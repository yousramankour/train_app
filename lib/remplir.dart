import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> remplirBaseDeDonnees() async {
  // 🔥 Liste d'ID utilisateurs (à remplacer par tes vrais IDs dans Firebase Auth)
  List<String> userIds = [
    'userId1',
    'userId2',
    'userId3',
    // Ajoute autant d'IDs que tu veux
  ];

  // 🔥 Boucle sur tous les users
  for (String userId in userIds) {
    // On veut ajouter plusieurs trajets pour chaque user
    for (int i = 0; i < 5; i++) {
      final trajet = {
        'trainid': 'Train-${1000 + i}',
        'ligne': 'Ligne-${String.fromCharCode(65 + i)}', // A, B, C, D, E...
        'startLocation': 'Départ Ville ${i + 1}',
        'endLocation': 'Arrivée Ville ${i + 2}',
        'temp': Timestamp.fromDate(DateTime(2025, 4, 27, 7 + i, 0)), // Heure départ
        'arrivee': Timestamp.fromDate(DateTime(2025, 4, 27, 9 + i, 30)), // Heure arrivée
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tri') // Attention : c'est bien 'tri' ta sous-collection
          .add(trajet);
    }
  }

  print('✅ Base de données remplie avec succès !');
}
