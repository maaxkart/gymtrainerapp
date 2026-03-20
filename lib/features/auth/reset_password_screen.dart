import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';

const primaryGreen = Color(0xFFD5EB45);
const lightGreen = Color(0xFFD5EB45);
const bgWhite = Color(0xFFF7F9FC);

class ResetPasswordScreen extends StatefulWidget {

  final String email;
  final String token;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {

  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool obscure1 = true;
  bool obscure2 = true;
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
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {

    if (passwordController.text.isEmpty ||
        confirmController.text.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    setState(() => loading = true);

    final response = await ApiService.resetPassword(
      widget.email,
      widget.token,
      passwordController.text,
      confirmController.text,
    );

    setState(() => loading = false);

    if (response["status"] == "success") {

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => successDialog(),
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              response["errors"]?["password"]?[0] ??
                  "Reset failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget successDialog() {

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Icon(
              Icons.check_circle,
              color: primaryGreen,
              size: 70,
            ),

            const SizedBox(height: 15),

            const Text(
              "Password Reset Successful",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Your password has been updated successfully.",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
              ),

              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                      (route) => false,
                );
              },

              child: const Text(
                "Back to Login",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
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
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),

                  child: Container(
                    padding: const EdgeInsets.all(30),

                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.85),
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
                          "Reset Password",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 30),

                        passwordField(
                          controller: passwordController,
                          hint: "New Password",
                          obscure: obscure1,
                          toggle: () {
                            setState(() => obscure1 = !obscure1);
                          },
                        ),

                        const SizedBox(height: 20),

                        passwordField(
                          controller: confirmController,
                          hint: "Confirm Password",
                          obscure: obscure2,
                          toggle: () {
                            setState(() => obscure2 = !obscure2);
                          },
                        ),

                        const SizedBox(height: 25),

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

  Widget passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback toggle,
  }) {

    return TextField(
      controller: controller,
      obscureText: obscure,

      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock, color: primaryGreen),

        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: primaryGreen,
          ),
          onPressed: toggle,
        ),

        hintText: hint,

        filled: true,
        fillColor: Colors.grey.shade100,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
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
        onPressed: loading ? null : resetPassword,
        child: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          "Update Password",
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