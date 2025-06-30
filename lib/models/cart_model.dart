import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  Map<String, dynamic> toJson() {
    return {
      'productId': product.id,
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['productId']),
      quantity: json['quantity'],
    );
  }
}

class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalPrice =>
      _items.fold(0, (total, item) => total + item.product.price * item.quantity);

  void addItem(Product product, [int quantity = 1]) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex != -1) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void removeItem(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void setItemsFromJson(List<dynamic> jsonList) {
    _items.clear();
    for (var item in jsonList) {
      _items.add(CartItem.fromJson(item));
    }
    notifyListeners();
  }

  List<Map<String, dynamic>> toJsonList() {
    return _items.map((item) => item.toJson()).toList();
  }
}
