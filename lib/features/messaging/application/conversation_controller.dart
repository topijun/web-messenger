import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/core/errors/message_error_mapper.dart';
import 'package:mobile_messenger/features/media/data/video_poster.dart';
import 'package:mobile_messenger/features/messaging/data/message_repository.dart';
import 'package:mobile_messenger/features/messaging/domain/chat_media_format.dart';
import 'package:mobile_messenger/features/messaging/domain/typing_label.dart';

/// Status of the conversation screen.
enum ConversationStatus {
  /// Fetching the first page of history.
  loading,

  /// Messages are available to render.
  ready,

  /// Loading failed.
  error,
}

/// Transient client-only send/receipt state. Not stored in the database.
enum ConversationItemStatus {
  /// Outgoing message waiting for the server.
  sending,

  /// Persisted on the server, not yet delivered to recipients.
  sent,

  /// At least one recipient has delivered.
  delivered,

  /// Every recipient has read.
  read,

  /// The send request failed and can be retried.
  failed,

  /// Incoming message from someone else.
  received,
}

/// Load state for decrypted chat media bytes.
enum ConversationMediaStatus {
  /// Media has not been requested.
  idle,

  /// Fetching decrypted bytes.
  loading,

  /// Bytes are available.
  loaded,

  /// Retrieval failed.
  failed,
}

/// One row in the conversation list, including optimistic outgoing items.
class ConversationItem {
  /// Creates a [ConversationItem].
  const ConversationItem({
    required this.localKey,
    required this.text,
    required this.createdAt,
    required this.status,
    required this.isMine,
    this.serverId,
    this.senderUsername,
    this.senderProfileImageId,
    this.receipts = const [],
    this.errorMessage,
    this.type = MessageType.text,
    this.mediaId,
    this.thumbnailMediaId,
    this.pendingBytes,
    this.mimeType,
    this.editedAt,
    this.deletedAt,
  });

  final String localKey;
  final int? serverId;
  final String text;
  final DateTime createdAt;
  final ConversationItemStatus status;
  final bool isMine;
  final String? senderUsername;
  final int? senderProfileImageId;
  final List<MessageReceipt> receipts;
  final String? errorMessage;
  final MessageType type;
  final int? mediaId;
  final int? thumbnailMediaId;
  final Uint8List? pendingBytes;
  final String? mimeType;
  final DateTime? editedAt;
  final DateTime? deletedAt;

  /// Whether this row is an image or video message.
  bool get isMedia => type == MessageType.image || type == MessageType.video;

  /// Whether this row is a WAV audio message.
  bool get isAudio => type == MessageType.audio;

  /// Soft-deleted placeholder; original content is not shown.
  bool get isDeleted => deletedAt != null;

  /// Edited and still visible.
  bool get isEdited => editedAt != null && deletedAt == null;

  /// Own persisted text that can still be edited.
  bool get canEdit =>
      isMine &&
      !isDeleted &&
      type == MessageType.text &&
      serverId != null &&
      status != ConversationItemStatus.sending &&
      status != ConversationItemStatus.failed;

  /// Own persisted message that can still be deleted.
  bool get canDelete =>
      isMine &&
      !isDeleted &&
      serverId != null &&
      status != ConversationItemStatus.sending &&
      status != ConversationItemStatus.failed;

  /// Builds an item from a server [MessageView].
  ///
  /// Phase 6 reads [Message.encryptedText] as plaintext.
  factory ConversationItem.fromView(MessageView view) {
    return ConversationItem(
      localKey: 's-${view.message.id}',
      serverId: view.message.id,
      text: view.message.encryptedText,
      createdAt: view.message.createdAt,
      status: statusFromView(view),
      isMine: view.isMine,
      senderUsername: view.senderUsername,
      senderProfileImageId: view.senderProfileImageId,
      receipts: view.receipts,
      type: view.message.type,
      mediaId: view.message.mediaId,
      thumbnailMediaId: view.thumbnailMediaId,
      editedAt: view.message.editedAt,
      deletedAt: view.message.deletedAt,
    );
  }

