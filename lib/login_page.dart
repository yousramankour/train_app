import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'signup.dart';
import 'theme_provider.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import 'forgot_password.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController email1 = TextEditingController();
  final TextEditingController password1 = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String errorMessage = '';
  bool isLoading = false;

  Future<void> signIn() async {
    final email = email1.text.trim();
    final password = password1.text;

    setState(() {
      errorMessage = '';
    });

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Veuillez remplir tous les champs.';
      });
      return;
    }

    try {
      setState(() => isLoading = true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'Une erreur est survenue.';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => isLoading = false);
        return; // L'utilisateur a annulé la connexion
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      final User? user = userCredential.user;

      if (user != null) {
        final DocumentSnapshot userDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        // ✅ Si l'utilisateur n'existe pas dans Firestore, on l'ajoute
        if (!userDoc.exists) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'name': user.displayName ?? '',
                'email': user.email ?? '',
                'photoUrl': user.photoURL ?? '',
                'createdAt': DateTime.now(),
                'isAdmin': false,
                'signInMethod': 'google',
              });
        }

        // ✅ Redirection vers la page d'accueil
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erreur de connexion Google.';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final primaryColor = const Color(0xFF008ECC);
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(height: 50, color: primaryColor),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Image.asset('assets/logo9itari.png', height: 20),
                  ),
                  const SizedBox(height: 20),
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
                  TextField(
                    controller: email1,
                    decoration: InputDecoration(
                      labelText: 'email'.tr(),
                      labelStyle: TextStyle(color: textColor, fontSize: 16),
                      border: const UnderlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: password1,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'password'.tr(),
                      labelStyle: TextStyle(color: textColor, fontSize: 16),
                      border: const UnderlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                  Center(
                    child:
                        isLoading
                            ? const CircularProgressIndicator()
                            : Column(
                              children: [
                                SizedBox(
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
                                        color:
                                            isDark
                                                ? Colors.black
                                                : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: 200,
                                  height: 50,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      side: BorderSide(color: primaryColor),
                                    ),
                                    icon: Image.asset(
                                      'assets/googlelogo.png',
                                      height: 15,
                                      width: 15,
                                    ),
                                    label: Text(
                                      'sign_in_google'.tr(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    onPressed: signInWithGoogle,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ],
              ),
            ),
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
