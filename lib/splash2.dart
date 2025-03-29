import 'package:flutter/material.dart';
import 'dart:async';
import 'login_page.dart';
import 'package:easy_localization/easy_localization.dart';

class Splash2 extends StatefulWidget {
  const Splash2({super.key});

  @override
  _Splash2State createState() => _Splash2State();
}

// 🔹 Classe d'état pour gérer l'animation et la logique de la page d'accueil.
class _Splash2State extends State<Splash2> {
  int currentIndex = 0; // Index actuel pour la PageView
  late PageController
  _pageController; // Contrôleur pour la navigation entre les pages

  @override
  void initState() {
    super.initState();
    _pageController = PageController(); // Initialisation du contrôleur de page

    // 🔹 Démarre un timer pour changer automatiquement de page après 3 secondes
    Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (currentIndex < 1) {
        currentIndex++;
        _pageController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        timer
            .cancel(); // Arrête le timer une fois qu'on est sur la dernière page
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 PageView pour afficher plusieurs écrans dans un effet de glissement
          PageView(
            controller: _pageController,
            children: [
              // Première page du splash screen
              buildSplashPage(
                icon: Icons.search,
                title: "search_train".tr(), // Texte traduit
                subtitle: "search_subtitle".tr(), // Texte traduit
                isFirst: true,
              ),
              // Deuxième page du splash screen
              buildSplashPage(
                icon: Icons.access_time,
                title: "save_time".tr(), // Texte traduit
                subtitle: "save_time_subtitle".tr(), // Texte traduit
                isFirst: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔹 Widget qui construit chaque page du splash screen
  Widget buildSplashPage({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isFirst,
  }) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 209, 248, 239),
            Color(0xFF81D4FA),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🔹 Icône entourée d'un cercle blanc
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 5),
            ),
            child: Icon(icon, size: 80, color: Colors.white),
          ),
          const SizedBox(height: 30),

          // 🔹 Titre de la page
          Text(
            title,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),

          // 🔹 Sous-titre explicatif
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 30),

          // 🔹 Indicateurs de pages
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildDot(isActive: isFirst),
              buildDot(isActive: !isFirst),
            ],
          ),

          // 🔹 Bouton "COMMENCER" qui s'affiche uniquement sur la deuxième page
          if (!isFirst) const SizedBox(height: 50),
          if (!isFirst)
            ElevatedButton(
              onPressed: () {
                // Navigation vers la page de connexion
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 219, 252, 244),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 70,
                  vertical: 15,
                ),
              ),
              child: Text(
                "start".tr(), // Texte traduit
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 🔹 Fonction qui construit un indicateur de page (dot)
  Widget buildDot({required bool isActive}) {
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
