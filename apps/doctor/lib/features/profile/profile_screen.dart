import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../data/repositories.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctor = ref.watch(doctorMeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: doctor.when(
        data: (d) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.person, color: AppColors.primary, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(d.user?.fullName ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  if (d.specialty != null)
                    Text(d.specialty!.nameAr, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  if (d.bio != null) Text(d.bio!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              children: [
                _Tile(icon: Icons.access_time, title: 'ساعات العمل', onTap: () => context.push('/working-hours')),
                _Tile(icon: Icons.location_on_outlined, title: 'الفروع', onTap: () => context.push('/branches')),
                _Tile(icon: Icons.notifications_outlined, title: 'الإشعارات', onTap: () => context.push('/notifications')),
              ],
            ),
            const SizedBox(height: 16),
            _Section(
              children: [
                _Tile(icon: Icons.language, title: 'اللغة', subtitle: 'العربية', onTap: () {}),
                _Tile(icon: Icons.dark_mode_outlined, title: 'المظهر', subtitle: 'فاتح', onTap: () {}),
                _Tile(icon: Icons.lock_outline, title: 'الأمان وكلمة المرور', onTap: () {}),
                _Tile(icon: Icons.help_outline, title: 'الدعم والمساعدة', onTap: () {}),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
              ),
              onPressed: () async {
                await ref.read(authRepoProvider).logout();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('تسجيل الخروج'),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('تعذر التحميل')),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final List<Widget> children;
  const _Section({required this.children});
  @override
  Widget build(BuildContext context) {
    final list = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      list.add(children[i]);
      if (i < children.length - 1) list.add(const Divider(height: 1));
    }
    return AppCard(padding: EdgeInsets.zero, child: Column(children: list));
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _Tile({required this.icon, required this.title, required this.onTap, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle == null ? null : Text(subtitle!, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_left, color: AppColors.textMuted),
    );
  }
}
