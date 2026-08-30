import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../services/api_exception.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand_logo.dart';
import 'otp_screen.dart';

/// Entry point for a Baas account - mobile number only (no guest
/// browsing, no email/international path, unlike the customer app -
/// a Baas is always a real, verified Sri Lankan mobile account).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  bool get _canContinue => RegExp(r'^07\d{8}$').hasMatch(_mobileController.text);

  Future<void> _continue() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await AuthService.instance.requestOtp(_mobileController.text);
      if (!mounted) return;

      Navigator.of(context).push(
        PageRouteBuilder(
          transitionDuration: AppMotion.medium,
          pageBuilder: (_, animation, __) => SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: animation, curve: AppMotion.curve)),
            child: OtpScreen(
              mobile: _mobileController.text,
              isNewAccount: result.flow == AuthFlowType.register,
            ),
          ),
        ),
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              const Center(child: BrandLogo(fontSize: 32)),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'For Baas Professionals',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: AppSpacing.xxl),

              Text('Mobile Number', style: Theme.of(context).textTheme.titleMedium)
                  .animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 4),
              Text(
                'Enter your 10-digit Sri Lankan mobile number.',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.border.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: const Text('+94', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _mobileController,
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(counterText: '', hintText: '07XXXXXXXX'),
                    ),
                  ),
                ],
              ),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                ),

              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_canContinue && !_loading) ? _continue : null,
                  child: _loading
                      ? const SizedBox(
                          height: 22, width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary),
                        )
                      : const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
