import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'payment_success_screen.dart';
import 'home_screen.dart';
import 'schedule_screen.dart';
import '../services/firebase_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  String _selectedPaymentMethod = 'Credit/Debit Card';
  String _selectedDelivery = 'Express';
  bool _useLoyaltyPoints = false;
  int _currentIndex = 0;
  DateTime? _scheduledDate;
  String? _scheduledTimeSlot;
  String? _deliveryNote;
  final FirebaseService _firebaseService = FirebaseService();
  String _cardHolderName = 'Card Holder';
  bool _isLoadingName = true;

  @override
  void initState() {
    super.initState();
    _loadCustomerName();
  }

  Future<void> _loadCustomerName() async {
    try {
      final phoneNumber = await _firebaseService.getCurrentUserPhoneNumber();
      
      if (phoneNumber != null) {
        final fullPhoneNumber = phoneNumber.startsWith('+') 
            ? phoneNumber 
            : '+94$phoneNumber';
        
        final customerData = await _firebaseService.getUserByPhoneNumber(fullPhoneNumber);
        
        if (customerData != null && mounted) {
          final firstName = customerData['firstName'] as String?;
          final lastName = customerData['lastName'] as String?;
          
          if (firstName != null || lastName != null) {
            final fullName = [(firstName ?? ''), (lastName ?? '')]
                .where((s) => s.isNotEmpty)
                .join(' ')
                .trim();
            if (fullName.isNotEmpty) {
              setState(() {
                _cardHolderName = fullName;
              });
            }
          } else if (customerData['name'] != null) {
            setState(() {
              _cardHolderName = customerData['name'] as String;
            });
          }
        }
      }
    } catch (e) {
      print('Error loading customer name: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingName = false;
        });
      }
    }
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
                            _buildPaymentMethodTabs(),
                            const SizedBox(height: 24),
                            _buildCreditCard(),
                            const SizedBox(height: 24),
                            _buildAddCardButton(),
                            const SizedBox(height: 24),
                            _buildDeliveryOptions(),
                            const SizedBox(height: 24),
                            _buildOrderSummary(),
                            const SizedBox(height: 24),
                            _buildLunalaPoints(),
                            const SizedBox(height: 24),
                            _buildPayButton(),
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
                  "Checkout",
                  style: GoogleFonts.instrumentSans(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Payments made real and safe",
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
  // PAYMENT METHOD TABS
  // ==========================
  Widget _buildPaymentMethodTabs() {
    return Row(
      children: [
        Expanded(
          child: _buildTab('Credit/Debit Card', _selectedPaymentMethod == 'Credit/Debit Card', () {
            setState(() {
              _selectedPaymentMethod = 'Credit/Debit Card';
            });
          }),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTab('Cash', _selectedPaymentMethod == 'Cash', () {
            setState(() {
              _selectedPaymentMethod = 'Cash';
            });
          }),
        ),
      ],
    );
  }

  Widget _buildTab(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00BF63) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.instrumentSans(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================
  // CREDIT CARD
  // ==========================
  Widget _buildCreditCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Card Background Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/financials/CreditDebit.png',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          // Card Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Finaci',
                      style: GoogleFonts.instrumentSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Image.asset(
                      'assets/financials/VisaLogo.png',
                      width: 60,
                      height: 20,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.credit_card, color: Colors.white.withOpacity(0.8), size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '**** **** **** 2345',
                      style: GoogleFonts.instrumentSans(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Card Holder name',
                          style: GoogleFonts.instrumentSans(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isLoadingName ? 'Card Holder' : _cardHolderName,
                          style: GoogleFonts.instrumentSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Expiry Date',
                          style: GoogleFonts.instrumentSans(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '02/30',
                          style: GoogleFonts.instrumentSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
  // ADD CARD BUTTON
  // ==========================
  Widget _buildAddCardButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          // Add card functionality
        },
        icon: const Icon(Icons.add, color: Color(0xFF00BF63)),
        label: Text(
          'Add Card',
          style: GoogleFonts.instrumentSans(
            color: const Color(0xFF00BF63),
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF00BF63), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ==========================
  // DELIVERY OPTIONS
  // ==========================
  Widget _buildDeliveryOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Options',
          style: GoogleFonts.instrumentSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDeliveryOption(
                'Express',
                Icons.inventory_2,
                '25-30 min',
                _selectedDelivery == 'Express',
                () {
                  setState(() {
                    _selectedDelivery = 'Express';
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDeliveryOption(
                'Schedule',
                Icons.calendar_today,
                _scheduledDate != null && _scheduledTimeSlot != null
                    ? '${DateFormat('MMM d').format(_scheduledDate!)} at $_scheduledTimeSlot'
                    : 'Choose when and what time to deliver',
                _selectedDelivery == 'Schedule',
                () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ScheduleScreen()),
                  );
                  
                  if (result != null) {
                    setState(() {
                      _selectedDelivery = 'Schedule';
                      _scheduledDate = result['date'] as DateTime?;
                      _scheduledTimeSlot = result['timeSlot'] as String?;
                      _deliveryNote = result['note'] as String?;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryOption(
    String label,
    IconData icon,
    String subtitle,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00BF63).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00BF63) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00BF63) : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.instrumentSans(
                color: isSelected ? const Color(0xFF00BF63) : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.instrumentSans(
                color: isSelected ? Colors.grey.shade700 : Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================
  // ORDER SUMMARY
  // ==========================
  Widget _buildOrderSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Summary',
          style: GoogleFonts.instrumentSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildSummaryRow('Subtotal', 'LKR 3,840'),
        const SizedBox(height: 12),
        _buildSummaryRow('Delivery Fee', 'LKR 149'),
        const SizedBox(height: 16),
        Divider(color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: GoogleFonts.instrumentSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '3899 LKR',
              style: GoogleFonts.instrumentSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00BF63),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.instrumentSans(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.instrumentSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
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
          GestureDetector(
            onTap: () {
              setState(() {
                _useLoyaltyPoints = !_useLoyaltyPoints;
              });
            },
            child: Text(
              "use",
              style: GoogleFonts.instrumentSans(
                fontSize: 14,
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
  // PAY BUTTON
  // ==========================
  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PaymentSuccessScreen()),
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
          "Pay Now",
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