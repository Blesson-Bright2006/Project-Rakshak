import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBCGhfUMvSwQvxGr8zj1W0i0hoAyDFf6QU",
      appId: "1:98589889380:android:4990367ca05fe1db306071",
      messagingSenderId: "98589889380",
      projectId: "project-rakshak-7c370",
      databaseURL: "https://project-rakshak-7c370-default-rtdb.firebaseio.com",
      storageBucket: "project-rakshak-7c370.firebasestorage.app",
    ),
  );
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: RakshakMainContainer(),
  ));
}

class RakshakMainContainer extends StatefulWidget {
  const RakshakMainContainer({super.key});
  @override
  State<RakshakMainContainer> createState() => _RakshakMainContainerState();
}

class _RakshakMainContainerState extends State<RakshakMainContainer> {
  int _selectedIndex = 0;
  StreamSubscription? _alertSubscription;

  @override
  void initState() {
    super.initState();
    _startAlertListener();
  }

  void _startAlertListener() {
    final dbRef = FirebaseDatabase.instance.ref("beacons/beacon_Kochi/status");
    _alertSubscription = dbRef.onValue.listen((event) {
      if (event.snapshot.value.toString().contains("VERIFIED")) {
        _triggerEmergencyAlert();
      }
    });
  }

  void _triggerEmergencyAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade900,
        title: const Text("🚨 EMERGENCY ALERT",
            style: TextStyle(color: Colors.white)),
        content: const Text("Hydro-Beacon detected a person in Kochi Sector!",
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL",
                  style: TextStyle(color: Colors.white70))),
          ElevatedButton(
              onPressed: _openExternalMaps, child: const Text("OPEN GPS")),
        ],
      ),
    );
  }

  Future<void> _openExternalMaps() async {
    final Uri uri = Uri.parse("google.navigation:q=9.9312,76.2673&mode=d");
    if (!await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication)) {
      await launchUrl(Uri.parse(
          "https://www.google.com/maps/search/?api=1&query=9.9312,76.2673"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
          index: _selectedIndex,
          children: const [MapTab(), ResourcesTab(), InfoTab()]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Live Map'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory), label: 'Resources'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Sensors'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _alertSubscription?.cancel();
    super.dispose();
  }
}

// --- 🛰️ TAB 1: LIVE INTERACTIVE MAP ---
class MapTab extends StatelessWidget {
  const MapTab({super.key});
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
          initialCenter: LatLng(9.9312, 76.2673), initialZoom: 14.0),
      children: [
        TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.dashboard'),
        MarkerLayer(
          markers: [
            Marker(
              point: const LatLng(9.9312, 76.2673),
              width: 80,
              height: 80,
              child: const Icon(Icons.radio_button_checked,
                  color: Colors.red, size: 40),
            ),
          ],
        ),
      ],
    );
  }
}

// --- 📦 TAB 2: RESOURCES GRID ---
class ResourcesTab extends StatelessWidget {
  const ResourcesTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: const Text("RESOURCES"), backgroundColor: Colors.red.shade900),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(15),
        children: [
          _buildCard("BOATS", "03", Icons.directions_boat, Colors.blue),
          _buildCard(
              "JACKETS", "45", Icons.support, Colors.orange), // Fixed Icon Name
          _buildCard("DRONES", "02", Icons.radar, Colors.purple),
          _buildCard("KITS", "120", Icons.fastfood, Colors.green),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String count, IconData icon, Color color) {
    return Card(
      color: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 40),
          Text(count,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}

// --- 📊 TAB 3: SENSOR DATA ---
class InfoTab extends StatelessWidget {
  const InfoTab({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: const Text("SENSORS"),
          backgroundColor: Colors.blueGrey.shade900),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sensorBar("Water Flow", 0.8, "CRITICAL"),
          _sensorBar("Pulse", 0.72, "STABLE"),
          _sensorBar("Battery", 0.94, "94%"),
        ],
      ),
    );
  }

  Widget _sensorBar(String label, double value, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white)),
              Text(status,
                  style: TextStyle(
                      color: value > 0.75 ? Colors.red : Colors.green)),
            ],
          ),
          const SizedBox(height: 5),
          LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.white12,
              color: value > 0.75 ? Colors.red : Colors.blue),
        ],
      ),
    );
  }
}
