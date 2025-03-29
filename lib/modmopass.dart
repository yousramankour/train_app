import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ModifierMDPPage extends StatefulWidget {
  @override
  _ModifierMDPPageState createState() => _ModifierMDPPageState();
}

class _ModifierMDPPageState extends State<ModifierMDPPage> {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("change_password")),
        backgroundColor: Colors.blue,
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              tr("old_password"),
              oldPasswordController,
              tr("enter_old_password"),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              tr("new_password"),
              newPasswordController,
              tr("enter_new_password"),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              tr("confirm_new_password"),
              confirmPasswordController,
              tr("confirm_password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Ajouter la logique pour sauvegarder le mot de passe
                Navigator.pop(context); // Retour à la page précédente
              },
              child: Text(tr("save")),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
    TextEditingController controller,
    String hintText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}
