/// One order/job as seen from the Baas side. The backend returns a
/// different field set depending on which list this came from (see
/// OrdersService.myOrders) - incoming requests don't have customer
/// contact info yet (that only unlocks on accept), while
/// active/completed do. Every field below is nullable/defaulted so
/// one model can represent all three views without three separate
/// classes.
class BaasOrder {
  final String id;
  final String orderId;
  final String service;
  final String location;
  final double? latitude;
  final double? longitude;
  final double? distanceKm;
  final int days;
  final double dailyRate;
  final double total;
  final String? paymentMethod; // pay_now | pay_direct - only on active/completed
  final double? baasAmount; // this Baas's actual take-home for the order, after commission
  final String preferredDate;
  final String status;
  final bool directRequest; // true if a customer specifically requested this Baas
  final String? customerName;
  final String? customerMobile;
  final String? createdAt;
  final String? acceptedAt;
  final String? completedAt;

  BaasOrder({
    required this.id,
    required this.orderId,
    required this.service,
    required this.location,
    this.latitude,
    this.longitude,
    this.distanceKm,
    required this.days,
    required this.dailyRate,
    required this.total,
    this.paymentMethod,
    this.baasAmount,
    required this.preferredDate,
    required this.status,
    this.directRequest = false,
    this.customerName,
    this.customerMobile,
    this.createdAt,
    this.acceptedAt,
    this.completedAt,
  });

  factory BaasOrder.fromJson(Map<String, dynamic> json) {
    return BaasOrder(
      id: json['id'] as String? ?? '',
      orderId: json['orderId'] as String? ?? '',
      service: json['service'] as String? ?? '',
      location: json['location'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      days: (json['days'] as num?)?.toInt() ?? 1,
      dailyRate: (json['dailyRate'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['paymentMethod'] as String?,
      baasAmount: (json['baasAmount'] as num?)?.toDouble(),
      preferredDate: json['preferredDate'] as String? ?? '',
      status: json['status'] as String? ?? 'Pending',
      directRequest: json['directRequest'] == true,
      customerName: json['customerName'] as String?,
      customerMobile: json['customerMobile'] as String?,
      createdAt: json['createdAt'] as String?,
      acceptedAt: json['acceptedAt'] as String?,
      completedAt: json['completedAt'] as String?,
    );
  }
}
