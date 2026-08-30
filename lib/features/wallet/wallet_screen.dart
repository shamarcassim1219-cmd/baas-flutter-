import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api.dart';
import '../../core/theme.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;
  final _money = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final d = await Api.i.wallet();
      if (mounted) setState(() { _data = d; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  void _topUpSheet() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Salli dhaanna',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Ganana',
                prefixText: 'Rs. ',
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [500, 1000, 2500, 5000]
                  .map((a) => ActionChip(
                        label: Text('$a'),
                        onPressed: () => ctrl.text = '$a',
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('PayHere connect karanna thawama thiyenawa')),
                );
              },
              child: const Text('PayHere walin gewanna'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _load, child: const Text('Aye try karanna')),
          ],
        ),
      );
    }

    final balance = (_data?['balance'] as num?)?.toDouble() ?? 0;
    final pendingFee = (_data?['pending_fee'] as num?)?.toDouble() ?? 0;
    final todayEarn = (_data?['today_earnings'] as num?)?.toDouble() ?? 0;
    final txns = (_data?['transactions'] as List?) ?? [];

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.teal, AppColors.teal.withOpacity(0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Wallet balance',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text('Rs. ${_money.format(balance)}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: _topUpSheet,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.teal,
                        ),
                        child: const Text('Salli dhaanna'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _stat('Ada ලැබූ ganana',
                    'Rs. ${_money.format(todayEarn)}', AppColors.teal),
              ),
              Expanded(
                child: _stat('Gewanna one fee',
                    'Rs. ${_money.format(pendingFee)}', AppColors.coral),
              ),
            ],
          ),
          if (pendingFee > 0)
            Card(
              child: ListTile(
                leading: Icon(Icons.warning_amber_rounded, color: AppColors.coral),
                title: const Text('Fee ekak gewanna thiyenawa'),
                subtitle: Text(
                    'Rs. ${_money.format(pendingFee)} gewuwata passe online yanna puluwan'),
              ),
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Text('Ganu denu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          if (txns.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Text('Thawama ganu denu naha',
                    style: TextStyle(color: Colors.grey[600])),
              ),
            )
          else
            ...txns.map((t) {
              final m = Map<String, dynamic>.from(t);
              final amt = (m['amount'] as num?)?.toDouble() ?? 0;
              final credit = amt >= 0;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        (credit ? AppColors.online : AppColors.coral)
                            .withOpacity(0.12),
                    child: Icon(
                      credit ? Icons.arrow_downward : Icons.arrow_upward,
                      color: credit ? AppColors.online : AppColors.coral,
                      size: 18,
                    ),
                  ),
                  title: Text(m['title']?.toString() ?? 'Transaction'),
                  subtitle: Text(m['created_at']?.toString() ?? ''),
                  trailing: Text(
                    '${credit ? '+' : '-'} Rs. ${_money.format(amt.abs())}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: credit ? AppColors.online : AppColors.coral,
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6E8EC)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      );
}
