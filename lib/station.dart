import 'package:flutter/material.dart';

class StationPage extends StatelessWidget {
  const StationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Page Station")),
      body: Center(child: Text("Bienvenue dans la page Station")),
    );
  }
}
