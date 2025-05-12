import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get _user => _auth.currentUser;

  // Fonction d'envoi de message
  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) {
      return; // Ne pas envoyer de message vide
    }

    if (_user == null) {
      if (kDebugMode) {
        print('L\'utilisateur n\'est pas connecté');
      }
      return; // L'utilisateur n'est pas connecté
    }

    try {
      // 🔽 Récupérer le nom depuis Firestore
      final userDoc =
          await _firestore.collection('users').doc(_user!.uid).get();
      final senderName = userDoc.data()?['name'] ?? 'Utilisateur';

      await _firestore.collection('chat').add({
        "text": _controller.text,
        "isMe": true,
        "senderId": _user!.uid,
        "senderName": senderName,
        "time": DateFormat('HH:mm').format(DateTime.now()),
        "timestamp": FieldValue.serverTimestamp(),
        "priority": 1,
      });

      if (kDebugMode) {
        print('Message envoyé avec succès');
      }

      _controller.clear();
    } catch (error) {
      if (kDebugMode) {
        print('Erreur lors de l\'envoi du message : $error');
      }
    }
  }

  // Fonction de suppression d'un message
  Future<void> _deleteMessage(String docId) async {
    await _firestore.collection('chat').doc(docId).delete();
  }

  // Fonction de construction d'un bubble de message
  Widget _buildMessageBubble(
    Map<String, dynamic> msg,
    bool isMe,
    String docId,
  ) {
    final senderName = msg['senderName'] ?? 'Utilisateur';
    return GestureDetector(
      onLongPress:
          isMe
              ? () {
                showDialog(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: const Text('Supprimer le message ?'),
                        content: const Text(
                          'Ce message sera supprimé pour tout le monde.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () {
                              _deleteMessage(docId);
                              Navigator.of(ctx).pop();
                            },
                            child: const Text(
                              'Supprimer',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                );
              }
              : null,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Text(
              senderName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.4,
              ),
              decoration: BoxDecoration(
                color: Colors.blueAccent, // Toutes les bulles sont bleues
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isMe ? 12 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    msg['text'],
                    style: TextStyle(
                      color: Colors.white, // Le texte est toujours blanc
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      (msg['timestamp'] as Timestamp)
                          .toDate()
                          .toLocal()
                          .toString()
                          .substring(11, 16),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white, // L'heure est également blanche
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chat '),
        backgroundColor: Colors.white10,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: MessageSearchDelegate());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  _firestore
                      .collection('chat')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
              builder: (ctx, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                DateTime? lastMessageDate;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (ctx, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
                    final isMe = msg['senderId'] == _user?.uid;
                    final docId = messages[index].id;
                    final messageTime =
                        (msg['timestamp'] as Timestamp).toDate();

                    // Créer un objet DateTime sans l'heure (juste la date)
                    DateTime messageDateOnly = DateTime(
                      messageTime.year,
                      messageTime.month,
                      messageTime.day,
                    );

                    // Vérifier si la date actuelle est différente de la dernière date
                    bool showDateHeader = false;

                    if (lastMessageDate == null ||
                        !isSameDay(lastMessageDate!, messageDateOnly)) {
                      // Si la date change, afficher l'en-tête de la date
                      showDateHeader = true;
                      lastMessageDate =
                          messageDateOnly; // Mettre à jour la date de dernier message
                    }

                    return Column(
                      children: [
                        // Si la date change, afficher l'en-tête avec la date complète
                        if (showDateHeader)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Text(
                                  DateFormat(
                                    'd MMMM yyyy',
                                    'fr_FR',
                                  ).format(messageTime), // Date complète
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        _buildMessageBubble(msg, isMe, docId),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 5),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: "Type a message...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  radius: 25,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Classe de recherche dans les messages
class MessageSearchDelegate extends SearchDelegate {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection('chat')
              .where('text', isGreaterThanOrEqualTo: query)
              .where('text', isLessThanOrEqualTo: '$query\uf8ff')
              .snapshots(),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!.docs;
        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (ctx, index) {
            final msg = messages[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(msg['text']),
              subtitle: Text(msg['senderName']),
              onTap: () {},
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String formatDateHeader(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(Duration(days: 1));
  final msgDate = DateTime(date.year, date.month, date.day);

  if (msgDate == today) {
    return 'Aujourd\'hui';
  } else if (msgDate == yesterday) {
    return 'Hier';
  } else {
    return DateFormat('d MMMM yyyy', 'fr_FR').format(date);
  }
}
