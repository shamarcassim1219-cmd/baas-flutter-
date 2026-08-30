import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding/login_screen.dart';
import 'screens/home/home_shell.dart';

void main() {
  runApp(const BaasApp());
}

class BaasApp extends StatelessWidget {
  const BaasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MYBAAS for Baas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _StartupGate(),
    );
  }
}

/// Checks for an existing session and picks LoginScreen or
/// HomeShell accordingly - no guest flow here, unlike the customer
/// app, since a Baas account always needs to be real.
class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  bool _ready = false;
  bool _loggedIn = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final loggedIn = await AuthService.instance.isLoggedIn();
      if (!mounted) return;
      setState(() {
        _loggedIn = loggedIn;
        _ready = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Unable to connect. Please check your internet connection and try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: AppTheme.light.scaffoldBackgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off, size: 40, color: AppColors.textMuted),
                const SizedBox(height: 12),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _error = null);
                    _check();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_ready) {
      return Scaffold(
        backgroundColor: AppTheme.light.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return _loggedIn ? const HomeShell() : const LoginScreen();
  }
}
