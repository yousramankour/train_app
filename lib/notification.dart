import 'package:appmob/tracker.dart';

import 'package:appmob/train.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 👉 Ajoute ta fonction remplirBaseDeDonnees ici ou importe-la si elle est ailleurs
Future<void> remplirBaseDeDonnees() async {
  List<String> userIds = ['userId1', 'userId2', 'userId3'];

  for (String userId in userIds) {
    for (int i = 0; i < 5; i++) {
      final trajet = {
        'trainid': 'Train-${1000 + i}',
        'ligne': 'Ligne-${String.fromCharCode(65 + i)}',
        'startLocation': 'Départ Ville ${i + 1}',
        'endLocation': 'Arrivée Ville ${i + 2}',
        'temp': Timestamp.fromDate(DateTime(2025, 4, 27, 7 + i, 0)),
        'arrivee': Timestamp.fromDate(DateTime(2025, 4, 27, 9 + i, 30)),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tri')
          .add(trajet);
    }
  }

  print('✅ Données remplies avec succès !');
}

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menu"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuButton(
              title: "Train",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrainPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            // MenuButton(
            // title: "Station",
            /* onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GroupListPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            MenuButton(
              title: "Lignes",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RailLinesScreen()),
                );
              },
            ),*/
            // const SizedBox(height: 20),
            MenuButton(
              title: "Gares",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => TripDetectionScreen(trainId: 'train1'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Le bouton personnalisé du menu
class MenuButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const MenuButton({super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 18),
      ),
      child: Text(title),
    );
  }
}
