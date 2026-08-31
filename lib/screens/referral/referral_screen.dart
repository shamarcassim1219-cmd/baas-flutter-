import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_theme.dart';
import '../../services/referral_service.dart';
import '../../utils/formatters.dart';
import '../../localization/locale_controller.dart';

/// "Earn with MYBAAS" - shows this account's own referral code, a
/// share button (native share sheet, since there's no functional
/// deep link to attach - a recipient enters the code manually at
/// signup), and how much has been earned from it. Same backend
/// endpoint as the customer app's referral screen - a Baas referring
/// another Baas earns 1% of that referred account's first wallet
/// top-up.
class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  bool _loading = true;
  String? _error;
  ReferralInfo? _info;

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
      final info = await ReferralService.instance.load();
      if (!mounted) return;
      setState(() {
        _info = info;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load your referral info. Pull down to try again.';
        _loading = false;
      });
    }
  }

  void _share() {
    final code = _info?.referralCode;
    if (code == null || code.isEmpty) return;

    SharePlus.instance.share(
      ShareParams(
        text: 'Join MYBAAS as a Baas professional! '
            'Use my referral code $code when you sign up.\n\n'
            'Download: https://play.google.com/store/apps/details?id=com.gobaas.baas',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleController>().t;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(t('earnWithMybaas'))),
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
                    _buildIntroCard(t),
                    const SizedBox(height: 20),
                    _buildCodeCard(t),
                    const SizedBox(height: 20),
                    _buildStatsRow(t),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildIntroCard(String Function(String) t) {
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
          const Icon(Icons.card_giftcard, color: Colors.white, size: 28),
          const SizedBox(height: 10),
          Text(
            t('inviteEarnTitle'),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            t('inviteEarnDesc'),
            style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeCard(String Function(String) t) {
    final code = _info?.referralCode ?? '------';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('yourReferralCode'),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
            ),
            child: Text(
              code,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 4),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _info == null ? null : _share,
              icon: const Icon(Icons.share, size: 18),
              label: Text(t('shareCode')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(String Function(String) t) {
    return Row(
      children: [
        Expanded(child: _statCard(Icons.group_outlined, t('friendsReferred'), '${_info?.referredCount ?? 0}')),
        const SizedBox(width: 12),
        Expanded(child: _statCard(Icons.savings_outlined, t('totalEarned'), formatMoney(_info?.totalEarnings ?? 0))),
      ],
    );
  }

  Widget _statCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
