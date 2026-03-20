import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'reset_password_screen.dart';

const primaryGreen = Color(0xFFD5EB45);
const lightGreen = Color(0xFFD5EB45);
const bgWhite = Color(0xFFF7F9FC);

class OtpScreen extends StatefulWidget {

  final String email;
  final String token;

  const OtpScreen({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {

  final List<TextEditingController> controllers =
  List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
  List.generate(6, (_) => FocusNode());

  int seconds = 30;
  Timer? timer;

  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    startTimer();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    checkClipboardOtp();
  }

  Future<void> checkClipboardOtp() async {
    final data = await Clipboard.getData('text/plain');

    if (data != null) {
      String text = data.text ?? "";

      if (text.length == 6 && int.tryParse(text) != null) {
        for (int i = 0; i < 6; i++) {
          controllers[i].text = text[i];
        }
        setState(() {});
      }
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (seconds == 0) {
        timer?.cancel();
      } else {
        setState(() => seconds--);
      }
    });
  }

  String getOtp() => controllers.map((e) => e.text).join();

  bool get isOtpComplete => getOtp().length == 6;

  void verifyOtp() {
    if (getOtp() == widget.token) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(
            email: widget.email,
            token: widget.token,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid OTP"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _bgController.dispose();

    for (var c in controllers) {
      c.dispose();
    }

    for (var f in focusNodes) {
      f.dispose();
    }

    super.dispose();
  }

  Widget otpBox(int index) {
    return Container(
      width: 55,
      height: 65,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.grey.shade100,
        border: Border.all(
          color: controllers[index].text.isNotEmpty
              ? primaryGreen
              : Colors.grey.shade300,
        ),
      ),

      child: TextField(
        controller: controllers[index],
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,

        style: const TextStyle(
          fontSize: 22,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),

        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),

        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            focusNodes[index + 1].requestFocus();
          }

          if (value.isEmpty && index > 0) {
            focusNodes[index - 1].requestFocus();
          }

          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final time = seconds.toString().padLeft(2, '0');

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
                            Icons.security,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "OTP Verification",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Enter the OTP sent to\n${widget.email}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, otpBox),
                        ),

                        const SizedBox(height: 30),

                        glowingButton(),

                        const SizedBox(height: 15),

                        seconds == 0
                            ? TextButton(
                          onPressed: () {
                            setState(() => seconds = 30);
                            startTimer();
                          },
                          child: const Text(
                            "Resend OTP",
                            style: TextStyle(color: primaryGreen),
                          ),
                        )
                            : Text(
                          "Resend in 00:$time",
                          style: const TextStyle(color: Colors.black45),
                        ),

                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Edit Email",
                            style: TextStyle(color: primaryGreen),
                          ),
                        )
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
        gradient: isOtpComplete
            ? const LinearGradient(
          colors: [primaryGreen, lightGreen],
        )
            : const LinearGradient(
          colors: [Colors.grey, Colors.grey],
        ),
      ),

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: isOtpComplete ? verifyOtp : null,
        child: const Text(
          "Verify OTP",
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