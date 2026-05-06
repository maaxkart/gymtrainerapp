import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import '../payments/payments_screen.dart';
import '../packages/packages_screen.dart';
import '../equipment/equipment_screen.dart';
import '../videos/videos_screen.dart';
import '../accounts/ledger_screen.dart';      // ← NEW
import '../accounts/pnl_screen.dart';         // ← NEW
import '../accounts/daybook_screen.dart';     // ← NEW
import 'edit_profile_screen.dart';
import '../members/members_screen.dart';

// ── Brand tokens ─────────────────────────────────────
const kGold       = Color(0xFFC8DC32);
const kGoldDark   = Color(0xFF8FA000);
const kGoldDeep   = Color(0xFF5A6E00);
const kGoldLight  = Color(0xFFF5F8D6);
const kGoldBorder = Color(0xFFE2EC8A);
const kBg         = Color(0xFFF7F7F5);
const kSurface    = Color(0xFFFFFFFF);
const kSurface2   = Color(0xFFF5F5F5);
const kBorder     = Color(0xFFEFEFEF);
const kText1      = Color(0xFF111111);
const kText2      = Color(0xFFAAAAAA);
const kGreen      = Color(0xFF4CAF50);
const kRed        = Color(0xFFE53935);
const kRedBg      = Color(0xFFFFF8F8);
const kRedBorder  = Color(0xFFFFE0E0);

