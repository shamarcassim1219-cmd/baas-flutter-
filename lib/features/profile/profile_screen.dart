import 'package:flutter/material.dart';
import '../../core/api.dart';
import '../../core/theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _me;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await Api.i.me();
      if (mounted) {
        setState(() {
          _me = Map<String, dynamic>.from((d['user'] ?? d) as Map);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await Api.i.clearToken();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final name = _me?['name']?.toString() ?? 'Baas';
    final phone = _me?['phone']?.toString() ?? '';
    final rating = (_me?['rating'] as num?)?.toDouble() ?? 0;
    final jobsDone = (_me?['jobs_completed'] as num?)?.toInt() ?? 0;
    final skills = (_me?['skills'] as List?) ?? [];
    final rate = (_me?['hourly_rate'] as num?)?.toDouble() ?? 0;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const SizedBox(height: 16),
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.teal.withOpacity(0.12),
            child: Icon(Icons.person, size: 46, color: AppColors.teal),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(name,
              style:
                  const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
        ),
        Center(child: Text(phone, style: TextStyle(color: Colors.grey[600]))),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _chip(Icons.star, '${rating.toStringAsFixed(1)}', 'Rating'),
            const SizedBox(width: 12),
            _chip(Icons.check_circle_outline, '$jobsDone', 'Wada'),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Skills',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                if (skills.isEmpty)
                  Text('Thawama skills ekathu karala naha',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13))
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: skills
                        .map((s) => Chip(
                              label: Text(s.toString()),
                              backgroundColor: AppColors.teal.withOpacity(0.08),
                              side: BorderSide.none,
                            ))
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.payments_outlined, color: AppColors.teal),
            title: const Text('Payi gaasthuwa'),
            trailing: Text('Rs. ${rate.toStringAsFixed(0)} / hour',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Profile eka wenas karanna'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Wada photos'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Udaw'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ],
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String value, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6E8EC)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.coral),
            const SizedBox(width: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      );
}
