import 'package:e_commerce_project/pages/main_home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../providers/cart_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;

  void _toggleFormType() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        final result = await AuthService.login(username: username, password: password);
        if (result['token'] != null) {
          Provider.of<UserProvider>(context, listen: false).setUsername(username);
          final items = result['cart'] as List<dynamic>? ?? [];
          Provider.of<CartProvider>(context, listen: false)
            .setItemsFromJson(items);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainHomePage()),
          );
        } else {
          _showError(result['message'] ?? 'Login failed.');
        }
      }

      else {
        if (password != confirmPassword) {
          _showError("Password and Confirm Password do not match.");
          return;
        }

        final result = await AuthService.signup(
          username: username,
          password: password,
          email: email,
          phone: phone,
        );

        if (result['userId'] != null) {
          _showSuccess("Signed up successfully! Please login.");
          _toggleFormType();
        } else {
          _showError(result['message'] ?? "Signup failed.");
        }
      }
    } catch (e) {
      _showError("Something went wrong: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK")),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK")),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 198, 172, 229),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/login.png', height: 200),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(_usernameController, 'Username',
                            hintText:
                                '4–20 chars: lowercase, uppercase, no spaces',
                            validator: (value) {
                          final usernameRegex =
                              RegExp(r'^[a-zA-Z]{4,20}$');
                          if (value == null || value.isEmpty) {
                            return 'Username is required';
                          }
                          if (!usernameRegex.hasMatch(value)) {
                            return 'Invalid username format';
                          }
                          return null;
                        }),
                        const SizedBox(height: 16),
                        if (!_isLogin)
                          Column(
                            children: [
                              _buildTextField(_emailController, 'Email',
                                  validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                }
                                if (!value.contains('@')) {
                                  return 'Invalid email format';
                                }
                                return null;
                              }),
                              const SizedBox(height: 16),
                              _buildTextField(_phoneController, 'Phone',
                                  type: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Phone is required';
                                    }
                                    if (!RegExp(r'^\d{10}$')
                                        .hasMatch(value)) {
                                      return 'Phone must be 10 digits';
                                    }
                                    return null;
                                  }),
                              const SizedBox(height: 16),
                            ],
                          ),
                        _buildTextField(_passwordController, 'Password',
                            obscure: true,
                            hintText:
                                'Min 8 chars: uppercase, lowercase, digit, special char',
                            validator: (value) {
                          final passwordRegex = RegExp(
                              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (!passwordRegex.hasMatch(value)) {
                            return 'Weak password';
                          }
                          return null;
                        }),
                        const SizedBox(height: 16),
                        if (!_isLogin)
                          _buildTextField(_confirmPasswordController,
                              'Confirm Password',
                              obscure: true, validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          }),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 80, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  _isLogin ? 'Login' : 'Sign Up',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white),
                                ),
                        ),
                        TextButton(
                          onPressed: _toggleFormType,
                          child: Text(_isLogin
                              ? "New user? Sign Up"
                              : "Already have an account? Login"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
    String? hintText,
  }) {
    final focusNode = FocusNode();

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Focus(
              focusNode: focusNode,
              onFocusChange: (_) => setState(() {}),
              child: TextFormField(
                controller: controller,
                obscureText: obscure,
                keyboardType: type,
                validator: validator,
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (focusNode.hasFocus && hintText != null)
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  hintText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}