import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddGareForm extends StatefulWidget {
  @override
  _AddGareFormState createState() => _AddGareFormState();
}

class _AddGareFormState extends State<AddGareForm> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs de texte
  final TextEditingController _gareController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fonction pour ajouter une gare
  Future<void> _ajouterGare() async {
    String gareNom = _gareController.text.trim();

    // Vérifier si un document avec le nom de la gare existe déjà
    DocumentSnapshot documentSnapshot =
        await _firestore.collection('gares').doc(gareNom).get();

    if (documentSnapshot.exists) {
      // Si le document existe déjà, afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cette gare existe déjà dans la base de données."),
        ),
      );
    } else {
      // Si le document n'existe pas, on l'ajoute à Firestore
      try {
        // Ajout de la gare dans la base de données
        await _firestore.collection('gares').doc(gareNom).set({
          'nom': gareNom,
          'latitude': double.parse(_latitudeController.text),
          'longitude': double.parse(_longitudeController.text),
          'coordinates': [
            double.parse(_latitudeController.text),
            double.parse(_longitudeController.text),
          ],
        });

        // Afficher un message de succès
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gare ajoutée avec succès.")));

        // Réinitialiser les champs
        _gareController.clear();
        _latitudeController.clear();
        _longitudeController.clear();
      } catch (e) {
        // En cas d'erreur lors de l'ajout de la gare
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr("Erreur lors de l'ajout de la gare", args: ["e"])),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter une gare".tr()),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Champ pour le nom de la gare
              TextFormField(
                controller: _gareController,
                decoration: InputDecoration(
                  labelText: "Nom de la gare".tr(),
                  prefixIcon: Icon(Icons.location_on, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Le nom de la gare est requis".tr();
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Champ pour la latitude
              TextFormField(
                controller: _latitudeController,
                decoration: InputDecoration(
                  labelText: "Latitude".tr(),
                  prefixIcon: Icon(Icons.my_location, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "La latitude est requise".tr();
                  }
                  return null;
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 16),

              // Champ pour la longitude
              TextFormField(
                controller: _longitudeController,
                decoration: InputDecoration(
                  labelText: "Longitude".tr(),
                  prefixIcon: Icon(Icons.my_location, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "La longitude est requise".tr();
                  }
                  return null;
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 32),

              // Bouton pour soumettre
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _ajouterGare();
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Ajouter la gare".tr(),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
