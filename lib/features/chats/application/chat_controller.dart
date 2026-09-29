import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:messenger_client/messenger_client.dart';
import 'package:mobile_messenger/core/errors/chat_error_mapper.dart';
import 'package:mobile_messenger/features/chats/data/chat_repository.dart';

/// Status of the chat home screen.
enum ChatStatus {
  /// Fetching chats and invitations.
  loading,

  /// Lists are available.
  ready,

  /// Loading failed.
  error,
}

/// Owns the signed-in user's chats and pending invitations.
///
/// Unread badges are derived from server [ChatSummary.unreadCount] plus
/// unique realtime message ids. Mute suppresses OS/push notifications
/// (not implemented here) but does not hide in-app unread counts: mute is
/// notification suppression, not unread-state suppression. Archive is
/// unchanged; a new message does not unarchive a chat.
///
/// Realtime [ChatEvent]s are the primary live-update path. [poll] is a
/// silent safety net used by the visible Home/Invitations UI.
class ChatController extends ChangeNotifier {
  /// Creates a [ChatController].
  ///
  /// [events] is a fixed stream (tests). [watch] is called again after the
  /// stream ends so a dropped Serverpod connection can be re-opened.
  ChatController({
    required ChatRepository repository,
    Stream<ChatEvent>? events,
    Stream<ChatEvent>? Function()? watch,
  }) : _repository = repository,
       _events = events,
       _watch = watch {
    _listen();
  }

  final ChatRepository _repository;
  final Stream<ChatEvent>? _events;
  final Stream<ChatEvent>? Function()? _watch;
  StreamSubscription<ChatEvent>? _subscription;

  ChatStatus _status = ChatStatus.loading;
  List<ChatSummary> _chats = const [];
  List<ChatInvitationView> _invitations = const [];
  String? _errorMessage;
  var _actionBusy = false;
  var _searching = false;
  ContactSearchResult? _contact;
  String? _contactFeedback;
  Future<void>? _loadInFlight;
  int? _activeChatId;
  final _countedUnreadIds = <int>{};
  final _processedReadIds = <int>{};

  ChatStatus get status => _status;
  List<ChatSummary> get chats => _chats;

  /// Chats shown on Home. Archived chats stay in [chats] but are hidden here.
  List<ChatSummary> get activeChats => [
    for (final summary in _chats)
      if (!summary.membership.archived) summary,
  ];

  /// Chats shown on Profile → Archived.
  List<ChatSummary> get archivedChats => [
    for (final summary in _chats)
      if (summary.membership.archived) summary,
  ];

  List<ChatInvitationView> get invitations => _invitations;
  String? get errorMessage => _errorMessage;
  bool get isBusy => _status == ChatStatus.loading || _actionBusy;
  bool get actionBusy => _actionBusy;
  bool get searching => _searching;
  ContactSearchResult? get contact => _contact;
  String? get contactFeedback => _contactFeedback;

  /// Pending incoming invitations. Used for the Home invitations badge.
  int get pendingInvitationCount => _invitations.length;

  /// Chat the user is currently viewing, if any.
  int? get activeChatId => _activeChatId;

  /// Unread count shown on the chat list for [summary].
  ///
  /// The open conversation is treated as viewed and never shows a badge.
  int unreadCountFor(ChatSummary summary) {
    if (summary.chat.id == _activeChatId) {
      return 0;
    }
    return summary.unreadCount;
  }

  /// Marks [chatId] as the conversation the user is viewing.
  ///
  /// Clears that chat's list badge immediately. Existing [markRead] in the
  /// conversation remains the source of truth for receipts.
  void setActiveChat(int? chatId) {
    if (_activeChatId == chatId) {
      return;
    }
    _activeChatId = chatId;
    if (chatId != null) {
      _setUnread(chatId, 0);
    }
    notifyListeners();
  }

  /// Applies a realtime event without incrementing counters blindly.
  ///
  /// Message and invitation identities are tracked so duplicate watch
  /// events and a later resume refresh cannot double-count the same row.
  void applyEvent(ChatEvent event) {
    var changed = false;
    switch (event.kind) {
      case ChatEventKind.message:
        changed = _applyIncomingMessage(event);
      case ChatEventKind.receipt:
        changed = _applyReceipt(event);
      case ChatEventKind.invitation:
        changed = _applyInvitation(event);
      case ChatEventKind.typingStarted:
      case ChatEventKind.typingStopped:
      case ChatEventKind.messageEdited:
      case ChatEventKind.messageDeleted:
        break;
    }
    if (changed) {
      notifyListeners();
    }
  }

  /// Loads chats and pending invitations for the signed-in user.
  ///
  /// Concurrent calls join the in-flight request. [silent] keeps existing
  /// lists visible instead of flipping back to a full-screen spinner.
  /// [background] keeps the current lists and hides the error banner when
  /// a safety-net poll fails.
  Future<void> load({bool silent = false, bool background = false}) {
    _listen();
    return _loadInFlight ??= _load(silent: silent, background: background)
        .whenComplete(() {
          _loadInFlight = null;
        });
  }

