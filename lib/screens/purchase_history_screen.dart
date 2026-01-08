import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../services/firebase_service.dart';
import 'order_detail_screen.dart';
import 'login_screen.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  
  String _selectedDateFilter = 'All';
  String _selectedStatusFilter = 'All';
  String _searchQuery = '';
  bool _isLoading = true;
  String? _errorMessage;
  
  // Real orders from Firebase
  List<Order> _allOrders = [];
  List<Order> _filteredOrders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // First try to get customer ID directly (more reliable than phone number)
      final customerId = await _firebaseService.getCurrentCustomerId();
      print('=== Purchase History Debug ===');
      print('Retrieved customer ID from SharedPreferences: ${customerId ?? "null"}');
      
      List<Map<String, dynamic>> ordersData = [];
      
      if (customerId != null && customerId.isNotEmpty) {
        // Use customer ID directly to get orders (most reliable method)
        print('Using customer ID to fetch orders: $customerId');
        ordersData = await _firebaseService.getOrdersByCustomerId(customerId);
        print('Purchase History: Retrieved ${ordersData.length} orders by customerId');
      } else {
        // Fallback: Try phone number
        final phoneNumber = await _firebaseService.getCurrentUserPhoneNumber();
        print('Customer ID not found, trying phone number: ${phoneNumber ?? "null"}');
        
        if (phoneNumber == null || phoneNumber.isEmpty) {
          print('ERROR: Both customer ID and phone number are null or empty!');
          print('This means the user did not complete login or data was not saved.');
          setState(() {
            _errorMessage = 'No user logged in. Please login to view your orders.';
            _allOrders = [];
            _filteredOrders = [];
            _isLoading = false;
          });
          return;
        }
        
        print('Phone number is valid, proceeding to fetch orders...');
        ordersData = await _firebaseService.getOrdersByPhoneNumber(phoneNumber);
        print('Purchase History: Retrieved ${ordersData.length} orders from Firebase');
      }
      
      // Convert Firestore data to Order models
      final orders = ordersData.map((data) {
        try {
          return Order.fromFirestore(data, data['id'] as String);
        } catch (e) {
          print('Error parsing order: $e');
          print('Order data: $data');
          return null;
        }
      }).whereType<Order>().toList();
      
      print('Purchase History: Successfully parsed ${orders.length} orders');
      
      setState(() {
        _allOrders = orders;
        _filteredOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading orders: $e');
      setState(() {
        _errorMessage = 'Failed to load orders. Please try again.';
        _allOrders = [];
        _filteredOrders = [];
        _isLoading = false;
      });
    }
  }


  void _applyFilters() {
    setState(() {
      _filteredOrders = _allOrders.where((order) {
        // Date filter
        final now = DateTime.now();
        final orderDate = order.createdAt ?? DateTime.now();
        bool dateMatch = true;
        
        if (_selectedDateFilter == 'Last 30 days') {
          dateMatch = orderDate.isAfter(now.subtract(const Duration(days: 30)));
        } else if (_selectedDateFilter == '3 months') {
          dateMatch = orderDate.isAfter(now.subtract(const Duration(days: 90)));
        }
        
        // Status filter
        bool statusMatch = _selectedStatusFilter == 'All' || 
                          order.status == _selectedStatusFilter;
        
        // Search filter
        bool searchMatch = _searchQuery.isEmpty ||
            order.id?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
            order.items.any((item) => 
                item.productName.toLowerCase().contains(_searchQuery.toLowerCase()));
        
        return dateMatch && statusMatch && searchMatch;
      }).toList();
    });
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
                            _buildSearchBar(),
                            const SizedBox(height: 16),
                            _buildFilters(),
                            const SizedBox(height: 20),
                            _isLoading
                                ? _buildLoadingState()
                                : _errorMessage != null
                                    ? _buildErrorState()
                                    : _filteredOrders.isEmpty
                                        ? _buildEmptyState()
                                        : _buildOrderList(),
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
                  "Purchase History",
                  style: GoogleFonts.instrumentSans(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "View your past orders and purchases",
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
  // SEARCH BAR
  // ==========================
  Widget _buildSearchBar() {
    return Container(
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
          Icon(Icons.search, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by order ID or product name...',
                hintStyle: GoogleFonts.instrumentSans(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: GoogleFonts.instrumentSans(
                fontSize: 14,
                color: Colors.black,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _applyFilters();
              },
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
                _applyFilters();
              },
              child: Icon(Icons.clear, color: Colors.grey.shade600, size: 20),
            ),
        ],
      ),
    );
  }

  // ==========================
  // FILTERS
  // ==========================
  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Range Filter
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['All', 'Last 30 days', '3 months'].map((filter) {
              final isSelected = _selectedDateFilter == filter;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDateFilter = filter;
                  });
                  _applyFilters();
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
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // Status Filter
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['All', 'delivered', 'processing', 'pending', 'cancelled'].map((filter) {
              final isSelected = _selectedStatusFilter == filter;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStatusFilter = filter;
                  });
                  _applyFilters();
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
                      filter.toUpperCase(),
                      style: GoogleFonts.instrumentSans(
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ==========================
  // ORDER LIST
  // ==========================
  Widget _buildOrderList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._filteredOrders.asMap().entries.map((entry) {
          final index = entry.key;
          final order = entry.value;
          return Column(
            children: [
              _buildOrderCard(order),
              if (index < _filteredOrders.length - 1)
                Divider(color: Colors.grey.shade200, height: 24),
            ],
          );
        }).toList(),
      ],
    );
  }

  // ==========================
  // ORDER CARD
  // ==========================
  Widget _buildOrderCard(Order order) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final orderDate = order.createdAt ?? DateTime.now();
    final itemCount = order.items.length;
    final itemSummary = itemCount == 1
        ? order.items.first.productName
        : '${itemCount} items';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(order: order),
          ),
        );
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order ${order.id ?? 'N/A'}',
                            style: GoogleFonts.instrumentSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${dateFormat.format(orderDate)} • ${timeFormat.format(orderDate)}',
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
                    _buildStatusBadge(order.status),
                  ],
                ),
                const SizedBox(height: 12),
                // Item Summary
                Row(
                  children: [
                    // Thumbnail
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00BF63).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.shopping_bag,
                        color: const Color(0xFF00BF63),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            itemSummary,
                            style: GoogleFonts.instrumentSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.deliveryAddress ?? 'No address',
                            style: GoogleFonts.instrumentSans(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Total Amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${order.totalAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.instrumentSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00BF63),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // STATUS BADGE
  // ==========================
  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'delivered':
      case 'completed': // Handle "completed" status (same as delivered)
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle;
        break;
      case 'processing':
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        icon = Icons.refresh;
        break;
      case 'pending':
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        icon = Icons.pending;
        break;
      case 'cancelled':
      case 'canceled': // Handle both spellings
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        icon = Icons.cancel;
        break;
      default:
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade700;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.instrumentSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // LOADING STATE
  // ==========================
  Widget _buildLoadingState() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 60,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 150,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  // ==========================
  // ERROR STATE
  // ==========================
  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Error Loading Orders',
            style: GoogleFonts.instrumentSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'An error occurred while loading your orders.',
            style: GoogleFonts.instrumentSans(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          if (_errorMessage?.contains('No user logged in') == true) ...[
            // Show Login button if user is not logged in
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BF63),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Go to Login',
                  style: GoogleFonts.instrumentSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Debug button to check SharedPreferences
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  // Test SharedPreferences
                  final prefsWorking = await _firebaseService.testSharedPreferences();
                  
                  final phone = await _firebaseService.getCurrentUserPhoneNumber();
                  final customerId = await _firebaseService.getCurrentCustomerId();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SharedPreferences Test: ${prefsWorking ? "WORKING" : "FAILED"}',
                            style: GoogleFonts.instrumentSans(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Phone: ${phone ?? "null"}',
                            style: GoogleFonts.instrumentSans(),
                          ),
                          Text(
                            'CustomerID: ${customerId ?? "null"}',
                            style: GoogleFonts.instrumentSans(),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                  // Try reloading
                  _loadOrders();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Debug: Test & Check Data',
                  style: GoogleFonts.instrumentSans(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _loadOrders();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _errorMessage?.contains('No user logged in') == true
                    ? Colors.grey.shade300
                    : const Color(0xFF00BF63),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.instrumentSans(
                  color: _errorMessage?.contains('No user logged in') == true
                      ? Colors.grey.shade700
                      : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // EMPTY STATE
  // ==========================
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty || _selectedStatusFilter != 'All' || _selectedDateFilter != 'All'
                ? 'No orders found'
                : "You haven't made any purchases yet.",
            style: GoogleFonts.instrumentSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _searchQuery.isNotEmpty || _selectedStatusFilter != 'All' || _selectedDateFilter != 'All'
                ? 'Try adjusting your filters or search query'
                : 'Start shopping to see your purchase history here',
            style: GoogleFonts.instrumentSans(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchQuery.isEmpty && _selectedStatusFilter == 'All' && _selectedDateFilter == 'All') ...[
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to home screen
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BF63),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Start Shopping',
                  style: GoogleFonts.instrumentSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

