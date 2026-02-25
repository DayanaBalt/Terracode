import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_theme.dart';
import '../data/visits_repository.dart';

class SellerMessagesScreen extends ConsumerStatefulWidget {
  const SellerMessagesScreen({super.key});

  @override
  ConsumerState<SellerMessagesScreen> createState() => _SellerMessagesScreenState();
}

class _SellerMessagesScreenState extends ConsumerState<SellerMessagesScreen> {
  final user = FirebaseAuth.instance.currentUser;
  List<dynamic> _readMessages = [];

  @override
  void initState() {
    super.initState();
    _fetchReadMessages();
  }

  // Obtenemos la lista de mensajes que este usuario ya leyó
  Future<void> _fetchReadMessages() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (mounted) {
      setState(() {
        _readMessages = doc.data()?['read_messages'] ?? [];
      });
    }
  }

  // Guardamos un mensaje en su lista personal de leídos
  Future<void> _markAsRead(String messageId) async {
    if (user == null || _readMessages.contains(messageId)) return;
    
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'read_messages': FieldValue.arrayUnion([messageId])
    });
    
    if (mounted) {
      setState(() {
        _readMessages.add(messageId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const Scaffold(body: Center(child: Text("Error de sesión")));

    final messagesAsync = ref.watch(globalMessagesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Bandeja de Mensajes", style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: messagesAsync.when(
        data: (messages) {
          if (messages.isEmpty) return const Center(child: Text("No hay mensajes del administrador."));

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final String messageId = msg['id'];
              
              // Verificamos si este ID está en la lista de leídos del usuario
              final isUnread = !_readMessages.contains(messageId);

              // Si es nuevo, lo marcamos como leído en el momento que aparece en pantalla
              if (isUnread) {
                _markAsRead(messageId);
              }

              String timeAgo = "Hace un momento";
              if (msg['createdAt'] != null) {
                final date = (msg['createdAt'] as Timestamp).toDate();
                timeAgo = "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border(left: BorderSide(color: isUnread ? Colors.red : AppTheme.primaryColor, width: 4)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: CircleAvatar(
                    backgroundColor: isUnread ? Colors.red[50] : const Color(0xFFE0F2F1),
                    child: Icon(
                      isUnread ? Icons.mark_email_unread : Icons.drafts,
                      color: isUnread ? Colors.red : AppTheme.primaryColor
                    ),
                  ),
                  title: Text(msg['title'] ?? 'Sin título', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(msg['body'] ?? ''),
                      const SizedBox(height: 10),
                      Text(timeAgo, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text("Error: $e")),
      ),
    );
  }
}