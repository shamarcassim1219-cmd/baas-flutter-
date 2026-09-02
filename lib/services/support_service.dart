import 'api_client.dart';

class ChatMessage {
  final String id;
  final String senderType; // 'customer' | 'admin' - confirmed field name (this app's user is also just "customer" role-wise to this endpoint)
  final String message;
  final DateTime createdAt;

  ChatMessage({required this.id, required this.senderType, required this.message, required this.createdAt});

  bool get isFromMe => senderType != 'admin';

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? '',
      senderType: json['senderType'] as String? ?? 'admin',
      message: json['message'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class SupportQuery {
  final String id;
  final String status; // 'open' | 'closed'
  final List<ChatMessage> messages;

  SupportQuery({required this.id, required this.status, required this.messages});

  bool get isOpen => status == 'open';

  factory SupportQuery.fromJson(Map<String, dynamic> json) {
    final messagesRaw = (json['messages'] as List?) ?? [];
    return SupportQuery(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'open',
      messages: messagesRaw.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

/// Confirmed against the real backend (same endpoints as the
/// customer app - role-agnostic):
/// - GET /api/support/chats -> {success, chats} - this user's own
///   chats, newest first
/// - POST /api/support/chats -> {success, chat}
/// - GET /api/support/chats/:id -> {success, chat, messages}
/// - POST /api/support/chats/:id/messages -> {message: text}
class SupportService {
  SupportService._internal();
  static final SupportService instance = SupportService._internal();

  final _api = ApiClient.instance;

  /// The most recent OPEN chat, if any - lets the chat screen
  /// resume an existing conversation on open rather than always
  /// starting blank.
  Future<SupportQuery?> mostRecentOpenChat() async {
    final data = await _api.get('/api/support/chats');
    final chats = (data['chats'] as List?) ?? [];
    if (chats.isEmpty) return null;

    final openChat = chats.cast<Map<String, dynamic>>().firstWhere(
          (c) => (c['status'] as String? ?? 'open') == 'open',
          orElse: () => const {},
        );
    if (openChat.isEmpty) return null;

    return getQuery(openChat['id'] as String? ?? '');
  }

  Future<SupportQuery> createQuery() async {
    final data = await _api.post('/api/support/chats', body: {});
    return SupportQuery.fromJson({
      ...(data['chat'] as Map<String, dynamic>? ?? {}),
      'messages': const [],
    });
  }

  Future<SupportQuery> getQuery(String queryId) async {
    final data = await _api.get('/api/support/chats/$queryId');
    return SupportQuery.fromJson({
      ...(data['chat'] as Map<String, dynamic>? ?? {}),
      'messages': data['messages'] ?? const [],
    });
  }

  Future<void> sendMessage(String queryId, String message) async {
    await _api.post('/api/support/chats/$queryId/messages', body: {'message': message});
  }
}