  /// Silent background reconciliation. Failures keep visible state.
  Future<void> poll() => load(silent: true, background: true);

  /// Re-subscribes if the realtime watch stream has ended.
  void resubscribeWatch() => _listen();

  Future<void> _load({required bool silent, required bool background}) async {
    final showSpinner = !silent || (_chats.isEmpty && _invitations.isEmpty);
    if (showSpinner && !background) {
      _status = ChatStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }
    try {
      await _refresh();
      _status = ChatStatus.ready;
      _errorMessage = null;
    } catch (error) {
      if (background && _keepVisibleStateOnBackgroundFailure) {
        notifyListeners();
        return;
      }
      _status = ChatStatus.error;
      _errorMessage =
          error is _RefreshFailure &&
              error.invitationsFailed &&
              !error.chatsFailed
          ? 'Could not load invitations. Please try again.'
          : 'Could not load chats. Please try again.';
    }
    notifyListeners();
  }

  bool get _keepVisibleStateOnBackgroundFailure {
    return _chats.isNotEmpty ||
        _invitations.isNotEmpty ||
        _status == ChatStatus.ready;
  }

  /// Invites [username] to a new direct chat.
  Future<bool> inviteDirect(String username) {
    return _runAction(() async {
      await _repository.inviteDirect(username: username.trim());
      await _refresh();
    });
  }

  /// Creates a group named [name] with the current user as admin.
  Future<bool> createGroup(String name) {
    return _runAction(() async {
      await _repository.createGroup(name: name.trim());
      await _refresh();
    });
  }

  /// Invites [username] to [chatId]. Caller must be a group admin.
  Future<bool> inviteToGroup({required int chatId, required String username}) {
    return _runAction(() async {
      await _repository.inviteToGroup(
        chatId: chatId,
        username: username.trim(),
      );
      await _refresh();
    });
  }

  /// Accepts a pending invitation addressed to the current user.
  Future<bool> accept(int invitationId) {
    return _runAction(() async {
      await _repository.accept(invitationId: invitationId);
      await _refresh();
    });
  }

  /// Declines a pending invitation addressed to the current user.
  Future<bool> decline(int invitationId) {
    return _runAction(() async {
      await _repository.decline(invitationId: invitationId);
      await _refresh();
    });
  }

  /// Archives or unarchives [chatId] for the current user.
  Future<bool> setArchived({required int chatId, required bool archived}) {
    return _runAction(() async {
      final membership = await _repository.setArchived(
        chatId: chatId,
        archived: archived,
      );
      _replaceMembership(chatId, membership);
    });
  }

  /// Mutes or unmutes [chatId] for the current user only.
  Future<bool> setMuted({
    required int chatId,
    required bool notificationsMuted,
  }) {
    return _runAction(() async {
      final membership = await _repository.setMuted(
        chatId: chatId,
        notificationsMuted: notificationsMuted,
      );
      _replaceMembership(chatId, membership);
    });
  }

  /// Members of [chatId], if the current user belongs to it.
  Future<List<ChatMember>> listMembers(int chatId) {
    return _repository.listMembers(chatId: chatId);
  }

  /// Looks up a user by username for invitation targeting.
  Future<MessengerUser?> lookupByUsername(String username) {
    return _repository.lookupByUsername(username: username.trim());
  }

  /// Finds a registered user by exact username or email.
  Future<void> searchContact(String query) async {
    final trimmed = query.trim();
    _searching = true;
    _contact = null;
    _contactFeedback = null;
    _errorMessage = null;
    notifyListeners();
    if (trimmed.isEmpty) {
      _contactFeedback = 'Enter a username or email.';
      _searching = false;
      notifyListeners();
      return;
    }
    try {
      _contact = await _repository.searchContact(query: trimmed);
      if (_contact == null) {
        _contactFeedback = 'No matching user was found.';
      }
    } catch (error) {
      _contactFeedback = ChatErrorMapper.map(error);
    } finally {
      _searching = false;
      notifyListeners();
    }
  }

  /// Clears the last contact search so a typed query change does not linger.
  void clearContactSearch() {
    if (_contact == null && _contactFeedback == null && !_searching) {
      return;
    }
    _contact = null;
    _contactFeedback = null;
    notifyListeners();
  }

  @override
  void dispose() {
    final subscription = _subscription;
    _subscription = null;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
    super.dispose();
  }

  void _listen() {
    if (_subscription != null) {
      return;
    }
    final stream = _events ?? _watch?.call();
    if (stream == null) {
      return;
    }
    _subscription = stream.listen(
      applyEvent,
      onError: (_) => _onWatchLost(),
      onDone: _onWatchLost,
      cancelOnError: true,
    );
  }

  void _onWatchLost() {
    _subscription = null;
  }

