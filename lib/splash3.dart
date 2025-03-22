import 'package:appmob/login_page.dart';
import 'package:appmob/loginpage2.dart';
import 'package:flutter/material.dart';

class Splash3Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF81D4FA), // Bleu ciel plus foncé
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 170), // Ajustement pour correspondre à l'image
            Text(
              "Open app as",
              style: TextStyle(
                fontSize: 26, // Identique à l'image
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                fontFamily: 'Serif', // Pour matcher le style
              ),
            ),
            SizedBox(height: 80),
            CustomButton(
              text: "A USER",
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
            SizedBox(height: 20),
            Text(
              "or",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),
            CustomButton(
              text: "AN ADMIN",

              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage2()),
                );
              },
            ),
            Spacer(), // Pousse l'image vers le bas
            Image.asset(
              'assets/amico.png', // Remplace par ton image
              height: 200, // Ajustement de la taille
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10), // Évite l’espace blanc
          ],
        ),
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  CustomButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220, // Largeur du bouton
      height: 40, // Hauteur du bouton
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Couleur du texte
            ),
          ),
        ),
      ),
    );
  }
}
