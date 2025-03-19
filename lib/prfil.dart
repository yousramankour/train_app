import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:appmob/modifier.dart';

class ProfilPage extends StatefulWidget {
  final VoidCallback onBack;

  const ProfilPage({required this.onBack, super.key});

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  File? _image; // ✅ Stocker l'image sélectionnée
  final picker = ImagePicker();

  // ✅ Fonction pour sélectionner une nouvelle photo de profil
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // ✅ Controllers pour les informations utilisateur
  TextEditingController nameController = TextEditingController(
    text: "John Doe",
  );
  TextEditingController emailController = TextEditingController(
    text: "john.doe@example.com",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Mon Profil", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack, // 🔙 Retour au menu
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ✅ Photo de profil avec bouton de modification
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        _image != null
                            ? FileImage(_image!) as ImageProvider
                            : const AssetImage(
                              "assets/photo1.png",
                            ), // ✅ Image par défaut
                    backgroundColor:
                        Colors.grey[300], // ✅ Fond gris clair si pas d'image
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    onPressed: _pickImage, // 📸 Modifier l'image
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ✅ Nom et email affichés en dessous de la photo
              Text(
                nameController.text,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                emailController.text,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(
                height: 40,
              ), // 🔹 Augmenter l'espace avant les boutons
              // ✅ Boutons alignés verticalement avec plus d’espace
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ModificationProfilPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text("Modifier les informations"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color.fromARGB(255, 159, 207, 247),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ), // 🔹 Plus d’espace entre les boutons

                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Ajouter la logique pour afficher l'historique des activités
                    },
                    icon: const Icon(Icons.history),
                    label: const Text("Voir l'historique des activités"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color.fromARGB(255, 159, 207, 247),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
