// screens/map_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// 💧 Define water blue — ONLY addition to your code
const Color kWaterBlue = Color(0xFF2196F3);

class MapScreen extends StatefulWidget {
  final LatLng customerLocation; // ✅ This must come from saved profile location
  final String orderTitle;

  const MapScreen({
    Key? key,
    required this.customerLocation,
    required this.orderTitle,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _deliveryBoyLocation;
  StreamSubscription<Position>? _positionStream;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _startLiveLocationUpdates();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _startLiveLocationUpdates() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _deliveryBoyLocation = LatLng(-1.286389, 36.817223));
        _sendLocationToServer();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _deliveryBoyLocation = LatLng(-1.286389, 36.817223));
          _sendLocationToServer();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _deliveryBoyLocation = LatLng(-1.286389, 36.817223));
        _sendLocationToServer();
        return;
      }

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) {
        setState(() {
          _deliveryBoyLocation = LatLng(position.latitude, position.longitude);
        });
        _sendLocationToServer();
      });
    } on Exception catch (e) {
      print("Location error: $e");
      setState(() => _deliveryBoyLocation = LatLng(-1.286389, 36.817223));
      _sendLocationToServer();
    }
  }

  Future<void> _sendLocationToServer() async {
    if (_deliveryBoyLocation == null) return;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/water_api/update_location.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'order_id': widget.orderTitle.split('#').last.split(' ').first,
          'latitude': _deliveryBoyLocation!.latitude,
          'longitude': _deliveryBoyLocation!.longitude,
        }),
      );

      print('📍 Location update: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('❌ Failed to send location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.orderTitle),
        backgroundColor: kWaterBlue, //
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: widget.customerLocation, // ✅ Use EXACT saved location
          initialZoom: 14.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
            userAgentPackageName: 'com.example.aqua',
          ),
          MarkerLayer(
            markers: [
              // 🔵 Delivery Boy (blue motorcycle)
              if (_deliveryBoyLocation != null)
                Marker(
                  point: _deliveryBoyLocation!,
                  width: 50,
                  height: 50,
                  child: Icon(Icons.motorcycle, color: Colors.blue, size: 40),
                ),

              // ✅ RED PIN: Exact location you saved in Profile
              Marker(
                point: widget.customerLocation,
                width: 50,
                height: 50,
                child: Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
