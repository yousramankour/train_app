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
  static const LatLng _pGooglePlex = LatLng(36.7333, 3.2800);
  LatLng? _currentP;
  bool _gpsEnabled = false;
  GoogleMapController? mapController; // Déclaration du contrôleur de carte

  @override
  void initState() {
    super.initState();
    checkGPSStatus();
  }

  Future<void> checkGPSStatus() async {
    bool serviceEnabled = await _locationController.serviceEnabled();
    setState(() {
      _gpsEnabled = serviceEnabled;
    });
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
          _gpsEnabled = true;
        });

        if (mapController != null && _currentP != null) {
          mapController!.animateCamera(CameraUpdate.newLatLng(_currentP!));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pGooglePlex,
              zoom: 14,
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
            },
          ),
          Align(
            alignment: Alignment(1, 0.3),
            child: ElevatedButton(
              onPressed: requestLocation,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(20),
                backgroundColor: Colors.white,
                shape: CircleBorder(),
              ),
              child: Icon(
                Icons.location_searching,
                size: 25,
                color: Colors.black,
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
