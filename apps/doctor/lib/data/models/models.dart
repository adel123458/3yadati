// Lightweight data models for the doctor app. JSON-mapped from the backend.
class User {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? doctorId;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.doctorId,
    this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id'] as String,
        email: j['email'] as String,
        fullName: j['fullName'] as String,
        role: j['role'] as String? ?? 'DOCTOR',
        doctorId: j['doctorId'] as String?,
        avatarUrl: j['avatarUrl'] as String?,
      );
}

class Specialty {
  final String id;
  final String nameAr;
  final String nameEn;
  const Specialty({required this.id, required this.nameAr, required this.nameEn});
  factory Specialty.fromJson(Map<String, dynamic> j) => Specialty(
        id: j['id'] as String,
        nameAr: j['nameAr'] as String? ?? '',
        nameEn: j['nameEn'] as String? ?? '',
      );
}

class DoctorProfile {
  final String id;
  final String? bio;
  final int? yearsOfExperience;
  final double? consultationPrice;
  final String currency;
  final bool isCenter;
  final String? centerName;
  final Specialty? specialty;
  final List<Branch> branches;
  final User? user;
  final String? wilayaCode;
  final String? wilayaNameAr;

  const DoctorProfile({
    required this.id,
    this.bio,
    this.yearsOfExperience,
    this.consultationPrice,
    this.currency = 'DZD',
    this.isCenter = false,
    this.centerName,
    this.specialty,
    this.branches = const [],
    this.user,
    this.wilayaCode,
    this.wilayaNameAr,
  });

  factory DoctorProfile.fromJson(Map<String, dynamic> j) => DoctorProfile(
        id: j['id'] as String,
        bio: j['bio'] as String?,
        yearsOfExperience: j['yearsOfExperience'] as int?,
        consultationPrice:
            j['consultationPrice'] == null ? null : double.tryParse(j['consultationPrice'].toString()),
        currency: j['currency'] as String? ?? 'DZD',
        isCenter: j['isCenter'] as bool? ?? false,
        centerName: j['centerName'] as String?,
        specialty:
            j['specialty'] is Map<String, dynamic> ? Specialty.fromJson(j['specialty'] as Map<String, dynamic>) : null,
        branches: (j['branches'] as List? ?? const [])
            .map((b) => Branch.fromJson(b as Map<String, dynamic>))
            .toList(),
        user: j['user'] is Map<String, dynamic> ? User.fromJson(j['user'] as Map<String, dynamic>) : null,
        wilayaCode: j['wilayaCode'] as String?,
        wilayaNameAr: j['wilayaNameAr'] as String?,
      );
}

class Branch {
  final String id;
  final String name;
  final String address;
  final String? phone;
  final String? city;
  final double? latitude;
  final double? longitude;
  final bool isPrimary;
  final bool isActive;

  const Branch({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.city,
    this.latitude,
    this.longitude,
    this.isPrimary = false,
    this.isActive = true,
  });

  factory Branch.fromJson(Map<String, dynamic> j) => Branch(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        address: j['address'] as String? ?? '',
        phone: j['phone'] as String?,
        city: j['city'] as String?,
        latitude: j['latitude'] == null ? null : (j['latitude'] as num).toDouble(),
        longitude: j['longitude'] == null ? null : (j['longitude'] as num).toDouble(),
        isPrimary: j['isPrimary'] as bool? ?? false,
        isActive: j['isActive'] as bool? ?? true,
      );
}

enum AppointmentStatus {
  available,
  pending,
  confirmed,
  completed,
  cancelled,
  noShow,
  closed;

  static AppointmentStatus parse(String s) {
    switch (s) {
      case 'AVAILABLE':
        return AppointmentStatus.available;
      case 'PENDING':
        return AppointmentStatus.pending;
      case 'CONFIRMED':
        return AppointmentStatus.confirmed;
      case 'COMPLETED':
        return AppointmentStatus.completed;
      case 'CANCELLED':
        return AppointmentStatus.cancelled;
      case 'NO_SHOW':
        return AppointmentStatus.noShow;
      case 'CLOSED':
        return AppointmentStatus.closed;
    }
    return AppointmentStatus.available;
  }

  String toApi() {
    switch (this) {
      case AppointmentStatus.available:
        return 'AVAILABLE';
      case AppointmentStatus.pending:
        return 'PENDING';
      case AppointmentStatus.confirmed:
        return 'CONFIRMED';
      case AppointmentStatus.completed:
        return 'COMPLETED';
      case AppointmentStatus.cancelled:
        return 'CANCELLED';
      case AppointmentStatus.noShow:
        return 'NO_SHOW';
      case AppointmentStatus.closed:
        return 'CLOSED';
    }
  }
}

