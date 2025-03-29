import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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
        title: Text(tr("modify_profile")), // 🔥 Texte traduit
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed:
              () => Navigator.pop(context), // 🔙 Retour à la page précédente
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: () {
              if (context.locale == Locale('fr', 'FR')) {
                context.setLocale(Locale('en', 'US'));
              } else if (context.locale == Locale('en', 'US')) {
                context.setLocale(Locale('ar', 'DZ'));
              } else {
                context.setLocale(Locale('fr', 'FR'));
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // ✅ Champ Nom
            _buildTextField(tr("name"), nameController),

            // ✅ Champ Email
            _buildTextField(tr("email"), emailController),

            // ✅ Champ Mot de passe
            _buildTextField(
              tr("new_password"),
              passwordController,
              isPassword: true,
            ),

            SizedBox(height: 20),

            // ✅ Bouton Enregistrer
            ElevatedButton(
              onPressed: () {
                // TODO: Ajouter la logique d'enregistrement
              },
              child: Text(tr("save")), // 🔥 Texte traduit
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
