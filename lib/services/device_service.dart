import 'package:device_info_plus/device_info_plus.dart';

/// A stable per-device identifier - Android's own ANDROID_ID, which
/// survives this app being uninstalled and reinstalled (unlike a
/// UUID generated and stored locally, which a banned account could
/// trivially dodge just by reinstalling). It does reset on a full
/// factory reset, which is an accepted limitation shared by most
/// apps that do this kind of device-level check.
class DeviceService {
  DeviceService._internal();
  static final DeviceService instance = DeviceService._internal();

  String? _cachedId;

  Future<String> getDeviceId() async {
    if (_cachedId != null) return _cachedId!;

    try {
      final info = await DeviceInfoPlugin().androidInfo;
      _cachedId = info.id;
    } catch (_) {
      _cachedId = '';
    }

    return _cachedId!;
  }
}
