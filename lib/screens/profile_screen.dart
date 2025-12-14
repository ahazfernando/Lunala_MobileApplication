import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _isLoading = false;
  
  // Mock user data - replace with actual data from Firebase/backend
  final String _userName = 'Ahaz Fernando';
  final DateTime _memberSince = DateTime(2023, 1, 15);
  
  // Mock payment cards data
  List<Map<String, dynamic>> _paymentCards = [
    {
      'id': 'card1',
      'cardNumber': '2345',
      'cardHolderName': 'Ahaz Fernando',
      'expiryDate': '02/30',
      'cardType': 'Visa',
      'isDefault': true,
    },
    {
      'id': 'card2',
      'cardNumber': '6789',
      'cardHolderName': 'Ahaz Fernando',
      'expiryDate': '12/28',
      'cardType': 'Mastercard',
      'isDefault': false,
    },
  ];
  
  // Mock loyalty data
  final String _currentTier = 'Gold';
  final int _loyaltyPoints = 12500;
  final double _totalSavings = 48750.0;
  final double _spentThisYear = 125000.0;
  final double _nextTierThreshold = 150000.0;
  
  // Mock insights
  final String _mostVisitedBranch = 'Keells Dehiwala';
  final String _preferredShoppingDay = 'Saturday';
  final String _preferredCategory = 'Fruits & Vegetables';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D973),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState()
            : SingleChildScrollView(
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
                            _buildProfileInfoCard(),
                            const SizedBox(height: 20),
                            _buildRewardsAndSavingsSection(),
                            const SizedBox(height: 20),
                            _buildLoyaltyTierOverview(),
                            const SizedBox(height: 20),
                            _buildPersonalInsightsSection(),
                            const SizedBox(height: 20),
                            _buildPaymentMethodsSection(),
                            const SizedBox(height: 20),
                            _buildAccountSettingsSection(),
                            const SizedBox(height: 20),
                            _buildAppPreferencesSection(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ==========================
  // GREEN HEADER
  // ==========================
  Widget _buildGreenHeader() {
    final memberSinceFormat = DateFormat('MMM yyyy');
    
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
                // Notification Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                // Profile Picture and Info
                Row(
                  children: [
                    // Profile Picture
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _showEditProfileDialog(),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF00BF63), width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Color(0xFF00BF63),
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: GoogleFonts.instrumentSans(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Member since ${memberSinceFormat.format(_memberSince)}',
                                style: GoogleFonts.instrumentSans(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildLoyaltyTierBadge(_currentTier),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  "Profile",
                  style: GoogleFonts.instrumentSans(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Manage your account and preferences",
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
  // PROFILE INFO CARD
  // ==========================
  Widget _buildProfileInfoCard() {
    final progress = (_spentThisYear / _nextTierThreshold).clamp(0.0, 1.0);
    final remainingAmount = (_nextTierThreshold - _spentThisYear).clamp(0.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00BF63),
            const Color(0xFF00BF63).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BF63).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress to ${_getNextTier(_currentTier)}',
                style: GoogleFonts.instrumentSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'LKR ${remainingAmount.toStringAsFixed(0)} away',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LKR ${_spentThisYear.toStringAsFixed(0)}',
                style: GoogleFonts.instrumentSans(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Text(
                'LKR ${_nextTierThreshold.toStringAsFixed(0)}',
                style: GoogleFonts.instrumentSans(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================
  // LOYALTY TIER BADGE
  // ==========================
  Widget _buildLoyaltyTierBadge(String tier) {
    final tierInfo = _getTierInfo(tier);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            tierInfo['icon'] as IconData,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            tier.toUpperCase(),
            style: GoogleFonts.instrumentSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // REWARDS & SAVINGS SECTION
  // ==========================
  Widget _buildRewardsAndSavingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.card_giftcard,
              color: const Color(0xFF00BF63),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'Rewards & Savings',
              style: GoogleFonts.instrumentSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildRewardCard(
                'Total Saved',
                'LKR ${_totalSavings.toStringAsFixed(0)}',
                Icons.savings,
                const Color(0xFF00BF63),
                'View Savings',
                () {
                  // TODO: Navigate to savings detail
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildRewardCard(
                'Loyalty Points',
                _loyaltyPoints.toString(),
                Icons.stars,
                Colors.orange,
                'Redeem',
                () {
                  // TODO: Navigate to rewards redemption
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRewardCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String buttonText,
    VoidCallback onTap,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              Icon(
                Icons.arrow_forward,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.instrumentSans(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.instrumentSans(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.instrumentSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // LOYALTY TIER OVERVIEW
  // ==========================
  Widget _buildLoyaltyTierOverview() {
    final tiers = ['Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond'];
    final currentTierIndex = tiers.indexOf(_currentTier);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
          Row(
            children: [
              Icon(
                Icons.workspace_premium,
                color: const Color(0xFF00BF63),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Loyalty Tiers',
                style: GoogleFonts.instrumentSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
            ...tiers.asMap().entries.map((entry) {
              final index = entry.key;
              final tier = entry.value;
              final isCurrentTier = index == currentTierIndex;
              final isUnlocked = index <= currentTierIndex;
              final tierInfo = _getTierInfo(tier);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCurrentTier
                      ? (tierInfo['color'] as Color).withOpacity(0.1)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrentTier
                        ? tierInfo['color'] as Color
                        : Colors.grey.shade200,
                    width: isCurrentTier ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Tier Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: isUnlocked
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  tierInfo['color'] as Color,
                                  (tierInfo['color'] as Color).withOpacity(0.7),
                                ],
                              )
                            : null,
                        color: isUnlocked ? null : Colors.grey.shade200,
                        shape: BoxShape.circle,
                        boxShadow: isCurrentTier
                            ? [
                                BoxShadow(
                                  color: (tierInfo['color'] as Color).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        tierInfo['icon'] as IconData,
                        color: isUnlocked ? Colors.white : Colors.grey.shade400,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Tier Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                tier,
                                style: GoogleFonts.instrumentSans(
                                  fontSize: 18,
                                  fontWeight: isCurrentTier
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isUnlocked
                                      ? Colors.black
                                      : Colors.grey.shade600,
                                ),
                              ),
                              if (isCurrentTier) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF00BF63),
                                        Color(0xFF00D973),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'CURRENT',
                                    style: GoogleFonts.instrumentSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _getTierBenefit(tier),
                            style: GoogleFonts.instrumentSans(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      );
  }

  // ==========================
  // PERSONAL INSIGHTS SECTION
  // ==========================
  Widget _buildPersonalInsightsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00BF63).withOpacity(0.05),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00BF63).withOpacity(0.2)),
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
            Row(
              children: [
                Icon(
                  Icons.insights,
                  color: const Color(0xFF00BF63),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Personal Insights',
                  style: GoogleFonts.instrumentSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInsightRow(
              Icons.store,
              'Most Visited Branch',
              _mostVisitedBranch,
            ),
            const SizedBox(height: 16),
            _buildInsightRow(
              Icons.calendar_today,
              'Preferred Shopping Day',
              _preferredShoppingDay,
            ),
            const SizedBox(height: 16),
            _buildInsightRow(
              Icons.shopping_bag,
              'Favorite Category',
              _preferredCategory,
            ),
          ],
        ),
      );
  }

  Widget _buildInsightRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00BF63).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF00BF63), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.instrumentSans(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.instrumentSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================
  // PAYMENT METHODS SECTION
  // ==========================
  Widget _buildPaymentMethodsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.credit_card,
                      color: const Color(0xFF00BF63),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Payment Methods',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => _showAddCardDialog(),
                  icon: const Icon(
                    Icons.add,
                    color: Color(0xFF00BF63),
                    size: 20,
                  ),
                  label: Text(
                    'Add Card',
                    style: GoogleFonts.instrumentSans(
                      color: const Color(0xFF00BF63),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_paymentCards.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.credit_card_off,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No payment methods',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add a card to make payments faster',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ..._paymentCards.map((card) => _buildPaymentCardItem(card)).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPaymentCardItem(Map<String, dynamic> card) {
    final isDefault = card['isDefault'] as bool;
    
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDefault ? const Color(0xFF00BF63) : Colors.grey.shade200,
              width: isDefault ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              // Card Background
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/financials/CreditDebit.png',
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
              // Card Content Overlay
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              if (isDefault)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'DEFAULT',
                                    style: GoogleFonts.instrumentSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Image.asset(
                                'assets/financials/VisaLogo.png',
                                width: 50,
                                height: 18,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.credit_card,
                            color: Colors.white.withOpacity(0.8),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '**** **** **** ${card['cardNumber']}',
                            style: GoogleFonts.instrumentSans(
                              color: Colors.white,
                              fontSize: 16,
                              letterSpacing: 1.5,
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
                                'Card Holder',
                                style: GoogleFonts.instrumentSans(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                card['cardHolderName'] as String,
                                style: GoogleFonts.instrumentSans(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Expires',
                                style: GoogleFonts.instrumentSans(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                card['expiryDate'] as String,
                                style: GoogleFonts.instrumentSans(
                                  color: Colors.white,
                                  fontSize: 14,
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
              ),
            ],
          ),
        ),
        // Action Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showEditCardDialog(card),
                  icon: const Icon(Icons.edit, size: 18),
                  label: Text(
                    'Edit',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00BF63),
                    side: const BorderSide(color: Color(0xFF00BF63)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (!isDefault)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _setAsDefault(card['id'] as String),
                    icon: const Icon(Icons.star_outline, size: 18),
                    label: Text(
                      'Set Default',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF00BF63),
                      side: const BorderSide(color: Color(0xFF00BF63)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteCard(card['id'] as String),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: Text(
                      'Delete',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (card != _paymentCards.last) _buildDivider(),
      ],
    );
  }

  void _showAddCardDialog() {
    final cardNumberController = TextEditingController();
    final cardHolderController = TextEditingController(text: _userName);
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add New Card',
          style: GoogleFonts.instrumentSans(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 19,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cardHolderController,
                decoration: InputDecoration(
                  labelText: 'Card Holder Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expiryController,
                      decoration: InputDecoration(
                        labelText: 'Expiry (MM/YY)',
                        hintText: '12/25',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.instrumentSans(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (cardNumberController.text.isNotEmpty &&
                  cardHolderController.text.isNotEmpty &&
                  expiryController.text.isNotEmpty &&
                  cvvController.text.isNotEmpty) {
                final last4 = cardNumberController.text.length >= 4
                    ? cardNumberController.text.substring(
                        cardNumberController.text.length - 4)
                    : '0000';
                
                setState(() {
                  _paymentCards.add({
                    'id': 'card${DateTime.now().millisecondsSinceEpoch}',
                    'cardNumber': last4,
                    'cardHolderName': cardHolderController.text,
                    'expiryDate': expiryController.text,
                    'cardType': 'Visa',
                    'isDefault': _paymentCards.isEmpty,
                  });
                });
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Card added successfully!'),
                    backgroundColor: const Color(0xFF00BF63),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BF63),
            ),
            child: Text(
              'Add Card',
              style: GoogleFonts.instrumentSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditCardDialog(Map<String, dynamic> card) {
    final cardNumberController = TextEditingController(
      text: '**** **** **** ${card['cardNumber']}',
    );
    final cardHolderController = TextEditingController(
      text: card['cardHolderName'] as String,
    );
    final expiryController = TextEditingController(
      text: card['expiryDate'] as String,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Card',
          style: GoogleFonts.instrumentSans(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                enabled: false,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cardHolderController,
                decoration: InputDecoration(
                  labelText: 'Card Holder Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: expiryController,
                decoration: InputDecoration(
                  labelText: 'Expiry (MM/YY)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.instrumentSans(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final index = _paymentCards.indexWhere(
                  (c) => c['id'] == card['id'],
                );
                if (index != -1) {
                  _paymentCards[index] = {
                    ..._paymentCards[index],
                    'cardHolderName': cardHolderController.text,
                    'expiryDate': expiryController.text,
                  };
                }
              });
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Card updated successfully!'),
                  backgroundColor: const Color(0xFF00BF63),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BF63),
            ),
            child: Text(
              'Save Changes',
              style: GoogleFonts.instrumentSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _setAsDefault(String cardId) {
    setState(() {
      for (var card in _paymentCards) {
        card['isDefault'] = card['id'] == cardId;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Default card updated!'),
        backgroundColor: const Color(0xFF00BF63),
      ),
    );
  }

  void _deleteCard(String cardId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Card',
          style: GoogleFonts.instrumentSans(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this card?',
          style: GoogleFonts.instrumentSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.instrumentSans(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _paymentCards.removeWhere((card) => card['id'] == cardId);
                // If deleted card was default, set first card as default
                if (_paymentCards.isNotEmpty && 
                    _paymentCards.every((c) => !c['isDefault'])) {
                  _paymentCards[0]['isDefault'] = true;
                }
              });
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Card deleted successfully!'),
                  backgroundColor: const Color(0xFF00BF63),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.instrumentSans(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // ACCOUNT SETTINGS SECTION
  // ==========================
  Widget _buildAccountSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Account & Profile',
              style: GoogleFonts.instrumentSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
            _buildSettingsTile(
              icon: Icons.person,
              title: 'Edit Personal Details',
              subtitle: 'Name, Email, Phone',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.camera_alt,
            title: 'Change Profile Picture',
            subtitle: 'Update your photo',
            onTap: () {
              // TODO: Implement profile picture change
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.lock,
            title: 'Change Password',
            subtitle: 'Update your security',
            onTap: () {
              // TODO: Navigate to change password screen
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.security,
            title: 'Security Information',
            subtitle: 'View security settings',
            onTap: () {
              // TODO: Navigate to security screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF00BF63).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF00BF63), size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.instrumentSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.instrumentSans(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade200,
      indent: 60,
    );
  }

  // ==========================
  // APP PREFERENCES SECTION
  // ==========================
  Widget _buildAppPreferencesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'App Preferences',
              style: GoogleFonts.instrumentSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00BF63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: const Color(0xFF00BF63),
                size: 20,
              ),
            ),
            title: Text(
              'Dark Mode',
              style: GoogleFonts.instrumentSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            subtitle: Text(
              _isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
              style: GoogleFonts.instrumentSans(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            value: _isDarkMode,
            activeColor: const Color(0xFF00BF63),
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
                // TODO: Apply theme change immediately
              });
            },
          ),
          _buildDivider(),
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00BF63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.notifications,
                color: const Color(0xFF00BF63),
                size: 20,
              ),
            ),
            title: Text(
              'Notifications',
              style: GoogleFonts.instrumentSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            subtitle: Text(
              _notificationsEnabled
                  ? 'Receive app notifications'
                  : 'Notifications disabled',
              style: GoogleFonts.instrumentSans(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            value: _notificationsEnabled,
            activeColor: const Color(0xFF00BF63),
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                // TODO: Update notification preferences
              });
            },
          ),
          _buildDivider(),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF00BF63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.language,
                color: const Color(0xFF00BF63),
                size: 20,
              ),
            ),
            title: Text(
              'Language',
              style: GoogleFonts.instrumentSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            subtitle: Text(
              'English',
              style: GoogleFonts.instrumentSans(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
            onTap: () {
              // TODO: Show language selection dialog
            },
          ),
        ],
      ),
    );
  }

  // ==========================
  // LOADING STATE
  // ==========================
  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: const Color(0xFF00BF63),
      ),
    );
  }

  // ==========================
  // EDIT PROFILE DIALOG
  // ==========================
  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.instrumentSans(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Profile editing feature coming soon!',
          style: GoogleFonts.instrumentSans(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.instrumentSans(
                color: const Color(0xFF00BF63),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // HELPER METHODS
  // ==========================
  Map<String, dynamic> _getTierInfo(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return {
          'color': Colors.brown,
          'icon': Icons.looks_one,
        };
      case 'silver':
        return {
          'color': Colors.grey,
          'icon': Icons.looks_two,
        };
      case 'gold':
        return {
          'color': Colors.amber,
          'icon': Icons.looks_3,
        };
      case 'platinum':
        return {
          'color': Colors.blueGrey,
          'icon': Icons.looks_4,
        };
      case 'diamond':
        return {
          'color': Colors.cyan,
          'icon': Icons.looks_5,
        };
      default:
        return {
          'color': Colors.grey,
          'icon': Icons.star,
        };
    }
  }

  String _getTierBenefit(String tier) {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return '5% discount on all purchases';
      case 'silver':
        return '7% discount + Free delivery';
      case 'gold':
        return '10% discount + Priority support';
      case 'platinum':
        return '15% discount + Exclusive offers';
      case 'diamond':
        return '20% discount + VIP treatment';
      default:
        return 'Member benefits';
    }
  }

  String _getNextTier(String currentTier) {
    final tiers = ['Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond'];
    final currentIndex = tiers.indexOf(currentTier);
    if (currentIndex < tiers.length - 1) {
      return tiers[currentIndex + 1];
    }
    return 'Max Tier';
  }
}
