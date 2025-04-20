import 'package:appmob/login_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String? selectedGender;
  final TextEditingController name1 = TextEditingController();
  final TextEditingController age1 = TextEditingController();
  final TextEditingController job1 = TextEditingController();
  final TextEditingController email1 = TextEditingController();
  final TextEditingController password1 = TextEditingController();
  final TextEditingController confirmPassword1 = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String errorMessage = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
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
                buildTextField("name_surname".tr(), name1, isDark: isDark),
                buildTextField(
                  "age".tr(),
                  age1,
                  keyboardType: TextInputType.number,
                  isDark: isDark,
                ),
                buildDropdownField("sex".tr(), isDark),
                buildTextField("job".tr(), job1, isDark: isDark),
                buildTextField(
                  "email".tr(),
                  email1,
                  keyboardType: TextInputType.emailAddress,
                  isDark: isDark,
                ),
                buildTextField(
                  "password".tr(),
                  password1,
                  obscureText: true,
                  isDark: isDark,
                ),
                buildTextField(
                  "confirm_password".tr(),
                  confirmPassword1,
                  obscureText: true,
                  isDark: isDark,
                ),

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
                              onPressed: signUp,
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

  Future<void> signUp() async {
    final name = name1.text.trim();
    final age = age1.text.trim();
    final job = job1.text.trim();
    final email = email1.text.trim();
    final password = password1.text;
    final confirmPassword = confirmPassword1.text;

    setState(() {
      errorMessage = '';
    });

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

    if (password != confirmPassword) {
      setState(() {
        errorMessage = "Les mots de passe ne correspondent pas.";
      });
      return;
    }

    try {
      setState(() => isLoading = true);

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ⬇️ Envoi de l'email de vérification
      await userCredential.user!.sendEmailVerification();

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

      // ⬇️ Message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Un e-mail de vérification a été envoyé."),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? "Une erreur est survenue.";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

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
            DropdownMenuItem(value: "man".tr(), child: Text("man".tr())),
            DropdownMenuItem(value: "woman".tr(), child: Text("woman".tr())),
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
