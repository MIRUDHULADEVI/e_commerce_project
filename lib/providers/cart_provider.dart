import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';

class CartProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  // 🔁 Initialize and load local cart when the provider is created
  CartProvider() {
    _loadFromLocal();
  }

  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('cart_items') ?? [];
    _cartItems.clear();
    for (var s in list) {
      final j = jsonDecode(s);
      _cartItems.add({
        'name': j['name'],
        'price': j['price'],
        'image': j['image'],
        'quantity': j['quantity'],
      });
    }
    notifyListeners();
  }

  Future<void> _saveLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _cartItems.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('cart_items', jsonList);
  }

  Future<void> _syncToServer(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;
    if (token == null) return;

    final url = Uri.parse('${AuthService.baseUrl}/cart');
    final body = jsonEncode({'items': _cartItems});
    try {
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );
    } catch (e) {
      debugPrint('Cart sync error: $e');
    }
  }

  void addToCart(String id, String name, double price, int quantity, String imageUrl) {
    final index = _cartItems.indexWhere((item) => item['id'] == id);
    if (index >= 0) {
      _cartItems[index]['quantity'] += quantity;
    } else {
      _cartItems.add({
        'id': id,
        'name': name,
        'price': price,
        'quantity': quantity,
        'image': imageUrl,
      });
    }
    print("🧾 Item added to cart: ${_cartItems.last}"); // 🔍 Add this

    notifyListeners();
    _saveLocally();
  }


  void removeFromCart(String id) {
    _cartItems.removeWhere((item) => item['id'] == id);
    notifyListeners();
    _saveLocally();
    // _syncToServer(); // This requires a BuildContext, so you may want to update this if needed.
  }

  void increaseQuantity(int index, {BuildContext? context}) {
    _cartItems[index]['quantity'] += 1;
    notifyListeners();
    _saveLocally();
    if (context != null) _syncToServer(context);
  }

  void decreaseQuantity(int index, {BuildContext? context}) {
    if (_cartItems[index]['quantity'] > 1) {
      _cartItems[index]['quantity'] -= 1;
    } else {
      _cartItems.removeAt(index);
    }
    notifyListeners();
    _saveLocally();
    if (context != null) _syncToServer(context);
  }

  void clearCart(BuildContext context) {
    _cartItems.clear();
    notifyListeners();
    _saveLocally();
    _syncToServer(context);
  }


  void setItems(List<Map<String, dynamic>> items, {BuildContext? context}) {
    _cartItems
      ..clear()
      ..addAll(items);
    notifyListeners();
    _saveLocally();
    if (context != null) _syncToServer(context);
  }

  void updateQuantity(String id, int newQuantity, {BuildContext? context}) {
    final index = _cartItems.indexWhere((item) => item['id'] == id);
    if (index >= 0) {
      _cartItems[index]['quantity'] = newQuantity;
      notifyListeners();
      _saveLocally();
      if (context != null) _syncToServer(context);
    }
  }

  int get totalItems =>
      _cartItems.fold(0, (sum, item) => sum + (item['quantity'] as int));
  double get totalPrice => _cartItems.fold<double>(0.0, (sum, item) {
        final price = item['price'] as double;
        final qty = item['quantity'] as int;
        return sum + price * qty;
      });

  // ✅ Convert full cart to JSON for backend sync
  List<Map<String, dynamic>> toJsonList() {
    return _cartItems.map((item) => {
      'productId': item['id'],
      'quantity': item['quantity'],
    }).toList();
  }

  // ✅ Load cart from backend after login
  // in CartProvider.setItemsFromJson()
  void setItemsFromJson(List<dynamic> jsonList) {
    _cartItems.clear();
    _cartItems.addAll(jsonList.map((item) {
      return {
        'id': item['productId'],        // just the ID
        'quantity': item['quantity'],   // the quantity
      };
    }).toList());
    notifyListeners();
    _saveCartToPrefs();
  }


  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('cart_items') ?? [];
    _cartItems.clear();
    for (var s in list) {
      final j = jsonDecode(s);
      print("📦 Restored from prefs: $j"); // 🔍 Add this
      _cartItems.add({
        'id': j['id'],
        'name': j['name'],
        'price': j['price'],
        'image': j['image'],
        'quantity': j['quantity'],
      });
    }
    notifyListeners();
  }

  Future<void> loadCartFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cartString = prefs.getString('cart');
    if (cartString != null) {
      _cartItems.clear();
      _cartItems.addAll(List<Map<String, dynamic>>.from(json.decode(cartString)));
      notifyListeners();
    }
  }

  Future<void> _saveCartToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cart', json.encode(_cartItems));
  }

  Future<void> _syncToServerWithPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    final url = Uri.parse('https://ecommerce-backend-xalg.onrender.com/api/cart/save');

    final body = jsonEncode({
      'items': toJsonList()
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint('⚠️ Failed to sync cart: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('⚠️ Error syncing cart: $e');
    }
  }
}
