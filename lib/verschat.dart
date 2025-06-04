import 'package:appmob/messageri.dart'; // Assure-toi que ChatScreen est dans ce fichier
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LinesListScreen extends StatelessWidget {
  const LinesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // fond blanc partout
      appBar: AppBar(
        backgroundColor: Colors.grey[100], // fond clair
        elevation: 0,
        title: const Text(
          'group chat',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('rail').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              // Chargement en cours
              return const Center(child: CircularProgressIndicator());
            }

            final lines = snapshot.data!.docs;

            if (lines.isEmpty) {
              return const Center(child: Text('Aucune ligne trouvée'));
            }

            return ListView.builder(
              itemCount: lines.length,
              itemBuilder: (context, index) {
                final lineDoc = lines[index];
                final lineName = lineDoc.id;

                return GestureDetector(
                  onTap: () {
                    // Navigation vers le chat en passant le nom de la ligne
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(lineName: lineName),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: ListTile(
                      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          lineName.isNotEmpty ? lineName[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      title: Text(lineName),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
