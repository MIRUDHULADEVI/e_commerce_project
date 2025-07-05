import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});
  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    print('🔍 Fetching orders for user: ');
    setState(() {
      isLoading = true;
    });
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');
    print(userId);

    if (userId == null || token == null) {
      print('❌ No user data found');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final res = await http.get(
      Uri.parse('http://192.168.40.207:5000/api/orders/user/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print('🕵️‍♂️ GET /orders: ${res.statusCode}');
    print(res.body);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        orders = data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (orders.isEmpty) return const Center(child: Text('🛍️ No orders found'));

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (c, idx) {
        final cartItems = orders[idx]['cartItems'] as List;
        final item = cartItems[0];
        return ListTile(
          leading: Image.asset('assets/images/${item['image']}'),
          title: Text(item['name']),
          subtitle: Text('₹${item['price']} x ${item['quantity']}'),
        );
      },
    );
  }
}
