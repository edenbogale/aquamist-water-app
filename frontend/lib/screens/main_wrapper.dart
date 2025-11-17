import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'orders_screen.dart';
import 'cart_screen.dart';
import 'profile_page.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

// 💧 Define water blue
const Color kWaterBlue = Color(0xFF2196F3);

class MainWrapper extends StatefulWidget {
  @override
  _MainWrapperState createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    final List<Widget> _screens = [
      HomeScreen(),
      OrdersScreen(),
      CartScreen(cartProvider: cartProvider),
      ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: kWaterBlue,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: _buildCartIconWithBadge(cartProvider),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  /// 🛒 Builds cart icon with animated badge showing item count
  Widget _buildCartIconWithBadge(CartProvider cartProvider) {
    final itemCount = cartProvider.items.length;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.shopping_cart),
        if (itemCount > 0)
          Positioned(
            right: -8,
            top: -8,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        itemCount > 99 ? '99+' : itemCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
