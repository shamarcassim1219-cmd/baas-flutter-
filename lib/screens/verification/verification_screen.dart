import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/verification_service.dart';
import '../../services/api_exception.dart';
import '../../localization/locale_controller.dart';

const _provinces = [
  'Western',
  'Central',
  'Southern',
  'Northern',
  'Eastern',
  'North Western',
  'North Central',
  'Uva',
  'Sabaragamuwa',
];

/// Identity verification - fullName/nic/phone/address/province/
/// district plus three photos (NIC front, NIC back, a live selfie).
/// Confirmed against the real backend: submitting always sets
/// status to "Pending", and the form is intentionally locked out of
/// re-opening for either "Pending" (already under review) or
/// "Approved" (nothing left to change) - only "Rejected" reopens it,
/// so a Baas can fix whatever was wrong and resubmit.
class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _loading = true;
  VerificationInfo? _existing;
  bool _showForm = false;

  final _fullNameController = TextEditingController();
  final _nicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _districtController = TextEditingController();
  String? _province;

  String? _nicPhotoBase64;
  String? _nicBackPhotoBase64;
  String? _selfiePhotoBase64;

  bool _submitting = false;
  String? _error;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    try {
      final user = await ApiClient.instance.getUser();
      final verificationJson = user?['verification'] as Map<String, dynamic>?;

      if (!mounted) return;
      setState(() {
        _existing = verificationJson != null ? VerificationInfo.fromJson(verificationJson) : null;
        // No submission yet - go straight to the form. Otherwise the
        // status view decides (Rejected reveals a "Resubmit" button).
        _showForm = _existing == null;
        if (_existing != null) {
          _fullNameController.text = _existing!.fullName;
          _nicController.text = _existing!.nic;
          _phoneController.text = _existing!.phone;
          _addressController.text = _existing!.address;
          _districtController.text = _existing!.district;
          _province = _existing!.province.isNotEmpty ? _existing!.province : null;
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _pickPhoto({required bool front, required void Function(String base64) onPicked}) async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: front ? CameraDevice.front : CameraDevice.rear,
        imageQuality: 70,
        maxWidth: 1280,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      final base64Str = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      onPicked(base64Str);
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open the camera. Please try again.')),
      );
    }
  }

  bool get _canSubmit =>
      _fullNameController.text.trim().isNotEmpty &&
      _nicController.text.trim().isNotEmpty &&
      _phoneController.text.trim().isNotEmpty &&
      _addressController.text.trim().isNotEmpty &&
      _province != null &&
      _districtController.text.trim().isNotEmpty &&
      _nicPhotoBase64 != null &&
      _nicBackPhotoBase64 != null &&
      _selfiePhotoBase64 != null;

  Future<void> _submit() async {
    if (!_canSubmit) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await VerificationService.instance.submit(
        fullName: _fullNameController.text.trim(),
        nic: _nicController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        province: _province!,
        district: _districtController.text.trim(),
        nicPhotoBase64: _nicPhotoBase64!,
        nicBackPhotoBase64: _nicBackPhotoBase64!,
        selfiePhotoBase64: _selfiePhotoBase64!,
      );

      // Refresh the cached user so the Pending status (and the
      // Settings badge) reflect this submission immediately.
      final data = await ApiClient.instance.get('/api/users/me');
      if (data['user'] != null) {
        await ApiClient.instance.saveUser(data['user'] as Map<String, dynamic>);
      }

      if (!mounted) return;
      await _load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification submitted. This is now under review.')),
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Unable to submit verification. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleController>().t;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(t('verificationCenter'))),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (!_showForm && _existing != null) _buildStatusCard(t) else _buildForm(t),
                ],
              ),
      ),
    );
  }

  Widget _buildStatusCard(String Function(String) t) {
    final info = _existing!;

    final (icon, color, bg, title, desc) = switch (info.status) {
      'Approved' => (
          Icons.verified,
          AppColors.success,
          AppColors.successSoft,
          t('verificationApproved'),
          t('verificationApprovedDesc'),
        ),
      'Rejected' => (
          Icons.error_outline,
          AppColors.danger,
          AppColors.dangerSoft,
          t('verificationRejected'),
          info.note?.isNotEmpty == true ? info.note! : t('verificationRejectedDesc'),
        ),
      _ => (
          Icons.hourglass_top,
          AppColors.warning,
          AppColors.warningSoft,
          t('verificationPending'),
          t('verificationPendingDesc'),
        ),
    };

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
          child: Column(
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: color)),
              const SizedBox(height: 6),
              Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            ],
          ),
        ),
        if (info.isRejected) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _showForm = true),
              child: Text(t('resubmit')),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildForm(String Function(String) t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t('verificationCenter'), style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(t('verificationIntro'), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 24),

        Text(t('fullNameField'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(controller: _fullNameController, onChanged: (_) => setState(() {})),
        const SizedBox(height: 16),

        Text(t('nicField'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(controller: _nicController, onChanged: (_) => setState(() {})),
        const SizedBox(height: 16),

        Text(t('phoneField'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(controller: _phoneController, keyboardType: TextInputType.phone, onChanged: (_) => setState(() {})),
        const SizedBox(height: 16),

        Text(t('addressField'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(controller: _addressController, maxLines: 2, onChanged: (_) => setState(() {})),
        const SizedBox(height: 16),

        Text(t('provinceField'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _province,
          items: _provinces.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
          onChanged: (v) => setState(() => _province = v),
          decoration: const InputDecoration(),
        ),
        const SizedBox(height: 16),

        Text(t('districtField'), style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(controller: _districtController, onChanged: (_) => setState(() {})),
        const SizedBox(height: 24),

        _buildPhotoRow(
          title: t('nicFrontPhoto'),
          base64: _nicPhotoBase64,
          onCapture: () => _pickPhoto(front: false, onPicked: (b) => _nicPhotoBase64 = b),
        ),
        const SizedBox(height: 16),
        _buildPhotoRow(
          title: t('nicBackPhoto'),
          base64: _nicBackPhotoBase64,
          onCapture: () => _pickPhoto(front: false, onPicked: (b) => _nicBackPhotoBase64 = b),
        ),
        const SizedBox(height: 16),
        _buildPhotoRow(
          title: t('liveSelfie'),
          base64: _selfiePhotoBase64,
          onCapture: () => _pickPhoto(front: true, onPicked: (b) => _selfiePhotoBase64 = b),
        ),

        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
        ],

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_canSubmit && !_submitting) ? _submit : null,
            child: _submitting
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                : Text(t('submitVerification')),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoRow({required String title, required String? base64, required VoidCallback onCapture}) {
    final captured = base64 != null;

    return InkWell(
      onTap: onCapture,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: captured ? AppColors.successSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: captured ? AppColors.success.withValues(alpha: 0.3) : AppColors.border),
        ),
        child: Row(
          children: [
            Icon(captured ? Icons.check_circle : Icons.camera_alt_outlined, color: captured ? AppColors.success : AppColors.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
            Text(captured ? 'Retake' : 'Capture', style: const TextStyle(fontSize: 12.5, color: AppColors.primary, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
