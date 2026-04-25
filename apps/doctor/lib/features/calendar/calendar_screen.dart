import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/avatars.dart';
import '../../core/widgets/skeletons.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/models.dart';
import '../../data/repositories.dart';

enum _ViewMode { day, week, month }

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();
  _ViewMode _mode = _ViewMode.day;

  AppDateRange get _range {
    switch (_mode) {
      case _ViewMode.day:
        final s = DateTime(_selected.year, _selected.month, _selected.day);
        return AppDateRange(s, s.add(const Duration(days: 1)));
      case _ViewMode.week:
        final start = _selected.subtract(Duration(days: _selected.weekday % 7));
        final s = DateTime(start.year, start.month, start.day);
        return AppDateRange(s, s.add(const Duration(days: 7)));
      case _ViewMode.month:
        final s = DateTime(_focused.year, _focused.month, 1);
        final e = DateTime(_focused.year, _focused.month + 1, 1);
        return AppDateRange(s, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final apptsAsync = ref.watch(appointmentsProvider(_range));
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('موعد جديد', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _CalendarHeader(
              selected: _selected,
              onPrev: () {
                setState(() {
                  _selected = _selected.subtract(const Duration(days: 1));
                  _focused = _selected;
                });
              },
              onNext: () {
                setState(() {
                  _selected = _selected.add(const Duration(days: 1));
                  _focused = _selected;
                });
              },
              onToday: () {
                setState(() {
                  _selected = DateTime.now();
                  _focused = DateTime.now();
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
              child: _ModeSwitcher(
                mode: _mode,
                onChanged: (m) => setState(() => _mode = m),
              ),
            ),
            _WeekStrip(
              selected: _selected,
              onSelect: (d) => setState(() {
                _selected = d;
                _focused = d;
              }),
            ),
            if (_mode == _ViewMode.month)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: AppCard(
                  padding: const EdgeInsets.all(8),
                  child: TableCalendar(
                    firstDay: DateTime.now().subtract(const Duration(days: 365)),
                    lastDay: DateTime.now().add(const Duration(days: 365)),
                    focusedDay: _focused,
                    selectedDayPredicate: (d) => isSameDay(_selected, d),
                    onDaySelected: (sel, foc) => setState(() {
                      _selected = sel;
                      _focused = foc;
                    }),
                    calendarFormat: CalendarFormat.month,
                    locale: 'ar',
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                      titleTextStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary),
                      ),
                      todayTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                      selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      weekendTextStyle: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: apptsAsync.when(
                data: (list) => _AppointmentList(items: list, mode: _mode),
                loading: () => const ListSkeleton(rows: 6, tileHeight: 84),
                error: (_, __) => const EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'تعذر تحميل المواعيد',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  final DateTime selected;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;
  const _CalendarHeader({
    required this.selected,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_right_rounded)),
          Expanded(
            child: GestureDetector(
              onTap: onToday,
              child: Column(
                children: [
                  const Text(
                    'التقويم',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatArabicDate(selected),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.text),
                  ),
                ],
              ),
            ),
          ),
          IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_left_rounded)),
        ],
      ),
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  final _ViewMode mode;
  final ValueChanged<_ViewMode> onChanged;
  const _ModeSwitcher({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color(0x0F0F172A), blurRadius: 14, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: _ViewMode.values.map((m) {
          final selected = m == mode;
          final label = switch (m) {
            _ViewMode.day => 'يومي',
            _ViewMode.week => 'أسبوعي',
            _ViewMode.month => 'شهري',
          };
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                          colors: AppColors.primaryGradient,
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;
  const _WeekStrip({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final start = selected.subtract(Duration(days: selected.weekday % 7));
    final today = DateTime.now();
    return SizedBox(
      height: 86,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final d = start.add(Duration(days: i));
          final isSelected = isSameDay(d, selected);
          final isToday = isSameDay(d, today);
          final weekdayShort = DateFormat('EEE', 'ar').format(d);
          return GestureDetector(
            onTap: () => onSelect(d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.30)
                        : const Color(0x0F0F172A),
                    blurRadius: isSelected ? 14 : 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: !isSelected && isToday
                    ? Border.all(color: AppColors.primary.withOpacity(0.5))
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekdayShort,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white.withOpacity(0.85) : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppColors.text,
                    ),
                  ),
                  if (isToday && !isSelected) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AppointmentList extends StatelessWidget {
  final List<Appointment> items;
  final _ViewMode mode;
  const _AppointmentList({required this.items, required this.mode});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy_rounded,
        title: 'لا توجد مواعيد',
        subtitle: 'يومك خالٍ من الحجوزات. استمتع بوقتك!',
      );
    }
    final sorted = [...items]..sort((a, b) => a.startAt.compareTo(b.startAt));
    return AnimationLimiter(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: sorted.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final a = sorted[i];
          return AnimationConfiguration.staggeredList(
            position: i,
            duration: const Duration(milliseconds: 360),
            child: SlideAnimation(
              verticalOffset: 16,
              child: FadeInAnimation(
                child: _AppointmentTile(a: a, showDate: mode != _ViewMode.day),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final Appointment a;
  final bool showDate;
  const _AppointmentTile({required this.a, required this.showDate});

  @override
  Widget build(BuildContext context) {
    final color = appointmentColor(a.status);
    return AppCard(
      onTap: () => context.push('/appointment/${a.id}'),
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 5,
            height: 64,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          GradientAvatar(name: a.patient?.fullName ?? 'موعد', size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.patient?.fullName ?? 'بدون مريض',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                ),
                const SizedBox(height: 4),
                Text(a.reason ?? 'استشارة',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 13, color: color),
                    const SizedBox(width: 4),
                    Text(
                      '${formatTimeArabic(a.startAt)} - ${formatTimeArabic(a.endAt)}',
                      style: TextStyle(fontSize: 11.5, color: color, fontWeight: FontWeight.w700),
                    ),
                    if (showDate) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(formatDateArabic(a.startAt),
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(status: a.status, small: true),
        ],
      ),
    );
  }
}
