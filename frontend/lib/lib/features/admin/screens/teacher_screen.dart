import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/neo_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/teacher_provider.dart';
import '../../../providers/department_provider.dart';
import '../../../providers/subject_provider.dart';
import '../../../models/department.dart';
import '../../../models/subject.dart';

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({Key? key}) : super(key: key);

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<TeacherProvider>().fetchTeachers(token);
      context.read<DepartmentProvider>().fetchDepartments(token);
      context.read<SubjectProvider>().fetchSubjects(token);
    }
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final staffIdController = TextEditingController();
    int? selectedDept;
    int? selectedSubject;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final allDepts = context.read<DepartmentProvider>().departments;
          final sortedDepts = List<Department>.from(allDepts)..sort((a, b) {
            if (a.name.toLowerCase() == 'no department') return -1;
            if (b.name.toLowerCase() == 'no department') return 1;
            return a.name.compareTo(b.name);
          });

          final allSubjects = context.read<SubjectProvider>().subjects;
          final sortedSubjects = List<Subject>.from(allSubjects)..sort((a, b) {
            if (a.name.toLowerCase() == 'no subject') return -1;
            if (b.name.toLowerCase() == 'no subject') return 1;
            return a.name.compareTo(b.name);
          });

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              side: BorderSide(color: Colors.black, width: 3),
              borderRadius: BorderRadius.zero,
            ),
            title: const Text('ADD TEACHER', style: TextStyle(fontWeight: FontWeight.w900)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NeoTextField(controller: nameController, label: 'Name'),
                  const SizedBox(height: 16),
                  NeoTextField(controller: emailController, label: 'Email'),
                  const SizedBox(height: 16),
                  NeoTextField(controller: staffIdController, label: 'Staff ID', hint: 'TCH001'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Department'),
                    items: sortedDepts.map((d) => DropdownMenuItem<int>(value: d.id, child: Text(d.name))).toList(),
                    onChanged: (v) => setState(() => selectedDept = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(labelText: 'Subject Taught'),
                    items: sortedSubjects.map((s) => DropdownMenuItem<int>(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (v) => setState(() => selectedSubject = v),
                  ),
                ],
              ),
            ),
            actions: [
              NeoButton(onPressed: () => Navigator.pop(context), text: 'CANCEL', backgroundColor: Colors.white, textColor: Colors.black),
              NeoButton(
                onPressed: () async {
                  final token = context.read<AuthProvider>().token;
                  if (token != null && selectedDept != null && selectedSubject != null) {
                    final success = await context.read<TeacherProvider>().addTeacher({
                      'name': nameController.text,
                      'email': emailController.text,
                      'staff_id': staffIdController.text,
                      'dept_id': selectedDept,
                      'subject_id': selectedSubject,
                    }, token);
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
      title: 'Teachers',
      actions: [
        IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh)),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: Consumer<TeacherProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.teachers.isEmpty) return const Center(child: Text('No teachers found.'));
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.teachers.length,
            itemBuilder: (context, index) {
              final teacher = provider.teachers[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: NeoCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(teacher.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                            Text('ID: ${teacher.staffId} | ${teacher.email}'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('${teacher.deptName} - ${teacher.subjectName}'.toUpperCase(), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 10)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final token = context.read<AuthProvider>().token;
                          if (token != null) await provider.deleteTeacher(teacher.id, token);
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
