import 'package:appmob/home.dart';
import 'package:flutter/material.dart';
// Ajout de l'import pour SVG
import 'signup.dart'; // Import de la page d'inscription

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.lightBlueAccent.shade100, Colors.white],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Barre de couleur en haut
              Container(
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent.shade100,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 31,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email), // Icône à gauche
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ), // Bordures arrondies
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 7,
                        ), // Espacement
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      obscureText: true, // Masque le texte du mot de passe
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(
                          Icons.lock,
                        ), // Icône de cadenas à gauche
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            10,
                          ), // Bordures arrondies
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 3,
                        ), // Espacement
                      ),
                    ),
                    SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 13,
                            fontWeight: FontWeight.bold, // Texte en gras
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 110,
                        ), // Largeur du bouton
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.lightBlueAccent.shade100,
                      ),
                      onPressed: () {},
                      child: Text(
                        "SIGN IN",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              // Barre de couleur en bas avec "Sign up"
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.lightBlueAccent.shade100,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don’t have an account?",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () {
                          // 🔹 Lien vers la page d'inscription
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpPage(),
                            ),
                          );
                        },
                        child: Text(
                          "SIGN UP",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
      ),
    );
  }
}