  ConversationItem copyWith({
    String? localKey,
    int? serverId,
    String? text,
    DateTime? createdAt,
    ConversationItemStatus? status,
    bool? isMine,
    String? senderUsername,
    int? senderProfileImageId,
    List<MessageReceipt>? receipts,
    String? errorMessage,
    MessageType? type,
    int? mediaId,
    int? thumbnailMediaId,
    Uint8List? pendingBytes,
    String? mimeType,
    DateTime? editedAt,
    DateTime? deletedAt,
  }) {
    return ConversationItem(
      localKey: localKey ?? this.localKey,
      serverId: serverId ?? this.serverId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      isMine: isMine ?? this.isMine,
      senderUsername: senderUsername ?? this.senderUsername,
      senderProfileImageId:
          senderProfileImageId ?? this.senderProfileImageId,
      receipts: receipts ?? this.receipts,
      errorMessage: errorMessage ?? this.errorMessage,
      type: type ?? this.type,
      mediaId: mediaId ?? this.mediaId,
      thumbnailMediaId: thumbnailMediaId ?? this.thumbnailMediaId,
      pendingBytes: pendingBytes ?? this.pendingBytes,
      mimeType: mimeType ?? this.mimeType,
      editedAt: editedAt ?? this.editedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  /// Derives ticks from recipient receipts.
  static ConversationItemStatus statusFromView(MessageView view) {
    return statusFromReceipts(isMine: view.isMine, receipts: view.receipts);
  }

  /// Derives ticks from recipient receipts.
  static ConversationItemStatus statusFromReceipts({
    required bool isMine,
    required List<MessageReceipt> receipts,
  }) {
    if (!isMine) {
      return ConversationItemStatus.received;
    }
    if (receipts.isEmpty) {
      return ConversationItemStatus.sent;
    }
    if (receipts.every((receipt) => receipt.readAt != null)) {
      return ConversationItemStatus.read;
    }
    if (receipts.any(
      (receipt) => receipt.deliveredAt != null || receipt.readAt != null,
    )) {
      return ConversationItemStatus.delivered;
    }
    return ConversationItemStatus.sent;
  }
}

/// Owns one chat's messages, send/retry, receipts, and realtime merge.
class ConversationController extends ChangeNotifier {
  /// Creates a [ConversationController].
  ConversationController({
    required MessageRepository repository,
    required this.chatId,
    this.selfUserId,
    this.selfProfileImageId,
    Stream<ChatEvent>? events,
    this.typingIdleTimeout = const Duration(milliseconds: 1500),
    this.typingHeartbeat = const Duration(milliseconds: 2000),
    this.typingStaleTimeout = const Duration(milliseconds: 5000),
    this.poster,
  }) : _repository = repository,
       _events = events;

  final MessageRepository _repository;
  final Stream<ChatEvent>? _events;

  /// Chat whose history this controller owns.
  final int chatId;

  /// Signed-in user, used to ignore our own typing events.
  final int? selfUserId;

  /// Current user's profile picture, used on optimistic outgoing rows.
  final int? selfProfileImageId;

  /// Idle pause before the local client emits typingStopped.
  final Duration typingIdleTimeout;

  /// Optional first-frame extractor for outgoing videos.
  final VideoPoster? poster;

  /// While still typing, refresh typingStarted this often.
  final Duration typingHeartbeat;

  /// Hide a remote typist if no refresh arrives within this duration.
  final Duration typingStaleTimeout;

  ConversationStatus _status = ConversationStatus.loading;
  final List<ConversationItem> _items = [];
  String? _errorMessage;
  var _hasMore = false;
  DateTime? _nextCreatedAt;
  int? _nextId;
  var _loadingOlder = false;
  var _seq = 0;
  StreamSubscription<ChatEvent>? _subscription;
  var _startedWatch = false;
  final Map<int, Uint8List> _mediaBytes = {};
  final Map<int, String> _mediaMimeTypes = {};
  final Map<int, ConversationMediaStatus> _mediaStatus = {};
  final Set<int> _mediaRequested = {};
  final Map<int, _RemoteTypist> _typists = {};
  var _localTyping = false;
  Timer? _idleTimer;
  Timer? _heartbeatTimer;
  ConversationItem? _editingItem;
  var _savingEdit = false;
  var _deleting = false;
  Future<void>? _loadInFlight;

  ConversationStatus get status => _status;
  List<ConversationItem> get items => List.unmodifiable(_items);
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  bool get loadingOlder => _loadingOlder;
  bool get isBusy => _status == ConversationStatus.loading;
  bool get isUploading =>
      _items.any((item) => item.status == ConversationItemStatus.sending);
  bool get isSavingEdit => _savingEdit;
  bool get isDeleting => _deleting;
  bool get isMutating => isUploading || _savingEdit || _deleting;
  ConversationItem? get editingItem => _editingItem;
  bool get isEditing => _editingItem != null;

  /// Label for remote typists in this chat, or null when none.
  String? get typingLabel =>
      formatTypingLabel(_typists.values.map((typist) => typist.username));

  /// Loads the newest page and starts realtime reconciliation.
  Future<void> load() {
    return _loadInFlight ??= _load(showSpinner: true).whenComplete(() {
      _loadInFlight = null;
    });
  }

  /// Reloads history after the app returns to the foreground.
  ///
  /// Does not replace visible messages with a spinner. Re-subscribes if the
  /// realtime watch stream has ended.
  Future<void> refreshOnResume() {
    return _loadInFlight ??= _load(showSpinner: false).whenComplete(() {
      _loadInFlight = null;
    });
  }

  Future<void> _load({required bool showSpinner}) async {
    if (showSpinner && _items.isEmpty) {
      _status = ConversationStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }
    try {
      final page = await _repository.listHistory(chatId: chatId);
      _replaceWithPage(page);
      _status = ConversationStatus.ready;
      _errorMessage = null;
      _listen();
      await _acknowledgeVisibleIncoming();
    } catch (error) {
      if (_items.isEmpty) {
        _status = ConversationStatus.error;
      }
      _errorMessage = MessageErrorMapper.map(error);
    }
    notifyListeners();
  }

  /// Loads the next older page. Existing items are kept and de-duplicated.
  Future<void> loadOlder() async {
    if (!_hasMore ||
        _loadingOlder ||
        _nextCreatedAt == null ||
        _nextId == null) {
      return;
    }
    _loadingOlder = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final page = await _repository.listHistory(
        chatId: chatId,
        beforeCreatedAt: _nextCreatedAt,
        beforeId: _nextId,
      );
      for (final view in page.messages) {
        _upsertView(view);
      }
      _hasMore = page.hasMore;
      _nextCreatedAt = page.nextCreatedAt;
      _nextId = page.nextId;
      _sort();
      await _acknowledgeVisibleIncoming();
    } catch (error) {
      _errorMessage = MessageErrorMapper.map(error);
    } finally {
      _loadingOlder = false;
      notifyListeners();
    }
  }

  /// Sends [text]. Failed items stay in the list and can be retried.
  Future<void> send(String text) async {
    await stopTyping();
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _errorMessage = 'Message text cannot be empty.';
      notifyListeners();
      return;
    }
    _seq += 1;
    final localKey = 'l-$_seq';
    _items.insert(
      0,
      ConversationItem(
        localKey: localKey,
        text: trimmed,
        createdAt: DateTime.now().toUtc(),
        status: ConversationItemStatus.sending,
        isMine: true,
        senderProfileImageId: selfProfileImageId,
      ),
    );
    _errorMessage = null;
    notifyListeners();
    await _submit(localKey, trimmed);
  }

