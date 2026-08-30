import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../../services/api_exception.dart';

/// Change email or mobile - both confirmed against the real backend
/// as a two-step OTP flow: request a code to the NEW address/number,
/// then verify it to actually apply the change. Neither takes effect
/// until the OTP is verified.
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await ApiClient.instance.getUser();
    if (!mounted) return;
    setState(() => _user = user);
  }

  Future<void> _changeEmail() async {
    final newEmail = await _promptForValue(
      title: 'New Email Address',
      hint: 'you@example.com',
      keyboardType: TextInputType.emailAddress,
      validator: (v) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v) ? null : 'Enter a valid email address',
    );
    if (newEmail == null) return;

    try {
      await AuthService.instance.requestEmailChangeOtp(newEmail);
      if (!mounted) return;

      final otp = await _promptForOtp('Enter the code sent to $newEmail');
      if (otp == null) return;

      await AuthService.instance.verifyEmailChangeOtp(newEmail, otp);
      if (!mounted) return;
      await _loadUser();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email updated.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update your email. Please try again.')),
      );
    }
  }

  Future<void> _changeMobile() async {
    final newMobile = await _promptForValue(
      title: 'New Mobile Number',
      hint: '07XXXXXXXX',
      keyboardType: TextInputType.phone,
      validator: (v) => RegExp(r'^07\d{8}$').hasMatch(v) ? null : 'Enter a valid Sri Lankan mobile number',
    );
    if (newMobile == null) return;

    try {
      await AuthService.instance.requestMobileChangeOtp(newMobile);
      if (!mounted) return;

      final otp = await _promptForOtp('Enter the code sent to +94 $newMobile');
      if (otp == null) return;

      await AuthService.instance.verifyMobileChangeOtp(newMobile, otp);
      if (!mounted) return;
      await _loadUser();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mobile number updated.')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update your mobile number. Please try again.')),
      );
    }
  }

  Future<String?> _promptForValue({
    required String title,
    required String hint,
    required TextInputType keyboardType,
    required String? Function(String) validator,
  }) async {
    final controller = TextEditingController();
    String? error;

    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                decoration: InputDecoration(hintText: hint),
              ),
              if (error != null) ...[
                const SizedBox(height: 8),
                Text(error!, style: const TextStyle(color: AppColors.danger, fontSize: 12.5)),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                final value = controller.text.trim();
                final validationError = validator(value);
                if (validationError != null) {
                  setDialogState(() => error = validationError);
                  return;
                }
                Navigator.of(context).pop(value);
              },
              child: const Text('Send Code'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _promptForOtp(String subtitle) async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Verification Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(hintText: '6-digit code', counterText: ''),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mobile = _user?['mobile'] as String? ?? '';
    final email = _user?['email'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Security')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _row(Icons.email_outlined, 'Email', email.isNotEmpty ? email : 'Not set', _changeEmail),
                  const Divider(height: 1),
                  _row(Icons.phone_outlined, 'Mobile', mobile.isNotEmpty ? mobile : 'Not set', _changeMobile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Text('Change', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
