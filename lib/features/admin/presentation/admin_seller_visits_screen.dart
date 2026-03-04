import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../../../../core/constants/app_theme.dart';
import 'admin_grade_visit_screen.dart';

class AdminSellerVisitsScreen extends StatelessWidget {
  final String sellerId;
  final String sellerName;

  const AdminSellerVisitsScreen({super.key, required this.sellerId, required this.sellerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), 
      appBar: AppBar(
        title: Text("Visitas de $sellerName", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Lógica de Firestore 
        stream: FirebaseFirestore.instance
            .collection('visits')
            .where('sellerId', isEqualTo: sellerId)
            .where('status', isEqualTo: 'completed')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          
          final visits = snapshot.data!.docs;

          if (visits.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 15),
                  Text("No hay visitas completadas para calificar", style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                ],
              ),
            );
          }

          //  LISTA DE VISITAS 
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: visits.length,
            itemBuilder: (context, index) {
              final visitDoc = visits[index];
              final visitData = visitDoc.data() as Map<String, dynamic>;
              visitData['id'] = visitDoc.id; 
              
              final int points = visitData['points'] ?? 0;
              final bool isGraded = points > 0;

              // Manejo de Fecha 
              String dateStr = "Fecha no registrada";
              if (visitData['endTime'] != null && visitData['endTime'] is Timestamp) {
                 dateStr = DateFormat('dd MMM yyyy, hh:mm a').format((visitData['endTime'] as Timestamp).toDate());
              } else if (visitData['createdAt'] != null && visitData['createdAt'] is Timestamp) {
                 dateStr = DateFormat('dd MMM yyyy, hh:mm a').format((visitData['createdAt'] as Timestamp).toDate());
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04), 
                      blurRadius: 10, 
                      offset: const Offset(0, 4)
                    )
                  ],
                  border: Border.all(
                    color: isGraded ? Colors.transparent : Colors.orange.withOpacity(0.4),
                    width: 1
                  )
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminGradeVisitScreen(visitData: visitData),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ICONO IZQUIERDO
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isGraded ? Colors.amber.withOpacity(0.15) : Colors.orange.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isGraded ? Icons.star_rounded : Icons.pending_actions_rounded, 
                              color: isGraded ? Colors.amber[700] : Colors.orange,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),

                          //  TEXTOS CENTRALES 
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  visitData['clientName'] ?? 'Cliente Desconocido', 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.darkText),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey[500]),
                                    const SizedBox(width: 5),
                                    Text(dateStr, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                //  ETIQUETA DE ESTADO 
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isGraded ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Text(
                                    isGraded ? "Calificada: $points pts" : "Pendiente de calificar",
                                    style: TextStyle(
                                      color: isGraded ? Colors.green[700] : Colors.orange[800], 
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),

                          //  FLECHA DERECHA 
                          const Padding(
                            padding: EdgeInsets.only(top: 22),
                            child: Icon(Icons.chevron_right_rounded, color: Colors.grey),
                          )
                        ],
                      ),
                    ),
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