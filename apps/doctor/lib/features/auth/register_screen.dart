import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../data/algeria_data.dart';
import '../../data/repositories.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  Wilaya? _wilaya;
  SpecialtyItem? _specialty;
  bool _isCenter = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(isCenter: _isCenter)
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: -0.08, curve: Curves.easeOutCubic),
                const SizedBox(height: 20),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _isCenter,
                        onChanged: (v) => setState(() => _isCenter = v),
                        title: const Text('أنا مركز طبي',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: const Text(
                            'فعّل الخيار إذا كنت تمثّل مركزًا متعدد الأطباء'),
                        activeColor: AppColors.primary,
                      ),
                      const Divider(height: 24),
                      _Field(
                        controller: _name,
                        icon: Icons.person_rounded,
                        label: _isCenter ? 'اسم المركز' : 'الاسم الكامل',
                        validator: (v) => (v == null || v.length < 2) ? 'مطلوب' : null,
                      ),
                      _Field(
                        controller: _email,
                        icon: Icons.alternate_email_rounded,
                        label: 'البريد الإلكتروني',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            (v == null || !v.contains('@')) ? 'بريد غير صحيح' : null,
                      ),
                      _Field(
                        controller: _phone,
                        icon: Icons.phone_rounded,
                        label: 'رقم الهاتف',
                        keyboardType: TextInputType.phone,
                      ),
                      _WilayaDropdown(
                        value: _wilaya,
                        onChanged: (w) => setState(() => _wilaya = w),
                      ),
                      if (!_isCenter)
                        _SpecialtyDropdown(
                          value: _specialty,
                          onChanged: (s) => setState(() => _specialty = s),
                        ),
                      _Field(
                        controller: _password,
                        icon: Icons.lock_rounded,
                        label: 'كلمة المرور',
                        obscure: true,
                        validator: (v) =>
                            (v == null || v.length < 8) ? 'لا تقل عن 8 أحرف' : null,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms)
                    .slideY(begin: 0.05),
                const SizedBox(height: 16),
                SizedBox(
                  height: 54,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5))
                        : const Text('إنشاء الحساب',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 180.ms),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('لديك حساب بالفعل؟ تسجيل الدخول'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_wilaya == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اختر الولاية')));
      return;
    }
    if (!_isCenter && _specialty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('اختر التخصص')));
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(authRepoProvider).register(
            email: _email.text.trim(),
            password: _password.text,
            fullName: _name.text.trim(),
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            isCenter: _isCenter,
            centerName: _isCenter ? _name.text.trim() : null,
            specialtyId: _specialty?.slug,
            wilayaCode: _wilaya?.code,
          );
      if (!mounted) return;
      context.go('/home');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _Header extends StatelessWidget {
  final bool isCenter;
  const _Header({required this.isCenter});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.30),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.45), width: 1.4),
            ),
            child: const Icon(Icons.person_add_alt_1_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isCenter ? 'تسجيل مركز طبي جديد' : 'تسجيل طبيب جديد',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('مرحبًا بك في عيادتي — النظام الطبي الذكي في الجزائر',
                    style: TextStyle(color: Colors.white70, fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String label;
  final TextInputType? keyboardType;
  final bool obscure;
  final String? Function(String?)? validator;
  const _Field({
    required this.controller,
    required this.icon,
    required this.label,
    this.keyboardType,
    this.obscure = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          filled: true,
          fillColor: AppColors.surfaceMuted,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _WilayaDropdown extends StatelessWidget {
  final Wilaya? value;
  final ValueChanged<Wilaya?> onChanged;
  const _WilayaDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<Wilaya>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'الولاية',
          prefixIcon: const Icon(Icons.location_city_rounded,
              color: AppColors.primary, size: 20),
          filled: true,
          fillColor: AppColors.surfaceMuted,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        items: AlgeriaData.wilayas
            .map((w) => DropdownMenuItem(value: w, child: Text(w.label)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _SpecialtyDropdown extends StatelessWidget {
  final SpecialtyItem? value;
  final ValueChanged<SpecialtyItem?> onChanged;
  const _SpecialtyDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<SpecialtyItem>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'التخصص الطبي',
          prefixIcon: const Icon(Icons.medical_services_rounded,
              color: AppColors.violet, size: 20),
          filled: true,
          fillColor: AppColors.surfaceMuted,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        items: AlgeriaData.specialties
            .map((s) => DropdownMenuItem(value: s, child: Text(s.nameAr)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
