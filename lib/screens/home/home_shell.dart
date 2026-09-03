import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../localization/locale_controller.dart';
import 'home_dashboard.dart';
import '../jobs/job_requests_screen.dart';
import '../wallet/wallet_screen.dart';
import '../profile/profile_screen.dart';

/// Four-tab shell: Home (status + earnings), Jobs, Wallet, Settings -
/// the Baas app's main navigation once logged in.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  final _homeDashboardKey = GlobalKey<HomeDashboardState>();

  late final List<Widget> _tabs = [
    HomeDashboard(key: _homeDashboardKey),
    const JobRequestsScreen(),
    const WalletScreen(),
    const ProfileScreen(),
  ];

  void _onTap(int index) {
    setState(() => _index = index);
    // Switching back to Home should reflect anything that changed
    // while on another tab - most importantly, accepting a job
    // takes the Baas offline automatically, and IndexedStack alone
    // wouldn't otherwise re-trigger a refresh of the already-built
    // Home tab to show that.
    if (index == 0) {
      _homeDashboardKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleController>().t;

    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onTap,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home), label: t('home')),
          BottomNavigationBarItem(icon: const Icon(Icons.work_outline), activeIcon: const Icon(Icons.work), label: t('jobs')),
          BottomNavigationBarItem(icon: const Icon(Icons.account_balance_wallet_outlined), activeIcon: const Icon(Icons.account_balance_wallet), label: t('wallet')),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline), activeIcon: const Icon(Icons.person), label: t('settings')),
        ],
      ),
    );
  }
}
