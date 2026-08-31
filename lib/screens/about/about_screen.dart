import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand_logo.dart';
import '../../localization/locale_controller.dart';

/// Static informational screen - no backend calls needed.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleController>().t;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(t('aboutMybaas'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Center(child: BrandLogo(fontSize: 32, animate: false)),
            const SizedBox(height: 24),
            const Text(
              'MYBAAS connects trusted, verified professionals ("Baas") '
              'with customers who need home repairs, construction work, '
              'and skilled trade services across Sri Lanka.',
              style: TextStyle(fontSize: 14.5, height: 1.6, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _infoRow('Version', '1.0.0'),
            _infoRow('Website', 'findbass.store'),
            const SizedBox(height: 32),
            const Text(
              'A verified identity, an up-to-date profile, and a fair '
              'platform fee keep MYBAAS working well for every Baas on it.',
              style: TextStyle(fontSize: 13, height: 1.6, color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
        ],
      ),
    );
  }
}
