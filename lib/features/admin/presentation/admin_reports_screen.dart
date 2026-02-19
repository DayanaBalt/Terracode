import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../data/admin_repository.dart';
import '../utils/pdf_generator.dart'; 

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos los datos en tiempo real
    final allVisitsAsync = ref.watch(allCompanyVisitsProvider);
    final sellersAsync = ref.watch(sellersListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENCABEZADO
              const Text("Reportes y Análisis", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
              const Text("Métricas detalladas de rendimiento", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),

              // FILTROS DE TIEMPO 
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    _buildTab("Semana", true),
                    _buildTab("Mes", false),
                    _buildTab("Año", false),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              //  CARGA DE DATOS REALES
              allVisitsAsync.when(
                data: (visits) {
                  // --- CÁLCULOS MATEMÁTICOS ---
                  final total = visits.length;
                  final completed = visits.where((v) => v['status'] == 'completed').length;
                  final efficiency = total == 0 ? 0 : ((completed / total) * 100).toInt();

                  // Preparar datos para el Gráfico (Lunes a Domingo)
                  List<double> dailyCounts = List.filled(7, 0.0);
                  for (var v in visits) {
                    if (v['createdAt'] != null) {
                      // Intentamos obtener la fecha
                      DateTime date;
                      if (v['createdAt'] is Timestamp) {
                         date = (v['createdAt'] as Timestamp).toDate();
                      } else {
                         // Si es string por alguna razón antigua
                         continue; 
                      }
                      
                      // Ajustar día 
                      final dayIndex = date.weekday - 1;
                      if (dayIndex >= 0 && dayIndex < 7) {
                        dailyCounts[dayIndex] += 1;
                      }
                    }
                  }

                  // Calcular altura máxima del gráfico
                  double maxY = 0;
                  for (var c in dailyCounts) {
                    if (c > maxY) maxY = c;
                  }
                  if (maxY == 0) maxY = 5; // Altura mínima estética

                  return Column(
                    children: [
                      // TARJETAS DE RESUMEN
                      Row(
                        children: [
                          _buildMetricCard("Visitas Totales", "$total", Icons.bar_chart, Colors.teal),
                          const SizedBox(width: 15),
                          _buildMetricCard("Eficiencia", "$efficiency%", Icons.pie_chart, Colors.purple),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // GRÁFICO DE BARRAS
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Visitas por Día", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 20),
                            AspectRatio(
                              aspectRatio: 1.5,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: maxY + 2,
                                  barTouchData: BarTouchData(enabled: false),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (double value, TitleMeta meta) {
                                          const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10);
                                          String text = '';
                                          switch (value.toInt()) {
                                            case 0: text = 'L'; break;
                                            case 1: text = 'M'; break;
                                            case 2: text = 'M'; break;
                                            case 3: text = 'J'; break;
                                            case 4: text = 'V'; break;
                                            case 5: text = 'S'; break;
                                            case 6: text = 'D'; break;
                                          }
                                          return Container(
                                            margin: const EdgeInsets.only(top: 8),
                                            child: Text(text, style: style),
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  gridData: const FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  barGroups: List.generate(7, (index) {
                                    return BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: dailyCounts[index],
                                          color: AppTheme.primaryColor,
                                          width: 14,
                                          borderRadius: BorderRadius.circular(4),
                                          backDrawRodData: BackgroundBarChartRodData(
                                            show: true,
                                            toY: maxY + 2,
                                            color: Colors.grey[100],
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // LISTA DE RENDIMIENTO POR VENDEDOR
                      const Align(alignment: Alignment.centerLeft, child: Text("Rendimiento por Vendedor", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
                      const SizedBox(height: 10),
                      
                      sellersAsync.when(
                        data: (sellers) {
                          if (sellers.isEmpty) return const Text("No hay vendedores");
                          return Column(
                            children: sellers.map((seller) {
                              return _buildSellerRow(seller['name'] ?? 'Vendedor');
                            }).toList(),
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (_,__) => const SizedBox(),
                      ),

                      const SizedBox(height: 30),

                      // BOTÓN EXPORTAR PDF
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            // GENERAR EL PDF REAL
                            await PdfGenerator.generateAndPrint(visits);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF004D40), 
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text("Exportar Reporte PDF"),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text("Error cargando datos: $e")),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS DE DISEÑO ---
  Widget _buildTab(String text, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF004D40) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey)),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 5),
            Row(children: [Icon(Icons.arrow_upward, size: 12, color: Colors.green[700]), Text(" Activo", style: TextStyle(fontSize: 10, color: Colors.green[700]))]),
          ],
        ),
      ),
    );
  }

  Widget _buildSellerRow(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          // Barra de progreso simulada para el diseño
          SizedBox(
            width: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: const LinearProgressIndicator(value: 0.85, color: AppTheme.primaryColor, minHeight: 6),
            ),
          )
        ],
      ),
    );
  }
}