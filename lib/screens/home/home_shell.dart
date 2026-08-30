import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../onboarding/login_screen.dart';

/// Placeholder home screen - confirms the login flow works
/// end-to-end. Job requests (accept/reject), wallet + top-up,
/// profile/skills/rates, and the online/offline toggle get built
/// out here next.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await ApiClient.instance.getUser();
    if (!mounted) return;
    setState(() => _user = user);
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstName = (_user?['firstName'] as String?) ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('MYBAAS')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 48, color: AppColors.success),
                const SizedBox(height: 16),
                Text(
                  firstName.isNotEmpty ? 'Welcome, $firstName!' : 'Welcome!',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Job requests, wallet, and profile screens\nare coming next.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),
                OutlinedButton(onPressed: _logout, child: const Text('Logout')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
