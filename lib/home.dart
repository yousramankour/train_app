import 'package:appmob/back-end.dart';
import 'package:appmob/directions_model.dart';
import 'package:appmob/directions_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:math';
//import 'package:latlong2/latlong.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'statistique.dart';
import 'notification.dart';
import 'messageri.dart';
import 'profile.dart';
import 'package:vector_math/vector_math.dart' hide Colors;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> railPolylines =
      {}; // map that contains all railsId+the whole rail polyline
  final _dbRef = FirebaseFirestore.instance; //
  Location _locationController = Location();
  LatLng? _currentP;
  GoogleMapController? mapController;
  List<Map<String, dynamic>> _etaList = [];
  String _searchText = '';
  LatLng? _destination;
  List<LatLng> _itineraire = [];
  String? _selectedTrain;
  Map<String, Map<String, bool>> stationPassedStatusMap = {};
  Map<String, TrainInfo> _trains = {};// map that contains all the the trains info
  LatLng? _trainLocation;
  LatLng? _trainLocationSnapped;
  late BitmapDescriptor trainIcon;
  double _currentZoom = 11.0;
  final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(36.7333, 3.2800),
    zoom: 11,
  );
  final _dbServices = DatabaseService();
  double? lastLat;
  double? lastLng;
  Map<String, Marker> trainMarkers = {};
  List<LatLng> _trainRoute = [];
  Map<String,LatLng> _garesMap = {};
   /* LatLng(36.77947718263685, 3.062102318233201), // Alger
    LatLng(36.76786434370996, 3.0571634472437097), // Agha
    LatLng(36.75637323481598, 3.0657403320287813), // Les Ateliers
    LatLng(36.74538839603068, 3.0943597112363648), // Hussein Dey
    LatLng(36.735711582340954, 3.1181884553515715), // El Harrach
    LatLng(36.72200348830961, 3.132535151799459), // Oued Smar
    LatLng(36.703758376754564, 3.171808002822587), // Bab Ezzouar
    LatLng(36.71454649851863, 3.2106916647344974), // Dar El Beïda
    LatLng(36.73408228629039, 3.2829753423722536), // Rouiba
    LatLng(36.73323925631257, 3.301790410930437), // Rouiba industrielle
    LatLng(36.73383032469597, 3.317588409429959), // Réghaïa industrielle
    LatLng(36.73561158985109, 3.3405445103102522), // Réghaïa
    LatLng(36.740279772532034, 3.4128444654637633), // Boudouaou
    LatLng(36.753723557039876, 3.435430500308115), // Corso
    LatLng(36.75324360227452, 3.473915470543915), // Boumerdès
    LatLng(36.7310886744763, 3.500921535370594), // Tidjelabine
    LatLng(36.725311597872135, 3.5530624990360025),*/
  final DirectionsRipository _directionsRepository = DirectionsRipository();
  Direction? _info;

  Future<void> fetchGares() async {
    final snapshot = await FirebaseFirestore.instance.collection('gares').get();
    setState(() {
      _garesMap = {
        for (var doc in snapshot.docs)
          doc.id: LatLng(
            doc['coordinates'].latitude,
            doc['coordinates'].longitude,
          ),
      };
    });
  }
  Set<Marker> get allMarkers => trainMarkers.values.toSet();

  /* Map<String, LatLng> stationCoordinatesMap= {
  "Agha": LatLng(36.7673269,3.05720034),
   "Les Ateliers": LatLng(36.75656656,3.06556762),
  "Hussein Dey": LatLng(36.74546964,3.09419534),
    "Caroubier": LatLng(36.73509586,3.12006988)
  };*/

  bool _isSearchExpanded = false;
  LatLng? _startStation;
  LatLng? _destinationStation;
 /* final List<String> _nomsGares = [
    "Alger",
    "Agha",
    "Les Ateliers",
    "Hussein Dey",
    "Caroubier",
    "El Harrach",
    "Oued Smar",
    "Bab Ezzouar",
    "Dar El Beïda",
    "Rouiba",
    "Rouiba industrielle",
    "Réghaïa industrielle",
    "Réghaïa",
    "Boudouaou",
    "Corso",
    "Boumerdès",
    "Tidjelabine",
    "Thénia",
  ];*/

  @override
  void initState() {
    super.initState();
    requestLocation();
    listenToAllTrains();
    buildFullPolylines();
    fetchGares();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  Future<void> buildFullPolylines() async {
    QuerySnapshot ligne = await _dbRef.collection("rail").get();
    for (var doc in ligne.docs) {
      String ligneId = doc.id;
      List<dynamic> stations = doc['gares'];
      List<LatLng> fullPolyline = [];
      List<Map<String, dynamic>> railStations = [];

      for (int i = 0; i < stations.length - 1; i++) {
        String st1 = "${stations[i]}-${stations[i + 1]}";
        String st2 = "${stations[i + 1]}-${stations[i]}";

        DocumentSnapshot doc;
        if ((await _dbRef.collection("station").doc(st1).get()).exists) {
          doc = await _dbRef.collection("station").doc(st1).get();
        } else if ((await _dbRef.collection("station").doc(st2).get()).exists) {
          doc = await _dbRef.collection("station").doc(st2).get();
        } else {
          continue;
        }
        List geoCordinates = doc['coordinates'];
        fullPolyline.addAll(
          geoCordinates.map((gp) => LatLng(gp.latitude, gp.longitude)).toList(),
        );
      }

      for (String stationName in stations) {
        // Fetch the real coordinate of the station from DB (or your stations list)
        DocumentSnapshot doc =
            await _dbRef.collection("gares").doc(stationName).get();
        GeoPoint coord =
            doc['coordinates']; // assuming each doc has a `position` field

        LatLng stationLatLng = LatLng(coord.latitude, coord.longitude);

        // Snap this station location to the fullPolyline
        SnapResult snap = findClosestPointOnPolyline(
          stationLatLng,
          fullPolyline,
        );

        // Save the bestIndex where this station snaps
        int index = snap.segmentIndex;
        railStations.add({
          'name': stationName,
          'coordinates': stationLatLng, // your station's actual coordinates
          'index': index,
        });
      }
      railPolylines[ligneId] = {
        'polyline': fullPolyline,
        'stations': railStations, // Adding the stations list
      };
    }
  }

  double calculateDistanceBetweenPoints(List<LatLng> points) {
    double total = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      total += Geolocator.distanceBetween(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
    }
    return total; // in meters
  }

  Future<void> requestLocation() async {
    bool serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted =
        await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    } else if (permissionGranted == PermissionStatus.deniedForever) {
      openAppSettings();
      return;
    }

    _locationController.onLocationChanged.listen((
      LocationData currentLocation,
    ) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
        });

        if (mapController != null) {
          mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(
              _boundsFromLatLngList(_trainRoute),
              80,
            ),
          );
        }
      }
    });
  }

  void openAppSettings() async {
    final Uri url = Uri.parse('app-settings:');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  double haversine(double? lat1, double? lon1, double lat2, double lon2) {
    const R = 6371; // Earth's radius in km
    final dLat = _degToRad(lat2 - lat1!);
    final dLon = _degToRad(lon2 - lon1!);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) => deg * pi / 180;

  double calculateSpeedKmh({
    required double? lastLat,
    required double? lastLng,
    required double newLat,
    required double newLng,
    required double timeDiffSeconds,
  }) {
    final distanceKm = haversine(lastLat!, lastLng!, newLat, newLng);
    final timeHours = timeDiffSeconds / 3600.0;
    return timeHours == 0 ? 0 : distanceKm / timeHours;
  }

 /* void _handleSearch(String value) {
    int index = _nomsGares.indexWhere(
      (gare) => gare.toLowerCase() == value.toLowerCase(),
    );
    if (index != -1) {
      LatLng garePosition = _gares[index];
      _selectGare(garePosition);
    }
  }*/

  String? findLigneIdForStations(String startStation, String destinationStation) {
    for (var entry in railPolylines.entries) {
      final String ligneId = entry.key;
      final List<dynamic> stations = entry.value['stations'];

      // Extract only the station names
      final List<String> stationNames = stations.map((s) => s['name'] as String).toList();

      if (stationNames.contains(startStation) && stationNames.contains(destinationStation)) {
        return ligneId; // Found the line
      }
    }
    return null; // Not found
  }
  void listenToAllTrains() {
    DatabaseReference allTrainsRef = FirebaseDatabase.instance.ref('trains');
    DateTime lastUpdateTime =DateTime.now();
    allTrainsRef.onValue.listen((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;


      if (data != null) {

        //double newlat;
        //double newlng;

        for (var entry in data.entries) {
          final String trainNom = entry.key; // <-- Here! Get the train name from the document ID
          final trainData = entry.value as Map<dynamic, dynamic>;
          DateTime CurrentUpdateTime =DateTime.now();
          List<Map<String, dynamic>> eta_list = [];

          if (trainData['latitude'] != null && trainData['longitude'] != null) {
            final LatLng rawLocation = LatLng(
              double.parse(trainData['latitude'].toString()),
              double.parse(trainData['longitude'].toString()),
            );
           //lllllllllllllll::::::::::: rawLocation =LatLng(36.745819, 3.092676);

           /* if (lastLng==null && lastLat==null){
              lastLat=rawLocation.latitude;
              lastLng=rawLocation.longitude;}*/
            _trainLocation = rawLocation;
            //double TimeDiffr=CurrentUpdateTime.difference(lastUpdateTime).inSeconds.toDouble();
            final double speed = double.parse(trainData['speed'].toString());


            // 🔥 Fetch train info from Firestore
            final querySnapshot =
                await FirebaseFirestore.instance
                    .collection('trains')
                    .where('nom', isEqualTo: trainNom)
                    .get();

            if (querySnapshot.docs.isNotEmpty) {
              final trainDoc = querySnapshot.docs.first;
              final String ligne = trainDoc['ligne'];
              final bool isGoing = trainDoc['isGoing'];

              // 🔥 Find the correct polyline and station list
              final List<LatLng> polyline =
                  railPolylines[ligne]?['polyline'] ?? [];
              final List<Map<String, dynamic>> stationList =
                  List<Map<String, dynamic>>.from(
                    railPolylines[ligne]?['stations'] ?? [],
                  );

              print("📍 Station list for $ligne:");
              for (var station in stationList) {
                print(
                  " - ${station['name']} at ${station['coordinates']} (index: ${station['index']})",
                );
              }
              // rawLocation=LatLng(36.76699671,3.05718731);
              if (polyline.isNotEmpty && stationList.isNotEmpty) {
                // Snap to polyline
                //rawLocation = LatLng(36.75943808,3.0619855 );
                final SnapResult snappedLocation = findClosestPointOnPolyline(
                  rawLocation,
                  polyline,
                );
                //newlat=snappedLocation.snappedPoint.latitude;
                //newlng= snappedLocation.snappedPoint.longitude;
               // final double speed =calculateSpeedKmh(lastLat: lastLat!, lastLng:lastLng! , newLat:newlat , newLng: snappedLocation.snappedPoint.longitude, timeDiffSeconds: TimeDiffr);
                // double.parse(trainData['speed'].toString());
                //snappedLocation.snappedPoint;
               // lastLat=newlat;
              //  lastLng=newlng;
                print(
                  "📍 Snapped Location: ${snappedLocation.snappedPoint.latitude}, ${snappedLocation.snappedPoint.longitude}",
                );
                print("Speed: ${speed.toStringAsFixed(1)} km/h");

                if (!stationPassedStatusMap.containsKey(trainNom)) {
                  stationPassedStatusMap[trainNom] = {};
                }
                //snappedLocation.snappedPoint_trainLocationSnapped = snappedLocation.snappedPoint;
                // 🛠 Calculate ETA for this train
                if (speed>0.5){
                eta_list = calculateETA(
                  garesList: stationList,
                  snappedTrainLocation: snappedLocation,
                  fullPolyline: polyline,
                  speedKmh: speed,
                  stationPassedStatus: stationPassedStatusMap[trainNom]!,
                  isGoingDirection: isGoing,
                  updateDirectionCallback: (newIsGoing) {
                    // Update direction for this train if needed
                  },
                );

                _trains[trainNom] = TrainInfo(//enregistrer les info du train avec trainNom comme key et valeur est une variable de type TrainInfo qui est déclarer comme une classe dans le map _trains qui va contenire tous les trains dans notre base de données , dans ce cas là on a qu'un seul train
                  rail: ligne,// la ligne ex Alger->Thénia
                  snappedLocation: snappedLocation,// la position du train dans la ligne
                  speed: speed,
                  etaList: eta_list,
                  isGoing: isGoing,
                );};
                //if u want to get any all trains location u need to loop throught _trains map and for each train get their location that would be _trains.forEach((key,value){ 'le train est $key et sa position est ${value.snappedLocation.snappedpoint} }
                // Update marker position
                updateTrainMarker(trainNom, snappedLocation.snappedPoint);
              }
            }
          }
        }
      }
    });
  }

  Map<String, dynamic>? getNextStation({
    required List<Map<String, dynamic>> orderedStations,
    required int trainIndex,
    required Map<String, bool> stationPassedStatus,
    required void Function(bool newIsGoing) updateDirectionCallback,
    required bool isGoingDirection,
  })
  {
    bool foundNext = false;

    for (var station in orderedStations) {
      int stationIndex = station['index'];
      String name = station['name'];

      if ((isGoingDirection && trainIndex > stationIndex) ||
          (!isGoingDirection && trainIndex < stationIndex)) {
        // Mark as passed
        stationPassedStatus[name] = true;
      } else {
        foundNext = true;
        return station;
      }
    }

    // If no unpassed station found = all passed
    if (!foundNext) {
      stationPassedStatus.updateAll((key, value) => false); // reset
      updateDirectionCallback(!isGoingDirection); // toggle direction
      print("🔁 All stations passed, switching direction!");
    }

    return null; // No next station found
  }

  void updateTrainMarker(String trainNom, LatLng snappedLocation) {
    trainMarkers[trainNom] = Marker(
      markerId: MarkerId(trainNom),
      position: snappedLocation,
      onTap: () {
        setState(() {
          _selectedTrain = trainNom; // Trigger the correct sheet
        });
      },
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: trainNom),
    );
    setState(() {}); // Refresh the map
  }

  SnapResult findClosestPointOnPolyline(LatLng point, List<LatLng> polyline) {
    Vector2 p = Vector2(point.latitude, point.longitude);
    double minDistance = double.infinity;
    LatLng closestPoint = polyline.first;
    int bestIndex = 0;
    double bestT = 0;

    for (int i = 0; i < polyline.length - 1; i++) {
      LatLng start = polyline[i];
      LatLng end = polyline[i + 1];

      Vector2 a = Vector2(start.latitude, start.longitude);
      Vector2 b = Vector2(end.latitude, end.longitude);

      Vector2 ap = p - a;
      Vector2 ab = b - a;

      double t = ap.dot(ab) / ab.length2;
      t = t.clamp(0.0, 1.0);

      Vector2 projection = a + ab * t;
      double distance = (p - projection).length;

      if (distance < minDistance) {
        minDistance = distance;
        closestPoint = LatLng(projection.x, projection.y);
        bestIndex = i;
        bestT = t;
      }
    }

    return SnapResult(closestPoint, bestIndex, bestT);
  }

  List<LatLng> slicePolylineFromTo(
    List<LatLng> polyline,
    LatLng from,
    LatLng to,
  )
  {
    int startIndex = polyline.indexWhere(
      (p) =>
          Geolocator.distanceBetween(
            p.latitude,
            p.longitude,
            from.latitude,
            from.longitude,
          ) <
          5,
    );
    if (startIndex == -1) {
      print("❌ Failed to find start point close to: $from");
    } else {
      print("✅ Found start point at index $startIndex for: $from");
    }


    int endIndex = polyline.indexWhere(
      (p) =>
          Geolocator.distanceBetween(
            p.latitude,
            p.longitude,
            to.latitude,
            to.longitude,
          ) <
          5,
    );
    if (endIndex == -1) {
      print("❌ Failed to find end point close to: $to");
    } else {
      print("✅ Found end point at index $endIndex for: $to");
    }

    if (startIndex != -1 && endIndex != -1 && startIndex < endIndex) {
      print("✂️ Slicing polyline from $startIndex to $endIndex");
      return polyline.sublist(startIndex, endIndex + 1);
    }
    print("⚠️ Returning empty polyline slice");
    return [];
  }

  List<Map<String, dynamic>> calculateETA({
    required List<Map<String, dynamic>> garesList,
    required SnapResult snappedTrainLocation,
    required List<LatLng> fullPolyline,
    required double speedKmh,
    required Map<String, bool> stationPassedStatus,
    required bool isGoingDirection,
    required void Function(bool newIsGoing) updateDirectionCallback,
  })
  {
    List<Map<String, dynamic>> orderedGares =
        isGoingDirection ? garesList : garesList.reversed.toList();

    List<Map<String, dynamic>> tempEtaList = [];
    int trainIndex = snappedTrainLocation.segmentIndex;

    // 🔁 Get next station and update passed status
    Map<String, dynamic>? nextStation = getNextStation(
      orderedStations: orderedGares,
      trainIndex: trainIndex,
      stationPassedStatus: stationPassedStatus,
      updateDirectionCallback: updateDirectionCallback,
      isGoingDirection: isGoingDirection,
    );

    if (nextStation == null) {
      print("✅ No next station (maybe just switched direction)");
      return tempEtaList;
    }

    // 🧮 Continue to calculate ETA for the remaining stations
    int nextIndex = orderedGares.indexWhere(
      (s) => s['name'] == nextStation['name'],
    );
    for (int i = nextIndex; i < orderedGares.length; i++) {
      List<LatLng> segment = slicePolylineFromTo(
        fullPolyline,
        snappedTrainLocation.snappedPoint,
        orderedGares[i]['coordinates'],
      );
      double distance = calculateDistanceBetweenPoints(segment); // meters
      double speedMps = (speedKmh * 1000) / 3600;
      double etaSeconds = speedMps > 0 ? distance / speedMps : double.infinity;
      double etaMinutes = etaSeconds / 60;
      print(
        "📏 Distance to ${orderedGares[i]['name']}: ${distance.toStringAsFixed(2)} meters",
      );

      tempEtaList.add({
        "station": orderedGares[i]['name'],
        "eta_minutes": etaMinutes.isFinite ? etaMinutes.ceil() : 0,
        "passed": stationPassedStatus[orderedGares[i]['name']],
      });

    }

    return tempEtaList;

    print("📋 ETA List:");
    for (var eta in tempEtaList) {
      print(
        "→ Station: ${eta['station']}, ETA: ${eta['eta_minutes']} min, Passed: ${eta['passed']}",
      );
    }
    print("🚅 Speed: $speedKmh km/h");
    print("🚉 Next Station: ${nextStation['name']}");
    print(
      "📌 Next Station Index: ${orderedGares.indexWhere((s) => s['name'] == nextStation['name'])}",
    );
  }

  /* double calculateETime(double distanceMeters, double speedKmh) {
    double speedMps = (speedKmh * 1000) / 3600;
    if (speedMps == 0) return double.infinity;
    return (distanceMeters / speedMps) / 60; // in minutes
  }
*/


    void _selectGare(LatLng garePosition) async {
      setState(() {
        _destination = garePosition;
      });

      if (_currentP != null) {
        try {
          print('Origin: $_currentP');
          print('Destination: $garePosition');
          final direction = await _directionsRepository.getDirection(
            origin: LatLng(36.752778, 3.042222),//_currentP!,
            destination: LatLng(36.716667, 3.086944), //garePosition,
          );

          // Vérification : direction non null et contient des points
          if (direction == null || direction.polylinePoints.isEmpty) {
            print("Aucune direction trouvée ou polyline vide.");
            return;
          }

          setState(() {
            _info = direction;
            _itineraire = direction.polylinePoints
                .map((e) => LatLng(e.latitude, e.longitude))
                .toList();
          });

          // Vérifie que mapController et _itineraire ne sont pas vides
          if (mapController != null && _itineraire.isNotEmpty) {
            mapController!.animateCamera(
              CameraUpdate.newLatLngBounds(_boundsFromLatLngList(_itineraire), 50),
            );
          }
        } catch (e) {
          print("Erreur lors de la récupération de l'itinéraire : $e");
        }
      } else {
        print("Position actuelle inconnue.");
      }
    }





  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double x0 = list.first.latitude;
    double x1 = list.first.latitude;
    double y0 = list.first.longitude;
    double y1 = list.first.longitude;

    for (LatLng latLng in list) {
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }

    return LatLngBounds(southwest: LatLng(x0, y0), northeast: LatLng(x1, y1));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_trainRoute.isNotEmpty) {
      _fitMapToBounds();
    }
  }

  void _fitMapToBounds() {
    if (mapController == null || _trainRoute.isEmpty) return;

    final bounds = _boundsFromLatLngList(_trainRoute);
    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  void _onCameraMove(CameraPosition position) {
    _currentZoom = position.zoom;
  }

  Future<void> _openInGoogleMaps(LatLng destination) async {
    final String url =
        'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print('Could not launch $url');
    }
  }

  Map<String, bool> initializeStationPassedStatus(List<String> stationList) {
    return {for (var station in stationList) station: false};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(36.7333, 3.2800),
              zoom: 13,
            ),
            onTap: (_) {
              setState(() {
                _selectedTrain = null;
              });
            },
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              if (_trainRoute.isNotEmpty) {
                controller.animateCamera(
                  CameraUpdate.newLatLngBounds(
                    _boundsFromLatLngList(_trainRoute),
                    50,
                  ),
                );
              }
            },
            markers: {
              ...allMarkers,
              /* if (_currentP != null)
                Marker(
                  markerId: MarkerId("current_position"),
                  position: _currentP!,
                  icon: BitmapDescriptor.defaultMarker,
                ),*/

              /*if (_trainLocation != null)
                Marker(
                  markerId: MarkerId("train_location_actual"),
                  position: _trainLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                  infoWindow: InfoWindow(title: "Train Position"),
                ),*/
              if (_trainLocationSnapped != null)
                Marker(
                  markerId: MarkerId("train_location_Snapped"),
                  position: _trainLocationSnapped!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                  infoWindow: InfoWindow(title: "Train Position"),
                ),

              ..._garesMap.entries.map(
                    (entry) => Marker(
                  markerId: MarkerId("gare_${entry.key}"),
                  position: entry.value,
                  infoWindow: InfoWindow(title: entry.key), // station name
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  ),

                 onTap: () => _selectGare(entry.value),
                ),
              ),
            },


            polylines: {
              ...railPolylines.entries.map((entry) {
                return Polyline(
                  polylineId: PolylineId(entry.key),
                  color: Colors.blue,
                  width: 4,
                  points:
                      entry.value['polyline'], // Access 'polyline' from the map
                );
              }).toSet(),
              if (_itineraire.isNotEmpty)
                Polyline(
                  polylineId: PolylineId("itineraire"),
                  color: Colors.blue,
                  width: 3,
                  points: _itineraire,
                ),
            },
          ),
          if (_selectedTrain != null && _trains.containsKey(_selectedTrain))
            DraggableScrollableSheet(
              initialChildSize: 0.1,
              minChildSize: 0.1,
              maxChildSize: 0.7,
              builder: (
                BuildContext context,
                ScrollController scrollController,
              ) {
                final train = _trains[_selectedTrain]!;
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(blurRadius: 10, color: Colors.black26),
                    ],
                  ),
                  child: Column(
                    children: [
                      // 🔹 Grab Handle
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // 🚉 Rail Name in Center Top
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          "${train.rail}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: train.etaList.length,
                          itemBuilder: (context, index) {
                            final eta = train.etaList[index];
                            final bool isPassed = eta["passed"] ?? false;
                            final String station = eta["station"];

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color:
                                            isPassed
                                                ? Colors.grey
                                                : const Color(0xFF008ECC),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    if (index != train.etaList.length - 1)
                                      Container(
                                        width: 2,
                                        height: 50,
                                        color:
                                            isPassed
                                                ? Colors.grey
                                                : const Color(0xFF008ECC),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      station,
                                      style: TextStyle(
                                        color:
                                            isPassed
                                                ? Colors.grey
                                                : Colors.black,
                                        decoration:
                                            isPassed
                                                ? TextDecoration.lineThrough
                                                : null,
                                      ),
                                    ),
                                    if (!isPassed)
                                      Text(
                                        "${eta["eta_minutes"]} min",
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                        ),
                                      ),
                                    if (isPassed)
                                      const Text(
                                        "✔️",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSearchExpanded = !_isSearchExpanded;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Search Route", style: TextStyle(fontWeight: FontWeight.bold)),
                        Icon(_isSearchExpanded ? Icons.expand_less : Icons.expand_more),
                      ],
                    ),
                  ),
                  if (_isSearchExpanded) ...[
                    SizedBox(height: 10),
                    DropdownButtonFormField<LatLng>(
                      hint: Text("Start Station or Current Location"),
                      value: _startStation, // should be of type LatLng?
                      items: [
                        ..._garesMap.entries.map((entry) => DropdownMenuItem(
                          value: entry.value, // LatLng
                          child: Text(entry.key), // Station name
                        )),
                       /* DropdownMenuItem(
                          value: _currentP, // current position as LatLng
                          child: Text("Use My Current Location"),
                        ),*/
                      ],
                     onChanged: (value) async {
                        setState(() {
                          _startStation = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<LatLng>(
                      hint: Text("Destination Station"),
                      value: _destinationStation,
                      items: _garesMap.entries.map((entry) => DropdownMenuItem(
                        value: entry.value, // LatLng
                        child: Text(entry.key),
                      )).toList(),
                      onChanged: (value) {
                        setState(() => _destinationStation = value);
                      },
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        // Call directions API here
                        print('From: $_startStation - To: $_destinationStation');
                      },
                      child: Text("Show Route"),
                    ),
                  ],
                ],
              ),
            ),
          ),

          /* Positioned(top:350,
        left:20,
        child: ElevatedButton(onPressed: (){
         _dbServices.update();
       },
            child: Text("Add cordination"),
        ),
    ),
          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: TextField(
                onChanged: (value) => _searchText = value,
                onSubmitted: _handleSearch,
                decoration: InputDecoration(
                  hintText: 'ابحث عن محطة...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: 10,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_destination != null) ...[
                    Text(
                      "Gare sélectionnée: ${_nomsGares[_gares.indexOf(_destination!)]}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_currentP != null) {
                              setState(() {
                                _itineraire = [_currentP!, _destination!];
                              });
                              mapController?.animateCamera(
                                CameraUpdate.newLatLngBounds(
                                  LatLngBounds(
                                    southwest: LatLng(
                                      _currentP!.latitude <
                                              _destination!.latitude
                                          ? _currentP!.latitude
                                          : _destination!.latitude,
                                      _currentP!.longitude <
                                              _destination!.longitude
                                          ? _currentP!.longitude
                                          : _destination!.longitude,
                                    ),
                                    northeast: LatLng(
                                      _currentP!.latitude >
                                              _destination!.latitude
                                          ? _currentP!.latitude
                                          : _destination!.latitude,
                                      _currentP!.longitude >
                                              _destination!.longitude
                                          ? _currentP!.longitude
                                          : _destination!.longitude,
                                    ),
                                  ),
                                  100,
                                ),
                              );
                            }
                          },
                          icon: Icon(Icons.map),
                          label: Text("Voir sur la carte"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF008ECC),
                            foregroundColor: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () => _openInGoogleMaps(_destination!),
                          icon: Icon(Icons.directions),
                          label: Text("Google Maps"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),*/
          Positioned(
            bottom: 80,
            left: 10,
            child: FloatingActionButton(
              onPressed: () {
                requestLocation();
                if (_currentP != null && mapController != null) {
                  mapController!.animateCamera(
                    CameraUpdate.newLatLngZoom(_currentP!, 15.0),
                  );
                }
              },
              backgroundColor: Colors.white,
              child: Icon(Icons.my_location, color: Color(0xFF008ECC)),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFF008ECC),
          borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
        ),
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomButton(LucideIcons.map, "الخريطة", () {}),
            _buildBottomButton(LucideIcons.barChart, "الإحصائيات", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsScreen()),
              );
            }),
            _buildBottomButton(LucideIcons.bell, "الإشعارات", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            }),
            _buildBottomButton(LucideIcons.messageCircle, "الرسائل", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MessageScreen()),
              );
            }),
            _buildBottomButton(LucideIcons.user, "الملف الشخصي", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(IconData icon, String label, Function() onPressed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white, size: 24),
          onPressed: onPressed,
        ),
        SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 9)),
      ],
    );
  }
}

class SnapResult {
  final LatLng snappedPoint;
  final int segmentIndex;
  final double tAlongSegment; // from 0 to 1

  SnapResult(this.snappedPoint, this.segmentIndex, this.tAlongSegment);
}

class TrainInfo { // class pour contenir les info de chaque train
  final String rail;// la ligne
  final SnapResult snappedLocation;//la position
  final double speed;
  final List<Map<String, dynamic>> etaList;// list des gares suivant et leurs temps
  final bool isGoing;

  TrainInfo({
    required this.rail,
    required this.snappedLocation,
    required this.speed,
    required this.etaList,
    required this.isGoing,
  });
}
