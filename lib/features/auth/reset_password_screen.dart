import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';

const gold = Color(0xFFD5EB45);

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
              color: Colors.green,
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
                backgroundColor: gold,
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
                style: TextStyle(color: Colors.black),
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
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) {

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  Color(0xff0B0D12),
                  Color(0xff141821),
                  Color(0xff1C1F2A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, _bgController.value, 1.0],
              ),
            ),

            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),

                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                        sigmaX: 25, sigmaY: 25),

                    child: Container(
                      padding: const EdgeInsets.all(30),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.05),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(.1),
                        ),
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
                                colors: [
                                  Color(0xFFD5EB45),
                                  Color(0xFFB7D933),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: gold.withOpacity(.6),
                                  blurRadius: 30,
                                  spreadRadius: 4,
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.lock_reset,
                              size: 40,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "Reset Password",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 30),

                          /// PASSWORD
                          passwordField(
                            controller: passwordController,
                            hint: "New Password",
                            obscure: obscure1,
                            toggle: () {
                              setState(() {
                                obscure1 = !obscure1;
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          /// CONFIRM PASSWORD
                          passwordField(
                            controller: confirmController,
                            hint: "Confirm Password",
                            obscure: obscure2,
                            toggle: () {
                              setState(() {
                                obscure2 = !obscure2;
                              });
                            },
                          ),

                          const SizedBox(height: 25),

                          /// RESET BUTTON
                          glowingButton(),
                        ],
                      ),
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

  Widget passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback toggle,
  }) {

    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock, color: gold),

        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off
                : Icons.visibility,
            color: gold,
          ),
          onPressed: toggle,
        ),

        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),

        filled: true,
        fillColor: Colors.black.withOpacity(.45),

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
          colors: [
            Color(0xFFD5EB45),
            Color(0xFFB7D933),
          ],
        ),

        boxShadow: [
          BoxShadow(
            color: gold.withOpacity(.6),
            blurRadius: 25,
          )
        ],
      ),

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),

        onPressed: loading ? null : resetPassword,

        child: loading
            ? const CircularProgressIndicator(
          color: Colors.black,
        )
            : const Text(
          "Update Password",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}