import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../data/repositories.dart';

class WorkingHoursScreen extends ConsumerWidget {
  const WorkingHoursScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hoursAsync = ref.watch(workingHoursProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('ساعات العمل')),
      body: hoursAsync.when(
        data: (list) {
          // Sort by weekday order
          const order = ['SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY'];
          final sorted = [...list]..sort((a, b) => order.indexOf(a.weekday).compareTo(order.indexOf(b.weekday)));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final w = sorted[i];
              return AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: w.isClosed ? AppColors.danger.withOpacity(0.1) : AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        w.isClosed ? Icons.do_not_disturb_alt : Icons.access_time,
                        color: w.isClosed ? AppColors.danger : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(weekdayArabic[w.weekday] ?? w.weekday,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(
                            w.isClosed
                                ? 'مغلق'
                                : '${w.startTime} - ${w.endTime}${w.breakStart != null ? '   • استراحة ${w.breakStart}-${w.breakEnd}' : ''}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Switch(value: !w.isClosed, onChanged: (_) {}),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('تعذر التحميل')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('إضافة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
