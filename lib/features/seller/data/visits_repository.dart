// El archivo que lee la colección(visits) Este código busca solo las visitas donde el sellerId coincida con el usuario conectado.

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class VisitsRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage = FirebaseStorage.instance; 
  VisitsRepository(this._firestore);

  // Subir foto y obtener el link de descarga
  Future<String?> uploadVisitPhoto(String visitId, File photo) async {
    try {
      final ref = _storage.ref().child('visits_photos').child(visitId).child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      // Subimos el archivo
      await ref.putFile(photo);
      
      // Pedimos el link público para guardarlo en la base de datos
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error subiendo foto: $e");
      return null;
    }
  }

  // Iniciar Visita (Marca la hora del servidor)
  Future<void> startVisit(String visitId) async {
    await _firestore.collection('visits').doc(visitId).update({
      'status': 'in_progress', 
      'startTime': FieldValue.serverTimestamp(), 
    });
  }

  // Finalizar Visita
Future<void> completeVisit(String visitId, String notes, String? photoUrl) async {
    await _firestore.collection('visits').doc(visitId).update({
      'status': 'completed',
      'endTime': FieldValue.serverTimestamp(),
      'notes': notes,
      'photoUrl': photoUrl, // link de la foto
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

final sellerNavIndexProvider = StateProvider<int>((ref) => 0); 
final activeVisitIdProvider = StateProvider<String?>((ref) => null);

// TABLERO DE MENSAJES GLOBALES 
final globalMessagesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('global_messages')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList());
});

// MENSAJES NO LEÍDOS 
final unreadNotificationsProvider = StreamProvider.family<int, String>((ref, userId) {
  // lista de mensajes que el usuario YA leyó
  return FirebaseFirestore.instance.collection('users').doc(userId).snapshots().asyncMap((userDoc) async {
    final userData = userDoc.data() ?? {};
    final List<dynamic> readMessages = userData['read_messages'] ?? [];

    final messagesSnapshot = await FirebaseFirestore.instance.collection('global_messages').get();
    
    int unreadCount = 0;
    for (var doc in messagesSnapshot.docs) {
      if (!readMessages.contains(doc.id)) {
        unreadCount++;
      }
    }
    return unreadCount;
  });
});