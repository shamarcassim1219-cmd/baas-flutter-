import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../../services/api_exception.dart';
import '../../services/baas_profile_service.dart';
import '../onboarding/login_screen.dart';
import '../settings/security_screen.dart';

/// Common Baas trade categories - a Baas picks any that apply
/// rather than typing free text, so search matching on the customer
/// side (which compares against these same strings) stays reliable.
const _availableServices = [
  'Mason',
  'Carpenter',
  'Painter',
  'Electrician',
  'Plumber',
  'Welder',
  'Tiler',
  'Roofer',
  'General Labour',
];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;

  final _dailyRateController = TextEditingController();
  final _aboutController = TextEditingController();
  final _locationController = TextEditingController();
  final Set<String> _selectedServices = {};

  bool _loading = true;
  bool _saving = false;
  bool _updatingLocation = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _dailyRateController.dispose();
    _aboutController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = await ApiClient.instance.getUser();
      final baasProfile = user?['baasProfile'] as Map<String, dynamic>?;

      if (!mounted) return;
      setState(() {
        _user = user;
        if (baasProfile != null) {
          _dailyRateController.text =
              (baasProfile['dailyRate'] as num?)?.toString() ?? '';
          _aboutController.text = baasProfile['about'] as String? ?? '';
          _locationController.text = baasProfile['location'] as String? ?? '';
          _selectedServices
            ..clear()
            ..addAll((baasProfile['services'] as List?)?.map((e) => e.toString()) ?? []);
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load your profile. Pull down to try again.';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      await BaasProfileService.instance.updateProfile(
        services: _selectedServices.toList(),
        dailyRate: double.tryParse(_dailyRateController.text.trim()),
        about: _aboutController.text.trim(),
        location: _locationController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Unable to save your profile. Please try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _updateLocationToCurrent() async {
    setState(() => _updatingLocation = true);

    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is needed to update this.')),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      await BaasProfileService.instance.updateLocation(position.latitude, position.longitude);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location updated - customers will now see distance to you correctly.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to update location. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _updatingLocation = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
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
    final fullName = [
      _user?['firstName'] as String? ?? '',
      _user?['lastName'] as String? ?? '',
    ].where((s) => s.isNotEmpty).join(' ');

    final mobile = _user?['mobile'] as String? ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.primarySoft,
                          child: Text(
                            fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          fullName.isNotEmpty ? fullName : 'MYBAAS Professional',
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

                  Text('Services', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  const Text(
                    'Select what you offer - this is how customers find you.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableServices.map((service) {
                      final selected = _selectedServices.contains(service);
                      return FilterChip(
                        label: Text(service),
                        selected: selected,
                        onSelected: (value) {
                          setState(() {
                            if (value) {
                              _selectedServices.add(service);
                            } else {
                              _selectedServices.remove(service);
                            }
                          });
                        },
                        selectedColor: AppColors.accentSoft,
                        checkmarkColor: AppColors.accent,
                        labelStyle: TextStyle(
                          color: selected ? AppColors.accent : AppColors.textSecondary,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        side: BorderSide(color: selected ? AppColors.accent : AppColors.border),
                        backgroundColor: AppColors.surface,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  Text('Daily Rate', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _dailyRateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(hintText: '0.00', prefixText: 'Rs. ', suffixText: '/ day'),
                  ),
                  const SizedBox(height: 24),

                  Text('About', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _aboutController,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'A short line about your experience'),
                  ),
                  const SizedBox(height: 24),

                  Text('Location Label', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  const Text(
                    'e.g. "Colombo 5" - shown to customers alongside your distance.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(hintText: 'Area / neighbourhood'),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _updatingLocation ? null : _updateLocationToCurrent,
                      icon: _updatingLocation
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.my_location, size: 18),
                      label: const Text('Use My Current Location'),
                    ),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                  ],

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                          : const Text('Save Profile'),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SecurityScreen()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Icon(Icons.security_outlined, size: 20, color: AppColors.primary),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text('Security', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ),
                            const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, size: 18, color: AppColors.danger),
                      label: const Text('Logout', style: TextStyle(color: AppColors.danger)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.dangerSoft, width: 1.5)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
