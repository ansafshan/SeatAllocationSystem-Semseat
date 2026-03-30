import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/neo_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/batch_provider.dart';
import '../../../providers/department_provider.dart';

class BatchScreen extends StatefulWidget {
  const BatchScreen({Key? key}) : super(key: key);

  @override
  State<BatchScreen> createState() => _BatchScreenState();
}

class _BatchScreenState extends State<BatchScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<BatchProvider>().fetchBatches(token);
      context.read<DepartmentProvider>().fetchDepartments(token);
    }
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    int? selectedDept;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final filteredDepts = context.read<DepartmentProvider>().departments
              .where((d) => d.name.toLowerCase() != 'no department').toList();

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              side: BorderSide(color: Colors.black, width: 3),
              borderRadius: BorderRadius.zero,
            ),
            title: const Text('ADD BATCH', style: TextStyle(fontWeight: FontWeight.w900)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                NeoTextField(controller: nameController, label: 'Batch Name (e.g. 2022-26)'),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Department'),
                  items: filteredDepts.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                  onChanged: (v) => setState(() => selectedDept = v),
                ),
              ],
            ),
            actions: [
              NeoButton(onPressed: () => Navigator.pop(context), text: 'CANCEL', backgroundColor: Colors.white, textColor: Colors.black),
              NeoButton(
                onPressed: () async {
                  final token = context.read<AuthProvider>().token;
                  if (token != null && nameController.text.isNotEmpty && selectedDept != null) {
                    final success = await context.read<BatchProvider>().addBatch(
                      nameController.text,
                      selectedDept!,
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
      title: 'Batches',
      actions: [
        IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh)),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: Consumer<BatchProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          
          final filteredBatches = provider.batches.where((b) => b.name.toLowerCase() != 'no batch').toList();
          if (filteredBatches.isEmpty) return const Center(child: Text('No batches found.'));
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredBatches.length,
            itemBuilder: (context, index) {
              final batch = filteredBatches[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: NeoCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(batch.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(batch.deptName ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final token = context.read<AuthProvider>().token;
                          if (token != null) await provider.deleteBatch(batch.id, token);
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
