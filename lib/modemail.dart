import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ModifierEmailPage extends StatefulWidget {
  @override
  _ModifierEmailPageState createState() => _ModifierEmailPageState();
}

class _ModifierEmailPageState extends State<ModifierEmailPage> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr("modify_email"), // Texte traduit
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [
          // Bouton pour changer de langue
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
            Text(
              tr("new_email"), // Texte traduit
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: tr("enter_new_email"), // Texte traduit
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Ajouter la logique pour sauvegarder l'email
                Navigator.pop(context); // Retour à la page précédente
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(tr("save")), // Texte traduit
            ),
          ],
        ),
      ),
    );
  }
}
