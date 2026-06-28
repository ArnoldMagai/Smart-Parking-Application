import 'package:flutter/material.dart';
import 'dart:math';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({Key? key}) : super(key: key);

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  
  String generateOTP() {
    Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }


  bool _isValidPhone() {
    String phone = _phoneController.text.trim();
    if (_selectedCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a country code'),
        ),
      );
      return false;
    }
    if (phone.length < 9 || phone.length > 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid phone number'),
        ),
      );
      return false;
    }
    return true;
  }
  
  // Added list of country codes
  final List<String> _countryCodes = ['+1', '+44', '+91', '+61', '+81', '+971', '+254', '+255', '+27', '+250'];
  String? _selectedCode;

  void _showBottomSheet() {
    if (!_isValidPhone()) {
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Send code to', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 16),
              // Updated to show dynamic country code
              Text('$_selectedCode ${_phoneController.text}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.message, color: Colors.red),
                title: const Text('Send code by SMS'),
                onTap: () {
                  Navigator.pop(context);
                  // Pass the country code + phone number to the verify page
                  String otp = generateOTP();
                  print("OTP = $otp");
                  Navigator.pushNamed(context, '/driver/verify', arguments: {'phone': '$_selectedCode ${_phoneController.text}','otp':otp,},);
                },
                tileColor: Colors.black12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.phone, color: Colors.green),
                title: const Text('Send code by WhatsApp'),
                onTap: () {
                  Navigator.pop(context);
                  String otp = generateOTP();
                  print("OTP = $otp");
                  Navigator.pushNamed(context, '/driver/verify', arguments: {'phone': '$_selectedCode ${_phoneController.text}','otp':otp,},);
                },
                tileColor: Colors.black12,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit phone number'),
                onTap: () => Navigator.pop(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.grey),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter your number', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('We\'ll send a code to verify your phone.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              Row(
                children: [
                  // Updated: Hardcoded text changed to DropdownButton
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCode,
                        hint: const Text("Code"),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        items: _countryCodes.map((String code) {
                          return DropdownMenuItem<String>(
                            value: code,
                            child: Text(code),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedCode = newValue;
                          });
                        }
                        
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: '(555) 000-0000',
                        prefixIcon: const Icon(Icons.phone),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _showBottomSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Continue', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}