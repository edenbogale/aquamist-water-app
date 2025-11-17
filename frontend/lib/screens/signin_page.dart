import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/user_provider.dart';
import '../models/user.dart';

const Color kWaterBlue = Color(0xFF2196F3);

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/water_api/signin.php'),
        body: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );

        final userData = data['user'];
        if (userData != null) {
          final user = User(
            name: userData['name'],
            email: userData['email'],
            phone: userData['phone'],
            address: userData['address'],
          );

          final userProvider =
              Provider.of<UserProvider>(context, listen: false);
          userProvider.setUser(user);
        }

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Please try again.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email first.')),
      );
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/water_api/reset_password.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message']),
          backgroundColor: data['success'] ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send reset request. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Container(
                constraints: BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header Section
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(vertical: 50, horizontal: 30),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            kWaterBlue,
                            Color(0xFF1976D2),
                            Color(0xFF1565C0),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.water_drop_rounded,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                          SizedBox(height: 25),
                          Text(
                            "Welcome Back!",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.95),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            "Fresh water delivered to your door",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.95),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Form Section
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email Field
                            _buildModernInputField(
                              controller: _emailController,
                              hintText: 'Email',
                              icon: Icons.email_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                } else if (!RegExp(
                                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Password Field
                            _buildModernInputField(
                              controller: _passwordController,
                              hintText: 'Password',
                              icon: Icons.lock_outline,
                              obscureText: !_isPasswordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey[400],
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                } else if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 8),

                            Align(
                              alignment: Alignment.center,
                              child: TextButton(
                                onPressed: _forgotPassword,
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),

                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSignIn,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kWaterBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: _isLoading
                                    ? CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text(
                                        'Login',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: 15),
                            Text('or',
                                style: TextStyle(color: Colors.grey[600])),
                            SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/signup');
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: kWaterBlue.withOpacity(0.5),
                                      width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Create an account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: kWaterBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey[300]!, width: 1.5),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(fontSize: 15, color: Colors.grey[800]),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: kWaterBlue),
          suffixIcon: suffixIcon,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }
}