  /// Uploads JPEG/PNG/MP4/WebM [bytes] as a chat message.
  Future<void> sendMedia(Uint8List bytes) async {
    await stopTyping();
    if (bytes.length > ChatMediaFormat.maxBytes) {
      _errorMessage = 'Images and videos must be at most 20 MB.';
      notifyListeners();
      return;
    }
    final format = ChatMediaFormat.detect(bytes);
    if (format == null) {
      _errorMessage = 'Chat media must be JPEG, PNG, MP4, WebM, MOV, or 3GP.';
      notifyListeners();
      return;
    }
    if (isUploading) {
      return;
    }

    _seq += 1;
    final localKey = 'l-$_seq';
    _items.insert(
      0,
      ConversationItem(
        localKey: localKey,
        text: '',
        createdAt: DateTime.now().toUtc(),
        status: ConversationItemStatus.sending,
        isMine: true,
        senderProfileImageId: selfProfileImageId,
        type: format.isVideo ? MessageType.video : MessageType.image,
        pendingBytes: bytes,
        mimeType: format.mimeType,
      ),
    );
    _errorMessage = null;
    notifyListeners();
    await _submitMedia(localKey, bytes, format);
  }

  /// Uploads WAV [bytes] as a chat audio message.
  Future<void> sendAudio(Uint8List bytes) async {
    await stopTyping();
    if (bytes.length <= ChatMediaFormat.wavHeaderBytes) {
      _errorMessage = 'Audio cannot be empty.';
      notifyListeners();
      return;
    }
    if (bytes.length > ChatMediaFormat.maxAudioBytes) {
      _errorMessage = 'Audio must be at most 10 MB.';
      notifyListeners();
      return;
    }
    if (ChatMediaFormat.detectAudio(bytes) == null) {
      _errorMessage = 'Audio must be WAV.';
      notifyListeners();
      return;
    }
    if (isUploading) {
      return;
    }

    _seq += 1;
    final localKey = 'l-$_seq';
    _items.insert(
      0,
      ConversationItem(
        localKey: localKey,
        text: '',
        createdAt: DateTime.now().toUtc(),
        status: ConversationItemStatus.sending,
        isMine: true,
        senderProfileImageId: selfProfileImageId,
        type: MessageType.audio,
        pendingBytes: bytes,
        mimeType: ChatMediaFormat.wavMime,
      ),
    );
    _errorMessage = null;
    notifyListeners();
    await _submitAudio(localKey, bytes);
  }

