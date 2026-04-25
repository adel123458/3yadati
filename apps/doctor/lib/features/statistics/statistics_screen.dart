import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/skeletons.dart';
import '../../data/models/models.dart';
import '../../data/repositories.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewProvider);
    final weeklyAsync = ref.watch(weeklyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('الإحصائيات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          overviewAsync.when(
            data: (o) {
              final cards = [
                AppStatCard(
                  title: 'حجوزات اليوم',
                  value: '${o.todayTotal}',
                  icon: Icons.event_rounded,
                  color: AppColors.info,
                  gradient: AppColors.infoGradient,
                  trend: '+8%',
                ),
                AppStatCard(
                  title: 'مؤكدة',
                  value: '${o.todayConfirmed}',
                  icon: Icons.check_circle_rounded,
                  color: AppColors.success,
                  gradient: AppColors.successGradient,
                ),
                AppStatCard(
                  title: 'قيد الانتظار',
                  value: '${o.todayPending}',
                  icon: Icons.hourglass_top_rounded,
                  color: AppColors.warning,
                  gradient: AppColors.warningGradient,
                ),
                AppStatCard(
                  title: 'ملغاة',
                  value: '${o.todayCancelled}',
                  icon: Icons.cancel_rounded,
                  color: AppColors.danger,
                  gradient: AppColors.dangerGradient,
                ),
                AppStatCard(
                  title: 'إجمالي المرضى',
                  value: '${o.totalPatients}',
                  icon: Icons.groups_rounded,
                  color: AppColors.primary,
                  gradient: AppColors.primaryGradient,
                ),
                AppStatCard(
                  title: 'إيرادات اليوم',
                  value: formatCurrency(o.todayRevenue, 'دج'),
                  icon: Icons.payments_rounded,
                  color: AppColors.violet,
                  gradient: AppColors.violetGradient,
                  trend: '+18%',
                ),
              ];
              return AnimationLimiter(
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.45,
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
            },
            loading: () => const StatGridSkeleton(count: 6),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 18),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.show_chart_rounded, color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Text('نظرة عامة على الحجوزات',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                    Spacer(),
                    Text('آخر 7 أيام',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 200,
                  child: weeklyAsync.when(
                    data: (data) => _BarsChart(values: data.isEmpty ? [0, 0, 0, 0, 0, 0, 0] : data),
                    loading: () => const ChartSkeleton(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          overviewAsync.when(
            data: (o) => Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: AppCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('توزيع الحالات',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 10),
                        SizedBox(height: 150, child: _StatusDonut(o: o)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            loading: () => const ChartSkeleton(height: 220),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 18),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 18),
                    SizedBox(width: 8),
                    Text('الحجوزات حسب الحالة',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 14),
                overviewAsync.when(
                  data: (o) => _StatusBars(o: o),
                  loading: () => const ChartSkeleton(height: 120),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarsChart extends StatelessWidget {
  final List<int> values;
  const _BarsChart({required this.values});

  @override
  Widget build(BuildContext context) {
    final maxV = (values.reduce((a, b) => a > b ? a : b)).toDouble();
    return BarChart(
      BarChartData(
        maxY: (maxV == 0 ? 1 : maxV) * 1.25,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (_) =>
              FlLine(color: AppColors.divider, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (v, _) {
                const labels = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
                final i = v.toInt();
                if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(labels[i],
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i].toDouble(),
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _StatusBars extends StatelessWidget {
  final StatisticsOverview o;
  const _StatusBars({required this.o});

  @override
  Widget build(BuildContext context) {
    final entries = [
      ('مؤكدة', o.todayConfirmed, AppColors.successGradient),
      ('قيد الانتظار', o.todayPending, AppColors.warningGradient),
      ('مكتملة', o.todayCompleted, AppColors.infoGradient),
      ('ملغاة', o.todayCancelled, AppColors.dangerGradient),
    ];
    final maxV = entries.map((e) => e.$2).fold<int>(0, (a, b) => a > b ? a : b);
    return Column(
      children: entries.map((e) {
        final pct = maxV == 0 ? 0.0 : e.$2 / maxV;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(e.$1, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  ),
                  Text('${e.$2}', style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  children: [
                    Container(height: 8, color: AppColors.divider),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutCubic,
                      height: 8,
                      width: MediaQuery.of(context).size.width * 0.7 * pct,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: e.$3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatusDonut extends StatelessWidget {
  final StatisticsOverview o;
  const _StatusDonut({required this.o});

  @override
  Widget build(BuildContext context) {
    final entries = <(String, int, Color)>[
      ('مؤكدة', o.todayConfirmed, AppColors.success),
      ('قيد الانتظار', o.todayPending, AppColors.warning),
      ('مكتملة', o.todayCompleted, AppColors.info),
      ('ملغاة', o.todayCancelled, AppColors.danger),
    ];
    final total = entries.fold<int>(0, (a, b) => a + b.$2);
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 36,
              startDegreeOffset: -90,
              sections: total == 0
                  ? [
                      PieChartSectionData(
                        value: 1,
                        color: AppColors.divider,
                        showTitle: false,
                        radius: 18,
                      ),
                    ]
                  : entries.where((e) => e.$2 > 0).map((e) {
                      return PieChartSectionData(
                        value: e.$2.toDouble(),
                        color: e.$3,
                        showTitle: false,
                        radius: 22,
                      );
                    }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: e.$3, borderRadius: BorderRadius.circular(3))),
                    const SizedBox(width: 6),
                    Expanded(child: Text(e.$1, style: const TextStyle(fontSize: 11.5))),
                    Text('${e.$2}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
