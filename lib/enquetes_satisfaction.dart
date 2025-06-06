import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SatisfactionSurveyPage extends StatefulWidget {
  @override
  _SatisfactionSurveyPageState createState() => _SatisfactionSurveyPageState();
}

class _SatisfactionSurveyPageState extends State<SatisfactionSurveyPage> {
  final _formKey = GlobalKey<FormState>();
  Map<int, int> ratings = {};
  TextEditingController suggestionController = TextEditingController();
  TextEditingController serviceAjouteController = TextEditingController();

  Widget buildRatingStars(int questionIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (starIndex) {
        return IconButton(
          icon: Icon(
            Icons.star,
            color:
                ratings[questionIndex] != null &&
                        ratings[questionIndex]! > starIndex
                    ? Colors.blue
                    : Colors.grey[300],
          ),
          onPressed: () {
            setState(() {
              ratings[questionIndex] = starIndex + 1;
            });
          },
        );
      }),
    );
  }

  List<String> questions = [
    " 1.Le suivi en temps réel est-il précis ?",
    "2.La traçabilité des trajets vous satisfait-elle ?",
    "3.Les alertes/notifications sont-elles fiables ?",
    "4.La messagerie est-elle utile ?",
    "5.L’application est-elle facile à utiliser ?",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text('Feedback'), backgroundColor: Colors.white),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            ...List.generate(questions.length, (index) {
              return Column(
                children: [
                  Text(
                    questions[index],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  buildRatingStars(index),
                  SizedBox(height: 16),
                ],
              );
            }),
            Text(
              "6.Avez-vous rencontré des problèmes ?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: serviceAjouteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Entrez votre réponse",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "7.Quels services voudriez-vous ajouter ?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: suggestionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Entrez votre suggestion",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    // Récupère l'utilisateur connecté
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      // Enregistre les réponses dans Firestore
                      await FirebaseFirestore.instance
                          .collection('feedbacks')
                          .add({
                            'userId': user.uid, // Identifiant de l'utilisateur
                            'timestamp':
                                DateTime.now()
                                    .toIso8601String(), // Heure de l'envoi
                            'q1': ratings[0], // Note question 1
                            'q2': ratings[1], // Note question 2
                            'q3': ratings[2], // Note question 3
                            'q4': ratings[3], // Note question 4
                            'q5': ratings[4], // Note question 5
                            'problemes':
                                serviceAjouteController
                                    .text, // Text de la question "problèmes"
                            'suggestions':
                                suggestionController
                                    .text, // Text de la question "suggestions"
                          });

                      // Message de confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Réponses envoyées !')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Veuillez vous connecter.')),
                      );
                    }
                  } catch (e) {
                    print("Erreur : $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur d’envoi des réponses.')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                "Envoyer",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
