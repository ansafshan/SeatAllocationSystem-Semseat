import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../core/widgets/neo_widgets.dart';
import '../../../models/malpractice.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<StudentProvider>().fetchMySeats(token);
        context.read<StudentProvider>().fetchMyMalpracticeHistory(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('STUDENT PORTAL', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            onPressed: () {
              final token = auth.token;
              if (token != null) {
                context.read<StudentProvider>().fetchMySeats(token);
                context.read<StudentProvider>().fetchMyMalpracticeHistory(token);
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
                    'WELCOME, ${auth.name?.toUpperCase() ?? 'STUDENT'}',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'View your seat allocations for upcoming exams here.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'YOUR SEAT ALLOCATIONS',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Consumer<StudentProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                if (provider.mySeats.isEmpty) return const NeoCard(child: Text('No seats allocated for upcoming exams.'));
                
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.mySeats.length,
                  itemBuilder: (context, index) {
                    final allocation = provider.mySeats[index];
                    final examDay = allocation.examDay;
                    final hall = allocation.hall;
                    final session = examDay?.session;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: NeoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  session?.name.toUpperCase() ?? 'EXAM',
                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(4)),
                                  child: Text(
                                    examDay?.slot ?? '??',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32, thickness: 2, color: Colors.black12),
                            _buildInfoRow(Icons.calendar_today, 'DATE', 
                              examDay != null ? DateFormat('EEEE, MMMM d, yyyy').format(DateTime.parse(examDay.date)) : '-'),
                            const SizedBox(height: 12),
                            _buildInfoRow(Icons.business, 'HALL', hall?.name ?? '-'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: _buildInfoRow(Icons.grid_on, 'BENCH', 'Row ${allocation.benchRow}, Col ${allocation.benchCol}')),
                                Expanded(child: _buildInfoRow(Icons.event_seat, 'POSITION', allocation.seatPosition)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'MALPRACTICE HISTORY',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Consumer<StudentProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) return const SizedBox();
                if (provider.malpracticeHistory.isEmpty) {
                  return const NeoCard(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Center(
                      child: Text(
                        'No incidents reported. Good job!',
                        style: TextStyle(fontWeight: FontWeight.w900, color: Colors.green),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.malpracticeHistory.length,
                  itemBuilder: (context, index) {
                    final m = provider.malpracticeHistory[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: NeoCard(
                        backgroundColor: const Color(0xFFFFEBEE),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(
                                  m.reason.toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.red),
                                ),
                              ],
                            ),
                            const Divider(height: 24, thickness: 2, color: Colors.black12),
                            Text('EXAM: ${m.examDay?.date} (${m.examDay?.slot})', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Text('REPORTED ON: ${m.createdAt.split('T')[0]}', style: const TextStyle(fontSize: 10)),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black38)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
      ],
    );
  }
}
