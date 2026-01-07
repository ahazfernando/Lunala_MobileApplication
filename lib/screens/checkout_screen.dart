import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wallet_screen.dart';
import 'home_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final Map<String, int> _itemQuantities = {
    'New York Style Pizza': 2,
    'Kist Ride Classic': 1,
    'Scan Jumbo Peanuts Chilli': 1,
    'Pringles Potato Chips': 1,
  };
  bool _requestUtensils = true;
  final TextEditingController _specialInstructionsController = TextEditingController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _specialInstructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D973),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildGreenHeader(),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDeliveryAddress(),
                            const SizedBox(height: 24),
                            _buildCartItems(),
                            const SizedBox(height: 24),
                            _buildSpecialRequests(),
                            const SizedBox(height: 24),
                            _buildOrderSummary(),
                            const SizedBox(height: 24),
                            _buildLunalaPoints(),
                            const SizedBox(height: 24),
                            _buildProceedButton(),
                            const SizedBox(height: 20),
                          ],
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
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ==========================
  // GREEN HEADER
  // ==========================
  Widget _buildGreenHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF00BF63),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF00D973).withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button and Notification
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Back",
                            style: GoogleFonts.instrumentSans(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  "Cart",
                  style: GoogleFonts.instrumentSans(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Sure, you got what you need?",
                  style: GoogleFonts.instrumentSans(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // DELIVERY ADDRESS
  // ==========================
  Widget _buildDeliveryAddress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.black, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Deliver to",
                  style: GoogleFonts.instrumentSans(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "No. 42, Galle Road, Dehiwala",
                  style: GoogleFonts.instrumentSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.person_add, color: Colors.grey.shade600, size: 24),
        ],
      ),
    );
  }

  // ==========================
  // CART ITEMS
  // ==========================
  Widget _buildCartItems() {
    final items = [
      {
        'name': 'New York Style Pizza',
        'description': 'Extra Cheese + Mushrooms',
        'price': '2490 LKR',
      },
      {
        'name': 'Kist Ride Classic',
        'description': '250ml',
        'price': '350 LKR',
      },
      {
        'name': 'Scan Jumbo Peanuts Chilli',
        'description': '70g',
        'price': '210 LKR',
      },
      {
        'name': 'Pringles Potato Chips',
        'description': '110g',
        'price': '790 LKR',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final itemName = item['name'] as String;
          final quantity = _itemQuantities[itemName] ?? 1;
          
          return Column(
            children: [
              _buildCartItem(item, quantity, itemName),
              if (index < items.length - 1)
                Divider(color: Colors.grey.shade200, height: 24),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCartItem(Map<String, dynamic> item, int quantity, String itemName) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['name'] as String,
                style: GoogleFonts.instrumentSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['description'] as String,
                style: GoogleFonts.instrumentSans(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Quantity Control
        Container(
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF00BF63),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  icon: const Icon(Icons.remove, color: Colors.white, size: 14),
                  onPressed: () {
                    setState(() {
                      if (quantity > 0) {
                        _itemQuantities[itemName] = quantity - 1;
                      }
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '$quantity',
                  style: GoogleFonts.instrumentSans(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(
                width: 28,
                height: 28,
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white, size: 14),
                  onPressed: () {
                    setState(() {
                      _itemQuantities[itemName] = quantity + 1;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          item['price'] as String,
          style: GoogleFonts.instrumentSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ==========================
  // SPECIAL REQUESTS
  // ==========================
  Widget _buildSpecialRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.restaurant, color: Colors.grey.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              "Request Utensils",
              style: GoogleFonts.instrumentSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Checkbox(
              value: _requestUtensils,
              onChanged: (value) {
                setState(() {
                  _requestUtensils = value ?? false;
                });
              },
              activeColor: const Color(0xFF00BF63),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _specialInstructionsController,
                  decoration: InputDecoration(
                    hintText: "Add any Special Instructions here",
                    hintStyle: GoogleFonts.instrumentSans(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                  style: GoogleFonts.instrumentSans(fontSize: 14),
                ),
              ),
              Icon(Icons.add, color: Colors.grey.shade600, size: 20),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================
  // ORDER SUMMARY
  // ==========================
  Widget _buildOrderSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Subtotal",
          style: GoogleFonts.instrumentSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          "3,840 LKR",
          style: GoogleFonts.instrumentSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ==========================
  // LUNALA POINTS
  // ==========================
  Widget _buildLunalaPoints() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF00BF63).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00BF63).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet, color: const Color(0xFF00BF63), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Save LKR 90 with Lunala Points",
              style: GoogleFonts.instrumentSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF00BF63),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // PROCEED BUTTON
  // ==========================
  Widget _buildProceedButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WalletScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BF63),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "Proceed to Checkout",
          style: GoogleFonts.instrumentSans(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
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
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
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
  }  Widget _buildCenterButton() {
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
}