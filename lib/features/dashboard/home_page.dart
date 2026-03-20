import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../members/members_screen.dart';
import '../equipment/equipment_screen.dart';
import '../payments/payments_screen.dart';
import '../packages/packages_screen.dart';
import '../videos/videos_screen.dart';
import '../notifications/alert_screen.dart';

// ── Brand tokens ─────────────────────────────────────
const kGold      = Color(0xFFC8DC32);
const kGoldDark  = Color(0xFF8FA000);   // text on gold bg
const kGoldLight = Color(0xFFF5F8D6);   // tinted gold surface
const kBg        = Color(0xFFF7F7F5);   // off-white page bg
const kSurface   = Color(0xFFFFFFFF);   // card / header bg
const kSurface2  = Color(0xFFF5F5F5);   // pill / input bg
const kBorder    = Color(0xFFEFEFEF);   // subtle border
const kText1     = Color(0xFF111111);   // primary text
const kText2     = Color(0xFFAAAAAA);   // muted text
const kAmber     = Color(0xFFFFB300);   // warning dot
const kOrange    = Color(0xFFE65C00);   // alert text

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = "Trainer";
  String gym  = "My Gym";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name") ?? "Trainer";
      gym  = prefs.getString("gym")  ?? "Gym";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeader(),
          _buildHeroRevenue(),
          _buildAnalyticsCard(),
          _buildQuickAccess(),
          _buildRecentActivity(),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────
  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        color: kSurface,
        padding: const EdgeInsets.fromLTRB(20, 58, 20, 18),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: kGold,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "T",
                    style: const TextStyle(
                      color: kText1,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "WELCOME BACK",
                        style: TextStyle(
                          color: kText2,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        name,
                        style: const TextStyle(
                          color: kText1,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        gym,
                        style: const TextStyle(
                          color: kGoldDark,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AlertsScreen()),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: kSurface2,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: kBorder),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: kText1,
                          size: 20,
                        ),
                      ),
                      Positioned(
                        top: 9,
                        right: 9,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: kGold,
                            shape: BoxShape.circle,
                            border: Border.all(color: kSurface, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _StatPill("120",  "Gym Members",   kGoldDark),
                const SizedBox(width: 10),
                _StatPill("₹35K", "Revenue",   kText1),
                const SizedBox(width: 10),
                _StatPill("50",  "App Visits",kText1),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── HERO REVENUE ─────────────────────────────────────
  Widget _buildHeroRevenue() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kGold,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "TODAY'S REVENUE",
                      style: TextStyle(
                        color: kGoldDark,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      "₹4,200",
                      style: TextStyle(
                        color: kText1,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "↑ 18% from yesterday",
                      style: TextStyle(
                        color: kGoldDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.currency_rupee_rounded,
                  color: kText1,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── ANALYTICS ─────────────────────────────────────────
  Widget _buildAnalyticsCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Gym Analytics",
                    style: TextStyle(
                      color: kText1,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: kGold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "THIS MONTH",
                      style: TextStyle(
                        color: kGoldDark,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  PremiumRadial(value: .80, useGold: true,  icon: Icons.people_outline,   label: "Members"),
                  PremiumRadial(value: .65, useGold: false, icon: Icons.currency_rupee,   label: "Revenue"),
                  PremiumRadial(value: .98, useGold: true,  icon: Icons.bar_chart_rounded, label: "Attend."),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(color: kBorder, height: 1),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _BottomStat("120",  "Members",   kGoldDark),
                  _BottomStat("₹35K", "Revenue",   kText1),
                  _BottomStat("98%",  "Attendance",kGoldDark),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── QUICK ACCESS ──────────────────────────────────────
  Widget _buildQuickAccess() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel("Quick Access"),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _QuickTile(Icons.fitness_center,         "Equipment", kGoldLight, kGoldDark, const EquipmentScreen()),
                _QuickTile(Icons.workspace_premium,      "Plans",     kGoldLight, kGoldDark, const PackagesScreen()),
                _QuickTile(Icons.credit_card_outlined,   "Payments",  kSurface2,  kText1,    const PaymentsScreen()),
                _QuickTile(Icons.video_library_outlined, "Videos",    kSurface2,  kText1,    const VideosScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── RECENT ACTIVITY ───────────────────────────────────
  Widget _buildRecentActivity() {
    final items = [
      _ActivityData("Ravi Menon joined",  "2 mins ago · Gold Plan",   "+₹2500", kGoldDark, kGold),
      _ActivityData("Priya Nair renewed", "1 hr ago · Silver Plan",   "+₹1500", kText1,    kText1),
      _ActivityData("Equipment alert",    "3 hrs ago · Treadmill #2", "Check",  kOrange,   kAmber),
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionLabel("Recent Activity"),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                children: items.asMap().entries.map((e) {
                  final isLast = e.key == items.length - 1;
                  final d = e.value;
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                        child: Row(
                          children: [
                            Container(
                              width: 7, height: 7,
                              decoration: BoxDecoration(color: d.dot, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(d.title,
                                      style: const TextStyle(
                                        color: kText1, fontSize: 13, fontWeight: FontWeight.w600,
                                      )),
                                  const SizedBox(height: 3),
                                  Text(d.subtitle,
                                      style: const TextStyle(color: kText2, fontSize: 10)),
                                ],
                              ),
                            ),
                            Text(d.value,
                                style: TextStyle(
                                  color: d.valueColor, fontSize: 13, fontWeight: FontWeight.w800,
                                )),
                          ],
                        ),
                      ),
                      if (!isLast) const Divider(color: kBorder, height: 1, indent: 40),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── DATA MODEL ───────────────────────────────────────────────
class _ActivityData {
  final String title, subtitle, value;
  final Color  valueColor, dot;
  const _ActivityData(this.title, this.subtitle, this.value, this.valueColor, this.dot);
}

// ── WIDGETS ──────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      color: kText2, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5,
    ),
  );
}

class _StatPill extends StatelessWidget {
  final String value, label;
  final Color  valueColor;
  const _StatPill(this.value, this.label, this.valueColor);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: kSurface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                color: valueColor, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5,
              )),
          const SizedBox(height: 3),
          Text(label.toUpperCase(),
              style: const TextStyle(
                color: kText2, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1,
              )),
        ],
      ),
    ),
  );
}

class PremiumRadial extends StatelessWidget {
  final double   value;
  final bool     useGold;
  final IconData icon;
  final String   label;

  const PremiumRadial({
    super.key,
    required this.value,
    required this.useGold,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final trackColor = useGold ? kGold      : kText1;
    final iconColor  = useGold ? kGoldDark  : kText1;
    final bgColor    = useGold ? kGoldLight : kSurface2;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 70, height: 70,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                strokeCap: StrokeCap.round,
                backgroundColor: kBorder,
                valueColor: AlwaysStoppedAnimation(trackColor),
              ),
            ),
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Text(label,
            style: const TextStyle(color: kText2, fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _BottomStat extends StatelessWidget {
  final String value, label;
  final Color  color;
  const _BottomStat(this.value, this.label, this.color);
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(value,
          style: TextStyle(
            color: color, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: -0.5,
          )),
      const SizedBox(height: 3),
      Text(label,
          style: const TextStyle(
            color: kText2, fontSize: 9, letterSpacing: 0.5, fontWeight: FontWeight.w600,
          )),
    ],
  );
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    bg, iconColor;
  final Widget   page;
  const _QuickTile(this.icon, this.label, this.bg, this.iconColor, this.page);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
    child: SizedBox(
      width: 76,
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kBorder),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kText2, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    ),
  );
}