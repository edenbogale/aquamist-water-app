import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/water_item.dart';
import '../providers/cart_provider.dart';

// 💧 Define water blue
const Color kWaterBlue = Color(0xFF2196F3);

class WaterDetailScreen extends StatefulWidget {
  final WaterItem waterItem;

  const WaterDetailScreen({Key? key, required this.waterItem})
      : super(key: key);

  @override
  _WaterDetailScreenState createState() => _WaterDetailScreenState();
}

class _WaterDetailScreenState extends State<WaterDetailScreen> {
  int _quantity = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          _buildContent(),
          _buildAppBar(),
          if (_quantity > 0) _buildBottomAddToCart(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroImage(),
          SizedBox(height: 24),
          _buildProductInfo(),
          SizedBox(height: 20),
          _buildIntroduceSection(),
          SizedBox(height: 120), // Increased to accommodate larger UI
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back, color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 360, // Increased from 300
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getCategoryGradient(widget.waterItem.category),
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 180, // Increased from 120
          height: 180, // Increased from 120
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 2,
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: Image.network(
            widget.waterItem.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.broken_image,
                size: 80,
                color: Colors.white,
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.waterItem.name,
            style: TextStyle(
              fontSize: 28, // Increased from 24
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Icon(
                _getCategoryIcon(widget.waterItem.category),
                color: kWaterBlue,
                size: 18,
              ),
              SizedBox(width: 6),
              Text(
                widget.waterItem.category,
                style: TextStyle(
                  fontSize: 14,
                  color: kWaterBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntroduceSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
          Text(
            widget.waterItem.description ?? 'No description available.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _quantity > 0
                          ? () => setState(() => _quantity--)
                          : null,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _quantity > 0 ? kWaterBlue : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.remove,
                          color:
                              _quantity > 0 ? Colors.white : Colors.grey[600],
                          size: 20,
                        ),
                      ),
                    ),
                    Container(
                      width: 50,
                      child: Text(
                        '$_quantity',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _quantity++),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: kWaterBlue,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Text(
                'KSh ${widget.waterItem.price.toInt()}',
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

  Widget _buildBottomAddToCart() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _addToCart(),
              style: ElevatedButton.styleFrom(
                backgroundColor: kWaterBlue,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'KSh ${(_quantity * widget.waterItem.price).toStringAsFixed(2)} Add to cart',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addToCart() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    for (int i = 0; i < _quantity; i++) {
      cartProvider.addItem(widget.waterItem);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $_quantity ${widget.waterItem.name} to cart'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    Navigator.pop(context);
  }

  List<Color> _getCategoryGradient(String category) {
    switch (category) {
      case "Still":
        return [Colors.blue[300]!, Colors.blue[100]!];
      case "Sparkling":
        return [Colors.cyan[300]!, Colors.cyan[100]!];
      case "Mineral":
        return [Colors.green[300]!, Colors.green[100]!];
      case "Juices":
        return [Colors.orange[300]!, Colors.orange[100]!];
      case "Flavored":
        return [Colors.purple[300]!, Colors.purple[100]!];
      default:
        return [kWaterBlue.withOpacity(0.3), kWaterBlue.withOpacity(0.1)];
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Still":
        return Icons.water_drop;
      case "Sparkling":
        return Icons.bubble_chart;
      case "Mineral":
        return Icons.terrain;
      case "Juices":
        return Icons.local_bar;
      case "Flavored":
        return Icons.local_drink;
      default:
        return Icons.water_drop;
    }
  }
}
