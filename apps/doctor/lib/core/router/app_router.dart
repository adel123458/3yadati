import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/calendar/calendar_screen.dart';
import '../../features/appointments/appointment_details_screen.dart';
import '../../features/working_hours/working_hours_screen.dart';
import '../../features/branches/branches_screen.dart';
import '../../features/patients/patients_screen.dart';
import '../../features/patients/patient_details_screen.dart';
import '../../features/statistics/statistics_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/shell/shell_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => ShellScreen(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
          GoRoute(path: '/patients', builder: (_, __) => const PatientsScreen()),
          GoRoute(path: '/statistics', builder: (_, __) => const StatisticsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(
        path: '/appointment/:id',
        builder: (_, state) => AppointmentDetailsScreen(appointmentId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/working-hours', builder: (_, __) => const WorkingHoursScreen()),
      GoRoute(path: '/branches', builder: (_, __) => const BranchesScreen()),
      GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
      GoRoute(
        path: '/patient/:id',
        builder: (_, state) => PatientDetailsScreen(patientId: state.pathParameters['id']!),
      ),
    ],
  );
});
