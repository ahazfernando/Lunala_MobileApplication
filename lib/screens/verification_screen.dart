import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import '../services/firebase_service.dart';

class VerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isLogin;

  const VerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.isLogin,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final FirebaseService _firebaseService = FirebaseService();
  int _resendTimer = 25;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
        _startTimer();
      }
    });
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
                  _buildVerificationCard(),
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
                  "Verification",
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
  // VERIFICATION CARD
  // ==========================
  Widget _buildVerificationCard() {
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
              "Enter Code",
              style: GoogleFonts.instrumentSans(
                fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
            Text(
              "Enter the Code sent to ${widget.phoneNumber}",
              style: GoogleFonts.instrumentSans(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
          ),
          const SizedBox(height: 30),
          _buildOTPInputs(),
          const SizedBox(height: 24),
          _buildResendCode(),
          const SizedBox(height: 24),
          _buildVerifyButton(),
            const SizedBox(height: 24),
          Center(
            child: TextButton(
              onPressed: () {},
                child: Text(
                "Didn't get OTP? Try another way",
                  style: GoogleFonts.instrumentSans(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildOTPInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        return SizedBox(
          width: 60,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: GoogleFonts.instrumentSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF00BF63), width: 2),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 3) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildResendCode() {
    return Center(
      child: Text(
        'Resend Code in ${_resendTimer}s',
        style: GoogleFonts.instrumentSans(
          color: Colors.grey,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isVerifying ? null : _handleVerifyOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00BF63),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey,
        ),
        child: _isVerifying
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Verify',
                style: GoogleFonts.instrumentSans(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _handleVerifyOTP() async {
    // Collect OTP from all 4 input fields
    final enteredOTP = _controllers.map((controller) => controller.text).join();

    // Validate OTP is complete
    if (enteredOTP.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter the complete OTP',
            style: GoogleFonts.instrumentSans(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      // Verify OTP with Firebase
      final isAuthenticated = await _firebaseService.verifyOTPAndAuthenticate(
        phoneNumber: widget.phoneNumber,
        otp: enteredOTP,
      );

      if (isAuthenticated) {
        // Successfully authenticated - navigate to home screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        // Invalid OTP
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Invalid OTP. Please enter 1234',
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
          _isVerifying = false;
        });
      }
    }
  }

}



