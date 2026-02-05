// El archivo que lee la colección(visits) Este código busca solo las visitas donde el sellerId coincida con el usuario conectado.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VisitsRepository {
  final FirebaseFirestore _firestore;
  VisitsRepository(this._firestore);

  // Iniciar Visita (Marca la hora del servidor)
  Future<void> startVisit(String visitId) async {
    await _firestore.collection('visits').doc(visitId).update({
      'status': 'in_progress', // Cambia el estado
      'startTime': FieldValue.serverTimestamp(), //  LA HORA REAL DE GOOGLE
    });
  }

  // Finalizar Visita
  Future<void> completeVisit(String visitId, String notes) async {
    await _firestore.collection('visits').doc(visitId).update({
      'status': 'completed',
      'endTime': FieldValue.serverTimestamp(), // Hora 
      'notes': notes,
    });
  }
}

// PROVIDER DE ACCIONES
final visitsRepositoryProvider = Provider((ref) => VisitsRepository(FirebaseFirestore.instance));

// Provider entrega una LISTA de mapas (datos).
final userVisitsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  
  // Obtenemos el usuario actual
  final user = FirebaseAuth.instance.currentUser;
  
  // Si nadie está logueado, no devolvemos nada
  if (user == null) return Stream.value([]);

  // Conectamos con Firebase
return FirebaseFirestore.instance
      .collection('visits')
      .where('sellerId', isEqualTo: user.uid)
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
});