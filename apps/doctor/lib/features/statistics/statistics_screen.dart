import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../data/repositories.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(overviewProvider);
    final weeklyAsync = ref.watch(weeklyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الإحصائيات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          overviewAsync.when(
            data: (o) => GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                AppStatCard(
                  title: 'إجمالي المواعيد اليوم',
                  value: '${o.todayTotal}',
                  icon: Icons.event,
                  color: AppColors.info,
                ),
                AppStatCard(
                  title: 'مؤكدة',
                  value: '${o.todayConfirmed}',
                  icon: Icons.check_circle,
                  color: AppColors.success,
                ),
                AppStatCard(
                  title: 'قيد الانتظار',
                  value: '${o.todayPending}',
                  icon: Icons.access_time,
                  color: AppColors.warning,
                ),
                AppStatCard(
                  title: 'ملغاة',
                  value: '${o.todayCancelled}',
                  icon: Icons.cancel,
                  color: AppColors.danger,
                ),
                AppStatCard(
                  title: 'إجمالي المرضى',
                  value: '${o.totalPatients}',
                  icon: Icons.people,
                  color: AppColors.primary,
                ),
                AppStatCard(
                  title: 'إيرادات اليوم',
                  value: formatCurrency(o.todayRevenue, 'دج'),
                  icon: Icons.trending_up,
                  color: AppColors.violet,
                ),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('نظرة عامة على الحجوزات', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('آخر 7 أيام', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: weeklyAsync.when(
                    data: (data) => _Chart(values: data.isEmpty ? [0, 0, 0, 0, 0, 0, 0] : data),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('الحجوزات حسب الحالة', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                overviewAsync.when(
                  data: (o) => _StatusBars(o: o),
                  loading: () => const SizedBox.shrink(),
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

class _Chart extends StatelessWidget {
  final List<int> values;
  const _Chart({required this.values});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[];
    for (var i = 0; i < values.length; i++) {
      spots.add(FlSpot(i.toDouble(), values[i].toDouble()));
    }
    return LineChart(
      LineChartData(
        minY: 0,
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                const days = ['أحد', 'إثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت'];
                final i = v.toInt();
                if (i < 0 || i >= days.length) return const SizedBox.shrink();
                return Padding(padding: const EdgeInsets.only(top: 6), child: Text(days[i], style: const TextStyle(fontSize: 11)));
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.25), AppColors.primary.withOpacity(0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBars extends StatelessWidget {
  final dynamic o;
  const _StatusBars({required this.o});

  @override
  Widget build(BuildContext context) {
    final total = (o.todayConfirmed + o.todayPending + o.todayCancelled + o.todayCompleted).clamp(1, 1 << 30);
    final items = [
      ('مؤكد', o.todayConfirmed, AppColors.success),
      ('قيد الانتظار', o.todayPending, AppColors.warning),
      ('مكتمل', o.todayCompleted, AppColors.info),
      ('ملغي', o.todayCancelled, AppColors.danger),
    ];
    return Column(
      children: items.map<Widget>((it) {
        final pct = (it.$2 as int) / total;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(width: 90, child: Text(it.$1, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct.toDouble(),
                    minHeight: 10,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation(it.$3),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 30,
                child: Text('${it.$2}', textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
