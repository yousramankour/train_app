// Import des pages nécessaires et des packages utilisés
import 'package:appmob/login_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // Pour la traduction
import 'package:firebase_auth/firebase_auth.dart'; // Pour l'authentification
import 'package:cloud_firestore/cloud_firestore.dart'; // Pour la base de données Firestore
import 'home.dart';

// Définition du widget d'inscription
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Variables pour stocker les données saisies par l'utilisateur
  String? selectedGender;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Instance Firebase
  final _auth = FirebaseAuth.instance;

  // Variables pour gérer les erreurs et l'état de chargement
  String errorMessage = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Détection du thème (sombre ou clair)
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre principal
                Center(
                  child: Text(
                    "create_account".tr(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Champs du formulaire d'inscription
                buildTextField(
                  "name_surname".tr(),
                  nameController,
                  isDark: isDark,
                ),
                buildTextField(
                  "age".tr(),
                  ageController,
                  keyboardType: TextInputType.number,
                  isDark: isDark,
                ),
                buildDropdownField("sex".tr(), isDark),
                buildTextField("job".tr(), jobController, isDark: isDark),
                buildTextField(
                  "email".tr(),
                  emailController,
                  keyboardType: TextInputType.emailAddress,
                  isDark: isDark,
                ),
                buildTextField(
                  "password".tr(),
                  passwordController,
                  obscureText: true,
                  isDark: isDark,
                ),
                buildTextField(
                  "confirm_password".tr(),
                  confirmPasswordController,
                  obscureText: true,
                  isDark: isDark,
                ),

                // Message d'erreur si présent
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

                const SizedBox(height: 20),
                // Bouton d'inscription
                Center(
                  child:
                      isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                            width: 200,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isDark
                                        ? Colors.blueGrey
                                        : const Color.fromARGB(
                                          255,
                                          172,
                                          219,
                                          241,
                                        ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed:
                                  signUp, // Appelle la fonction d'inscription
                              child: Text(
                                "sign_up".tr(),
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                ),
                const SizedBox(height: 20),
                // Ligne de séparation et lien vers la page de connexion
                Divider(color: isDark ? Colors.grey : Colors.black),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "already_have_account".tr(),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Redirection vers la page de connexion
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          "sign_in".tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fonction d'inscription
  Future<void> signUp() async {
    final name = nameController.text.trim();
    final age = ageController.text.trim();
    final job = jobController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    setState(() {
      errorMessage = '';
    });

    // Vérifie que tous les champs sont remplis
    if (name.isEmpty ||
        age.isEmpty ||
        selectedGender == null ||
        job.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        errorMessage = "Veuillez remplir tous les champs.";
      });
      return;
    }

    // Vérifie que les mots de passe sont identiques
    if (password != confirmPassword) {
      setState(() {
        errorMessage = "Les mots de passe ne correspondent pas.";
      });
      return;
    }

    try {
      setState(() => isLoading = true);

      // Création de l'utilisateur Firebase
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Enregistrement des données supplémentaires dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'name': name,
            'age': age,
            'sex': selectedGender,
            'job': job,
            'email': email,
            'createdAt': DateTime.now(),
          });

      // Redirection vers la page d'accueil après inscription
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Gestion des erreurs Firebase
      setState(() {
        errorMessage = e.message ?? "Une erreur est survenue.";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Widget personnalisé pour les champs de texte
  Widget buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  // Widget personnalisé pour la sélection du sexe (dropdown)
  Widget buildDropdownField(String label, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
        DropdownButtonFormField<String>(
          value: selectedGender,
          dropdownColor: isDark ? Colors.grey[900] : Colors.white,
          items: [
            DropdownMenuItem(value: "Homme", child: Text("man".tr())),
            DropdownMenuItem(value: "Femme", child: Text("woman".tr())),
          ],
          onChanged: (value) {
            setState(() {
              selectedGender = value;
            });
          },
          decoration: InputDecoration(
            border: const UnderlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
