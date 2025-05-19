import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'train_passage_service.dart';
import 'dart:async';

class StatistiqueGareScreen extends StatefulWidget {
  @override
  _StatistiqueGareScreenState createState() => _StatistiqueGareScreenState();
}

class _StatistiqueGareScreenState extends State<StatistiqueGareScreen> {
  Position? _currentPosition;
  String? _gareProche;
  Map<String, int> _votes = {'faible': 0, 'moyenne': 0, 'forte': 0};
  String _niveauDominant = '';
  Map<String, int> _votesParSexe = {'Homme': 0, 'Femme': 0};
  Map<String, int> _votesParAge = {
    'moins de 18': 0,
    '18-30': 0,
    '31-45': 0,
    '46+': 0,
  };

  // Variables pour les fonctionnalités avancées
  String passageStatus = '';
  int frequencePassage = 0;
  Map<String, int> panne = {'panne': 0, 'retard': 0};
  Map<String, int> frequenceParLigne = {};

  // Gestion des notifications
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Timer? _proximityTimer;
  bool _notificationSent = false;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _initAll();
  }

  @override
  void dispose() {
    _proximityTimer?.cancel();
    super.dispose();
  }

  Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('logoapp');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'channelId',
          'channelName',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> _sendProximityNotification(String gareId) async {
    try {
      final gareDoc =
          await FirebaseFirestore.instance
              .collection('gares')
              .doc(gareId)
              .get();

      final gareName = gareDoc.data()?['nom'] ?? 'la gare';
      final niveau = _niveauDominant.toLowerCase();

      String message = "Aide-nous à faire l'estimation !";

      await _showNotification("Affluence à $gareName", message);

      // Sauvegarder dans la base de données
      await FirebaseFirestore.instance.collection('notification').add({
        'etat': 'affluence',
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _notificationSent = true;
    } catch (e) {
      print('Erreur envoi notification: $e');
    }
  }

  Future<void> _initAll() async {
    await _obtenirPosition();
    await chargerStatistiquesUtilisateurs();
    await chargerstatstiquepanneetretard();
    await chargerFrequencePassages();
    await verifierPassage();
  }

  Future<void> verifierPassage() async {
    final result = await TrainService.verifierPassageTrain("train1");
    if (result.containsKey('error')) {
      setState(() => passageStatus = "Erreur: ${result['error']}");
    } else {
      setState(() {
        passageStatus = result['status'];
        frequencePassage = result['frequence'];
      });
    }
  }

  Future<void> chargerstatstiquepanneetretard() async {
    final allNotifications =
        await FirebaseFirestore.instance.collection('notification').get();

    final Map<String, int> stats = {'panne': 0, 'retard': 0};

    for (var notificat in allNotifications.docs) {
      final etat = notificat.data()['etat']?.toString().toLowerCase();
      if (etat == 'panne')
        stats['panne'] = stats['panne']! + 1;
      else if (etat == 'retard')
        stats['retard'] = stats['retard']! + 1;
    }

    setState(() => panne = stats);
  }

  Future<void> chargerStatistiquesUtilisateurs() async {
    final allUsers = await FirebaseFirestore.instance.collection('users').get();
    final Map<String, int> tempSexe = {'Homme': 0, 'Femme': 0};
    final Map<String, int> tempAge = {
      'moins de 18': 0,
      '18-30': 0,
      '31-45': 0,
      '46+': 0,
    };

    for (var user in allUsers.docs) {
      final data = user.data();
      final rawSexe = (data['sex'] ?? '').toString().toLowerCase().trim();

      if (rawSexe == 'homme' || rawSexe == 'man') {
        tempSexe['Homme'] = tempSexe['Homme']! + 1;
      } else if (rawSexe == 'femme' || rawSexe == 'woman') {
        tempSexe['Femme'] = tempSexe['Femme']! + 1;
      }

      int? age;
      try {
        age = int.parse(data['age'].toString());
      } catch (_) {
        age = null;
      }

      tempAge['moins de 18'] = tempAge['moins de 18']! + 1;
      tempAge['18-30'] = tempAge['18-30']! + 1;
      tempAge['31-45'] = tempAge['31-45']! + 1;
      tempAge['46+'] = tempAge['46+']! + 1;
    }

    setState(() {
      _votesParSexe = tempSexe;
      _votesParAge = tempAge;
    });
  }

  Future<void> _obtenirPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => passageStatus = "Service de localisation désactivé.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => passageStatus = "Permission refusée.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => passageStatus = "Permission définitivement refusée.");
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      await _verifierGareProche();
    } catch (e) {
      setState(() => passageStatus = "Erreur: ${e.toString()}");
    }
  }

  Future<void> _verifierGareProche() async {
    final gares = await FirebaseFirestore.instance.collection('gares').get();

    // Réinitialiser la notification si on change de gare
    _proximityTimer?.cancel();
    _notificationSent = false;

    String? closestGareId;
    double minDistance = double.infinity;

    for (var doc in gares.docs) {
      final geoPoint = doc.data()['coordinates'] as GeoPoint?;
      if (geoPoint == null || _currentPosition == null) continue;

      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        geoPoint.latitude,
        geoPoint.longitude,
      );

      if (distance < minDistance && distance <= 50000) {
        // 500 mètres
        minDistance = distance;
        closestGareId = doc.id;
      }
    }

    setState(() => _gareProche = closestGareId);

    if (_gareProche != null) {
      await _chargerVotes();

      // Démarrer le timer de 5 minutes
      _proximityTimer = Timer(Duration(minutes: 1), () async {
        if (!_notificationSent && _gareProche != null) {
          await _sendProximityNotification(_gareProche!);
        }
      });
    }
  }

  Future<void> _chargerVotes() async {
    if (_gareProche == null) return;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(Duration(days: 1));

    final allUsers = await FirebaseFirestore.instance.collection('users').get();
    final Map<String, int> tempVotes = {'faible': 0, 'moyenne': 0, 'forte': 0};

    for (var user in allUsers.docs) {
      final voteDoc =
          await user.reference.collection('votes').doc(_gareProche).get();

      if (voteDoc.exists) {
        final data = voteDoc.data()!;
        final niveau = data['niveau']?.toString().toLowerCase();
        final timestamp = data['date'] as Timestamp?;

        if (niveau != null && tempVotes.containsKey(niveau)) {
          if (timestamp == null ||
              (timestamp.toDate().isAfter(todayStart) &&
                  timestamp.toDate().isBefore(todayEnd))) {
            tempVotes[niveau] = tempVotes[niveau]! + 1;
          }
        }
      }
    }

    final dominant =
        tempVotes.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      _votes = tempVotes;
      _niveauDominant = dominant.isNotEmpty ? dominant.first.key : 'Aucun';
    });
  }

  Future<void> chargerFrequencePassages() async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref('trains');
      DatabaseEvent event = await ref.once();

      if (!event.snapshot.exists) return;

      final dynamic value = event.snapshot.value;
      if (value == null || value is! Map) return;

      Map<dynamic, dynamic> trainsData = value;
      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      Map<String, int> frequenceTemp = {};

      trainsData.forEach((key, value) {
        if (value is Map) {
          final train = Map<String, dynamic>.from(value);
          final String? ligne = train['ligne']?.toString();
          final String? temps = train['temps']?.toString();

          if (ligne != null && temps != null) {
            final datePassage = DateTime.tryParse(temps);
            if (datePassage != null &&
                DateFormat('yyyy-MM-dd').format(datePassage) == today) {
              frequenceTemp[ligne] = (frequenceTemp[ligne] ?? 0) + 1;
            }
          }
        }
      });

      setState(() => frequenceParLigne = frequenceTemp);
    } catch (e) {
      print('Erreur fréquences: $e');
    }
  }

  Future<void> _voter(String niveau) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null || _gareProche == null) return;

      final now = Timestamp.now();
      final voteData = {'gare': _gareProche, 'niveau': niveau, 'date': now};

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('votes')
          .doc(_gareProche)
          .set(voteData);

      await _chargerVotes();
    } catch (e) {
      print('Erreur vote: $e');
    }
  }

  Widget _buildStatCard(
    String title,
    IconData icon,
    String content,
    Color color,
  ) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        subtitle: Text(content),
      ),
    );
  }

  Widget _buildVoteButton(String niveau, Color color, IconData icon) {
    return ElevatedButton(
      onPressed: () => _voter(niveau),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 8),
          Text(niveau, style: TextStyle(color: Colors.white)),
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  Widget _buildVotesTable() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🗳️ Détail des votes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Divider(),
            ..._votes.entries.map(
              (entry) => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(entry.key), Text('${entry.value}')],
                  ),
                  Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSexeStatsTable() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🧑‍🤝‍🧑 Votes par sexe',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Divider(),
            ..._votesParSexe.entries.map(
              (entry) => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(entry.key), Text('${entry.value}')],
                  ),
                  Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeStatsTable() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎂 Votes par âge',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Divider(),
            ..._votesParAge.entries.map(
              (entry) => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(entry.key), Text('${entry.value}')],
                  ),
                  Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanneStatsTable() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚠️ Pannes et retards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Divider(),
            ...panne.entries.map(
              (entry) => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text(entry.key), Text('${entry.value}')],
                  ),
                  Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassageInfo() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🚆 Statut des trains',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Statut:'), Text(passageStatus)],
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Fréquence:'), Text('$frequencePassage')],
            ),
            if (frequenceParLigne.isNotEmpty) ...[
              Divider(),
              Text(
                'Fréquence par ligne:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              ...frequenceParLigne.entries.map(
                (entry) => Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text(entry.key), Text('${entry.value}')],
                    ),
                    Divider(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVoteOptions() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildVoteButton('faible', Colors.green, Icons.thumb_up),
            _buildVoteButton('moyenne', Colors.orange, Icons.thumbs_up_down),
            _buildVoteButton('forte', Colors.red, Icons.thumb_down),
          ],
        ),
        SizedBox(height: 20),
        _buildVotesTable(),
        _buildSexeStatsTable(),
        _buildAgeStatsTable(),
        _buildPanneStatsTable(),
        _buildPassageInfo(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistiques des gares'),
        backgroundColor: Colors.blue,
      ),
      body:
          _gareProche == null
              ? Center(child: Text('Aucune gare proche trouvée.'))
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatCard(
                      '📍 Gare la plus proche',
                      Icons.train,
                      _gareProche ?? 'Aucune',
                      Colors.blue,
                    ),
                    _buildStatCard(
                      '💡 Niveau dominant',
                      Icons.bar_chart,
                      _niveauDominant,
                      Colors.purple,
                    ),
                    SizedBox(height: 16),
                    _buildVoteOptions(),
                  ],
                ),
              ),
    );
  }
}
