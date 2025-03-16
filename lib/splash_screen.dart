import 'package:flutter/material.dart';
import 'dart:async';
import 'splash2.dart'; // Import de la page de connexion

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    //Redirige vers la page de connexion après 3 secondes
    Timer(const Duration(seconds: 3), () {
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
              Color(0xFF81D4FA), // Bleu ciel plus foncé
              Color(0xFFFFFFFF), // Blanc pur
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 5),
              ),
              child: const Icon(
                Icons.search,
                size: 89, // Réduit la taille
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Search for your train",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                "No need to get to the train station to check for your train",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [buildDot(true), buildDot(false)],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.black : Colors.white,
        border: Border.all(color: Colors.black),
      ),
    );
  }
}
