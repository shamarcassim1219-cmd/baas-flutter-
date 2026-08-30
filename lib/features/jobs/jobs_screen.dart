import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/api.dart';
import '../../core/theme.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});
  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabs,
            labelColor: AppColors.teal,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.teal,
            tabs: const [
              Tab(text: 'Aluth'),
              Tab(text: 'Karagena yana'),
              Tab(text: 'Ivarai'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: const [
              JobList(status: 'new'),
              JobList(status: 'ongoing'),
              JobList(status: 'completed'),
            ],
          ),
        ),
      ],
    );
  }
}

class JobList extends StatefulWidget {
  final String status;
  const JobList({super.key, required this.status});
  @override
  State<JobList> createState() => _JobListState();
}

class _JobListState extends State<JobList> {
  List<dynamic> _jobs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final j = await Api.i.jobs(widget.status);
      if (mounted) setState(() { _jobs = j; _loading = false; });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  Future<void> _act(int id, String action, String confirmText) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(confirmText),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Naha')),
          FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Ow')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await Api.i.jobAction(id, action);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _load, child: const Text('Aye try karanna')),
          ],
        ),
      );
    }
    if (_jobs.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            const SizedBox(height: 120),
            Icon(Icons.inbox_outlined, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Center(
              child: Text('Meke wada naha',
                  style: TextStyle(color: Colors.grey[600])),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _jobs.length,
        itemBuilder: (_, i) => _JobCard(
          job: Map<String, dynamic>.from(_jobs[i]),
          status: widget.status,
          onAccept: (id) => _act(id, 'accept', 'Me wadaya bara gannawada?'),
          onReject: (id) => _act(id, 'reject', 'Me wadaya prathikshepa karanawada?'),
          onComplete: (id) => _act(id, 'complete', 'Wadaya ivara kalada?'),
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final String status;
  final void Function(int) onAccept, onReject, onComplete;

  const _JobCard({
    required this.job,
    required this.status,
    required this.onAccept,
    required this.onReject,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final id = (job['id'] as num).toInt();
    final amount = (job['amount'] as num?)?.toDouble() ?? 0;
    final fee = amount * 0.05;
    final money = NumberFormat('#,##0.00');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.teal.withOpacity(0.12),
                  child: Icon(Icons.person, color: AppColors.teal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job['customer_name']?.toString() ?? 'Customer',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(job['service']?.toString() ?? '-',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                Text('Rs. ${money.format(amount)}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.teal)),
              ],
            ),
            const SizedBox(height: 12),
            _row(Icons.location_on_outlined, job['address']?.toString() ?? '-'),
            _row(Icons.schedule, job['scheduled_at']?.toString() ?? '-'),
            if ((job['note']?.toString() ?? '').isNotEmpty)
              _row(Icons.notes, job['note'].toString()),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.coral.withOpacity(0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Service fee 5% = Rs. ${money.format(fee)}',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.coral,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 14),
            if (status == 'new')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onReject(id),
                      child: const Text('Epa'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => onAccept(id),
                      child: const Text('Bara ganna'),
                    ),
                  ),
                ],
              )
            else if (status == 'ongoing')
              FilledButton(
                onPressed: () => onComplete(id),
                child: const Text('Ivarai kiyanna'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
                child: Text(text,
                    style: TextStyle(color: Colors.grey[800], fontSize: 13))),
          ],
        ),
      );
}
