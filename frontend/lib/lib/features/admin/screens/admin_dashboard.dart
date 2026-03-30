import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/admin_provider.dart';
import '../../../core/widgets/neo_widgets.dart';
import 'package:go_router/go_router.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<AdminProvider>().fetchDashboardStats(token);
        context.read<AdminProvider>().fetchRecentMalpractices(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Dashboard',
      child: SingleChildScrollView(
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
                    'Welcome back, ${context.read<AuthProvider>().name?.toUpperCase() ?? 'ADMIN'}',
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 28, 
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The seat allocation system is running normally. Review upcoming sessions and manage resources.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Consumer<AdminProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                final stats = provider.stats;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.count(
                      crossAxisCount: MediaQuery.of(context).size.width > 1000 ? 4 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard('Total Students', stats['students'].toString(), Icons.group),
                        _buildStatCard('Total Teachers', stats['teachers'].toString(), Icons.school),
                        _buildStatCard('Exam Halls', stats['halls'].toString(), Icons.business),
                        _buildStatCard(
                          'Upcoming Exams', 
                          stats['upcomingExams'].toString(), 
                          Icons.event,
                          isPrimary: true
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'MALPRACTICE MONITOR',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 16),
                    _buildMalpracticeMonitor(provider.recentMalpractices),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMalpracticeMonitor(List<dynamic> logs) {
    if (logs.isEmpty) {
      return const NeoCard(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('No recent malpractice reported.')),
        ),
      );
    }

    return Column(
      children: logs.map((log) {
        final studentName = log['Student']?['User']?['name'] ?? 'Unknown';
        final sessionName = log['ExamDay']?['Session']?['name'] ?? 'Exam';
        final reason = log['reason'] ?? 'No reason provided';
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: NeoCard(
            backgroundColor: Colors.red.shade50,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.warning, color: Colors.white),
              ),
              title: Text(
                '$studentName - $sessionName'.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(reason),
              trailing: Text(
                log['created_at'] != null 
                  ? DateTime.parse(log['created_at']).toLocal().toString().split(' ')[0]
                  : '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, {bool isPrimary = false}) {
    return NeoCard(
      backgroundColor: isPrimary ? Colors.black : Colors.white,
      padding: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(), 
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold,
                  color: isPrimary ? Colors.white70 : Colors.black54,
                  letterSpacing: 1.1,
                )
              ),
              Icon(icon, color: isPrimary ? Colors.white : Colors.black),
            ],
          ),
          const Spacer(),
          Text(
            value, 
            style: TextStyle(
              fontSize: 48, 
              fontWeight: FontWeight.w900,
              color: isPrimary ? Colors.white : Colors.black,
            )
          ),
        ],
      ),
    );
  }
}
