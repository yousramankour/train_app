import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'directions_model.dart';
import 'package:appmob/.env.dart';

class DirectionsRipository {

  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';
  final Dio _dio;

  DirectionsRipository({Dio? dio}) : _dio = dio ?? Dio();
  Future<Direction?> getDirection({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key': GOOGLE_API_KEY,
        },
      );

      if (response.statusCode == 200) {
        return Direction.fromMap(response.data);
      }
    } catch (e) {
      debugPrint('Direction API error: $e');
    }

    return null; // ✅ now allowed because return type is Future<Direction?>

  }
}
