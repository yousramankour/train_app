import 'package:appmob/gars.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GareListPage extends StatefulWidget {
  const GareListPage({super.key});

  @override
  _GareListPageState createState() => _GareListPageState();
}

class _GareListPageState extends State<GareListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Liste des Gares',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('gares').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucune gare trouvée'));
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var gareName = doc.id;

              return Card(
                color: Colors.white,
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.train, color: Colors.blue),
                  title: Text(
                    gareName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.blue),
                    onPressed: () => _confirmDelete(context, gareName),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddGareForm()),
          );
        },
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Ajouter Gare',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String gareName) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Supprimer'),
            content: Text(
              'Voulez-vous vraiment supprimer la gare "$gareName" ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  // 1. Supprimer la gare
                  await FirebaseFirestore.instance
                      .collection('gares')
                      .doc(gareName)
                      .delete();

                  // 2. Parcourir toutes les lignes et retirer la gare si elle y est
                  var railSnapshot =
                      await FirebaseFirestore.instance.collection('rail').get();
                  for (var doc in railSnapshot.docs) {
                    List<dynamic>? gares = doc['gares'];
                    if (gares != null && gares.contains(gareName)) {
                      gares.remove(gareName);
                      await FirebaseFirestore.instance
                          .collection('rail')
                          .doc(doc.id)
                          .update({'gares': gares});
                    }
                  }

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gare "$gareName" supprimée partout'),
                    ),
                  );
                },
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
