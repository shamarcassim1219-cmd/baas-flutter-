import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/support_service.dart';
import '../../localization/locale_controller.dart';

/// Live support chat - sends a message, polls for a reply every few
/// seconds. Same backend endpoints as the customer app's support
/// chat (role-agnostic).
class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  String? _queryId;
  List<ChatMessage> _messages = [];
  bool _queryOpen = true;
  bool _sending = false;
  bool _loadingHistory = true;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadExistingChat();
  }

  /// Resumes the most recent open conversation, if any, instead of
  /// always starting blank - a Baas closing and reopening this
  /// screen mid-conversation should still see what was already said.
  Future<void> _loadExistingChat() async {
    try {
      final existing = await SupportService.instance.mostRecentOpenChat();
      if (!mounted) return;

      if (existing != null) {
        setState(() {
          _queryId = existing.id;
          _messages = existing.messages;
          _queryOpen = existing.isOpen;
          _loadingHistory = false;
        });
        _scrollToBottom();
        _startPolling();
      } else {
        setState(() => _loadingHistory = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingHistory = false);
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _sending = true;
      _error = null;
    });

    try {
      _queryId ??= (await SupportService.instance.createQuery()).id;
      await SupportService.instance.sendMessage(_queryId!, text);
      _messageController.clear();
      await _refresh();
      _startPolling();
    } catch (e) {
      setState(() => _error = 'Unable to send your message. Please try again.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _refresh() async {
    if (_queryId == null) return;
    try {
      final query = await SupportService.instance.getQuery(_queryId!);
      if (!mounted) return;
      setState(() {
        _messages = query.messages;
        _queryOpen = query.isOpen;
      });
      _scrollToBottom();
      if (!query.isOpen) _pollTimer?.cancel();
    } catch (_) {
      // Silent - next poll tick tries again.
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) => _refresh());
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _startNewConversation() async {
    _pollTimer?.cancel();
    setState(() {
      _queryId = null;
      _messages = [];
      _queryOpen = true;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleController>().t;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(t('support'))),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _loadingHistory
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.support_agent_outlined, size: 48, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text(
                              t('sendMessageHint'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length + (_queryOpen ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) return _buildClosedNotice(t);
                        return _buildMessageBubble(_messages[index]);
                      },
                    ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 12.5)),
              ),
            _buildInputBar(t),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.isFromMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: isMe ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          message.message,
          style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildClosedNotice(String Function(String) t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: AppColors.warningSoft, borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
            child: Text(t('chatClosed'), style: const TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: _startNewConversation, child: Text(t('startNewConversation'))),
        ],
      ),
    );
  }

  Widget _buildInputBar(String Function(String) t) {
    final disabled = !_queryOpen;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !disabled,
              decoration: InputDecoration(
                hintText: disabled ? t('conversationClosed') : t('typeMessage'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: disabled ? null : _send,
            icon: _sending
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                : const Icon(Icons.send, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
