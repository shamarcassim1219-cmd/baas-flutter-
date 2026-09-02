import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/baas_complaint_service.dart';
import '../../utils/formatters.dart';
import '../../localization/locale_controller.dart';

/// Complaints customers have filed against this account - reason,
/// details, and any photo they attached. Confirmed against the real
/// backend: GET /api/baas/complaints, filtered server-side to this
/// account already.
class BaasComplaintsScreen extends StatefulWidget {
  const BaasComplaintsScreen({super.key});

  @override
  State<BaasComplaintsScreen> createState() => _BaasComplaintsScreenState();
}

class _BaasComplaintsScreenState extends State<BaasComplaintsScreen> {
  bool _loading = true;
  String? _error;
  List<BaasComplaint> _complaints = [];

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
      final list = await BaasComplaintService.instance.myComplaints();
      if (!mounted) return;
      setState(() {
        _complaints = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load complaints. Pull down to try again.';
        _loading = false;
      });
    }
  }

  void _viewPhoto(String base64DataUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
          body: Center(
            child: InteractiveViewer(
              child: _decodedImage(base64DataUrl, BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _decodedImage(String dataUrl, BoxFit fit) {
    try {
      final commaIndex = dataUrl.indexOf(',');
      final bytes = base64Decode(commaIndex != -1 ? dataUrl.substring(commaIndex + 1) : dataUrl);
      return Image.memory(bytes, fit: fit);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LocaleController>().t;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(t('complaints'))),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _load,
                child: _complaints.isEmpty && _error == null
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 80),
                            child: Center(
                              child: Column(
                                children: [
                                  const Icon(Icons.flag_outlined, size: 48, color: AppColors.textMuted),
                                  const SizedBox(height: 12),
                                  Text(t('noComplaints'), style: const TextStyle(color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        children: [
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
                            ),
                          ..._complaints.map(_buildRow),
                        ],
                      ),
              ),
      ),
    );
  }

  Widget _buildRow(BaasComplaint c) {
    final (color, bg) = switch (c.status) {
      'Approved' => (AppColors.danger, AppColors.dangerSoft),
      'Rejected' => (AppColors.success, AppColors.successSoft),
      _ => (AppColors.warning, AppColors.warningSoft),
    };

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
              Expanded(child: Text(c.reason, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
                child: Text(c.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(c.orderId, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text(c.details, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          if (c.photos.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: c.photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final img = _decodedImage(c.photos[i], BoxFit.cover);
                  return InkWell(
                    onTap: () => _viewPhoto(c.photos[i]),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: img ?? Container(color: AppColors.border),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(formatShortDate(c.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
