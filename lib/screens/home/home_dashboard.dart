import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/baas_profile_service.dart';
import '../../services/api_exception.dart';
import '../../utils/formatters.dart';
import '../../localization/locale_controller.dart';
import '../jobs/job_requests_screen.dart';
import '../wallet/top_up_screen.dart';

/// The Baas's landing screen - online/offline toggle up top (the
/// backend blocks going online if an outstanding platform fee is
/// past the minimum, surfaced here with a direct "pay now" action),
/// today's earnings summary, and a shortcut into job requests.
class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  Map<String, dynamic>? _user;
  bool _online = false;
  bool _togglingOnline = false;

  PlatformFeeStatus? _feeStatus;
  TodayEarnings? _earnings;
  bool _loading = true;
  String? _error;

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
      final user = await ApiClient.instance.getUser();
      final baasProfile = user?['baasProfile'] as Map<String, dynamic>?;

      final results = await Future.wait([
        BaasProfileService.instance.platformFeeStatus(),
        BaasProfileService.instance.earningsToday(),
      ]);

      if (!mounted) return;
      setState(() {
        _user = user;
        _online = baasProfile?['active'] == true;
        _feeStatus = results[0] as PlatformFeeStatus;
        _earnings = results[1] as TodayEarnings;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load your dashboard. Pull down to try again.';
        _loading = false;
      });
    }
  }

  Future<void> _toggleOnline(bool value) async {
    setState(() => _togglingOnline = true);

    try {
      final active = await BaasProfileService.instance.setAvailability(value);
      if (!mounted) return;
      setState(() => _online = active);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.code == 'PLATFORM_FEE_DUE') {
        final feeOwed = (e.data?['feeOwed'] as num?)?.toDouble() ?? 0;
        await _showFeeDueDialog(feeOwed);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update your status. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _togglingOnline = false);
    }
  }

  Future<void> _showFeeDueDialog(double feeOwed) async {
    final t = context.read<LocaleController>().t;

    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('platformFeeDue')),
        content: Text('${t('platformFeeDueDesc')} ${formatMoney(feeOwed)}. ${t('payToGoOnline')}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: Text(t('notNow'))),
          TextButton(onPressed: () => Navigator.of(context).pop('wallet'), child: Text(t('payFromWallet'))),
          TextButton(onPressed: () => Navigator.of(context).pop('card'), child: Text(t('payByCard'))),
        ],
      ),
    );

    if (choice == null) return;

    if (choice == 'card') {
      final completed = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => TopUpScreen(purpose: 'platform_fee', fixedAmount: feeOwed)),
      );
      if (completed == true && mounted) await _load();
      return;
    }

    try {
      await BaasProfileService.instance.payPlatformFeeFromWallet();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('feePaidCanGoOnline'))),
      );
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to pay the platform fee. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleController>().t;
    final firstName = (_user?['firstName'] as String?) ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _load,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  children: [
                    Text(
                      firstName.isNotEmpty ? 'Hi, $firstName' : t('welcome'),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 20),

                    if (_error != null) ...[
                      Text(_error!, style: const TextStyle(color: AppColors.danger)),
                      const SizedBox(height: 16),
                    ],

                    _buildOnlineToggleCard(t),
                    const SizedBox(height: 16),

                    if (_feeStatus != null && _feeStatus!.feeOwed > 0) _buildFeeBanner(t),

                    const SizedBox(height: 16),
                    _buildEarningsCard(t),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const JobRequestsScreen()));
                        },
                        icon: const Icon(Icons.inbox_outlined),
                        label: Text(t('viewJobRequests')),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOnlineToggleCard(String Function(String) t) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _online ? AppColors.successSoft : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: _online ? AppColors.success.withValues(alpha: 0.3) : AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _online ? AppColors.success : AppColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _online ? t('youreOnline') : t('youreOffline'),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  _online ? t('visibleToCustomers') : t('goOnlineToReceive'),
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          _togglingOnline
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Switch(value: _online, onChanged: _toggleOnline, activeThumbColor: AppColors.success),
        ],
      ),
    );
  }

  Widget _buildFeeBanner(String Function(String) t) {
    final fee = _feeStatus!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fee.blocksGoingOnline ? AppColors.dangerSoft : AppColors.warningSoft,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            fee.blocksGoingOnline ? Icons.error_outline : Icons.info_outline,
            color: fee.blocksGoingOnline ? AppColors.danger : AppColors.warning,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${t('platformFee')}: ${formatMoney(fee.feeOwed)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: fee.blocksGoingOnline ? AppColors.danger : AppColors.warning,
                  ),
                ),
                if (fee.blocksGoingOnline)
                  Text(
                    t('mustBePaidToGoOnline'),
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showFeeDueDialog(fee.feeOwed),
            child: Text(t('pay')),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(String Function(String) t) {
    final earnings = _earnings;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('todaysEarnings'),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            formatMoney(earnings?.todayEarnings ?? 0),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            '${earnings?.ordersToday ?? 0} ${t('jobsToday')}',
            style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
