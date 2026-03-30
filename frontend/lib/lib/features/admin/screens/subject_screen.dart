import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/neo_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/subject_provider.dart';
import '../../../providers/department_provider.dart';
import '../../../providers/batch_provider.dart';
import '../../../models/batch.dart';
import '../../../models/department.dart';
import '../../../models/subject.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({Key? key}) : super(key: key);

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<SubjectProvider>().fetchSubjects(token);
      context.read<DepartmentProvider>().fetchDepartments(token);
      context.read<BatchProvider>().fetchBatches(token);
    }
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    int? selectedDept;
    int? selectedBatch;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final filteredDepts = context.read<DepartmentProvider>().departments
              .where((d) => d.name.toLowerCase() != 'no department').toList();
          
          // Only show batches for the selected department
          final filteredBatches = selectedDept == null 
              ? <Batch>[] 
              : context.read<BatchProvider>().batches
                  .where((b) => b.name.toLowerCase() != 'no batch' && b.deptId == selectedDept).toList();

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              side: BorderSide(color: Colors.black, width: 3),
              borderRadius: BorderRadius.zero,
            ),
            title: const Text('ADD SUBJECT', style: TextStyle(fontWeight: FontWeight.w900)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NeoTextField(controller: nameController, label: 'Subject Name'),
                  const SizedBox(height: 16),
                  NeoTextField(controller: codeController, label: 'Subject Code'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(),
                    ),
                    items: filteredDepts.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                    onChanged: (v) {
                      setState(() {
                        selectedDept = v;
                        selectedBatch = null; // Reset batch when dept changes
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedBatch,
                    decoration: InputDecoration(
                      labelText: 'Batch',
                      hintText: selectedDept == null ? 'Select Department First' : 'Select Batch',
                      border: const OutlineInputBorder(),
                    ),
                    // Disable dropdown if no department is selected
                    items: selectedDept == null 
                        ? null 
                        : filteredBatches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                    onChanged: selectedDept == null 
                        ? null 
                        : (v) => setState(() => selectedBatch = v),
                  ),
                ],
              ),
            ),
            actions: [
              NeoButton(onPressed: () => Navigator.pop(context), text: 'CANCEL', backgroundColor: Colors.white, textColor: Colors.black),
              NeoButton(
                onPressed: () async {
                  final token = context.read<AuthProvider>().token;
                  if (token != null && selectedDept != null && selectedBatch != null) {
                    final success = await context.read<SubjectProvider>().addSubject(
                      nameController.text,
                      codeController.text,
                      selectedDept!,
                      selectedBatch!,
                      token
                    );
                    if (success && mounted) Navigator.pop(context);
                  }
                },
                text: 'ADD',
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Subjects',
      actions: [
        IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh)),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: Consumer<SubjectProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          
          final filteredSubjects = provider.subjects.where((s) => s.name.toLowerCase() != 'no subject').toList();
          if (filteredSubjects.isEmpty) return const Center(child: Text('No subjects found.'));
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredSubjects.length,
            itemBuilder: (context, index) {
              final subject = filteredSubjects[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: NeoCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${subject.name} (${subject.code})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('${subject.deptName} - ${subject.batchName}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final token = context.read<AuthProvider>().token;
                          if (token != null) await provider.deleteSubject(subject.id, token);
                        },
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
