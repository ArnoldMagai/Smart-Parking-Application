import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'activity_page.dart';



class DriverHomePage extends StatefulWidget {
  const DriverHomePage({Key? key}) : super(key: key);

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> activityHistory = [];
  String currentLocation = "Detecting Location...";

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
    Position position = await Geolocator.getCurrentPosition();

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
            Expanded(
              child: facilities.isEmpty
                ? const Center(child: Text('No parking facility registered in the entered location',),)
                :ListView.builder(
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