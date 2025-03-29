import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Titre localisé
                Text(
                  tr("create_account"),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Formulaire avec les textes localisés
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      buildTextField(tr("first_name"), Icons.person),
                      buildTextField(tr("last_name"), Icons.person_outline),
                      buildTextField(tr("email"), Icons.email),
                      buildTextField(
                        tr("password"),
                        Icons.lock,
                        obscureText: true,
                      ),
                      buildTextField(
                        tr("confirm_password"),
                        Icons.lock,
                        obscureText: true,
                      ),
                      buildTextField(
                        tr("age"),
                        Icons.calendar_today,
                        keyboardType: TextInputType.number,
                      ),
                      buildDropdown(tr("gender"), ["Male", "Female"]),
                      buildTextField(tr("job"), Icons.work),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Bouton Sign Up
                ElevatedButton(onPressed: () {}, child: Text(tr("sign_up"))),

                const SizedBox(height: 20),

                // Lien vers la connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(tr("already_have_account")),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        tr("sign_in"),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                // Bouton pour changer la langue
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.setLocale(const Locale('en'));
                      },
                      child: const Text("🇬🇧 English"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        context.setLocale(const Locale('fr'));
                      },
                      child: const Text("🇫🇷 Français"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    IconData icon, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget buildDropdown(String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        items:
            options.map((String value) {
              return DropdownMenuItem(value: value, child: Text(value));
            }).toList(),
        onChanged: (value) {},
      ),
    );
  }
}
