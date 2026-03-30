import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/teacher_provider.dart';
import '../../../core/widgets/neo_widgets.dart';
import '../../../models/malpractice.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({Key? key}) : super(key: key);

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<TeacherProvider>().fetchDuties(token);
        context.read<TeacherProvider>().fetchRecentMalpractice(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('TEACHER PORTAL', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            onPressed: () {
              final token = auth.token;
              if (token != null) {
                context.read<TeacherProvider>().fetchDuties(token);
                context.read<TeacherProvider>().fetchRecentMalpractice(token);
              }
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              auth.logout();
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NeoCard(
              backgroundColor: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WELCOME, ${auth.name?.toUpperCase() ?? 'TEACHER'}',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'View your invigilation schedule and hall seating charts.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'YOUR INVIGILATION DUTIES',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Consumer<TeacherProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                if (provider.duties.isEmpty) return const NeoCard(child: Text('No duties assigned.'));
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.duties.length,
                  itemBuilder: (context, index) {
                    final duty = provider.duties[index];
                    final examDay = duty['ExamDay'];
                    final hall = duty['Hall'];
                    final session = examDay['Session'];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: InkWell(
                        onTap: () => context.push('/teacher/halls/${examDay['id']}/${hall['id']}'),
                        child: NeoCard(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4)),
                                child: Text(examDay['slot'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat('EEE, MMM d, yyyy').format(DateTime.parse(examDay['date'])),
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                    ),
                                    Text('${session['name']} - HALL: ${hall['name']}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'RECENT MALPRACTICE REPORTS',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Consumer<TeacherProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) return const SizedBox();
                if (provider.recentMalpractice.isEmpty) {
                  return const NeoCard(child: Center(child: Text('No recent reports found.')));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.recentMalpractice.length,
                  itemBuilder: (context, index) {
                    final m = provider.recentMalpractice[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: NeoCard(
                        backgroundColor: const Color(0xFFFFF3E0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.student?.name ?? 'UNKNOWN STUDENT',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                  ),
                                  Text('Reason: ${m.reason}'),
                                  Text(
                                    'Exam: ${m.examDay?.date} (${m.examDay?.slot})',
                                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteReportDialog(m.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteReportDialog(int logId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 3),
          borderRadius: BorderRadius.zero,
        ),
        title: const Text('DELETE REPORT', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to delete this report? This is only allowed within a limited time window (60 mins).'),
        actions: [
          NeoButton(onPressed: () => Navigator.pop(context), text: 'CANCEL', backgroundColor: Colors.white, textColor: Colors.black),
          NeoButton(
            onPressed: () async {
              final token = context.read<AuthProvider>().token;
              if (token != null) {
                final success = await context.read<TeacherProvider>().deleteMalpractice(logId, token);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'REPORT DELETED' : 'FAILED TO DELETE. TIME WINDOW EXPIRED?'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              }
            },
            text: 'DELETE',
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }
}
