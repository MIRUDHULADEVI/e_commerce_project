import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../providers/user_provider.dart';
import 'login_page.dart';
import 'product_detail.dart';
import '../providers/cart_provider.dart';
import '../models/product.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> localProducts = [
    Product(
      id: '1',
      name: '20-Litre Refilled RO Water',
      imageUrl: 'image 1.png',
      price: 20.0,
      originalPrice: 30.0,
      description: 'Refilled RO Water',
    ),
    Product(
      id: '2',
      name: '20-Litre Branded Drinking Water',
      imageUrl: 'image 2.png',
      price: 45.0,
      originalPrice: 75.0,
      description: 'Branded water',
    ),
    Product(
      id: '3',
      name: '20-Litre Premium Branded Drinking Water',
      imageUrl: 'image 3.png',
      price: 85.0,
      originalPrice: 120.0,
      description: 'Premium Branded water',
    ),
  ];

  List<bool> wishlistStates = [];

  @override
  void initState() {
    super.initState();
    wishlistStates = List.generate(localProducts.length, (_) => false);
    updatePricesFromServer();
  }

  Future<void> updatePricesFromServer() async {
    try {
      final response = await http.get(Uri.parse('https://ecommerce-backend-xalg.onrender.com/api/product-prices'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        for (var item in jsonData) {
          final index = localProducts.indexWhere((p) => p.id == item['id']);
          if (index != -1) {
            localProducts[index] = Product(
              id: localProducts[index].id,
              name: localProducts[index].name,
              imageUrl: localProducts[index].imageUrl,
              description: localProducts[index].description,
              price: item['price'].toDouble(),
              originalPrice: item['originalPrice'].toDouble(),
            );
          }
        }
        setState(() {});
      } else {
        throw Exception('Failed to fetch updated prices');
      }
    } catch (e) {
      print('Error fetching prices: $e');
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _toggleWishlist(int index) {
    setState(() {
      wishlistStates[index] = !wishlistStates[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 198, 172, 229),
              Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🔐 Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundImage: AssetImage('assets/images/user.jpg'),
                        ),
                        const SizedBox(width: 12),
                        Consumer<UserProvider>(
                          builder: (context, userProvider, child) {
                            final username = userProvider.username;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Welcome,", style: TextStyle(fontSize: 14, color: Colors.black54)),
                                Text(
                                  username?.isNotEmpty == true ? username! : "User",
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Consumer<CartProvider>(
                          builder: (context, cart, _) => Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.shopping_cart, color: Colors.black),
                                onPressed: () => Navigator.pushNamed(context, '/cart'),
                              ),
                              if (cart.cartItems.isNotEmpty)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      cart.cartItems.length.toString(),
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout),
                          onPressed: () => _logout(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 🔍 Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 📦 Product Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: localProducts.length,
                  itemBuilder: (context, index) {
                    final product = localProducts[index];
                    final isWishlisted = wishlistStates.length > index ? wishlistStates[index] : false;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailPage(product: product),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  child: Image.asset(
                                    'assets/images/${product.imageUrl}',
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.fitHeight,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => _toggleWishlist(index),
                                    child: Icon(
                                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                                      color: isWishlisted ? Colors.red : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Text(
                                        "Rs.${product.originalPrice?.toStringAsFixed(0) ?? ''}",
                                        style: const TextStyle(
                                          decoration: TextDecoration.lineThrough,
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Rs.${product.price.toStringAsFixed(0)}",
                                        style: const TextStyle(
                                          color: Colors.deepPurple,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
