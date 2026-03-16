import 'dart:ui';
import 'package:flutter/material.dart';

const gold = Color(0xFFD5EB45);
const bg = Color(0xff0B0D12);
const card = Color(0xff12141A);

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => isSaving = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile Updated Successfully"),
        backgroundColor: gold,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      floatingActionButton: _saveButton(),

      body: CustomScrollView(
        slivers: [

          /// 🔥 PREMIUM APP BAR
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: bg,
            title: const Text("Edit Profile"),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gold.withOpacity(0.35),
                      bg
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: _profileImage(),
              ),
            ),
          ),

          /// 💎 FORM
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [

                    _glassField(
                      "Full Name",
                      Icons.person,
                      controller: nameController,
                    ),

                    _glassField(
                      "Phone Number",
                      Icons.phone,
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                    ),

                    _glassField(
                      "Email Address",
                      Icons.email,
                      controller: emailController,
                      keyboardType:
                      TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// 🖼 PROFILE IMAGE
  Widget _profileImage() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [

          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [gold, Colors.transparent],
              ),
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: card,
              child: Icon(Icons.person,
                  size: 40,
                  color: Colors.white70),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: gold,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit,
                size: 18,
                color: Colors.black),
          )
        ],
      ),
    );
  }

  /// 🧊 GLASS FIELD
  Widget _glassField(
      String hint,
      IconData icon, {
        required TextEditingController controller,
        TextInputType keyboardType =
            TextInputType.text,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: 10, sigmaY: 10),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
                color: Colors.white),
            validator: (value) {
              if (value == null ||
                  value.isEmpty) {
                return "Required Field";
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                  color: Colors.white38),
              prefixIcon:
              Icon(icon, color: gold),
              filled: true,
              fillColor:
              card.withOpacity(0.7),
              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(18),
                borderSide:
                BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 💾 SAVE BUTTON
  Widget _saveButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color:
            gold.withOpacity(0.5),
            blurRadius: 25,
          )
        ],
      ),
      child: FloatingActionButton.extended(
        backgroundColor: gold,
        onPressed:
        isSaving ? null : saveProfile,
        icon: isSaving
            ? const SizedBox(
          height: 18,
          width: 18,
          child:
          CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.black,
          ),
        )
            : const Icon(Icons.check,
            color: Colors.black),
        label: Text(
          isSaving
              ? "Saving..."
              : "Save Changes",
          style: const TextStyle(
              color: Colors.black,
              fontWeight:
              FontWeight.bold),
        ),
      ),
    );
  }
}