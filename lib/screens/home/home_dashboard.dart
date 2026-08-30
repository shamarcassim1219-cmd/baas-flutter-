import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/baas_profile_service.dart';
import '../../services/api_exception.dart';
import '../../utils/formatters.dart';
import '../jobs/job_requests_screen.dart';

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
    final pay = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Platform Fee Due'),
        content: Text(
          'You have an outstanding platform fee of ${formatMoney(feeOwed)}. '
          'Pay it from your wallet to go back online.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Not Now')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Pay from Wallet')),
        ],
      ),
    );

    if (pay != true) return;

    try {
      await BaasProfileService.instance.payPlatformFeeFromWallet();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Platform fee paid. You can go online now.')),
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
                      firstName.isNotEmpty ? 'Hi, $firstName' : 'Welcome',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 20),

                    if (_error != null) ...[
                      Text(_error!, style: const TextStyle(color: AppColors.danger)),
                      const SizedBox(height: 16),
                    ],

                    _buildOnlineToggleCard(),
                    const SizedBox(height: 16),

                    if (_feeStatus != null && _feeStatus!.feeOwed > 0) _buildFeeBanner(),

                    const SizedBox(height: 16),
                    _buildEarningsCard(),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const JobRequestsScreen()));
                        },
                        icon: const Icon(Icons.inbox_outlined),
                        label: const Text('View Job Requests'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOnlineToggleCard() {
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
                  _online ? "You're Online" : "You're Offline",
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  _online ? 'Visible to nearby customers' : 'Go online to receive job requests',
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

  Widget _buildFeeBanner() {
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
                  'Platform fee: ${formatMoney(fee.feeOwed)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    color: fee.blocksGoingOnline ? AppColors.danger : AppColors.warning,
                  ),
                ),
                if (fee.blocksGoingOnline)
                  const Text(
                    'This must be paid before you can go online.',
                    style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showFeeDueDialog(fee.feeOwed),
            child: const Text('Pay'),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard() {
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
          const Text(
            "TODAY'S EARNINGS",
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            formatMoney(earnings?.todayEarnings ?? 0),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            '${earnings?.ordersToday ?? 0} job${(earnings?.ordersToday ?? 0) == 1 ? '' : 's'} today',
            style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
