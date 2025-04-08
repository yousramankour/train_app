import 'package:flutter/material.dart';

class HistoriquePage extends StatelessWidget {
  const HistoriquePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Historique"), backgroundColor: Color(0xFF2196F3)),
      body: const Center(child: Text("Page Historique (à remplir)")),
    );
  }
}
