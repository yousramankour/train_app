import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'splash2.dart'; // Import de la page suivante

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.lightBlueAccent.shade100, // Fond bleu clair
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centrage du contenu
          children: [
            const Spacer(flex: 1), // Décalage vers le bas
            // Texte "Bienvenue sur"
            Text(
              "welcome".tr(), // Utilisation de la traduction
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40), // Espace entre les textes
            // Nom de l'application avec un style différent
            Text(
              "SmartRail",
              style: GoogleFonts.lobster(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 209, 248, 239),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20), // Espace avant l'animation
            // Animation Lottie
            Expanded(
              flex: 3,
              child: AnimatedSplashScreen(
                backgroundColor: Colors.transparent,
                splash: Lottie.asset("assets/lottie.json"),
                duration: 10000, // 10 secondes
                nextScreen: Splash2(),
                splashIconSize: 250,
                animationDuration: const Duration(milliseconds: 1500),
              ),
            ),

            const SizedBox(height: 40), // Espace après l'animation
            // Sous-titre
            Text(
              "loading".tr(), // Utilisation de la traduction
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color.fromARGB(255, 235, 233, 233),
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(flex: 1), // Décalage supplémentaire vers le bas
          ],
        ),
      ),
    );
  }
}
