import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'checkout_screen.dart';
import 'purchase_history_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _selectedMealFilter = 'Salads';
  String _selectedCategoryFilter = 'Fruits';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          _buildSearchScreen(),
          _buildHomeContent(), // Placeholder for scan action
          _buildHistoryScreen(),
          _buildProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildTopBar(),
            _buildSearchBar(),
            _buildPromotionalBanner(),
            _buildCategoryButtons(),
            _buildMealFilters(),
            _buildRecommendedSection(),
          ],
        ),
      ),
    );
  }

  // ==========================
  // TOP BAR
  // ==========================
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          // Profile Picture
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: Icon(Icons.person, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 12),
          // Greeting and Address
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, Ahaz!',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                Text(
                      '123 2/A Cinnamon St, LA',
                      style: GoogleFonts.instrumentSans(
                    fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                  ),
                  ],
                ),
              ],
            ),
          ),
          // Icons
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckoutScreen()),
              );
            },
            child: Icon(Icons.shopping_cart_outlined, color: Colors.grey.shade700, size: 24),
          ),
          const SizedBox(width: 16),
          Icon(Icons.notifications_outlined, color: Colors.grey.shade700, size: 24),
        ],
      ),
    );
  }

  // ==========================
  // SEARCH BAR
  // ==========================
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = 1; // Navigate to search screen
          });
        },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        child: Row(
          children: [
              Icon(Icons.search, color: const Color(0xFF090909), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search for fruits, vegetables, dishes...',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 14,
                    color: const Color(0xFF090909).withOpacity(0.5),
                  ),
                ),
              ),
              Icon(Icons.tune, color: const Color(0xFF090909), size: 20),
          ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromotionalBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF00BF63),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 0,
            bottom: 0,
            child: Center(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You have Free',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Delivery Coupons',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Redeem Now',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 16,
                            color: const Color(0xFF00BF63),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -80,
            top:-60,
            bottom:-70,
            child: Opacity(
              opacity: 0.95,
              child: Image.asset(
                'assets/home/IllustrationHeartLunala.png',
                width: 302,
                height: 302,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            right: -80,
            top: -40,
            bottom: -10,
            child: Image.asset(
              'assets/home/BobbaLunala.png',
              width: 250,
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // CATEGORY BUTTONS
  // ==========================
  Widget _buildCategoryButtons() {
    final categories = [
      {'name': 'Groceries', 'image': 'assets/home/Baghome.png'},
      {'name': 'Food', 'image': 'assets/home/Pizzahome.png'},
      {'name': 'Product', 'image': 'assets/home/Fruithome.png'},
      {'name': 'Offers', 'image': 'assets/home/dicountsd2.png'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: categories.map((category) {
          return Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BF63),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
            child: Column(
              children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        category['image'] as String,
                  width: 50,
                  height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                Text(
                      category['name'] as String,
                      style: GoogleFonts.instrumentSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================
  // MEAL FILTERS
  // ==========================
  Widget _buildMealFilters() {
    final mealFilters = ['Breakfast', 'Lunch', 'Dinner', 'Beverages', 'Salads'];
    final categoryFilters = ['Fruits', 'Vegetables'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal Type Filters
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mealFilters.length,
              itemBuilder: (context, index) {
                final filter = mealFilters[index];
                final isSelected = _selectedMealFilter == filter;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMealFilter = filter;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00BF63) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF00BF63) : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        filter,
                        style: GoogleFonts.instrumentSans(
                          fontSize: 14,
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Category Filters
          Row(
            children: [
              Text(
                'Filters',
                style: GoogleFonts.instrumentSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              ...categoryFilters.map((filter) {
                final isSelected = _selectedCategoryFilter == filter;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryFilter = filter;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00BF63) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF00BF63) : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      filter,
                      style: GoogleFonts.instrumentSans(
                        fontSize: 14,
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================
  // RECOMMENDED SECTION
  // ==========================
  Widget _buildRecommendedSection() {
    final greenProducts = [
      {
        'name': 'Strawberry Salad with Berry',
        'description': 'Hand Plucked Fresh Strawberries',
        'price': '\$12.49',
        'badge': 'Top Picks',
        'delivery': 'Free Delivery',
        'image': 'assets/menu/StrawberrySalad.png',
      },
      {
        'name': 'Nutella Crepes',
        'description': 'Nutella & Strawberries crepes',
        'price': '\$8.49',
        'badge': '20% Discount',
        'delivery': 'Free Delivery',
        'image': 'assets/menu/NutellaCrepes.png',
      },
    ];

    final whiteProducts = [
      {
        'name': 'Mixed Fruit salad',
        'description': 'Fruitful bites of joy!',
        'price': '\$8.49',
        'image': 'assets/menu/FruitSaladD1V1.png',
      },
      {
        'name': 'French Fruit salad',
        'description': "Nature's sweet mix!",
        'price': '\$12.49',
        'image': 'assets/menu/FruitSaladD1V1.png',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommended For you',
            style: GoogleFonts.instrumentSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...greenProducts.map((product) => _buildProductCard(context, product)).toList(),
          const SizedBox(height: 16),
          // White cards in a row
          Row(
            children: [
              Expanded(
                child: _buildWhiteProductCard(context, whiteProducts[0]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildWhiteProductCard(context, whiteProducts[1]),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF00BF63),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Left side content
          Positioned(
            left: 16,
            top: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    if (product['badge'] != null)
                      Container(
                        height: 24,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              product['badge'] as String,
                              style: GoogleFonts.instrumentSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    // Product Name
                    Text(
                      product['name'] as String,
                      style: GoogleFonts.instrumentSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Description
                    if (product['description'] != null)
                      Text(
                        product['description'] as String,
                        style: GoogleFonts.instrumentSans(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price and Delivery Row
                    Row(
                      children: [
                        Text(
                          product['price'] as String,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (product['delivery'] != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.local_shipping, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            product['delivery'] as String,
                            style: GoogleFonts.instrumentSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Product Image - Positioned like banner
          Positioned(
            right: -80,
            top: -40,
            bottom: -10,
            child: Stack(
              children: [
                Image.asset(
                  product['image'] as String,
                  width: 250,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                // Heart Icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00BF63),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      size: 14,
                      color: const Color(0xFF00BF63),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Buy Now Button - On top of image, positioned relative to card
          Positioned(
            bottom: 16,
            right: 16,
            child: SizedBox(
              height: 32,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Buy Now +',
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF00BF63),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // WHITE PRODUCT CARD
  // ==========================
  Widget _buildWhiteProductCard(BuildContext context, Map<String, dynamic> product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image with Heart Icon
          Center(
            child: Stack(
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      product['image'] as String,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Heart Icon
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00BF63),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      size: 14,
                      color: const Color(0xFF00BF63),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Product Name
          Text(
            product['name'] as String,
            style: GoogleFonts.instrumentSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          // Description
          if (product['description'] != null)
            Text(
              product['description'] as String,
              style: GoogleFonts.instrumentSans(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          const SizedBox(height: 8),
          // Price
          Text(
            product['price'] as String,
            style: GoogleFonts.instrumentSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00BF63),
            ),
          ),
          const SizedBox(height: 12),
          // Buy Now Button
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BF63),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Buy Now +',
                style: GoogleFonts.instrumentSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // BOTTOM NAVIGATION BAR
  // ==========================
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Home', 0),
              _buildNavItem(Icons.search, 'Search', 1),
              _buildCenterButton(),
              _buildNavItem(Icons.history, 'History', 3),
              _buildNavItem(Icons.person_outline, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF00BF63) : Colors.black;
    
    IconData displayIcon = icon;
    if (index == 0) {
      displayIcon = isSelected ? Icons.home : Icons.home_outlined;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            displayIcon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.instrumentSans(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = 2;
        });
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF00BF63),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00BF63).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.center_focus_strong,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  // ==========================
  // SEARCH SCREEN
  // ==========================
  Widget _buildSearchScreen() {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: const Color(0xFF090909), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search for fruits, vegetables, dishes...',
                    hintStyle: GoogleFonts.instrumentSans(
                      fontSize: 14,
                      color: const Color(0xFF090909).withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: GoogleFonts.instrumentSans(
                    fontSize: 14,
                    color: const Color(0xFF090909),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Actions Section
              _buildQuickActionsSection(),
              const SizedBox(height: 24),
              // Recent Searches (if any)
              _buildRecentSearches(),
              const SizedBox(height: 24),
              // Search Results or Empty State
              _buildSearchResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2F5BFF),
            Color(0xFF1E3FCC),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F5BFF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Start typing to search for products...',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    // Mock recent searches - replace with actual data
    final recentSearches = ['Strawberry', 'Salad', 'Fruits'];
    
    if (recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Searches',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentSearches.map((search) {
              return InkWell(
                onTap: () {
                  _searchController.text = search;
                  // Trigger search
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.history,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        search,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final hasSearchQuery = _searchController.text.isNotEmpty;
    
    if (!hasSearchQuery) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
              Icon(
                Icons.search_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
          const SizedBox(height: 16),
          Text(
                'Start searching...',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search for products, or use quick actions above',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // TODO: Implement actual search results
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Results',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found for "${_searchController.text}"',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryScreen() {
    return const PurchaseHistoryScreen();
  }

  Widget _buildProfileScreen() {
    return const ProfileScreen();
  }
}
