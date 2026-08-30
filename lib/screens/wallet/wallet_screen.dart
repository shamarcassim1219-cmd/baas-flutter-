import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/wallet_service.dart';
import '../../utils/formatters.dart';
import 'withdraw_screen.dart';

/// A Baas's wallet is only ever funded by order earnings (released
/// on accept for pay_now, or the platform-fee-adjusted equivalent
/// for pay_direct) - no top-up here, unlike the customer app.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _loading = true;
  String? _error;
  WalletBalance? _balance;
  List<LedgerEntry> _ledger = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final (balance, ledger) = await WalletService.instance.load();
      if (!mounted) return;
      setState(() {
        _balance = balance;
        _ledger = ledger;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load your wallet. Pull down to try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Wallet')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
                      ),
                    _buildBalanceCard(),
                    const SizedBox(height: 24),
                    Text('Transaction History', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    if (_ledger.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(child: Text('No transactions yet.', style: TextStyle(color: AppColors.textMuted))),
                      )
                    else
                      ..._ledger.map(_buildLedgerRow),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    final pending = _balance?.pending ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AVAILABLE BALANCE',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            formatMoney(_balance?.available ?? 0),
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
          ),
          if (pending > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
              child: Text(
                'PENDING: ${formatMoney(pending)}',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final completed = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => WithdrawScreen(availableBalance: _balance?.available ?? 0)),
                );
                if (completed == true) _load();
              },
              icon: const Icon(Icons.arrow_outward, size: 18, color: Colors.white),
              label: const Text('Withdraw', style: TextStyle(color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white30),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerRow(LedgerEntry entry) {
    final isNegative = entry.amount < 0;
    final isPending = entry.state == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.note.isNotEmpty ? entry.note : entry.type,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(formatShortDate(entry.createdAt), style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                if (isPending) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.warningSoft, borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
                    child: const Text('PENDING', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.warning)),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${isNegative ? '-' : '+'}${formatMoney(entry.amount.abs())}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isPending ? AppColors.warning : (isNegative ? AppColors.danger : AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}
