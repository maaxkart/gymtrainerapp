import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
const gold = Color(0xFFD5EB45);

class GymRegistrationScreen extends StatefulWidget {

  final List<int> selectedFacilities;
  final String address;
  final double latitude;
  final double longitude;

  const GymRegistrationScreen({
    super.key,
    required this.selectedFacilities,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<GymRegistrationScreen> createState() =>
      _GymRegistrationScreenState();
}

class _GymRegistrationScreenState
    extends State<GymRegistrationScreen>
    with SingleTickerProviderStateMixin {

  final _formKey = GlobalKey<FormState>();

  final gymNameController = TextEditingController();
  final ownerController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final locationController = TextEditingController();
  final taxIdController = TextEditingController();
  final capacityController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? emailError;
  String? taxIdError;

  bool isSubmitting = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  File? gymImage;
  final ImagePicker picker = ImagePicker();

  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    locationController.text = widget.address;
  }

  @override
  void dispose() {

    _bgController.dispose();

    gymNameController.dispose();
    ownerController.dispose();
    emailController.dispose();
    mobileController.dispose();
    locationController.dispose();
    taxIdController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  Future pickGymImage() async {

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        gymImage = File(pickedFile.path);
      });
    }
  }

  Future<void> submit() async {

    if (!_formKey.currentState!.validate()) return;

    if (gymImage == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload gym photo")),
      );

      return;
    }

    setState(() {
      isSubmitting = true;
      emailError = null;
      taxIdError = null;
    });

    try {

      final response = await ApiService.registerGym(

        gymName: gymNameController.text,
        gymPhoto: gymImage!,
        address: locationController.text,
        latitude: widget.latitude,
        longitude: widget.longitude,
        taxId: taxIdController.text,
        capacity: capacityController.text,
        facilities: widget.selectedFacilities,
        name: ownerController.text,
        email: emailController.text,
        password: passwordController.text,
        passwordConfirmation: confirmPasswordController.text,
      );

      setState(() => isSubmitting = false);

      if (response["status"] == "success") {

        final prefs = await SharedPreferences.getInstance();

        /// SAVE GYM REGISTERED STATE
        await prefs.setBool("gym_registered", true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gym Registered Successfully"),
            backgroundColor: gold,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );

      } else {

        final errors = response["errors"];

        setState(() {

          if (errors["email"] != null) {
            emailError = errors["email"][0];
          }

          if (errors["tax_id"] != null) {
            taxIdError = errors["tax_id"][0];
          }

        });
      }

    } catch (e) {

      setState(() => isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Server Error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [

          AnimatedBuilder(
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
              );
            },
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 30),

                  const Text(
                    "Register Your Gym",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Form(
                    key: _formKey,

                    child: Column(
                      children: [

                        /// Gym Image
                        GestureDetector(
                          onTap: pickGymImage,
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: gold),
                              image: gymImage != null
                                  ? DecorationImage(
                                  image: FileImage(gymImage!),
                                  fit: BoxFit.cover)
                                  : null,
                            ),
                            child: gymImage == null
                                ? const Center(
                              child: Text(
                                "Upload Gym Photo",
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                                : null,
                          ),
                        ),

                        const SizedBox(height: 25),

                        buildField("Gym Name", Icons.fitness_center, gymNameController),

                        const SizedBox(height: 20),
                        buildField(
                          "Gym Capacity",
                          Icons.people,
                          capacityController,
                          type: TextInputType.number,
                        ),

                        const SizedBox(height: 20),

                        buildField("Owner Name", Icons.person, ownerController),

                        const SizedBox(height: 20),

                        buildField(
                          "Email",
                          Icons.email,
                          emailController,
                          errorText: emailError,
                          type: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 20),

                        buildField("Mobile", Icons.phone, mobileController,
                            type: TextInputType.phone),

                        const SizedBox(height: 20),

                        buildField(
                          "Tax ID",
                          Icons.badge,
                          taxIdController,
                          errorText: taxIdError,
                        ),

                        const SizedBox(height: 20),

                        buildPasswordField(),

                        const SizedBox(height: 20),

                        buildConfirmPasswordField(),

                        const SizedBox(height: 20),

                        buildField("Address", Icons.location_on, locationController),

                        const SizedBox(height: 35),

                        GestureDetector(
                          onTap: isSubmitting ? null : submit,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFD5EB45),
                                  Color(0xFFB7D933),
                                ],
                              ),
                            ),
                            child: Center(
                              child: isSubmitting
                                  ? const CircularProgressIndicator(color: Colors.black)
                                  : const Text(
                                "Register Gym",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildField(
      String hint,
      IconData icon,
      TextEditingController controller, {
        String? errorText,
        TextInputType type = TextInputType.text,
      }) {

    return TextFormField(
      controller: controller,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      validator: (value) => value!.isEmpty ? "Required Field" : null,

      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: gold),
        hintText: hint,
        errorText: errorText,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.black.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildPasswordField() {

    return TextFormField(
      controller: passwordController,
      obscureText: obscurePassword,
      style: const TextStyle(color: Colors.white),

      validator: (value) {

        if (value == null || value.isEmpty) {
          return "Password required";
        }

        if (value.length < 6) {
          return "Minimum 6 characters required";
        }

        return null;
      },

      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock, color: gold),

        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: gold,
          ),
          onPressed: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
        ),

        hintText: "Password",

        filled: true,
        fillColor: Colors.black.withOpacity(0.4),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget buildConfirmPasswordField() {

    return TextFormField(
      controller: confirmPasswordController,
      obscureText: obscureConfirmPassword,
      style: const TextStyle(color: Colors.white),

      validator: (value) {

        if (value != passwordController.text) {
          return "Passwords do not match";
        }

        return null;
      },

      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: gold),

        suffixIcon: IconButton(
          icon: Icon(
            obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: gold,
          ),
          onPressed: () {
            setState(() {
              obscureConfirmPassword =
              !obscureConfirmPassword;
            });
          },
        ),

        hintText: "Confirm Password",

        filled: true,
        fillColor: Colors.black.withOpacity(0.4),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}