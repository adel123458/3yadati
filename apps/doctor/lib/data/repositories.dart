import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import 'mock_data.dart';
import 'models/models.dart';

/// Repositories wrap API calls. When the API is unreachable they fall back
/// to mock data so the UI remains usable in demo mode.
class AppointmentsRepo {
  final Dio dio;
  AppointmentsRepo(this.dio);

  Future<List<Appointment>> list({DateTime? from, DateTime? to}) async {
    try {
      final res = await dio.get('/appointments', queryParameters: {
        if (from != null) 'from': from.toUtc().toIso8601String(),
        if (to != null) 'to': to.toUtc().toIso8601String(),
      });
      return (res.data as List).map((e) => Appointment.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return MockData.todayAppointments;
    }
  }

  Future<Appointment?> get(String id) async {
    try {
      final res = await dio.get('/appointments/$id');
      return Appointment.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return MockData.todayAppointments.firstWhere(
        (a) => a.id == id,
        orElse: () => MockData.todayAppointments.first,
      );
    }
  }

  Future<void> changeStatus(String id, AppointmentStatus s, {String? reason}) async {
    try {
      await dio.patch('/appointments/$id/status', data: {
        'status': s.toApi(),
        if (reason != null) 'cancelledReason': reason,
      });
    } catch (_) {/* demo mode */}
  }

  Future<void> reschedule(String id, DateTime startAt, DateTime endAt) async {
    try {
      await dio.patch('/appointments/$id/reschedule', data: {
        'startAt': startAt.toUtc().toIso8601String(),
        'endAt': endAt.toUtc().toIso8601String(),
      });
    } catch (_) {}
  }
}

class PatientsRepo {
  final Dio dio;
  PatientsRepo(this.dio);

  Future<List<Patient>> list({String? q}) async {
    try {
      final res = await dio.get('/patients', queryParameters: {if (q != null && q.isNotEmpty) 'q': q});
      return (res.data as List).map((e) => Patient.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      final all = MockData.patients;
      if (q == null || q.isEmpty) return all;
      return all.where((p) => p.fullName.contains(q) || (p.phone?.contains(q) ?? false)).toList();
    }
  }
}

class WorkingHoursRepo {
  final Dio dio;
  WorkingHoursRepo(this.dio);

  Future<List<WorkingHour>> list() async {
    try {
      final res = await dio.get('/working-hours');
      return (res.data as List).map((e) => WorkingHour.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return MockData.workingHours;
    }
  }
}

class BranchesRepo {
  final Dio dio;
  BranchesRepo(this.dio);

  Future<List<Branch>> list() async {
    try {
      final res = await dio.get('/branches');
      return (res.data as List).map((e) => Branch.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return MockData.branches;
    }
  }
}

class NotificationsRepo {
  final Dio dio;
  NotificationsRepo(this.dio);

  Future<List<AppNotification>> list() async {
    try {
      final res = await dio.get('/notifications');
      return (res.data as List).map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return MockData.notifications;
    }
  }

  Future<int> unreadCount() async {
    try {
      final res = await dio.get('/notifications/unread-count');
      return (res.data['count'] as int?) ?? 0;
    } catch (_) {
      return MockData.notifications.where((n) => !n.read).length;
    }
  }
}

class StatisticsRepo {
  final Dio dio;
  StatisticsRepo(this.dio);

  Future<StatisticsOverview> overview() async {
    try {
      final res = await dio.get('/statistics/overview');
      return StatisticsOverview.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return MockData.overview;
    }
  }

  Future<List<int>> weekly() async {
    try {
      final res = await dio.get('/statistics/weekly');
      return (res.data as List).map((e) => (e['count'] as num).toInt()).toList();
    } catch (_) {
      return MockData.weeklyChart;
    }
  }
}

class DoctorsRepo {
  final Dio dio;
  DoctorsRepo(this.dio);

  Future<DoctorProfile> me() async {
    try {
      final res = await dio.get('/doctors/me');
      return DoctorProfile.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return MockData.doctor;
    }
  }
}

class AuthRepo {
  final ApiClient client;
  AuthRepo(this.client);

