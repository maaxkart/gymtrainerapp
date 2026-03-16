import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../auth/otp_screen.dart';

const gold = Color(0xFFD5EB45);
const bg = Color(0xff0B0D12);

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

            child: Stack(
              children: [

                /// Glow circles
                Positioned(
                  top: -80,
                  left: -60,
                  child: glowCircle(gold),
                ),

                Positioned(
                  bottom: -100,
                  right: -60,
                  child: glowCircle(const Color(0xFFD5EB45)),
                ),

                /// MAIN CARD
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),

                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 25,
                          sigmaY: 25,
                        ),

                        child: Container(
                          padding: const EdgeInsets.all(30),

                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
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
                                "Forgot Password",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                "Enter your email to receive OTP",
                                style: TextStyle(
                                  color: Colors.white54,
                                ),
                              ),

                              const SizedBox(height: 30),

                              /// EMAIL FIELD
                              TextField(
                                controller: emailController,
                                style: const TextStyle(
                                    color: Colors.white),
                                keyboardType:
                                TextInputType.emailAddress,

                                decoration: InputDecoration(
                                  prefixIcon:
                                  const Icon(Icons.email,
                                      color: gold),

                                  hintText: "Email Address",

                                  hintStyle: const TextStyle(
                                      color: Colors.white38),

                                  filled: true,
                                  fillColor:
                                  Colors.black.withOpacity(.45),

                                  border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 25),

                              /// SEND OTP BUTTON
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
        },
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
            spreadRadius: 1,
          )
        ],
      ),

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),

        onPressed: loading ? null : sendReset,

        child: loading
            ? const CircularProgressIndicator(
          color: Colors.black,
        )
            : const Text(
          "Send OTP",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
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
        color: color.withOpacity(.25),
      ),
    );
  }
}