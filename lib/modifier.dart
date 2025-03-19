import 'package:flutter/material.dart';

class ModificationProfilPage extends StatefulWidget {
  @override
  _ModificationProfilPageState createState() => _ModificationProfilPageState();
}

class _ModificationProfilPageState extends State<ModificationProfilPage> {
  TextEditingController nameController = TextEditingController(
    text: "John Doe",
  );
  TextEditingController emailController = TextEditingController(
    text: "john.doe@example.com",
  );
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modifier le profil"),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed:
              () => Navigator.pop(context), // 🔙 Retour à la page précédente
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // ✅ Champ Nom
            _buildTextField("Nom", nameController),

            // ✅ Champ Email
            _buildTextField("Email", emailController),

            // ✅ Champ Mot de passe
            _buildTextField(
              "Nouveau mot de passe",
              passwordController,
              isPassword: true,
            ),

            SizedBox(height: 20),

            // ✅ Bouton Enregistrer
            ElevatedButton(
              onPressed: () {
                // TODO: Ajouter la logique d'enregistrement
              },
              child: Text("Enregistrer"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Fonction pour créer un champ de texte réutilisable
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: isPassword, // Masquer le mot de passe
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon: isPassword ? Icon(Icons.lock) : null,
        ),
      ),
    );
  }
}
