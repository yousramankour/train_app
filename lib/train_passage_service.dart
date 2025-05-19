import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class TrainService {
  static Future<Map<String, dynamic>> verifierPassageTrain(
    String nomTrain,
  ) async {
    final rtdb = FirebaseDatabase.instance;
    final firestore = FirebaseFirestore.instance;

    try {
      final trainSnap = await rtdb.ref('trains/$nomTrain').get();
      if (!trainSnap.exists) return {'error': "Train non trouvé dans RTDB"};

      final trainData = Map<String, dynamic>.from(trainSnap.value as Map);
      final double? trainLat = (trainData['latitude'] as num?)?.toDouble();
      final double? trainLng = (trainData['longitude'] as num?)?.toDouble();
      final String? ligne = trainData['ligne'] as String?;
      if (trainLat == null || trainLng == null || ligne == null) {
        return {'error': "Données train invalides"};
      }

      final railDoc = await firestore.collection('rail').doc(ligne).get();
      if (!railDoc.exists) return {'error': "Ligne introuvable"};

      final List<String> gares = List<String>.from(railDoc['gares']);
      const double seuil = 50000; // 2 km
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

      if (closest == null) return {'error': "Aucune gare proche détectée."};

      await firestore.collection('passages').add({
        'train': nomTrain,
        'gare': closest,
        'ligne': ligne,
        'timestamp': Timestamp.now(),
      });

      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      final docRef = firestore
          .collection('frequence_passage')
          .doc('$ligne\_$today');
      final snap = await docRef.get();

      int frequence = 0;
      Map<String, dynamic> trains = {};
      if (snap.exists) {
        final data = snap.data()!;
        frequence = data['frequence'] ?? 0;
        trains = Map.from(data['trains'] ?? {});
      }

      List<dynamic> garesVis = trains[nomTrain]?['garesVisitees'] ?? [];
      Map<String, dynamic> stamps = Map.from(
        trains[nomTrain]?['timestamps'] ?? {},
      );

      bool timeout = false;
      if (stamps.containsKey(closest)) {
        final lastTs = (stamps[closest] as Timestamp).toDate();
        if (now.difference(lastTs).inHours >= 8) {
          timeout = true;
        }
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
        'frequence': frequence,
        'trains': {
          ...trains,
          nomTrain: {'garesVisitees': garesVis, 'timestamps': stamps},
        },
      }, SetOptions(merge: true));

      return {
        'status': "Passage à $closest (${minDist!.toStringAsFixed(0)} m)",
        'frequence': frequence,
        'gare': closest,
        'ligne': ligne,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
