import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "https://ecommerce-backend-xalg.onrender.com/api";

  static Future<Map<String, dynamic>> signup({
    required String username,
    required String password,
    required String email,
    required String phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username.trim().toLowerCase(),
        "password": password.trim(),
        "email": email.trim(),
        "phone": phone.trim(),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {
        'success': false,
        'message': 'Signup failed',
        'status': response.statusCode,
        'body': response.body
      };
    }
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username.trim().toLowerCase(),
        "password": password.trim(),
      }),
    );

    final data = jsonDecode(response.body);
    print('🔐 Login response: $data');

    final token = data['token']?.toString() ?? '';
    if (token.isEmpty) {
      return data; // No token = error or bad login
    }

    try {
      final cartResp = await http.get(
        Uri.parse('$baseUrl/cart'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (cartResp.statusCode == 200) {
        final cartData = jsonDecode(cartResp.body);
        data['cart'] = cartData['items'] is List ? cartData['items'] : [];
      } else {
        data['cart'] = [];
      }
    } catch (e) {
      print('🛑 Cart fetch error: $e');
      data['cart'] = [];
    }

    return data;
  }
}
