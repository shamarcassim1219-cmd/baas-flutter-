import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../services/api_exception.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand_logo.dart';
import '../home/home_shell.dart';

/// Last onboarding step for a brand-new Baas account - first/last
/// name only. Service selection, daily rate, and other profile
/// details are set up separately from the Profile tab once inside
/// the app, not forced here, so a new Baas can get in and look
/// around before committing to a full profile.
class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  bool get _canContinue =>
      _firstNameController.text.trim().isNotEmpty &&
      _lastNameController.text.trim().isNotEmpty;

  Future<void> _continue() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await AuthService.instance.completeRegistration(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          transitionDuration: AppMotion.slow,
          pageBuilder: (_, animation, __) =>
              FadeTransition(opacity: animation, child: const HomeShell()),
        ),
        (route) => false,
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Unable to save your profile. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              const Center(child: BrandLogo(fontSize: 28)),
              const SizedBox(height: AppSpacing.lg),
              Text(
                "What's your name?",
                style: Theme.of(context).textTheme.headlineMedium,
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 6),
              Text(
                'This is how customers will see you.',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 180.ms),
              const SizedBox(height: AppSpacing.xl),

              TextField(
                controller: _firstNameController,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: 'First name'),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _lastNameController,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: 'Last name'),
              ),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_canContinue && !_loading) ? _continue : null,
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary),
                        )
                      : const Text('Continue'),
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
