import 'package:flutter/material.dart';
import 'dart:async';
import 'splash2.dart'; // Import de la page de connexion

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0; // Définition initiale pour l'effet de fondu

  @override
  void initState() {
    super.initState();

    // Lancer l'effet de fondu dès l'affichage
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Attendre 10 secondes avant de passer à SplashScreen2
    Timer(Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Splash2()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF81D4FA),
              Color(0xFFFFFFFF),
            ], // Dégradé bleu -> blanc
          ),
        ),
        child: Center(
          child: AnimatedOpacity(
            duration: Duration(seconds: 3), // Animation de 3s
            opacity: _opacity, // Applique l'effet de fondu
            child: Image.asset(
              'assets/logo.png', // Remplace par ton logo
              width: 150, // Ajuste la taille
              height: 150,
            ),
          ),
        ),
      ),
    );
  }
}
