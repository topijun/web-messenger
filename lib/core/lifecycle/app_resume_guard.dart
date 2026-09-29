import 'package:flutter/widgets.dart';

/// Debounces application-resume work so inactive→paused→resumed is one refresh.
class AppResumeGuard {
  /// Creates an [AppResumeGuard].
  AppResumeGuard({
    this.minInterval = const Duration(seconds: 2),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// Minimum time between accepted resume refreshes.
  final Duration minInterval;

  final DateTime Function() _clock;
  DateTime? _lastRefreshAt;
  var _away = false;
  var _busy = false;

  /// Whether a refresh is currently running.
  bool get isBusy => _busy;

  /// Records [state]. Returns true once when the app should refresh.
  bool shouldRefresh(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_away || _busy) {
        return false;
      }
      _away = false;
      final now = _clock();
      if (_lastRefreshAt != null &&
          now.difference(_lastRefreshAt!) < minInterval) {
        return false;
      }
      _lastRefreshAt = now;
      return true;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _away = true;
    }
    return false;
  }

  /// Runs [action] if no refresh is already in flight.
  Future<void> run(Future<void> Function() action) async {
    if (_busy) {
      return;
    }
    _busy = true;
    try {
      await action();
    } finally {
      _busy = false;
    }
  }
}
