import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackAdminScreen extends StatelessWidget {
  FeedbackAdminScreen({Key? key}) : super(key: key);

  final Map<String, String> questionLabels = {
    'q1': "1. Le suivi en temps réel est-il précis ?".tr(),
    'q2': "2. La traçabilité des trajets vous satisfait-elle ?".tr(),
    'q3': "3. Les alertes/notifications sont-elles fiables ?".tr(),
    'q4': "4. La messagerie est-elle utile ?".tr(),
    'q5': "5. L’application est-elle facile à utiliser ?".tr(),
  };

  Future<String> _getUserName(String userId) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
      if (userDoc.exists) {
        return userDoc.data()?['name'] ?? 'Utilisateur';
      } else {
        return 'Utilisateur inconnu';
      }
    } catch (e) {
      return 'Erreur nom';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Retours des utilisateurs".tr(),
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('feedbacks')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Erreur de chargement.".tr()));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final feedbacks = snapshot.data!.docs;

            if (feedbacks.isEmpty) {
              return Center(child: Text("Aucun retour trouvé.".tr()));
            }

            return ListView.separated(
              itemCount: feedbacks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final data = feedbacks[index].data() as Map<String, dynamic>;
                final userId = data['userId'];

                return FutureBuilder<String>(
                  future: _getUserName(userId),
                  builder: (context, snapshot) {
                    final userName = snapshot.data ?? "Chargement...".tr();

                    return GestureDetector(
                      onLongPress: () {
                        // Ouvre une boîte de dialogue de confirmation
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text("Supprimer ce retour ?".tr()),
                                content: Text(
                                  "Voulez-vous vraiment supprimer ce feedback?"
                                      .tr(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("Annuler".tr()),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context); // Ferme la boîte
                                      await FirebaseFirestore.instance
                                          .collection('feedbacks')
                                          .doc(feedbacks[index].id)
                                          .delete();
                                    },
                                    child: Text(
                                      "Supprimer".tr(),
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: Colors.grey.withAlpha(128),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '👤 $userName',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...questionLabels.entries.map((entry) {
                                final note = data[entry.key] ?? 'N/A';
                                return Text('⭐ ${entry.value} : $note / 5');
                              }),
                              const SizedBox(height: 10),
                              if ((data['problemes'] ?? '')
                                  .toString()
                                  .trim()
                                  .isNotEmpty)
                                Text('❗ Problèmes : ${data['problemes']}'),
                              if ((data['suggestions'] ?? '')
                                  .toString()
                                  .trim()
                                  .isNotEmpty)
                                Text('💡 Suggestions : ${data['suggestions']}'),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
