import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/razorpay_payment_page.dart';
import '../providers/cart_provider.dart';
import '../providers/user_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CustomerDetailsPage extends StatefulWidget {
  const CustomerDetailsPage({super.key});

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _gpsLinkController = TextEditingController();
  final FocusNode _gpsFocusNode = FocusNode();

  TimeOfDay? _dispatchTime;
  DateTime? _dispatchDate;
  String _selectedPaymentMethod = "Online Payment";

  final List<String> _availablePincodes = ["600019", "600057" , "600068", "Pincode not found"];
  String? _selectedPincode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final userProvider = Provider.of<UserProvider>(context);
    _nameController.text = userProvider.username ?? '';
    _emailController.text = userProvider.email ?? '';
    _phoneController.text = userProvider.phone ?? '';
    _address1Controller.text = userProvider.addressLine1 ?? '';
    _address2Controller.text = userProvider.addressLine2 ?? '';
    _districtController.text = userProvider.district ?? '';
    _stateController.text = userProvider.state ?? '';
    _selectedPincode = userProvider.pincode ?? _availablePincodes.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Details"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nameController, "Name"),
              _buildTextField(_emailController, "Email"),
              _buildTextField(_phoneController, "Phone", inputType: TextInputType.phone),
              const SizedBox(height: 10),
              const Text("Address", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              _buildTextField(_address1Controller, "Address Line 1"),
              _buildTextField(_address2Controller, "Address Line 2"),
              _buildTextField(_districtController, "District"),
              _buildTextField(_stateController, "State"),

              const SizedBox(height: 10),
              const Text("Pincode", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              DropdownButtonFormField<String>(
                value: _availablePincodes.contains(_selectedPincode)
                    ? _selectedPincode
                    : null,
                items: _availablePincodes
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedPincode = val;
                  });
                },
                decoration: InputDecoration(border: OutlineInputBorder()),
              ),

              const SizedBox(height: 10),
              Focus(
                focusNode: _gpsFocusNode,
                onFocusChange: (_) => setState(() {}),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _gpsLinkController,
                      decoration: const InputDecoration(
                        labelText: "Paste Google Maps Location Link",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Please enter your location link" : null,
                    ),
                    const SizedBox(height: 4),
                    if (_gpsFocusNode.hasFocus)
                      const Padding(
                        padding: EdgeInsets.only(left: 12.0),
                        child: Text(
                          "Long press on your location in Google Maps > Share > Copy Link \nSample Link : https://maps.app.goo.gl/4XgJyeDzVTERNrrV6?g_st=ac",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              ListTile(
                title: Text(_dispatchDate == null
                    ? "Preferred Dispatch Date"
                    : "Date: ${_dispatchDate!.toLocal().toString().split(' ')[0]}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) setState(() => _dispatchDate = picked);
                },
              ),
              ListTile(
                title: Text(_dispatchTime == null
                    ? "Preferred Dispatch Time"
                    : "Time: ${_dispatchTime!.format(context)}"),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) setState(() => _dispatchTime = picked);
                },
              ),
              const SizedBox(height: 10),
              const Text("Preferred Payment Method", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ListTile(
                title: const Text("Cash on Delivery"),
                leading: Radio<String>(
                  value: "Cash on Delivery",
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() => _selectedPaymentMethod = value!);
                  },
                ),
              ),
              ListTile(
                title: const Text("Online Payment"),
                leading: Radio<String>(
                  value: "Online Payment",
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() => _selectedPaymentMethod = value!);
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate() && _dispatchTime != null && _dispatchDate != null) {
                    if (_selectedPincode == "Pincode not found") {
                      _showPincodeWarning(context);
                      return;
                    }
                    if (_selectedPaymentMethod == "Cash on Delivery") {
                      _showComingSoonPopup(context);
                    } else {
                      _showOrderConfirmationPopup(context);
                    }
                  }
                },
                child: const Text("Proceed"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType inputType = TextInputType.text,
  }) {
    final isAddressLine = label.startsWith("Address Line");
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLength: isAddressLine ? 30 : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          counterText: isAddressLine ? null : "", // hide counter for non-address
        ),
        validator: (val) {
          if (val == null || val.isEmpty) {
            return "Please enter $label";
          }
          if (isAddressLine && val.length > 30) {
            return "$label must be ≤ 30 characters";
          }
          return null;
        },
      ),
    );
  }

  
  void _showPincodeWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.deepPurple.shade50,
        title: const Text("Service Unavailable",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        content: const Text("We currently provide service only for the following pincodes:\n600019,600057,600068",
            style: TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
    );
  }
  RadioListTile<String> _buildRadio(String value) {
    return RadioListTile(
      title: Text(value),
      value: value,
      groupValue: _selectedPaymentMethod,
      onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
    );
  }

  void _showComingSoonPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.deepPurple.shade50,
        title: const Text("Feature Coming Soon",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        content: const Text("Cash on Delivery will be available soon. Please use Online Payment.",
            style: TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
    );
  }
  Future<void> _submitOrderToBackend(BuildContext context, double totalAmount) async {
  final cart = Provider.of<CartProvider>(context, listen: false);
  final user = Provider.of<UserProvider>(context, listen: false);

  final Uri url = Uri.parse("https://ecommerce-backend-xalg.onrender.com/api/orders/create");

  final body = { // Replace 'id' with the correct property name for user ID in your UserProvider
    "cartItems": cart.cartItems.map((item) => {
      "name": item['name'],
      "price": item['price'],
      "quantity": item['quantity'],
      "image": item['image'],
    }).toList(),
    "customerDetails": {
      "name": _nameController.text,
      "email": _emailController.text,
      "phone": _phoneController.text,
      "address": "${_address1Controller.text}, ${_address2Controller.text}, ${_districtController.text}, ${_stateController.text} - ${_selectedPincode ?? ''}",
      "gpsLocation": _gpsLinkController.text,
    },
    "dispatchDate": _dispatchDate!.toIso8601String(),
    "dispatchTime": _dispatchTime!.format(context),
    "paymentMethod": _selectedPaymentMethod,
    "paymentStatus": "Paid", // Assuming payment was successful
    "totalAmount": totalAmount,
  };

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      cart.clearCart(context); // Clear cart after order
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully")),
      );
      Navigator.popUntil(context, (route) => route.isFirst); // Go back to home
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to place order")),
      );
    }
  } catch (e) {
    print("Order Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Something went wrong")),
    );
  }
}
  @override
  void dispose() {
    _gpsFocusNode.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _gpsLinkController.dispose();
    super.dispose();
  }

  void _showOrderConfirmationPopup(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final totalAmount = cart.totalPrice; // ✅ only one declaration

    final productDetails = cart.cartItems.map((item) =>
        "${item['name']} - ${item['quantity']} pcs - ₹${item['price'] * item['quantity']}").join('\n');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),),
        title: const Text("Confirm Your Order", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(productDetails),
            const SizedBox(height: 10),
            const Text("Delivery Charges: Included"),
            const Text("Offers Applied: None"),
            Text("Total Amount: ₹${totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate() && _dispatchTime != null && _dispatchDate != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RazorpayPaymentPage(amount: totalAmount),
                  ),
                );
              }
            },            
            child: const Text('Proceed to Pay',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),),
            style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,)
          ),
        ],
      ),
    );
  }
}