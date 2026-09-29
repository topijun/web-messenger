import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_messenger/core/lifecycle/app_resume_guard.dart';

void main() {
  test('inactive then paused then resumed is a single refresh', () {
    final guard = AppResumeGuard();

    expect(guard.shouldRefresh(AppLifecycleState.inactive), isFalse);
    expect(guard.shouldRefresh(AppLifecycleState.paused), isFalse);
    expect(guard.shouldRefresh(AppLifecycleState.resumed), isTrue);
    expect(guard.shouldRefresh(AppLifecycleState.resumed), isFalse);
  });

  test('startup resumed does not refresh until the app has been away', () {
    final guard = AppResumeGuard();

    expect(guard.shouldRefresh(AppLifecycleState.resumed), isFalse);
  });

  test('repeated resumes inside the interval are ignored', () {
    var now = DateTime.utc(2026, 9, 24, 22);
    final guard = AppResumeGuard(
      minInterval: const Duration(seconds: 2),
      clock: () => now,
    );

    guard.shouldRefresh(AppLifecycleState.paused);
    expect(guard.shouldRefresh(AppLifecycleState.resumed), isTrue);

    guard.shouldRefresh(AppLifecycleState.paused);
    expect(guard.shouldRefresh(AppLifecycleState.resumed), isFalse);

    now = now.add(const Duration(seconds: 2));
    guard.shouldRefresh(AppLifecycleState.paused);
    expect(guard.shouldRefresh(AppLifecycleState.resumed), isTrue);
  });

  test('run ignores overlapping actions', () async {
    final guard = AppResumeGuard();
    final first = Completer<void>();
    var started = 0;

    final running = guard.run(() async {
      started += 1;
      await first.future;
    });
    await guard.run(() async {
      started += 1;
    });

    expect(started, 1);
    expect(guard.isBusy, isTrue);
    first.complete();
    await running;
    expect(guard.isBusy, isFalse);
  });
}
