import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/avatars.dart';
import '../../data/mock_data.dart';

class PatientDetailsScreen extends ConsumerWidget {
  final String patientId;
  const PatientDetailsScreen({super.key, required this.patientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patient = MockData.patients.firstWhere(
      (p) => p.id == patientId,
      orElse: () => MockData.patients.first,
    );
    final isFemale = patient.gender == 'FEMALE';
    final gradient = isFemale ? AppColors.pinkGradient : AppColors.primaryGradient;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('ملف المريض')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GradientCard(
            gradient: gradient,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: Row(
              children: [
                GradientAvatar(name: patient.fullName, size: 64),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        patient.phone ?? '',
                        style: TextStyle(color: Colors.white.withOpacity(0.85)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _ChipWhite(label: isFemale ? 'أنثى' : 'ذكر'),
                          const SizedBox(width: 8),
                          if (patient.lastVisit != null)
                            _ChipWhite(label: 'آخر زيارة منذ ${DateTime.now().difference(patient.lastVisit!).inDays} يوم'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  value: '12',
                  label: 'إجمالي الزيارات',
                  icon: Icons.event_repeat_rounded,
                  gradient: AppColors.primaryGradient,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  value: '3',
                  label: 'مواعيد قادمة',
                  icon: Icons.upcoming_rounded,
                  gradient: AppColors.violetGradient,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const SectionTitle(title: 'سجل الزيارات', icon: Icons.history_rounded),
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Column(
              children: List.generate(3, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.event_note_rounded, color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('زيارة سابقة #${i + 1}',
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('قبل ${(i + 1) * 7} أيام',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipWhite extends StatelessWidget {
  final String label;
  const _ChipWhite({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final List<Color> gradient;
  const _MiniStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Row(
        children: [
          GradientIcon(icon: icon, gradient: gradient),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
