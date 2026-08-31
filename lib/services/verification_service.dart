import 'api_client.dart';

class VerificationInfo {
  final String status; // 'Pending' | 'Approved' | 'Rejected'
  final String? note;
  final String fullName;
  final String nic;
  final String phone;
  final String address;
  final String province;
  final String district;

  VerificationInfo({
    required this.status,
    this.note,
    required this.fullName,
    required this.nic,
    required this.phone,
    required this.address,
    required this.province,
    required this.district,
  });

  bool get isPending => status == 'Pending';
  bool get isApproved => status == 'Approved';
  bool get isRejected => status == 'Rejected';

  factory VerificationInfo.fromJson(Map<String, dynamic> json) {
    return VerificationInfo(
      status: json['status'] as String? ?? 'Pending',
      note: json['note'] as String?,
      fullName: json['fullName'] as String? ?? '',
      nic: json['nic'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      province: json['province'] as String? ?? '',
      district: json['district'] as String? ?? '',
    );
  }
}

/// Confirmed against the real backend: POST /api/users/verification
/// takes fullName, nic, phone, address, province, district, and
/// three base64-encoded photos (nicPhoto, nicBackPhoto, selfiePhoto -
/// all required for a Sri Lankan/local account). Submitting always
/// sets status to "Pending" - the badge only turns on once an admin
/// later sets it to "Approved" via a separate admin-side endpoint.
class VerificationService {
  VerificationService._internal();
  static final VerificationService instance = VerificationService._internal();

  final _api = ApiClient.instance;

  Future<void> submit({
    required String fullName,
    required String nic,
    required String phone,
    required String address,
    required String province,
    required String district,
    required String nicPhotoBase64,
    required String nicBackPhotoBase64,
    required String selfiePhotoBase64,
  }) async {
    await _api.post('/api/users/verification', body: {
      'fullName': fullName,
      'nic': nic,
      'phone': phone,
      'address': address,
      'province': province,
      'district': district,
      'nicPhoto': nicPhotoBase64,
      'nicBackPhoto': nicBackPhotoBase64,
      'selfiePhoto': selfiePhotoBase64,
    });
  }
}
