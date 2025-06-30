import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://ecommerce-backend-xalg.onrender.com/api"; // Replace with your local IP

  Future<Map<String, dynamic>> fetchCart(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch cart');
    }
  }

  Future<void> updateCart(List<Map<String, dynamic>> items, String token) async {
    await http.post(
      Uri.parse('$baseUrl/cart'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'items': items}),
    );
  }

}
