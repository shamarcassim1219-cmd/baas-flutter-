import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/auth_service.dart';
import 'services/push_notification_service.dart';
import 'theme/app_theme.dart';
import 'localization/locale_controller.dart';
import 'screens/onboarding/language_screen.dart';
import 'screens/onboarding/login_screen.dart';
import 'screens/home/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(
    ChangeNotifierProvider(
      create: (_) => LocaleController(),
      child: const BaasApp(),
    ),
  );
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

/// Checks for an existing session and picks LanguageScreen (brand
/// new install, language never chosen), LoginScreen, or HomeShell
/// accordingly - no guest flow here, unlike the customer app, since
/// a Baas account always needs to be real.
class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  bool _ready = false;
  bool _loggedIn = false;
  bool _needsLanguageScreen = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    try {
      final locale = context.read<LocaleController>();
      await locale.load();

      final loggedIn = await AuthService.instance.isLoggedIn();

      if (loggedIn) {
        PushNotificationService.instance.initialize();
      }

      if (!mounted) return;
      setState(() {
        _loggedIn = loggedIn;
        _needsLanguageScreen = !loggedIn && !locale.hasSelected;
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

    if (_needsLanguageScreen) {
      return const LanguageScreen();
    }

    return _loggedIn ? const HomeShell() : const LoginScreen();
  }
}
