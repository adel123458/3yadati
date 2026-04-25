import 'package:intl/intl.dart';

String formatTimeArabic(DateTime dt) {
  final hour = dt.hour == 0
      ? 12
      : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
  final minute = dt.minute.toString().padLeft(2, '0');
  final suffix = dt.hour < 12 ? 'ص' : 'م';
  return '$hour:$minute $suffix';
}

String formatDateArabic(DateTime dt) {
  return DateFormat('d MMMM yyyy', 'ar').format(dt);
}

String formatWeekdayArabic(DateTime dt) {
  return DateFormat('EEEE', 'ar').format(dt);
}

const Map<String, String> weekdayArabic = {
  'SUNDAY': 'الأحد',
  'MONDAY': 'الإثنين',
  'TUESDAY': 'الثلاثاء',
  'WEDNESDAY': 'الأربعاء',
  'THURSDAY': 'الخميس',
  'FRIDAY': 'الجمعة',
  'SATURDAY': 'السبت',
};

String formatCurrency(double v, [String currency = 'دج']) {
  final formatter = NumberFormat.decimalPattern('ar');
  return '${formatter.format(v)} $currency';
}
