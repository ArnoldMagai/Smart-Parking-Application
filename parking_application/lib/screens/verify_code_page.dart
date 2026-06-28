import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyCodePage extends StatefulWidget {
  const VerifyCodePage({Key? key}) : super(key: key);

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  // Added: Controllers and FocusNodes for 6 text fields
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());

  Future<void> saveLoginSession(String phone) async {
    final prefs  = await SharedPreferences.getInstance();
    await prefs.setBool('driver_logged_in', true,);
    await prefs.setString('driver_phone', phone);
  }

  Future<void> verifyOTP(String correctOTP, String phone,) async {
    String enteredOTP = _controllers.map((controller) => controller.text).join();
    if (enteredOTP == correctOTP) {
      await saveLoginSession(phone);
      Navigator.pushNamedAndRemoveUntil(
        context, '/driver/home', (route) => false,
      );
   } else {
     ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invalid verification code'),
      ), );
   }
  }
  


  @override
  void dispose() {
    for (var node in _focusNodes) { node.dispose(); }
    for (var controller in _controllers) { controller.dispose(); }
    super.dispose();
  }

  // Added: Logic to move between boxes automatically
  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus(); // Last box, hide keyboard
      }
    } else {
      // If user deletes, go backwards
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieves the number passed from the previous page
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    print(args);
    final String phone = args['phone'] ?? '';
    final String otp = args['otp'] ?? '';

    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Verify code', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // Updated text to use the full argument passed over
              Text('We\'ve sent a 6-digit code to\n$phone', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index], // Attached focus node
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) => _onOtpChanged(value, index), // Calls logic to advance
                    ),
                  );
                }),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    verifyOTP(otp,phone,);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Verify', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Resend Code', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
