import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

class PdfGenerator {
  static Future<void> generateAndPrint(List<Map<String, dynamic>> visits) async {
    final doc = pw.Document();
    
    // Calculamos métricas
    final total = visits.length;
    final completed = visits.where((v) => v['status'] == 'completed').length;
    
    // Suma segura de puntos
    final points = visits.fold<int>(0, (sum, v) {
      final p = v['points'];
      return sum + (p is int ? p : 0);
    });
    
    final font = await PdfGoogleFonts.nunitoExtraLight();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font),
        build: (pw.Context context) {
          return [
            // ENCABEZADO
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("TerraCode", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text("Reporte Semanal", style: const pw.TextStyle(fontSize: 18, color: PdfColors.grey)),
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),

            //  RESUMEN
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(10),
                color: PdfColors.grey100,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildPdfStat("Total Visitas", "$total"),
                  _buildPdfStat("Completadas", "$completed"),
                  _buildPdfStat("Puntos", "$points"),
                ],
              ),
            ),

            pw.SizedBox(height: 30),

            // TABLA
            pw.Text("Detalle de Actividad", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            
            pw.TableHelper.fromTextArray(
              context: context,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.teal),
              rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
              data: <List<dynamic>>[
                ['Fecha', 'Cliente', 'Estado', 'Puntos'],
                ...visits.map((visit) {
                  String date = "---";
                  if (visit['createdAt'] != null) {
                    try {
                       date = "Registrado"; 
                    } catch (e) { date = "---"; }
                  }
                  
                  return [
                    date,
                    visit['clientName'] ?? 'Desconocido',
                    visit['status'] == 'completed' ? 'Completado' : 'Pendiente',
                    (visit['points'] ?? 0).toString(),
                  ];
                }).toList(),
              ],
            ),
            
            pw.SizedBox(height: 20),
            pw.Footer(
              leading: pw.Text("Generado el ${DateFormat('yyyy-MM-dd').format(DateTime.now())}"),
              trailing: pw.Text("TerraCode App"),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  static pw.Widget _buildPdfStat(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.teal)),
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ],
    );
  }
}