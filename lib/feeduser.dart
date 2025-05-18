import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class FeedbackAdminScreen extends StatelessWidget {
  const FeedbackAdminScreen({super.key});

  final Map<String, String> questionLabels = const {
    'q1': "feedback.q1",
    'q2': "feedback.q2",
    'q3': "feedback.q3",
    'q4': "feedback.q4",
    'q5': "feedback.q5",
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
          'admin_feedback.title'.tr(),
          style: const TextStyle(color: Colors.black),
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
              return Center(child: Text('Erreur de chargement.'.tr()));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final feedbacks = snapshot.data!.docs;

            if (feedbacks.isEmpty) {
              return Center(child: Text('Aucun retour trouvé.'.tr()));
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
                    final userName = snapshot.data ?? 'Chargement...'.tr();

                    return GestureDetector(
                      onLongPress: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                backgroundColor: Colors.white,
                                title: Text("admin_feedback.delete_title".tr()),
                                content: Text(
                                  "admin_feedback.delete_confirm".tr(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text("admin_feedback.cancel".tr()),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      await FirebaseFirestore.instance
                                          .collection('feedbacks')
                                          .doc(feedbacks[index].id)
                                          .delete();
                                    },
                                    child: Text(
                                      "admin_feedback.delete".tr(),
                                      style: const TextStyle(
                                        color: Colors.blue,
                                      ),
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
                        shadowColor: Colors.grey.withAlpha((0.5 * 255).toInt()),
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
                                return Text(
                                  '⭐ ${entry.value.tr()} : $note / 5',
                                );
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
