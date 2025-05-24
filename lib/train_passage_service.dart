import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class TrainService {
  static Future<List<Map<String, dynamic>>> verifierPassageTousTrains() async {
    final rtdb = FirebaseDatabase.instance;
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);

    final List<Map<String, dynamic>> resultats = [];

    try {
      final trainsSnap = await rtdb.ref('trains').get();
      if (!trainsSnap.exists)
        return [
          {'error': "Aucun train trouvé dans RTDB"},
        ];

      final Map<String, dynamic> allTrains = Map<String, dynamic>.from(
        trainsSnap.value as Map,
      );

      for (final entry in allTrains.entries) {
        final nomTrain = entry.key;
        final Map trainData = Map<String, dynamic>.from(entry.value);

        final double? trainLat = (trainData['latitude'] as num?)?.toDouble();
        final double? trainLng = (trainData['longitude'] as num?)?.toDouble();
        final String? ligne = trainData['ligne'] as String?;

        if (trainLat == null || trainLng == null || ligne == null) {
          resultats.add({'train': nomTrain, 'error': "Données invalides"});
          continue;
        }

        final railDoc = await firestore.collection('rail').doc(ligne).get();
        if (!railDoc.exists) {
          resultats.add({'train': nomTrain, 'error': "Ligne introuvable"});
          continue;
        }

        final List<String> gares = List<String>.from(railDoc['gares']);
        const double seuil = 20000; // 2 km
        double? minDist;
        String? closest;

        for (final nomG in gares) {
          final doc = await firestore.collection('gares').doc(nomG).get();
          if (!doc.exists) continue;

          final data = doc.data()!;
          if (data['coordinates'] is GeoPoint) {
            final GeoPoint gp = data['coordinates'];
            final d = Geolocator.distanceBetween(
              trainLat,
              trainLng,
              gp.latitude,
              gp.longitude,
            );
            if (d <= seuil && (minDist == null || d < minDist)) {
              minDist = d;
              closest = nomG;
            }
          }
        }

        if (closest == null) {
          resultats.add({
            'train': nomTrain,
            'error': "Aucune gare proche détectée",
          });
          continue;
        }

        // Enregistrer le passage
        await firestore.collection('passages').add({
          'train': nomTrain,
          'gare': closest,
          'ligne': ligne,
          'timestamp': Timestamp.now(),
        });

        final docRef = firestore
            .collection('frequence_passage')
            .doc('$ligne\_$today');
        final snap = await docRef.get();

        int frequence = 0;
        Map<String, dynamic> trains = {};
        if (snap.exists) {
          final data = snap.data()!;
          frequence = data['frequence'] ?? 0;
          trains = Map<String, dynamic>.from(data['trains'] ?? {});
        }

        List<dynamic> garesVis = trains[nomTrain]?['garesVisitees'] ?? [];
        Map<String, dynamic> stamps = Map<String, dynamic>.from(
          trains[nomTrain]?['timestamps'] ?? {},
        );

        bool timeout = false;
        if (stamps.containsKey(closest)) {
          final lastTs = (stamps[closest] as Timestamp).toDate();
          if (now.difference(lastTs).inHours >= 1) timeout = true;
        } else {
          timeout = true;
        }

        if (!garesVis.contains(closest)) garesVis.add(closest);
        stamps[closest] = Timestamp.now();

        bool trajetComplet = garesVis.toSet().containsAll(gares.toSet());
        if (timeout || trajetComplet) frequence += 1;

        if (trajetComplet) {
          garesVis = [];
          stamps = {};
        }

        await docRef.set({
          'date': today,
          'frequence': frequence,
          'trains': {
            ...trains,
            nomTrain: {'garesVisitees': garesVis, 'timestamps': stamps},
          },
        }, SetOptions(merge: true));

        resultats.add({
          'train': nomTrain,
          'status': "Passage à $closest (${minDist!.toStringAsFixed(0)} m)",
          'frequence': frequence,
          'gare': closest,
          'ligne': ligne,
        });
      }

      return resultats;
    } catch (e) {
      return [
        {'error': e.toString()},
      ];
    }
  }
}
