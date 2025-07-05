import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/cart_provider.dart';

class RazorpayPaymentPage extends StatefulWidget {
  final Map<String, String>? customerData;
  final double amount;
  final VoidCallback? onSuccess;

  const RazorpayPaymentPage({
    Key? key,
    this.customerData,
    required this.amount,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<RazorpayPaymentPage> createState() => _RazorpayPaymentPageState();
}

class _RazorpayPaymentPageState extends State<RazorpayPaymentPage> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _startPayment() {
    final amountInPaise = (widget.amount * 100).toInt();

    var options = {
      'key': 'rzp_test_R7gEnK2atbAJYT',
      'amount': amountInPaise,
      'name': widget.customerData?["name"] ?? "User",
      'description': 'Product Purchase',
      'prefill': {
        'contact': widget.customerData?["phone"] ?? "",
        'email': widget.customerData?["email"] ?? "",
      },
      'theme': {
        'color': '#673AB7',
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _handleSuccess(PaymentSuccessResponse response) async {
    final cart = Provider.of<CartProvider>(context, listen: false);

    print(response.paymentId);

    // 🔐 Get userId and token (from SharedPreferences or UserProvider)
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final token = prefs.getString('token');

    if (userId != null && token != null) {
      await saveOrderToBackend(
          cart.cartItems, userId, token, response.paymentId!);
    }

    cart.clearCart(context);

    if (widget.onSuccess != null) {
      widget.onSuccess!();
    }

    // ✅ Show success dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.deepPurple.shade50,
        title: const Text(
          "Payment Success",
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 60, color: Colors.green),
            const SizedBox(height: 10),
            Text("Payment ID: ${response.paymentId}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text("OK", style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
    );
  }

  Future<void> saveOrderToBackend(
      List cartItems, String userId, String token, String paymentId) async {
    final url = Uri.parse('http://192.168.40.207:5000/api/orders/create');

    final body = jsonEncode({
      'userId': userId,
      'cartItems': cartItems
          .map((item) => {
                'productId': item['id'],
                'name': item['name'],
                'price': item['price'],
                'quantity': item['quantity'],
                'image': item['image'] ?? item['imageUrl'], // ensure image key
              })
          .toList(),
      'totalAmount': (widget.amount * 100).toInt(),
      'paymentId': paymentId,
    });
    print(body);

    try {
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      if (res.statusCode != 200 && res.statusCode != 201) {
        debugPrint('❌ Failed to save order: ${res.statusCode} ${res.body}');
      }
    } catch (e) {
      debugPrint('❌ Error saving order: $e');
    }
  }

  void _handleError(PaymentFailureResponse response) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.deepPurple.shade50,
        title: const Text("Payment Failed",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.redAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cancel, size: 60, color: Colors.redAccent),
            const SizedBox(height: 10),
            Text("Reason: ${response.message}",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Online Payment"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "You're paying",
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            Text(
              "₹${widget.amount.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.payment),
              onPressed: _startPayment,
              label: const Text("Pay Now"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
