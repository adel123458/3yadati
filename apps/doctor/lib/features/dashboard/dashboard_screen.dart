import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/repositories.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewProvider);
    final doctorAsync = ref.watch(doctorMeProvider);
    final unreadAsync = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(overviewProvider);
            ref.invalidate(doctorMeProvider);
            ref.invalidate(unreadCountProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              // Header
              doctorAsync.when(
                data: (d) => _Header(name: d.user?.fullName ?? 'الطبيب', specialty: d.specialty?.nameAr ?? '', unread: unreadAsync.valueOrNull ?? 0),
                loading: () => _Header(name: '...', specialty: '', unread: unreadAsync.valueOrNull ?? 0),
                error: (_, __) => _Header(name: '...', specialty: '', unread: unreadAsync.valueOrNull ?? 0),
              ),
              const SizedBox(height: 16),
              const Text('إليك ملخص عيادتك لليوم', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 16),

              // Stat grid
              overviewAsync.when(
                data: (o) => _StatGrid(o: o),
                loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                error: (_, __) => const Text('تعذّر تحميل الإحصائيات'),
              ),

              const SizedBox(height: 24),
              const _SectionTitle('الإجراءات السريعة'),
              const SizedBox(height: 12),
              _QuickActions(),
              const SizedBox(height: 24),
              const _SectionTitle('المواعيد القادمة'),
              const SizedBox(height: 12),
              overviewAsync.when(
                data: (o) {
                  if (o.upcoming.isEmpty) return const _EmptyState(text: 'لا توجد مواعيد قادمة');
                  return Column(
                    children: o.upcoming.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        onTap: () => context.push('/appointment/${a.id}'),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: appointmentColor(a.status).withOpacity(0.15),
                              child: Icon(Icons.person, color: appointmentColor(a.status)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.patient?.fullName ?? 'موعد', style: const TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(a.reason ?? 'استشارة', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(formatTimeArabic(a.startAt), style: const TextStyle(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                StatusBadge(status: a.status, small: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String name;
  final String specialty;
  final int unread;
  const _Header({required this.name, required this.specialty, required this.unread});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.primaryLight,
          child: Icon(Icons.person, color: AppColors.primary, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('مرحبًا 👋', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 2),
              Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              if (specialty.isNotEmpty)
                Text(specialty, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
        IconButton.outlined(
          onPressed: () => context.push('/notifications'),
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined),
              if (unread > 0)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                    child: Text(
                      '$unread',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatGrid extends StatelessWidget {
  final dynamic o;
  const _StatGrid({required this.o});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        AppStatCard(
          title: 'إجمالي الإيرادات',
          value: formatCurrency(o.todayRevenue, 'دج'),
          icon: Icons.trending_up,
          color: AppColors.violet,
          trend: '+18%',
        ),
        AppStatCard(
          title: 'المرضى الجدد',
          value: '${o.newPatientsThisWeek}',
          icon: Icons.people,
          color: AppColors.success,
          trend: '+12%',
        ),
        AppStatCard(
          title: 'إجمالي الحجوزات',
          value: '${o.todayTotal}',
          icon: Icons.calendar_today,
          color: AppColors.info,
          trend: '+8%',
        ),
        AppStatCard(
          title: 'المواعيد القادمة',
          value: '${o.upcoming.length}',
          icon: Icons.access_time,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _QuickAction(icon: Icons.calendar_month, label: 'التقويم', onTap: () => context.push('/calendar'))),
        const SizedBox(width: 8),
        Expanded(child: _QuickAction(icon: Icons.access_time, label: 'ساعات العمل', onTap: () => context.push('/working-hours'))),
        const SizedBox(width: 8),
        Expanded(child: _QuickAction(icon: Icons.location_on_outlined, label: 'الفروع', onTap: () => context.push('/branches'))),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) =>
      Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800));
}

class _EmptyState extends StatelessWidget {
  final String text;
  const _EmptyState({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(color: AppColors.textSecondary)),
    );
  }
}
