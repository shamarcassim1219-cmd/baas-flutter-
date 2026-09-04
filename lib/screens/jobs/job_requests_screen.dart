import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/orders_service.dart';
import '../../services/api_exception.dart';
import '../../models/baas_order.dart';
import '../../utils/formatters.dart';
import '../../localization/locale_controller.dart';
import '../../services/legal_service.dart';

/// Mirrors the backend's three-view /api/baas/orders?type= endpoint
/// as three tabs: Incoming (open requests to accept/reject), Active
/// (accepted, in progress - shows the customer's contact, since
/// accepting is what unlocks that), and Completed (job history).
class JobRequestsScreen extends StatefulWidget {
  const JobRequestsScreen({super.key});

  @override
  State<JobRequestsScreen> createState() => _JobRequestsScreenState();
}

class _JobRequestsScreenState extends State<JobRequestsScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabController;

  bool _loading = true;
  String? _error;
  List<BaasOrder> _incoming = [];
  List<BaasOrder> _active = [];
  List<BaasOrder> _completed = [];

  // Tracks orders being accepted/rejected right now, so their
  // buttons show a spinner instead of the whole tab reloading.
  final Set<String> _actioning = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  /// Refreshes incoming/active/completed job lists whenever the app
  /// comes back to the foreground - without this, a new incoming job
  /// request or an accept/reject made from another device wouldn't
  /// show up until manually pulled to refresh.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        OrdersService.instance.myOrders('incoming'),
        OrdersService.instance.myOrders('active'),
        OrdersService.instance.myOrders('completed'),
      ]);

      if (!mounted) return;
      setState(() {
        _incoming = results[0];
        _active = results[1];
        _completed = results[2];
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load job requests. Pull down to try again.';
        _loading = false;
      });
    }
  }

  Future<void> _accept(BaasOrder order) async {
    final agreed = await _showAcceptTermsDialog(order);
    if (agreed != true) return;

    final locale = context.read<LocaleController>();
    LegalService.instance.agree(context: 'baas_accept', language: locale.langCode);

    setState(() => _actioning.add(order.id));
    try {
      await OrdersService.instance.acceptOrder(order.orderId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order accepted.')),
      );
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _actioning.remove(order.id));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _actioning.remove(order.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to accept this order. Please try again.')),
      );
    }
  }

  Future<bool?> _showAcceptTermsDialog(BaasOrder order) async {
    bool agreed = false;

    return showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Accept Job'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Accept "${order.service}"?'),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => setDialogState(() => agreed = !agreed),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: agreed,
                      onChanged: (v) => setDialogState(() => agreed = v ?? false),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 14),
                        child: Text(
                          'I agree to the job acceptance terms and conditions',
                          style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            TextButton(
              onPressed: agreed ? () => Navigator.of(context).pop(true) : null,
              child: const Text('Accept'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _reject(BaasOrder order) async {
    final t = context.read<LocaleController>().t;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('rejectOrderTitle')),
        content: Text('${t('rejectOrderConfirm')} "${order.service}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(t('cancel'))),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(t('reject'))),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _actioning.add(order.id));
    try {
      await OrdersService.instance.rejectOrder(order.orderId);
      if (!mounted) return;
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _actioning.remove(order.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to reject this order. Please try again.')),
      );
    }
  }

  Future<void> _complete(BaasOrder order) async {
    final t = context.read<LocaleController>().t;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('markCompleteTitle')),
        content: Text('"${order.service}" - ${t('markCompleteConfirm')}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(t('cancel'))),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: Text(t('markComplete'))),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _actioning.add(order.id));
    try {
      await OrdersService.instance.completeOrder(order.orderId);
      if (!mounted) return;
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _actioning.remove(order.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to mark this order complete. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleController>().t;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(t('jobRequests')),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.accent,
          tabs: [
            Tab(text: '${t('incoming')} (${_incoming.length})'),
            Tab(text: '${t('active')} (${_active.length})'),
            Tab(text: t('completed')),
          ],
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _load,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(t, _incoming, _buildIncomingCard),
                    _buildList(t, _active, _buildActiveCard),
                    _buildList(t, _completed, _buildCompletedCard),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildList(String Function(String) t, List<BaasOrder> orders, Widget Function(BaasOrder) cardBuilder) {
    if (orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 80),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text(t('nothingHereYet'), style: const TextStyle(color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: orders.map(cardBuilder).toList(),
    );
  }

  Widget _buildIncomingCard(BaasOrder order) {
    final t = context.read<LocaleController>().t;
    final busy = _actioning.contains(order.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(order.service, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
              if (order.directRequest)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Text(
                    t('requestedYou'),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.accent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(order.location, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          if (order.distanceKm != null) ...[
            const SizedBox(height: 3),
            Text('${order.distanceKm!.toStringAsFixed(1)} ${t('kmAway')}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${order.days} ${order.days == 1 ? t('day') : t('days')}', style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
              Text(formatMoney(order.total), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy ? null : () => _reject(order),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44), foregroundColor: AppColors.danger),
                  child: Text(t('reject')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: busy ? null : () => _accept(order),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                  child: busy
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(t('accept')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCard(BaasOrder order) {
    final t = context.read<LocaleController>().t;
    final busy = _actioning.contains(order.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(order.service, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 6),
          Text(order.location, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          if (order.customerName != null) ...[
            const SizedBox(height: 6),
            Text('${t('customer')}: ${order.customerName}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          ],
          if (order.customerMobile != null && order.customerMobile!.isNotEmpty) ...[
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(Icons.phone, size: 13, color: AppColors.success),
                const SizedBox(width: 4),
                Text(order.customerMobile!, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.success)),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${order.days} ${order.days == 1 ? t('day') : t('days')}', style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
              Text(
                order.baasAmount != null ? formatMoney(order.baasAmount!) : formatMoney(order.total),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: busy ? null : () => _complete(order),
              child: busy
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(t('markComplete')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCard(BaasOrder order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(order.service, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
              const Icon(Icons.check_circle, size: 18, color: AppColors.success),
            ],
          ),
          const SizedBox(height: 6),
          Text(order.location, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Text(
            order.baasAmount != null ? formatMoney(order.baasAmount!) : formatMoney(order.total),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
