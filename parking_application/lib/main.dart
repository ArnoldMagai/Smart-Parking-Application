import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'screens/phone_login_page.dart';
import 'screens/verify_code_page.dart';
import 'screens/driver_home_page.dart';
import 'screens/facility_details_page.dart';
import 'screens/profile_page.dart';
import 'screens/manager_register_facility_page.dart';
import 'screens/manager_dashboard_page.dart';
import 'screens/manager_login_page.dart';
import 'theme.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    print("REAL ERROR:");
    print(details.exception);

    print("STACK:`");
    print(details.stack);
  };
  runApp(const SmartParkingApp());
}

class SmartParkingApp extends StatefulWidget {
  const SmartParkingApp({Key? key}) : super(key: key);

  @override
  State<SmartParkingApp> createState() => _SmartParkingAppState();
}

class _SmartParkingAppState extends State<SmartParkingApp> {
  bool isDarkMode = true;
  bool isLoggedIn = false;
  bool loading = true;

  Future<void> checkLogin() async {
   try {    
     final prefs =
         await SharedPreferences.getInstance();
 
     isLoggedIn = 
         prefs.getBool('driver_logged_in',) ??
         false;

     print("LOGIN STATUS = $isLoggedIn");
    } catch (e) {
      print("SHARED PREF ERROR:");
      print(e);
    }   

    setState(() {
      loading = false;
    });
  }

  @override 
  void initState() {
    super.initState();
    
    Future.microtask(() {
      checkLogin();
    });
  }

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    return MaterialApp(
      title: 'Smart parking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
  
      home: isLoggedIn
          ? const DriverHomePage()
          : const LandingPage(),

      routes:{
        '/driver/login': (context) => const PhoneLoginPage(),
        '/driver/verify': (context) => const VerifyCodePage(),
        '/driver/home':(context) =>  const DriverHomePage(),
        '/driver/facility': (context) => const FacilityDetailsPage(),
        '/manager/dashboard-page': (context) => const ManagerDashboardPage(),
        '/manager/register-facility': (context) => const ManagerRegisterFacilityPage(),
        '/manager/login-page': (context) => const ManagerLoginPage(),
        '/driver/profile': (context) => ProfilePage(isDarkMode: isDarkMode, onThemeToggle: toggleTheme,),
      } ,    
    );
  }
}
