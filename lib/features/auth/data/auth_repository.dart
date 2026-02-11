// Este código usa Riverpod para crear un "servicio" que pueda ser llamado desde cualquier pantalla.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Este provider nos permite acceder al repositorio desde la UI
final authRepositoryProvider = Provider((ref) => AuthRepository(
  FirebaseAuth.instance,
  FirebaseFirestore.instance,
));

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository(this._auth, this._firestore);

 // INICIAR SESIÓN
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // REGISTRAR USUARIO
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    // Crear usuario en el sistema de Autenticación
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Guardar nombre, teléfono y rol en la Base de Datos
    if (userCredential.user != null) {
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'name': name,
        'phone': phone,
        'role': 'seller', // Por defecto todos son vendedores al registrarse
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
  }

  // CERRAR SESIÓN
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Funcion para obtener el rol
  Future<String?> getUserRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data()?['role'] as String?;
      }
    }
    return null;
  }
}

//Datos del usuario actual (Admin o Vendedor)
  final currentUserProfileProvider = StreamProvider<Map<String, dynamic>?>((ref) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(null);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) => doc.data());
  });