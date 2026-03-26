import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const primaryGreen = Color(0xFFC8DC32);
const lightGreen = Color(0xFFC8DC32);
const bgWhite = Color(0xFFF7F9FC);

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
    extends State<GymRegistrationScreen> {

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

  bool isSubmitting = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  File? gymImage;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    locationController.text = widget.address;
  }

  Future pickGymImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() => gymImage = File(pickedFile.path));
    }
  }

  Future<void> submit() async {

    if (!_formKey.currentState!.validate()) return;

    if (gymImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload gym photo")),
      );
      return;
    }

    setState(() => isSubmitting = true);

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
        await prefs.setBool("gym_registered", true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gym Registered Successfully")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration failed")),
        );
      }

    } catch (e) {

      setState(() => isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Server Error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bgWhite,

      body: Stack(
        children: [

          /// BACKGROUND
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

          /// FORM
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 20),

                  const Text(
                    "Register Your Gym",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Form(
                    key: _formKey,

                    child: Column(
                      children: [

                        /// IMAGE
                        GestureDetector(
                          onTap: pickGymImage,
                          child: Container(
                            height: 150,
                            width: double.infinity,

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.grey.shade200,
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
                                style: TextStyle(color: Colors.black54),
                              ),
                            )
                                : null,
                          ),
                        ),

                        const SizedBox(height: 25),

                        buildField("Gym Name", Icons.fitness_center, gymNameController),
                        const SizedBox(height: 20),

                        buildField("Capacity", Icons.people, capacityController,
                            type: TextInputType.number),
                        const SizedBox(height: 20),

                        buildField("Owner Name", Icons.person, ownerController),
                        const SizedBox(height: 20),

                        buildField("Email", Icons.email, emailController,
                            type: TextInputType.emailAddress),
                        const SizedBox(height: 20),

                        buildField("Mobile", Icons.phone, mobileController,
                            type: TextInputType.phone),
                        const SizedBox(height: 20),

                        buildField("Tax ID", Icons.badge, taxIdController),
                        const SizedBox(height: 20),

                        buildPasswordField(),
                        const SizedBox(height: 20),

                        buildConfirmPasswordField(),
                        const SizedBox(height: 20),

                        buildField("Address", Icons.location_on, locationController),
                        const SizedBox(height: 30),

                        /// BUTTON
                        Container(
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

                            onPressed: isSubmitting ? null : submit,

                            child: isSubmitting
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              "Register Gym",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
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

  /// TEXT FIELD
  Widget buildField(
      String hint,
      IconData icon,
      TextEditingController controller, {
        TextInputType type = TextInputType.text,
      }) {

    return TextFormField(
      controller: controller,
      keyboardType: type,

      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),

      validator: (value) => value!.isEmpty ? "Required Field" : null,

      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryGreen),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade600),

        filled: true,
        fillColor: Colors.white,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
      ),
    );
  }

  /// PASSWORD
  Widget buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: obscurePassword,

      style: const TextStyle(color: Colors.black),

      validator: (value) {
        if (value == null || value.isEmpty) return "Password required";
        if (value.length < 6) return "Min 6 characters";
        return null;
      },

      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock, color: primaryGreen),

        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: primaryGreen,
          ),
          onPressed: () =>
              setState(() => obscurePassword = !obscurePassword),
        ),

        hintText: "Password",
        hintStyle: TextStyle(color: Colors.grey.shade600),

        filled: true,
        fillColor: Colors.white,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
      ),
    );
  }

  /// CONFIRM PASSWORD
  Widget buildConfirmPasswordField() {
    return TextFormField(
      controller: confirmPasswordController,
      obscureText: obscureConfirmPassword,

      style: const TextStyle(color: Colors.black),

      validator: (value) {
        if (value != passwordController.text) {
          return "Passwords do not match";
        }
        return null;
      },

      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock_outline, color: primaryGreen),

        suffixIcon: IconButton(
          icon: Icon(
            obscureConfirmPassword
                ? Icons.visibility_off
                : Icons.visibility,
            color: primaryGreen,
          ),
          onPressed: () => setState(() =>
          obscureConfirmPassword = !obscureConfirmPassword),
        ),

        hintText: "Confirm Password",
        hintStyle: TextStyle(color: Colors.grey.shade600),

        filled: true,
        fillColor: Colors.white,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
      ),
    );
  }
}