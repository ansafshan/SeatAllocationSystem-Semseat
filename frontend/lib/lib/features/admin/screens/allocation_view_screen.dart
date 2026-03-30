import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../../../core/widgets/neo_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/hall_provider.dart';
import '../../../models/hall.dart';
import '../../../models/exam.dart';

class AllocationViewScreen extends StatefulWidget {
  final int dayId;
  final Hall hall;

  const AllocationViewScreen({
    Key? key,
    required this.dayId,
    required this.hall,
  }) : super(key: key);

  @override
  State<AllocationViewScreen> createState() => _AllocationViewScreenState();
}

class _AllocationViewScreenState extends State<AllocationViewScreen> {
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<ExamProvider>().fetchAllocations(widget.dayId, token);
      context.read<HallProvider>().fetchDisabledBenches(widget.hall.id, token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Allocation: ${widget.hall.name}',
      actions: [
        IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh)),
        IconButton(onPressed: () => _showDeleteAllocationDialog(), icon: const Icon(Icons.delete_forever, color: Colors.red)),
      ],
      child: Scrollbar(
        controller: _verticalController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _verticalController,
          padding: const EdgeInsets.all(24.0),
          child: Scrollbar(
            controller: _horizontalController,
            thumbVisibility: true,
            notificationPredicate: (notif) => notif.depth == 1,
            child: SingleChildScrollView(
              controller: _horizontalController,
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  _buildLegend(),
                  const SizedBox(height: 32),
                  _buildStage(),
                  const SizedBox(height: 32),
                  _buildGrid(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteAllocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 3),
          borderRadius: BorderRadius.zero,
        ),
        title: const Text('DELETE ALLOCATIONS', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to delete all allocations for this exam day? This action cannot be undone.'),
        actions: [
          NeoButton(onPressed: () => Navigator.pop(context), text: 'CANCEL', backgroundColor: Colors.white, textColor: Colors.black),
          NeoButton(
            onPressed: () async {
              final token = context.read<AuthProvider>().token;
              if (token != null) {
                final result = await context.read<ExamProvider>().deleteAllocations(widget.dayId, token);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? (result['success'] ? 'ALLOCATIONS CLEARED' : 'FAILED TO CLEAR')),
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

  Widget _buildLegend() {
    return const Wrap(
      spacing: 24,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _LegendItem(color: Colors.white, label: 'Available'),
        _LegendItem(color: Colors.green, label: 'Occupied'),
        _LegendItem(color: Color(0xFF424242), label: 'Disabled'),
      ],
    );
  }

  Widget _buildStage() {
    return Column(
      children: [
        Container(height: 5, width: 200, color: Colors.black),
        const SizedBox(height: 4),
        const Text(
          'STAGE / FRONT',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 4),
        )
      ],
    );
  }

  Widget _buildGrid() {
    return Consumer2<ExamProvider, HallProvider>(
      builder: (context, examProv, hallProv, _) {
        if (examProv.isLoading || hallProv.isLoading) return const Center(child: CircularProgressIndicator());

        final allocations = examProv.allocations.where((a) => a.hallId == widget.hall.id).toList();

        return Column(
          children: List.generate(widget.hall.rows, (rowIdx) {
            final row = rowIdx + 1;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.hall.cols, (colIdx) {
                final col = colIdx + 1;
                final isDisabled = hallProv.disabledBenches.any((b) => b.row == row && b.col == col);
                
                final benchAllocations = allocations.where((a) => a.benchRow == row && a.benchCol == col).toList();

                return Container(
                  margin: const EdgeInsets.all(8),
                  width: 100,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDisabled ? const Color(0xFF424242) : Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: !isDisabled ? neoShadowSm : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'R$row C$col',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDisabled ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: ['L', 'M', 'R'].map((pos) {
                          final allocation = benchAllocations.firstWhereOrNull((a) => a.seatPosition == pos);
                          final isOccupied = allocation != null;
                          
                          return GestureDetector(
                            onTap: isOccupied ? () => _showStudentDetails(allocation) : null,
                            child: Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: isOccupied ? Colors.green : (isDisabled ? Colors.grey : Colors.white),
                                border: Border.all(
                                  color: isDisabled ? Colors.white24 : Colors.black, 
                                  width: 1
                                ),
                                shape: BoxShape.rectangle,
                              ),
                              child: Center(
                                child: Text(
                                  pos,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: isOccupied || isDisabled ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }),
            );
          }),
        );
      },
    );
  }

  void _showStudentDetails(SeatAllocation allocation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 3),
          borderRadius: BorderRadius.zero,
        ),
        title: Row(
          children: [
            const Icon(Icons.person, color: Colors.black, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                allocation.student?.name?.toUpperCase() ?? 'STUDENT DETAILS',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('REG NO', allocation.student?.regNo ?? '-'),
            _detailRow('ROLL NO', allocation.student?.rollNo ?? '-'),
            _detailRow('DEPT', allocation.student?.deptName ?? '-'),
            _detailRow('BATCH', allocation.student?.batchName ?? '-'),
            const Divider(color: Colors.black, thickness: 2),
            _detailRow('SEAT', 'R${allocation.benchRow} C${allocation.benchCol} [${allocation.seatPosition}]'),
          ],
        ),
        actions: [
          NeoButton(
            onPressed: () => Navigator.pop(context),
            text: 'CLOSE',
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black, width: 2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
