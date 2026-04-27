import 'models/models.dart';

/// Demo / fallback data so the app runs even without a live backend.
class MockData {
  static User get user => const User(
        id: 'demo-user',
        email: 'doctor@3yadati.dz',
        fullName: 'د. أحمد السعيد',
        role: 'DOCTOR',
        doctorId: 'demo-doc',
      );

  static DoctorProfile get doctor => DoctorProfile(
        id: 'demo-doc',
        bio: 'طبيب قلب بخبرة 12 سنة في تشخيص وعلاج أمراض القلب والشرايين.',
        yearsOfExperience: 12,
        consultationPrice: 3500,
        currency: 'DZD',
        specialty: const Specialty(id: 'cardio', nameAr: 'طب القلب', nameEn: 'Cardiology'),
        branches: branches,
        user: user,
        wilayaCode: '16',
        wilayaNameAr: 'الجزائر العاصمة',
      );

  static List<Branch> get branches => const [
        Branch(
          id: 'b1',
          name: 'الفرع الرئيسي - الجزائر العاصمة',
          address: 'شارع ديدوش مراد، الجزائر',
          city: 'الجزائر',
          phone: '+213500000010',
          latitude: 36.7538,
          longitude: 3.0588,
          isPrimary: true,
        ),
        Branch(
          id: 'b2',
          name: 'فرع وهران',
          address: 'حي الصديقية، وهران',
          city: 'وهران',
          phone: '+213500000011',
          latitude: 35.6911,
          longitude: -0.6417,
        ),
      ];

  static List<Patient> get patients => [
        Patient(id: 'p1', fullName: 'سارة محمد', phone: '+213551111111', gender: 'FEMALE', lastVisit: DateTime.now().subtract(const Duration(days: 7))),
        Patient(id: 'p2', fullName: 'أحمد السالم', phone: '+213552222222', gender: 'MALE', lastVisit: DateTime.now().subtract(const Duration(days: 3))),
        Patient(id: 'p3', fullName: 'محمد عبدالله', phone: '+213553333333', gender: 'MALE', lastVisit: DateTime.now().subtract(const Duration(days: 1))),
        Patient(id: 'p4', fullName: 'نورة علي', phone: '+213554444444', gender: 'FEMALE', lastVisit: DateTime.now().subtract(const Duration(days: 10))),
        Patient(id: 'p5', fullName: 'منال درعي', phone: '+213555555555', gender: 'FEMALE', lastVisit: DateTime.now().subtract(const Duration(days: 14))),
        Patient(id: 'p6', fullName: 'ياسر خليل', phone: '+213556666666', gender: 'MALE', lastVisit: DateTime.now().subtract(const Duration(days: 30))),
        Patient(id: 'p7', fullName: 'خالد الفيصل', phone: '+213557777777', gender: 'MALE', lastVisit: DateTime.now().subtract(const Duration(days: 45))),
      ];

  static List<Appointment> get todayAppointments {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    DateTime t(int h, int m) => today.add(Duration(hours: h, minutes: m));
    return [
      Appointment(id: 'a1', code: 'APT-100001', startAt: t(9, 0), endAt: t(9, 30), status: AppointmentStatus.confirmed, reason: 'استشارة قلبية', patient: patients[0]),
      Appointment(id: 'a2', code: 'APT-100002', startAt: t(10, 30), endAt: t(11, 0), status: AppointmentStatus.confirmed, reason: 'متابعة حالة', patient: patients[2]),
      Appointment(id: 'a3', code: 'APT-100003', startAt: t(11, 0), endAt: t(11, 30), status: AppointmentStatus.pending, reason: 'تخطيط قلب', patient: patients[1]),
      Appointment(id: 'a4', code: 'APT-100004', startAt: t(13, 30), endAt: t(14, 0), status: AppointmentStatus.confirmed, reason: 'فحص دوري', patient: patients[3]),
      Appointment(id: 'a5', code: 'APT-100005', startAt: t(14, 30), endAt: t(15, 0), status: AppointmentStatus.pending, reason: 'متابعة نتائج', patient: patients[4]),
      Appointment(id: 'a6', code: 'APT-100006', startAt: t(15, 0), endAt: t(15, 30), status: AppointmentStatus.confirmed, reason: 'استشارة قلبية', patient: patients[5]),
      Appointment(id: 'a7', code: 'APT-100007', startAt: t(16, 0), endAt: t(16, 30), status: AppointmentStatus.cancelled, reason: 'استشارة قلبية', patient: patients[6]),
    ];
  }

  static List<WorkingHour> get workingHours => const [
        WorkingHour(id: 'w1', weekday: 'SUNDAY', startTime: '09:00', endTime: '17:00', slotMinutes: 30, breakStart: '12:30', breakEnd: '13:30'),
        WorkingHour(id: 'w2', weekday: 'MONDAY', startTime: '09:00', endTime: '17:00', slotMinutes: 30, breakStart: '12:30', breakEnd: '13:30'),
        WorkingHour(id: 'w3', weekday: 'TUESDAY', startTime: '09:00', endTime: '17:00', slotMinutes: 30, breakStart: '12:30', breakEnd: '13:30'),
        WorkingHour(id: 'w4', weekday: 'WEDNESDAY', startTime: '09:00', endTime: '17:00', slotMinutes: 30, breakStart: '12:30', breakEnd: '13:30'),
        WorkingHour(id: 'w5', weekday: 'THURSDAY', startTime: '09:00', endTime: '17:00', slotMinutes: 30, breakStart: '12:30', breakEnd: '13:30'),
        WorkingHour(id: 'w6', weekday: 'FRIDAY', startTime: '00:00', endTime: '00:00', isClosed: true),
        WorkingHour(id: 'w7', weekday: 'SATURDAY', startTime: '10:00', endTime: '14:00', slotMinutes: 30),
      ];

  static List<AppNotification> get notifications => [
        AppNotification(id: 'n1', type: 'APPOINTMENT_CREATED', title: 'موعد جديد', body: 'حجزت سارة محمد موعدًا في تمام الساعة 09:00', read: false, createdAt: DateTime.now().subtract(const Duration(minutes: 5))),
        AppNotification(id: 'n2', type: 'APPOINTMENT_CONFIRMED', title: 'تأكيد موعد', body: 'تم تأكيد موعد محمد عبدالله الساعة 10:30', read: false, createdAt: DateTime.now().subtract(const Duration(hours: 1))),
        AppNotification(id: 'n3', type: 'APPOINTMENT_CANCELLED', title: 'إلغاء موعد', body: 'تم إلغاء موعد خالد الفيصل', read: true, createdAt: DateTime.now().subtract(const Duration(hours: 3))),
        AppNotification(id: 'n4', type: 'REMINDER', title: 'تذكير', body: 'لديك 7 مواعيد لهذا اليوم', read: true, createdAt: DateTime.now().subtract(const Duration(days: 1))),
      ];

  static StatisticsOverview get overview => StatisticsOverview(
        todayTotal: 7,
        todayConfirmed: 4,
        todayPending: 2,
        todayCancelled: 1,
        todayCompleted: 0,
        todayRevenue: 14000,
        totalPatients: 156,
        newPatientsThisWeek: 18,
        upcoming: todayAppointments.take(4).toList(),
      );

  static List<int> get weeklyChart => [12, 18, 22, 16, 25, 14, 19];
}