  /// Retries a failed outgoing [localKey].
  Future<void> retry(String localKey) async {
    final index = _items.indexWhere((item) => item.localKey == localKey);
    if (index < 0) {
      return;
    }
    final item = _items[index];
    if (item.status != ConversationItemStatus.failed) {
      return;
    }
    _items[index] = item.copyWith(
      status: ConversationItemStatus.sending,
      errorMessage: '',
    );
    _errorMessage = null;
    notifyListeners();
    final pending = item.pendingBytes;
    if (pending != null) {
      if (item.type == MessageType.audio) {
        await _submitAudio(localKey, pending);
      } else {
        final format = ChatMediaFormat.detect(pending);
        if (format == null) {
          _markFailed(localKey, Exception('unsupportedFormat'));
          notifyListeners();
          return;
        }
        await _submitMedia(localKey, pending, format);
      }
    } else {
      await _submit(localKey, item.text);
    }
  }

  /// Applies a realtime or test event. Duplicate server ids are merged.
  void applyEvent(ChatEvent event) {
    if (event.chatId != chatId) {
      return;
    }
    if (_isMessageKind(event.kind) && event.message != null) {
      _upsertView(event.message!);
      _sort();
      notifyListeners();
      if (event.kind == ChatEventKind.message) {
        final view = event.message!;
        final id = view.message.id;
        if (!view.isMine && id != null) {
          unawaited(_acknowledge(messageIds: [id], read: true));
        }
      }
      return;
    }
    if (event.kind == ChatEventKind.receipt && event.receipt != null) {
      _applyReceipt(event.receipt!);
      notifyListeners();
      return;
    }
    if (event.kind == ChatEventKind.typingStarted ||
        event.kind == ChatEventKind.typingStopped) {
      _applyTyping(event);
    }
  }

  /// Puts [item] into composer edit mode. Cancel leaves the message unchanged.
  void beginEdit(ConversationItem item) {
    if (!item.canEdit) {
      return;
    }
    unawaited(stopTyping());
    _editingItem = item;
    _errorMessage = null;
    notifyListeners();
  }

  /// Leaves edit mode without calling the server.
  void cancelEdit() {
    if (_editingItem == null && !_savingEdit) {
      return;
    }
    _editingItem = null;
    _savingEdit = false;
    notifyListeners();
  }

