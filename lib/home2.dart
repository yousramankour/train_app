import 'package:flutter/material.dart';

class home2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🔹 Barre bleue en haut
          Container(
            width: double.infinity,
            height: 40,
            color: Color(0xFFB3D8EB),
          ),

          const SizedBox(height: 30),
          // 🔹 Espace pour l'image du train et le texte de bienvenue
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            height: 190,
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 183, 223, 242),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Image à gauche
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    "assets/amico.png", // Remplacez par le chemin de votre image
                    width: 200, // Ajustez la taille de l'image
                    height: 210, // Ajustez la taille de l'image
                  ),
                ),
                // Texte à droite
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "welcome Back ! ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 90),

          // 🔹 Boutons avec largeur et hauteur personnalisables
          Column(
            children: [
              // Premier bouton
              SizedBox(
                width: 280, // Largeur moyenne (PAS toute la largeur)
                height: 50, // Hauteur fixe
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 172, 219, 241),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Action du premier bouton
                  },
                  child: Text(
                    "UPDATE / DELETE TRAIN",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25), // Espace entre les boutons
              // Deuxième bouton
              SizedBox(
                width: 280, // Largeur moyenne (PAS toute la largeur)
                height: 50, // Hauteur fixe
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 172, 219, 241),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Action du deuxième bouton
                  },
                  child: Text(
                    "ADD TRAIN",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const Spacer(), // Ajoute un espace flexible
          // 🔹 Image en bas + LOG OUT centré
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                "assets/build.png",
                width: double.infinity,
                height: 210,
                fit: BoxFit.cover,
              ),
              ElevatedButton(
                onPressed: () {
                  print("Déconnexion");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor:
                      Colors.blue, // Remplacez 'color.bleu' par 'Colors.blue'
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                  elevation: 5,
                ),
                child: Text(
                  "LOG OUT",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          // 🔹 Barre bleue en bas
          Container(
            width: double.infinity,
            height: 40,
            color: Color(0xFFB3D8EB),
          ),
        ],
      ),
    );
  }
}
