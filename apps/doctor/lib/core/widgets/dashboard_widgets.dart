import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import 'app_card.dart';

/// Top search header with greeting label and profile pill, similar to modern
/// dashboard mockups. Adapts to compact (mobile) and expanded (web) layouts.
class DashSearchHeader extends StatelessWidget {
  final String name;
  final String specialty;
  final int unread;
  final VoidCallback? onBell;
  final VoidCallback? onProfile;
  final ValueChanged<String>? onSearch;

  const DashSearchHeader({
    super.key,
    required this.name,
    required this.specialty,
    required this.unread,
    this.onBell,
    this.onProfile,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.softShadow,
                  blurRadius: 18,
                  offset: Offset(0, 6),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: onSearch,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                      hintText: 'بحث عن مريض، موعد، فرع...',
                      filled: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _CircleIconButton(
          icon: Icons.notifications_rounded,
          onTap: onBell,
          badgeCount: unread,
        ),
        const SizedBox(width: 10),
        _ProfilePill(name: name, specialty: specialty, onTap: onProfile),
      ],
    ).animate().fadeIn(duration: 320.ms).slideY(begin: -0.06, curve: Curves.easeOut);
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final int badgeCount;
  const _CircleIconButton({required this.icon, this.onTap, this.badgeCount = 0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: AppColors.surface,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Ink(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.softShadow,
                    blurRadius: 18,
                    offset: Offset(0, 6),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: SizedBox(
                width: 50,
                height: 50,
                child: Icon(icon, color: AppColors.violet, size: 22),
              ),
            ),
          ),
        ),
        if (badgeCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text('$badgeCount',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
            ),
          ),
      ],
    );
  }
}

class _ProfilePill extends StatelessWidget {
  final String name;
  final String specialty;
  final VoidCallback? onTap;
  const _ProfilePill({required this.name, required this.specialty, this.onTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 520;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: AppColors.softShadow,
                blurRadius: 18,
                offset: Offset(0, 6),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(compact ? 6 : 8, 6, compact ? 12 : 14, 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: AppColors.sidebarGradient,
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                ),
                if (!compact) ...[
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.text,
                        ),
                      ),
                      if (specialty.isNotEmpty)
                        Text(
                          specialty,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// KPI tile in the modern dashboard style: small icon top-right, big number,
/// label, % change chip below. Uses violet/indigo accents on a white card.
class KpiTile extends StatelessWidget {
  final String label;
  final String value;
  final String? trend;
  final IconData icon;
  final List<Color> gradient;

  const KpiTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.gradient = AppColors.sidebarGradient,
    this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final trendUp = trend != null && !trend!.startsWith('-');
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.last.withOpacity(0.32),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              height: 1.1,
            ),
          ),
          if (trend != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  size: 14,
                  color: trendUp ? AppColors.success : AppColors.danger,
                ),
                const SizedBox(width: 4),
                Text(
                  trend!,
                  style: TextStyle(
                    color: trendUp ? AppColors.success : AppColors.danger,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'مقارنة بالأسبوع',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 10.5),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Big bar chart card showing weekly appointments / revenue with gradient bars
/// and a Months/Years tab.
class BarChartCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<double> values;
  final List<String> labels;
  final String unitSuffix;
  final String highlightedLabel;
  final double highlightedValue;

  const BarChartCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.values,
    required this.labels,
    this.unitSuffix = '',
    this.highlightedLabel = '',
    this.highlightedValue = 0,
  });

  @override
  State<BarChartCard> createState() => _BarChartCardState();
}

class _BarChartCardState extends State<BarChartCard> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final maxVal = widget.values.fold<double>(0, (p, e) => e > p ? e : p);
    final maxY = (maxVal * 1.25).clamp(1, double.infinity).toDouble();
    final highlightedIdx = widget.values.indexOf(widget.highlightedValue);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _PillTabs(
                tabs: const ['أشهر', 'سنوات'],
                selected: tab,
                onChanged: (i) => setState(() => tab = i),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (widget.highlightedLabel.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.sidebarGradient,
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.violet.withOpacity(0.30),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.highlightedLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.highlightedValue.toStringAsFixed(0)}${widget.unitSuffix}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.divider,
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: maxY / 4,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= widget.labels.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            widget.labels[i],
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(widget.values.length, (i) {
                  final isHighlight = i == highlightedIdx;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: widget.values[i],
                        width: 14,
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: isHighlight
                              ? AppColors.sidebarGradient
                              : [
                                  AppColors.violet.withOpacity(0.35),
                                  AppColors.indigo.withOpacity(0.55),
                                ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ],
                  );
                }),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppColors.text,
                    getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                      '${rod.toY.toStringAsFixed(0)}${widget.unitSuffix}',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.04);
  }
}

class _PillTabs extends StatelessWidget {
  final List<String> tabs;
  final int selected;
  final ValueChanged<int> onChanged;
  const _PillTabs({required this.tabs, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(tabs.length, (i) {
          final s = i == selected;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: s ? AppColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: s
                    ? const [
                        BoxShadow(
                          color: AppColors.softShadow,
                          blurRadius: 10,
                          offset: Offset(0, 3),
                          spreadRadius: -2,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                tabs[i],
                style: TextStyle(
                  color: s ? AppColors.violet : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Donut chart card with center label, similar to "Reviews 75%" card.
class DonutPerformanceCard extends StatelessWidget {
  final double percent; // 0..1
  final String label;
  final String centerTitle;
  final String subtitle;
  final List<Color> gradient;

  const DonutPerformanceCard({
    super.key,
    required this.percent,
    required this.label,
    required this.centerTitle,
    required this.subtitle,
    this.gradient = AppColors.sidebarGradient,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
              const Icon(Icons.more_horiz_rounded, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 14),
          Center(
            child: SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 50,
                      startDegreeOffset: -90,
                      sections: [
                        PieChartSectionData(
                          value: percent.clamp(0, 1) * 100,
                          color: gradient.last,
                          radius: 18,
                          showTitle: false,
                          gradient: LinearGradient(
                            colors: gradient,
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                        ),
                        PieChartSectionData(
                          value: (1 - percent.clamp(0, 1)) * 100,
                          color: AppColors.divider,
                          radius: 18,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(percent * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        centerTitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              subtitle,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).scale(begin: const Offset(0.96, 0.96));
  }
}

/// Small horizontal date strip (Mon, Tue, ...) with selected pill.
class WeekDateStrip extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime>? onSelect;
  const WeekDateStrip({super.key, required this.selected, this.onSelect});

  @override
  Widget build(BuildContext context) {
    final start = selected.subtract(Duration(days: selected.weekday - 1));
    const ar = ['اث', 'ث', 'أر', 'خ', 'ج', 'س', 'أح'];
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          final d = start.add(Duration(days: i));
          final isSelected = d.day == selected.day && d.month == selected.month;
          return GestureDetector(
            onTap: () => onSelect?.call(d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: AppColors.sidebarGradient,
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      )
                    : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.violet.withOpacity(0.30),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  Text(
                    ar[i],
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.text,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
