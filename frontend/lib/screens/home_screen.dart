import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/water_item.dart';
import '../services/api_service.dart';
import '../providers/cart_provider.dart';
import 'water_detail_screen.dart';

// 💧 Define water blue theme colors
const Color kWaterBlue = Color(0xFF2196F3); // Primary water blue
const Color kWaterBlueLight = Color(0xFFBBDEFB); // Light blue
const Color kWaterBlueDark = Color(0xFF0D47A1); // Deep blue
const Color kWaterBlueAccent = Color(0xFF64B5F6); // Mid blue

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedCategoryIndex = 0;
  late Future<Map<String, List<WaterItem>>> _categoriesFuture;
  final ApiService _apiService = ApiService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _apiService.fetchProductsGroupedByCategory();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
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
      backgroundColor: const Color(0xFFF0F8FF),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _categoriesFuture = _apiService.fetchProductsGroupedByCategory();
          });
          await _categoriesFuture;
        },
        color: kWaterBlue,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: FutureBuilder<Map<String, List<WaterItem>>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingState();
                    } else if (snapshot.hasError) {
                      return _buildErrorState(snapshot);
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyState();
                    }

                    final categoryKeys = snapshot.data!.keys.toList();
                    final currentItems =
                        snapshot.data![categoryKeys[_selectedCategoryIndex]] ??
                            [];

                    return _buildHomeContent(categoryKeys, currentItems);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kWaterBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kWaterBlue),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading fresh products...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(AsyncSnapshot snapshot) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load products',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kWaterBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.water_drop_outlined,
                  color: kWaterBlue, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'No products available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for fresh deliveries',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent(
      List<String> categoryKeys, List<WaterItem> currentItems) {
    return Column(
      children: [
        _buildTopHeader(),
        const SizedBox(height: 20),
        _buildPromoCard(),
        const SizedBox(height: 20),
        _buildSearchBar(categoryKeys),
        const SizedBox(height: 25),
        _buildCategoryTabs(categoryKeys),
        const SizedBox(height: 30),
        _buildSectionHeader('Available', categoryKeys[_selectedCategoryIndex]),
        const SizedBox(height: 16),
        _buildItemList(currentItems),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildTopHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: kWaterBlue.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: kWaterBlue.withOpacity(0.2), width: 2),
            ),
            child: Icon(Icons.person, color: kWaterBlue, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back!',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Explore Products',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kWaterBlue, kWaterBlueDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kWaterBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.local_offer, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Special Offer!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Get 20% off on first order',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Use Now',
              style: TextStyle(
                color: kWaterBlue,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(List<String> categoryKeys) {
    return GestureDetector(
      onTap: () async {
        try {
          final products = await _categoriesFuture;
          final allItems = products.values.expand((list) => list).toList();
          showSearch(
            context: context,
            delegate: WaterSearchDelegate(allItems),
          );
        } catch (e) {
          showSearch(
            context: context,
            delegate: WaterSearchDelegate(const []),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[400], size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'What products you want?',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 15,
                ),
              ),
            ),
            Icon(Icons.tune, color: Colors.grey[400], size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(List<String> categories) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = index),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [kWaterBlueAccent, kWaterBlue],
                        )
                      : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : kWaterBlue.withOpacity(0.3),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: kWaterBlue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Center(
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : kWaterBlue,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: kWaterBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(List<WaterItem> items) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutBack,
          child: _buildWaterItem(items[index]),
        );
      },
    );
  }

  Widget _buildWaterItem(WaterItem item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WaterDetailScreen(waterItem: item),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: 'water_${item.name}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                kWaterBlueLight,
                                kWaterBlueAccent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(kWaterBlue),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                kWaterBlueLight,
                                kWaterBlueAccent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: kWaterBlue,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: kWaterBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getSizeFromName(item.name),
                        style: TextStyle(
                          color: kWaterBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kWaterBlueAccent, kWaterBlue],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: kWaterBlue.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'KSh ${item.price.toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSizeFromName(String name) {
    if (name.contains('500ml')) return '500 ml';
    if (name.contains('1L')) return '1 L';
    if (name.contains('1.5L')) return '1.5 L';
    if (name.contains('5L')) return '5 L';
    if (name.contains('18.9L')) return '18.9 L';
    if (name.contains('300ml')) return '300 ml';
    return 'Premium';
  }
}

/// Enhanced Search delegate with improved UI
class WaterSearchDelegate extends SearchDelegate<WaterItem?> {
  final List<WaterItem> allItems;

  WaterSearchDelegate(this.allItems);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: kWaterBlue),
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
      ),
    );
  }

  @override
  String get searchFieldLabel => 'Search water products...';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: Icon(Icons.clear, color: kWaterBlue),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back, color: kWaterBlue),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final q = query.toLowerCase();
    final results = allItems
        .where((item) =>
            item.name.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q))
        .toList();
    return _buildResultList(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final q = query.toLowerCase();
    final suggestions = q.isEmpty
        ? allItems.take(6).toList()
        : allItems
            .where((item) =>
                item.name.toLowerCase().contains(q) ||
                item.description.toLowerCase().contains(q))
            .toList();
    return _buildResultList(context, suggestions);
  }

  Widget _buildResultList(BuildContext context, List<WaterItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                size: 40,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "No matching items found",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 50,
                height: 50,
                child: Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kWaterBlueLight, kWaterBlueAccent],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.image_not_supported,
                        color: kWaterBlue,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
            title: Text(
              item.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            subtitle: Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: kWaterBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "KSh ${item.price.toInt()}",
                style: TextStyle(
                  color: kWaterBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: kWaterBlue,
            ),
            onTap: () {
              close(context, item);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WaterDetailScreen(waterItem: item),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
