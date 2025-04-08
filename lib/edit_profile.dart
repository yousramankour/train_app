import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String age;
  final String gender;
  final String job;

  const EditProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.job,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController ageController;
  late TextEditingController genderController;
  late TextEditingController jobController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
    ageController = TextEditingController(text: widget.age);
    genderController = TextEditingController(text: widget.gender);
    jobController = TextEditingController(text: widget.job);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    ageController.dispose();
    genderController.dispose();
    jobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier Profil"),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom')),
            TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'Âge')),
            TextField(
                controller: genderController,
                decoration: const InputDecoration(labelText: 'Sexe')),
            TextField(
                controller: jobController,
                decoration: const InputDecoration(labelText: 'Métier')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Enregistre les modifications ici
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
              ),
              child: const Text("Sauvegarder"),
            ),
          ],
        ),
      ),
    );
  }
}
