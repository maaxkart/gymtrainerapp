import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_service.dart';
import '../auth/login_screen.dart';

import '../payments/payments_screen.dart';
import '../packages/packages_screen.dart';
import '../equipment/equipment_screen.dart';
import '../videos/videos_screen.dart';
import 'edit_profile_screen.dart';

const gold = Color(0xFFD5EB45);
const bg = Color(0xff0B0D12);
const surface = Color(0xff161A23);
const surfaceLight = Color(0xff1E2430);

class TrainerProfileScreen extends StatefulWidget {
  const TrainerProfileScreen({super.key});

  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {

  String userName = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  /// LOAD USER FROM SHARED PREFERENCES
  Future loadUser() async {

    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString("user");

    if (userString != null) {

      final user = jsonDecode(userString);

      setState(() {
        userName = user["name"] ?? "";
        email = user["email"] ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bg,

      body: CustomScrollView(
        slivers: [

          /// 🔥 PREMIUM HEADER
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [surfaceLight, surface],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),

              child: Column(
                children: [

                  /// PROFILE IMAGE
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [gold, Colors.transparent],
                      ),
                    ),

                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: surface,

                      child: Text(
                        userName.isNotEmpty
                            ? userName[0].toUpperCase()
                            : "U",

                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// USER NAME
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// EMAIL
                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                    children: [
                      ProfileStat("120", "Clients"),
                      ProfileStat("₹35K", "Revenue"),
                      ProfileStat("4.9", "Rating"),
                    ],
                  )
                ],
              ),
            ),
          ),

          /// BODY
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [

                  _sectionTitle("Management"),

                  _menuCard(
                    context,
                    Icons.payments,
                    "Payments",
                        () => _go(context, const PaymentsScreen()),
                  ),

                  _menuCard(
                    context,
                    Icons.workspace_premium,
                    "Packages",
                        () => _go(context, PackagesScreen()),
                  ),

                  _menuCard(
                    context,
                    Icons.fitness_center,
                    "Equipment",
                        () => _go(context, const EquipmentScreen()),
                  ),

                  _menuCard(
                    context,
                    Icons.video_library,
                    "Workout Videos",
                        () => _go(context, const VideosScreen()),
                  ),

                  const SizedBox(height: 30),

                  _sectionTitle("Account & Security"),

                  _menuCard(
                    context,
                    Icons.person,
                    "Edit Profile",
                        () => _go(context, const EditProfileScreen()),
                  ),

                  _menuCard(
                    context,
                    Icons.logout,
                    "Logout",
                        () => _logout(context),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  /// MENU CARD
  Widget _menuCard(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {

    return GestureDetector(
      onTap: onTap,

      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: surfaceLight,
          borderRadius: BorderRadius.circular(22),
        ),

        child: Row(
          children: [

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: gold.withOpacity(0.15),
                shape: BoxShape.circle,
              ),

              child: Icon(icon, color: gold, size: 20),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: gold,
            )
          ],
        ),
      ),
    );
  }

  /// SECTION TITLE
  Widget _sectionTitle(String text) {

    return Align(
      alignment: Alignment.centerLeft,

      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),

        child: Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: gold,
          ),
        ),
      ),
    );
  }

  /// NAVIGATION
  void _go(BuildContext context, Widget page) {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// LOGOUT
  Future<void> _logout(BuildContext context) async {

    showDialog(
      context: context,

      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),

        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          TextButton(
            onPressed: () async {

              Navigator.pop(context);

              await ApiService.logout();

              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                    (route) => false,
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {

  final String value, label;

  const ProfileStat(this.value, this.label, {super.key});

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [

        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: gold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        )
      ],
    );
  }
}