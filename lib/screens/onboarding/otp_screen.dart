import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../services/api_exception.dart';
import '../../theme/app_theme.dart';
import '../../widgets/brand_logo.dart';
import 'name_screen.dart';
import '../home/home_shell.dart';

class OtpScreen extends StatefulWidget {
  final String mobile;
  final bool isNewAccount;

  const OtpScreen({super.key, required this.mobile, required this.isNewAccount});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  bool _loading = false;
  bool _wrong = false;
  String? _error;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) return;

    setState(() {
      _loading = true;
      _wrong = false;
      _error = null;
    });

    try {
      widget.isNewAccount
          ? await AuthService.instance.verifyRegisterOtp(widget.mobile, otp)
          : await AuthService.instance.verifyLoginOtp(widget.mobile, otp);

      if (!mounted) return;

      if (widget.isNewAccount) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: AppMotion.medium,
            pageBuilder: (_, animation, __) => FadeTransition(opacity: animation, child: const NameScreen()),
          ),
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            transitionDuration: AppMotion.slow,
            pageBuilder: (_, animation, __) => FadeTransition(opacity: animation, child: const HomeShell()),
          ),
          (route) => false,
        );
      }
    } on ApiException catch (e) {
      setState(() {
        _wrong = true;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _wrong = true;
        _error = 'Invalid code. Please try again.';
      });
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
              const SizedBox(height: AppSpacing.md),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Center(child: BrandLogo(fontSize: 26)),
              const SizedBox(height: AppSpacing.lg),
              Text('Enter verification code', style: Theme.of(context).textTheme.headlineMedium)
                  .animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 6),
              Text(
                'We sent a code to +94 ${widget.mobile}',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 180.ms),
              const SizedBox(height: AppSpacing.xl),

              Center(
                child: _OtpBoxes(
                  controller: _otpController,
                  isWrong: _wrong,
                  onChanged: (value) {
                    setState(() {});
                    if (value.length == 6) _verify();
                  },
                ),
              ),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Center(
                    child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                  ),
                ),

              const SizedBox(height: AppSpacing.xl),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_otpController.text.length == 6 && !_loading) ? _verify : null,
                  child: _loading
                      ? const SizedBox(
                          height: 22, width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary),
                        )
                      : const Text('Verify'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Six individual animated boxes rather than a single text field -
/// reads immediately as "this is an OTP input" and gives a small,
/// satisfying pop as each digit lands.
class _OtpBoxes extends StatelessWidget {
  final TextEditingController controller;
  final bool isWrong;
  final ValueChanged<String> onChanged;

  const _OtpBoxes({required this.controller, required this.isWrong, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            final filled = index < controller.text.length;
            final digit = filled ? controller.text[index] : '';

            return Container(
              width: 44,
              height: 54,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: filled ? AppColors.accentSoft : AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                  color: isWrong
                      ? AppColors.danger
                      : (filled ? AppColors.accent : AppColors.border),
                  width: filled || isWrong ? 2 : 1.5,
                ),
              ),
              child: Text(
                digit,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            )
                .animate(target: filled ? 1 : 0)
                .scale(begin: const Offset(1, 1), end: const Offset(1.06, 1.06), duration: 120.ms)
                .then()
                .scale(begin: const Offset(1.06, 1.06), end: const Offset(1, 1), duration: 120.ms);
          }),
        )
            .animate(target: isWrong ? 1 : 0)
            .shake(hz: 4, duration: 400.ms, curve: Curves.easeInOut),

        Opacity(
          opacity: 0,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: onChanged,
            autofocus: true,
          ),
        ),
      ],
    );
  }
}
