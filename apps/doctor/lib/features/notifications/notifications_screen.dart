import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../data/repositories.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('الإشعارات')),
      body: notifs.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('لا توجد إشعارات', style: TextStyle(color: AppColors.textSecondary)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final n = list[i];
              final color = _colorFor(n.type);
              final icon = _iconFor(n.type);
              return AppCard(
                color: n.read ? AppColors.surface : AppColors.primaryLight.withOpacity(0.4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                      child: Icon(icon, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(n.body, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          const SizedBox(height: 6),
                          Text(
                            DateFormat('d MMM • HH:mm', 'ar').format(n.createdAt),
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    if (!n.read)
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                      ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('تعذر التحميل')),
      ),
    );
  }

  Color _colorFor(String type) {
    switch (type) {
      case 'APPOINTMENT_CONFIRMED':
        return AppColors.success;
      case 'APPOINTMENT_CANCELLED':
        return AppColors.danger;
      case 'APPOINTMENT_RESCHEDULED':
        return AppColors.warning;
      case 'REMINDER':
        return AppColors.info;
      default:
        return AppColors.primary;
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'APPOINTMENT_CONFIRMED':
        return Icons.check_circle_outline;
      case 'APPOINTMENT_CANCELLED':
        return Icons.cancel_outlined;
      case 'APPOINTMENT_RESCHEDULED':
        return Icons.event_repeat;
      case 'REMINDER':
        return Icons.alarm;
      default:
        return Icons.notifications;
    }
  }
}
