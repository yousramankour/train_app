import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const MyApp()); // Ajout de 'const' pour optimiser les performances
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Ajout de la clé pour optimiser l'application

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Train App", // Ajout d'un titre pour l'application
      theme: ThemeData(
        primarySwatch: Colors.blue, // Ajout d'un thème de couleur principal
      ),
      home: SplashScreen(), // Ajout de 'const' pour optimiser l'affichage
    );
  }
}
