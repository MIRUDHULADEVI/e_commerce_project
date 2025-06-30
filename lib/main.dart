import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/user_provider.dart';

import 'pages/login_page.dart';
import 'pages/cart_page.dart';
import 'pages/home_page.dart';
import 'pages/product_detail.dart';
import 'pages/product_page.dart';
import 'models/product.dart';
import 'pages/splash_screen.dart'; // Splash screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Your App',
        theme: ThemeData(primarySwatch: Colors.deepPurple),
        home: const SplashScreen(), // First screen shown

        // Define named routes
        routes: {
          '/cart': (context) => const CartPage(),
          '/home': (context) => const HomePage(),
          '/products': (context) => const ProductPage(),
          '/login': (context) => const LoginPage(),
        },

        // Handle dynamic routes
        onGenerateRoute: (settings) {
          if (settings.name == '/product_detail') {
            final product = settings.arguments as Product;
            return MaterialPageRoute(
              builder: (context) => ProductDetailPage(product: product),
            );
          }
          return null;
        },
      ),
    );
  }
}
