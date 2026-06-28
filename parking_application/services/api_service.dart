import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android emulator to access localhost
  static const String baseUrl = "http://10.0.2.2:8000/api";
  
  static Future<Map<String, dynamic>> loginWithPhone(String phone) async {
    // Send POST request to Django backend
    final response = await http.post(
      Uri.parse('$baseUrl/auth/phone/'),
      body: jsonEncode({'phone': phone}),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> verifyOTP(String phone, String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify/'),
      body: jsonEncode({'phone': phone, 'code': code}),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getFacilities() async {
    final response = await http.get(Uri.parse('$baseUrl/facilities/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load facilities');
    }
  }

  static Future<Map<String, dynamic>> getFacilityDetails(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/facilities/$id/'));
    return jsonDecode(response.body);
  }
}
