import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'dart:developer' as developer;

class Appobservation with WidgetsBindingObserver {
  static bool isAppInForeground = true;

  static void startObserver() {
    WidgetsBinding.instance.addObserver(Appobservation());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    isAppInForeground = (state == AppLifecycleState.resumed);
    developer.log("App is in foreground: $isAppInForeground");
  }

  //fonction pour supprimer les donner d'apres fairebase apres une period donner
  Future<void> deletfromfairebase(
    String nomcollection,
    Duration maxtemps,
  ) async {
    final now = DateTime.now();
    final limitDate = now.subtract(maxtemps);
    final collection = FirebaseFirestore.instance.collection(nomcollection);
    try {
      final querySnapshot =
          await collection
              .where('timestamp', isLessThan: Timestamp.fromDate(limitDate))
              .get();
      for (var doc in querySnapshot.docs) {
        await collection.doc(doc.id).delete();
        print("document suprimer:${doc.id}");
      }
      print("suppression terminee.");
    } catch (e) {
      print("erreur lors de la suppression des documents : &e");
    }
  }
}
