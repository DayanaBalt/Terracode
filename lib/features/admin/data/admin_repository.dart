import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepository(this._firestore);

  //  Crear una nueva visita
  Future<void> createVisit({
    required String sellerId,
    required String clientName,
    required String address,
    required bool isUrgent,
    required double lat,
    required double lng,
    required String phone,
    required String schedule,
  }) async {
    await _firestore.collection('visits').add({
      'sellerId': sellerId,
      'clientName': clientName,
      'address': address,
      'isUrgent': isUrgent,
      'status': 'pending',
      'date': DateTime.now().toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
      'location': {'lat': lat, 'lng': lng},
      'points': 0, 
      'phone': phone,
      'schedule': schedule,
    });
  }

 // ENVIAR MENSAJE GLOBAL A TODOS LOS VENDEDORES 
  Future<void> sendGlobalNotification(String title, String message) async {
    //  Buscamos a todos los usuarios que sean vendedores
    final sellersSnapshot = await _firestore.collection('users').where('role', isEqualTo: 'seller').get();
    final batch = _firestore.batch();

    for (var doc in sellersSnapshot.docs) {
      final newNotifRef = _firestore.collection('notifications').doc();
      batch.set(newNotifRef, {
        'userId': doc.id, 
        'title': title,
        'body': message,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    //  Ejecutamos el guardado masivo
    await batch.commit();
  }

  // Asignar puntos a una visita (Calificar)
  Future<void> assignPointsToVisit(String visitId, int points) async {
    await _firestore.collection('visits').doc(visitId).update({
      'points': points,
      'pointsAssignedAt': FieldValue.serverTimestamp(),
    });
  }

  //  Obtener lista de vendedores (usuarios con rol 'seller')
  Stream<List<Map<String, dynamic>>> getSellers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'seller')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['uid'] = doc.id;
              return data;
            }).toList());
  }
}

// PROVEEDORES
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(FirebaseFirestore.instance);
});

final sellersListProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).getSellers();
});

// Antena Global para el Dashboard
final allCompanyVisitsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('visits')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList());
});

//  Trae las visitas de UN vendedor específico (por ID)
final sellerVisitsProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, sellerId) {
  return FirebaseFirestore.instance
      .collection('visits')
      .where('sellerId', isEqualTo: sellerId)
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList());
});