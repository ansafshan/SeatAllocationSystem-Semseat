import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'core/routing/app_router.dart';

// Providers
import 'providers/department_provider.dart';
import 'providers/batch_provider.dart';
import 'providers/subject_provider.dart';
import 'providers/student_provider.dart';
import 'providers/teacher_provider.dart';
import 'providers/hall_provider.dart';
import 'providers/exam_provider.dart';
import 'providers/admin_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final authProvider = AuthProvider();
  await authProvider.tryAutoLogin();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => DepartmentProvider()),
        ChangeNotifierProvider(create: (_) => BatchProvider()),
        ChangeNotifierProvider(create: (_) => SubjectProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
        ChangeNotifierProvider(create: (_) => HallProvider()),
        ChangeNotifierProvider(create: (_) => ExamProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: const SemSeatApp(),
    ),
  );
}

class SemSeatApp extends StatelessWidget {
  const SemSeatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SEMSEAT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        primaryColor: Colors.black,
        fontFamily: 'Lexend',
        textTheme: GoogleFonts.lexendTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
          shape: Border(
            bottom: BorderSide(color: Colors.black, width: 3),
          ),
          titleTextStyle: TextStyle(
            fontFamily: 'Lexend',
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      routerConfig: AppRouter.router,
    );
  }
}
