// screens/cart_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:water_delivery_app/models/user.dart';
import '../models/water_item.dart';
import '../models/water_order.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/user_provider.dart';

// 💧 Define water blue — ONLY addition to your code
const Color kWaterBlue = Color(0xFF2196F3);
const Color kWaterBlueLight = Color(0xFFBBDEFB);
const Color kWaterBlueDark = Color(0xFF0D47A1);
const Color kWaterBlueAccent = Color(0xFF64B5F6);

class CartScreen extends StatefulWidget {
  final CartProvider cartProvider;
  const CartScreen({Key? key, required this.cartProvider}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FEFF),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: widget.cartProvider.items.isEmpty
                  ? _buildEmptyCart()
                  : _buildCartContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    // ✅ Get the first product’s image if cart is not empty
    String? imageUrl;
    if (widget.cartProvider.items.isNotEmpty) {
      final firstItem = widget.cartProvider.items.first;

      final rawUrl = firstItem.imageUrl;

      // Ensure it's a full URL
      imageUrl = rawUrl.startsWith('http')
          ? rawUrl
          : "http://localhost:8080/water_api/$rawUrl";
    }

    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                kWaterBlueAccent,
                kWaterBlue,
                Colors.blue.shade400,
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ✅ Show product image if available
              if (imageUrl != null && imageUrl.isNotEmpty)
                Opacity(
                  opacity: 0.25,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.broken_image,
                            color: Colors.white54, size: 40),
                      );
                    },
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                  ),
                ),

              // ✅ Decorative shapes
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              const Positioned(
                top: 20,
                right: 30,
                child: Icon(Icons.shopping_cart, color: Colors.white, size: 28),
              ),
              const Positioned(
                top: 35,
                right: 55,
                child: Icon(Icons.water_drop, color: Colors.white70, size: 16),
              ),
            ],
          ),
        ),
        title: const Text(
          'Cart',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
          },
        ),
      ),
      actions: widget.cartProvider.items.isEmpty
          ? null
          : [
              Container(
                margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.white, size: 20),
                  onPressed: () => _showDialog(
                    'Clear Cart',
                    'Remove all items?',
                    _clearCart,
                  ),
                ),
              ),
            ],
    );
  }

  Widget _buildEmptyCart() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: ScaleTransition(
          scale: _slideAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.shade100,
                      Colors.grey.shade50,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 60,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your cart is empty',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add some fresh water products to get started',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                  (route) => false,
                ),
                icon: const Icon(Icons.water_drop, size: 18),
                label: const Text('Browse Products'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kWaterBlue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildCartHeader(),
        const SizedBox(height: 16),
        _buildCartList(),
        _buildBottomSection(),
      ],
    );
  }

  Widget _buildCartHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kWaterBlueLight, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kWaterBlue.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kWaterBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child:
                const Icon(Icons.shopping_bag, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.cartProvider.items.length} ${widget.cartProvider.items.length == 1 ? 'Item' : 'Items'} in Cart',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Review your order before checkout',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kWaterBlue, // ← was Colors.teal
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'KSh ${widget.cartProvider.totalAmount.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: widget.cartProvider.items.length,
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          child: _buildCartItem(widget.cartProvider.items[index], index),
        );
      },
    );
  }

  Widget _buildCartItem(dynamic item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildItemIcon(item),
            const SizedBox(width: 16),
            Expanded(child: _buildItemDetails(item)),
            _buildItemControls(item, index),
          ],
        ),
      ),
    );
  }

  Widget _buildItemIcon(dynamic item) {
    // get imageUrl from item (adjust if your cart stores product inside CartItem)
    final rawUrl = item.imageUrl;
    final imageUrl = rawUrl.startsWith('http')
        ? rawUrl
        : "http://localhost:8080/water_api/$rawUrl";

    return Hero(
      tag: 'cart_item_${item.id}', // unique tag per product
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade200,
              ),
              child:
                  const Icon(Icons.broken_image, color: Colors.grey, size: 30),
            );
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(strokeWidth: 2),
            );
          },
        ),
      ),
    );
  }

  Widget _buildItemDetails(dynamic item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: kWaterBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            item.category ?? 'Water',
            style: TextStyle(
              color: kWaterBlue,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'KSh ${(item.price * item.quantity).toStringAsFixed(2)}',
          style: TextStyle(
            color: kWaterBlue,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (item.quantity > 1)
          Text(
            'KSh ${item.price.toStringAsFixed(2)} x ${item.quantity}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildItemControls(dynamic item, int index) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showDialog(
            'Remove Item',
            'Remove "${item.name}"?',
            () => _removeItem(item),
          ),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.delete_outline, color: Colors.red, size: 18),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuantityButton(
                Icons.remove,
                item.quantity > 1 ? kWaterBlue : Colors.grey,
                () => item.quantity > 1 ? _updateQuantity(item, -1) : null,
              ),
              Container(
                constraints: const BoxConstraints(minWidth: 32),
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              _buildQuantityButton(
                Icons.add,
                kWaterBlue,
                () => _updateQuantity(item, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityButton(IconData icon, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              _buildOrderSummary(),
              const SizedBox(height: 16),
              _buildCheckoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kWaterBlueLight, Colors.blue.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kWaterBlue.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              Text(
                'KSh ${widget.cartProvider.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Delivery:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              Text(
                'FREE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade600,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'KSh ${widget.cartProvider.totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: kWaterBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _showCheckoutDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ).copyWith(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kWaterBlueAccent, kWaterBlue],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: kWaterBlue.withOpacity(0.3),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            child: const Text(
              'Check out',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateQuantity(dynamic item, int change) {
    setState(() => item.quantity += change);
  }

  void _removeItem(dynamic item) {
    setState(() => widget.cartProvider.items.remove(item));
    _showSnackBar('${item.name} removed from cart', Colors.red);
  }

  void _clearCart() {
    setState(() => widget.cartProvider.items.clear());
    _showSnackBar('All items cleared from cart', Colors.red);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCheckoutDialog() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your cart is empty")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Choose Payment Method',
          style: TextStyle(fontWeight: FontWeight.bold, color: kWaterBlue),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPaymentOption(
                icon: Icons.mobile_friendly,
                title: 'Pay with M-Pesa',
                subtitle: 'You will get a PIN prompt',
                color: Colors.green,
                onTap: () {
                  Navigator.pop(ctx);
                  _makeMPesaPayment(user, cartProvider, orderProvider);
                },
              ),
              const Divider(),
              _buildPaymentOption(
                icon: Icons.money,
                title: 'Cash on Delivery',
                subtitle: 'Pay when delivered',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(ctx);
                  _placeOrder(
                      user, cartProvider, orderProvider, 'cash_on_delivery');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  // ✅ NEW: Clean, minimal M-Pesa function
  Future<void> _makeMPesaPayment(
      User user, CartProvider cartProvider, OrderProvider orderProvider) async {
    // Clean phone number to 2547XXXXXXXX format
    String cleanPhone(String phone) {
      String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.startsWith('254') && digits.length == 12) return digits;
      if (digits.startsWith('0') && digits.length == 10)
        return '254' + digits.substring(1);
      if (digits.startsWith('7') && digits.length == 9) return '254' + digits;
      return digits;
    }

    final phone = cleanPhone(user.phone);
    final amount = cartProvider.totalAmount.toInt();
    final orderId = 'WATER-${DateTime.now().millisecondsSinceEpoch}';

    // Validate
    if (amount <= 0 || !RegExp(r'^2547[0-9]{8}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Please enter a valid Safaricom number (e.g. 0712345678)")),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Sending payment request..."),
            ],
          ),
        ),
      ),
    );

    try {
      // 🔁 UPDATE THIS URL TO MATCH YOUR NGROK + PORT
      final url =
          Uri.parse('http://localhost:8080/water_api/mpesa/stkpush.php');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'amount': amount,
          'orderId': orderId,
        }),
      );

      final data = jsonDecode(response.body);
      Navigator.pop(context); // Close loading

      if (data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
        // Optional: Auto-place order after 6 seconds (or wait for callback)
        Future.delayed(const Duration(seconds: 6), () {
          _placeOrder(user, cartProvider, orderProvider, 'mpesa',
              orderId: orderId);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${data['error']}')),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: $e')),
      );
    }
  }

  Future<void> _placeOrder(
    User user,
    CartProvider cartProvider,
    OrderProvider orderProvider,
    String paymentMethod, {
    String? orderId,
  }) async {
    final ip = 'localhost';

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/water_api/createOrder.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_name': user.name,
          'user_email': user.email,
          'user_phone': user.phone,
          'address': user.address,
          'total_amount': cartProvider.totalAmount,
          'payment_method': paymentMethod,
          'order_id':
              orderId ?? 'manual_${DateTime.now().millisecondsSinceEpoch}',
          'items': cartProvider.items
              .map((item) => {
                    'product_id': item.id,
                    'quantity': item.quantity,
                    'price': item.price,
                  })
              .toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final newOrder = WaterOrder(
            id: data['order_id'].toString(),
            status: 'confirmed',
            items: cartProvider.items
                .map((item) => '${item.name} x${item.quantity}')
                .join(', '),
            orderDate: DateTime.now().toLocal().toString().split(' ')[0],
            estimatedDelivery: '2:30 PM',
          );

          orderProvider.addOrder(newOrder);
          cartProvider.clearCart();

          Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Order #${data['order_id']} placed successfully!'),
                backgroundColor: kWaterBlue, // ← was Colors.teal
              ),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Order failed: ${data['error']}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("HTTP Error: ${response.statusCode}")),
        );
      }
    } on Exception catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}
