import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/neo_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/student_provider.dart';
import '../../../providers/department_provider.dart';
import '../../../providers/batch_provider.dart';
import '../../../models/student.dart';
import '../../../models/malpractice.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({Key? key}) : super(key: key);

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  String _sortBy = 'reg_no'; // 'reg_no' or 'roll_no'

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<StudentProvider>().fetchStudents(token);
      context.read<DepartmentProvider>().fetchDepartments(token);
      context.read<BatchProvider>().fetchBatches(token);
    }
  }

  List<Student> _getSortedStudents(List<Student> students) {
    List<Student> sorted = List.from(students);
    if (_sortBy == 'reg_no') {
      sorted.sort((a, b) => a.regNo.compareTo(b.regNo));
    } else {
      sorted.sort((a, b) => a.rollNo.compareTo(b.rollNo));
    }
    return sorted;
  }
  
  void _showHistoryDialog(Student student) {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<StudentProvider>().fetchMalpracticeHistory(student.id, token);
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 3),
          borderRadius: BorderRadius.zero,
        ),
        title: Text('HISTORY FOR ${student.name.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w900)),
        content: SizedBox(
          width: 500,
          child: Consumer<StudentProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) return const Center(child: CircularProgressIndicator());
              if (provider.malpracticeHistory.isEmpty) return const Center(child: Text('No history found.'));
              
              return ListView.builder(
                shrinkWrap: true,
                itemCount: provider.malpracticeHistory.length,
                itemBuilder: (context, index) {
                  final log = provider.malpracticeHistory[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: NeoCard(
                      padding: 8,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(log.reason, style: const TextStyle(fontWeight: FontWeight.w900)),
                                Text(
                                  '${log.examDay?.session?.name ?? 'Exam'} on ${DateFormat('MMM d, yyyy').format(DateTime.parse(log.createdAt))}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('DELETE LOG?'),
                                  content: const Text('Are you sure you want to remove this malpractice record?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('DELETE')),
                                  ],
                                ),
                              );
                              if (confirm == true && mounted) {
                                final token = context.read<AuthProvider>().token;
                                if (token != null) {
                                  await provider.deleteMalpractice(log.id, token);
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [NeoButton(onPressed: () => Navigator.pop(context), text: 'CLOSE', backgroundColor: Colors.white, textColor: Colors.black)],
      ),
    );
  }

  void _showAddEditDialog([Student? student]) {
    final nameController = TextEditingController(text: student?.name);
    final emailController = TextEditingController(text: student?.email);
    final regNoController = TextEditingController(text: student?.regNo);
    final rollNoController = TextEditingController(text: student?.rollNo);
    final dobController = TextEditingController(text: student?.dob);
    int? selectedDeptId = student?.deptId;
    int? selectedBatchId = student?.batchId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final depts = context.read<DepartmentProvider>().departments
                .where((d) => d.name.toLowerCase() != 'no department').toList();
            final batches = context.read<BatchProvider>().batches
                .where((b) => b.name.toLowerCase() != 'no batch' && (selectedDeptId == null || b.deptId == selectedDeptId)).toList();
            
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.black, width: 3), borderRadius: BorderRadius.zero),
              title: Text(student == null ? 'ADD STUDENT' : 'EDIT STUDENT', style: const TextStyle(fontWeight: FontWeight.w900)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NeoTextField(controller: nameController, label: 'Full Name', hint: 'Alex Johnson'),
                    const SizedBox(height: 16),
                    NeoTextField(controller: emailController, label: 'Email Address', hint: 'alex@college.edu'),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final initialDate = (dobController.text.isNotEmpty) 
                            ? DateTime.tryParse(dobController.text) ?? DateTime(2005)
                            : DateTime(2005);
                        final date = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: DateTime(1980),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            dobController.text = DateFormat('yyyy-MM-dd').format(date);
                          });
                        }
                      },
                      child: IgnorePointer(
                        child: NeoTextField(
                          controller: dobController, 
                          label: 'Date of Birth', 
                          hint: 'YYYY-MM-DD',
                          suffixIcon: const Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    NeoTextField(controller: regNoController, label: 'Register Number', hint: 'REG12345'),
                    const SizedBox(height: 16),
                    NeoTextField(controller: rollNoController, label: 'Roll Number', hint: '42'),
                    const SizedBox(height: 16),
                    
                    // Department Dropdown
                    DropdownButtonFormField<int>(
                      value: selectedDeptId,
                      decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
                      items: depts.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedDeptId = val;
                          selectedBatchId = null; // Reset batch when dept changes
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Batch Dropdown
                    DropdownButtonFormField<int>(
                      value: selectedBatchId,
                      decoration: const InputDecoration(labelText: 'Batch', border: OutlineInputBorder()),
                      items: batches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                      onChanged: (val) => setState(() => selectedBatchId = val),
                    ),
                  ],
                ),
              ),
              actions: [
                NeoButton(onPressed: () => Navigator.pop(context), text: 'CANCEL', backgroundColor: Colors.white, textColor: Colors.black),
                NeoButton(
                  onPressed: () async {
                    if (selectedDeptId == null || selectedBatchId == null || dobController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                      return;
                    }

                    final token = context.read<AuthProvider>().token;
                    if (token == null) return;

                    final data = {
                      'name': nameController.text,
                      'email': emailController.text,
                      'dob': dobController.text,
                      'reg_no': regNoController.text,
                      'roll_no': rollNoController.text,
                      'dept_id': selectedDeptId,
                      'batch_id': selectedBatchId,
                    };

                    bool success;
                    if (student == null) {
                      success = await context.read<StudentProvider>().addStudent(data, token);
                    } else {
                      success = await context.read<StudentProvider>().updateStudent(student.id, data, token);
                    }

                    if (success && mounted) {
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to save student')));
                    }
                  },
                  text: 'SAVE',
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  Future<void> _handleBulkUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final token = context.read<AuthProvider>().token;
      if (token == null) return;

      final success = await context.read<StudentProvider>().bulkUpload(
        result.files.single.bytes!.toList(),
        result.files.single.name,
        token,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bulk upload successful')));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bulk upload failed')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Students',
      actions: [
        IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh)),
      ],
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'bulk',
            onPressed: _handleBulkUpload,
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(side: BorderSide(color: Colors.black, width: 3)),
            child: const Icon(Icons.upload_file, color: Colors.black),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => _showAddEditDialog(),
            backgroundColor: Colors.black,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      child: Consumer<StudentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.students.isEmpty) return const Center(child: Text('No students found.'));
          
          final sortedStudents = _getSortedStudents(provider.students);
          
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Text('SORT BY:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                    const SizedBox(width: 8),
                    NeoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      onPressed: () => setState(() => _sortBy = 'reg_no'),
                      text: 'REG NO',
                      backgroundColor: _sortBy == 'reg_no' ? Colors.black : Colors.white,
                      textColor: _sortBy == 'reg_no' ? Colors.white : Colors.black,
                    ),
                    const SizedBox(width: 8),
                    NeoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      onPressed: () => setState(() => _sortBy = 'roll_no'),
                      text: 'ROLL NO',
                      backgroundColor: _sortBy == 'roll_no' ? Colors.black : Colors.white,
                      textColor: _sortBy == 'roll_no' ? Colors.white : Colors.black,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedStudents.length,
                  itemBuilder: (context, index) {
                    final student = sortedStudents[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: NeoCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(student.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                                  Text('REG: ${student.regNo} | ROLL: ${student.rollNo}'.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('DOB: ${student.dob} | ${student.deptName}'.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text('BATCH: ${student.batchName}'.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            IconButton(onPressed: () => _showAddEditDialog(student), icon: const Icon(Icons.edit)),
                            IconButton(
                              onPressed: () => _showHistoryDialog(student),
                              icon: const Icon(Icons.history, color: Colors.blue),
                            ),
                            IconButton(
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('DELETE STUDENT?'),
                                    content: Text('Delete ${student.name}?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
                                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('DELETE')),
                                    ],
                                  ),
                                );
                                if (confirm == true && mounted) {
                                  final token = context.read<AuthProvider>().token;
                                  if (token != null) context.read<StudentProvider>().deleteStudent(student.id, token);
                                }
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
