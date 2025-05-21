import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'signup.dart';
import 'theme_provider.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Contrôleurs pour les champs de texte
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Instance de FirebaseAuth pour l'authentification
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Variables pour gérer l'état de l'erreur et du chargement
  String errorMessage = '';
  bool isLoading = false;

  // Fonction pour gérer la connexion de l'utilisateur
  Future<void> signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Réinitialiser le message d'erreur
    setState(() {
      errorMessage = '';
    });

    // Vérifier si les champs sont vides
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = "Veuillez remplir tous les champs.".tr();
      });
      return;
    }

    try {
      setState(() => isLoading = true);

      // Tentative de connexion avec Firebase
      final _ = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Naviguer vers la page d'accueil en cas de succès
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Gérer les erreurs d'authentification
      setState(() {
        errorMessage = e.message ?? 'Une erreur est survenue.'.tr();
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Déterminer le mode sombre ou clair
    final bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    // Définir les couleurs en fonction du thème
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final primaryColor =
        isDark ? const Color.fromARGB(255, 0, 2, 116) : const Color(0xFF008ECC);
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Barre supérieure
            Container(height: 50, color: primaryColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo de l'application
                  Center(
                    child: Image.asset('assets/logo9itari.png', height: 80),
                  ),
                  const SizedBox(height: 20),
                  // Titre de la page
                  Center(
                    child: Text(
                      'sign_in'.tr(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Champ pour l'email
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'email'.tr(),
                      labelStyle: TextStyle(color: textColor, fontSize: 16),
                      border: const UnderlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Champ pour le mot de passe
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'password'.tr(),
                      labelStyle: TextStyle(color: textColor, fontSize: 16),
                      border: const UnderlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Lien pour le mot de passe oublié
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage(),
                          ),
                        );
                      },
                      child: Text(
                        'forgot_password'.tr(),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Affichage du message d'erreur
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
                  // Bouton de connexion
                  Center(
                    child:
                        isLoading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                              width: 200,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: signIn,
                                child: Text(
                                  'sign_in'.tr(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.black : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                  ),
                ],
              ),
            ),
            // Barre inférieure avec lien vers l'inscription
            Container(
              height: 50,
              color: primaryColor,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('no_account'.tr(), style: TextStyle(color: textColor)),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ),
                        );
                      },
                      child: Text(
                        'sign_up'.tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
