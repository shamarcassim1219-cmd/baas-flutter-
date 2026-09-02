import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../../localization/locale_controller.dart';
import '../onboarding/login_screen.dart';
import '../settings/security_screen.dart';
import '../verification/verification_screen.dart';
import '../support/live_chat_screen.dart';
import '../referral/referral_screen.dart';
import '../about/about_screen.dart';
import 'profile_details_screen.dart';

/// Top-level Settings screen - the account header (with verified
/// badge), then a menu into everything else (Profile details,
/// Security, Support, referrals, language, About), plus logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      // Refreshes from the backend (not just the locally cached
      // copy) so a verification status change (e.g. Approved by an
      // admin since this account last opened the app) shows up
      // without needing a logout/login.
      await AuthService.instance.refreshCurrentUser();
      final user = await ApiClient.instance.getUser();
      if (!mounted) return;
      setState(() {
        _user = user;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _changeLanguage() async {
    final locale = context.read<LocaleController>();

    final options = [
      ('en', 'English', 'English'),
      ('si', 'Sinhala', 'සිංහල'),
      ('ta', 'Tamil', 'தமிழ்'),
    ];

    final chosen = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) {
            final (code, englishName, nativeName) = option;
            return RadioListTile<String>(
              value: code,
              groupValue: locale.langCode,
              onChanged: (value) => Navigator.of(context).pop(value),
              title: Text(nativeName),
              subtitle: Text(englishName),
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ),
      ),
    );

    if (chosen == null || chosen == locale.langCode) return;
    await locale.setLanguage(chosen);
  }

  Future<void> _logout() async {
    final t = context.read<LocaleController>().t;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('logout')),
        content: Text(t('logoutConfirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t('cancel'))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text(t('logout'))),
        ],
      ),
    );

    if (confirmed != true) return;

    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleController>().t;

    final fullName = [
      _user?['firstName'] as String? ?? '',
      _user?['lastName'] as String? ?? '',
    ].where((s) => s.isNotEmpty).join(' ');

    final mobile = _user?['mobile'] as String? ?? '';
    final verification = _user?['verification'] as Map<String, dynamic>?;
    final isVerified = verification?['status'] == 'Approved';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(t('settings'))),
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
                    Center(
                      child: Column(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(100),
                            onTap: () {
                              if (isVerified) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(t('verifiedBadge'))),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(t('notVerified'))),
                                );
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VerificationScreen()));
                              }
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  radius: 44,
                                  backgroundColor: AppColors.primarySoft,
                                  child: Text(
                                    fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary),
                                  ),
                                ),
                                if (isVerified)
                                  Positioned(
                                    right: -2,
                                    bottom: -2,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                      child: const Icon(Icons.verified, color: AppColors.info, size: 22),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            fullName.isNotEmpty ? fullName : t('myBaasProfessional'),
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                          ),
                          if (mobile.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(mobile, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _actionRow(Icons.person_outline, t('profile'), () async {
                            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileDetailsScreen()));
                            _load();
                          }),
                          const Divider(height: 1),
                          _actionRow(Icons.verified_user_outlined, t('identityVerification'), () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VerificationScreen()));
                          }),
                          const Divider(height: 1),
                          _actionRow(Icons.security_outlined, t('security'), () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SecurityScreen()));
                          }),
                          const Divider(height: 1),
                          _actionRow(Icons.support_agent_outlined, t('support'), () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LiveChatScreen()));
                          }),
                          const Divider(height: 1),
                          _actionRow(Icons.card_giftcard_outlined, t('earnWithMybaas'), () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReferralScreen()));
                          }),
                          const Divider(height: 1),
                          _actionRow(Icons.language_outlined, t('language'), _changeLanguage),
                          const Divider(height: 1),
                          _actionRow(Icons.info_outline, t('aboutMybaas'), () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AboutScreen()));
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, size: 18, color: AppColors.danger),
                        label: Text(t('logout'), style: const TextStyle(color: AppColors.danger)),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.dangerSoft, width: 1.5)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _actionRow(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
