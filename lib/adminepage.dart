import 'package:flutter/material.dart';
import 'train.dart';
import 'line.dart';
import 'gars.dart';
import 'station.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  void navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Panneau d'administration"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            buildButton("Gars", Icons.person, Colors.blue, GarsPage()),
            buildButton("Train", Icons.train, Colors.green, TrainPage()),
            buildButton("Ligne", Icons.timeline, Colors.orange, LignePage()),
            buildButton(
              "Station",
              Icons.location_on,
              Colors.purple,
              StationPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(String title, IconData icon, Color color, Widget page) {
    return ElevatedButton(
      onPressed: () => navigateTo(page),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.all(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.white),
          SizedBox(height: 10),
          Text(title, style: TextStyle(fontSize: 18, color: Colors.white)),
        ],
      ),
    );
  }
}
