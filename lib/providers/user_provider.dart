import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _username;
  String? _password;
  String? _token;
  String? _userId;

  // Contact and address fields
  String? _email;
  String? _phone;
  String? _addressLine1;
  String? _addressLine2;
  String? _district;
  String? _state;
  String? _pincode;

  // Getters
  String? get username => _username;
  String? get password => _password;
  String? get email => _email;
  String? get phone => _phone;
  String? get addressLine1 => _addressLine1;
  String? get addressLine2 => _addressLine2;
  String? get district => _district;
  String? get state => _state;
  String? get pincode => _pincode;
  String? get token => _token;
  String? get userId => _userId;

  // Setters
  void setUsername(String username) {
    _username = username;
    notifyListeners(); // 🔔 this triggers UI rebuilds
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setPhone(String phone) {
    _phone = phone;
    notifyListeners();
  }
  // Add a method to set the token if needed
  void setToken(String? token) {
    _token = token;
    notifyListeners();
  }

  void setUserId(String? userId) {
    _userId = userId;
    notifyListeners();
  }

  void setAddress({
    required String line1,
    required String line2,
    required String district,
    required String state,
    required String pincode,
  }) {
    _addressLine1 = line1;
    _addressLine2 = line2;
    _district = district;
    _state = state;
    _pincode = pincode;
    notifyListeners();
  }
}

  

  