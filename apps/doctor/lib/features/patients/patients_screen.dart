import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/avatars.dart';
import '../../core/widgets/skeletons.dart';
import '../../data/repositories.dart';

class PatientsScreen extends ConsumerStatefulWidget {
  const PatientsScreen({super.key});
  @override
  ConsumerState<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends ConsumerState<PatientsScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(patientsProvider(_q));
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('المرضى')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _q = v),
                decoration: InputDecoration(
                  hintText: 'ابحث عن مريض بالاسم أو الرقم',
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.search_rounded, color: AppColors.primary),
                  ),
                ),
              ),
            ),
            Expanded(
              child: patients.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const EmptyState(
                      icon: Icons.person_search_rounded,
                      title: 'لا يوجد مرضى',
                      subtitle: 'حاول البحث بكلمة أخرى أو أضف مريضًا جديدًا.',
                    );
                  }
                  return AnimationLimiter(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final p = list[i];
                        return AnimationConfiguration.staggeredList(
                          position: i,
                          duration: const Duration(milliseconds: 350),
                          child: SlideAnimation(
                            verticalOffset: 16,
                            child: FadeInAnimation(
                              child: AppCard(
                                onTap: () => context.push('/patient/${p.id}'),
                                padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                                child: Row(
                                  children: [
                                    GradientAvatar(name: p.fullName, size: 46),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(p.fullName,
                                              style: const TextStyle(fontWeight: FontWeight.w800)),
                                          const SizedBox(height: 4),
                                          Text(p.phone ?? '',
                                              style: const TextStyle(
                                                  fontSize: 12, color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (p.gender == 'FEMALE'
                                                ? AppColors.pink
                                                : AppColors.info)
                                            .withOpacity(0.10),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        p.gender == 'FEMALE' ? 'أنثى' : 'ذكر',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: p.gender == 'FEMALE'
                                              ? AppColors.pink
                                              : AppColors.info,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.chevron_left_rounded,
                                        color: AppColors.textMuted),
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
                loading: () => const ListSkeleton(rows: 6),
                error: (_, __) => const EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'تعذر تحميل القائمة',
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('مريض جديد', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
