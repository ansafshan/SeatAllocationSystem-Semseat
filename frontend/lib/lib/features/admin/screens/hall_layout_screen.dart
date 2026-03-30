import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/neo_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/hall_provider.dart';
import '../../../models/hall.dart';

class HallLayoutScreen extends StatefulWidget {
  final int? dayId;
  final Hall hall;

  const HallLayoutScreen({
    Key? key,
    this.dayId,
    required this.hall,
  }) : super(key: key);

  @override
  State<HallLayoutScreen> createState() => _HallLayoutScreenState();
}

class _HallLayoutScreenState extends State<HallLayoutScreen> {
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
      final token = context.read<AuthProvider>().token;
      if (token != null) {
        context.read<HallProvider>().fetchDisabledBenches(widget.hall.id, token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Layout: ${widget.hall.name}',
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
                  _buildBenchGrid(),
                ],
              ),
            ),
          ),
        ),
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

  Widget _buildBenchGrid() {
    return Consumer<HallProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        
        return Column(
          children: List.generate(widget.hall.rows, (row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.hall.cols, (col) {
                final isEnabled = !provider.disabledBenches.any(
                  (b) => b.row == row + 1 && b.col == col + 1
                );
                return GestureDetector(
                  onTap: () async {
                    final token = context.read<AuthProvider>().token;
                    if (token != null) {
                      await provider.toggleDisabledBench(
                        widget.hall.id, row + 1, col + 1, token
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    width: 80,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isEnabled ? Colors.white : const Color(0xFF424242),
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: isEnabled ? neoShadowSm : [],
                    ),
                    child: Center(
                      child: Text(
                        'R${row + 1} C${col + 1}',
                        style: TextStyle(
                          color: isEnabled ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        );
      },
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
