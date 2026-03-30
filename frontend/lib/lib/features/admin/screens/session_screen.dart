import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/neo_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/exam_provider.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({Key? key}) : super(key: key);

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<ExamProvider>().fetchSessions(token);
    }
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    String type = 'series';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.black, width: 3),
            borderRadius: BorderRadius.zero,
          ),
          title: const Text('NEW EXAM SESSION', style: TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeoTextField(controller: nameController, label: 'Session Name', hint: 'e.g. Nov 2024 Univ'),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft, 
                child: Text('TYPE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))
              ),
              Row(
                children: [
                  Radio<String>(value: 'series', groupValue: type, onChanged: (v) => setState(() => type = v!)),
                  const Text('Series'),
                  const SizedBox(width: 16),
                  Radio<String>(value: 'university', groupValue: type, onChanged: (v) => setState(() => type = v!)),
                  const Text('University'),
                ],
              ),
            ],
          ),
          actions: [
            NeoButton(onPressed: () => Navigator.pop(context), text: 'CANCEL', backgroundColor: Colors.white, textColor: Colors.black),
            NeoButton(
              onPressed: () async {
                final token = context.read<AuthProvider>().token;
                if (token != null && nameController.text.isNotEmpty) {
                  final success = await context.read<ExamProvider>().createSession(nameController.text, type, token);
                  if (success && mounted) Navigator.pop(context);
                }
              },
              text: 'CREATE',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Exam Sessions',
      actions: [
        IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh)),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: Consumer<ExamProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.sessions.isEmpty) return const Center(child: Text('No sessions created.'));
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.sessions.length,
            itemBuilder: (context, index) {
              final session = provider.sessions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: InkWell(
                  onTap: () => context.push('/admin/sessions/${session.id}'),
                  child: NeoCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(session.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                              const SizedBox(height: 4),
                              Text(
                                'TYPE: ${session.type.toUpperCase()}', 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => _showDeleteDialog(session.id),
                        ),
                        const Icon(Icons.chevron_right, size: 24),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteDialog(int sessionId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 3),
          borderRadius: BorderRadius.zero,
        ),
        title: const Text('DELETE SESSION', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to delete this session? This will delete all associated data.'),
        actions: [
          NeoButton(onPressed: () => Navigator.pop(context), text: 'CANCEL', backgroundColor: Colors.white, textColor: Colors.black),
          NeoButton(
            onPressed: () async {
              final token = context.read<AuthProvider>().token;
              if (token != null) {
                final result = await context.read<ExamProvider>().deleteSession(sessionId, token);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor: result['success'] ? Colors.green : Colors.red,
                    ),
                  );
                  if (result['success']) {
                    _refreshData();
                  }
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
