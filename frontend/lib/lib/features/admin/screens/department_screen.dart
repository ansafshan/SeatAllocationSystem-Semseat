import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/neo_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/department_provider.dart';

class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({Key? key}) : super(key: key);

  @override
  State<DepartmentScreen> createState() => _DepartmentScreenState();
}

class _DepartmentScreenState extends State<DepartmentScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<DepartmentProvider>().fetchDepartments(token);
    }
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 3),
          borderRadius: BorderRadius.zero,
        ),
        title: const Text('ADD DEPARTMENT', style: TextStyle(fontWeight: FontWeight.w900)),
        content: NeoTextField(controller: nameController, label: 'Department Name'),
        actions: [
          NeoButton(onPressed: () => Navigator.pop(context), text: 'CANCEL', backgroundColor: Colors.white, textColor: Colors.black),
          NeoButton(
            onPressed: () async {
              final token = context.read<AuthProvider>().token;
              if (token != null && nameController.text.isNotEmpty) {
                final success = await context.read<DepartmentProvider>().addDepartment(nameController.text, token);
                if (success && mounted) Navigator.pop(context);
              }
            },
            text: 'ADD',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Departments',
      actions: [
        IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh)),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: Consumer<DepartmentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          
          final filteredDepts = provider.departments.where((d) => d.name.toLowerCase() != 'no department').toList();
          if (filteredDepts.isEmpty) return const Center(child: Text('No departments found.'));
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredDepts.length,
            itemBuilder: (context, index) {
              final dept = filteredDepts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: NeoCard(
                  child: Row(
                    children: [
                      Expanded(child: Text(dept.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                      IconButton(
                        onPressed: () async {
                          final token = context.read<AuthProvider>().token;
                          if (token != null) await provider.deleteDepartment(dept.id, token);
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
