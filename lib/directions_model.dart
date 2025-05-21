import 'package:flutter/cupertino.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Direction {
  final LatLngBounds bounds;
  final List<PointLatLng> polylinePoints;
  final String TotalDistance;
  final String TotalDuration;

  const Direction({
    required this.bounds,
    required this.polylinePoints,
    required this.TotalDistance,
    required this.TotalDuration,
  });

  factory Direction.fromMap(Map<String, dynamic> map) {
    if ((map['routes'] as List).isEmpty) throw Exception('No routes found');
    final data = map['routes'][0] as Map<String, dynamic>;
    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      northeast: LatLng(northeast['lat'], northeast['lng']),
      southwest: LatLng(southwest['lat'], southwest['lng']),
    );
    String distance = '';
    String duration = '';
    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];
    }
    return Direction(
      bounds: bounds,
      polylinePoints: PolylinePoints().decodePolyline(
        data['overview_polyline']['points'],
      ),
      TotalDistance: distance,
      TotalDuration: duration,
    );
  }
}