  Future<User> login({required String email, required String password}) async {
    try {
      final res = await client.dio.post('/auth/login', data: {'email': email, 'password': password});
      final data = res.data as Map<String, dynamic>;
      await client.setToken(data['accessToken'] as String?);
      return User.fromJson(data['user'] as Map<String, dynamic>);
    } catch (_) {
      // Demo mode: accept anything and store a fake token.
      await client.setToken('demo-token');
      return MockData.user;
    }
  }

  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? specialtyId,
    bool isCenter = false,
    String? centerName,
  }) async {
    try {
      final res = await client.dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'fullName': fullName,
        if (phone != null) 'phone': phone,
        if (specialtyId != null) 'specialtyId': specialtyId,
        if (isCenter) 'isCenter': true,
        if (centerName != null) 'centerName': centerName,
      });
      final data = res.data as Map<String, dynamic>;
      await client.setToken(data['accessToken'] as String?);
      return User.fromJson(data['user'] as Map<String, dynamic>);
    } catch (_) {
      await client.setToken('demo-token');
      return MockData.user;
    }
  }

  Future<void> logout() async {
    await client.setToken(null);
  }
}

// Providers
final authRepoProvider = Provider<AuthRepo>((ref) => AuthRepo(ref.watch(apiClientProvider)));
final appointmentsRepoProvider =
    Provider<AppointmentsRepo>((ref) => AppointmentsRepo(ref.watch(apiClientProvider).dio));
final patientsRepoProvider = Provider<PatientsRepo>((ref) => PatientsRepo(ref.watch(apiClientProvider).dio));
final workingHoursRepoProvider =
    Provider<WorkingHoursRepo>((ref) => WorkingHoursRepo(ref.watch(apiClientProvider).dio));
final branchesRepoProvider = Provider<BranchesRepo>((ref) => BranchesRepo(ref.watch(apiClientProvider).dio));
final notificationsRepoProvider =
    Provider<NotificationsRepo>((ref) => NotificationsRepo(ref.watch(apiClientProvider).dio));
final statisticsRepoProvider =
    Provider<StatisticsRepo>((ref) => StatisticsRepo(ref.watch(apiClientProvider).dio));
final doctorsRepoProvider = Provider<DoctorsRepo>((ref) => DoctorsRepo(ref.watch(apiClientProvider).dio));

final overviewProvider = FutureProvider<StatisticsOverview>((ref) {
  return ref.watch(statisticsRepoProvider).overview();
});
final weeklyProvider = FutureProvider<List<int>>((ref) => ref.watch(statisticsRepoProvider).weekly());
final appointmentsProvider =
    FutureProvider.family<List<Appointment>, AppDateRange>((ref, range) {
  return ref.watch(appointmentsRepoProvider).list(from: range.from, to: range.to);
});
final patientsProvider = FutureProvider.family<List<Patient>, String>((ref, q) {
  return ref.watch(patientsRepoProvider).list(q: q);
});
final workingHoursProvider = FutureProvider<List<WorkingHour>>((ref) {
  return ref.watch(workingHoursRepoProvider).list();
});
final branchesProvider = FutureProvider<List<Branch>>((ref) => ref.watch(branchesRepoProvider).list());
final notificationsProvider =
    FutureProvider<List<AppNotification>>((ref) => ref.watch(notificationsRepoProvider).list());
final unreadCountProvider = FutureProvider<int>((ref) => ref.watch(notificationsRepoProvider).unreadCount());
final doctorMeProvider = FutureProvider<DoctorProfile>((ref) => ref.watch(doctorsRepoProvider).me());
final appointmentByIdProvider =
    FutureProvider.family<Appointment?, String>((ref, id) => ref.watch(appointmentsRepoProvider).get(id));

class AppDateRange {
  final DateTime from;
  final DateTime to;
  const AppDateRange(this.from, this.to);

  @override
  bool operator ==(Object other) =>
      other is AppDateRange && other.from == from && other.to == to;
  @override
  int get hashCode => Object.hash(from, to);
}
