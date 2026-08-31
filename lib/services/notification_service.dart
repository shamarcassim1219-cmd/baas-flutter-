import 'api_client.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool read;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      type: json['type'] as String? ?? 'general',
      read: json['read'] == true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// Confirmed against the real backend (same role-agnostic endpoints
/// as the customer app): GET /api/notifications, PUT /api/notifications/:id/read,
/// PUT /api/notifications/read-all.
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final _api = ApiClient.instance;

  Future<List<AppNotification>> load() async {
    final data = await _api.get('/api/notifications');
    final list = (data['notifications'] as List?) ?? [];
    return list.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<int> unreadCount() async {
    final all = await load();
    return all.where((n) => !n.read).length;
  }

  Future<void> markRead(String id) => _api.put('/api/notifications/$id/read');
  Future<void> markAllRead() => _api.put('/api/notifications/read-all');
}