  Future<bool> _runAction(Future<void> Function() action) async {
    if (_actionBusy) {
      return false;
    }
    _actionBusy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      _status = ChatStatus.ready;
      return true;
    } catch (error) {
      _errorMessage = ChatErrorMapper.map(error);
      if (_status == ChatStatus.loading) {
        _status = ChatStatus.error;
      }
      return false;
    } finally {
      _actionBusy = false;
      notifyListeners();
    }
  }

  Future<void> _refresh() async {
    List<ChatSummary>? chats;
    List<ChatInvitationView>? invitations;
    Object? chatsError;
    Object? invitationsError;

    await Future.wait([
      () async {
        try {
          chats = await _repository.listMine();
        } catch (error) {
          chatsError = error;
        }
      }(),
      () async {
        try {
          invitations = await _repository.listPendingMine();
        } catch (error) {
          invitationsError = error;
        }
      }(),
    ]);

    if (chats != null) {
      _chats = chats!;
      if (_activeChatId != null) {
        _setUnread(_activeChatId!, 0);
      }
    }
    if (invitations != null) {
      _invitations = invitations!;
    }

    if (chatsError != null || invitationsError != null) {
      throw _RefreshFailure(
        chatsFailed: chatsError != null,
        invitationsFailed: invitationsError != null,
      );
    }
  }

  bool _applyIncomingMessage(ChatEvent event) {
    final view = event.message;
    if (view == null) {
      return false;
    }
    var changed = _touchLastMessageAt(event.chatId, view.message.createdAt);
    if (view.isMine || view.message.deletedAt != null) {
      return changed;
    }
    final messageId = view.message.id;
    if (messageId == null) {
      return changed;
    }
    if (_activeChatId == event.chatId) {
      return changed;
    }
    if (!_countedUnreadIds.add(messageId)) {
      return changed;
    }
    _adjustUnread(event.chatId, 1);
    return true;
  }

  bool _applyReceipt(ChatEvent event) {
    final receipt = event.receipt;
    if (receipt == null || receipt.readAt == null) {
      return false;
    }
    final summary = _findChat(event.chatId);
    if (summary == null || summary.membership.userId != receipt.userId) {
      return false;
    }
    if (!_processedReadIds.add(receipt.messageId)) {
      return false;
    }
    _countedUnreadIds.remove(receipt.messageId);
    if (summary.unreadCount <= 0) {
      return false;
    }
    _adjustUnread(event.chatId, -1);
    return true;
  }

  bool _applyInvitation(ChatEvent event) {
    final view = event.invitation;
    if (view == null) {
      return false;
    }
    if (view.invitation.status != ChatInvitationStatus.pending) {
      return false;
    }
    final id = view.invitation.id;
    if (id != null &&
        _invitations.any((existing) => existing.invitation.id == id)) {
      return false;
    }
    _invitations = [view, ..._invitations];
    return true;
  }

  bool _touchLastMessageAt(int chatId, DateTime createdAt) {
    final summary = _findChat(chatId);
    if (summary == null) {
      return false;
    }
    final current = summary.chat.lastMessageAt;
    if (current != null && !createdAt.isAfter(current)) {
      return false;
    }
    _replaceChat(
      summary.copyWith(chat: summary.chat.copyWith(lastMessageAt: createdAt)),
    );
    _sortChats();
    return true;
  }

  void _adjustUnread(int chatId, int delta) {
    final summary = _findChat(chatId);
    if (summary == null) {
      return;
    }
    final next = summary.unreadCount + delta;
    _setUnread(chatId, next < 0 ? 0 : next);
  }

  void _setUnread(int chatId, int unreadCount) {
    final summary = _findChat(chatId);
    if (summary == null || summary.unreadCount == unreadCount) {
      return;
    }
    _replaceChat(summary.copyWith(unreadCount: unreadCount));
  }

  void _replaceChat(ChatSummary next) {
    _chats = [
      for (final summary in _chats)
        if (summary.chat.id == next.chat.id) next else summary,
    ];
  }

  ChatSummary? _findChat(int chatId) {
    for (final summary in _chats) {
      if (summary.chat.id == chatId) {
        return summary;
      }
    }
    return null;
  }

  void _sortChats() {
    _chats = [..._chats]..sort((a, b) => _compareChats(a.chat, b.chat));
  }

  int _compareChats(Chat a, Chat b) {
    final aLast = a.lastMessageAt;
    final bLast = b.lastMessageAt;
    if (aLast == null && bLast == null) {
      return (b.id ?? 0).compareTo(a.id ?? 0);
    }
    if (aLast == null) {
      return 1;
    }
    if (bLast == null) {
      return -1;
    }
    final compared = bLast.compareTo(aLast);
    if (compared != 0) {
      return compared;
    }
    return (b.id ?? 0).compareTo(a.id ?? 0);
  }

  void _replaceMembership(int chatId, ChatParticipant membership) {
    _chats = [
      for (final summary in _chats)
        if (summary.chat.id == chatId)
          ChatSummary(
            chat: summary.chat,
            membership: membership,
            otherUsernames: summary.otherUsernames,
            otherAvatars: summary.otherAvatars,
            unreadCount: summary.unreadCount,
          )
        else
          summary,
    ];
  }
}

class _RefreshFailure implements Exception {
  const _RefreshFailure({
    required this.chatsFailed,
    required this.invitationsFailed,
  });

  final bool chatsFailed;
  final bool invitationsFailed;
}
