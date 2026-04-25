import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
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
      appBar: AppBar(title: const Text('تفاصيل الحجز')),
      body: appt.when(
        data: (a) => a == null ? const Center(child: Text('غير موجود')) : _Body(a: a),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('تعذر التحميل')),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  final Appointment a;
  const _Body({required this.a});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Patient header
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primaryLight,
                child: Icon(Icons.person, color: AppColors.primary, size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.patient?.fullName ?? 'بدون مريض',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(a.patient?.phone ?? '', style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              StatusBadge(status: a.status),
            ],
          ),
        ),
        const SizedBox(height: 16),

        AppCard(
          child: Column(
            children: [
              _Row(label: 'التاريخ', value: formatDateArabic(a.startAt)),
              const Divider(),
              _Row(label: 'الوقت', value: '${formatTimeArabic(a.startAt)} - ${formatTimeArabic(a.endAt)}'),
              const Divider(),
              _Row(label: 'سبب الزيارة', value: a.reason ?? '—'),
              if (a.branch != null) ...[
                const Divider(),
                _Row(label: 'الفرع', value: a.branch!.name),
              ],
              if (a.internalNotes != null && a.internalNotes!.isNotEmpty) ...[
                const Divider(),
                _Row(label: 'ملاحظات', value: a.internalNotes!),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _changeStatus(context, ref, AppointmentStatus.confirmed),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('تأكيد الوصول'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.event_repeat),
                label: const Text('إعادة جدولة'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.danger),
          ),
          onPressed: () => _changeStatus(context, ref, AppointmentStatus.cancelled),
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('إلغاء الحجز'),
        ),
      ],
    );
  }

  Future<void> _changeStatus(BuildContext context, WidgetRef ref, AppointmentStatus s) async {
    await ref.read(appointmentsRepoProvider).changeStatus(a.id, s);
    if (context.mounted) {
      ref.invalidate(appointmentByIdProvider(a.id));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم: ${StatusBadge(status: s).runtimeType}')));
    }
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.start),
          ),
        ],
      ),
    );
  }
}
