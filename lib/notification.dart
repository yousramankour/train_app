import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationScreen extends StatelessWidget {
  final DateFormat formatter = DateFormat('dd MMM yyyy - HH:mm');

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 2 onglets
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Notifications".tr()),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          foregroundColor: Colors.black,
          bottom: TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [Tab(text: "retard".tr()), Tab(text: "panne".tr())],
          ),
        ),
        body: TabBarView(
          children: [
            NotificationList(filter: "retard".tr()),
            NotificationList(filter: "panne".tr()),
          ],
        ),
      ),
    );
  }
}

class NotificationList extends StatelessWidget {
  final String filter;
  const NotificationList({super.key, required this.filter});

  IconData getIcon(String etat) {
    switch (etat) {
      case 'retard':
        return Icons.schedule;
      case 'panne':
        return Icons.error;

      default:
        return Icons.notifications;
    }
  }

  Color getIconColor(String etat) {
    switch (etat) {
      case 'retard':
        return Colors.blue;
      case 'panne':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  String getTitle(String etat) {
    switch (etat) {
      case 'retard':
        return "Retard signalé".tr();
      case 'panne':
        return "Panne détectée".tr();
      default:
        return 'Notification';
    }
  }

  String timeAgo(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return "Il y a quelques secondes".tr();
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('notification')
              .orderBy('timestamp', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("Erreur".tr()));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;

        final filteredDocs =
            docs.where((doc) {
              final etat = doc['etat'];
              return etat == filter;
            }).toList();

        if (filteredDocs.isEmpty) {
          return Center(child: Text("Aucune notification".tr()));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final etat = doc['etat'];
            final message = doc['message'];
            final timestamp = doc['timestamp'] as Timestamp;
            final dateText = timeAgo(timestamp.toDate());

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),

                    decoration: BoxDecoration(
                      color: getIconColor(etat).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      getIcon(etat),
                      color: getIconColor(etat),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTitle(etat),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(message, style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 6),
                        Text(
                          dateText,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
