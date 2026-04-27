import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/avatars.dart';
import '../../data/algeria_data.dart';
import '../../data/mock_data.dart';
import '../../data/repositories.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 900;
    final overview = ref.watch(overviewProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('لوحة المشرف'),
        actions: [
          IconButton(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'خروج من وضع المشرف',
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(wide ? 24 : 14, 14, wide ? 24 : 14, 32),
        children: [
          _HeroBanner()
              .animate()
              .fadeIn(duration: 380.ms)
              .slideY(begin: -0.08, curve: Curves.easeOutCubic),
          const SizedBox(height: 18),
          overview.when(
            data: (o) => GridView.count(
              crossAxisCount: wide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: wide ? 1.45 : 1.3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                const _AdminKpi(
                  label: 'أطباء',
                  value: '3',
                  icon: Icons.medical_services_rounded,
                  gradient: AppColors.primaryGradient,
                ),
                _AdminKpi(
                  label: 'مواعيد اليوم',
                  value: o.todayTotal.toString(),
                  icon: Icons.event_available_rounded,
                  gradient: const [Color(0xFF7B6BFF), Color(0xFF5A47E0)],
                ),
                _AdminKpi(
                  label: 'مرضى',
                  value: o.totalPatients.toString(),
                  icon: Icons.people_alt_rounded,
                  gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                ),
                _AdminKpi(
                  label: 'إيرادات اليوم',
                  value: '${o.todayRevenue.toStringAsFixed(0)} دج',
                  icon: Icons.payments_rounded,
                  gradient: const [Color(0xFF10B981), Color(0xFF059669)],
                ),
              ],
            ),
            loading: () => const SizedBox(
                height: 180, child: Center(child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(
                child: Text('قائمة الأطباء',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.filter_list_rounded, size: 16),
                label: const Text('تصفية'),
                style: TextButton.styleFrom(foregroundColor: AppColors.violet),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._doctors.asMap().entries.map((e) {
            final i = e.key;
            final d = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _DoctorRow(data: d),
            )
                .animate()
                .fadeIn(duration: 320.ms, delay: (60 * i).ms)
                .slideX(begin: 0.05);
          }),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text('أحدث الحجوزات',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
              ),
              Text('${MockData.todayAppointments.length} موعد',
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (int i = 0; i < MockData.todayAppointments.length; i++) ...[
                  _AdminApptRow(a: MockData.todayAppointments[i]),
                  if (i < MockData.todayAppointments.length - 1)
                    const Divider(height: 1, indent: 14, endIndent: 14),
                ],
              ],
            ),
          ).animate().fadeIn(duration: 380.ms, delay: 120.ms),
        ],
      ),
    );
  }

  static final _doctors = [
    _DoctorSummary(
      name: 'د. أحمد السعيد',
      specialty: AlgeriaData.specialties[0].nameAr,
      wilaya: AlgeriaData.wilayas[15].nameAr,
      appts: 7,
    ),
    _DoctorSummary(
      name: 'د. منال بن صالح',
      specialty: AlgeriaData.specialties[2].nameAr,
      wilaya: AlgeriaData.wilayas[30].nameAr,
      appts: 5,
    ),
    _DoctorSummary(
      name: 'د. يوسف بلعيدي',
      specialty: AlgeriaData.specialties[5].nameAr,
      wilaya: AlgeriaData.wilayas[24].nameAr,
      appts: 9,
    ),
  ];
}

class _DoctorSummary {
  final String name;
  final String specialty;
  final String wilaya;
  final int appts;
  const _DoctorSummary({
    required this.name,
    required this.specialty,
    required this.wilaya,
    required this.appts,
  });
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.sidebarGradient,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withOpacity(0.30),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.admin_panel_settings_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('مرحبًا، مشرف النظام',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('راقب أداء جميع الأطباء والعيادات والفروع من مكان واحد',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminKpi extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final List<Color> gradient;
  const _AdminKpi({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
            ],
          ),
          Text(value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _DoctorRow extends StatelessWidget {
  final _DoctorSummary data;
  const _DoctorRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          GradientAvatar(name: data.name, size: 46),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${data.specialty} • ${data.wilaya}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.violetLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('${data.appts} موعد',
                style: const TextStyle(
                    color: AppColors.violet,
                    fontWeight: FontWeight.w800,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _AdminApptRow extends StatelessWidget {
  final dynamic a;
  const _AdminApptRow({required this.a});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          GradientAvatar(name: a.patient?.fullName ?? 'موعد', size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.patient?.fullName ?? '',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 13)),
                const SizedBox(height: 2),
                Text(a.reason ?? '',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11.5)),
              ],
            ),
          ),
          Text(a.code ?? '',
              style: const TextStyle(
                  color: AppColors.violet,
                  fontWeight: FontWeight.w800,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
