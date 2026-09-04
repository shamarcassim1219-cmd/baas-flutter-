import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/orders_service.dart';
import '../../models/baas_order.dart';
import '../../utils/formatters.dart';

/// Full detail for a single job/order - reached from anywhere an
/// orderId is referenced (a complaint filed against this Baas, a
/// wallet transaction). Always fetches fresh from the backend,
/// rather than trusting whatever partial copy of the order the
/// calling screen happened to have on hand.
class JobDetailScreen extends StatefulWidget {
  final String orderId;

  const JobDetailScreen({super.key, required this.orderId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _loading = true;
  String? _error;
  BaasOrder? _order;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final order = await OrdersService.instance.getOrder(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load this job. Pull down to try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Job Detail')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _load,
                child: _order == null
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(_error ?? 'Job not found.', style: const TextStyle(color: AppColors.danger)),
                          ),
                        ],
                      )
                    : _buildContent(_order!),
              ),
      ),
    );
  }

  Widget _buildContent(BaasOrder order) {
    final (badgeColor, badgeBg) = _statusColors(order.status);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(order.service, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
              child: Text(order.status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: badgeColor)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(order.orderId, style: const TextStyle(fontSize: 12.5, color: AppColors.textMuted, fontFamily: 'monospace')),
        const SizedBox(height: 24),

        _sectionCard([
          _row('Location', order.location),
          _row('Preferred Date', formatShortDate(DateTime.tryParse(order.preferredDate) ?? DateTime.now())),
          _row('Days', '${order.days} day${order.days == 1 ? '' : 's'}'),
          _row('Daily Rate', formatMoney(order.dailyRate)),
          _row('Total', formatMoney(order.baasAmount ?? order.total), emphasize: true),
        ]),

        if (order.customerName != null) ...[
          const SizedBox(height: 16),
          Text('Customer', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _sectionCard([
            _row('Name', order.customerName!),
            if (order.customerMobile != null && order.customerMobile!.isNotEmpty)
              _row('Mobile', order.customerMobile!),
          ]),
        ],

        if (order.paymentMethod != null) ...[
          const SizedBox(height: 16),
          Text('Payment', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _sectionCard([
            _row('Method', order.paymentMethod == 'pay_now' ? 'Pay Now' : 'Pay Direct'),
          ]),
        ],

        if (order.createdAt != null) ...[
          const SizedBox(height: 16),
          Text('Placed', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _sectionCard([
            _row('Date', formatShortDate(DateTime.tryParse(order.createdAt!) ?? DateTime.now())),
          ]),
        ],
      ],
    );
  }

  Widget _sectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(children: children),
    );
  }

  Widget _row(String label, String value, {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMuted))),
          Text(
            value,
            style: TextStyle(
              fontSize: emphasize ? 16 : 13.5,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
              color: emphasize ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _statusColors(String status) {
    switch (status) {
      case 'Completed':
        return (AppColors.success, AppColors.successSoft);
      case 'Accepted':
        return (AppColors.info, AppColors.infoSoft);
      case 'Cancelled':
      case 'Rejected':
        return (AppColors.danger, AppColors.dangerSoft);
      default:
        return (AppColors.warning, AppColors.warningSoft);
    }
  }
}
