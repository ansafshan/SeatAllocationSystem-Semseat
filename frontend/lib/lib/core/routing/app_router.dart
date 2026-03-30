import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../../providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/admin/screens/admin_dashboard.dart';
import '../../features/admin/screens/department_screen.dart';
import '../../features/admin/screens/batch_screen.dart';
import '../../features/admin/screens/subject_screen.dart';
import '../../features/admin/screens/student_screen.dart';
import '../../features/admin/screens/teacher_screen.dart';
import '../../features/admin/screens/hall_screen.dart';
import '../../features/admin/screens/session_screen.dart';
import '../../features/admin/screens/session_detail_screen.dart';
import '../../features/admin/screens/exam_day_detail_screen.dart';
import '../../features/admin/screens/hall_layout_screen.dart';
import '../../features/admin/screens/allocation_view_screen.dart';
import '../../features/teacher/screens/teacher_dashboard.dart';
import '../../features/teacher/screens/teacher_hall_seats.dart';
import '../../features/student/screens/student_dashboard.dart';
import '../../models/hall.dart';
import '../../providers/hall_provider.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final auth = context.read<AuthProvider>();
      final isLoggingIn = state.matchedLocation == '/login';

      if (!auth.isAuthenticated) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        final role = auth.role;
        if (role == 'admin') return '/admin';
        if (role == 'teacher') return '/teacher';
        if (role == 'student') return '/student';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/admin/departments',
        builder: (context, state) => const DepartmentScreen(),
      ),
      GoRoute(
        path: '/admin/batches',
        builder: (context, state) => const BatchScreen(),
      ),
      GoRoute(
        path: '/admin/subjects',
        builder: (context, state) => const SubjectScreen(),
      ),
      GoRoute(
        path: '/admin/students',
        builder: (context, state) => const StudentScreen(),
      ),
      GoRoute(
        path: '/admin/teachers',
        builder: (context, state) => const TeacherScreen(),
      ),
      GoRoute(
        path: '/admin/halls',
        builder: (context, state) => const HallScreen(),
      ),
      GoRoute(
        path: '/admin/halls/:hid/layout',
        builder: (context, state) {
          final hallId = int.parse(state.pathParameters['hid']!);
          final hall = context.read<HallProvider>().halls.firstWhereOrNull((h) => h.id == hallId);
          if (hall == null) return const HallScreen();
          return HallLayoutScreen(hall: hall);
        },
      ),
      GoRoute(
        path: '/admin/sessions',
        builder: (context, state) => const SessionScreen(),
      ),
      GoRoute(
        path: '/admin/sessions/:sid',
        builder: (context, state) => SessionDetailScreen(sessionId: int.parse(state.pathParameters['sid']!)),
      ),
      GoRoute(
        path: '/admin/exam-days/:did',
        builder: (context, state) => ExamDayDetailScreen(dayId: int.parse(state.pathParameters['did']!)),
      ),
      GoRoute(
        path: '/admin/exam-days/:did/halls/:hid/layout',
        builder: (context, state) {
          final hallId = int.parse(state.pathParameters['hid']!);
          final dayId = int.parse(state.pathParameters['did']!);
          final hall = context.read<HallProvider>().halls.firstWhereOrNull((h) => h.id == hallId);
          if (hall == null) return ExamDayDetailScreen(dayId: dayId);
          return HallLayoutScreen(dayId: dayId, hall: hall);
        },
      ),
      GoRoute(
        path: '/admin/exam-days/:did/halls/:hid/view',
        builder: (context, state) {
          final hallId = int.parse(state.pathParameters['hid']!);
          final dayId = int.parse(state.pathParameters['did']!);
          final hall = context.read<HallProvider>().halls.firstWhereOrNull((h) => h.id == hallId);
          if (hall == null) return ExamDayDetailScreen(dayId: dayId);
          return AllocationViewScreen(dayId: dayId, hall: hall);
        },
      ),
      GoRoute(
        path: '/teacher',
        builder: (context, state) => const TeacherDashboard(),
      ),
      GoRoute(
        path: '/teacher/halls/:did/:hid',
        builder: (context, state) => TeacherHallSeatsScreen(
          dayId: int.parse(state.pathParameters['did']!),
          hallId: int.parse(state.pathParameters['hid']!),
        ),
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentDashboard(),
      ),
    ],
  );
}
