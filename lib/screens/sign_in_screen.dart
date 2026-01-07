import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'verification_screen.dart';
import 'login_screen.dart';
import '../services/firebase_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D973),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Stack(
            children: [
              Column(
                children: [
                  _buildGreenHeader(),
                  _buildSignUpCard(),
                ],
              ),
              // Positioned image overlapping both sections
              Positioned(
                top: 100, // Positioned to overlap green header and white card
                right: 0,
                child: Image.asset(
                  'assets/Signin/keellslogov1 1.png',
                  height: 200,
                  fit: BoxFit.contain,
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
                // BACK BUTTON
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
                const SizedBox(height: 15),
                Text(
                  "Hello",
                  style: GoogleFonts.instrumentSans(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Fresh Finds, Every Day.",
                  style: GoogleFonts.instrumentSans(
                    color: Colors.white,
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
  // SIGN UP CARD
  // ==========================
  Widget _buildSignUpCard() {
    return Transform.translate(
      offset: const Offset(0, -5),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.only(top: 30, left: 24, right: 24, bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Sign Up",
              style: GoogleFonts.instrumentSans(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Create your account",
              style: GoogleFonts.instrumentSans(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField('First Name', _firstNameController),
            const SizedBox(height: 16),
            _buildTextField('Last Name', _lastNameController),
            const SizedBox(height: 16),
            _buildTextField('Email Address', _emailController, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildPhoneInput(),
            const SizedBox(height: 24),
            _buildVerifyButton(),
            const SizedBox(height: 24),
            _buildDivider(),
            const SizedBox(height: 24),
            _buildSocialLogin(),
            const SizedBox(height: 24),
            _buildRewardsSection(),
            const SizedBox(height: 16),
            _buildLoginLink(),
          ],
        ),
      ),
    );
  }

  // ==========================
  // TEXT FIELD
  // ==========================
  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: GoogleFonts.instrumentSans(
            color: Colors.grey.shade400,
          ),
        ),
        style: GoogleFonts.instrumentSans(),
      ),
    );
  }

  // ==========================
  // PHONE INPUT
  // ==========================
  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Text("🇱🇰", style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  "+94",
                  style: GoogleFonts.instrumentSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey.shade600)
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "Phone Number",
                  border: InputBorder.none,
                  hintStyle: GoogleFonts.instrumentSans(
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ==========================
  // VERIFY BUTTON
  // ==========================
  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BF63),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                "Verify",
                style: GoogleFonts.instrumentSans(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _handleSignUp() async {
    // Validate all fields
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final phoneNumber = _phoneController.text.trim();

    if (firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter your first name',
            style: GoogleFonts.instrumentSans(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter your last name',
            style: GoogleFonts.instrumentSans(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter your phone number',
            style: GoogleFonts.instrumentSans(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Format phone number with country code
    final fullPhoneNumber = '+94$phoneNumber';

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if user already exists
      final userExists = await _firebaseService.userExistsByPhoneNumber(fullPhoneNumber);

      if (userExists) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'User already exists. Please login instead.',
              style: GoogleFonts.instrumentSans(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Create new user in Firebase
      final userId = await _firebaseService.createUser(
        phoneNumber: fullPhoneNumber,
        firstName: firstName,
        lastName: lastName,
        email: email.isNotEmpty ? email : null,
      );

      if (userId != null) {
        // Send OTP
        final otpSent = await _firebaseService.sendOTP(fullPhoneNumber);

        if (otpSent) {
          // Navigate to verification screen with phone number
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => VerificationScreen(phoneNumber: fullPhoneNumber, isLogin: false),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Account created but failed to send OTP. Please try again.',
                  style: GoogleFonts.instrumentSans(),
                ),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to create account. Please try again.',
                style: GoogleFonts.instrumentSans(),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An error occurred. Please try again.',
              style: GoogleFonts.instrumentSans(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ==========================
  // DIVIDER
  // ==========================
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "or",
            style: GoogleFonts.instrumentSans(fontSize: 14),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  // ==========================
  // SOCIAL LOGIN
  // ==========================
  Widget _buildSocialLogin() {
    return Row(
      children: [
        Expanded(
          child: _socialBtn(icon: "G", label: "Google", isGoogle: true),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _socialBtn(icon: Icons.fingerprint, label: "Biometrics", isGoogle: false),
        ),
      ],
    );
  }

  Widget _socialBtn({required dynamic icon, required String label, required bool isGoogle}) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      onPressed: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isGoogle
              ? Text(icon, style: GoogleFonts.instrumentSans(fontSize: 18, fontWeight: FontWeight.bold))
              : Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.instrumentSans(fontSize: 16)),
        ],
      ),
    );
  }

  // ==========================
  // REWARDS BOX
  // ==========================
  Widget _buildRewardsSection() {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0x14000000), // Black with 8% opacity (0.08 * 255 ≈ 20)
            offset: const Offset(0, 0),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Left side content
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            right: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Unlock Rewards",
                  style: GoogleFonts.instrumentSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Where Loyalty is Rewarded. Stay up for amazing savings ahead",
                  style: GoogleFonts.instrumentSans(fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  "View More",
                  style: GoogleFonts.instrumentSans(
                    color: const Color(0xFF00BF63),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Box image on the right - positioned like promotional banner
          Positioned(
            right: -20,
            top: 0,
            bottom: -20,
            child: Image.asset(
              'assets/Signin/Box.png',
              width: 120,
              height: 140,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================
  // LOGIN LINK
  // ==========================
  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Already have an account? ",
            style: GoogleFonts.instrumentSans(fontSize: 14),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: Text(
              "Login",
              style: GoogleFonts.instrumentSans(
                fontSize: 14,
                color: const Color(0xFF00BF63),
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }
}