class TrainerProfileScreen extends StatefulWidget {
  const TrainerProfileScreen({super.key});

  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  String userName = "";
  String email    = "";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs      = await SharedPreferences.getInstance();
    final userString = prefs.getString("user");
    if (userString != null) {
      final user = jsonDecode(userString);
      setState(() {
        userName = user["name"]  ?? "";
        email    = user["email"] ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildTopBar(context),
          _buildProfileCard(),
          _buildBody(context),
        ],
      ),
    );
  }

  // ── TOP BAR ────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(color: kSurface),
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "My Profile",
              style: TextStyle(color: kText1, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.3),
            ),
            GestureDetector(
              onTap: () => _go(context, const EditProfileScreen()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(12)),
                child: const Text(
                  "EDIT",
                  style: TextStyle(color: kGoldDeep, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── PROFILE CARD ───────────────────────────────────
  Widget _buildProfileCard() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          color: kSurface,
          border: Border(bottom: BorderSide(color: kBorder)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gold cover strip with hatch overlay ──
            Stack(
              children: [
                Container(
                  height: 90,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kGold, Color(0xFFDDED60), kGoldLight],
                      stops: [0, 0.55, 1],
                    ),
                  ),
                ),
                CustomPaint(size: const Size(double.infinity, 90), painter: _HatchPainter()),
              ],
            ),

            // ── Avatar + name row ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -36),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(color: kSurface, width: 4),
                            boxShadow: [BoxShadow(color: kGold.withOpacity(.35), blurRadius: 20, offset: const Offset(0, 8))],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.network(
                              "https://i.pravatar.cc/300?img=68",
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: kGoldLight,
                                child: const Icon(Icons.person, color: kGoldDark, size: 40),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2, right: 2,
                          child: Container(
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              color: kGold,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: kSurface, width: 2),
                            ),
                            child: const Icon(Icons.verified_rounded, color: kGoldDeep, size: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName.isNotEmpty ? userName : "Trainer",
                            style: const TextStyle(color: kText1, fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.4),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            email.isNotEmpty ? email : "trainer@gym.com",
                            style: const TextStyle(color: kText2, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Role pill + Online indicator ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: kGoldLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kGoldBorder),
                    ),
                    child: const Text("HEAD TRAINER",
                      style: TextStyle(color: kGoldDark, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: kGreen, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  const Text("Online", style: TextStyle(color: kGreen, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            // ── Stats strip ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Row(
                children: [
                  _StatPill("120",  "Clients", kGoldDark, true),
                  const SizedBox(width: 10),
                  _StatPill("₹35K", "Revenue", kText1,    false),
                  const SizedBox(width: 10),
                  _StatPill("4.9★", "Rating",  kGoldDark, true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── BODY ───────────────────────────────────────────
  Widget _buildBody(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const _SectionLabel("Management"),

            _MenuCard(
              icon: Icons.credit_card_outlined,
              title: "Payments",
              subtitle: "Transactions & invoices",
              iconBg: kGoldLight,
              iconColor: kGoldDark,
              onTap: () => _go(context, const PaymentsScreen()),
            ),
            _MenuCard(
              icon: Icons.workspace_premium_outlined,
              title: "Packages",
              subtitle: "Membership plans",
              iconBg: kGoldLight,
              iconColor: kGoldDark,
              onTap: () => _go(context, PackagesScreen()),
            ),
            // _MenuCard(
            //   icon: Icons.person_add_alt_1_rounded,
            //   title: "Add Member",
            //   subtitle: "Register new gym member",
            //   iconBg: kGoldLight,
            //   iconColor: kGoldDark,
            //   onTap: () => _go(context, MembersScreen()),
            // ),
            _MenuCard(
              icon: Icons.fitness_center_outlined,
              title: "Equipment",
              subtitle: "Manage gym assets",
              iconBg: kSurface2,
              iconColor: kText1,
              onTap: () => _go(context, const EquipmentScreen()),
            ),
            _MenuCard(
              icon: Icons.video_library_outlined,
              title: "Workout Videos",
              subtitle: "Upload & manage content",
              iconBg: kSurface2,
              iconColor: kText1,
              onTap: () => _go(context, const VideosScreen()),
            ),

            // ── NEW: Features / Accounts section ─────────────────────────
            const SizedBox(height: 8),
            const _SectionLabel("Accounts & Finance"),

            // Mini feature banner
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [kGold, Color(0xFFDDED60)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(double.infinity, 56),
                    painter: _HatchPainter(),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: kGoldDeep.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(Icons.account_balance_outlined, color: kGoldDeep, size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Finance Suite",
                              style: TextStyle(color: kGoldDeep, fontSize: 14, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: 2),
                            Text("Ledger · P&L · Day Book",
                              style: TextStyle(color: kGoldDeep, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            _MenuCard(
              icon: Icons.menu_book_outlined,
              title: "Ledger",
              subtitle: "All credit & debit entries",
              iconBg: kGoldLight,
              iconColor: kGoldDark,
              onTap: () => _go(context, const LedgerScreen
                ()),
            ),
            _MenuCard(
              icon: Icons.trending_up_rounded,
              title: "P & L Account",
              subtitle: "Profit & loss statement",
              iconBg: kGoldLight,
              iconColor: kGoldDark,
              onTap: () => _go(context, const PnlScreen()),
            ),
            _MenuCard(
              icon: Icons.calendar_today_outlined,
              title: "Day Book",
              subtitle: "Daily transaction register",
              iconBg: kGoldLight,
              iconColor: kGoldDark,
              onTap: () => _go(context, const DaybookScreen()),
            ),
            // ─────────────────────────────────────────────────────────────

            const SizedBox(height: 8),
            const _SectionLabel("Account & Security"),

            _MenuCard(
              icon: Icons.person_outline_rounded,
              title: "Edit Profile",
              subtitle: "Update your info",
              iconBg: kSurface2,
              iconColor: kText1,
              onTap: () => _go(context, const EditProfileScreen()),
            ),

            // Logout
            GestureDetector(
              onTap: () => _logout(context),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kRedBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kRedBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(color: kRedBorder, borderRadius: BorderRadius.circular(15)),
                      child: const Icon(Icons.logout_rounded, color: kRed, size: 20),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Logout", style: TextStyle(color: kRed, fontSize: 14, fontWeight: FontWeight.w700)),
                          SizedBox(height: 2),
                          Text("Sign out of your account", style: TextStyle(color: kRed, fontSize: 11, fontWeight: FontWeight.w400)),
                        ],
                      ),
                    ),
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(color: kRedBorder, borderRadius: BorderRadius.circular(9)),
                      child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: kRed),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext context, Widget page) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }
}

// ── HATCH TEXTURE PAINTER ────────────────────────────
class _HatchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.06)..strokeWidth = 1;
    const spacing = 14.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }
  @override
  bool shouldRepaint(_HatchPainter old) => false;
}

// ── REUSABLE WIDGETS ──────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(color: kText2, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5),
    ),
  );
}

class _StatPill extends StatelessWidget {
  final String value, label;
  final Color  valueColor;
  final bool   hasAccent;
  const _StatPill(this.value, this.label, this.valueColor, this.hasAccent);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      decoration: BoxDecoration(
        color: kSurface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(height: 3, decoration: BoxDecoration(color: hasAccent ? kGold : kText1)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Text(value,
                    style: TextStyle(color: valueColor, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                const SizedBox(height: 3),
                Text(label.toUpperCase(),
                    style: const TextStyle(color: kText2, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String   title, subtitle;
  final Color    iconBg, iconColor;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: kText1, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: kText2, fontSize: 11)),
              ],
            ),
          ),
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: kText2),
          ),
        ],
      ),
    ),
  );
}

// Kept for backward compat
class ProfileStat extends StatelessWidget {
  final String value, label;
  const ProfileStat(this.value, this.label, {super.key});
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kText1)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: kText2, fontSize: 12)),
    ],
  );
}