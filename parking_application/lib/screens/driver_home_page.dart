import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'activity_page.dart';
import 'package:url_launcher/url_launcher.dart';



class DriverHomePage extends StatefulWidget {
  const DriverHomePage({Key? key}) : super(key: key);

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  int _selectedIndex = 0;
  bool isMapView = false;
  List<Map<String, dynamic>> activityHistory = [];
  List<LatLng> routePoints = [];
  String currentLocation = "Detecting Location...";
  String trafficStatus = "Normal";
  double? currentLatitude;
  double? currentLongitude;
  double? routeDistance;
  double? routeDuration;
  final MapController mapController = MapController();

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        currentLocation = "Location disabled";
      });
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        currentLocation = "Permission denied";
      });
      return;
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high,);
    currentLatitude = position.latitude;
    currentLongitude = position.longitude;

    final response = await http.get(
      Uri.parse(
        'http://127.0.0.1:8000/api/reverse-geocode/'
        '?lat=${position.latitude}'
        '&lng=${position.longitude}',
      ),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      if (data['success']) {

        setState(() {
          currentLocation = data['location'];
        });

      } else {

        setState(() {
          currentLocation = "Location unavailable";
        });

      }

    } else {

      setState(() {
        currentLocation = "Location unavailable";
      });

    }
  }

  // Added diverse mock facilities to match React design
  List facilities = [];

  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();

  final String apiUrl = 'http://127.0.0.1:8000/api/facilities/'; // Replace with your actual API endpoint
  Future<void> fetchFacilities([String search = '']) async {
    try {
      String url = 'http://127.0.0.1:8000/api/facilities/';
      
      if (search.isNotEmpty) {
        url = 'http://127.0.0.1:8000/api/facilities/?search=$search';
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          facilities = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load facilities');
      }
    } catch (e) {
      print(e);
    
    }
  }

  Future<void> getRoute(double destinationLat, double destinationLng,) async {
    final url = 'http://router.project-osrm.org/route/v1/driving/''$currentLongitude,$currentLatitude;''$destinationLng,$destinationLat''?overview=full&geometries=geojson';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['routes'] == null || data['routes'].isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No route found')),
        );
        return;
      }
      final coordinates = data['routes'][0]['geometry']['coordinates'];
      List<LatLng> points = [];
      for (var coord in coordinates) {
        points.add(LatLng(coord[1], coord[0]));
      }
      setState((){
        routePoints = points;
        routeDistance = data['routes'][0]['distance'] / 1000; // Convert to km
        routeDuration = data['routes'][0]['duration'] / 60; // Convert to minutes
        DateTime now = DateTime.now();
        int hour= now.hour;

        double trafficFactor;
        if ((hour >= 6 && hour <= 9)) {
          //Morning rush hour
          trafficFactor = 2.0;
          trafficStatus = "Morning Traffic";
        } else if ((hour >= 10 && hour <= 15)) {
          //Daytime traffic
          trafficFactor = 1.5;
          trafficStatus = "Moderate Traffic";
        } else if ((hour >= 16 && hour <= 19)) {
          //Evening rush hour
          trafficFactor = 2.2;
          trafficStatus = "Heavy Traffic";  
        } else {
          //NightTraffic
          trafficFactor = 1.2;
          trafficStatus = "Light Traffic";
        }
        // Use the already computed routeDuration as the base duration (in minutes)
        // routeDuration may be nullable, fall back to 0.0 if null
        double baseDuration = routeDuration ?? 0.0;
        routeDuration = baseDuration * trafficFactor;
      });
      if (points.isNotEmpty) {
        mapController.fitCamera(
          CameraFit.bounds(bounds: LatLngBounds.fromPoints(points), padding: const EdgeInsets.all(60),),
        );
      }
    }
  }

  Future<void> openGoogleMaps(double latitude, double longitude,) async {
    final Uri url = Uri.parse('https://www.google.com/maps/dir/?api=1''&destination=$latitude,$longitude''&travelmode=driving');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication,);
    }
  }


  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder:(_) => ActivityPage(activities: activityHistory,),),);
    } else if (index == 2) {
      Navigator.pushNamed(context, '/driver/profile',);
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }
  
  @override
  void initState() {
    super.initState();
    fetchFacilities();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Current Location', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red, size: 16),
                          const SizedBox(width: 4),
                          Text( currentLocation, style: const TextStyle(fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: searchController,
                onChanged: (value) {fetchFacilities(value);},
                decoration: InputDecoration(
                  hintText: 'Search destination...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child:GestureDetector(
                        onTap: () {
                          setState (() {
                            isMapView = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !isMapView ? Colors.red : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              'List View',
                              style: TextStyle(
                                color: !isMapView ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isMapView = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isMapView ? Colors.red : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Text(
                              'Map View',
                              style: TextStyle(
                                color: isMapView ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),


            const SizedBox(height: 16),
            Expanded(
              child: isMapView
                  ? Stack(
                      children: [
                        FlutterMap(
                          mapController: mapController,
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
                        if (routePoints.isNotEmpty)
                          PolylineLayer(polylines: [Polyline(points: routePoints, strokeWidth: 5, color: Colors.blue)],),
                        MarkerLayer(
                          markers: [
                            if (currentLatitude != null && currentLongitude != null)
                              Marker(
                                point: LatLng(currentLatitude!, currentLongitude!),
                                width: 80,
                                height: 80,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.7),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                  ),
                                ),
                              ),
                            ...facilities
                              .where(
                                (facility) =>
                                facility['latitude'] != null &&
                                facility['longitude'] != null &&
                                facility['latitude'] != 0.0 &&
                                facility['longitude'] != 0.0,
                              )
                              .map<Marker>(
                                (facility) => Marker(
                                  point: LatLng(
                                    facility['latitude'],
                                    facility['longitude'],
                                  ),
                                  width: 80,
                                  height: 80,
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text(facility['name']),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(Icons.location_on, color: Colors.red, size: 18),
                                                  const SizedBox(width: 6),
                                                  Expanded(child: Text(facility['location'])),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.local_parking,
                                                    color: Colors.green,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text('${facility['total_slots']} Slots'),
                                                ],
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Close'),
                                            ),
                                            ElevatedButton.icon(
                                              icon: const Icon(Icons.navigation),
                                              label: const Text('Navigate'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                getRoute(
                                                  facility['latitude'],
                                                  facility['longitude'],
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                                  ),
                                ),
                              )
                              .toList(),
                            ],
                        )
                      ],
                    ),
                   if (routePoints.isNotEmpty)
                     Positioned(
                       top: 15,
                       left: 15,
                       right: 15,
                       child: Container(
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(
                           color: Colors.black87,
                           borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Distance',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '${routeDistance?.toStringAsFixed(2) ?? '0.00'} km',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: Colors.white24,
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'ETA',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                 ),
                                 const SizedBox(height: 5),
                                 Text(
                                   trafficStatus,
                                   style: const TextStyle(
                                     color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                     fontSize: 12,
                                   ),
                                 ),
                                 Text(
                                   '${routeDuration?.toStringAsFixed(0) ?? '0'} min',
                                   style: const TextStyle(
                                     color: Colors.white,
                                     fontWeight: FontWeight.bold,
                                     fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                    ],
                  )
                  : facilities.isEmpty
                ? const Center(child: Text('No parking facility registered in the entered location',),)
                : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: facilities.length,
                itemBuilder: (context, index) {
                  final facility = facilities[index];
                  final int slots = facility['total_slots'] ?? 0; // Handle null case
                  final bool hasSlots = slots > 0;

                  return GestureDetector(
                    onTap: () { 
                      activityHistory.insert(
                        0,
                        {
                          'name': facility['name'],
                          'time': DateTime.now(),
                        },
                      );
                      Navigator.pushNamed(context, '/driver/facility', arguments: facility); },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?auto=format&fit=crop&q=80&w=600',
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(facility['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text(facility['location'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: hasSlots ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: hasSlots ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2)),
                                  ),
                                  child: Text(
                                    '$slots slots', 
                                    style: TextStyle(
                                      color: hasSlots ? Colors.green : Colors.red, 
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold
                                    )
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: 'Activity'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}