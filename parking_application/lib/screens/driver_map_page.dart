import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DriverMapPage extends StatelessWidget {
  const DriverMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parking Map"),
      ),
      body: FlutterMap(
        options: const MapOptions(
          initialCenter: LatLng(-6.7924, 39.2083),
          initialZoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName:
                'com.example.smart_parking',
          ),
        ],
      ),
    );
  }
}