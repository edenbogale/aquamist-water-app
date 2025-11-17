// screens/profile_location_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';

// 💧 Define water blue — ONLY addition to your code
const Color kWaterBlue = Color(0xFF2196F3);

class ProfileLocationScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const ProfileLocationScreen({Key? key, this.initialLocation})
      : super(key: key);

  @override
  _ProfileLocationScreenState createState() => _ProfileLocationScreenState();
}

class _ProfileLocationScreenState extends State<ProfileLocationScreen> {
  late LatLng _pickedLocation;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation ??
        LatLng(-1.286389, 36.817223); // Nairobi default
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
        backgroundColor: kWaterBlue, // ← was Colors.teal
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _pickedLocation,
              initialZoom: 15.0,
              onTap: (tapPos, latlng) {
                setState(() {
                  _pickedLocation = latlng;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.aqua',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pickedLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kWaterBlue, // ← was Colors.teal
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text("Save Location",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: () {
                // ✅ Save to user profile
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                final user = userProvider.user;

                if (user != null) {
                  final updatedUser = user.copyWith(
                    address:
                        "${_pickedLocation.latitude}, ${_pickedLocation.longitude}",
                  );
                  userProvider.setUser(updatedUser);
                }

                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Location updated!"),
                  backgroundColor: kWaterBlue, // ← was Colors.teal
                ));

                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
