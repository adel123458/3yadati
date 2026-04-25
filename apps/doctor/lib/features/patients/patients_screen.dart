import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
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
      appBar: AppBar(title: const Text('المرضى')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _q = v),
                decoration: const InputDecoration(
                  hintText: 'ابحث عن مريض بالاسم أو الرقم',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: patients.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Center(child: Text('لا يوجد مرضى', style: TextStyle(color: AppColors.textSecondary)));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final p = list[i];
                      return AppCard(
                        onTap: () => context.push('/patient/${p.id}'),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: p.gender == 'FEMALE'
                                  ? const Color(0xFFFCE7F3)
                                  : AppColors.primaryLight,
                              child: Icon(
                                p.gender == 'FEMALE' ? Icons.face_3 : Icons.face,
                                color: p.gender == 'FEMALE' ? const Color(0xFFEC4899) : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(p.phone ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_left, color: AppColors.textMuted),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('تعذر التحميل')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.person_add),
        label: const Text('مريض جديد'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
