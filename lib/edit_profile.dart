import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _metierController = TextEditingController();
  String _selectedSexe = "Homme";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          _nomController.text = data['nom'] ?? '';
          _ageController.text = data['age']?.toString() ?? '';
          _metierController.text = data['metier'] ?? '';
          _selectedSexe = data['sexe'] ?? 'Homme';
        });
      }
    }
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'nom': _nomController.text.trim(),
          'email': user.email, // Ne pas modifier l'email
          'age': int.tryParse(_ageController.text.trim()) ?? 0,
          'metier': _metierController.text.trim(),
          'sexe': _selectedSexe,
        });
        Navigator.pop(context); // Retour au profil après sauvegarde
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier les informations"),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator:
                    (val) => val == null || val.isEmpty ? 'Nom requis' : null,
              ),
              // Suppression du champ email
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Âge'),
                keyboardType: TextInputType.number,
                validator:
                    (val) =>
                        val == null || int.tryParse(val) == null
                            ? 'Âge invalide'
                            : null,
              ),
              DropdownButtonFormField<String>(
                // Sélection du sexe
                value: _selectedSexe,
                items: const [
                  DropdownMenuItem(value: 'Homme', child: Text('Homme')),
                  DropdownMenuItem(value: 'Femme', child: Text('Femme')),
                  DropdownMenuItem(value: 'Autre', child: Text('Autre')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedSexe = val);
                  }
                },
                decoration: const InputDecoration(labelText: 'Sexe'),
              ),
              TextFormField(
                controller: _metierController,
                decoration: const InputDecoration(labelText: 'Métier'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text(
                  "Sauvegarder",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
