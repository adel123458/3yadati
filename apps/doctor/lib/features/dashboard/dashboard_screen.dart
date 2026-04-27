import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/avatars.dart';
import '../../core/widgets/dashboard_widgets.dart';
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
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 900;

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
            padding: EdgeInsets.fromLTRB(wide ? 24 : 14, 12, wide ? 24 : 14, 32),
            children: [
              doctorAsync.when(
                data: (d) => DashSearchHeader(
                  name: d.user?.fullName ?? 'الطبيب',
                  specialty: d.specialty?.nameAr ?? '',
                  unread: unreadAsync.valueOrNull ?? 0,
                  onBell: () => context.push('/notifications'),
                  onProfile: () => context.go('/profile'),
                ),
                loading: () => DashSearchHeader(
                  name: 'الطبيب',
                  specialty: '',
                  unread: unreadAsync.valueOrNull ?? 0,
                ),
                error: (_, __) => DashSearchHeader(
                  name: 'الطبيب',
                  specialty: '',
                  unread: unreadAsync.valueOrNull ?? 0,
                ),
              ),
              const SizedBox(height: 18),
              overviewAsync.when(
                data: (o) => _DashBody(
                  o: o,
                  weekly: weeklyAsync.valueOrNull,
                  wide: wide,
                ),
                loading: () => const _DashLoading(),
                error: (_, __) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('تعذّر تحميل الإحصائيات')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashLoading extends StatelessWidget {
  const _DashLoading();
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 4),
        StatGridSkeleton(),
        SizedBox(height: 16),
        ChartSkeleton(height: 240),
        SizedBox(height: 16),
        ListSkeleton(rows: 3),
      ],
    );
  }
}

class _DashBody extends StatelessWidget {
  final StatisticsOverview o;
  final List<int>? weekly;
  final bool wide;
  const _DashBody({required this.o, required this.weekly, required this.wide});

  @override
  Widget build(BuildContext context) {
    final spark = (weekly ?? const [12, 18, 22, 16, 25, 14, 19]).map((e) => e.toDouble()).toList();
    final highlightedIdx = _maxIdx(spark);
    final today = formatArabicDate(DateTime.now());

    final kpis = [
      KpiTile(
        label: 'حجوزات اليوم',
        value: '${o.todayTotal}',
        icon: Icons.event_rounded,
        gradient: AppColors.sidebarGradient,
        trend: '+8%',
      ),
      KpiTile(
        label: 'مرضى جدد',
        value: '${o.newPatientsThisWeek}',
        icon: Icons.group_add_rounded,
        gradient: AppColors.successGradient,
        trend: '+12%',
      ),
      KpiTile(
        label: 'مكتملة اليوم',
        value: '${o.todayCompleted}',
        icon: Icons.task_alt_rounded,
        gradient: AppColors.indigoGradient,
        trend: '+4%',
      ),
      KpiTile(
        label: 'الإيرادات',
        value: formatCurrency(o.todayRevenue, 'دج'),
        icon: Icons.payments_rounded,
        gradient: AppColors.warningGradient,
        trend: '+18%',
      ),
    ];

    final chart = BarChartCard(
      title: 'نمو الحجوزات',
      subtitle: 'نظرة أسبوعية — $today',
      values: spark,
      labels: const ['اث', 'ث', 'أر', 'خ', 'ج', 'س', 'أح'],
      unitSuffix: '',
      highlightedLabel: 'أعلى يوم',
      highlightedValue: highlightedIdx >= 0 ? spark[highlightedIdx] : 0,
    );

    final donutSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DonutPerformanceCard(
          percent: _safePerf(o),
          label: 'مؤشر الأداء',
          centerTitle: 'الأداء',
          subtitle: 'نسبة المواعيد المكتملة + المؤكدة',
        ),
        const SizedBox(height: 14),
        _AuditCard(o: o),
      ],
    );

    final upcoming = _UpcomingSection(o: o);

    if (wide) {
      // Two-column layout: main (KPIs + bar chart + table) and right (donut + audit)
      return LayoutBuilder(builder: (context, c) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _KpiGrid(items: kpis, columns: 4),
                  const SizedBox(height: 16),
                  chart,
                  const SizedBox(height: 18),
                  upcoming,
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(flex: 3, child: donutSection),
          ],
        );
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _KpiGrid(items: kpis, columns: 2),
        const SizedBox(height: 14),
        chart,
        const SizedBox(height: 14),
        donutSection,
        const SizedBox(height: 18),
        upcoming,
      ],
    );
  }

  int _maxIdx(List<double> v) {
    if (v.isEmpty) return -1;
    var idx = 0;
    for (var i = 1; i < v.length; i++) {
      if (v[i] > v[idx]) idx = i;
    }
    return idx;
  }

  double _safePerf(StatisticsOverview o) {
    final total = o.todayTotal;
    if (total == 0) return 0.0;
    final ok = o.todayCompleted + o.todayConfirmed;
    return (ok / total).clamp(0.0, 1.0);
  }
}

