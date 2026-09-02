import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/api_exception.dart';
import '../../services/baas_profile_service.dart';
import '../../localization/locale_controller.dart';

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

/// Everything a customer sees about this Baas: name, services, daily
/// rate, about text, and location label. Name is editable, but only
/// up until identity verification is Approved - after that it's
/// locked, since an approved verification is tied to the name that
/// was on file when it was reviewed.
class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  Map<String, dynamic>? _user;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dailyRateController.dispose();
    _aboutController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  bool get _isVerified =>
      (_user?['verification'] as Map<String, dynamic>?)?['status'] == 'Approved';

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
        _firstNameController.text = user?['firstName'] as String? ?? '';
        _lastNameController.text = user?['lastName'] as String? ?? '';
        if (baasProfile != null) {
          _dailyRateController.text = (baasProfile['dailyRate'] as num?)?.toString() ?? '';
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
      // Name is only editable pre-verification - completeRegistration
      // reuses the same PUT /api/users/profile endpoint used at
      // signup, which works just as well for a later edit.
      if (!_isVerified) {
        await AuthService.instance.completeRegistration(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
        );
      }

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
      await _load();
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

      try {
        final placemarks = await Geocoding().placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final label = [place.subLocality, place.locality]
              .where((s) => s != null && s.isNotEmpty)
              .join(', ');
          if (label.isNotEmpty && mounted) {
            setState(() => _locationController.text = label);
          }
        }
      } catch (_) {
        // Reverse geocoding failing shouldn't block the location
        // update itself - the coordinates are already saved.
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location updated.')),
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

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleController>().t;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(t('profile'))),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(t('firstName'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _firstNameController,
                    enabled: !_isVerified,
                    textCapitalization: TextCapitalization.words,
                  ),
                  if (_isVerified) ...[
                    const SizedBox(height: 4),
                    Text(t('nameLockedVerified'), style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted)),
                  ],
                  const SizedBox(height: 16),

                  Text(t('lastName'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _lastNameController,
                    enabled: !_isVerified,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 24),

                  Text(t('services'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(t('selectServicesDesc'), style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
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
                  const SizedBox(height: 20),

                  Text(t('dailyRate'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _dailyRateController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(hintText: '0.00', prefixText: 'Rs. ', suffixText: '/ day'),
                  ),
                  const SizedBox(height: 20),

                  Text(t('about'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _aboutController,
                    maxLines: 3,
                    decoration: InputDecoration(hintText: t('aboutHint')),
                  ),
                  const SizedBox(height: 20),

                  Text(t('locationLabel'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(t('locationLabelDesc'), style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
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
                      label: Text(t('useCurrentLocation')),
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
                          : Text(t('saveProfile')),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
