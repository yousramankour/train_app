import 'package:appmob/back_end.dart';
import 'package:appmob/chat.dart';
import 'package:appmob/directions_model.dart';
import 'package:appmob/directions_repository.dart';
import 'package:appmob/notification_service.dart';
import 'package:appmob/statistiques.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_database/firebase_database.dart';
import 'notification.dart';
import 'messageri.dart';
import 'profile.dart';
import 'package:vector_math/vector_math.dart' hide Colors;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static Map<String, NotificationService> notificationInstances = {};
  static Map<String, LatLng> garesMap = {};

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // map that contains all railsId+the whole rail polyline
  final _dbRef = FirebaseFirestore.instance; //
  Location _locationController = Location();
  LatLng? _currentP;
  GoogleMapController? mapController;
  LatLng? _destination;
  List<LatLng> _itineraire = [];
  String? _selectedTrain;
  Map<String, TrainInfo> _trains =
      {}; // map that contains all the the trains info
  LatLng? _trainLocationSnapped;
  List<Ligne> allLignes = [];
  Map<PolylineId, Polyline> allPolylines = {};
  bool _isSheetOpen = false;
  late BitmapDescriptor trainIcon = BitmapDescriptor.defaultMarker;
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
  final DirectionsRipository _directionsRepository = DirectionsRipository();
  Direction? _info;
  bool going_direction = true;

  Set<Marker> get allMarkers => trainMarkers.values.toSet();
  bool trajet_plannified = false;
  bool _isSearchExpanded = false;
  String? _startStation;
  String? _destinationStation;

  @override
  void initState() {
    super.initState();
    requestLocation();
    listenToAllTrains();
    buildFullPolylines();
    CustomMarker();
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
      List<Station> myStations = [];

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
        SnapResult snap = SnapResult.findClosestPointOnPolyline(
          stationLatLng,
          fullPolyline,
        );

        // Save the bestIndex where this station snaps
        int index = snap.segmentIndex;
        if (!HomeScreen.garesMap.containsKey(doc.id)) {
          HomeScreen.garesMap[stationName] = LatLng(
            doc['coordinates'].latitude,
            doc['coordinates'].longitude,
          );
        }
        ;

        myStations.add(
          // create station
          Station.createStation(stationName, stationLatLng, index),
        );
      }
      final polylineId = PolylineId('$ligneId');
      final polyline = Polyline(
        polylineId: polylineId,
        points: fullPolyline,
        color: Colors.blue,
        width: 4,
      );
      allPolylines[polylineId] = polyline;
      allLignes.add(
        Ligne.createLigne(
          ligneId,
          doc['station1'],
          doc['station2'],
          fullPolyline,
          myStations,
        ),
      );
      print("🦋🦋🦋🦋🦋🦋Total polylines: ${allPolylines.length}");
      print("🟢🟢🟢RAIL:$polylineId");
    }
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

  String? findLigneIdForStations(
    String? startStation,
    String? destinationStation,
  ) {
    for (var ligne in allLignes) {
      final String ligneId = ligne.ligneId;
      final List<Station> stations = ligne.stations;

      print("ENTERED 22222");
      // Extract only the station names
      final List<String> stationNames = stations.map((s) => s.nom).toList();

      if (stationNames.contains(startStation) &&
          stationNames.contains(destinationStation)) {
        final int station1 = stationNames.indexOf(startStation!);
        final int station2 = stationNames.indexOf(destinationStation!);
        if (station1 < station2) {
          print("index of st1   $station1 start station $startStation");
          print("index of st2   $station2 send station $destinationStation");
          print("direction = $going_direction");
          setState(() {
            going_direction = true;
          });
        } else {
          print("direction$going_direction");
          setState(() {
            going_direction = false;
          });
        }
        return ligneId; // Found the line
      }
    }
    return null; // Not found
  }

  void listenToAllTrains() {
    final trainsRef = FirebaseDatabase.instance.ref('trains');

    trainsRef.onChildAdded.listen((event) {
      String trainId = event.snapshot.key!;
      final data = event.snapshot.value as Map;

      // Get real-time data from Firebase
      final String ligne = data['ligne'];
      double latitude = double.tryParse(data['latitude'].toString()) ?? 0.0;
      double longitude = double.tryParse(data['longitude'].toString()) ?? 0.0;
      double speed = double.tryParse(data['speed'].toString()) ?? 0.0;

      TrainInfo train = TrainInfo(
        trainId: trainId,
        rail: ligne,
        snappedLocation: SnapResult(LatLng(latitude, longitude), 0, 0),
        speed: 0,
        etaList: [],
        isGoing: true,
        lastTwoSnaps: [],
        onUpdateMarker: updateTrainMarker,
      );
      HomeScreen.notificationInstances[trainId] = NotificationService(
        trainId: trainId,
      );

      // Save to map
      _trains[trainId] = train;
      print("train Id =$trainId");

      // Start listening
      train.listenToTrain(trainsRef.child(trainId), allPolylines, allLignes);
    });
  }

  void CustomMarker() {
    BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(40, 40)),
      "assets/train_icon.png",
    ).then((icon) {
      setState(() {
        trainIcon = icon;
      });
    });
  }

  void updateTrainMarker(String trainNom, LatLng snappedLocation) {
    if (!trajet_plannified) {
      trainMarkers[trainNom] = Marker(
        markerId: MarkerId(trainNom),
        position: snappedLocation,
        onTap: () {
          setState(() {
            _selectedTrain = trainNom; // Trigger the correct sheet
            _isSheetOpen = true;
          });
        },
        icon: trainIcon,
        infoWindow: InfoWindow(title: trainNom),
      );
      print("marker train name:$trainNom");
      setState(() {}); // Refresh the map}
    }
  }

  void _selectGare(LatLng garePosition) async {
    setState(() {
      _destination = garePosition;
    });

    if (_currentP != null) {
      try {
        print('Origin: $_currentP');
        print('Destination: $garePosition');
        final direction = await _directionsRepository.getDirection(
          origin: _currentP!,
          destination: garePosition,
        );

        // Vérification : direction non null et contient des points
        if (direction == null || direction.polylinePoints.isEmpty) {
          print("Aucune direction trouvée ou polyline vide.");
          return;
        }

        setState(() {
          _info = direction;
          _itineraire =
              direction.polylinePoints
                  .map((e) => LatLng(e.latitude, e.longitude))
                  .toList();
        });

        // Vérifie que mapController et _itineraire ne sont pas vides
        if (mapController != null && _itineraire.isNotEmpty) {
          mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(
              _boundsFromLatLngList(_itineraire),
              50,
            ),
          );
        }
      } catch (e) {
        print("Erreur lors de la récupération de l'itinéraire : $e");
      }
    } else {
      print("Position actuelle inconnue.");
    }
  }

  void filterTrainMarkersByStartStation(String? startStation) {
    final filteredMarkers = <String, Marker>{};
    print("JUST ENTERED");
    _trains.forEach((trainId, trainInfo) {
      print(
        "🚇 Processing $trainId | Direction: ${trainInfo.isGoing} / required: $going_direction",
      );

      if (trainInfo.isGoing == going_direction) {
        print("✅ Direction matches");

        final stillHasStartStation = trainInfo.etaList.any((station) {
          final match =
              station['station'] == startStation && station['passed'] != true;
          print(
            "🧪 ETA Check → Station: ${station['station']} | Passed: ${station['passed']} | Match: $match",
          );
          return match;
        });

        if (stillHasStartStation) {
          print("🎯 Still has start station");

          if (trainMarkers.containsKey(trainId)) {
            print("👌👌👌👌👌👌👌train selected :$trainId");
            filteredMarkers[trainId] = trainMarkers[trainId]!;
          } else {
            print("⚠️ trainId $trainId not found in trainMarkers");
          }
        } else {
          print("🚫 No matching station left (maybe passed)");
        }
      } else {
        print("⛔ Direction does not match");
      }
    });

    setState(() {
      // Show only filtered markers
      trajet_plannified = true;
      trainMarkers = filteredMarkers;
    });
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
                _isSheetOpen = false;
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

              if (_currentP != null)
                Marker(
                  markerId: MarkerId("current_position"),
                  position: _currentP!,
                  icon: BitmapDescriptor.defaultMarker,
                ),
              if (_trainLocationSnapped != null)
                Marker(
                  markerId: MarkerId("train_location_Snapped"),
                  position: _trainLocationSnapped!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                  infoWindow: InfoWindow(title: "Train Position"),
                ),

              ...HomeScreen.garesMap.entries.map(
                (entry) => Marker(
                  markerId: MarkerId("gare_${entry.key}"),
                  position: entry.value,
                  infoWindow: InfoWindow(title: entry.key),
                  // station name
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  ),

                  onTap: () => _selectGare(entry.value),
                ),
              ),
            },

            polylines: {
              ...allPolylines.values,

              if (_itineraire.isNotEmpty)
                Polyline(
                  polylineId: PolylineId("itineraire"),
                  color: Colors.red,
                  width: 3,
                  points: _itineraire,
                ),
            },
          ),
          if (_selectedTrain != null && _trains.containsKey(_selectedTrain))
            DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.25,
              maxChildSize: 0.7,
              builder: (
                BuildContext context,
                ScrollController scrollController,
              ) {
                final train = _trains[_selectedTrain]!;

                final direction = train.isGoing;
                final Ligne currentLigne = allLignes.firstWhere(
                  (ligne) => (ligne.ligneId == train.rail),
                );
                String ligne;
                if (direction == false) {
                  ligne = "${currentLigne.Arr} -> ${currentLigne.Dep}";
                } else {
                  ligne = "${currentLigne.Dep} -> ${currentLigne.Arr}";
                }
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
                          "$ligne",
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
                        trajet_plannified = false;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Planifier Trajet",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Icon(
                          _isSearchExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                        ),
                      ],
                    ),
                  ),
                  if (_isSearchExpanded) ...[
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      hint: Text("Start Station "),
                      value: _startStation, // should be of type LatLng?
                      items: [
                        ...HomeScreen.garesMap.entries.map(
                          (entry) => DropdownMenuItem<String>(
                            value: entry.key, // LatLng
                            child: Text(entry.key), // Station name
                          ),
                        ),
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
                    DropdownButtonFormField<String>(
                      hint: Text("Destination Station"),
                      value: _destinationStation,
                      items:
                          HomeScreen.garesMap.entries
                              .map(
                                (entry) => DropdownMenuItem<String>(
                                  value: entry.key, // LatLng
                                  child: Text(entry.key),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() => _destinationStation = value);
                      },
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        findLigneIdForStations(
                          _startStation,
                          _destinationStation,
                        ); // Call directions API here
                        filterTrainMarkersByStartStation(_startStation);
                        print(
                          '🏇🏇🏇🏇🏇🏇From: $_startStation - 🏇🏇🏇🏇🏇🏇To: $_destinationStation',
                        );
                        setState(() {
                          _isSearchExpanded = !_isSearchExpanded;
                        });
                      },
                      child: Text("Show Trains"),
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (!_isSheetOpen)
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
            _buildBottomButton(LucideIcons.map, "Carte".tr(), () {}),
            _buildBottomButton(LucideIcons.barChart, "Statistique".tr(), () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatistiqueGareScreen(),
                ),
              );
            }),
            _buildBottomButton(LucideIcons.bell, "Notifications".tr(), () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            }),
            _buildBottomButton(
              LucideIcons.messageCircle,
              "Messagerie".tr(),
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreend()),
                );
              },
            ),
            _buildBottomButton(LucideIcons.user, "Profil".tr(), () {
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

  static SnapResult findClosestPointOnPolyline(
    LatLng point,
    List<LatLng> polyline,
  ) {
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
}

class TrainInfo {
  // class pour contenir les info de chaque train
  String trainId;
  String rail; // la ligne
  SnapResult snappedLocation; //la position
  double speed;
  List<Map<String, dynamic>> etaList; // list des gares suivant et leurs temps
  bool isGoing;
  List<SnapResult> lastTwoSnaps = [];
  final void Function(String trainNom, LatLng snappedLocation) onUpdateMarker;

  TrainInfo({
    required this.trainId,
    required this.rail,
    required this.snappedLocation,
    required this.speed,
    required this.etaList,
    required this.isGoing,
    required this.lastTwoSnaps,
    required this.onUpdateMarker,
  });

  void updateSnap(SnapResult newSnap) {
    if (lastTwoSnaps.length >= 2) {
      lastTwoSnaps.removeAt(0);
    }
    lastTwoSnaps.add(newSnap);
    detectDirection();
  }

  void detectDirection() {
    if (lastTwoSnaps.length < 2) return;
    final before = lastTwoSnaps[0];
    final now = lastTwoSnaps[1];

    if (now.segmentIndex > before.segmentIndex) {
      isGoing = true; // going toward Arr
    } else if (now.segmentIndex < before.segmentIndex) {
      isGoing = false; // coming back toward Dep
    }
  }

  void listenToTrain(
    DatabaseReference trainRef,
    Map<PolylineId, Polyline> allPolylines,
    List<Ligne> allLignes,
  ) {
    trainRef.onValue.listen((event) async {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map;

        Map<String, bool> stationPassedStatus = {};
        // Update train data
        final LatLng rawLocation = LatLng(data['latitude'], data['longitude']);
        speed = data['speed']?.toDouble() ?? 0; //train speed
        print("🟢🟢🟢SPEED:$speed");
        print("🟢🟢🟢RAIL:$rail");
        PolylineId polylineId = PolylineId(rail);

        print("ligne of polyline:${allPolylines[polylineId]!.polylineId}");

        snappedLocation = SnapResult.findClosestPointOnPolyline(
          rawLocation,
          allPolylines[polylineId]!.points,
        );
        updateSnap(snappedLocation);

        print("SNAPPEDLOCATION:${snappedLocation.snappedPoint}");

        final Ligne currentLigne = allLignes.firstWhere(
          (ligne) => (ligne.ligneId == rail),
        );
        final trainId = trainRef.key!; //le nom du train utiliser var train id

        print("🚉🚉🚉🚉🚉trainId:$trainId");
        print("LIGNE:${currentLigne.ligneId}");

        final notificationService = HomeScreen.notificationInstances[trainId]!;
        notificationService.positions.add(snappedLocation.snappedPoint);

        final List<Map<String, dynamic>> garesListAsMap =
            currentLigne.stations.map((station) => station.toMap()).toList();

        if (speed > 0.1) {
          etaList = ETA.calculateETA(
            garesList: garesListAsMap,
            snappedTrainLocation: snappedLocation,
            fullPolyline: allPolylines[polylineId]!.points,
            speedKmh: speed,
            stationPassedStatus: stationPassedStatus,
            isGoingDirection: isGoing,
            updateDirectionCallback: (newIsGoing) {
              // Update direction for this train if needed
            },
          );
        }
        print("📌 Liste mise à jour : ${HomeScreen.notificationInstances}");
        notificationService.verifierTrain(
          notificationService.positions,
          trainId,
          etaList,
        );
        // Update marker
        onUpdateMarker(trainId, snappedLocation.snappedPoint);

        // Calculate ETA list
      }
    });
  }
}

class Station {
  final String nom;
  final LatLng coordinates;
  final int index;

  Station({required this.nom, required this.coordinates, required this.index});

  static Station createStation(String name, LatLng coor, int index) {
    return Station(nom: name, coordinates: coor, index: index);
  }

  Map<String, dynamic> toMap() {
    return {'name': nom, 'coordinates': coordinates, 'index': index};
  }

  static Map<String, dynamic>? getNextStation({
    required List<Map<String, dynamic>> orderedStations,
    required int trainIndex,
    required Map<String, bool> stationPassedStatus,
    required void Function(bool newIsGoing) updateDirectionCallback,
    required bool isGoingDirection,
    required List<Map<String, dynamic>> tempEtaList,
  }) {
    bool foundNext = false;

    for (var station in orderedStations) {
      int stationIndex = station['index'];
      String name = station['name'];

      if ((isGoingDirection && trainIndex > stationIndex) ||
          (!isGoingDirection && trainIndex < stationIndex)) {
        // Mark as passed
        stationPassedStatus[name] = true;
        tempEtaList.add({
          "station": name,
          "eta_minutes": 0,
          "passed": stationPassedStatus[name],
        });
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
}

class Ligne {
  final String ligneId;
  final String Dep;
  final String Arr;
  final List<LatLng> polyline;
  final List<Station> stations;

  Ligne({
    required this.ligneId,
    required this.Dep,
    required this.Arr,
    required this.polyline,
    required this.stations,
  });

  factory Ligne.createLigne(
    String Id,
    String Depart,
    String Arrivee,
    List<LatLng> polylineData,
    List<Station> stationList,
  ) {
    // Example: manually creating 3 stations
    return Ligne(
      ligneId: Id,
      Dep: Depart,
      Arr: Arrivee,
      polyline: polylineData,
      stations: stationList,
    );
  }

  static List<LatLng> slicePolylineFromTo(
    List<LatLng> polyline,
    LatLng from,
    LatLng to,
  ) {
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
}

class ETA {
  final String stationName;
  final bool passed;
  final double estimatedTime;

  ETA({
    required this.stationName,
    required this.passed,
    required this.estimatedTime,
  });

  static List<Map<String, dynamic>> calculateETA({
    required List<Map<String, dynamic>> garesList,
    required SnapResult snappedTrainLocation,
    required List<LatLng> fullPolyline,
    required double speedKmh,
    required Map<String, bool> stationPassedStatus,
    required bool isGoingDirection,
    required void Function(bool newIsGoing) updateDirectionCallback,
  }) {
    List<Map<String, dynamic>> orderedGares =
        isGoingDirection ? garesList : garesList.reversed.toList();

    List<Map<String, dynamic>> tempEtaList = [];
    int trainIndex = snappedTrainLocation.segmentIndex;

    // 🔁 Get next station and update passed status
    Map<String, dynamic>? nextStation = Station.getNextStation(
      orderedStations: orderedGares,
      trainIndex: trainIndex,
      stationPassedStatus: stationPassedStatus,
      updateDirectionCallback: updateDirectionCallback,
      isGoingDirection: isGoingDirection,
      tempEtaList: tempEtaList,
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
      LatLng from;
      LatLng To;
      if (isGoingDirection == true) {
        from = snappedTrainLocation.snappedPoint;
        To = orderedGares[i]['coordinates'];
      } else {
        from = orderedGares[i]['coordinates'];
        To = snappedTrainLocation.snappedPoint;
      }

      List<LatLng> segment = Ligne.slicePolylineFromTo(fullPolyline, from, To);
      double distance = ETA.calculateDistanceBetweenPoints(segment); // meters
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
    return tempEtaList;
  }

  static double calculateDistanceBetweenPoints(List<LatLng> points) {
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
}
