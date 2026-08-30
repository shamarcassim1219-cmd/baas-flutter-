import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/api.dart';
import 'core/theme.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: BaasApp()));
}

class BaasApp extends StatelessWidget {
  const BaasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MYBAAS Baas',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: const Gate(),
    );
  }
}

class Gate extends StatefulWidget {
  const Gate({super.key});
  @override
  State<Gate> createState() => _GateState();
}

class _GateState extends State<Gate> {
  bool _loading = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final t = await Api.i.token;
    setState(() {
      _loggedIn = t != null && t.isNotEmpty;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _loggedIn ? const HomeShell() : const LoginScreen();
  }
}
