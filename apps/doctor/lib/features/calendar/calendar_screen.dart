import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
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
      appBar: AppBar(
        title: const Text('التقويم'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // View mode tabs
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SegmentedButton<_ViewMode>(
                segments: const [
                  ButtonSegment(value: _ViewMode.day, label: Text('يومي'), icon: Icon(Icons.view_day)),
                  ButtonSegment(value: _ViewMode.week, label: Text('أسبوعي'), icon: Icon(Icons.view_week)),
                  ButtonSegment(value: _ViewMode.month, label: Text('شهري'), icon: Icon(Icons.calendar_month)),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
            ),
            const SizedBox(height: 8),
            TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focused,
              selectedDayPredicate: (d) => isSameDay(_selected, d),
              onDaySelected: (sel, foc) => setState(() {
                _selected = sel;
                _focused = foc;
              }),
              calendarFormat: _mode == _ViewMode.month
                  ? CalendarFormat.month
                  : (_mode == _ViewMode.week ? CalendarFormat.week : CalendarFormat.week),
              locale: 'ar',
              startingDayOfWeek: StartingDayOfWeek.sunday,
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary),
                ),
                todayTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700),
                selectedDecoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                weekendTextStyle: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: apptsAsync.when(
                data: (list) => _AppointmentList(items: list, mode: _mode),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('تعذر التحميل')),
              ),
            ),
          ],
        ),
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
      return const Center(child: Text('لا توجد مواعيد', style: TextStyle(color: AppColors.textSecondary)));
    }
    final sorted = [...items]..sort((a, b) => a.startAt.compareTo(b.startAt));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final a = sorted[i];
        return AppCard(
          onTap: () => context.push('/appointment/${a.id}'),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 56,
                decoration: BoxDecoration(
                  color: appointmentColor(a.status),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.patient?.fullName ?? 'بدون مريض',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      a.reason ?? 'استشارة',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          '${formatTimeArabic(a.startAt)} - ${formatTimeArabic(a.endAt)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        if (mode != _ViewMode.day) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.calendar_today, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(formatDateArabic(a.startAt),
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              StatusBadge(status: a.status, small: true),
            ],
          ),
        );
      },
    );
  }
}
