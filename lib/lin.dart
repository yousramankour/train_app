import 'package:appmob/moderail.dart'; // page modification
import 'package:appmob/rail.dart'; // page ajout ligne
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class RailLinesScreen extends StatelessWidget {
  const RailLinesScreen({super.key});

  void _confirmDelete(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Supprimer la ligne".tr()),
            content: Text("Voulez-vous vraiment supprimer cette ligne ?".tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Annuler".tr()),
              ),
              TextButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('rail')
                      .doc(docId)
                      .delete();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Ligne supprimée".tr())),
                  );
                },
                child: Text("Supprimer", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _editLine(BuildContext context, String docId, List<String> gares) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditLineScreen(
              docId: docId,
              initialName: docId,
              initialGares: gares,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Lignes de Rail".tr(),
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('rail').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Erreur de chargement"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var rails = snapshot.data!.docs;

          if (rails.isEmpty) {
            return Center(child: Text("Aucune ligne disponible.".tr()));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rails.length,
            itemBuilder: (context, index) {
              var rail = rails[index];
              var fromTo = rail.id; // Exemple: "Alger->Thénia"
              var gares = List<String>.from(rail['gares'] ?? []);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          fromTo,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed:
                            () => _editLine(
                              context,
                              rail.id,
                              gares,
                            ), // <<<<< CORRIGÉ
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.blue),
                        onPressed: () => _confirmDelete(context, rail.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: gares.length,
                    itemBuilder: (context, gareIndex) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.blueAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              if (gareIndex != gares.length - 1)
                                Container(
                                  width: 2,
                                  height: 30,
                                  color: Colors.blueAccent,
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                gares[gareIndex],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const Divider(height: 32, thickness: 1),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRailLinePage()),
          );
        },
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          "Ajouter ligne".tr(),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
