import 'package:flutter/material.dart';
import 'package:appmob/chat.dart';// Assurez-vous que ce fichier existe
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';


class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Location _locationController = new Location();
  static const LatLng _pGooglePlex = LatLng(36.7333, 3.2800); // to display rouiba
  LatLng? _currentP;
  bool _gpsEnabled = false;
  final TextEditingController _startLocationController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkGPSStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 172, 219, 241),
              ),
              child: Center(
                child: Text(
                  "Menu",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person, color: Colors.blue),
              title: Text("My Profile"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.bar_chart, color: Colors.blue),
              title: Text("Statistics"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.blue),
              title: Text("Chat"),
              onTap: () {
                Navigator.pop(context); // ✅ Ferme le Drawer avant de naviguer
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.grey),
              title: Text("Settings"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Logout"),
              onTap: () {},
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.black, size: 30),
              onPressed: () {
                Scaffold.of(
                  context,
                ).openDrawer(); // ✅ Ouvre correctement le menu
              },
            );
          },
        ),
      ),
      body: Stack(
      children: [
      GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _pGooglePlex,
        zoom: 14,
      ),
      zoomControlsEnabled: false,

      markers: {

        if (_currentP != null)
          Marker(
            markerId: MarkerId("_current_position"),
            position: _currentP!,
            icon: BitmapDescriptor.defaultMarker,
            // infoWindow: const InfoWindow(title: "Gare de rouiba"),
          ),


      },
    ),
    Align(
    alignment: Alignment(1, 0.3),
    child: ElevatedButton(

    onPressed: requestLocation,
    style: ElevatedButton.styleFrom(
    padding: EdgeInsets.all(20),
    backgroundColor: Colors.white, // Button color
    shape: CircleBorder()
    ),
    child: Icon(
    Icons.location_searching,
    size: 25,
    color: Colors.black,
    )
    ),
    ),
    DraggableScrollableSheet(
    initialChildSize: 0.3,
    minChildSize: 0.05,
    maxChildSize: 0.7,
    builder: (BuildContext context,
    ScrollController scrollController) {
    return Container(
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.horizontal(
    left: Radius.circular(30),
    right: Radius.circular(30)),
    ),

    child: SingleChildScrollView(
    controller: scrollController,

    child: Column(

    children: [
    Container(
    margin: EdgeInsets.only(top: 8),
    width: 70,
    height: 5,
    decoration: BoxDecoration(
    color: Colors.grey[400],
    borderRadius: BorderRadius.circular(10),
    ),
    ),
    SizedBox(height: 20),

    /// Start Location Input
    TextField(
    controller: _startLocationController,
    decoration: InputDecoration(
    labelText: "Start Location",
    prefixIcon: Icon(Icons.location_on),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20)),
    ),
    ),
    SizedBox(height: 15),

    /// Destination Input
    TextField(
    controller: _destinationController,
    decoration: InputDecoration(
    labelText: "Destination",
    prefixIcon: Icon(Icons.map),
    border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(20)),
    ),
    ),
    SizedBox(height: 20),

    /// Submit Button
    ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    // Change button color
    foregroundColor: Colors.white,
    // Change text color
    padding: EdgeInsets.symmetric(
    horizontal: 30, vertical: 15),
    // Adjust size
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(
    12), // Rounded corners
    ),
    ),
    onPressed: () {
    print("Start: ${_currentP}");
    print("Destination: ${_destinationController
        .text}");
    },
    child: Text("Find Train"),
    ),
    ],
    )
    )
    );
    }
    )
    ]
    ),
    );
  }

  Future<void> checkGPSStatus() async {
    bool serviceEnabled = await _locationController.serviceEnabled();
    setState(() {
      _gpsEnabled = serviceEnabled;
    });
  }

  Future<void> requestLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    // Check if GPS is enabled
    serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) {
        print("User refused to enable GPS.");
        return; // Don't proceed if user refuses
      }
    }

    // Check and request permission
    permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print("Permission denied.");
        return;
      }
    } else if (permissionGranted == PermissionStatus.deniedForever) {
      print("Permission permanently denied. Redirecting to settings.");
      openAppSettings();
      return;
    }

    // Start getting location updates
    _locationController.onLocationChanged.listen((
        LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          _gpsEnabled = true;
          print("Updated location: $_currentP");
        });
      }
    });
  }

}
void openAppSettings() async {
  final Uri url = Uri.parse('app-settings:');
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    print("Could not open app settings.");
  }
}
