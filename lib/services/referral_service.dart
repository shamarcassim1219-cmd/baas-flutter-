import 'api_client.dart';

class ReferralInfo {
  final String referralCode;
  final int referredCount;
  final double totalEarnings;

  ReferralInfo({
    required this.referralCode,
    required this.referredCount,
    required this.totalEarnings,
  });

  factory ReferralInfo.fromJson(Map<String, dynamic> json) {
    return ReferralInfo(
      referralCode: json['referralCode'] as String? ?? '',
      referredCount: (json['referredCount'] as num?)?.toInt() ?? 0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Confirmed against the real backend: GET /api/referral/info ->
/// {success, referralCode, referredCount, totalEarnings} - this
/// endpoint (and the referral bonus logic behind it) is
/// role-agnostic, so it works the same way here as it does for the
/// customer app - a Baas referring another Baas earns 1% of that
/// referred account's first wallet top-up.
class ReferralService {
  ReferralService._internal();
  static final ReferralService instance = ReferralService._internal();

  final _api = ApiClient.instance;

  Future<ReferralInfo> load() async {
    final data = await _api.get('/api/referral/info');
    return ReferralInfo.fromJson(data);
  }
}
