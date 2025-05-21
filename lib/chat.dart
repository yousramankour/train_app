import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ChatScreend extends StatefulWidget {
  static const String screenRoute = 'chat_screen';

  const ChatScreend({super.key});

  @override
  _ChatScreendState createState() => _ChatScreendState();
}

class _ChatScreendState extends State<ChatScreend> {
  final FirebaseAuth _auth =
      FirebaseAuth.instance; //var pour gere l'utilisateur from fairbase
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; //pour lire ou ecire dans la base de donner
  final TextEditingController _messageController =
      TextEditingController(); //pour controler msgtxt
  static User? _signedInUser; // l'utilisateur actuelle connect
  String? _msgText; // la var ou stoke le mesg d'envoi
  Map<String, String> userNames = {}; // UID → Nom

  @override
  //les fonction qui ce declanche a l'ouvirture de page chat
  void initState() {
    super.initState();
    _getCurrentUser();
    _loadUserNames();
  }

  // fonction pour recuperer l'utilisateur connecter(email):
  void _getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          _signedInUser = user;
        });
        print('Utilisateur connecté : ${_signedInUser!.email}');
      }
    } catch (e) {
      print('Erreur utilisateur : $e');
    }
  }

  // fonction pour stoker les noma des utilisateur
  Future<void> _loadUserNames() async {
    final usersSnapshot = await _firestore.collection('users').get();
    final Map<String, String> names = {};
    for (var doc in usersSnapshot.docs) {
      names[doc.id] = doc['name'] ?? 'Utilisateur';
    }
    setState(() {
      userNames = names;
    });
  }

  //fonction pour l'envio d'un message
  Future<void> _sendMessage() async {
    if (_msgText == null || _msgText!.trim().isEmpty || _signedInUser == null)
      return;

    try {
      await _firestore.collection('chat').add({
        'text': _msgText!.trim(),
        'senderId': _signedInUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
      setState(() {
        _msgText = '';
      });
    } catch (e) {
      print('Erreur lors de l\'envoi du message : $e');
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe) {
    final senderId = msg['senderId'] as String?;
    final senderName =
        senderId != null
            ? (userNames[senderId] ?? 'Utilisateur')
            : 'Utilisateur';
    final text = msg['text'] ?? '';
    final timestamp = msg['timestamp'] as Timestamp?;
    final timeString =
        timestamp != null ? DateFormat('HH:mm').format(timestamp.toDate()) : '';

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            senderName,
            style: const TextStyle(fontSize: 12, color: Colors.black45),
          ),
          const SizedBox(height: 5),
          Material(
            elevation: 5,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(30),
              bottomLeft: const Radius.circular(30),
              bottomRight: const Radius.circular(30),
            ),
            color:
                isMe ? const Color.fromARGB(255, 11, 111, 226) : Colors.white,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      color: isMe ? Colors.white : Colors.black,
                    ),
                  ),
                  if (timeString.isNotEmpty)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        timeString,
                        style: TextStyle(
                          fontSize: 10,
                          color: const Color.fromARGB(255, 0, 0, 0),
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
    if (_signedInUser == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 240, 245, 252),
          title: const Text('chat global'),
        ),
        body: const Center(child: Text("Utilisateur non connecté")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: const Text('chat global'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    _firestore
                        .collection('chat')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 20,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg =
                          messages[index].data() as Map<String, dynamic>;
                      final isMe = msg['senderId'] == _signedInUser!.uid;
                      return _buildMessageBubble(msg, isMe);
                    },
                  );
                },
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Color.fromARGB(255, 7, 113, 199),
                    width: 2,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: (value) {
                        setState(() {
                          _msgText = value;
                        });
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        hintText: 'Écris ton message ici...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  TextButton(
                    onPressed: _sendMessage,
                    child: Text(
                      'Envoyer',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
