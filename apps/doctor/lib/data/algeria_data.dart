/// Static datasets tailored to the Algerian market.
/// Used in registration, doctor profile, branch creation, etc.
library;

class AlgeriaData {
  /// 58 Algerian wilayas (ولايات) in their official order.
  static const List<Wilaya> wilayas = [
    Wilaya(code: '01', nameAr: 'أدرار'),
    Wilaya(code: '02', nameAr: 'الشلف'),
    Wilaya(code: '03', nameAr: 'الأغواط'),
    Wilaya(code: '04', nameAr: 'أم البواقي'),
    Wilaya(code: '05', nameAr: 'باتنة'),
    Wilaya(code: '06', nameAr: 'بجاية'),
    Wilaya(code: '07', nameAr: 'بسكرة'),
    Wilaya(code: '08', nameAr: 'بشار'),
    Wilaya(code: '09', nameAr: 'البليدة'),
    Wilaya(code: '10', nameAr: 'البويرة'),
    Wilaya(code: '11', nameAr: 'تمنراست'),
    Wilaya(code: '12', nameAr: 'تبسة'),
    Wilaya(code: '13', nameAr: 'تلمسان'),
    Wilaya(code: '14', nameAr: 'تيارت'),
    Wilaya(code: '15', nameAr: 'تيزي وزو'),
    Wilaya(code: '16', nameAr: 'الجزائر العاصمة'),
    Wilaya(code: '17', nameAr: 'الجلفة'),
    Wilaya(code: '18', nameAr: 'جيجل'),
    Wilaya(code: '19', nameAr: 'سطيف'),
    Wilaya(code: '20', nameAr: 'سعيدة'),
    Wilaya(code: '21', nameAr: 'سكيكدة'),
    Wilaya(code: '22', nameAr: 'سيدي بلعباس'),
    Wilaya(code: '23', nameAr: 'عنابة'),
    Wilaya(code: '24', nameAr: 'قالمة'),
    Wilaya(code: '25', nameAr: 'قسنطينة'),
    Wilaya(code: '26', nameAr: 'المدية'),
    Wilaya(code: '27', nameAr: 'مستغانم'),
    Wilaya(code: '28', nameAr: 'المسيلة'),
    Wilaya(code: '29', nameAr: 'معسكر'),
    Wilaya(code: '30', nameAr: 'ورقلة'),
    Wilaya(code: '31', nameAr: 'وهران'),
    Wilaya(code: '32', nameAr: 'البيض'),
    Wilaya(code: '33', nameAr: 'إليزي'),
    Wilaya(code: '34', nameAr: 'برج بوعريريج'),
    Wilaya(code: '35', nameAr: 'بومرداس'),
    Wilaya(code: '36', nameAr: 'الطارف'),
    Wilaya(code: '37', nameAr: 'تندوف'),
    Wilaya(code: '38', nameAr: 'تيسمسيلت'),
    Wilaya(code: '39', nameAr: 'الوادي'),
    Wilaya(code: '40', nameAr: 'خنشلة'),
    Wilaya(code: '41', nameAr: 'سوق أهراس'),
    Wilaya(code: '42', nameAr: 'تيبازة'),
    Wilaya(code: '43', nameAr: 'ميلة'),
    Wilaya(code: '44', nameAr: 'عين الدفلى'),
    Wilaya(code: '45', nameAr: 'النعامة'),
    Wilaya(code: '46', nameAr: 'عين تموشنت'),
    Wilaya(code: '47', nameAr: 'غرداية'),
    Wilaya(code: '48', nameAr: 'غليزان'),
    Wilaya(code: '49', nameAr: 'تيميمون'),
    Wilaya(code: '50', nameAr: 'برج باجي مختار'),
    Wilaya(code: '51', nameAr: 'أولاد جلال'),
    Wilaya(code: '52', nameAr: 'بني عباس'),
    Wilaya(code: '53', nameAr: 'عين صالح'),
    Wilaya(code: '54', nameAr: 'عين قزام'),
    Wilaya(code: '55', nameAr: 'تقرت'),
    Wilaya(code: '56', nameAr: 'جانت'),
    Wilaya(code: '57', nameAr: 'المغير'),
    Wilaya(code: '58', nameAr: 'المنيعة'),
  ];

  /// Arabic medical specialties commonly found in Algerian clinics.
  static const List<SpecialtyItem> specialties = [
    SpecialtyItem(slug: 'cardio', nameAr: 'طب القلب'),
    SpecialtyItem(slug: 'general', nameAr: 'طب عام'),
    SpecialtyItem(slug: 'pediatrics', nameAr: 'طب الأطفال'),
    SpecialtyItem(slug: 'gynecology', nameAr: 'أمراض النساء والتوليد'),
    SpecialtyItem(slug: 'dermatology', nameAr: 'الأمراض الجلدية'),
    SpecialtyItem(slug: 'ortho', nameAr: 'جراحة العظام'),
    SpecialtyItem(slug: 'ent', nameAr: 'أنف وأذن وحنجرة'),
    SpecialtyItem(slug: 'ophtalmo', nameAr: 'طب العيون'),
    SpecialtyItem(slug: 'neuro', nameAr: 'طب الأعصاب'),
    SpecialtyItem(slug: 'psych', nameAr: 'الطب النفسي'),
    SpecialtyItem(slug: 'dentist', nameAr: 'طب الأسنان'),
    SpecialtyItem(slug: 'uro', nameAr: 'أمراض المسالك البولية'),
    SpecialtyItem(slug: 'gastro', nameAr: 'أمراض الجهاز الهضمي'),
    SpecialtyItem(slug: 'endocrine', nameAr: 'أمراض الغدد والسكري'),
    SpecialtyItem(slug: 'pneumo', nameAr: 'أمراض الصدر والجهاز التنفسي'),
    SpecialtyItem(slug: 'rheumato', nameAr: 'أمراض الروماتيزم'),
    SpecialtyItem(slug: 'onco', nameAr: 'علاج الأورام'),
    SpecialtyItem(slug: 'radio', nameAr: 'الأشعة والتصوير الطبي'),
    SpecialtyItem(slug: 'surgery', nameAr: 'الجراحة العامة'),
    SpecialtyItem(slug: 'nutrition', nameAr: 'التغذية والحمية'),
  ];
}

class Wilaya {
  final String code;
  final String nameAr;
  const Wilaya({required this.code, required this.nameAr});

  String get label => '$code - $nameAr';
}

class SpecialtyItem {
  final String slug;
  final String nameAr;
  const SpecialtyItem({required this.slug, required this.nameAr});
}
