import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/teacher_provider.dart';
import '../../../core/widgets/neo_widgets.dart';
import '../../../models/exam.dart';

class TeacherHallSeatsScreen extends StatefulWidget {
  final int dayId;
  final int hallId;
  const TeacherHallSeatsScreen({Key? key, required this.dayId, required this.hallId}) : super(key: key);

  @override
  State<TeacherHallSeatsScreen> createState() => _TeacherHallSeatsScreenState();
}

class _TeacherHallSeatsScreenState extends State<TeacherHallSeatsScreen> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  void _refreshData() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<TeacherProvider>().fetchHallSeats(widget.dayId, widget.hallId, token);
    }
  }

  void _showReportDialog(SeatAllocation allocation) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 3),
          borderRadius: BorderRadius.zero,
        ),
        title: Text('REPORT ${allocation.student?.name?.toUpperCase() ?? 'STUDENT'}', style: const TextStyle(fontWeight: FontWeight.w900)),
        content: NeoTextField(
          controller: reasonController,
          label: 'Reason for Report',
          hint: 'e.g., Found notes, talking, etc.',
        ),
        actions: [
          NeoButton(onPressed: () => Navigator.pop(context), text: 'CANCEL', backgroundColor: Colors.white, textColor: Colors.black),
          NeoButton(
            onPressed: () async {
              final token = context.read<AuthProvider>().token;
              if (token != null && reasonController.text.isNotEmpty) {
                final success = await context.read<TeacherProvider>().reportMalpractice(
                  allocation.studentId,
                  widget.dayId,
                  reasonController.text,
                  token,
                );
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? 'Report submitted successfully.' : 'Failed to submit report.')),
                  );
                }
              }
            },
            text: 'SUBMIT REPORT',
          ),
        ],
      ),
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
            onPressed: () {
              Navigator.pop(context);
              _showReportDialog(allocation);
            },
            text: 'REPORT MALPRACTICE',
            backgroundColor: Colors.orange,
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HALL SEATING CHART', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh))],
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.hallSeats.isEmpty) return const Center(child: Text('No allocations found for this hall.'));

          final firstAlloc = provider.hallSeats.first;
          final hall = firstAlloc.hall;
          if (hall == null) return const Center(child: Text('Hall data missing.'));

          return Scrollbar(
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
                      _buildGrid(provider.hallSeats, hall.rows, hall.cols),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegend() {
    return const Wrap(
      spacing: 24,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _LegendItem(color: Colors.white, label: 'Empty'),
        _LegendItem(color: Colors.green, label: 'Occupied'),
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

  Widget _buildGrid(List<SeatAllocation> allocations, int rows, int cols) {
    return Column(
      children: List.generate(rows, (rowIdx) {
        final row = rowIdx + 1;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(cols, (colIdx) {
            final col = colIdx + 1;
            final benchAllocations = allocations.where((a) => a.benchRow == row && a.benchCol == col).toList();

            return Container(
              margin: const EdgeInsets.all(8),
              width: 100,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: neoShadowSm,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'R$row C$col',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: ['L', 'M', 'R'].map((pos) {
                      final allocation = benchAllocations.firstWhere((a) => a.seatPosition == pos, orElse: () => SeatAllocation(id: 0, studentId: 0, hallId: 0, examDayId: 0, benchRow: 0, benchCol: 0, seatPosition: ''));
                      final isOccupied = allocation.id != 0;
                      
                      return GestureDetector(
                        onTap: isOccupied ? () => _showStudentDetails(allocation) : null,
                        child: Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: isOccupied ? Colors.green : Colors.white,
                            border: Border.all(color: Colors.black, width: 1),
                            shape: BoxShape.rectangle,
                          ),
                          child: Center(
                            child: Text(
                              pos,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isOccupied ? Colors.white : Colors.black,
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
