import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GradientAvatar extends StatelessWidget {
  final String name;
  final double size;
  final String? imageUrl;
  const GradientAvatar({super.key, required this.name, this.size = 44, this.imageUrl});

  static const _palette = <List<Color>>[
    AppColors.primaryGradient,
    AppColors.violetGradient,
    AppColors.pinkGradient,
    AppColors.infoGradient,
    AppColors.successGradient,
    AppColors.warningGradient,
  ];

  List<Color> _gradientFor(String s) {
    int hash = 0;
    for (final code in s.runes) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return _palette[hash % _palette.length];
  }

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.take(1).toString();
    return parts.first.characters.take(1).toString() + parts[1].characters.take(1).toString();
  }

  @override
  Widget build(BuildContext context) {
    final grad = _gradientFor(name);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: grad, begin: Alignment.topRight, end: Alignment.bottomLeft),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: grad.last.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        _initials(name),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}
