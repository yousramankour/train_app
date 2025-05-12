import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class TripDetectionScreen extends StatefulWidget {
  final String trainId;

  TripDetectionScreen({required this.trainId});

  @override
  _TripDetectionScreenState createState() => _TripDetectionScreenState();
}

class _TripDetectionScreenState extends State<TripDetectionScreen> {
  String statusMessage = "⏳ Analyse en cours...";
  String? gareProche;
  double? distanceTrain;
  bool trajetEnregistre = false;
  Timer? _monitorTimer;
  String? trainId;

  @override
  void initState() {
    super.initState();
    trainId = widget.trainId;
    _initializeTripDetection();
  }

  @override
  void dispose() {
    _monitorTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeTripDetection() async {
    await detectAndDisplayTrip(trainId!);
  }

  Future<void> detectAndDisplayTrip(String trainId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => statusMessage = "❌ Utilisateur non connecté !");
      return;
    }

    Position? userPosition = await _getUserPosition();
    if (userPosition == null) {
      setState(() => statusMessage = "❌ Position introuvable.");
      return;
    }

    final gareResult = await _findNearestGare(userPosition);
    if (gareResult == null) {
      setState(() => statusMessage = "🚫 Aucune gare proche.");
      return;
    }
    setState(() => gareProche = gareResult['nom']);

    final trainData = await _getTrainPosition(trainId);
    if (trainData == null) {
      setState(() => statusMessage = "🚫 Train introuvable.");
      return;
    }

    double distTrain = Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      trainData['latitude'],
      trainData['longitude'],
    );
    setState(() => distanceTrain = distTrain);

    if (gareResult['distance'] <= 100 && distTrain <= 100) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('historique')
          .add({
            'depart': gareResult['nom'],
            'arrivee': 'Bab Ezzouar',
            'ligne': trainData['ligne'],
            'date': Timestamp.now(),
            'duree': '00:20',
            'latitude_depart': gareResult['lat'],
            'longitude_depart': gareResult['lon'],
            'latitude_arrivee': trainData['latitude'],
            'longitude_arrivee': trainData['longitude'],
          });

      setState(() {
        statusMessage = "✅ Trajet enregistré depuis ${gareResult['nom']}";
        trajetEnregistre = true;
      });

      _startMonitoringExit(trainId);
    } else {
      setState(() => statusMessage = "📍 Trop loin de la gare ou du train.");
    }
  }

  void _startMonitoringExit(String trainId) {
    _monitorTimer = Timer.periodic(Duration(seconds: 10), (_) async {
      Position? currentPos = await _getUserPosition();
      if (currentPos == null) return;

      final trainData = await _getTrainPosition(trainId);
      if (trainData == null) return;

      double distanceFromTrain = Geolocator.distanceBetween(
        currentPos.latitude,
        currentPos.longitude,
        trainData['latitude'],
        trainData['longitude'],
      );

      final gareResult = await _findNearestGare(currentPos);

      if (distanceFromTrain > 150 &&
          gareResult != null &&
          gareResult['distance'] <= 100) {
        _monitorTimer?.cancel();
        setState(
          () => statusMessage = "📤 Descente détectée à ${gareResult['nom']}",
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('historique')
            .add({
              'descente_detectee': true,
              'position_descente': GeoPoint(
                currentPos.latitude,
                currentPos.longitude,
              ),
              'date_descente': Timestamp.now(),
              'arrivee': gareResult['nom'],
              'trainId': trainId,
            });
      }
    });
  }

  Future<Position?> _getUserPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<Map<String, dynamic>?> _findNearestGare(Position userPosition) async {
    final garesSnapshot =
        await FirebaseFirestore.instance.collection('gares').get();

    String? nearestGareName;
    double minDistance = double.infinity;
    double? nearestLat, nearestLon;

    for (var doc in garesSnapshot.docs) {
      final data = doc.data();
      final GeoPoint location = data['location'];
      double latitude = location.latitude;
      double longitude = location.longitude;

      double distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        latitude,
        longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestGareName = doc.id;
        nearestLat = latitude;
        nearestLon = longitude;
      }
    }

    if (nearestGareName != null) {
      return {
        'nom': nearestGareName,
        'distance': minDistance,
        'lat': nearestLat,
        'lon': nearestLon,
      };
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> _getTrainPosition(String trainId) async {
    final ref = FirebaseDatabase.instance.ref("trains/$trainId");
    final snapshot = await ref.get();

    if (!snapshot.exists) return null;

    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return {
      'latitude': double.tryParse(data['latitude'].toString()) ?? 0.0,
      'longitude': double.tryParse(data['longitude'].toString()) ?? 0.0,
      'ligne': data['ligne'] ?? 'Inconnue',
      'speed': data['speed'],
      'time': data['time'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Détection de Trajet')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(statusMessage, style: TextStyle(fontSize: 16)),
            if (gareProche != null) Text("🛤 Gare proche : $gareProche"),
            if (distanceTrain != null)
              Text(
                "🚆 Distance au train : ${distanceTrain!.toStringAsFixed(2)} m",
              ),
            if (trajetEnregistre) Text("📋 Trajet enregistré ✅"),
            SizedBox(height: 20),

            /// LE BOUTON DOIT ÊTRE ICI 👇
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('historique')
                      .add({
                        'depart': 'Gare A',
                        'arrivee': 'Gare B',
                        'ligne': 'Ligne 1',
                        'date': Timestamp.now(),
                        'duree': '00:18',
                        'latitude_depart': 36.732,
                        'longitude_depart': 3.087,
                        'latitude_arrivee': 36.713,
                        'longitude_arrivee': 3.099,
                        'mode': 'manuel',
                      });

                  setState(() {
                    statusMessage = "✅ Trajet manuel ajouté à l’historique.";
                    trajetEnregistre = true;
                  });
                } else {
                  setState(() {
                    statusMessage = "❌ Utilisateur non connecté.";
                  });
                }
              },
              child: Text('➕ Ajouter Trajet Manuel'),
            ),
          ],
        ),
      ),
    );
  }
}
