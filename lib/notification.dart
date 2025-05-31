import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Pour formater la date
import 'package:easy_localization/easy_localization.dart'; // Pour les traductions

// Écran principal des notifications
class NotificationScreen extends StatelessWidget {
  final DateFormat formatter = DateFormat('dd MMM yyyy - HH:mm');

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Deux onglets : Retard et Panne
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Notifications".tr()), // Titre traduit
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          foregroundColor: Colors.black,
          bottom: TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: "retard".tr()), // Onglet 1 : Retards
              Tab(text: "panne".tr()), // Onglet 2 : Pannes
            ],
          ),
        ),
        body: TabBarView(
          children: [
            NotificationList(
              filter: "retard",
            ), // Liste filtrée pour les retards
            NotificationList(filter: "panne"), // Liste filtrée pour les pannes
          ],
        ),
      ),
    );
  }
}

// Liste des notifications filtrées (retard ou panne)
class NotificationList extends StatelessWidget {
  final String filter; // 'retard' ou 'panne'

  const NotificationList({super.key, required this.filter});

  // Retourne une icône en fonction de l'état
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

  // Retourne une couleur en fonction de l'état
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

  // Retourne un titre en fonction de l'état
  String getTitle(String etat) {
    switch (etat) {
      case 'retard':
        return "retard_title".tr();
      case 'panne':
        return "panne_title".tr();
      default:
        return 'Notification';
    }
  }

  // Formate le temps écoulé depuis la notification
  String timeAgo(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return "time_few_seconds".tr();
    if (diff.inMinutes < 60)
      return tr('time_minutes', args: ['${diff.inMinutes}']);
    if (diff.inHours < 24) return tr('time_hours', args: ['${diff.inHours}']);
    return DateFormat('dd MMM yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // On écoute les notifications depuis Firestore
      stream:
          FirebaseFirestore.instance
              .collection('notification')
              .orderBy('timestamp', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text("error".tr()));
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;

        // Filtrage des notifications selon l'état
        final filteredDocs =
            docs.where((doc) => doc['etat'] == filter).toList();

        if (filteredDocs.isEmpty) {
          return Center(child: Text("no_notifications".tr()));
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
                  // Icône d'état
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
                  // Détails du message
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
