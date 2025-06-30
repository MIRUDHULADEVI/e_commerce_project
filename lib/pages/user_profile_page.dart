import 'package:e_commerce_project/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  void _saveAddress(UserProvider userProvider) {
  userProvider.setAddress(
    line1: _address1Controller.text,
    line2: _address2Controller.text,
    district: _districtController.text,
    state: _stateController.text,
    pincode: _pincodeController.text,
  );

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Address saved successfully!")),
  );
}


  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password updated (mock).")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final username = userProvider.username ?? "User";

    return Scaffold(
      appBar: AppBar(
        title: const Text("User Profile"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.person, size: 30, color: Colors.white),
              ),
              const SizedBox(width: 16),
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
                        color: Colors.deepPurple),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 🔐 Password Section
          const Text("Change Password", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "New Password",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _changePassword,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text("Update Password",
                style: TextStyle(color: Colors.white)),
          ),

          const Divider(height: 40),

          // 🏡 Address Section
          const Text("Address Details", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildAddressField(_address1Controller, "Address Lane 1"),
          _buildAddressField(_address2Controller, "Address Lane 2"),
          _buildAddressField(_districtController, "District"),
          _buildAddressField(_stateController, "State"),
          
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => _saveAddress(userProvider),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text("Save Address", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressField(TextEditingController controller, String label,
      {TextInputType inputType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        maxLength: label.startsWith("Address Lane") ? 30 : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          counterText: label.startsWith("Address Lane") ? null : "", // hide counter for other fields
        ),
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _districtController.dispose();
    _stateController.dispose();
   
    super.dispose();
  }
}
