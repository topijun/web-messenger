import 'package:flutter/material.dart';
import 'package:mobile_messenger/features/auth/domain/auth_state.dart';
import 'package:mobile_messenger/features/auth/presentation/auth_scope.dart';
import 'package:mobile_messenger/features/auth/presentation/login_screen.dart';
import 'package:mobile_messenger/features/home/presentation/home_screen.dart';

/// Routes between session restore, login, and the authenticated home.
class AuthGate extends StatelessWidget {
  /// Creates an [AuthGate].
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final status = auth.state.status;
    return switch (status) {
      AuthStatus.checking => const _AuthLoadingScreen(),
      AuthStatus.authenticated => HomeScreen(
        key: ValueKey<String>(auth.state.username ?? 'authenticated'),
      ),
      AuthStatus.unauthenticated ||
      AuthStatus.awaitingVerification ||
      AuthStatus.error => const _UnauthenticatedNavigator(),
    };
  }
}

class _UnauthenticatedNavigator extends StatelessWidget {
  const _UnauthenticatedNavigator();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: const ValueKey<String>('unauthenticated'),
      onGenerateRoute: (_) {
        return MaterialPageRoute<void>(
          builder: (_) => const LoginScreen(),
        );
      },
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Checking signed-in status…'),
          ],
        ),
      ),
    );
  }
}
