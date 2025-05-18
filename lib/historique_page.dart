import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class TripHistoryPage extends StatefulWidget {
  const TripHistoryPage({super.key});

  @override
  State<TripHistoryPage> createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends State<TripHistoryPage> {
  List<Map<String, dynamic>> tripHistory = [];

  @override
  void initState() {
    super.initState();
    fetchTrips();
  }

  Future<void> fetchTrips() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final tripsSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('historique')
            .get();

    final trips =
        tripsSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'trainId': data['trainid'] ?? '',
            'line': data['ligne'] ?? '',
            'startLocation': data['startLocation'] ?? '',
            'endLocation': data['endLocation'] ?? '',
            'startTime': data['temp'],
            'endTime': data['arrivee'],
          };
        }).toList();

    setState(() {
      tripHistory = trips;
    });
  }

  String formatDateTime(dynamic timeData) {
    if (timeData == null) return tr('inconnu');
    try {
      DateTime dateTime;
      if (timeData is Timestamp) {
        dateTime = timeData.toDate();
      } else if (timeData is String) {
        dateTime = DateTime.parse(timeData);
      } else {
        return tr('format_invalide');
      }
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return tr('erreur');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('historique_des_trajets'.tr()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body:
          tripHistory.isEmpty
              ? Center(child: Text('aucun_trajet_trouve'.tr()))
              : ListView.builder(
                itemCount: tripHistory.length,
                itemBuilder: (context, index) {
                  final trip = tripHistory[index];
                  return Card(
                    color: Colors.grey[100],
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      title: Text('${trip['trainId']} - ${trip['line']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${tr('depart')} : ${trip['startLocation']} ${tr('a')} ${formatDateTime(trip['startTime'])}',
                          ),
                          Text(
                            '${tr('arrivee')} : ${trip['endLocation']} ${tr('a')} ${formatDateTime(trip['endTime'])}',
                          ),
                        ],
                      ),
                      leading: const Icon(Icons.train, color: Colors.blue),
                    ),
                  );
                },
              ),
    );
  }
}
