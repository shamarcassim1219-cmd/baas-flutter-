import 'api_client.dart';

class BaasComplaint {
  final String id;
  final String complaintId;
  final String orderId;
  final String reason;
  final String details;
  final List<String> photos;
  final String status; // Pending | Approved | Rejected
  final DateTime createdAt;

  BaasComplaint({
    required this.id,
    required this.complaintId,
    required this.orderId,
    required this.reason,
    required this.details,
    required this.photos,
    required this.status,
    required this.createdAt,
  });

  factory BaasComplaint.fromJson(Map<String, dynamic> json) {
    return BaasComplaint(
      id: json['id'] as String? ?? '',
      complaintId: json['complaintId'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      details: json['details'] as String? ?? '',
      photos: (json['photos'] as List?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status'] as String? ?? 'Pending',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// Confirmed against the real backend: GET /api/baas/complaints
/// returns complaints filed against this Baas by customers - reason,
/// details, and any photos the customer attached.
class BaasComplaintService {
  BaasComplaintService._internal();
  static final BaasComplaintService instance = BaasComplaintService._internal();

  final _api = ApiClient.instance;

  Future<List<BaasComplaint>> myComplaints() async {
    final data = await _api.get('/api/baas/complaints');
    final list = (data['complaints'] as List?) ?? [];
    return list.map((e) => BaasComplaint.fromJson(e as Map<String, dynamic>)).toList();
  }
}
