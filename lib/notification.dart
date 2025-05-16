import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Pour formater la date proprement
import 'package:easy_localization/easy_localization.dart';

class NotificationScreen extends StatelessWidget {
  final DateFormat formatter = DateFormat('dd MMM yyyy - HH:mm');

  NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 216, 245, 243),
      appBar: AppBar(
        title: Text('Notifications'.tr()),
        backgroundColor: Colors.blue,
        centerTitle: false,
        elevation: 4,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('notification')
                .orderBy('timestamp', descending: false)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur de chargement'.tr()));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!.docs;

          if (notifications.isEmpty) {
            return Center(
              child: Text(
                "Aucune notification".tr(),
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final String type = doc['etat'];
              final String message = doc['message'];
              final Timestamp timestamp = doc['timestamp'] ?? Timestamp.now();

              final bool isRetard = type == 'retard';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isRetard ? Colors.orange[100] : Colors.red[100],
                    child: Icon(
                      isRetard ? Icons.access_time : Icons.warning_amber,
                      color: isRetard ? Colors.orange : Colors.red,
                    ),
                  ),
                  title: Text(
                    message,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    formatter.format(timestamp.toDate()),
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
