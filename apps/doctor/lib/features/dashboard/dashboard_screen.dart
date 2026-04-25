import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/avatars.dart';
import '../../core/widgets/skeletons.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/models.dart';
import '../../data/repositories.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewProvider);
    final doctorAsync = ref.watch(doctorMeProvider);
    final unreadAsync = ref.watch(unreadCountProvider);
    final weeklyAsync = ref.watch(weeklyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(overviewProvider);
            ref.invalidate(doctorMeProvider);
            ref.invalidate(unreadCountProvider);
            ref.invalidate(weeklyProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              doctorAsync.when(
                data: (d) => _HeroHeader(
                  name: d.user?.fullName ?? 'الطبيب',
                  specialty: d.specialty?.nameAr ?? '',
                  unread: unreadAsync.valueOrNull ?? 0,
                ),
                loading: () => const HeroSkeleton(),
                error: (_, __) => _HeroHeader(
                  name: 'الطبيب',
                  specialty: '',
                  unread: unreadAsync.valueOrNull ?? 0,
                ),
              ),
              const SizedBox(height: 18),
              const SectionTitle(title: 'نظرة عامة', icon: Icons.dashboard_rounded),
              const SizedBox(height: 10),
              overviewAsync.when(
                data: (o) => _StatGrid(o: o, weekly: weeklyAsync.valueOrNull),
                loading: () => const StatGridSkeleton(),
                error: (_, __) => const Text('تعذّر تحميل الإحصائيات'),
              ),
              const SizedBox(height: 22),
              const SectionTitle(title: 'الإجراءات السريعة', icon: Icons.bolt_rounded),
              const SizedBox(height: 10),
              const _QuickActions(),
              const SizedBox(height: 22),
              SectionTitle(
                title: 'المواعيد القادمة',
                icon: Icons.event_available_rounded,
                action: 'عرض الكل',
                onAction: () => context.push('/calendar'),
              ),
              const SizedBox(height: 10),
              overviewAsync.when(
                data: (o) {
                  if (o.upcoming.isEmpty) {
                    return const EmptyState(
                      icon: Icons.event_note_rounded,
                      title: 'لا توجد مواعيد قادمة',
                      subtitle: 'سيظهر هنا أي موعد جديد فور حجزه.',
                    );
                  }
                  return AnimationLimiter(
                    child: Column(
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 380),
                        childAnimationBuilder: (w) => SlideAnimation(
                          horizontalOffset: 30,
                          child: FadeInAnimation(child: w),
                        ),
                        children: o.upcoming.map<Widget>((a) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _UpcomingTile(a: a),
                            )).toList(),
                      ),
                    ),
                  );
                },
                loading: () => const ListSkeleton(rows: 3),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final String name;
  final String specialty;
  final int unread;
  const _HeroHeader({required this.name, required this.specialty, required this.unread});

  @override
  Widget build(BuildContext context) {
    final today = formatArabicDate(DateTime.now());
    return GradientCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.18),
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.4),
                ),
                child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحبًا 👋',
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        )),
                    if (specialty.isNotEmpty)
                      Text(specialty,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 12.5,
                          )),
                  ],
                ),
              ),
              _BellButton(unread: unread),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    today,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'اليوم',
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 320.ms).slideY(begin: -0.06, curve: Curves.easeOut);
  }
}

class _BellButton extends StatelessWidget {
  final int unread;
  const _BellButton({required this.unread});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.white.withOpacity(0.18),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => GoRouter.of(context).push('/notifications'),
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.notifications_rounded, color: Colors.white),
            ),
          ),
        ),
        if (unread > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 1.4),
              ),
              alignment: Alignment.center,
              child: Text('$unread',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
            ),
          ),
      ],
    );
  }
}

class _StatGrid extends StatelessWidget {
  final StatisticsOverview o;
  final List<int>? weekly;
  const _StatGrid({required this.o, this.weekly});

  @override
  Widget build(BuildContext context) {
    final spark = (weekly ?? const [12, 18, 22, 16, 25, 14, 19]).map((e) => e.toDouble()).toList();
    final cards = [
      AppStatCard(
        title: 'إيرادات اليوم',
        value: formatCurrency(o.todayRevenue, 'دج'),
        icon: Icons.payments_rounded,
        color: AppColors.violet,
        gradient: AppColors.violetGradient,
        trend: '+18%',
        sparkline: spark,
      ),
      AppStatCard(
        title: 'المرضى الجدد',
        value: '${o.newPatientsThisWeek}',
        icon: Icons.group_add_rounded,
        color: AppColors.success,
        gradient: AppColors.successGradient,
        trend: '+12%',
        sparkline: spark.reversed.toList(),
      ),
      AppStatCard(
        title: 'حجوزات اليوم',
        value: '${o.todayTotal}',
        icon: Icons.event_rounded,
        color: AppColors.info,
        gradient: AppColors.infoGradient,
        trend: '+8%',
        sparkline: spark,
      ),
      AppStatCard(
        title: 'المواعيد القادمة',
        value: '${o.upcoming.length}',
        icon: Icons.schedule_rounded,
        color: AppColors.primary,
        gradient: AppColors.primaryGradient,
        sparkline: spark,
      ),
    ];
    return AnimationLimiter(
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.18,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(cards.length, (i) {
          return AnimationConfiguration.staggeredGrid(
            position: i,
            columnCount: 2,
            duration: const Duration(milliseconds: 380),
            child: ScaleAnimation(
              scale: 0.95,
              child: FadeInAnimation(child: cards[i]),
            ),
          );
        }),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.calendar_month_rounded,
            label: 'التقويم',
            gradient: AppColors.primaryGradient,
            onTap: () => GoRouter.of(context).push('/calendar'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickAction(
            icon: Icons.access_time_filled_rounded,
            label: 'ساعات العمل',
            gradient: AppColors.warningGradient,
            onTap: () => GoRouter.of(context).push('/working-hours'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickAction(
            icon: Icons.location_on_rounded,
            label: 'الفروع',
            gradient: AppColors.violetGradient,
            onTap: () => GoRouter.of(context).push('/branches'),
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          GradientIcon(icon: icon, gradient: gradient, size: 46, iconSize: 22),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.text)),
        ],
      ),
    );
  }
}

class _UpcomingTile extends StatelessWidget {
  final Appointment a;
  const _UpcomingTile({required this.a});

  @override
  Widget build(BuildContext context) {
    final color = appointmentColor(a.status);
    return AppCard(
      onTap: () => GoRouter.of(context).push('/appointment/${a.id}'),
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          GradientAvatar(name: a.patient?.fullName ?? 'موعد', size: 42),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.patient?.fullName ?? 'موعد',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(a.reason ?? 'استشارة',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(formatTimeArabic(a.startAt),
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              StatusBadge(status: a.status, small: true),
            ],
          ),
        ],
      ),
    );
  }
}
