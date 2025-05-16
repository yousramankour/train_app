import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class StatistiqueGareScreen extends StatefulWidget {
  const StatistiqueGareScreen({super.key});

  @override
  StatistiqueGareScreenState createState() => StatistiqueGareScreenState();
}

class StatistiqueGareScreenState extends State<StatistiqueGareScreen> {
  Position? _currentPosition;
  String? _gareProche;
  Map<String, int> _votes = {'faible': 0, 'moyenne': 0, 'forte': 0};
  String _niveauDominant = '';
  Map<String, int> _votesParSexe = {'Homme': 0, 'Femme': 0, 'Autre': 0};
  Map<String, int> _votesParAge = {
    'moins de 18': 0,
    '18-30': 0,
    '31-45': 0,
    '46+': 0,
  };

  @override
  void initState() {
    super.initState();
    _obtenirPosition();
    chargerStatistiquesUtilisateurs();
  }

  Future<void> chargerStatistiquesUtilisateurs() async {
    final allUsers = await FirebaseFirestore.instance.collection('users').get();
    final Map<String, int> tempSexe = {'Homme': 0, 'Femme': 0, 'Autre': 0};
    final Map<String, int> tempAge = {
      'moins de 18': 0,
      '18-30': 0,
      '31-45': 0,
      '46+': 0,
    };

    for (var user in allUsers.docs) {
      final data = user.data();
      final rawSexe = (data['sex'] ?? 'Autre').toString().toLowerCase().trim();
      String sexe;
      if (rawSexe == 'homme' || rawSexe == 'man') {
        sexe = 'Homme';
      } else if (rawSexe == 'femme' || rawSexe == 'woman') {
        sexe = 'Femme';
      } else {
        sexe = 'Autre';
      }
      tempSexe[sexe] = tempSexe[sexe]! + 1;

      int? age;
      try {
        age = int.parse(data['age'].toString());
      } catch (_) {
        age = null;
      }

      if (age != null) {
        if (age < 18) {
          tempAge['moins de 18'] = tempAge['moins de 18']! + 1;
        } else if (age <= 30) {
          tempAge['18-30'] = tempAge['18-30']! + 1;
        } else if (age <= 45) {
          tempAge['31-45'] = tempAge['31-45']! + 1;
        } else {
          tempAge['46+'] = tempAge['46+']! + 1;
        }
      }
    }

    setState(() {
      _votesParSexe = tempSexe;
      _votesParAge = tempAge;
    });
  }

  Future<void> _obtenirPosition() async {
    _currentPosition = await Geolocator.getCurrentPosition();
    _verifierGareProche();
  }

  Future<void> _verifierGareProche() async {
    final gares = await FirebaseFirestore.instance.collection('gares').get();

    for (var doc in gares.docs) {
      final data = doc.data();
      final geoPoint = data['coordinates'] as GeoPoint;
      final lat = geoPoint.latitude;
      final lng = geoPoint.longitude;

      final distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        lat,
        lng,
      );

      if (distance <= 150000) {
        setState(() => _gareProche = doc.id);
        await _chargerVotes();
        return;
      }
    }

    setState(() => _gareProche = null);
  }

  Future<void> _chargerVotes() async {
    final allUsers = await FirebaseFirestore.instance.collection('users').get();
    final Map<String, int> tempVotes = {'faible': 0, 'moyenne': 0, 'forte': 0};

    for (var user in allUsers.docs) {
      final voteDoc =
          await user.reference.collection('votes').doc(_gareProche).get();
      if (voteDoc.exists) {
        final niveau = voteDoc.data()!['niveau'];
        tempVotes[niveau] = (tempVotes[niveau] ?? 0) + 1;
      }
    }

    final dominant =
        tempVotes.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    setState(() {
      _votes = tempVotes;
      _niveauDominant = dominant.isNotEmpty ? dominant.first.key : 'Aucun';
    });
  }

  Future<void> _voter(String niveau) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final now = Timestamp.now();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('votes_history')
        .add({'gare': _gareProche, 'niveau': niveau, 'date': now});

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('votes')
        .doc(_gareProche)
        .set({'gare': _gareProche, 'niveau': niveau, 'date': now});

    await _chargerVotes();
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
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 255, 255, 255)),
          SizedBox(width: 8),
          Text(niveau, style: TextStyle(color: Colors.white)),
        ],
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
              '🗳️ Détail des votes enregistrés',
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
