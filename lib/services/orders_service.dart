import 'api_client.dart';
import '../models/baas_order.dart';

/// Confirmed against the real backend (GET /api/baas/orders?type=):
/// - incoming: open requests this Baas could accept
/// - active: accepted, not yet completed (includes customer contact)
/// - completed: finished job history
class OrdersService {
  OrdersService._internal();
  static final OrdersService instance = OrdersService._internal();

  final _api = ApiClient.instance;

  Future<List<BaasOrder>> myOrders(String type) async {
    final data = await _api.get('/api/baas/orders', query: {'type': type});
    final list = (data['orders'] as List?) ?? [];
    return list.map((e) => BaasOrder.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Confirmed against the real backend: GET /api/orders/:id -
  /// accessible to the Baas assigned to the order (not just the
  /// customer who created it), used by JobDetailScreen so anywhere
  /// a Baas sees an orderId referenced (a complaint against them, a
  /// wallet transaction) they can tap through to the full order.
  Future<BaasOrder> getOrder(String orderId) async {
    final data = await _api.get('/api/orders/$orderId');
    return BaasOrder.fromJson(data['order'] as Map<String, dynamic>);
  }

  Future<void> acceptOrder(String orderId) => _api.post('/api/orders/$orderId/accept');
  Future<void> rejectOrder(String orderId) => _api.post('/api/orders/$orderId/reject');
  Future<void> completeOrder(String orderId) => _api.put('/api/orders/$orderId/complete');
}
