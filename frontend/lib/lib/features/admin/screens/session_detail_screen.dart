import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/neo_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/exam_provider.dart';

class SessionDetailScreen extends StatefulWidget {
  final int sessionId;
  const SessionDetailScreen({Key? key, required this.sessionId}) : super(key: key);

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<ExamProvider>().fetchSession(widget.sessionId, token);
      context.read<ExamProvider>().fetchExamDays(widget.sessionId, token);
    }
  }

  void _showAddDayDialog() {
    DateTime? selectedDate;
    String slot = 'FN';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.black, width: 3),
            borderRadius: BorderRadius.zero,
          ),
          title: const Text('ADD EXAM DAY', style: TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeoButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
                text: selectedDate == null ? 'SELECT DATE' : DateFormat('yyyy-MM-dd').format(selectedDate!),
                backgroundColor: Colors.white,
                textColor: Colors.black,
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft, 
                child: Text('SLOT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12))
              ),
              Row(
                children: [
                  Radio<String>(value: 'FN', groupValue: slot, onChanged: (v) => setState(() => slot = v!)),
                  const Text('Forenoon (FN)'),
                  const SizedBox(width: 16),
                  Radio<String>(value: 'AN', groupValue: slot, onChanged: (v) => setState(() => slot = v!)),
                  const Text('Afternoon (AN)'),
                ],
              ),
            ],
          ),
          actions: [
            NeoButton(onPressed: () => Navigator.pop(context), text: 'CANCEL', backgroundColor: Colors.white, textColor: Colors.black),
            NeoButton(
              onPressed: () async {
                final token = context.read<AuthProvider>().token;
                if (token != null && selectedDate != null) {
                  final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate!);
                  final success = await context.read<ExamProvider>().createExamDay(widget.sessionId, dateStr, slot, token);
                  if (success && mounted) Navigator.pop(context);
                }
              },
              text: 'ADD',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Session Schedule',
      actions: [
        IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh)),
      ],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDayDialog,
        backgroundColor: Colors.black,
        label: const Text('ADD DAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
      child: Consumer<ExamProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.examDays.isEmpty) return const Center(child: Text('No exam days scheduled yet.'));
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.examDays.length,
            itemBuilder: (context, index) {
              final day = provider.examDays[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: InkWell(
                  onTap: () => context.push('/admin/exam-days/${day.id}'),
                  child: NeoCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            day.slot,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('EEEE, MMMM d, yyyy').format(DateTime.parse(day.date)),
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {}, // Do nothing on tap of the detector
                          child: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _showDeleteDayDialog(day.id),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16),
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

  void _showDeleteDayDialog(int dayId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 3),
          borderRadius: BorderRadius.zero,
        ),
        title: const Text('DELETE EXAM DAY', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to delete this exam day? This will delete all subjects and allocations for this slot.'),
        actions: [
          NeoButton(onPressed: () => Navigator.pop(context), text: 'CANCEL', backgroundColor: Colors.white, textColor: Colors.black),
          NeoButton(
            onPressed: () async {
              final token = context.read<AuthProvider>().token;
              if (token != null) {
                final result = await context.read<ExamProvider>().deleteExamDay(dayId, token);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message']),
                      backgroundColor: result['success'] ? Colors.green : Colors.red,
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
