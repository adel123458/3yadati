import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/avatars.dart';
import '../../core/widgets/skeletons.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/models.dart';
import '../../data/repositories.dart';

class AppointmentDetailsScreen extends ConsumerWidget {
  final String appointmentId;
  const AppointmentDetailsScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appt = ref.watch(appointmentByIdProvider(appointmentId));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('تفاصيل الحجز')),
      body: appt.when(
        data: (a) => a == null
            ? const EmptyState(icon: Icons.search_off_rounded, title: 'الموعد غير موجود')
            : _Body(a: a),
        loading: () => const _LoadingBody(),
        error: (_, __) => const EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'تعذر تحميل التفاصيل',
        ),
      ),
    );
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Shimmered(
          child: SkeletonBox(height: 120, borderRadius: BorderRadius.all(Radius.circular(20))),
        ),
        SizedBox(height: 16),
        Shimmered(
          child: SkeletonBox(height: 200, borderRadius: BorderRadius.all(Radius.circular(20))),
        ),
        SizedBox(height: 16),
        Shimmered(
          child: SkeletonBox(height: 56, borderRadius: BorderRadius.all(Radius.circular(16))),
        ),
      ],
    );
  }
}

class _Body extends ConsumerWidget {
  final Appointment a;
  const _Body({required this.a});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = appointmentColor(a.status);
    final gradient = _statusGradient(a.status);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GradientCard(
          gradient: gradient,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GradientAvatar(name: a.patient?.fullName ?? 'موعد', size: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.patient?.fullName ?? 'بدون مريض',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          a.patient?.phone ?? '',
                          style: TextStyle(color: Colors.white.withOpacity(0.85)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _statusLabel(a.status),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${formatTimeArabic(a.startAt)} - ${formatTimeArabic(a.endAt)}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      formatDateArabic(a.startAt),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 280.ms).slideY(begin: -0.05),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            children: [
              _DetailRow(icon: Icons.medical_information_rounded, label: 'سبب الزيارة', value: a.reason ?? '—', color: color),
              if (a.branch != null) _DetailRow(
                icon: Icons.location_on_rounded,
                label: 'الفرع',
                value: a.branch!.name,
                color: AppColors.violet,
              ),
              _DetailRow(
                icon: Icons.timer_outlined,
                label: 'المدة',
                value: '${a.endAt.difference(a.startAt).inMinutes} دقيقة',
                color: AppColors.info,
              ),
              if (a.internalNotes != null && a.internalNotes!.isNotEmpty)
                _DetailRow(
                  icon: Icons.note_alt_outlined,
                  label: 'ملاحظات',
                  value: a.internalNotes!,
                  color: AppColors.warning,
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.timeline_rounded, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text('سير الحجز', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 14),
              _StatusTimeline(current: a.status),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _changeStatus(context, ref, AppointmentStatus.confirmed),
                icon: const Icon(Icons.check_circle_rounded),
                label: const Text('تأكيد الوصول'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.event_repeat_rounded),
                label: const Text('إعادة جدولة'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.danger),
          ),
          onPressed: () => _changeStatus(context, ref, AppointmentStatus.cancelled),
          icon: const Icon(Icons.cancel_rounded),
          label: const Text('إلغاء الحجز'),
        ),
      ],
    );
  }

  Future<void> _changeStatus(BuildContext context, WidgetRef ref, AppointmentStatus s) async {
    await ref.read(appointmentsRepoProvider).changeStatus(a.id, s);
    if (context.mounted) {
      ref.invalidate(appointmentByIdProvider(a.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحديث الحالة: ${_statusLabel(s)}')),
      );
    }
  }

  static List<Color> _statusGradient(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.confirmed:
        return AppColors.successGradient;
      case AppointmentStatus.pending:
        return AppColors.warningGradient;
      case AppointmentStatus.completed:
        return AppColors.infoGradient;
      case AppointmentStatus.cancelled:
        return AppColors.dangerGradient;
      case AppointmentStatus.noShow:
      case AppointmentStatus.closed:
        return [AppColors.textSecondary, AppColors.textMuted];
      case AppointmentStatus.available:
        return AppColors.primaryGradient;
    }
  }

  static String _statusLabel(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.confirmed:
        return 'مؤكد';
      case AppointmentStatus.pending:
        return 'قيد الانتظار';
      case AppointmentStatus.completed:
        return 'مكتمل';
      case AppointmentStatus.cancelled:
        return 'ملغي';
      case AppointmentStatus.noShow:
        return 'لم يحضر';
      case AppointmentStatus.closed:
        return 'مغلق';
      case AppointmentStatus.available:
        return 'متاح';
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DetailRow({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final AppointmentStatus current;
  const _StatusTimeline({required this.current});

  static const _steps = [
    (AppointmentStatus.available, 'متاح', Icons.event_available_rounded),
    (AppointmentStatus.pending, 'قيد الانتظار', Icons.hourglass_top_rounded),
    (AppointmentStatus.confirmed, 'مؤكد', Icons.check_circle_rounded),
    (AppointmentStatus.completed, 'مكتمل', Icons.task_alt_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _steps.indexWhere((e) => e.$1 == current);
    final isCancelled = current == AppointmentStatus.cancelled;
    return Row(
      children: List.generate(_steps.length, (i) {
        final isPast = !isCancelled && currentIndex >= 0 && i <= currentIndex;
        final color = isCancelled
            ? AppColors.danger
            : (isPast ? AppColors.primary : AppColors.border);
        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isPast ? color : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: color, width: 2),
                      boxShadow: isPast
                          ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))]
                          : null,
                    ),
                    child: Icon(_steps[i].$3, color: isPast ? Colors.white : color, size: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(_steps[i].$2,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isPast ? AppColors.text : AppColors.textSecondary,
                      )),
                ],
              ),
              if (i < _steps.length - 1)
                Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 22),
                    decoration: BoxDecoration(
                      color: isPast ? color : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
