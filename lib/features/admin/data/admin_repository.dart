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

 //  ENVIAR AL TABLÓN DE ANUNCIOS GLOBAL 
  Future<void> sendGlobalNotification(String title, String message) async {
    await _firestore.collection('global_messages').add({
      'title': title,
      'body': message,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  //  BLOQUEAR O DESBLOQUEAR USUARIOS 
  Future<void> toggleUserAccess(String userId, bool currentStatus) async {
    await _firestore.collection('users').doc(userId).update({
      'isActive': !currentStatus,
    });
  }

  // Cambiar el rol de un usuario
  Future<void> updateUserRole(String userId, String newRole) async {
    await _firestore.collection('users').doc(userId).update({'role': newRole});
  }

  // Obtener a TODOS los usuarios
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) => 
      snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList()
    );
  }

  // Asignar puntos a una visita (Calificar)
  Future<void> assignPointsToVisit(String visitId, int points) async {
    await _firestore.collection('visits').doc(visitId).update({
      'points': points,
      'pointsAssignedAt': FieldValue.serverTimestamp(),
    });
  }

  //  Obtener lista de vendedores
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

final allUsersListProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).getAllUsers();
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