  /// Saves composer text as an edit of [editingItem].
  Future<void> saveEdit(String text) async {
    final item = _editingItem;
    final messageId = item?.serverId;
    if (item == null || messageId == null || _savingEdit) {
      return;
    }
    await stopTyping();
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _errorMessage = 'Message text cannot be empty.';
      notifyListeners();
      return;
    }
    _savingEdit = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final view = await _repository.editText(
        messageId: messageId,
        encryptedText: trimmed,
      );
      _editingItem = null;
      _upsertView(view);
      _sort();
    } catch (error) {
      _errorMessage = MessageErrorMapper.map(error);
    }
    _savingEdit = false;
    notifyListeners();
  }

  /// Soft-deletes a persisted own message. Failure leaves the local item.
  Future<void> deleteMessage(ConversationItem item) async {
    final messageId = item.serverId;
    if (!item.canDelete || messageId == null || _deleting) {
      return;
    }
    if (_editingItem?.serverId == messageId) {
      _editingItem = null;
    }
    _deleting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final view = await _repository.deleteMessage(messageId: messageId);
      _upsertView(view);
      _sort();
    } catch (error) {
      _errorMessage = MessageErrorMapper.map(error);
    }
    _deleting = false;
    notifyListeners();
  }

  /// Updates local typing from composer text. Empty text stops typing.
  void onComposerTextChanged(String text) {
    if (text.trim().isEmpty) {
      unawaited(stopTyping());
      return;
    }
    _idleTimer?.cancel();
    _idleTimer = Timer(typingIdleTimeout, () {
      unawaited(stopTyping());
    });
    if (_localTyping) {
      return;
    }
    _localTyping = true;
    unawaited(_emitTyping(true));
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(typingHeartbeat, (_) {
      unawaited(_emitTyping(true));
    });
  }

  /// Emits typingStopped if this client was advertising typing.
  Future<void> stopTyping() async {
    _idleTimer?.cancel();
    _heartbeatTimer?.cancel();
    _idleTimer = null;
    _heartbeatTimer = null;
    if (!_localTyping) {
      return;
    }
    _localTyping = false;
    await _emitTyping(false);
  }

  /// Decrypted bytes for [mediaId], if already loaded or sent from this device.
  Uint8List? mediaBytes(int mediaId) => _mediaBytes[mediaId];

  /// MIME type for loaded [mediaId].
  String? mediaMimeType(int mediaId) => _mediaMimeTypes[mediaId];

  /// Load status for [mediaId].
  ConversationMediaStatus mediaStatus(int mediaId) {
    return _mediaStatus[mediaId] ?? ConversationMediaStatus.idle;
  }

  /// Fetches decrypted media when the UI needs it. History stays metadata-only.
  Future<void> ensureMedia(int mediaId) async {
    if (_items.any((item) => item.mediaId == mediaId && item.isDeleted)) {
      _dropMedia(mediaId);
      return;
    }
    if (_mediaBytes.containsKey(mediaId) || _mediaRequested.contains(mediaId)) {
      return;
    }
    _mediaRequested.add(mediaId);
    _mediaStatus[mediaId] = ConversationMediaStatus.loading;
    notifyListeners();
    try {
      final media = await _repository.getChatMedia(mediaId: mediaId);
      _mediaBytes[mediaId] = Uint8List.sublistView(media.bytes);
      _mediaMimeTypes[mediaId] = media.mimeType;
      _mediaStatus[mediaId] = ConversationMediaStatus.loaded;
    } catch (error) {
      _mediaRequested.remove(mediaId);
      _mediaStatus[mediaId] = ConversationMediaStatus.failed;
      _errorMessage = MessageErrorMapper.map(error);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(stopTyping());
    _clearRemoteTyping(notify: false);
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _submit(String localKey, String text) async {
    try {
      final view = await _repository.sendText(
        chatId: chatId,
        encryptedText: text,
      );
      _removeLocal(localKey);
      _upsertView(view);
      _sort();
    } catch (error) {
      _markFailed(localKey, error);
    }
    notifyListeners();
  }

  Future<void> _submitMedia(
    String localKey,
    Uint8List bytes,
    ChatMediaFormat format,
  ) async {
    try {
      Uint8List? posterBytes;
      if (format.isVideo && poster != null) {
        posterBytes = await poster!.extract(
          bytes: bytes,
          mimeType: format.mimeType,
        );
      }
      final view = await _repository.sendMedia(
        chatId: chatId,
        bytes: ByteData.sublistView(bytes),
        thumbnailBytes: posterBytes == null
            ? null
            : ByteData.sublistView(posterBytes),
      );
      final mediaId = view.message.mediaId;
      if (mediaId != null) {
        _mediaBytes[mediaId] = bytes;
        _mediaMimeTypes[mediaId] = format.mimeType;
        _mediaStatus[mediaId] = ConversationMediaStatus.loaded;
        _mediaRequested.add(mediaId);
      }
      final thumbnailId = view.thumbnailMediaId;
      if (thumbnailId != null && posterBytes != null) {
        _mediaBytes[thumbnailId] = posterBytes;
        _mediaMimeTypes[thumbnailId] = 'image/jpeg';
        _mediaStatus[thumbnailId] = ConversationMediaStatus.loaded;
        _mediaRequested.add(thumbnailId);
      }
      _removeLocal(localKey);
      _upsertView(view);
      _sort();
    } catch (error) {
      _markFailed(localKey, error);
    }
    notifyListeners();
  }

  Future<void> _submitAudio(String localKey, Uint8List bytes) async {
    try {
      final view = await _repository.sendAudio(
        chatId: chatId,
        bytes: ByteData.sublistView(bytes),
      );
      final mediaId = view.message.mediaId;
      if (mediaId != null) {
        _mediaBytes[mediaId] = bytes;
        _mediaMimeTypes[mediaId] = ChatMediaFormat.wavMime;
        _mediaStatus[mediaId] = ConversationMediaStatus.loaded;
        _mediaRequested.add(mediaId);
      }
      _removeLocal(localKey);
      _upsertView(view);
      _sort();
    } catch (error) {
      _markFailed(localKey, error);
    }
    notifyListeners();
  }

  void _markFailed(String localKey, Object error) {
    final mapped = MessageErrorMapper.map(error);
    _errorMessage = mapped;
    final index = _items.indexWhere((item) => item.localKey == localKey);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(
        status: ConversationItemStatus.failed,
        errorMessage: mapped,
      );
    }
  }

  void _listen() {
    if (_startedWatch) {
      return;
    }
    _startedWatch = true;
    _subscription = (_events ?? _repository.watch()).listen(
      applyEvent,
      onError: (_) => _onWatchLost(),
      onDone: _onWatchLost,
      cancelOnError: true,
    );
  }

  void _onWatchLost() {
    _subscription = null;
    _startedWatch = false;
    _clearRemoteTyping();
  }

  void _replaceWithPage(MessageHistoryPage page) {
    final pending = [
      for (final item in _items)
        if (item.serverId == null) item,
    ];
    _items
      ..clear()
      ..addAll([
        for (final view in page.messages) ConversationItem.fromView(view),
      ])
      ..addAll(pending);
    _hasMore = page.hasMore;
    _nextCreatedAt = page.nextCreatedAt;
    _nextId = page.nextId;
    _sort();
  }

  void _upsertView(MessageView view) {
    final id = view.message.id;
    if (id == null) {
      return;
    }
    final next = ConversationItem.fromView(view);
    if (next.isDeleted) {
      final mediaId = next.mediaId;
      if (mediaId != null) {
        _dropMedia(mediaId);
      }
      if (_editingItem?.serverId == id) {
        _editingItem = null;
      }
    }
    final existing = _items.indexWhere((item) => item.serverId == id);
    if (existing >= 0) {
      final previous = _items[existing];
      _items[existing] = next.isDeleted
          ? next
          : next.copyWith(
              pendingBytes: previous.pendingBytes,
              mimeType: previous.mimeType,
            );
      return;
    }
    if (view.isMine) {
      final local = _items.indexWhere(
        (item) =>
            item.serverId == null &&
            item.isMine &&
            (item.status == ConversationItemStatus.sending ||
                item.status == ConversationItemStatus.failed) &&
            ((item.isMedia &&
                    item.isMedia == next.isMedia &&
                    item.type == next.type) ||
                (item.isAudio && next.type == MessageType.audio) ||
                (!item.isMedia &&
                    !item.isAudio &&
                    item.text == view.message.encryptedText)),
      );
      if (local >= 0) {
        final previous = _items[local];
        _items[local] = next.copyWith(
          pendingBytes: previous.pendingBytes,
          mimeType: previous.mimeType,
        );
        return;
      }
    }
    _items.add(next);
  }

  void _applyReceipt(MessageReceipt receipt) {
    final index = _items.indexWhere(
      (item) => item.serverId == receipt.messageId,
    );
    if (index < 0) {
      return;
    }
    final item = _items[index];
    final receipts = [
      for (final existing in item.receipts)
        if (existing.userId != receipt.userId) existing,
      receipt,
    ];
    _items[index] = item.copyWith(
      receipts: receipts,
      status: ConversationItem.statusFromReceipts(
        isMine: item.isMine,
        receipts: receipts,
      ),
    );
  }

  void _removeLocal(String localKey) {
    _items.removeWhere(
      (item) => item.localKey == localKey && item.serverId == null,
    );
  }

  void _sort() {
    _items.sort((a, b) {
      final compared = b.createdAt.compareTo(a.createdAt);
      if (compared != 0) {
        return compared;
      }
      final aId = a.serverId ?? 0;
      final bId = b.serverId ?? 0;
      if (aId != bId) {
        return bId.compareTo(aId);
      }
      return b.localKey.compareTo(a.localKey);
    });
  }

  Future<void> _acknowledgeVisibleIncoming() {
    final ids = [
      for (final item in _items)
        if (!item.isMine && item.serverId != null) item.serverId!,
    ];
    return _acknowledge(messageIds: ids, read: true);
  }

  Future<void> _acknowledge({
    required List<int> messageIds,
    required bool read,
  }) async {
    if (messageIds.isEmpty) {
      return;
    }
    try {
      await _repository.markDelivered(messageIds: messageIds);
      if (read) {
        await _repository.markRead(messageIds: messageIds);
      }
    } catch (_) {
      // Receipts are recovered on the next history load.
    }
  }

  void _dropMedia(int mediaId) {
    _mediaBytes.remove(mediaId);
    _mediaMimeTypes.remove(mediaId);
    _mediaStatus.remove(mediaId);
    _mediaRequested.remove(mediaId);
  }

  bool _isMessageKind(ChatEventKind kind) {
    return kind == ChatEventKind.message ||
        kind == ChatEventKind.messageEdited ||
        kind == ChatEventKind.messageDeleted;
  }

  Future<void> _emitTyping(bool isTyping) async {
    try {
      await _repository.setTyping(chatId: chatId, isTyping: isTyping);
    } catch (_) {
      // Typing is non-critical; sending messages must still work.
    }
  }

  void _applyTyping(ChatEvent event) {
    final userId = event.typingUserId;
    final username = event.typingUsername;
    if (userId == null || username == null || username.isEmpty) {
      return;
    }
    if (selfUserId != null && userId == selfUserId) {
      return;
    }
    if (event.kind == ChatEventKind.typingStopped) {
      _typists.remove(userId)?.expiry.cancel();
      notifyListeners();
      return;
    }
    final existing = _typists[userId];
    existing?.expiry.cancel();
    _typists[userId] = _RemoteTypist(
      userId: userId,
      username: username,
      expiry: Timer(typingStaleTimeout, () {
        _typists.remove(userId);
        notifyListeners();
      }),
    );
    notifyListeners();
  }

  void _clearRemoteTyping({bool notify = true}) {
    for (final typist in _typists.values) {
      typist.expiry.cancel();
    }
    if (_typists.isEmpty) {
      return;
    }
    _typists.clear();
    if (notify) {
      notifyListeners();
    }
  }
}

class _RemoteTypist {
  _RemoteTypist({
    required this.userId,
    required this.username,
    required this.expiry,
  });

  final int userId;
  final String username;
  final Timer expiry;
}
