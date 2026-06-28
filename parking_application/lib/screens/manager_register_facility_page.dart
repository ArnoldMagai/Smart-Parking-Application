import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ManagerRegisterFacilityPage extends StatefulWidget {
  const ManagerRegisterFacilityPage({Key? key}) : super(key: key);

  @override
  State<ManagerRegisterFacilityPage> createState() => _ManagerRegisterFacilityPageState();
}

class _ManagerRegisterFacilityPageState extends State<ManagerRegisterFacilityPage> {
  final _formKey = GlobalKey<FormState>();
  bool _success = false;
  bool loading = false;

  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final capacityController = TextEditingController();
  
  

  Future<void> _handleSubmit() async {
    final prefs = await SharedPreferences.getInstance();
    int? managerId = prefs.getInt('manager_id');

    if (managerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Manager not logged in'),
        ),
      );
      return;
    }
    setState(() {
      loading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/register-facility/',),
        headers: {'Content-Type': 'application/json',},
        body: jsonEncode({
          'manager_id': managerId,
          'name': nameController.text,
          'owner_name': 'Manager',
          'email': '',
          'phone': '',
          'location': locationController.text,
          'latitude': 0,
          'longitude': 0,
          'total_slots': int.tryParse(capacityController.text,) ?? 0,
        }),
      );

      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _success = true;
        });
        Future.delayed(
          const Duration(seconds: 2),
          () {
            Navigator.pushReplacementNamed(
              context,
              '/manager/dashboard-page',
            );
          },
        );
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_success) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
              ),
              const SizedBox(height: 24),
              const Text('Facility Submitted!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              const Text('Your parking lot has been successfully\nadded to the system awaiting administrator approval.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

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
        child: Form( key: _formKey, child: SingleChildScrollView( 
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Register Facility', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              const Text('Add a new parking lot to your management portfolio.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              
              _buildInputLabel('Facility Name'),
              _buildTextField( controller: nameController, hintText: 'e.g. Westside Plaza Parking', icon: Icons.business, validator: (value) { if (value == null || value.trim().isEmpty) {return 'Facility name is required';} return null;},),
              const SizedBox(height: 20),
              
              _buildInputLabel('Location / Address'),
              _buildTextField(controller: locationController, hintText: 'Full address', icon: Icons.location_on, validator: (value) {if (value == null || value.trim().isEmpty){return 'Location is required';}return null;},),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('Capacity'),
                        _buildTextField(controller: capacityController, hintText: 'Total slots', icon: Icons.format_list_numbered, isNumber: true, validator: (value) {if (value == null || value.trim().isEmpty) {return ' Capacity is required';} final capacity = int.tryParse(value); if (capacity == null || capacity <=0) {return 'Enter a valid capacity';}return null;},),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  /*Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel('Hourly Rate'),
                        _buildTextField(hintText: '0.00', icon: Icons.attach_money, isNumber: true),
                      ],
                    ),
                  ),*/
                ],
              ),
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {if (! _formKey.currentState!.validate()) {return;} _handleSubmit();},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Register Facility', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14)),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText, required IconData icon, bool isNumber = false, String? Function(String?)? validator,}) {
    return TextFormField(
      validator: validator,
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}