import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VoirReponsesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Réponses des utilisateurs")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("enquetes_satisfaction").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text("⭐ Suivi: ${doc['noteSuivi']}, Trajets: ${doc['noteTrajets']}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Alertes: ${doc['noteAlertes']}, Messagerie: ${doc['noteMessagerie']}, UI: ${doc['noteUI']}"),
                      SizedBox(height: 5),
                      Text("🛠 Services à ajouter: ${doc['servicesAjoutes'] ?? ''}"),
                      Text("💬 Suggestions: ${doc['suggestions'] ?? ''}"),
                    ],
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
