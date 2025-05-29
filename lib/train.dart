import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class TrainPage extends StatefulWidget {
  const TrainPage({super.key});

  @override
  State<TrainPage> createState() => _TrainPageState();
}

class _TrainPageState extends State<TrainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Liste des Trains".tr())),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('trains').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Erreur de chargement".tr()));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final trains = snapshot.data!.docs;

          if (trains.isEmpty) {
            return Center(child: Text("Aucun train trouvé.".tr()));
          }

          return ListView.builder(
            itemCount: trains.length,
            itemBuilder: (context, index) {
              final train = trains[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.train),
                  title: Text(train['nom'] ?? 'Nom inconnu'),
                  subtitle: Text(
                    "Ligne : ${train['ligne'] ?? '-'}\n"
                    "Départ : ${train['depart'] ?? '-'} → Arrivée : ${train['arrivee'] ?? '-'}\n"
                    "Heure : ${train['heure'] ?? '-'}",
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _ajouterTrainDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _ajouterTrainDialog(BuildContext context) {
    final TextEditingController nomController = TextEditingController();
    final TextEditingController ligneController = TextEditingController();
    final TextEditingController departController = TextEditingController();
    final TextEditingController arriveeController = TextEditingController();
    final TextEditingController heureController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Ajouter un train".tr()),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nomController,
                    decoration: InputDecoration(labelText: "Nom".tr()),
                  ),
                  TextField(
                    controller: ligneController,
                    decoration: InputDecoration(labelText: "Ligne".tr()),
                  ),
                  TextField(
                    controller: departController,
                    decoration: InputDecoration(labelText: "Départ".tr()),
                  ),
                  TextField(
                    controller: arriveeController,
                    decoration: InputDecoration(labelText: "Arrivée".tr()),
                  ),
                  TextField(
                    controller: heureController,
                    decoration: InputDecoration(labelText: "Heure".tr()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Annuler".tr()),
              ),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('trains').add({
                    'nom': nomController.text,
                    'ligne': ligneController.text,
                    'depart': departController.text,
                    'arrivee': arriveeController.text,
                    'heure': heureController.text,
                  });
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                child: Text("Ajouter".tr()),
              ),
            ],
          ),
    );
  }
}
