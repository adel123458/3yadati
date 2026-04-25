import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/skeletons.dart';
import '../../data/repositories.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(notificationsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('الإشعارات')),
      body: notifs.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_off_rounded,
              title: 'لا توجد إشعارات',
              subtitle: 'كل شيء هادئ هنا!',
            );
          }
          return AnimationLimiter(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final n = list[i];
                final gradient = _gradientFor(n.type);
                final icon = _iconFor(n.type);
                return AnimationConfiguration.staggeredList(
                  position: i,
                  duration: const Duration(milliseconds: 350),
                  child: SlideAnimation(
                    verticalOffset: 16,
                    child: FadeInAnimation(
                      child: AppCard(
                        color: n.read ? AppColors.surface : AppColors.primaryLight.withOpacity(0.45),
                        padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GradientIcon(icon: icon, gradient: gradient, size: 42, iconSize: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(n.title,
                                            style: const TextStyle(fontWeight: FontWeight.w800)),
                                      ),
                                      if (!n.read)
                                        Container(
                                          width: 9,
                                          height: 9,
                                          decoration: const BoxDecoration(
                                              color: AppColors.danger, shape: BoxShape.circle),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(n.body,
                                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                  const SizedBox(height: 6),
                                  Text(
                                    DateFormat('d MMM • HH:mm', 'ar').format(n.createdAt),
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const ListSkeleton(rows: 5),
        error: (_, __) => const EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'تعذر تحميل الإشعارات',
        ),
      ),
    );
  }

  List<Color> _gradientFor(String type) {
    switch (type) {
      case 'APPOINTMENT_CONFIRMED':
        return AppColors.successGradient;
      case 'APPOINTMENT_CANCELLED':
        return AppColors.dangerGradient;
      case 'APPOINTMENT_RESCHEDULED':
        return AppColors.warningGradient;
      case 'REMINDER':
        return AppColors.infoGradient;
      default:
        return AppColors.primaryGradient;
    }
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'APPOINTMENT_CONFIRMED':
        return Icons.check_circle_rounded;
      case 'APPOINTMENT_CANCELLED':
        return Icons.cancel_rounded;
      case 'APPOINTMENT_RESCHEDULED':
        return Icons.event_repeat_rounded;
      case 'REMINDER':
        return Icons.alarm_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}
