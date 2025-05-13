import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class TrainDetectionPage extends StatefulWidget {
  // Plus besoin de passer userId dans le constructeur

  @override
  _TrainDetectionPageState createState() => _TrainDetectionPageState();
}

class _TrainDetectionPageState extends State<TrainDetectionPage> {
  final _dbRef = FirebaseDatabase.instance.ref('trains');
  bool isTripActive = false; // Suivre si un trajet est en cours
  late String tripId; // Identifier le trajet en cours
  late String userId; // Stocker l'ID de l'utilisateur

  @override
  void initState() {
    super.initState();
    getUserId(); // Obtenir automatiquement l'ID de l'utilisateur
    detectTrainProximity();
  }

  Future<void> getUserId() async {
    // Récupérer l'ID de l'utilisateur actuellement authentifié
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid; // Récupérer l'ID de l'utilisateur
      });
    } else {
      // Si l'utilisateur n'est pas connecté, rediriger ou afficher un message
      print('Utilisateur non connecté');
    }
  }

  Future<void> detectTrainProximity() async {
    // Obtenir la position de l'utilisateur
    Position userPos = await Geolocator.getCurrentPosition();

    _dbRef.onValue.listen((event) {
      final trains = Map<String, dynamic>.from(event.snapshot.value as Map);
      trains.forEach((id, data) async {
        final train = Map<String, dynamic>.from(data);
        final trainLat = train['latitude'];
        final trainLon = train['longitude'];
        final ligne = train['ligne'];
        final vitesse = train['speed'];
        final date = DateTime.now().toIso8601String();

        double distance = Geolocator.distanceBetween(
          userPos.latitude,
          userPos.longitude,
          trainLat,
          trainLon,
        );

        
        if (distance < 60 && !isTripActive) {
          // Démarrer un trajet si la distance est inférieure à 60m
          isTripActive = true;

          // Sauvegarder le trajet dans Firestore
          DocumentReference tripRef = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId) // Utiliser automatiquement l'ID de l'utilisateur
              .collection('trips')
              .add({
            'trainId': id,
            'ligne': ligne,
            'startLocation': {'latitude': trainLat, 'longitude': trainLon},
            'date': date,
            'vitesse': vitesse,
            'status': 'in_progress', // Indiquer que le trajet est en cours
          });

          tripId = tripRef.id; // Enregistrer l'ID du trajet en cours
          print('Trajet démarré ✅');
        }

        // Vérifier la fin du trajet (distance > 60m)
        if (isTripActive && distance > 60) {
          // Mettre à jour le trajet pour le marquer comme terminé
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId) // Utiliser l'ID de l'utilisateur automatiquement
              .collection('trips')
              .doc(tripId) // Utiliser l'ID du trajet en cours
              .update({
            'status': 'completed', // Mettre à jour le statut du trajet
            'endLocation': {
              'latitude': userPos.latitude,
              'longitude': userPos.longitude,
            },
            'endDate': DateTime.now().toIso8601String(),
          });

          isTripActive = false; // Le trajet est terminé
          print('Trajet terminé ✅');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Détection du train")),
      body: Center(child: Text("Analyse en cours...")),
    );
  }
}
