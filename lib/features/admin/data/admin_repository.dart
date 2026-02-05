import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//  Provider para obtener la lista de vendedores
final sellersListProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'seller') // Solo queremos vendedores
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
});

// clase que contiene la función para guardar la visita
class AdminRepository {
  final FirebaseFirestore _firestore;
  AdminRepository(this._firestore);

  Future<void> createVisit({
    required String sellerId,
    required String clientName,
    required String address,
    required bool isUrgent,
 }) async {
    // Guarda en la colección 'visits'
    await _firestore.collection('visits').add({
      'sellerId': sellerId, // Esto enlaza la ruta con el vendedor específico
      'clientName': clientName,
      'address': address,
      'status': 'pending',
      'isUrgent': isUrgent,
      'date': DateTime.now().toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

// PROVIDER Para poder usar la clase anterior en las pantallas
final adminRepositoryProvider = Provider((ref) => AdminRepository(FirebaseFirestore.instance));