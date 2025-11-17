// lib/screens/cover_screen.dart
import 'package:flutter/material.dart';
import 'signin_page.dart';

// 💧 Minimal water color palette
const Color kWaterBlue = Color(0xFF2196F3);
const Color kWaterBlueDark = Color(0xFF0D47A1);
const Color kWaterBlueLight = Color(0xFF64B5F6);

class CoverScreen extends StatefulWidget {
  @override
  _CoverScreenState createState() => _CoverScreenState();
}

class _CoverScreenState extends State<CoverScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Subtle background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  kWaterBlueLight.withOpacity(0.05),
                ],
              ),
            ),
          ),

          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Simple logo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kWaterBlue.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.water_drop,
                        size: 64,
                        color: kWaterBlue,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Simple title
                    Text(
                      'Aquamist',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: kWaterBlueDark,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Minimal subtitle
                    Text(
                      'Fresh Water Delivery',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Clean features
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFeature(Icons.local_shipping_outlined, 'Fast'),
                          _buildFeature(Icons.verified_outlined, 'Quality'),
                          _buildFeature(Icons.support_agent_outlined, '24/7'),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Simple continue button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    SignInPage(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                  opacity: animation, child: child);
                            },
                            transitionDuration:
                                const Duration(milliseconds: 400),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: kWaterBlue,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: kWaterBlue.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Get Started',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kWaterBlue.withOpacity(0.08),
          ),
          child: Icon(
            icon,
            color: kWaterBlue,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
