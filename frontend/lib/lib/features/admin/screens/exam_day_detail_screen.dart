import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import '../../../core/widgets/neo_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/subject_provider.dart';
import '../../../providers/hall_provider.dart';
import '../../../providers/teacher_provider.dart';
import '../../../models/subject.dart';
import '../../../models/teacher.dart';
import '../../../services/pdf_service.dart';
import '../../../models/hall.dart';
import 'hall_layout_screen.dart';
import '../../../models/exam.dart';

class HallAllocationGrid extends StatefulWidget {
  final Hall hall;
  final List<SeatAllocation> allocations;
  final Function(SeatAllocation) onShowStudentDetails;

  const HallAllocationGrid({
    Key? key,
    required this.hall,
    required this.allocations,
    required this.onShowStudentDetails,
  }) : super(key: key);

  @override
  State<HallAllocationGrid> createState() => _HallAllocationGridState();
}

class _HallAllocationGridState extends State<HallAllocationGrid> {
  final ScrollController _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      controller: _horizontalController,
      notificationPredicate: (notif) => notif.depth == 1,
      child: SingleChildScrollView(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              _buildGridLegend(),
              const SizedBox(height: 24),
              _buildStage(),
              const SizedBox(height: 24),
              Column(
                children: List.generate(widget.hall.rows, (rowIdx) {
                  final row = rowIdx + 1;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.hall.cols, (colIdx) {
                      final col = colIdx + 1;
                      final benchAllocations = widget.allocations
                          .where((a) => a.benchRow == row && a.benchCol == col)
                          .toList();

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
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: ['L', 'M', 'R'].map((pos) {
                                final allocation = benchAllocations
                                    .firstWhereOrNull(
                                      (a) => a.seatPosition == pos,
                                    );
                                final isOccupied = allocation != null;

                                return GestureDetector(
                                  onTap: isOccupied
                                      ? () => widget.onShowStudentDetails(allocation)
                                      : null,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isOccupied
                                          ? Colors.green
                                          : Colors.white,
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        pos,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: isOccupied
                                              ? Colors.white
                                              : Colors.black,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridLegend() {
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}

class ExamDayDetailScreen extends StatefulWidget {
  final int dayId;
  const ExamDayDetailScreen({Key? key, required this.dayId}) : super(key: key);

  @override
  State<ExamDayDetailScreen> createState() => _ExamDayDetailScreenState();
}

class _ExamDayDetailScreenState extends State<ExamDayDetailScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<ExamProvider>().fetchExamDay(widget.dayId, token);
      context.read<ExamProvider>().fetchDaySubjects(widget.dayId, token);
      context.read<ExamProvider>().fetchAllocations(widget.dayId, token);
      context.read<SubjectProvider>().fetchSubjects(token);
      context.read<HallProvider>().fetchHalls(token);
      context.read<TeacherProvider>().fetchTeachers(token);
    }
  }

  void _showAddSubjectDialog() {
    Subject? selectedSubject;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.black, width: 3),
            borderRadius: BorderRadius.zero,
          ),
          title: const Text(
            'ASSIGN SUBJECT',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Consumer<SubjectProvider>(
            builder: (context, subProv, _) {
              return SizedBox(
                width: 300,
                child: DropdownButtonFormField<Subject>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Select Subject',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedSubject,
                  items: subProv.subjects
                      .where((s) => s.name.toLowerCase() != 'no subject')
                      .map(
                        (s) => DropdownMenuItem(
                          value: s,
                          child: Text('${s.code} - ${s.name}'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedSubject = v),
                ),
              );
            },
          ),
          actions: [
            NeoButton(
              onPressed: () => Navigator.pop(context),
              text: 'CANCEL',
              backgroundColor: Colors.white,
              textColor: Colors.black,
            ),
            NeoButton(
              onPressed: () async {
                final token = context.read<AuthProvider>().token;
                if (token != null && selectedSubject != null) {
                  final success = await context
                      .read<ExamProvider>()
                      .addDaySubject(widget.dayId, selectedSubject!.id, token);
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
      title: 'Exam Day Details',
      actions: [
        IconButton(onPressed: _refreshData, icon: const Icon(Icons.refresh)),
      ],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SUBJECTS IN THIS SLOT',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                NeoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  onPressed: _showAddSubjectDialog,
                  text: 'ASSIGN SUBJECT',
                  icon: Icons.add,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<ExamProvider>(
              builder: (context, examProv, _) {
                if (examProv.isLoading)
                  return const Center(child: CircularProgressIndicator());
                if (examProv.daySubjects.isEmpty)
                  return const NeoCard(
                    child: Center(child: Text('No subjects assigned.')),
                  );

                return Column(
                  children: examProv.daySubjects
                      .map(
                        (ds) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: NeoCard(
                            padding: 12,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Colors.black,
                                  child: Text(
                                    ds.subject?.code ?? '???',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    ds.subject?.name.toUpperCase() ??
                                        'UNKNOWN SUBJECT',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _showDeleteSubjectDialog(ds.subjectId),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),

            const SizedBox(height: 32),
            NeoCard(
              backgroundColor: const Color(0xFFFFF9C4),
              child: Consumer<ExamProvider>(
                builder: (context, examProv, _) => Column(
                  children: [
                    const Text(
                      'ENGINE CONTROLS',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        NeoButton(
                          onPressed: examProv.daySubjects.isEmpty
                              ? null
                              : () async {
                                  final confirm =
                                      await _showRunAllocationDialog();
                                  if (confirm == true) {
                                    final token = context
                                        .read<AuthProvider>()
                                        .token;
                                    if (token != null && token.isNotEmpty) {
                                      final success = await examProv.allocate(
                                        widget.dayId,
                                        token,
                                      );
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              success
                                                  ? 'ALLOCATION COMPLETED SUCCESSFULLY!'
                                                  : 'ALLOCATION FAILED. CHECK CONSOLE.',
                                            ),
                                            backgroundColor: success
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                          text: 'RUN ENGINE',
                        ),
                        const SizedBox(width: 16),
                        NeoButton(
                          onPressed: examProv.allocations.isEmpty
                              ? null
                              : () {
                                  final day = examProv.examDays
                                      .firstWhereOrNull(
                                        (d) => d.id == widget.dayId,
                                      );
                                  if (day != null) {
                                    PdfService.generateAllocationPdf(
                                      examProv.allocations,
                                      day.session?.name ?? 'Exam',
                                      day.date,
                                      day.slot,
                                    );
                                  }
                                },
                          text: 'EXPORT PDF',
                          backgroundColor: Colors.white,
                          textColor: Colors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ALLOCATION RESULTS',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Consumer<ExamProvider>(
                  builder: (context, prov, _) {
                    final seated = prov.allocations.length;
                    // We can't know "found" without a backend change or checking subjects,
                    // but we can show the seated count clearly.
                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(width: 2),
                          ),
                          child: Text(
                            'TOTAL SEATED: $seated',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<ExamProvider>(
              builder: (context, examProv, _) {
                if (examProv.isLoading)
                  return const Center(child: CircularProgressIndicator());
                if (examProv.allocations.isEmpty)
                  return const Center(
                    child: Text('No allocations found. Run the engine above.'),
                  );

                final halls = context.watch<HallProvider>().halls;
                final allocationsByHall = groupBy(
                  examProv.allocations,
                  (a) => a.hallId,
                );
                final sessionType =
                    examProv.allocations.first.examDay?.session?.type ??
                    'series';

                return Column(
                  children: allocationsByHall.entries.map((entry) {
                    final hall = halls.firstWhereOrNull(
                      (h) => h.id == entry.key,
                    );
                    final hallName = hall?.name ?? 'Hall ${entry.key}';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 3),
                        ),
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          title: Text(
                            '${hallName.toUpperCase()} (${entry.value.length} STUDENTS)',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          children: [
                            if (hall == null)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('Hall data loading...'),
                              )
                            else ...[
                              // Invigilators View
                              _buildInvigilatorSection(
                                entry.key,
                                examProv.hallTeachers,
                              ),
                              HallAllocationGrid(
                                hall: hall,
                                allocations: entry.value,
                                onShowStudentDetails: _showStudentDetails,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteSubjectDialog(int subjectId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 3),
          borderRadius: BorderRadius.zero,
        ),
        title: const Text(
          'REMOVE SUBJECT',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Are you sure you want to remove this subject from the slot?',
        ),
        actions: [
          NeoButton(
            onPressed: () => Navigator.pop(context),
            text: 'CANCEL',
            backgroundColor: Colors.white,
            textColor: Colors.black,
          ),
          NeoButton(
            onPressed: () async {
              final token = context.read<AuthProvider>().token;
              if (token != null) {
                final result = await context
                    .read<ExamProvider>()
                    .removeDaySubject(widget.dayId, subjectId, token);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result['message'] ??
                            (result['success']
                                ? 'SUBJECT REMOVED'
                                : 'FAILED TO REMOVE'),
                      ),
                      backgroundColor: result['success']
                          ? Colors.green
                          : Colors.red,
                    ),
                  );
                }
              }
            },
            text: 'REMOVE',
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Future<bool?> _showRunAllocationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 3),
          borderRadius: BorderRadius.zero,
        ),
        title: const Text(
          'RUN ALLOCATION?',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'This will reset all existing seats for this slot and re-assign them. This cannot be undone. Continue?',
        ),
        actions: [
          NeoButton(
            onPressed: () => Navigator.pop(context, false),
            text: 'CANCEL',
            backgroundColor: Colors.white,
            textColor: Colors.black,
          ),
          NeoButton(
            onPressed: () => Navigator.pop(context, true),
            text: 'RUN',
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }

  void _removeTeacher(int teacherId) async {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      final result = await context.read<ExamProvider>().removeTeacherAssignment(
        widget.dayId,
        teacherId,
        token,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Status updated'),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  void _showAssignTeacherDialog(int hallId) {
    Teacher? selectedTeacher;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.black, width: 3),
            borderRadius: BorderRadius.zero,
          ),
          title: const Text(
            'ASSIGN TEACHER MANUALLY',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Consumer<TeacherProvider>(
            builder: (context, teacherProv, _) {
              if (teacherProv.isLoading) return const Center(child: CircularProgressIndicator());
              return SizedBox(
                width: 300,
                child: DropdownButtonFormField<Teacher>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Select Teacher',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedTeacher,
                  items: teacherProv.teachers
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.name.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedTeacher = v),
                ),
              );
            },
          ),
          actions: [
            NeoButton(
              onPressed: () => Navigator.pop(context),
              text: 'CANCEL',
              backgroundColor: Colors.white,
              textColor: Colors.black,
            ),
            NeoButton(
              onPressed: () async {
                final token = context.read<AuthProvider>().token;
                if (token != null && selectedTeacher != null) {
                  final result = await context.read<ExamProvider>().assignTeacherManually(
                    widget.dayId,
                    hallId,
                    selectedTeacher!.id,
                    token,
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message'] ?? 'Status updated'),
                        backgroundColor: result['success'] ? Colors.green : Colors.red,
                      ),
                    );
                  }
                }
              },
              text: 'ASSIGN',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvigilatorSection(
    int hallId,
    List<HallTeacherAssignment> assignments,
  ) {
    final hallTeachers = assignments.where((a) => a.hallId == hallId).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'INVIGILATORS',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              ),
              NeoButton(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                onPressed: () => _showAssignTeacherDialog(hallId),
                text: 'ASSIGN TEACHER',
                backgroundColor: Colors.white,
                textColor: Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (hallTeachers.isEmpty)
            const Text('NO TEACHERS ASSIGNED YET', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold))
          else
            ...hallTeachers.map((a) {
              final teacher = a.teacher;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.security, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${teacher?.name.toUpperCase() ?? 'UNKNOWN'} (ID: ${teacher?.staffId ?? 'N/A'})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red, size: 18),
                      onPressed: () => _removeTeacher(a.teacherId),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            }).toList(),
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
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
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
            _detailRow(
              'SEAT',
              'R${allocation.benchRow} C${allocation.benchCol} [${allocation.seatPosition}]',
            ),
          ],
        ),
        actions: [
          NeoButton(onPressed: () => Navigator.pop(context), text: 'CLOSE'),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
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
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
