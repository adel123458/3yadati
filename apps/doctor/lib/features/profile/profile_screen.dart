import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/avatars.dart';
import '../../data/repositories.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctor = ref.watch(doctorMeProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: doctor.when(
        data: (d) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: GradientCard(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 28),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        ),
                        const Spacer(),
                        const Text('حسابي',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                        const Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.edit_rounded, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.18),
                        border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                      ),
                      child: GradientAvatar(name: d.user?.fullName ?? 'الطبيب', size: 84),
                    ),
                    const SizedBox(height: 12),
                    Text(d.user?.fullName ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                    if (d.specialty != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(d.specialty!.nameAr,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ],
                    if (d.bio != null) ...[
                      const SizedBox(height: 12),
                      Text(d.bio!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withOpacity(0.92), fontSize: 12.5)),
                    ],
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              sliver: SliverList.list(
                children: [
                  const SectionTitle(title: 'إدارة العيادة', icon: Icons.dashboard_customize_rounded),
                  const SizedBox(height: 8),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.access_time_filled_rounded,
                        title: 'ساعات العمل',
                        gradient: AppColors.warningGradient,
                        onTap: () => context.push('/working-hours'),
                      ),
                      _MenuItem(
                        icon: Icons.location_on_rounded,
                        title: 'الفروع',
                        gradient: AppColors.violetGradient,
                        onTap: () => context.push('/branches'),
                      ),
                      _MenuItem(
                        icon: Icons.notifications_rounded,
                        title: 'الإشعارات',
                        gradient: AppColors.dangerGradient,
                        onTap: () => context.push('/notifications'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const SectionTitle(title: 'الإعدادات', icon: Icons.settings_rounded),
                  const SizedBox(height: 8),
                  _MenuCard(
                    items: [
                      _MenuItem(
                        icon: Icons.language_rounded,
                        title: 'اللغة',
                        subtitle: 'العربية',
                        gradient: AppColors.infoGradient,
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.dark_mode_rounded,
                        title: 'المظهر',
                        subtitle: 'فاتح',
                        gradient: AppColors.violetGradient,
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.lock_rounded,
                        title: 'الأمان وكلمة المرور',
                        gradient: AppColors.successGradient,
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.help_rounded,
                        title: 'الدعم والمساعدة',
                        gradient: AppColors.pinkGradient,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                    ),
                    onPressed: () async {
                      await ref.read(authRepoProvider).logout();
                      if (context.mounted) context.go('/login');
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('تسجيل الخروج'),
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'تعذر تحميل الملف الشخصي',
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      GradientIcon(icon: item.icon, gradient: item.gradient, size: 38, iconSize: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                            if (item.subtitle != null) ...[
                              const SizedBox(height: 2),
                              Text(item.subtitle!,
                                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
              if (i < items.length - 1)
                const Padding(
                  padding: EdgeInsets.only(right: 64, left: 14),
                  child: Divider(height: 1),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.gradient,
    required this.onTap,
    this.subtitle,
  });
}
