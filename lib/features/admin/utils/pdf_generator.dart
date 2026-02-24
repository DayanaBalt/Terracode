import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

class PdfGenerator {
static Future<void> generateAndPrint(List<Map<String, dynamic>> visits, {String reportTitle = "General"}) async {   
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
    final fontBold = await PdfGoogleFonts.nunitoBold();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: font, bold: fontBold),
        build: (pw.Context context) {
          return [
            // ENCABEZADO
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("TerraCode", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800)),
                      pw.Text("Reporte de Rendimiento", style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
                    ]
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      // MUESTRA DE QUIÉN ES EL REPORTE
                      pw.Text("Vendedor: $reportTitle", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.Text("Fecha: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}", style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
                    ]
                  )
                ],
              ),
            ),
            
            pw.SizedBox(height: 20),

            //  RESUMEN
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.teal200),
                borderRadius: pw.BorderRadius.circular(10),
                color: PdfColors.teal50,
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
              cellAlignment: pw.Alignment.centerLeft,
              data: <List<dynamic>>[
                ['Fecha y Hora', 'Cliente', 'Estado', 'Puntos'],
                ...visits.map((visit) {
                  //  FECHA REAL 
                  String date = "---";
                  if (visit['createdAt'] != null && visit['createdAt'] is Timestamp) {
                    final dt = (visit['createdAt'] as Timestamp).toDate();
                    date = DateFormat('dd/MM/yy HH:mm').format(dt);
                  } else if (visit['date'] != null) {
                    try {
                      final dt = DateTime.parse(visit['date'].toString());
                      date = DateFormat('dd/MM/yy HH:mm').format(dt);
                    } catch (_) {}
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
              leading: pw.Text("Documento de rendimiento"),
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
        pw.Text(value, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.teal800)),
        pw.SizedBox(height: 4),
        pw.Text(label, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
      ],
    );
  }
}