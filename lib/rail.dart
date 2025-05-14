import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddRailLinePage extends StatefulWidget {
  @override
  _AddRailLinePageState createState() => _AddRailLinePageState();
}

class _AddRailLinePageState extends State<AddRailLinePage> {
  final TextEditingController _lineNameController = TextEditingController();
  final TextEditingController _gareController = TextEditingController();
  List<String> _gares = [];

  // Méthode pour enregistrer dans Firestore
  Future<void> _saveLineToFirestore() async {
    String lineName = _lineNameController.text.trim();

    if (lineName.isEmpty || _gares.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance
              .collection('rail')
              .doc(lineName)
              .get();

      if (doc.exists) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Cette ligne existe déjà 🔴')));
        return;
      }

      await FirebaseFirestore.instance.collection('rail').doc(lineName).set({
        'gares': _gares,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ligne ajoutée avec succès 🎉')));

      _lineNameController.clear();
      _gareController.clear();
      setState(() {
        _gares.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  // Ajout d'une gare avec vérification dans Firestore
  Future<void> _addGareIfExists() async {
    String gareName = _gareController.text.trim();

    if (gareName.isEmpty) return;

    try {
      DocumentSnapshot gareDoc =
          await FirebaseFirestore.instance
              .collection('gares')
              .doc(gareName)
              .get();

      if (!gareDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('La gare "$gareName" n\'existe pas dans les gars 🔴'),
          ),
        );
        return;
      }

      if (_gares.contains(gareName)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('La gare "$gareName" est déjà ajoutée ⚠️')),
        );
        return;
      }

      setState(() {
        _gares.add(gareName);
        _gareController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text('Ajouter une Ligne', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _lineNameController,
              decoration: InputDecoration(
                labelText: 'Nom de la ligne',
                prefixIcon: Icon(Icons.train, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Champ pour ajouter une gare
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _gareController,
                    decoration: InputDecoration(
                      labelText: 'Ajouter une gare',
                      prefixIcon: Icon(Icons.location_on, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addGareIfExists,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 20),

            Expanded(
              child:
                  _gares.isEmpty
                      ? Center(child: Text('Aucune gare ajoutée'))
                      : ListView.builder(
                        itemCount: _gares.length,
                        itemBuilder: (context, index) {
                          return Card(
                            color: Colors.white,
                            elevation: 2,
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              leading: Icon(
                                Icons.location_city,
                                color: Colors.blue,
                              ),
                              title: Text(_gares[index]),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _gares.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveLineToFirestore,
                icon: Icon(Icons.save, color: Colors.black),
                label: Text(
                  'Enregistrer la ligne',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
