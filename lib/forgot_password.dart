import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String message = '';
  bool isLoading = false;

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    setState(() {
      message = '';
    });

    if (email.isEmpty) {
      setState(() {
        message = "Veuillez entrer votre adresse e-mail.".tr();
      });
      return;
    }

    try {
      setState(() => isLoading = true);

      // Vérifier si l'e-mail existe
      // ignore: deprecated_member_use
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isEmpty) {
        setState(() {
          message = "Aucun compte associé à cet e-mail.".tr();
        });
        return;
      }

      // Envoyer l'e-mail de réinitialisation
      await _auth.sendPasswordResetEmail(email: email);
      setState(() {
        message = "Un e-mail de réinitialisation a été envoyé.".tr();
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        message = e.message ?? "Une erreur est survenue.".tr();
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(title: Text("Réinitialiser le mot de passe".tr())),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Adresse e-mail".tr()),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: resetPassword,
                  child: Text("Envoyer le lien de réinitialisation"),
                ),
            const SizedBox(height: 20),
            if (message.isNotEmpty)
              Text(message, style: TextStyle(color: textColor)),
          ],
        ),
      ),
    );
  }
}
