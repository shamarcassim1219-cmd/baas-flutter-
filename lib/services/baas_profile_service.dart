import 'api_client.dart';
import 'api_exception.dart';

class BaasProfile {
  final bool active;
  final List<String> services;
  final double dailyRate;
  final String about;
  final String displayName;
  final String location;

  BaasProfile({
    required this.active,
    required this.services,
    required this.dailyRate,
    required this.about,
    required this.displayName,
    required this.location,
  });

  factory BaasProfile.fromJson(Map<String, dynamic> json) {
    return BaasProfile(
      active: json['active'] == true,
      services: (json['services'] as List?)?.map((e) => e.toString()).toList() ?? [],
      dailyRate: (json['dailyRate'] as num?)?.toDouble() ?? 0,
      about: json['about'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      location: json['location'] as String? ?? '',
    );
  }
}

class PlatformFeeStatus {
  final double feeOwed;
  final double feePercent;
  final double blockThreshold;
  final bool blocksGoingOnline;

  PlatformFeeStatus({
    required this.feeOwed,
    required this.feePercent,
    required this.blockThreshold,
    required this.blocksGoingOnline,
  });

  factory PlatformFeeStatus.fromJson(Map<String, dynamic> json) {
    return PlatformFeeStatus(
      feeOwed: (json['feeOwed'] as num?)?.toDouble() ?? 0,
      feePercent: (json['feePercent'] as num?)?.toDouble() ?? 2.5,
      blockThreshold: (json['blockThreshold'] as num?)?.toDouble() ?? 50,
      blocksGoingOnline: json['blocksGoingOnline'] == true,
    );
  }
}

class TodayEarnings {
  final double todayEarnings;
  final int ordersToday;
  final DateTime? firstOnlineToday;

  TodayEarnings({required this.todayEarnings, required this.ordersToday, this.firstOnlineToday});

  factory TodayEarnings.fromJson(Map<String, dynamic> json) {
    return TodayEarnings(
      todayEarnings: (json['todayEarnings'] as num?)?.toDouble() ?? 0,
      ordersToday: (json['ordersToday'] as num?)?.toInt() ?? 0,
      firstOnlineToday: json['firstOnlineToday'] != null
          ? DateTime.tryParse(json['firstOnlineToday'] as String)
          : null,
    );
  }
}

/// Confirmed against the real backend - covers everything specific
/// to being a Baas: the online/offline toggle (blocked once an
/// outstanding platform fee passes the minimum), the platform fee
/// itself and paying it off from wallet, today's earnings summary,
/// and the service/rate profile shown to customers.
class BaasProfileService {
  BaasProfileService._internal();
  static final BaasProfileService instance = BaasProfileService._internal();

  final _api = ApiClient.instance;

  /// Throws ApiException(code: 'PLATFORM_FEE_DUE') if trying to go
  /// online (active: true) while an outstanding fee blocks it - the
  /// exception's `data['feeOwed']` carries the amount to show.
  Future<bool> setAvailability(bool active) async {
    final data = await _api.put('/api/baas/availability', body: {'active': active});
    return data['active'] == true;
  }

  Future<PlatformFeeStatus> platformFeeStatus() async {
    final data = await _api.get('/api/baas/platform-fee');
    return PlatformFeeStatus.fromJson(data);
  }

  Future<void> payPlatformFeeFromWallet() async {
    await _api.post('/api/baas/platform-fee/pay-wallet');
  }

  Future<TodayEarnings> earningsToday() async {
    final data = await _api.get('/api/baas/earnings-today');
    return TodayEarnings.fromJson(data);
  }

  Future<BaasProfile> updateProfile({
    List<String>? services,
    double? dailyRate,
    String? about,
    String? displayName,
    String? location,
  }) async {
    final data = await _api.put('/api/baas/profile', body: {
      if (services != null) 'services': services,
      if (dailyRate != null) 'dailyRate': dailyRate,
      if (about != null) 'about': about,
      if (displayName != null) 'displayName': displayName,
      if (location != null) 'location': location,
    });
    return BaasProfile.fromJson(data['baasProfile'] as Map<String, dynamic>? ?? {});
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    await _api.put('/api/baas/location', body: {'latitude': latitude, 'longitude': longitude});
  }
}
