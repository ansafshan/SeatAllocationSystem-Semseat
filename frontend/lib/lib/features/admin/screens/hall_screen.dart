import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/neo_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/hall_provider.dart';

class HallScreen extends StatefulWidget {
  const HallScreen({Key? key}) : super(key: key);

  @override
  State<HallScreen> createState() => _HallScreenState();
}

class _HallScreenState extends State<HallScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<HallProvider>().fetchHalls(token);
    }
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final rowsController = TextEditingController();
    final colsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 3),
          borderRadius: BorderRadius.zero,
        ),
        title: const Text('ADD HALL', style: TextStyle(fontWeight: FontWeight.w900)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeoTextField(controller: nameController, label: 'Hall Name'),
              const SizedBox(height: 16),
              NeoTextField(controller: rowsController, label: 'Number of Rows'),
              const SizedBox(height: 16),
              NeoTextField(controller: colsController, label: 'Benches per Row'),
            ],
          ),
        ),
        actions: [
          NeoButton(onPressed: () => Navigator.pop(context), text: 'CANCEL', backgroundColor: Colors.white, textColor: Colors.black),
          NeoButton(
            onPressed: () async {
              final token = context.read<AuthProvider>().token;
              if (token != null && nameController.text.isNotEmpty) {
                final success = await context.read<HallProvider>().addHall(
                  nameController.text,
                  int.tryParse(rowsController.text) ?? 0,
                  int.tryParse(colsController.text) ?? 0,
                  token
                );
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
      title: 'Halls',
      actions: [
        IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh)),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      child: Consumer<HallProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.halls.isEmpty) return const Center(child: Text('No halls found.'));
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.halls.length,
            itemBuilder: (context, index) {
              final hall = provider.halls[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: NeoCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(hall.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                            Text('${hall.rows} rows x ${hall.cols} benches', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push('/admin/halls/${hall.id}/layout'),
                        icon: const Icon(Icons.grid_on),
                      ),
                      IconButton(
                        onPressed: () async {
                          final token = context.read<AuthProvider>().token;
                          if (token != null) await provider.deleteHall(hall.id, token);
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
