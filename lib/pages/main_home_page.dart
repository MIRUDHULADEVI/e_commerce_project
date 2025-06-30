import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/user_provider.dart';
import 'cart_page.dart';
import 'about_page.dart';
import 'user_profile_page.dart';
import 'home_page.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _currentIndex = 0;

  final List<String> _titles = [
    'Home',
    'Products',
    'About Us',
    'Your Cart',
    'My Orders',
  ];

  final List<Widget> _pages = [
    const HomeContent(),
    const HomePage(),
    const AboutPage(),
    const CartPage(),
    const MyOrdersPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        backgroundColor: Color.fromARGB(255, 103, 58, 183),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserProfilePage()),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  setState(() {
                    _currentIndex = 3;
                  });
                },
              ),
              if (cart.totalItems > 0)
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
                      cart.totalItems.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 236, 226, 248),
              Color.fromARGB(255, 198, 172, 229),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Color.fromARGB(255, 255, 255, 255),
        unselectedItemColor: Color.fromARGB(255, 205, 176, 255),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color.fromARGB(255, 103, 58, 183),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline), label: 'About Us'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Your Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'My Orders'),
        ],
      ),
    );
  }
}

// 🛒 Dummy My Orders Page
class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // TODO: Fetch user orders from backend.
          final pastOrders = <String>[
            // Replace with real fetched orders
          ];
          // Example: Show a dialog or print orders
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('My Orders'),
              content: Text(pastOrders.isEmpty
                  ? 'No orders found.'
                  : pastOrders.join('\n')),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
        child: const Text('My Orders'),
      ),
    );
  }
}

// 👤 User Section Styled Like Product Page
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final username = Provider.of<UserProvider>(context).username ?? 'User';
    final cart = Provider.of<CartProvider>(context);

    return ListView(
      children: [
        // ✅ User Info (Simple, No Gradient, No Icons)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.asset(
                  'assets/images/user.jpg',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Welcome,",
                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),


        // 🟣 Purple Info Box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 226, 212, 255),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 90, 24, 204).withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/image.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Text(
                      "At Swiftoo, we believe that life's essentials shouldn't be hard to access they should arrive at your doorstep in just minutes.",
                      style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 77, 34, 151)),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),

        // 📄 Company Info
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            "Welcome to Swiftoo – Delivering Pure Hydration, Instantly Swiftoo is your trusted companion for quick, safe, and affordable access to drinking water. Whether you’re at home, at work, or running a business, we ensure your hydration needs are met with just a few taps. From cost-effective RO refills to premium branded 20-litre water cans, Swiftoo brings high-quality drinking water straight to your doorstep in just minutes.\nDesigned to serve every segment of society, our platform combines technology, eco-friendly practices, and reliable service to make clean water accessible to all. Every order is handled with care, ensuring hygiene, safety, and customer satisfaction at every step.\nWith Swiftoo, you no longer have to lift heavy cans or worry about water quality. Just download the app, place your order, and enjoy hassle-free hydration—anytime, anywhere.",
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
