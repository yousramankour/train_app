import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'statistique.dart';
import 'notification.dart';
import 'messageri.dart';
import 'profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Location _locationController = Location();
  LatLng? _currentP;
  GoogleMapController? mapController;
  String _searchText = '';
  LatLng? _destination;
  List<LatLng> _itineraire = [];

  final List<LatLng> _gares = [
    LatLng(36.7805, 3.0595), // Alger
    LatLng(36.7679, 3.0618), // Agha
    LatLng(36.7441, 3.0828), // Les Ateliers
    LatLng(36.7320, 3.0870), // Hussein Dey
    LatLng(36.7291, 3.1102), // Khrouba
    LatLng(36.7215, 3.1230), // El Harrach
    LatLng(36.7071, 3.1472), // Oued Smar
    LatLng(36.7120, 3.1800), // Bab Ezzouar
    LatLng(36.7139, 3.2158), // Dar El Beïda
    LatLng(36.7395, 3.2823), // Rouiba
    LatLng(36.7413, 3.3124), // Rouiba industrielle
    LatLng(36.7514, 3.3408), // Réghaïa industrielle
    LatLng(36.7530, 3.3600), // Réghaïa
    LatLng(36.7489, 3.4096), // Boudouaou
    LatLng(36.7537, 3.4355), // Corso
    LatLng(36.7533, 3.4742), // Boumerdès
    LatLng(36.7366, 3.5313), // Tidjelabine
    LatLng(36.7248, 3.5566), // Thénia
  ];

  final List<String> _nomsGares = [
    "Alger",
    "Agha",
    "Les Ateliers",
    "Hussein Dey",
    "Khrouba",
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
  ];

  @override
  void initState() {
    super.initState();
    requestLocation();
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
            CameraUpdate.newLatLngBounds(_boundsFromLatLngList(_gares), 80),
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

  void _handleSearch(String value) {
    int index = _nomsGares.indexWhere(
      (gare) => gare.toLowerCase() == value.toLowerCase(),
    );
    if (index != -1) {
      LatLng garePosition = _gares[index];
      _selectGare(garePosition);
    }
  }

  void _selectGare(LatLng garePosition) {
    setState(() {
      _destination = garePosition;
      if (_currentP != null) {
        _itineraire = [_currentP!, garePosition];
      }
    });

    mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            _currentP!.latitude < garePosition.latitude
                ? _currentP!.latitude
                : garePosition.latitude,
            _currentP!.longitude < garePosition.longitude
                ? _currentP!.longitude
                : garePosition.longitude,
          ),
          northeast: LatLng(
            _currentP!.latitude > garePosition.latitude
                ? _currentP!.latitude
                : garePosition.latitude,
            _currentP!.longitude > garePosition.longitude
                ? _currentP!.longitude
                : garePosition.longitude,
          ),
        ),
        100,
      ),
    );
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
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            markers: {
              if (_currentP != null)
                Marker(
                  markerId: MarkerId("current_position"),
                  position: _currentP!,
                  icon: BitmapDescriptor.defaultMarker,
                ),
              ..._gares.asMap().entries.map(
                (entry) => Marker(
                  markerId: MarkerId("gare_${entry.key}"),
                  position: entry.value,
                  infoWindow: InfoWindow(title: _nomsGares[entry.key]),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  ),
                  onTap: () => _selectGare(entry.value),
                ),
              ),
            },
            polylines: {
              Polyline(
                polylineId: PolylineId("ligne_gares"),
                color: Colors.red,
                width: 4,
                points: _gares,
              ),
              if (_itineraire.isNotEmpty)
                Polyline(
                  polylineId: PolylineId("itineraire"),
                  color: Colors.blue,
                  width: 4,
                  points: _itineraire,
                ),
            },
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
                  hintText: 'Rechercher une gare...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
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
            _buildBottomButton(LucideIcons.map, "Carte", () {}),
            _buildBottomButton(LucideIcons.barChart, "Statistique", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StatsScreen()),
              );
            }),
            _buildBottomButton(LucideIcons.bell, "Notifications", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            }),
            _buildBottomButton(LucideIcons.messageCircle, "Messagerie", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MessageScreen()),
              );
            }),
            _buildBottomButton(LucideIcons.user, "Profil", () {
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
