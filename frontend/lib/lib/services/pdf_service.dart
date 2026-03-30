import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/exam.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateAllocationPdf(
    List<SeatAllocation> allocations, 
    String sessionName, 
    String date, 
    String slot
  ) async {
    final pdf = pw.Document();

    // Group by hall
    Map<String, List<SeatAllocation>> hallGroups = {};
    for (var a in allocations) {
      final hName = a.hall?.name ?? 'Unknown';
      if (!hallGroups.containsKey(hName)) hallGroups[hName] = [];
      hallGroups[hName]!.add(a);
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('SEMSEAT - EXAM ALLOCATION REPORT', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Text('Session: $sessionName'),
                  pw.Text('Date: $date | Slot: $slot'),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            ...hallGroups.entries.expand((entry) {
              return [
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  color: PdfColors.black,
                  width: double.infinity,
                  child: pw.Text(
                    'HALL: ${entry.key.toUpperCase()}', 
                    style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 16)
                  ),
                ),
                pw.TableHelper.fromTextArray(
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headers: ['SEAT', 'ROLL NO', 'STUDENT NAME', 'DEPARTMENT'],
                  data: entry.value.map((a) => [
                    'R${a.benchRow} C${a.benchCol} ${a.seatPosition}',
                    a.student?.rollNo ?? '-',
                    a.student?.name ?? '-',
                    a.student?.deptName ?? '-'
                  ]).toList(),
                ),
                pw.SizedBox(height: 30),
              ];
            }).toList(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