class Appointment {
  final String id;
  final DateTime startAt;
  final DateTime endAt;
  final AppointmentStatus status;
  final String? reason;
  final String? internalNotes;
  final String? code;
  final Patient? patient;
  final Branch? branch;

  const Appointment({
    required this.id,
    required this.startAt,
    required this.endAt,
    required this.status,
    this.reason,
    this.internalNotes,
    this.code,
    this.patient,
    this.branch,
  });

  factory Appointment.fromJson(Map<String, dynamic> j) => Appointment(
        id: j['id'] as String,
        startAt: DateTime.parse(j['startAt'] as String).toLocal(),
        endAt: DateTime.parse(j['endAt'] as String).toLocal(),
        status: AppointmentStatus.parse(j['status'] as String? ?? 'AVAILABLE'),
        reason: j['reason'] as String?,
        internalNotes: j['internalNotes'] as String?,
        code: j['code'] as String?,
        patient: j['patient'] is Map<String, dynamic> ? Patient.fromJson(j['patient'] as Map<String, dynamic>) : null,
        branch: j['branch'] is Map<String, dynamic> ? Branch.fromJson(j['branch'] as Map<String, dynamic>) : null,
      );
}

class Patient {
  final String id;
  final String fullName;
  final String? phone;
  final String? email;
  final DateTime? birthDate;
  final String? gender;
  final DateTime? lastVisit;

  const Patient({
    required this.id,
    required this.fullName,
    this.phone,
    this.email,
    this.birthDate,
    this.gender,
    this.lastVisit,
  });

  factory Patient.fromJson(Map<String, dynamic> j) => Patient(
        id: j['id'] as String,
        fullName: j['fullName'] as String? ?? '',
        phone: j['phone'] as String?,
        email: j['email'] as String?,
        birthDate: j['birthDate'] == null ? null : DateTime.tryParse(j['birthDate'] as String),
        gender: j['gender'] as String?,
        lastVisit: j['lastVisit'] == null ? null : DateTime.tryParse(j['lastVisit'] as String),
      );
}

class WorkingHour {
  final String id;
  final String weekday; // SUNDAY..SATURDAY
  final String startTime;
  final String endTime;
  final int slotMinutes;
  final String? breakStart;
  final String? breakEnd;
  final bool isClosed;

  const WorkingHour({
    required this.id,
    required this.weekday,
    required this.startTime,
    required this.endTime,
    this.slotMinutes = 30,
    this.breakStart,
    this.breakEnd,
    this.isClosed = false,
  });

  factory WorkingHour.fromJson(Map<String, dynamic> j) => WorkingHour(
        id: j['id'] as String,
        weekday: j['weekday'] as String,
        startTime: j['startTime'] as String,
        endTime: j['endTime'] as String,
        slotMinutes: j['slotMinutes'] as int? ?? 30,
        breakStart: j['breakStart'] as String?,
        breakEnd: j['breakEnd'] as String?,
        isClosed: j['isClosed'] as bool? ?? false,
      );
}

class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] as String,
        type: j['type'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        read: j['read'] as bool? ?? false,
        createdAt: DateTime.parse(j['createdAt'] as String).toLocal(),
      );
}

class StatisticsOverview {
  final int todayTotal;
  final int todayConfirmed;
  final int todayPending;
  final int todayCancelled;
  final int todayCompleted;
  final double todayRevenue;
  final int totalPatients;
  final int newPatientsThisWeek;
  final List<Appointment> upcoming;

  const StatisticsOverview({
    required this.todayTotal,
    required this.todayConfirmed,
    required this.todayPending,
    required this.todayCancelled,
    required this.todayCompleted,
    required this.todayRevenue,
    required this.totalPatients,
    required this.newPatientsThisWeek,
    required this.upcoming,
  });

  factory StatisticsOverview.fromJson(Map<String, dynamic> j) {
    final today = j['today'] as Map<String, dynamic>? ?? {};
    final patients = j['patients'] as Map<String, dynamic>? ?? {};
    final upcoming = (j['upcoming'] as List? ?? const [])
        .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
        .toList();
    return StatisticsOverview(
      todayTotal: (today['total'] ?? 0) as int,
      todayConfirmed: (today['confirmed'] ?? 0) as int,
      todayPending: (today['pending'] ?? 0) as int,
      todayCancelled: (today['cancelled'] ?? 0) as int,
      todayCompleted: (today['completed'] ?? 0) as int,
      todayRevenue: ((today['revenue'] ?? 0) as num).toDouble(),
      totalPatients: (patients['total'] ?? 0) as int,
      newPatientsThisWeek: (patients['newThisWeek'] ?? 0) as int,
      upcoming: upcoming,
    );
  }
}
