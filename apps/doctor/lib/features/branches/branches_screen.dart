import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/skeletons.dart';
import '../../data/repositories.dart';

class BranchesScreen extends ConsumerWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branches = ref.watch(branchesProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('الفروع')),
      body: branches.when(
        data: (list) => AnimationLimiter(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final b = list[i];
              final gradient = b.isPrimary ? AppColors.primaryGradient : AppColors.violetGradient;
              return AnimationConfiguration.staggeredList(
                position: i,
                duration: const Duration(milliseconds: 380),
                child: SlideAnimation(
                  verticalOffset: 18,
                  child: FadeInAnimation(
                    child: AppCard(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              GradientIcon(
                                icon: Icons.location_on_rounded,
                                gradient: gradient,
                                size: 46,
                                iconSize: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  b.name,
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                ),
                              ),
                              if (b.isPrimary)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: AppColors.primaryGradient),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text('رئيسي',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.place_rounded, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(b.address,
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                              ),
                            ],
                          ),
                          if (b.phone != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.phone_rounded, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(b.phone!,
                                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 40),
                                    foregroundColor: AppColors.primary,
                                    side: const BorderSide(color: AppColors.primary),
                                  ),
                                  onPressed: () {},
                                  icon: const Icon(Icons.map_rounded, size: 16),
                                  label: const Text('الخريطة'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(0, 40),
                                  ),
                                  onPressed: () {},
                                  icon: const Icon(Icons.edit_rounded, size: 16),
                                  label: const Text('تعديل'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        loading: () => const ListSkeleton(rows: 4, tileHeight: 130),
        error: (_, __) => const EmptyState(
          icon: Icons.error_outline_rounded,
          title: 'تعذر تحميل الفروع',
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_rounded),
        label: const Text('فرع جديد', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
