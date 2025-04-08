import 'package:flutter/material.dart';

class AProposPage extends StatelessWidget {
  const AProposPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("À propos"), backgroundColor: Color(0xFF2196F3)),
      body: const Center(child: Text("Page À propos (guide à venir)")),
    );
  }
}
