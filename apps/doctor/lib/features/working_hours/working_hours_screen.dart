import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/skeletons.dart';
import '../../data/repositories.dart';

class WorkingHoursScreen extends ConsumerWidget {
  const WorkingHoursScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hoursAsync = ref.watch(workingHoursProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('ساعات العمل')),
      body: hoursAsync.when(
        data: (list) {
          const order = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
          final sorted = [...list]..sort((a, b) => order.indexOf(a.weekday).compareTo(order.indexOf(b.weekday)));
          return AnimationLimiter(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: sorted.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final w = sorted[i];
                return AnimationConfiguration.staggeredList(
                  position: i,
                  duration: const Duration(milliseconds: 360),
                  child: SlideAnimation(
                    verticalOffset: 16,
                    child: FadeInAnimation(
                      child: AppCard(
                        padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                        child: Row(
                          children: [
                            GradientIcon(
                              icon: w.isClosed ? Icons.do_not_disturb_alt_rounded : Icons.access_time_filled_rounded,
                              gradient: w.isClosed ? AppColors.dangerGradient : AppColors.primaryGradient,
                              size: 44,
                              iconSize: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(weekdayArabic[w.weekday] ?? w.weekday,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (w.isClosed)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.danger.withOpacity(0.10),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text('مغلق',
                                              style: TextStyle(
                                                  color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.w800)),
                                        )
                                      else ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text('${w.startTime} - ${w.endTime}',
                                              style: const TextStyle(
                                                  color: AppColors.primary, fontSize: 11.5, fontWeight: FontWeight.w800)),
                                        ),
                                        if (w.breakStart != null) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.warning.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text('استراحة ${w.breakStart}',
                                                style: const TextStyle(
                                                    color: AppColors.warning, fontSize: 10.5, fontWeight: FontWeight.w800)),
                                          ),
                                        ],
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: !w.isClosed,
                              activeColor: AppColors.primary,
                              onChanged: (_) {},
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
        loading: () => const ListSkeleton(rows: 7),
        error: (_, __) => const EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'تعذر تحميل ساعات العمل',
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_rounded),
        label: const Text('إضافة', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
