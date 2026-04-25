import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final AppointmentStatus status;
  final bool small;
  const StatusBadge({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    final cfg = _config(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 8 : 10, vertical: small ? 3 : 5),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        cfg.label,
        style: TextStyle(
          color: cfg.fg,
          fontSize: small ? 11 : 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  static _BadgeConfig _config(AppointmentStatus s) {
    switch (s) {
      case AppointmentStatus.confirmed:
        return _BadgeConfig('مؤكد', AppColors.success, AppColors.success.withOpacity(0.12));
      case AppointmentStatus.pending:
        return _BadgeConfig('قيد الانتظار', AppColors.warning, AppColors.warning.withOpacity(0.12));
      case AppointmentStatus.completed:
        return _BadgeConfig('مكتمل', AppColors.info, AppColors.info.withOpacity(0.12));
      case AppointmentStatus.cancelled:
        return _BadgeConfig('ملغي', AppColors.danger, AppColors.danger.withOpacity(0.12));
      case AppointmentStatus.noShow:
        return _BadgeConfig('لم يحضر', AppColors.textSecondary, AppColors.textSecondary.withOpacity(0.12));
      case AppointmentStatus.closed:
        return _BadgeConfig('مغلق', AppColors.textMuted, AppColors.textMuted.withOpacity(0.15));
      case AppointmentStatus.available:
        return _BadgeConfig('متاح', AppColors.primary, AppColors.primaryLight);
    }
  }
}

class _BadgeConfig {
  final String label;
  final Color fg;
  final Color bg;
  _BadgeConfig(this.label, this.fg, this.bg);
}

Color appointmentColor(AppointmentStatus s) {
  switch (s) {
    case AppointmentStatus.confirmed:
      return AppColors.success;
    case AppointmentStatus.pending:
      return AppColors.warning;
    case AppointmentStatus.completed:
      return AppColors.info;
    case AppointmentStatus.cancelled:
      return AppColors.danger;
    case AppointmentStatus.noShow:
      return AppColors.textSecondary;
    case AppointmentStatus.closed:
      return AppColors.textMuted;
    case AppointmentStatus.available:
      return AppColors.primary;
  }
}
