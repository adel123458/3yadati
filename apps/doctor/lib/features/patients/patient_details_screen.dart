import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('ملف المريض')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(
                    patient.gender == 'FEMALE' ? Icons.face_3 : Icons.face,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(patient.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(patient.phone ?? '', style: const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('سجل الزيارات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: List.generate(3, (i) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_note, color: AppColors.primary),
                  title: Text('زيارة سابقة #${i + 1}'),
                  subtitle: Text('قبل ${(i + 1) * 7} أيام', style: const TextStyle(fontSize: 12)),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
