import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/widgets/neo_widgets.dart'; // Import neo widgets

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'admin@semseat.com');
  final _passwordController = TextEditingController(text: 'admin');

  void _login() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text,
      _passwordController.text,
    );
    if (success && mounted) {
      final role = authProvider.role;
      if (role == 'admin') context.go('/admin');
      if (role == 'teacher') context.go('/teacher');
      if (role == 'student') context.go('/student');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Failed. Please check your credentials.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'SEMSEAT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'EXAM SEAT ALLOCATION SYSTEM',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 48),
                NeoTextField(
                  controller: _emailController,
                  label: 'Email Address',
                ),
                const SizedBox(height: 24),
                NeoTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: true,
                ),
                const SizedBox(height: 48),
                authProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : NeoButton(
                        onPressed: _login,
                        text: 'Login',
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
