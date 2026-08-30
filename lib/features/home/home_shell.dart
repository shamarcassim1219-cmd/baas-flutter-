import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api.dart';
import '../../core/theme.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});
  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;
  bool _online = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final me = await Api.i.me();
      final u = (me['user'] ?? me) as Map;
      setState(() => _online = u['is_online'] == 1 || u['is_online'] == true);
    } catch (_) {}
  }

  Future<void> _toggle(bool want) async {
    setState(() => _busy = true);
    try {
      final res = await Api.i.setOnline(want);
      setState(() => _online = res);
    } on PendingFeeException catch (e) {
      if (mounted) _showFeeSheet(e.amount, e.settleId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showFeeSheet(double amount, int settleId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.receipt_long, size: 40, color: AppColors.coral),
            const SizedBox(height: 12),
            const Text('Fee ekak gewanna thiyenawa',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Giya dawase avasan karapu orders walin 5% service fee eka '
              'gewuwata passe online yanna puluwan.',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.coral.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('Gewanna one', style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Rs. ${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  await Api.i.paySettlement(settleId);
                  await _toggle(true);
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          e.toString().replaceAll('Exception: ', ''))));
                }
              },
              child: const Text('Wallet eken gewanna'),
            ),
            const SizedBox(height: 8),
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Passe')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const pages = [
      _Placeholder('Job Requests'),
      _Placeholder('Wallet'),
      _Placeholder('Profile'),
      _Placeholder('Notifications'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('MYBAAS'),
        actions: [
          Row(
            children: [
              Text(
                _online ? 'Online' : 'Offline',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _online ? AppColors.online : AppColors.offline,
                ),
              ),
              _busy
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : Switch(
                      value: _online,
                      activeColor: AppColors.online,
                      onChanged: _toggle,
                    ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.work_outline),
              selectedIcon: Icon(Icons.work),
              label: 'Jobs'),
          NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Wallet'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile'),
          NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications),
              label: 'Alerts'),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder(this.title);
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('$title\n(ithuru wada karanna thiyenawa)',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600])));
}
