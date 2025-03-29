import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ModifierNomPage extends StatefulWidget {
  @override
  _ModifierNomPageState createState() => _ModifierNomPageState();
}

class _ModifierNomPageState extends State<ModifierNomPage> {
  TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("change_name")),
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
            Text(
              tr("new_name"),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: tr("enter_new_name"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Sauvegarder le nom (ajouter la logique plus tard)
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
}
