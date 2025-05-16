import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class AddCoordinatesPage extends StatefulWidget {
  const AddCoordinatesPage({super.key});

  @override
  AddCoordinatesPageState createState() => AddCoordinatesPageState();
}

class AddCoordinatesPageState extends State<AddCoordinatesPage> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _coordsTextController = TextEditingController();

  List<List<double>> _coordinates = [];

  void _parseCoordinatesFromText() {
    final regex = RegExp(r'\[\s*([\d\.\-]+)\s*,\s*([\d\.\-]+)\s*\]');
    final matches = regex.allMatches(_coordsTextController.text);

    final newCoords = <List<double>>[];

    for (final match in matches) {
      final lat = double.tryParse(match.group(1)!);
      final lng = double.tryParse(match.group(2)!);
      if (lat != null && lng != null) {
        newCoords.add([lat, lng]);
      }
    }

    if (newCoords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Aucune coordonnée valide trouvée ❌".tr())),
      );
    } else {
      setState(() {
        _coordinates = newCoords;
      });
    }
  }

  Future<void> _saveToFirestore() async {
    final from = _fromController.text.trim();
    final to = _toController.text.trim();

    if (from.isEmpty || to.isEmpty || _coordinates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Remplir tous les champs 📌".tr())),
      );
      return;
    }

    final docId = "$from-$to";

    try {
      await FirebaseFirestore.instance.collection("station").doc(docId).set({
        "coordinates":
            _coordinates.map((coord) => GeoPoint(coord[0], coord[1])).toList(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Coordonnées enregistrées avec succès ✅".tr()),
          ),
        );
      }

      setState(() {
        _coordinates.clear();
        _fromController.clear();
        _toController.clear();
        _coordsTextController.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // permet d'éviter overflow avec clavier
      appBar: AppBar(
        title: Text("Ajouter des coordonnées".tr()),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        // évite le overflow
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _fromController,
              decoration: InputDecoration(
                labelText: "Station 1".tr(),
                prefixIcon: Icon(Icons.train, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _toController,
              decoration: InputDecoration(
                labelText: "Station 2".tr(),
                prefixIcon: Icon(Icons.train, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _coordsTextController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: "Coordonnées format [lat, lng]",
                hintText:
                    "[36.70398799, 3.17206101],\n[36.70394708, 3.17189291],",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _parseCoordinatesFromText,
              icon: Icon(Icons.format_list_bulleted),
              label: Text("Charger la liste".tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Container(
              child:
                  _coordinates.isEmpty
                      ? Center(child: Text("Aucune coordonnée chargée"))
                      : ListView.builder(
                        itemCount: _coordinates.length,
                        itemBuilder: (context, index) {
                          return Card(
                            elevation: 2,
                            child: ListTile(
                              title: Text(
                                "Lat: ${_coordinates[index][0]}, Lng: ${_coordinates[index][1]}",
                              ),
                            ),
                          );
                        },
                      ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saveToFirestore,
                icon: Icon(Icons.save),
                label: Text("Enregistrer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
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
