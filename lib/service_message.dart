// services/message_listener_service.dart
import 'package:appmob/etatdeapp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class MessageListenerService {
  static bool _isListening = false;

  static void listenToNewMessages() async {
    if (_isListening) return;
    _isListening = true;

    final prefs = await SharedPreferences.getInstance();
    String? _lastMessageId = prefs.getString('lastMessageId');

    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final User? _user = _auth.currentUser;
    bool _isFirstSnapshot = true;

    _firestore
        .collection('chat')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) async {
          if (_isFirstSnapshot) {
            _isFirstSnapshot = false;
            if (snapshot.docs.isNotEmpty) {
              final latestId = snapshot.docs.first.id;
              if (_lastMessageId == null) {
                _lastMessageId = latestId;
                prefs.setString('lastMessageId', latestId);
              }
            }
            return;
          }

          if (snapshot.docs.isNotEmpty) {
            final doc = snapshot.docs.first;
            final msgId = doc.id;

            if (msgId == _lastMessageId) return;

            _lastMessageId = msgId;
            prefs.setString('lastMessageId', msgId); // met à jour localement

            final msg = doc.data();
            final senderId = msg['senderId'] ?? '';
            final text = msg['text'] ?? '';

            if (_user != null && senderId != _user.uid) {
              final userDoc =
                  await _firestore.collection('users').doc(senderId).get();
              final senderName = userDoc.data()?['name'] ?? 'Quelqu\'un';

              if (Appobservation.isAppInForeground) {
                NotificationService.showNotification(
                  "Nouveau message de $senderName",
                  text,
                );
              } else {
                NotificationService.sendNotification(
                  'all',
                  "Nouveau message de $senderName",
                  text,
                );
              }
            }
          }
        });
  }
}
