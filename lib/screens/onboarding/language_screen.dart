import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand_logo.dart';
import '../../localization/locale_controller.dart';
import '../../localization/app_localizations.dart';
import '../onboarding/login_screen.dart';

class LanguageOption {
  final String code;
  final String label;
  final String native;
  const LanguageOption(this.code, this.label, this.native);
}

const _languages = [
  LanguageOption('en', 'English', 'English'),
  LanguageOption('si', 'Sinhala', 'සිංහල'),
  LanguageOption('ta', 'Tamil', 'தமிழ்'),
];

/// First screen a brand-new install shows, before any login - picks
/// the app's language, then continues to LoginScreen. The choice is
/// changeable again later from Settings (see ProfileScreen's
/// Language row), this is just the first prompt.
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String? _selected;

  Future<void> _continue() async {
    if (_selected == null) return;

    await context.read<LocaleController>().setLanguage(_selected!);

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: AppMotion.medium,
        pageBuilder: (_, animation, __) => FadeTransition(opacity: animation, child: const LoginScreen()),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(),
              const BrandLogo(fontSize: 32),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.t('selectYourLanguage', _selected ?? 'en'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              ..._languages.map((lang) {
                final isSelected = _selected == lang.code;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: InkWell(
                    onTap: () => setState(() => _selected = lang.code),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: AnimatedContainer(
                      duration: AppMotion.fast,
                      curve: AppMotion.curve,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accentSoft : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(
                          color: isSelected ? AppColors.accent : AppColors.border,
                          width: isSelected ? 2 : 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lang.native, style: Theme.of(context).textTheme.titleLarge),
                                if (lang.native != lang.label)
                                  Text(lang.label, style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.accent,
                              child: Icon(Icons.check, size: 16, color: AppColors.primary),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selected == null ? null : _continue,
                  child: Text(AppLocalizations.t('continueBtn', _selected ?? 'en')),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