class _KpiGrid extends StatelessWidget {
  final List<Widget> items;
  final int columns;
  const _KpiGrid({required this.items, required this.columns});

  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      child: GridView.count(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: columns == 4 ? 1.55 : 1.18,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(items.length, (i) {
          return AnimationConfiguration.staggeredGrid(
            position: i,
            columnCount: columns,
            duration: const Duration(milliseconds: 380),
            child: ScaleAnimation(
              scale: 0.95,
              child: FadeInAnimation(child: items[i]),
            ),
          );
        }),
      ),
    );
  }
}

class _AuditCard extends StatelessWidget {
  final StatisticsOverview o;
  const _AuditCard({required this.o});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.summarize_rounded, color: AppColors.violet, size: 18),
              SizedBox(width: 8),
              Text(
                'ملخّص اليوم',
                style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.text, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AuditRow(label: 'مؤكدة', value: '${o.todayConfirmed}', color: AppColors.success),
          _AuditRow(label: 'قيد الانتظار', value: '${o.todayPending}', color: AppColors.amber),
          _AuditRow(label: 'مكتملة', value: '${o.todayCompleted}', color: AppColors.indigo),
          _AuditRow(label: 'ملغاة', value: '${o.todayCancelled}', color: AppColors.danger),
          const Divider(height: 24),
          Row(
            children: [
              const Text(
                'إجمالي المرضى',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '${o.totalPatients}',
                style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuditRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _AuditRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
          ),
          Text(value, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _UpcomingSection extends StatelessWidget {
  final StatisticsOverview o;
  const _UpcomingSection({required this.o});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_available_rounded, color: AppColors.violet, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'المواعيد القادمة',
                  style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.text, fontSize: 14),
                ),
              ),
              GestureDetector(
                onTap: () => GoRouter.of(context).push('/calendar'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.violetLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'عرض الكل',
                        style: TextStyle(color: AppColors.violet, fontSize: 11.5, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_back_rounded, color: AppColors.violet, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (o.upcoming.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'لا توجد مواعيد قادمة',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            AnimationLimiter(
              child: Column(
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 380),
                  childAnimationBuilder: (w) => SlideAnimation(
                    horizontalOffset: 30,
                    child: FadeInAnimation(child: w),
                  ),
                  children: o.upcoming.map<Widget>((a) => _UpcomingTile(a: a)).toList(),
                ),
              ),
            ),
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
    return InkWell(
      onTap: () => GoRouter.of(context).push('/appointment/${a.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 10),
            GradientAvatar(name: a.patient?.fullName ?? 'موعد', size: 38),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.patient?.fullName ?? 'موعد',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  const SizedBox(height: 3),
                  Text(a.reason ?? 'استشارة',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(formatTimeArabic(a.startAt),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                const SizedBox(height: 4),
                StatusBadge(status: a.status, small: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
