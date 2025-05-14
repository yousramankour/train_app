import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _jobController = TextEditingController();
  final _sexController = TextEditingController();
  String email = "";
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();
      if (doc.exists) {
        setState(() {
          email = user!.email ?? '';
          _nameController.text = doc['name'] ?? '';
          _ageController.text = doc['age']?.toString() ?? '';
          _jobController.text = doc['job'] ?? '';
          _sexController.text = doc['sex'] ?? '';
        });
      }
    }
  }

  void _saveChanges() async {
    final name = _nameController.text.trim();
    final age = _ageController.text.trim();
    final job = _jobController.text.trim();
    final sex = _sexController.text.trim();
    if (name.isEmpty || age.isEmpty || job.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'name': name,
      'age': int.tryParse(age),
      'job': job,
      'sex': sex,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil mis à jour avec succès')),
    );
  }

  void _changePassword() async {
    if (user != null) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Un lien de réinitialisation a été envoyé à votre email.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Modifier le Profil',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildReadOnlyField("Email", email),
              const SizedBox(height: 20),
              _buildEditableField("Nom", _nameController),
              const SizedBox(height: 20),
              _buildEditableField(
                "Âge",
                _ageController,
                type: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _buildEditableField("Métier", _jobController),
              const SizedBox(height: 20),
              _buildEditableField("genre", _sexController),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _saveChanges,
                child: const Text(
                  'Enregistrer',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _changePassword,
                icon: const Icon(Icons.lock_reset, color: Colors.blue),
                label: const Text(
                  "Changer le mot de passe",
                  style: TextStyle(color: Colors.blue),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        fillColor: Colors.grey[100],
        filled: true,
      ),
    );
  }
}
