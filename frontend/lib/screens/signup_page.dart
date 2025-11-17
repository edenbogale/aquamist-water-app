import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/user.dart';
import '../providers/user_provider.dart';

const Color kWaterBlue = Color(0xFF2196F3);

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
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
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.water_drop_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            "Welcome!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w400,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Create Your Account",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Start your journey with us today",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.95),
                                fontWeight: FontWeight.w400,
                              ),
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
                            // Name Field
                            _buildModernInputField(
                              controller: _nameController,
                              hintText: 'Full Name',
                              icon: Icons.person_outline,
                              keyboardType: TextInputType.name,
                            ),
                            SizedBox(height: 16),

                            // Phone Field
                            _buildModernInputField(
                              controller: _phoneController,
                              hintText: 'Phone',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                            SizedBox(height: 16),

                            // Email Field
                            _buildModernInputField(
                              controller: _emailController,
                              hintText: 'Email Address',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
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
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 16),

                            // Confirm Password Field
                            _buildModernInputField(
                              controller: _confirmPasswordController,
                              hintText: 'Confirm Password',
                              icon: Icons.lock_outline,
                              obscureText: !_isConfirmPasswordVisible,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 30),

                            // Sign Up Button
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _handleSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kWaterBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // Sign In Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Have an account? ',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacementNamed(
                                        context, '/signin');
                                  },
                                  child: Text(
                                    'Sign in',
                                    style: TextStyle(
                                      color: kWaterBlue,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
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
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $hintText';
          }
          final val = value.trim();

          if (hintText == 'Full Name') {
            if (val.length < 2) return 'Name must be at least 2 characters';
            if (!hasNoNumbers(val)) return 'Name should not contain numbers';
          } else if (hintText == 'Phone') {
            if (!isValidPhone(val)) return 'Enter a valid phone (10-15 digits)';
          } else if (hintText == 'Email Address') {
            if (!isValidEmail(val)) return 'Enter a valid email';
          } else if (hintText == 'Password') {
            if (!isValidPassword(val)) {
              return 'Password must be 8+ chars and include upper, lower, number & special';
            }
          } else if (hintText == 'Confirm Password') {
            if (val != _passwordController.text) {
              return 'Passwords do not match';
            }
          }

          return null;
        },
        style: TextStyle(fontSize: 15, color: Colors.grey[800]),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: kWaterBlue, size: 22),
          suffixIcon: suffixIcon,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }

  void _handleSignUp() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || name.length < 2 || !hasNoNumbers(name)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Name cannot be empty, less than two characters or contain numbers")));
      return;
    }

    if (!isValidPhone(phone)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Invalid phone number")));
      return;
    }

    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Invalid email")));
      return;
    }

    if (!isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Password must be at least 8 chars and include upper, lower, number & special")));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Passwords do not match")));
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/water_api/signup.php'),
        body: {
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
        },
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        final user = User(
          name: name,
          phone: phone,
          email: email,
          address: '',
        );

        Provider.of<UserProvider>(context, listen: false).setUser(user);

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Success')));

        Navigator.pushReplacementNamed(context, '/signin');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Signup failed')));
      }
    } catch (e) {
      print('Signup error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error. Please try again.')),
      );
    }
  }

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool hasNoNumbers(String input) {
    final RegExp noNumbers = RegExp(r'^[^0-9]+$');
    return noNumbers.hasMatch(input);
  }

  bool isValidPhone(String phone) {
    final RegExp phoneRegex = RegExp(r'^[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone);
  }

  bool isValidPassword(String password) {
    final RegExp passwordRegex =
        RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$');
    return passwordRegex.hasMatch(password);
  }
}
