// screens/profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';
import 'profile_location_screen.dart'; // ✅ Import new screen
import 'package:latlong2/latlong.dart';

// 💧 Define water blue — ONLY addition to your code
const Color kWaterBlue = Color(0xFF2196F3);

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final User? user = userProvider.user;

    // Show loading or placeholder if no user
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('No user found. Please sign up again.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: kWaterBlue), // ← was Colors.teal
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
              color: kWaterBlue,
              fontWeight: FontWeight.bold), // ← was Colors.teal
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor:
                      kWaterBlue.withOpacity(0.3), // ← was Colors.teal[300]
                  child:
                      const Icon(Icons.person, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),
                _item(
                    Icons.person,
                    kWaterBlue, // ← was Colors.teal
                    user.name,
                    () => _edit('Name', user.name,
                        (v) => _updateUser(user.copyWith(name: v)))),
                _item(
                    Icons.phone,
                    Colors.orange,
                    user.phone,
                    () => _edit('Phone', user.phone,
                        (v) => _updateUser(user.copyWith(phone: v)))),
                _item(
                    Icons.email,
                    Colors.orange,
                    user.email,
                    () => _edit('Email', user.email,
                        (v) => _updateUser(user.copyWith(email: v)))),

                // ✅ Location picker
                _item(
                  Icons.location_on,
                  Colors.orange,
                  user.address.isNotEmpty ? user.address : "Set your location",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => ProfileLocationScreen(
                          initialLocation: user.address.contains(",")
                              ? LatLng(
                                  double.parse(user.address.split(",")[0]),
                                  double.parse(user.address.split(",")[1]),
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                ),

                const Divider(),
                _item(Icons.logout, Colors.red, 'Log out', _logout),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(IconData icon, Color color, String text, VoidCallback? onTap) {
    if (text == 'none') return Container(); // skip invalid items

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _edit(String title, String current, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: current);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: title,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                onSave(value);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('$title updated')));
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: kWaterBlue), // ← was Colors.teal
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _updateUser(User updatedUser) {
    Provider.of<UserProvider>(context, listen: false).setUser(updatedUser);
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Provider.of<UserProvider>(context, listen: false).clearUser();
              Navigator.pushNamedAndRemoveUntil(
                  ctx, '/signin', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
