import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class ManagerLoginPage extends StatefulWidget {
  const ManagerLoginPage({Key? key}) : super(key: key);

  @override
  State<ManagerLoginPage> createState() => _ManagerLoginPageState();
}

class _ManagerLoginPageState extends State<ManagerLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginManager() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(Uri.parse('http://127.0.0.1:8000/api/manager/login/',),
          headers: {'Content-Type': 'application/json',},
          body: jsonEncode({
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
     );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      // Login successful, navigate to dashboard
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('manager_logged_in', true,);
      await prefs.setInt('manager_id', data['user_id'],);
      await prefs.setString('username', data['username'],);
      await prefs.setString('email', data['email'],);

      Navigator.pushReplacementNamed(context, '/manager/dashboard-page');
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password'),),
      );
    }
    } catch (e) {
      // Handle network or parsing errors
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error: $e',),),
      );
    } 
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.business, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 24),
              const Text('Manager Portal', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              const Text('Sign in to manage your parking facilities.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              
              const Text('Work Email', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'admin@parkingcorp.com',
                  prefixIcon: const Icon(Icons.email, color: Colors.grey),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              
              const Text('Password', style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : loginManager,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Access Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}