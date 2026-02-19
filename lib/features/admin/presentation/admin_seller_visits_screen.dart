import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'admin_grade_visit_screen.dart';

class AdminSellerVisitsScreen extends StatelessWidget {
  final String sellerId;
  final String sellerName;

  const AdminSellerVisitsScreen({super.key, required this.sellerId, required this.sellerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Visitas de $sellerName")),
      body: StreamBuilder<QuerySnapshot>(
        // Solo traemos las completadas para calificar
        stream: FirebaseFirestore.instance
            .collection('visits')
            .where('sellerId', isEqualTo: sellerId)
            .where('status', isEqualTo: 'completed')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final visits = snapshot.data!.docs;

          if (visits.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No hay visitas completadas para calificar", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: visits.length,
            itemBuilder: (context, index) {
              final visitDoc = visits[index];
              final visitData = visitDoc.data() as Map<String, dynamic>;
              visitData['id'] = visitDoc.id; 
              
              final int points = visitData['points'] ?? 0;
              final bool isGraded = points > 0;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    backgroundColor: isGraded ? Colors.amber[100] : Colors.grey[200],
                    child: Icon(Icons.star, color: isGraded ? Colors.amber[800] : Colors.grey),
                  ),
                  title: Text(visitData['clientName'] ?? 'Cliente', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    isGraded ? "Calificación: $points pts" : "Pendiente de calificar",
                    style: TextStyle(color: isGraded ? Colors.green : Colors.orange),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    // Navegar a calificar
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminGradeVisitScreen(visitData: visitData),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}