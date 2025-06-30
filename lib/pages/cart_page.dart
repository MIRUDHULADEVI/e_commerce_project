import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/cart_provider.dart';
import 'customer_details_page.dart';
import '../services/razorpay_payment_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}
class _CartPageState extends State<CartPage> {
  @override
  //void initState() {
    //super.initState();
    //_checkFirstTimeUser();
  //}
  //Future<bool> isFirstTimeUser() async {
    //final prefs = await SharedPreferences.getInstance();
    //return prefs.getBool('hasPaidDeposit') ?? false;
  //}
  //Future<void> setDepositPaid() async {
    //final prefs = await SharedPreferences.getInstance();
    //await prefs.setBool('hasPaidDeposit', true);
  //}
  //void _checkFirstTimeUser() async {
    //final isPaid = await isFirstTimeUser();
    //if (!isPaid) {
      //_showDepositPopup();
    //}
  //}
  //void _showDepositPopup() {
    //showDialog(
      //context: context,
      //barrierDismissible: false,
      //builder: (_) => AlertDialog(
        //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        //backgroundColor: Colors.deepPurple.shade50,
        //title: const Text(
          //"Security Deposit Required",
          //style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
        //),
        //content: const Text(
          //"As a first-time user, a Non-refundable deposit of ₹150 is required to continue shopping.",
          //style: TextStyle(color: Colors.black87),
        //),
        //actions: [
          //TextButton(
            //onPressed: () => Navigator.pop(context),
            //child: const Text("Cancel", style: TextStyle(color: Colors.deepPurple)),
          //),
          //ElevatedButton(
            //onPressed: () {
              //Navigator.pop(context);
              //_proceedToDepositPayment();
            //},
            //style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            //child: const Text("Pay ₹99",style: TextStyle(color: Color.fromARGB(221, 255, 255, 255)),)
          //),
        //],
      //),
    //);
  //}
  //void _proceedToDepositPayment() {
    //Navigator.push(
      //context,
      //MaterialPageRoute(
        //builder: (_) => RazorpayPaymentPage(
          //amount: 99,
          //onSuccess: () async {
            //await setDepositPaid();
            //ScaffoldMessenger.of(context).showSnackBar(
              //const SnackBar(content: Text("Deposit paid successfully!"))
            //);
          //},
        //),
      //),
    //);
  //}
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      body: cart.cartItems.isEmpty
          ? const Center(
              child: Text(
                '🛒 Your cart is empty!',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : ListView.builder(
              itemCount: cart.cartItems.length,
              itemBuilder: (context, index) {
                final item = cart.cartItems[index];
                final quantity = item['quantity'] as int;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 10,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Builder(
                        builder: (context) {
                          final img = item['image'] ?? '';
                          if (img.startsWith('http')) {
                            return Image.network(img, width: 70, height: 70, fit: BoxFit.cover,
                                errorBuilder: (_,__,___)=>const Icon(Icons.broken_image));
                          } else {
                            return Image.asset(
                              item['image']?.isNotEmpty == true
                                ? 'assets/images/${item['image']}'
                                : 'assets/images/image.png',
                              width: 70, height: 100, fit: BoxFit.fitHeight,
                            );
                          }
                        },
                      ),
                    ),
                    title: Text(
                      item['name']?.toString() ?? 'Product',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "₹${(item['price'] * item['quantity']).toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          "Including Delivery Charges",
                          style: const TextStyle(color: Color.fromARGB(255, 85, 85, 86), fontSize: 13),
                        ),
                        const SizedBox(height: 0),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => cart.decreaseQuantity(index),
                              icon: const Icon(Icons.remove_circle_outline),
                              iconSize: 20,
                            ),
                            Text(
                              quantity.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.deepPurple),
                            ),
                            IconButton(
                              onPressed: () => cart.increaseQuantity(index),
                              icon: const Icon(Icons.add_circle_outline),
                              iconSize: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => cart.removeFromCart(item['id']),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.cartItems.isNotEmpty
    ? Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Colors.black12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Total Price Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "₹${cart.totalPrice.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Checkout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CustomerDetailsPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      )
    : null,
    );
  }
}
