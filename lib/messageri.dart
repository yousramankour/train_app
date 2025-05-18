import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'etatdeapp.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  static bool hasnewmsg = false;

  static checknewmsg(Function(bool) newmsg) {
    FirebaseFirestore.instance
        .collection('chat')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final lastmsg = snapshot.docs.first.data();
            final sendeId = lastmsg['senderId'];
            if (sendeId != FirebaseAuth.instance.currentUser?.uid) {
              newmsg(true);
            } else {
              newmsg(false);
            }
          }
        });
  }

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? msgid;
  User? get _user => _auth.currentUser;

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    if (_user == null) {
      if (kDebugMode) print('L\'utilisateur n\'est pas connecté');
      return;
    }

    try {
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

      _controller.clear();
    } catch (error) {
      if (kDebugMode) print('Erreur lors de l\'envoi du message : $error');
    }
  }

  Future<void> _deleteMessage(String docId) async {
    await _firestore.collection('chat').doc(docId).delete();
  }

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
                        title: Text('Supprimer le message ?'.tr()),
                        content: Text(
                          'Ce message sera supprimé pour tout le monde.'.tr(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: Text('Annuler'.tr()),
                          ),
                          TextButton(
                            onPressed: () {
                              _deleteMessage(docId);
                              Navigator.of(ctx).pop();
                            },
                            child: Text(
                              'Supprimer'.tr(),
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
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
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
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      (msg['timestamp'] as Timestamp)
                          .toDate()
                          .toLocal()
                          .toString()
                          .substring(11, 16),
                      style: TextStyle(fontSize: 11, color: Colors.white),
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
        title: Text('Chat'.tr()),
        backgroundColor: Colors.white10,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
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
                  return Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                DateTime? lastMessageDate;

                if (messages.isNotEmpty) {
                  final lastmsg = messages.first;
                  final lastmsgdata = lastmsg.data() as Map<String, dynamic>;
                  final lastmsgid = lastmsg.id;
                  final isme = lastmsgdata['senderId'] == _user?.uid;

                  if (msgid != lastmsgid && !isme) {
                    msgid = lastmsgid;
                    if (Appobservation.isAppInForeground) {
                      NotificationService.showNotification(
                        lastmsgdata['senderName'] ?? 'utilisateur',
                        lastmsgdata['text'] ?? '',
                      );
                    } else {
                      NotificationService.sendNotification(
                        'all',
                        lastmsgdata['senderName'] ?? 'utilisateur',
                        lastmsgdata['text'] ?? '',
                      );
                    }
                  }
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (ctx, index) {
                    final msg = messages[index].data() as Map<String, dynamic>;
                    final isMe = msg['senderId'] == _user?.uid;
                    final docId = messages[index].id;
                    final messageTime =
                        (msg['timestamp'] as Timestamp).toDate();
                    DateTime messageDateOnly = DateTime(
                      messageTime.year,
                      messageTime.month,
                      messageTime.day,
                    );
                    bool showDateHeader = false;

                    if (lastMessageDate == null ||
                        !isSameDay(lastMessageDate!, messageDateOnly)) {
                      showDateHeader = true;
                      lastMessageDate = messageDateOnly;
                    }

                    return Column(
                      children: [
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
                                  ).format(messageTime),
                                  style: TextStyle(
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
          Divider(height: 1),
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
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: "Type a message...".tr(),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  radius: 25,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
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

bool isSameDay(DateTime d1, DateTime d2) {
  return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}

class MessageSearchDelegate extends SearchDelegate {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
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
          return Center(child: CircularProgressIndicator());
        }

        final messages = snapshot.data!.docs;
        return ListView(
          children:
              messages.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(data['senderName'] ?? 'Utilisateur'),
                  subtitle: Text(data['text'] ?? ''),
                );
              }).toList(),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
