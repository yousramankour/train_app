//import 'package:appmob/historique.dart';
import 'package:appmob/tracker.dart';
//import 'package:appmob/train.dart';
import 'package:flutter/material.dart';

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
                /*Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrainPage()),
                );*/
              },
            ),
            const SizedBox(height: 20),
            MenuButton(
              title: "Station",
              onPressed: () {
                /*Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TripHistoryPage()),
                );*/
              },
            ),
            const SizedBox(height: 20),
            MenuButton(
              title: "Lignes",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrainDetectionPage()),
                );
              },
            ),
            const SizedBox(height: 20),
            MenuButton(
              title: "Gares",
              onPressed: () {
                // Action pour Gares
              },
            ),
          ],
        ),
      ),
    );
  }
}

// الزر المخصص للقائمة
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
