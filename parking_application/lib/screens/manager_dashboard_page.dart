import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';  
import 'package:http/http.dart' as http;
import 'dart:convert';


class ManagerDashboardPage extends StatefulWidget {
  const ManagerDashboardPage({Key? key}) : super(key: key);

  @override
  State<ManagerDashboardPage> createState() => _ManagerDashboardPageState();
}

class _ManagerDashboardPageState extends State<ManagerDashboardPage> {
  bool checkingLogin = true;
  
  List facilities = [];
  bool loadingFacilities = true;
  String username = '';

 @override
  void initState() {
    super.initState();
    checkLogin();
    fetchFacilities();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
    });
  }

  Future<void> fetchFacilities() async {
    final prefs = await SharedPreferences.getInstance();
    int? managerId = prefs.getInt('manager_id'); 
    print('Manager ID = $managerId'); // Debugging line

    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/manager-facilities/$managerId/',),);

      print('STAUS CODE = ${response.statusCode}'); // Debugging line
      print('BODY = ${response.body}'); // Debugging line

      if (response.statusCode == 200) {
        setState(() {
          facilities = jsonDecode(response.body);
          loadingFacilities = false;
        });
      } else {
        setState(() {
          loadingFacilities = false;
        });
        
      }
    } catch (e) {
      print('ERROR = $e'); // Debugging line
      setState(() {
        loadingFacilities = false;
      });
    }
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('manager_logged_in') ?? false;
    if (!loggedIn) {
      Navigator.pushReplacementNamed(context, '/manager/login-page',);
      return;
    } 

      setState(() {
        checkingLogin = false;
      });

  }

  @override
  Widget build(BuildContext context) {
    if (checkingLogin) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(),),
      );
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        title:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manager Portal', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Welcome back, $username', style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushNamedAndRemoveUntil(context, '/manager/login-page', (route) => false,);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                       children: [
                         Expanded(
                           child: Container(
                             padding: const EdgeInsets.all(16),
                             decoration: BoxDecoration(
                               color: Theme.of(context).colorScheme.surface,
                               borderRadius: BorderRadius.circular(16),
                              ),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 const Text(' TOTAL FACILITIES', style: TextStyle(color: Colors.grey, fontSize:12,),),
                                 const SizedBox(height: 8),
                                 Text(
                                   '${facilities.length}',
                                   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold,),
                                  ),
                                ],  
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                    ),
                  ),
                ],
              ),
            ),   
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Your Facilities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/manager/register-facility'),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add New'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  loadingFacilities
                    ? const Center(child: CircularProgressIndicator(),)
                    : facilities.isEmpty
                      ? const Center(child: Text('No facilities found. Please add one.', style: TextStyle(color: Colors.grey),),)
                      : Column(
                          children: facilities.map((facility) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(facility['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                      const SizedBox(height: 4),
                                      Text(facility['location'], style: const TextStyle(color: Colors.grey,),),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5,),
                                    decoration: BoxDecoration(
                                      color: facility['is_approved']
                                          ? Colors.green.withValues(alpha: 0.1)
                                          : facility['is_denied'] == true
                                              ? Colors.red.withValues(alpha: 0.1)
                                              : Colors.orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(facility['is_approved'] ? 'APPROVED' : facility['is_denied'] == true ? 'DENIED' : 'PENDING', style: TextStyle(color: facility['is_approved'] ? Colors.green : facility['is_denied'] == true ? Colors.red : Colors.orange,),),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                  
                  // Add new dashed button
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/manager/register-facility'),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.3), style: BorderStyle.solid), // Dashed border styling optional
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, color: Colors.grey, size: 32),
                          SizedBox(height: 8),
                          Text('Register Facility', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Facilities'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}