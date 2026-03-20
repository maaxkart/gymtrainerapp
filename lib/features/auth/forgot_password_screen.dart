import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../auth/otp_screen.dart';

const primaryGreen = Color(0xFFD5EB45);
const lightGreen = Color(0xFFD5EB45);
const bgWhite = Color(0xFFF7F9FC);

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {

  final emailController = TextEditingController();
  bool loading = false;

  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void sendReset() async {

    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email is required")),
      );
      return;
    }

    setState(() => loading = true);

    try {

      final response = await ApiService.forgotPassword(
        emailController.text.trim(),
      );

      setState(() => loading = false);

      if (response["status"] == "success") {

        String token = response["token"].toString();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              email: emailController.text.trim(),
              token: token,
            ),
          ),
        );

      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response["errors"]?["email"]?[0] ??
                  "Something went wrong",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }

    } catch (e) {

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Server error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bgWhite,

      body: Stack(
        children: [

          /// 🌿 BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF7F9FC),
                  Color(0xFFE8F5E9),
                  Color(0xFFD0F0E0),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// 🌿 GLOW
          Positioned(
            top: -80,
            left: -60,
            child: glowCircle(primaryGreen),
          ),

          Positioned(
            bottom: -100,
            right: -60,
            child: glowCircle(lightGreen),
          ),

          /// 🧊 CARD
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),

                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 20,
                    sigmaY: 20,
                  ),

                  child: Container(
                    padding: const EdgeInsets.all(30),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(30),
                    ),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        /// ICON
                        Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [primaryGreen, lightGreen],
                            ),
                          ),
                          child: const Icon(
                            Icons.lock_reset,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Forgot Password",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Enter your email to receive OTP",
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 30),

                        /// EMAIL FIELD
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,

                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.email,
                              color: primaryGreen,
                            ),

                            hintText: "Email Address",

                            filled: true,
                            fillColor: Colors.grey.shade100,

                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        /// BUTTON
                        glowingButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget glowingButton() {

    return Container(
      width: double.infinity,
      height: 55,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [primaryGreen, lightGreen],
        ),
      ),

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),

        onPressed: loading ? null : sendReset,

        child: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          "Send OTP",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget glowCircle(Color color) {
    return Container(
      height: 220,
      width: 220,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(.2),
      ),
    );
  }
}