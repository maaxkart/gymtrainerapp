import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/total.dart';
import '../analytics/member.dart';
import '../analytics/revenue.dart';
import '../analytics/visits.dart';
import '../chat/memebers_list.dart';
import '../equipment/equipment_screen.dart';
import '../payments/payments_screen.dart';
import '../payments/add_payment.dart';
import '../packages/packages_screen.dart';
import '../videos/videos_screen.dart';
import '../notifications/alert_screen.dart';
import '../accounts/daybook_screen.dart';
import '../accounts/ledger_screen.dart';
import '../accounts/pnl_screen.dart';

// ══════════════════════════════════════════════════════════════
// DESIGN TOKENS — Ultra Premium Light
// ══════════════════════════════════════════════════════════════
const kGold      = Color(0xFFC8DC32);
const kGoldDark  = Color(0xFF8FA000);
const kGoldLight = Color(0xFFF5F8D6);
const kGoldGlow  = Color(0xFFE8F500);
const kBg        = Color(0xFFF4F4F0);
const kBgWarm    = Color(0xFFFAF9F5);
const kSurface   = Color(0xFFFFFFFF);
const kSurface2  = Color(0xFFF7F7F3);
const kBorder    = Color(0xFFECECE6);
const kBorderSoft= Color(0xFFF2F2EC);
const kText1     = Color(0xFF0E0E0E);
const kText2     = Color(0xFFAAAAAA);
const kText3     = Color(0xFF6E6E6E);
const kAmber     = Color(0xFFFFB300);
const kOrange    = Color(0xFFE65C00);
const kOrangeDark= Color(0xFFB84400);

// Semantic palette extras
const kGreen     = Color(0xFF2E7D32);
const kGreenLight= Color(0xFFE8F5E9);
const kGreenSoft = Color(0xFF43A047);
const kRed       = Color(0xFFC62828);
const kRedLight  = Color(0xFFFFEBEE);
const kBlue      = Color(0xFF1565C0);
const kBlueLight = Color(0xFFE3F2FD);
const kPurple    = Color(0xFF4A148C);
const kPurpleLight = Color(0xFFF3E5F5);
const kTeal      = Color(0xFF00695C);
const kTealLight = Color(0xFFE0F2F1);

// Ultra Premium Elevation shadows (Softer, wider spread)
List<BoxShadow> kShadowSm = [
  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, spreadRadius: 0, offset: const Offset(0, 4)),
  BoxShadow(color: kGoldDark.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
];
List<BoxShadow> kShadowMd = [
  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 35, spreadRadius: -2, offset: const Offset(0, 12)),
  BoxShadow(color: kGoldDark.withOpacity(0.03), blurRadius: 12, offset: const Offset(0, 4)),
];
List<BoxShadow> kShadowLg = [
  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 50, spreadRadius: -4, offset: const Offset(0, 20)),
  BoxShadow(color: kGoldDark.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
];
List<BoxShadow> kGoldShadow = [
  BoxShadow(color: kGold.withOpacity(0.45), blurRadius: 30, spreadRadius: -2, offset: const Offset(0, 10)),
  BoxShadow(color: kGoldDark.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
];

// Time-of-day greeting
String _greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good Morning';
  if (h < 17) return 'Good Afternoon';
  return 'Good Evening';
}
String _greetEmoji() {
  final h = DateTime.now().hour;
  if (h < 12) return '🌅';
  if (h < 17) return '☀️';
  return '🌙';
}

// Premium text style helper
TextStyle _inter(double size, FontWeight weight, Color color,
    {double? spacing, double? height, TextDecoration? decoration}) =>
    GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color,
        letterSpacing: spacing, height: height, decoration: decoration);

// ══════════════════════════════════════════════════════════════
// HOME PAGE
// ══════════════════════════════════════════════════════════════
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String name = "Trainer";
  String gym  = "My Gym";

  bool _drawerOpen = false;
  late AnimationController _drawerCtrl;
  late Animation<double>   _drawerAnim;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _drawerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _drawerAnim = CurvedAnimation(
        parent: _drawerCtrl, curve: Curves.easeOutExpo);
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name") ?? "Trainer";
      gym  = prefs.getString("gym")  ?? "Gym";
    });
  }

  void _openDrawer() {
    HapticFeedback.mediumImpact();
    setState(() => _drawerOpen = true);
    _drawerCtrl.forward();
  }

  void _closeDrawer() {
    _drawerCtrl.reverse().then((_) {
      if (mounted) setState(() => _drawerOpen = false);
    });
  }

  @override
  void dispose() {
    _drawerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: kBg,
        body: Stack(children: [
          // Elevated background texture
          Positioned.fill(
            child: CustomPaint(painter: _BackgroundPainter()),
          ),

          // ── Main scroll content ──
          CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              _buildHeader(),
              const SliverToBoxAdapter(child: AnalyticsCard()),
              const SliverToBoxAdapter(child: RevenueWithFeeTabsCard()),
              _buildGymStatsRow(),
              _buildRecentActivity(),
              const SliverToBoxAdapter(child: SizedBox(height: 130)),
            ],
          ),

          // ── Scrim ──
          if (_drawerOpen)
            AnimatedBuilder(
              animation: _drawerAnim,
              builder: (_, __) => GestureDetector(
                onTap: _closeDrawer,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5 * _drawerAnim.value, sigmaY: 5 * _drawerAnim.value),
                  child: Container(
                    color: Colors.black.withOpacity(0.35 * _drawerAnim.value),
                  ),
                ),
              ),
            ),

          // ── Ultra Premium Side Drawer ──
          if (_drawerOpen)
            AnimatedBuilder(
              animation: _drawerAnim,
              builder: (_, __) {
                final dx = -340.0 * (1 - _drawerAnim.value);
                return Positioned(
                  top: 0, bottom: 0, left: 0, width: 340,
                  child: Transform.translate(
                    offset: Offset(dx, 0),
                    child: _UltraPremiumDrawer(
                        name: name, gym: gym, onClose: _closeDrawer),
                  ),
                );
              },
            ),
        ]),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────
  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: (_drawerAnim.value * 12).clamp(0.0, 12.0),
            sigmaY: (_drawerAnim.value * 12).clamp(0.0, 12.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: kSurface.withOpacity(0.85),
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.8), width: 1.5)),
              boxShadow: [
                BoxShadow(color: kGold.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 10)),
                ...kShadowSm,
              ],
            ),
            padding: EdgeInsets.fromLTRB(
                24, MediaQuery.of(context).padding.top + 20, 24, 26),
            child: Row(children: [
              // ── Double-ring Gold Avatar ──
              GestureDetector(
                onTap: _openDrawer,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [Colors.white, kBorderSoft.withOpacity(0.5)]
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
                      ]
                  ),
                  child: Stack(children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kGold, kGoldGlow, Color(0xFFD8E840)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: kGoldShadow,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : "T",
                        style: _inter(24, FontWeight.w900, kGoldDark, spacing: -0.5),
                      ),
                    ),
                    // Online indicator
                    Positioned(
                      bottom: -2, right: -2,
                      child: Container(
                        width: 16, height: 16,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF66BB6A), Color(0xFF43A047)]),
                          shape: BoxShape.circle,
                          border: Border.all(color: kSurface, width: 3.0),
                          boxShadow: [BoxShadow(
                              color: const Color(0xFF4CAF50).withOpacity(0.5),
                              blurRadius: 10, spreadRadius: 2)],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(width: 20),

              // ── Title ──
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const _ShimmerBadge(),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Text("${_greetEmoji()} ", style: const TextStyle(fontSize: 18)),
                    Expanded(
                      child: Text(
                        "${_greeting()}, $name",
                        overflow: TextOverflow.ellipsis,
                        style: _inter(19, FontWeight.w900, kText1, spacing: -0.8, height: 1.1),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kGoldLight.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kGold.withOpacity(0.4)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.location_on_rounded, size: 12, color: kGoldDark),
                      const SizedBox(width: 4),
                      Text(gym, style: _inter(11, FontWeight.w800, kGoldDark, spacing: 0.2)),
                    ]),
                  ),
                ]),
              ),

              const SizedBox(width: 10),

              // ── Notification Bell ──
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AlertsScreen()));
                },
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white, width: 2), // Glass edge
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Stack(alignment: Alignment.center, children: [
                    const Icon(Icons.notifications_outlined, color: kText1, size: 24),
                    Positioned(
                      top: 12, right: 12,
                      child: _PulsingDot(
                        size: 10,
                        colors: const [kGold, kGoldGlow],
                        borderColor: kSurface,
                      ),
                    ),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Gym Stats Row ────────────────────────────────────────────
  Widget _buildGymStatsRow() {
    final stats = [
      _StatData(
        value: "40", label: "Total Members", color: kGoldDark,
        icon: Icons.group_rounded,
        barData: [0.45, 0.60, 0.52, 0.70, 0.65, 0.78, 0.82],
        barColor: kGoldDark, barTrack: kGoldLight,
        trend: "+5%", trendUp: true,
        chartType: _ChartType.sparkline,
        page: const MembersListScreen(showActive: true),
      ),
      _StatData(
        value: "₹25K", label: "Total Revenue", color: kGoldDark,
        icon: Icons.currency_rupee_rounded,
        barData: [0.40, 0.55, 0.50, 0.65, 0.60, 0.75, 0.80],
        barColor: kGoldDark, barTrack: kGoldLight,
        trend: "+12%", trendUp: true,
        chartType: _ChartType.sparkline,
        page: const _GymStatDetail(
          title: "Total Revenue", value: "₹25K",
          icon: Icons.currency_rupee_rounded, color: kGoldDark,
          items: ["Ravi Menon – ₹2500", "Priya Nair – ₹1500",
            "Sneha Ramesh – ₹800", "Mohammed F – ₹2500", "Kiran Thomas – ₹800"],
        ),
      ),
      _StatData(
        value: "142", label: "Users",
        color: kBlue,
        icon: Icons.people_alt_rounded,
        barData: [0.30, 0.45, 0.60, 0.50, 0.65, 0.70, 0.68],
        barColor: kBlue, barTrack: kBlueLight,
        trend: "+8%", trendUp: true,
        chartType: _ChartType.donut,
        donutSegments: [
          _DonutSegment("Active",   0.56, kBlue),
          _DonutSegment("New",      0.30, const Color(0xFF42A5F5)),
          _DonutSegment("Inactive", 0.14, const Color(0xFFBBDEFB)),
        ],
        page: const _GymStatDetail(
          title: "Users", value: "142",
          icon: Icons.people_alt_rounded, color: kBlue,
          items: ["Active Users – 80", "New Users – 43", "Inactive Users – 19"],
        ),
      ),
      _StatData(
        value: "30", label: "Active Members",
        color: kGreen,
        icon: Icons.verified_rounded,
        barData: [0.50, 0.55, 0.58, 0.62, 0.65, 0.72, 0.78],
        barColor: kGreenSoft, barTrack: kGreenLight,
        trend: "+10%", trendUp: true,
        chartType: _ChartType.sparkline,
        page: const MembersListScreen(showActive: true),
      ),
      _StatData(
        value: "10", label: "Inactive Members",
        color: kRed,
        icon: Icons.person_off_rounded,
        barData: [0.60, 0.55, 0.50, 0.45, 0.40, 0.38, 0.35],
        barColor: const Color(0xFFEF5350), barTrack: kRedLight,
        trend: "-5%", trendUp: false,
        chartType: _ChartType.sparkline,
        page: const MembersListScreen(showActive: false),
      ),
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _PremiumSectionLabel(
            title: "Gym Overview",
            subtitle: "Live performance metrics",
            icon: Icons.analytics_rounded,
          ),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width > 600 ? 3 : 2;
            final itemWidth =
                (width - (16.0 * (crossAxisCount - 1))) / crossAxisCount;
            return Wrap(
              spacing: 16, runSpacing: 16,
              children: stats
                  .map((s) => SizedBox(width: itemWidth,
                  child: _TappableStatPill(data: s)))
                  .toList(),
            );
          }),
        ]),
      ),
    );
  }

  // ── Recent Activity ──────────────────────────────────────────
  Widget _buildRecentActivity() {
    final items = [
      _ActivityData("Ravi Menon joined",  "2 mins ago · Gold Plan",
          "+₹2500", kGoldDark, kGold, Icons.person_add_rounded),
      _ActivityData("Priya Nair renewed", "1 hr ago · Silver Plan",
          "+₹1500", kText1, kText2, Icons.autorenew_rounded),
      _ActivityData("Equipment alert",    "3 hrs ago · Treadmill #2",
          "Check", kOrange, kAmber, Icons.warning_amber_rounded),
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _PremiumSectionLabel(
            title: "Recent Activity",
            subtitle: "Latest updates",
            icon: Icons.history_rounded,
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white, width: 2), // Glass edge
              boxShadow: kShadowMd,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Column(
                children: items.asMap().entries.map((e) {
                  final isLast = e.key == items.length - 1;
                  final isFirst = e.key == 0;
                  final d = e.value;
                  return _ActivityTile(data: d, isLast: isLast, isFirst: isFirst);
                }).toList(),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Activity tile ────────────────────────────────────────────
class _ActivityTile extends StatefulWidget {
  final _ActivityData data;
  final bool isLast;
  final bool isFirst;
  const _ActivityTile({required this.data, required this.isLast, this.isFirst = false});
  @override
  State<_ActivityTile> createState() => _ActivityTileState();
}

class _ActivityTileState extends State<_ActivityTile> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return GestureDetector(
      onTapDown: (_) => setState(() => _hovered = true),
      onTapUp: (_) => setState(() => _hovered = false),
      onTapCancel: () => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        color: _hovered ? kGoldLight.withOpacity(0.5) : Colors.transparent,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: IntrinsicHeight(
              child: Row(children: [
                // Timeline connector
                SizedBox(
                  width: 20,
                  child: Column(children: [
                    if (!widget.isFirst)
                      Container(width: 2, height: 10, decoration: BoxDecoration(color: kGold.withOpacity(0.4), borderRadius: BorderRadius.circular(1))),
                    Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [d.dot, d.dot.withOpacity(0.7)]),
                        shape: BoxShape.circle,
                        border: Border.all(color: kSurface, width: 2),
                        boxShadow: [BoxShadow(
                            color: d.dot.withOpacity(0.4), blurRadius: 8)],
                      ),
                    ),
                    if (!widget.isLast)
                      Expanded(child: Container(
                          width: 2, decoration: BoxDecoration(color: kGold.withOpacity(0.2), borderRadius: BorderRadius.circular(1)))),
                  ]),
                ),
                const SizedBox(width: 16),
                // Icon
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [d.dot.withOpacity(0.15), d.dot.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: d.dot.withOpacity(0.2)),
                    boxShadow: [BoxShadow(
                        color: d.dot.withOpacity(0.08), blurRadius: 10,
                        offset: const Offset(0, 4))],
                  ),
                  child: Icon(d.icon, color: d.dot, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(d.title, style: _inter(14.5, FontWeight.w800, kText1, spacing: -0.3)),
                      const SizedBox(height: 4),
                      Text(d.subtitle, style: _inter(11.5, FontWeight.w600, kText3)),
                    ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [d.valueColor.withOpacity(0.15), d.valueColor.withOpacity(0.05)]),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: d.valueColor.withOpacity(0.2)),
                  ),
                  child: Text(d.value, style: _inter(13, FontWeight.w800, d.valueColor, spacing: -0.2)),
                ),
              ]),
            ),
          ),
          if (!widget.isLast)
            Padding(
              padding: const EdgeInsets.only(left: 76),
              child: Divider(color: kBorderSoft, height: 1, thickness: 1),
            ),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// BACKGROUND PAINTER — Ultra Premium Mesh Grid
// ══════════════════════════════════════════════════════════════
class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Ambient radial glow top-left (warm gold)
    final goldGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.8, -0.6),
        radius: 1.4,
        colors: [kGold.withOpacity(0.09), kGold.withOpacity(0.03), Colors.transparent],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), goldGlow);

    // Ambient radial glow bottom-right (warm)
    final warmGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.9, 0.8),
        radius: 1.2,
        colors: [kGoldGlow.withOpacity(0.07), kGoldLight.withOpacity(0.03), Colors.transparent],
        stops: const [0.0, 0.35, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), warmGlow);

    // Subtle dot grid (refined for ultra premium)
    final dotPaint = Paint()
      ..color = const Color(0xFFD8D8CC).withOpacity(0.28)
      ..style = PaintingStyle.fill;
    const spacing = 36.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }
  @override
  bool shouldRepaint(_BackgroundPainter old) => false;
}

// ══════════════════════════════════════════════════════════════
// SECTION LABEL — Ultra Premium version
// ══════════════════════════════════════════════════════════════
class _PremiumSectionLabel extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  const _PremiumSectionLabel({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kGold, kGoldGlow, Color(0xFFD8E840)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
          boxShadow: [
            BoxShadow(color: kGold.withOpacity(0.5), blurRadius: 18, offset: const Offset(0, 6)),
            BoxShadow(color: kGoldGlow.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Icon(icon, color: kGoldDark, size: 20),
      ),
      const SizedBox(width: 16),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: _inter(18, FontWeight.w900, kText1, spacing: -0.6)),
        const SizedBox(height: 2),
        Text(subtitle, style: _inter(11, FontWeight.w600, kText2, spacing: 0.3)),
      ]),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: kGoldLight.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kGold.withOpacity(0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(
            color: kGoldDark, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: kGoldDark.withOpacity(0.5), blurRadius: 6)],
          )),
          const SizedBox(width: 6),
          Text("LIVE", style: _inter(8, FontWeight.w900, kGoldDark, spacing: 1.2)),
        ]),
      ),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════
// ULTRA PREMIUM DRAWER
// ══════════════════════════════════════════════════════════════
class _UltraPremiumDrawer extends StatefulWidget {
  final String name, gym;
  final VoidCallback onClose;
  const _UltraPremiumDrawer(
      {required this.name, required this.gym, required this.onClose});
  @override
  State<_UltraPremiumDrawer> createState() => _UltraPremiumDrawerState();
}

class _UltraPremiumDrawerState extends State<_UltraPremiumDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _stagger;

  @override
  void initState() {
    super.initState();
    _stagger = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _stagger.forward();
  }

  @override
  void dispose() { _stagger.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final topPadding    = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final sections = [
      _DrawerSection("MAIN", [
        _NavItem(Icons.home_rounded,              "Dashboard",  true,  null),
        _NavItem(Icons.people_rounded,            "Members",    false,
            const MembersListScreen(showActive: true)),
        _NavItem(Icons.fitness_center_rounded,    "Equipment",  false,
            const EquipmentScreen()),
        _NavItem(Icons.workspace_premium_rounded, "Plans",      false,
            const PackagesScreen()),
        _NavItem(Icons.payment_rounded,           "Payments",   false,
            const AddPaymentScreen()),
        _NavItem(Icons.play_circle_rounded,       "Videos",     false,
            const VideosScreen()),
      ]),
      _DrawerSection("ACCOUNTS", [
        _NavItem(Icons.menu_book_rounded,         "Day Book",   false,
            const DaybookScreen()),
        _NavItem(Icons.account_balance_rounded,   "Ledger",     false,
            const LedgerScreen()),
        _NavItem(Icons.bar_chart_rounded,         "P & L",      false,
            const PnlScreen()),
      ]),
      _DrawerSection("OTHER", [
        _NavItem(Icons.notifications_outlined,    "Alerts",     false,
            const AlertsScreen()),
      ]),
    ];

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight:    Radius.circular(48),
          bottomRight: Radius.circular(48),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 340,
            decoration: BoxDecoration(
              color: kSurface.withOpacity(0.95),
              borderRadius: const BorderRadius.only(
                topRight:    Radius.circular(48),
                bottomRight: Radius.circular(48),
              ),
              border: Border(right: BorderSide(color: Colors.white.withOpacity(0.8), width: 1.5)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.15),
                    blurRadius: 60, spreadRadius: -5, offset: const Offset(20, 0)),
              ],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Gradient Header ──────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(26, topPadding + 28, 26, 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kGold, kGoldGlow, Color(0xFFD4E840)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(topRight: Radius.circular(44)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    // Avatar with ring
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
                        boxShadow: [BoxShadow(
                            color: kGoldDark.withOpacity(0.4),
                            blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget.name.isNotEmpty ? widget.name[0].toUpperCase() : "T",
                          style: _inter(28, FontWeight.w900, kGoldDark, spacing: -0.5),
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: widget.onClose,
                      child: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.6)),
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: kGoldDark, size: 20),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  Text(widget.name,
                      style: _inter(24, FontWeight.w900, kText1, spacing: -0.8)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(children: [
                        const Icon(Icons.location_on_rounded,
                            size: 12, color: kGoldDark),
                        const SizedBox(width: 4),
                        Text(widget.gym, style: _inter(12, FontWeight.w800, kGoldDark)),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: kGoldDark,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(
                            color: kGoldDark.withOpacity(0.5), blurRadius: 10)],
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.workspace_premium_rounded,
                            color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text("TRAINER PRO",
                            style: _inter(10, FontWeight.w900, Colors.white, spacing: 0.8)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 22),
                  // Stats row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                      boxShadow: [BoxShadow(
                          color: kGoldDark.withOpacity(0.15),
                          blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: Row(children: [
                      _DrawerStat("40",   "Members"),
                      _DrawerDivider(),
                      _DrawerStat("₹25K", "Revenue"),
                      _DrawerDivider(),
                      _DrawerStat("30",   "Active"),
                    ]),
                  ),
                ]),
              ),

              // ── Nav sections ─────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: sections.asMap().entries.map((entry) {
                      final si  = entry.key;
                      final sec = entry.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (si > 0) const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 0, 10),
                            child: Row(children: [
                              Container(width: 18, height: 2, decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(1))),
                              const SizedBox(width: 8),
                              Text(sec.title,
                                  style: const TextStyle(color: kText2, fontSize: 10,
                                      fontWeight: FontWeight.w900, letterSpacing: 2.2)),
                            ]),
                          ),
                          ...sec.items.asMap().entries.map((e) {
                            final globalIdx = sections
                                .take(si)
                                .fold(0, (sum, s) => sum + s.items.length) + e.key;
                            return _UltraNavTile(
                              item: e.value,
                              index: globalIdx,
                              staggerAnim: _stagger,
                              onClose: widget.onClose,
                            );
                          }),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),

              // ── Footer ───────────────────────────────────────────
              Container(
                padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 24),
                decoration: const BoxDecoration(
                  color: kBgWarm,
                  border: Border(top: BorderSide(color: kBorderSoft, width: 1.5)),
                ),
                child: GestureDetector(
                  onTap: () { HapticFeedback.lightImpact(); widget.onClose(); },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: kRedLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kRed.withOpacity(0.25), width: 1.5),
                      boxShadow: [BoxShadow(
                          color: kRed.withOpacity(0.1),
                          blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: kRed.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.logout_rounded, color: kRed, size: 20),
                      ),
                      const SizedBox(width: 14),
                      const Text("Log Out", style: TextStyle(color: kRed,
                          fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: kRed),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Drawer helpers ──────────────────────────────────────────────
class _DrawerSection {
  final String title;
  final List<_NavItem> items;
  const _DrawerSection(this.title, this.items);
}

class _DrawerStat extends StatelessWidget {
  final String value, label;
  const _DrawerStat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: _inter(18, FontWeight.w900, kText1, spacing: -0.6)),
    const SizedBox(height: 4),
    Text(label, style: _inter(10, FontWeight.w800, kGoldDark, spacing: 0.5)),
  ]));
}

class _DrawerDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1.5, height: 36, color: Colors.white.withOpacity(0.5));
}

class _NavItem {
  final IconData icon;
  final String   label;
  final bool     isActive;
  final Widget?  page;
  const _NavItem(this.icon, this.label, this.isActive, this.page);
}

class _UltraNavTile extends StatefulWidget {
  final _NavItem            item;
  final int                 index;
  final AnimationController staggerAnim;
  final VoidCallback        onClose;
  const _UltraNavTile({
    required this.item, required this.index,
    required this.staggerAnim, required this.onClose,
  });
  @override
  State<_UltraNavTile> createState() => _UltraNavTileState();
}

class _UltraNavTileState extends State<_UltraNavTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final active   = widget.item.isActive;
    final delay    = (widget.index * 0.06).clamp(0.0, 0.6);
    final interval = Interval(delay, (delay + 0.4).clamp(0.0, 1.0),
        curve: Curves.easeOutCubic);
    final slideAnim = Tween<Offset>(
        begin: const Offset(-0.4, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: widget.staggerAnim, curve: interval));
    final fadeAnim  = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: widget.staggerAnim, curve: interval));

    return SlideTransition(
      position: slideAnim,
      child: FadeTransition(
        opacity: fadeAnim,
        child: GestureDetector(
          onTapDown: (_) { HapticFeedback.lightImpact(); setState(() => _pressed = true); },
          onTapUp: (_) {
            setState(() => _pressed = false);
            if (widget.item.page != null) {
              widget.onClose();
              Future.delayed(const Duration(milliseconds: 280), () {
                if (context.mounted) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => widget.item.page!));
                }
              });
            }
          },
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              gradient: active ? const LinearGradient(
                colors: [kGoldLight, Color(0xFFEDF5A0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ) : null,
              color: active ? null : (_pressed ? kGoldLight.withOpacity(0.6) : Colors.transparent),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: active ? kGold : (_pressed ? kGold.withOpacity(0.3) : Colors.transparent), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: active
                      ? kGold.withOpacity(0.25)
                      : Colors.transparent,
                  blurRadius: active ? 14 : 0.01,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 42, height: 42,
                decoration: BoxDecoration(
                  gradient: active ? const LinearGradient(
                    colors: [kGold, kGoldGlow],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ) : null,
                  color: active ? null : kSurface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: active ? Colors.white.withOpacity(0.8) : kBorder,
                      width: 1.5),
                  boxShadow: active ? [BoxShadow(
                      color: kGold.withOpacity(0.6), blurRadius: 10,
                      offset: const Offset(0, 4))] : [],
                ),
                child: Icon(widget.item.icon,
                    color: active ? kGoldDark : kText3, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(widget.item.label,
                  style: TextStyle(
                    color: active ? kGoldDark : kText1, fontSize: 14.5,
                    fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                    letterSpacing: -0.3,
                  ))),
              if (active)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kGoldDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text("NOW",
                      style: TextStyle(color: Colors.white, fontSize: 9,
                          fontWeight: FontWeight.w900, letterSpacing: 0.8)),
                )
              else
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: kSurface2,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kBorder),
                  ),
                  child: const Icon(Icons.chevron_right_rounded,
                      size: 18, color: kText2),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// REVENUE WITH FEE TABS CARD
// ══════════════════════════════════════════════════════════════
class RevenueWithFeeTabsCard extends StatefulWidget {
  const RevenueWithFeeTabsCard({super.key});
  @override
  State<RevenueWithFeeTabsCard> createState() => _RevenueWithFeeTabsCardState();
}

class _RevenueWithFeeTabsCardState extends State<RevenueWithFeeTabsCard>
    with SingleTickerProviderStateMixin {

  late AnimationController _barCtrl;
  late Animation<double>   _barAnim;

  int _feeIndex    = 1;
  int _periodIndex = 1;
  int _selectedBar = 4;

  final List<String> _periods   = ["Today", "Week", "Month"];
  final List<String> _dayLabels = ["M", "T", "W", "T", "F", "S", "S"];

  final Map<int, Map<int, List<double>>> _actual = {
    0: { 0: [200,350,500,300,600,450,250], 1: [1500,2200,3500,1900,4200,1500,1100], 2: [6500,7800,10500,5200,8900,6100,4300] },
    1: { 0: [800,1200,1800,1400,2200,1600,900], 1: [8000,12000,18500,9000,21000,8000,5500], 2: [28000,35000,52000,25000,45000,32000,21000] },
    2: { 0: [500,800,1200,900,1500,1100,600], 1: [5000,6000,9000,5500,11000,4000,2800], 2: [18000,22000,31000,15000,27000,19000,12000] },
    3: { 0: [300,500,800,600,1200,900,400], 1: [3500,4500,7000,4000,9000,3000,2200], 2: [12000,18000,21000,11000,22000,14000,8000] },
  };
  final Map<int, Map<int, List<double>>> _target = {
    0: { 0: [250,400,550,350,650,500,300], 1: [1800,2500,4000,2200,4600,1700,1300], 2: [7000,8500,11500,5800,9500,6600,4800] },
    1: { 0: [900,1400,2000,1600,2400,1800,1000], 1: [9000,13000,20000,10000,23000,9000,6000], 2: [30000,38000,56000,27000,48000,35000,23000] },
    2: { 0: [600,900,1400,1000,1700,1200,700], 1: [5500,6800,10000,6200,12000,4500,3200], 2: [20000,24000,34000,17000,29000,21000,13500] },
    3: { 0: [350,600,900,700,1300,1000,500], 1: [4000,5000,8000,4500,9800,3500,2600], 2: [13000,20000,23000,12500,24000,15500,9000] },
  };

  static const _feeTypes = [
    _FeeTab(id: 0, label: "Registration", shortLabel: "REG",
        icon: Icons.app_registration_rounded,
        color: kTeal, bg: kTealLight,
        track: Color(0xFFA7FFEB), glow: Color(0xFF00BFA5)),
    _FeeTab(id: 1, label: "Monthly", shortLabel: "MON",
        icon: Icons.calendar_month_rounded,
        color: kGoldDark, bg: kGoldLight,
        track: Color(0xFFEEF4B0), glow: kGold),
    _FeeTab(id: 2, label: "Half Yearly", shortLabel: "6M",
        icon: Icons.event_repeat_rounded,
        color: kBlue, bg: kBlueLight,
        track: Color(0xFFBBDEFB), glow: Color(0xFF42A5F5)),
    _FeeTab(id: 3, label: "Yearly", shortLabel: "YR",
        icon: Icons.workspace_premium_rounded,
        color: kPurple, bg: kPurpleLight,
        track: Color(0xFFE1BEE7), glow: Color(0xFFAB47BC)),
  ];

  List<double> get _curActual => _actual[_feeIndex]![_periodIndex]!;
  List<double> get _curTarget => _target[_feeIndex]![_periodIndex]!;
  double get _maxValue => [..._curActual, ..._curTarget].reduce(math.max);
  _FeeTab get _selFee => _feeTypes[_feeIndex];

  String _fmt(double v) {
    if (v >= 100000) return "₹${(v / 100000).toStringAsFixed(1)}L";
    if (v >= 1000)   return "₹${(v / 1000).toStringAsFixed(1)}K";
    return "₹${v.toInt()}";
  }

  String _fmtShort(double v) {
    if (v >= 100000) return "${(v / 100000).toStringAsFixed(1)}L";
    if (v >= 1000)   return "${(v / 1000).toStringAsFixed(1)}K";
    return "${v.toInt()}";
  }

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 950));
    _barAnim = CurvedAnimation(parent: _barCtrl, curve: Curves.easeOutQuart);
    _barCtrl.forward();
    _selectedBar = _curActual.indexOf(_curActual.reduce(math.max));
  }

  void _switchFee(int i) {
    if (i == _feeIndex) return;
    HapticFeedback.selectionClick();
    setState(() {
      _feeIndex = i;
      _selectedBar = _curActual.indexOf(_curActual.reduce(math.max));
    });
    _barCtrl.forward(from: 0);
  }

  void _switchPeriod(int i) {
    if (i == _periodIndex) return;
    HapticFeedback.selectionClick();
    setState(() {
      _periodIndex = i;
      _selectedBar = _curActual.indexOf(_curActual.reduce(math.max));
    });
    _barCtrl.forward(from: 0);
  }

  @override
  void dispose() { _barCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final fee   = _selFee;
    final total = _curActual.reduce((a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white, width: 2), // Glass edge
          boxShadow: kShadowLg,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Colored top band ────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [fee.color, fee.glow.withOpacity(0.65), fee.bg.withOpacity(0.95)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(color: fee.color.withOpacity(0.25), blurRadius: 24,
                    offset: const Offset(0, 10)),
              ],
            ),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("REVENUE",
                    style: _inter(10, FontWeight.w900, Colors.white70, spacing: 2.5)),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  child: Text(_fmt(total),
                      key: ValueKey('total-$_feeIndex-$_periodIndex'),
                      style: _inter(34, FontWeight.w900, Colors.white, spacing: -1.5)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                  ),
                  child: Text(fee.label,
                      style: _inter(11, FontWeight.w800, Colors.white)),
                ),
              ]),
              const Spacer(),
              // Period selector
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(_periods.length, (i) {
                    final sel = _periodIndex == i;
                    return GestureDetector(
                      onTap: () => _switchPeriod(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: sel
                                    ? Colors.black.withOpacity(0.12)
                                    : Colors.transparent,
                                blurRadius: sel ? 8 : 0.01,
                                offset: Offset(0, sel ? 2 : 0)
                            ),
                          ],
                        ),
                        child: Text(_periods[i],
                            style: TextStyle(
                              color: sel ? fee.color : Colors.white,
                              fontSize: 11,
                              fontWeight: sel ? FontWeight.w900 : FontWeight.w700,
                            )),
                      ),
                    );
                  }),
                ),
              ),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // ── Fee Type Tabs ────────────────────────────────
              Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: kSurface2,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: kBorder),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10,
                          offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    children: List.generate(_feeTypes.length, (i) {
                      final ft = _feeTypes[i];
                      final isSel = _feeIndex == i;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _switchFee(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutBack,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: isSel
                                  ? LinearGradient(
                                colors: [ft.color, ft.glow.withOpacity(0.85)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )
                                  : null,
                              color: isSel ? null : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isSel
                                  ? [
                                BoxShadow(
                                  color: ft.glow.withOpacity(0.5),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: ft.color.withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                                  : [
                                BoxShadow(
                                  color: Colors.transparent,
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: Colors.transparent,
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  ft.icon,
                                  size: 22,
                                  color: isSel ? Colors.white : ft.color,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  ft.shortLabel,
                                  style: _inter(
                                    10,
                                    FontWeight.w900,
                                    isSel ? Colors.white : ft.color,
                                    spacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  )),

              const SizedBox(height: 20),

              // ── Mini Stats Row ───────────────────────────────
              Row(children: [
                _MiniChip(
                    label: "Peak",
                    value: _fmt(_curActual.reduce(math.max)),
                    color: fee.color),
                const SizedBox(width: 10),
                _MiniChip(
                    label: "Avg",
                    value: _fmt(_curActual.reduce((a, b) => a + b) / _curActual.length),
                    color: fee.glow.withOpacity(0.8) == Colors.transparent
                        ? fee.color : fee.glow),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: fee.bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: fee.color.withOpacity(0.3), width: 1.5),
                  ),
                  child: Text(
                    "${_curActual.last > _curActual.first ? (((_curActual.last - _curActual.first) / _curActual.first) * 100).toStringAsFixed(0) : '0'}% trend",
                    style: TextStyle(color: fee.color, fontSize: 11,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ]),

              const SizedBox(height: 20),

              // ── Legend ───────────────────────────────────────
              Row(children: [
                _LegendDot(color: fee.track, label: "Target"),
                const SizedBox(width: 16),
                _LegendDot(color: fee.color, label: "Actual"),
                const SizedBox(width: 16),
                _LegendLine(color: fee.glow, label: "Trend"),
              ]),

              const SizedBox(height: 24),

              // ── Bar Chart ────────────────────────────────────
              AnimatedBuilder(
                animation: _barAnim,
                builder: (_, __) => _buildChart(),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildChart() {
    final actual = _curActual;
    final target = _curTarget;
    final maxV   = _maxValue;
    final fee    = _selFee;

    return LayoutBuilder(builder: (ctx, constraints) {
      const chartH    = 165.0;
      const tooltipH  = 52.0;
      const dayLabelH = 32.0;
      const groupGap  = 8.0;
      const barPad    = 3.0;
      final n         = actual.length;
      final totalW    = constraints.maxWidth;
      final groupW    = (totalW - groupGap * (n - 1)) / n;
      final barW      = (totalW / n - 8) / 2;

      final trendPts = List.generate(n, (i) {
        final gx   = i * (groupW + groupGap);
        final cx   = gx + barW + barPad / 2 + barW / 2;
        final frac = (actual[i] / maxV).clamp(0.0, 1.0) * _barAnim.value;
        return Offset(cx, chartH - frac * chartH);
      });

      return SizedBox(
        height: tooltipH + chartH + dayLabelH,
        child: Stack(children: [
          // ── Bars ──
          Positioned(
            top: tooltipH, left: 0, right: 0,
            child: SizedBox(
              height: chartH,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(n, (i) {
                  final isSel      = i == _selectedBar;
                  final actualFrac = (actual[i] / maxV).clamp(0.0, 1.0) * _barAnim.value;
                  final targetFrac = (target[i] / maxV).clamp(0.0, 1.0) * _barAnim.value;
                  final actualH    = math.max(actualFrac * chartH, 6.0);
                  final targetH    = math.max(targetFrac * chartH, 6.0);

                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedBar = i);
                      },
                      child: SizedBox(
                        height: chartH,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      height: targetH,
                                      decoration: BoxDecoration(
                                        color: fee.track,
                                        borderRadius: BorderRadius.circular(barW / 2 + 2),
                                      ),
                                    ),
                                  ])),
                              const SizedBox(width: barPad),
                              Expanded(child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      height: actualH,
                                      decoration: BoxDecoration(
                                        gradient: isSel ? LinearGradient(
                                          colors: [fee.glow, fee.color],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ) : null,
                                        color: isSel ? null : fee.color.withOpacity(0.35),
                                        borderRadius: BorderRadius.circular(barW / 2 + 2),
                                        border: isSel ? Border.all(color: Colors.white.withOpacity(0.6), width: 1) : null,
                                        boxShadow: [
                                          BoxShadow(
                                            color: isSel
                                                ? _selFee.glow.withOpacity(0.5)
                                                : Colors.transparent,
                                            blurRadius: isSel ? 16 : 0.01,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ])),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // ── Trend line ──
          if (_barAnim.value > 0.3)
            Positioned(
              top: tooltipH, left: 0, right: 0,
              child: SizedBox(
                height: chartH,
                child: CustomPaint(
                  painter: _TrendLinePainter(
                      points: trendPts,
                      color: fee.glow,
                      progress: _barAnim.value),
                ),
              ),
            ),

          // ── Tooltip ──
          if (_barAnim.value > 0.5)
            _buildTooltip(
              index: _selectedBar,
              actual: actual[_selectedBar],
              target: target[_selectedBar],
              chartH: chartH,
              tooltipZone: tooltipH,
              groupW: groupW,
              groupGap: groupGap,
              maxV: maxV,
              totalW: totalW,
            ),

          // ── Day labels ──
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Row(
              children: List.generate(n, (i) {
                final isSel = i == _selectedBar;
                return Expanded(
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSel ? 24 : 0,
                      height: isSel ? 24 : 0,
                      decoration: isSel ? BoxDecoration(
                        color: _selFee.color,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: _selFee.color.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2))],
                      ) : null,
                      child: Center(
                        child: Text(
                          _dayLabels[i],
                          style: TextStyle(
                            color: isSel ? Colors.white : kText2,
                            fontSize: 10,
                            fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ]),
      );
    });
  }

  Widget _buildTooltip({
    required int index,
    required double actual,
    required double target,
    required double chartH,
    required double tooltipZone,
    required double groupW,
    required double groupGap,
    required double maxV,
    required double totalW,
  }) {
    final fee  = _selFee;
    final frac = (actual / maxV).clamp(0.0, 1.0) * _barAnim.value;
    final barH = frac * chartH;
    final barTop = tooltipZone + (chartH - barH);

    double xCenter = 0;
    for (int i = 0; i < index; i++) xCenter += groupW + groupGap;
    xCenter += groupW / 2;

    const tipMaxW = 115.0;
    const tipArrow = 8.0;
    const tipH    = 56.0;
    final double leftRaw = xCenter - tipMaxW / 2;
    final double left    = leftRaw.clamp(0.0, totalW - tipMaxW);

    final diff    = actual - target;
    final diffPos = diff >= 0;
    final diffTxt = diffPos ? "▲ ${_fmtShort(diff)}" : "▼ ${_fmtShort(diff.abs())}";

    return Positioned(
      top: barTop - tipH - tipArrow - 8,
      left: left,
      width: tipMaxW,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: tipMaxW,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [fee.color, fee.glow.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            boxShadow: [BoxShadow(
                color: fee.glow.withOpacity(0.5),
                blurRadius: 16,
                offset: const Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _fmt(actual),
                style: const TextStyle(
                    color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.w900, letterSpacing: -0.5),
              ),
              const SizedBox(height: 4),
              Row(children: [
                Flexible(
                  child: Text(
                    "T:${_fmtShort(target)}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  diffTxt,
                  style: TextStyle(
                    color: diffPos ? const Color(0xFFB9F6CA) : const Color(0xFFFFCDD2),
                    fontSize: 10, fontWeight: FontWeight.w900,
                  ),
                ),
              ]),
            ],
          ),
        ),
        Center(
          child: CustomPaint(
            size: const Size(14, tipArrow),
            painter: _TooltipArrowPainter(color: fee.color),
          ),
        ),
      ]),
    );
  }
}

// ── Fee tab model ─────────────────────────────────────────────
class _FeeTab {
  final int     id;
  final String  label, shortLabel;
  final IconData icon;
  final Color   color, bg, track, glow;
  const _FeeTab({
    required this.id, required this.label,
    required this.shortLabel, required this.icon,
    required this.color, required this.bg,
    required this.track, required this.glow,
  });
}

// ── Trend line painter ────────────────────────────────────────
class _TrendLinePainter extends CustomPainter {
  final List<Offset> points;
  final Color        color;
  final double       progress;
  const _TrendLinePainter(
      {required this.points, required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color       = color
      ..strokeWidth = 3.0
      ..style       = PaintingStyle.stroke
      ..strokeCap   = StrokeCap.round
      ..strokeJoin  = StrokeJoin.round;

    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final cp1 = Offset((points[i].dx + points[i+1].dx) / 2, points[i].dy);
      final cp2 = Offset((points[i].dx + points[i+1].dx) / 2, points[i+1].dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i+1].dx, points[i+1].dy);
    }

    // Draw drop shadow for the path
    canvas.drawPath(path.shift(const Offset(0, 4)), Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

    final metrics = path.computeMetrics().first;
    canvas.drawPath(metrics.extractPath(0, metrics.length * progress), paint);

    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < points.length; i++) {
      if (i / (points.length - 1) > progress) break;
      dotPaint.color = color;
      canvas.drawCircle(points[i], 4.5, dotPaint);
      canvas.drawCircle(points[i], 4.5,
          Paint()..color = Colors.white ..style = PaintingStyle.stroke ..strokeWidth = 2.0);
    }
  }

  @override
  bool shouldRepaint(_TrendLinePainter old) =>
      old.progress != progress || old.color != color;
}

// ── Tooltip arrow painter ─────────────────────────────────────
class _TooltipArrowPainter extends CustomPainter {
  final Color color;
  const _TooltipArrowPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()..moveTo(0, 0)..lineTo(size.width, 0)..lineTo(size.width / 2, size.height)..close(),
      Paint()..color = color,
    );
  }
  @override
  bool shouldRepaint(_TooltipArrowPainter old) => old.color != color;
}

// ── Legend helpers ────────────────────────────────────────────
class _LegendDot extends StatelessWidget {
  final Color color; final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 12, height: 12, decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(4))),
    const SizedBox(width: 6),
    Text(label, style: _inter(11, FontWeight.w700, kText2)),
  ]);
}

class _LegendLine extends StatelessWidget {
  final Color color; final String label;
  const _LegendLine({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 18, height: 3.0, decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(2))),
    const SizedBox(width: 6),
    Text(label, style: _inter(11, FontWeight.w700, kText2)),
  ]);
}

class _MiniChip extends StatelessWidget {
  final String label, value; final Color color;
  const _MiniChip({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(label, style: TextStyle(color: color.withOpacity(0.8),
          fontSize: 10, fontWeight: FontWeight.w700)),
      const SizedBox(width: 8),
      Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900)),
    ]),
  );
}

// ══════════════════════════════════════════════════════════════
// CHART TYPE + DONUT SEGMENT
// ══════════════════════════════════════════════════════════════
enum _ChartType { sparkline, donut }

class _DonutSegment {
  final String label; final double value; final Color color;
  const _DonutSegment(this.label, this.value, this.color);
}

// ══════════════════════════════════════════════════════════════
// STAT DATA MODEL
// ══════════════════════════════════════════════════════════════
class _StatData {
  final String value, label, trend;
  final Color  color, barColor, barTrack;
  final IconData icon;
  final List<double> barData;
  final bool   trendUp;
  final Widget page;
  final _ChartType chartType;
  final List<_DonutSegment> donutSegments;
  const _StatData({
    required this.value, required this.label, required this.color,
    required this.icon,  required this.barData, required this.barColor,
    required this.barTrack, required this.trend, required this.trendUp,
    required this.page,
    this.chartType = _ChartType.sparkline,
    this.donutSegments = const [],
  });
}

// ══════════════════════════════════════════════════════════════
// SPARKLINE PAINTER
// ══════════════════════════════════════════════════════════════
class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color lineColor, fillColor;
  final Animation<double> animation;
  _SparklinePainter({
    required this.data, required this.lineColor,
    required this.fillColor, required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;
    final n = data.length;
    final stepX = size.width / (n - 1);
    final progress = animation.value;
    final pts = List.generate(n, (i) =>
        Offset(i * stepX, size.height - (data[i] * size.height * progress)));

    final linePath = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 0; i < n - 1; i++) {
      final cp1 = Offset((pts[i].dx + pts[i+1].dx) / 2, pts[i].dy);
      final cp2 = Offset((pts[i].dx + pts[i+1].dx) / 2, pts[i+1].dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i+1].dx, pts[i+1].dy);
    }
    final fillPath = Path.from(linePath)
      ..lineTo(pts.last.dx, size.height)
      ..lineTo(pts.first.dx, size.height)..close();

    canvas.drawPath(fillPath, Paint()
      ..shader = LinearGradient(
          colors: [fillColor, fillColor.withOpacity(0.0)],
          begin: Alignment.topCenter, end: Alignment.bottomCenter)
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill);

    // Shadow under the sparkline
    canvas.drawPath(linePath.shift(const Offset(0, 4)), Paint()
      ..color = lineColor.withOpacity(0.2)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

    canvas.drawPath(linePath, Paint()
      ..color = lineColor ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round ..strokeJoin = StrokeJoin.round);

    canvas.drawCircle(pts.last, 4.5,
        Paint()..color = lineColor..style = PaintingStyle.fill);
    canvas.drawCircle(pts.last, 4.5,
        Paint()..color = Colors.white
          ..style = PaintingStyle.stroke ..strokeWidth = 2.0);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.animation.value != animation.value || old.lineColor != lineColor;
}

// ══════════════════════════════════════════════════════════════
// DONUT PAINTER
// ══════════════════════════════════════════════════════════════
class _DonutPainter extends CustomPainter {
  final List<_DonutSegment> segments;
  final Animation<double>   animation;
  _DonutPainter({required this.segments, required this.animation})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center   = Offset(size.width / 2, size.height / 2);
    final radius   = math.min(size.width, size.height) / 2 - 4;
    const stroke   = 12.0;
    const gapRad   = 3.0 * math.pi / 180;
    final progress = animation.value;

    canvas.drawCircle(center, radius, Paint()
      ..color = kBorderSoft ..strokeWidth = stroke
      ..style = PaintingStyle.stroke ..strokeCap = StrokeCap.round);

    double startAngle = -math.pi / 2;
    final totalSweep  = 2 * math.pi * progress;
    for (final seg in segments) {
      final sweep = totalSweep * seg.value - gapRad;
      if (sweep <= 0) { startAngle += totalSweep * seg.value; continue; }
      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle, sweep, false,
          Paint()..color = seg.color ..strokeWidth = stroke
            ..style = PaintingStyle.stroke ..strokeCap = StrokeCap.round);
      startAngle += totalSweep * seg.value;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.animation.value != animation.value;
}

// ══════════════════════════════════════════════════════════════
// TAPPABLE STAT PILL — Ultra Premium Inner Card
// ══════════════════════════════════════════════════════════════
class _TappableStatPill extends StatefulWidget {
  final _StatData data;
  const _TappableStatPill({super.key, required this.data});
  @override
  State<_TappableStatPill> createState() => _TappableStatPillState();
}

class _TappableStatPillState extends State<_TappableStatPill>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 140), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return GestureDetector(
      onTapDown: (_) { HapticFeedback.lightImpact(); setState(() => _pressed = true); },
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.push(context, MaterialPageRoute(builder: (_) => d.page));
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        transform: Matrix4.identity()..scale(_pressed ? 0.94 : 1.0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
              color: Colors.white,
              width: 2.0),
          boxShadow: _pressed ? kShadowSm : kShadowLg,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Top Row: Icon + Trend ──
            Row(children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [d.barTrack, d.barTrack.withOpacity(0.5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: d.barColor.withOpacity(0.2), width: 1.5),
                  boxShadow: [BoxShadow(
                      color: d.barColor.withOpacity(0.12), blurRadius: 10,
                      offset: const Offset(0, 4))],
                ),
                child: Icon(d.icon, color: d.barColor, size: 22),
              ),
              const Spacer(),
              _TrendBadge(trend: d.trend, trendUp: d.trendUp),
            ]),

            const SizedBox(height: 18),

            // ── Value ──
            Text(d.value,
                style: _inter(28, FontWeight.w900, d.color, spacing: -1.2, height: 1)),

            const SizedBox(height: 6),

            // ── Label ──
            Text(d.label.toUpperCase(),
                style: _inter(9, FontWeight.w800, kText2, spacing: 1.2)),

            const SizedBox(height: 18),

            // ── Inner Frosted Chart Area ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kSurface2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                children: [
                  if (d.chartType == _ChartType.sparkline)
                    SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _SparklinePainter(
                            data: d.barData,
                            lineColor: d.barColor,
                            fillColor: d.barColor.withOpacity(0.15),
                            animation: _anim),
                      ),
                    )
                  else
                    _buildDonutChart(d),

                  if (d.chartType == _ChartType.sparkline) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ["M","T","W","T","F","S","S"].map((l) =>
                          Expanded(child: Text(l,
                              textAlign: TextAlign.center,
                              style: _inter(9, FontWeight.w700, kText2)))).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildDonutChart(_StatData d) {
    return SizedBox(height: 76,
      child: Row(children: [
        SizedBox(width: 68, height: 68,
            child: Stack(alignment: Alignment.center, children: [
              CustomPaint(size: const Size(68, 68),
                  painter: _DonutPainter(segments: d.donutSegments, animation: _anim)),
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: d.barTrack,
                  shape: BoxShape.circle,
                ),
                child: Icon(d.icon, color: d.barColor, size: 16),
              ),
            ])),
        const SizedBox(width: 14),
        Expanded(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: d.donutSegments.map((seg) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Row(children: [
              Container(width: 8, height: 8,
                  decoration: BoxDecoration(
                      color: seg.color,
                      borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 6),
              Expanded(child: Text(seg.label, style: const TextStyle(
                  color: kText2, fontSize: 9, fontWeight: FontWeight.w700))),
              Text("${(seg.value * 100).toInt()}%",
                  style: TextStyle(color: seg.color, fontSize: 10,
                      fontWeight: FontWeight.w900)),
            ]),
          )).toList(),
        )),
      ]),
    );
  }
}

// ── Trend badge widget ────────────────────────────────────────
class _TrendBadge extends StatelessWidget {
  final String trend;
  final bool   trendUp;
  const _TrendBadge({required this.trend, required this.trendUp});
  @override
  Widget build(BuildContext context) {
    final color  = trendUp ? kGreen : kRed;
    final bgCol  = trendUp ? kGreenLight : kRedLight;
    final border = trendUp ? const Color(0xFFA5D6A7) : const Color(0xFFEF9A9A);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgCol, bgCol.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1),
        boxShadow: [BoxShadow(
            color: color.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(
          trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
          size: 14, color: color,
        ),
        const SizedBox(width: 4),
        Text(trend, style: _inter(10, FontWeight.w900, color)),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// GYM STAT DETAIL SCREEN — Premium
// ══════════════════════════════════════════════════════════════
class _GymStatDetail extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final List<String> items;
  const _GymStatDetail({
    required this.title, required this.value,
    required this.icon, required this.color, required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(children: [
        Container(
          color: kSurface,
          child: SafeArea(bottom: false, child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
            child: Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: kSurface2,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kBorder),
                    boxShadow: kShadowSm,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: kText1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title.toUpperCase(),
                    style: const TextStyle(color: kText2, fontSize: 10,
                        letterSpacing: 2.0, fontWeight: FontWeight.w800)),
                Text(title, style: const TextStyle(color: kText1, fontSize: 22,
                    fontWeight: FontWeight.w900, letterSpacing: -0.6)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kGold, kGoldGlow]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: kGoldShadow,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Row(children: [
                  Icon(icon, color: kGoldDark, size: 18),
                  const SizedBox(width: 8),
                  Text(value, style: const TextStyle(color: kGoldDark,
                      fontSize: 16, fontWeight: FontWeight.w900)),
                ]),
              ),
            ]),
          )),
        ),
        Container(height: 1.5, color: kBorderSoft),
        Expanded(child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) => Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: kShadowMd,
            ),
            child: Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(items[i],
                  style: const TextStyle(color: kText1,
                      fontSize: 14.5, fontWeight: FontWeight.w700))),
              const Icon(Icons.chevron_right_rounded, color: kText2, size: 20),
            ]),
          ),
        )),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ANALYTICS CARD — Ultra Premium
// ══════════════════════════════════════════════════════════════
class AnalyticsCard extends StatefulWidget {
  const AnalyticsCard({super.key});
  @override
  State<AnalyticsCard> createState() => _AnalyticsCardState();
}

class _AnalyticsCardState extends State<AnalyticsCard>
    with SingleTickerProviderStateMixin {
  final List<String> _periods = ["Today", "Week", "Month"];
  int _sel = 2;
  late TabController _tab;

  final Map<String, _PData> _data = {
    "Today": _PData(members: 8,   revenue: 4200,  visits: 34,  radius5km: 18,  total: 42),
    "Week":  _PData(members: 22,  revenue: 18500, visits: 210, radius5km: 110, total: 232),
    "Month": _PData(members: 120, revenue: 35000, visits: 700, radius5km: 380, total: 820),
  };
  final Map<String, _PData> _max = {
    "Today": _PData(members: 50,  revenue: 10000, visits: 100, radius5km: 50,  total: 160),
    "Week":  _PData(members: 60,  revenue: 30000, visits: 500, radius5km: 200, total: 560),
    "Month": _PData(members: 150, revenue: 50000, visits: 1000,radius5km: 500, total: 1200),
  };

  _PData get _cur  => _data[_periods[_sel]]!;
  _PData get _mCur => _max[_periods[_sel]]!;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _periods.length, vsync: this, initialIndex: _sel);
    _tab.addListener(() { if (!_tab.indexIsChanging) setState(() => _sel = _tab.index); });
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  String _fmtRevenue(int v) {
    if (v >= 100000) return "₹${(v / 100000).toStringAsFixed(1)}L";
    if (v >= 1000)   return "₹${(v / 1000).toStringAsFixed(0)}K";
    return "₹$v";
  }

  void _go(BuildContext ctx, Widget page) {
    HapticFeedback.lightImpact();
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final d    = _cur;
    final mx   = _mCur;
    final mPct = (d.members / mx.members).clamp(0.0, 1.0);
    final rPct = (d.revenue / mx.revenue).clamp(0.0, 1.0);
    final vPct = (d.visits  / mx.visits ).clamp(0.0, 1.0);
    final tPct = (d.total   / mx.total  ).clamp(0.0, 1.0);
    final period = _periods[_sel];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white, width: 2), // Glass Edge
          boxShadow: kShadowLg,
        ),
        child: Column(children: [

          // ── Header bar ─────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("ANALYTICS",
                    style: _inter(10, FontWeight.w900, kGoldDark, spacing: 2.5)),
                const SizedBox(height: 6),
                Text("Power Gym Analytics",
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: _inter(18, FontWeight.w900, kText1, spacing: -0.6)),
              ])),
              const SizedBox(width: 12),
              // Tab bar
              Container(
                height: 38,
                decoration: BoxDecoration(
                  color: kSurface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder),
                ),
                child: TabBar(
                  controller: _tab,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: const EdgeInsets.all(4),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(colors: [kGold, kGoldGlow]),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(
                        color: kGold.withOpacity(0.45), blurRadius: 10,
                        offset: const Offset(0, 3))],
                  ),
                  labelColor: kGoldDark,
                  unselectedLabelColor: kText2,
                  labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                  unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  dividerColor: Colors.transparent,
                  tabs: _periods.map((p) => Tab(text: p, height: 30)).toList(),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 26),

          // ── Radial indicators ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _TapRadial(value: mPct, useGold: true,
                  icon: Icons.people_outline, label: "Members",
                  onTap: () => _go(context, MembersDetailScreen(period: period))),
              _TapRadial(value: rPct, useGold: false,
                  icon: Icons.currency_rupee, label: "Revenue",
                  onTap: () => _go(context, RevenueDetailScreen(period: period))),
              _TapRadial(value: vPct, useGold: true,
                  icon: Icons.bar_chart_rounded, label: "Visits",
                  onTap: () => _go(context, VisitsDetailScreen(period: period))),
            ]),
          ),

          const SizedBox(height: 24),

          // ── Gold Summary Card ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kGoldLight, const Color(0xFFF0F8B0), kGoldLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: kGold.withOpacity(0.5), width: 1.5),
                boxShadow: [BoxShadow(
                    color: kGold.withOpacity(0.25),
                    blurRadius: 20, offset: const Offset(0, 6))],
              ),
              child: Column(children: [
                Row(children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [kGold, kGoldGlow]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(
                          color: kGold.withOpacity(0.45),
                          blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: const Icon(Icons.leaderboard_rounded,
                        color: kGoldDark, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text("TOTAL · ${_periods[_sel].toUpperCase()}",
                        style: const TextStyle(color: kGoldDark, fontSize: 10,
                            fontWeight: FontWeight.w900, letterSpacing: 1.8)),
                    const SizedBox(height: 6),
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(d.total.toString(),
                          style: const TextStyle(color: kText1, fontSize: 28,
                              fontWeight: FontWeight.w900, letterSpacing: -1.0)),
                      const SizedBox(width: 8),
                      const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text("activities",
                              style: TextStyle(color: kText2,
                                  fontSize: 12, fontWeight: FontWeight.w700))),
                    ]),
                  ])),
                  // Progress ring
                  Container(
                    width: 58, height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.6),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                          color: kGold.withOpacity(0.25), blurRadius: 10)],
                    ),
                    child: Stack(alignment: Alignment.center, children: [
                      SizedBox(width: 58, height: 58, child: _MiniRing(value: tPct)),
                      Text("${(tPct * 100).toInt()}%",
                          style: const TextStyle(color: kGoldDark, fontSize: 12,
                              fontWeight: FontWeight.w900)),
                    ]),
                  ),
                ]),

                const SizedBox(height: 18),
                Divider(color: kGold.withOpacity(0.4), height: 1, thickness: 1.5),
                const SizedBox(height: 18),

                // ── Two stat cards ──
                Row(children: [
                  Expanded(child: GestureDetector(
                    onTap: () => _go(context, VisitsDetailScreen(period: period)),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kGold.withOpacity(0.4), width: 1.5),
                        boxShadow: [BoxShadow(
                            color: kGold.withOpacity(0.15),
                            blurRadius: 10, offset: const Offset(0, 3))],
                      ),
                      child: Row(children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [kGoldLight, kGold]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.phone_android_rounded,
                              color: kGoldDark, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d.visits.toString(),
                                  style: const TextStyle(color: kText1,
                                      fontSize: 19, fontWeight: FontWeight.w900,
                                      letterSpacing: -0.6)),
                              const Text("Total Visits",
                                  style: TextStyle(color: kText2,
                                      fontSize: 10, fontWeight: FontWeight.w700)),
                            ])),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            size: 12, color: kGoldDark),
                      ]),
                    ),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: kGold.withOpacity(0.4), width: 1.5),
                      boxShadow: [BoxShadow(
                          color: kGold.withOpacity(0.15),
                          blurRadius: 10, offset: const Offset(0, 3))],
                    ),
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [kGoldLight, kGold]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.location_on_rounded,
                            color: kGoldDark, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.radius5km.toString(),
                                style: const TextStyle(color: kText1,
                                    fontSize: 19, fontWeight: FontWeight.w900,
                                    letterSpacing: -0.6)),
                            const Text("Nearby Users",
                                style: TextStyle(color: kText2,
                                    fontSize: 10, fontWeight: FontWeight.w700)),
                          ])),
                    ]),
                  )),
                ]),
              ]),
            ),
          ),

          const SizedBox(height: 20),
          Divider(color: kBorderSoft, height: 1.5, thickness: 1.5),
          const SizedBox(height: 18),

          // ── Bottom Stats Row ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(children: [
              Expanded(child: _BotStat(d.members.toString(), "Members", kGoldDark,
                  onTap: () => _go(context, MembersDetailScreen(period: period)))),
              _VertDivider(),
              Expanded(child: _BotStat(_fmtRevenue(d.revenue), "Revenue", kText1,
                  onTap: () => _go(context, RevenueDetailScreen(period: period)))),
              _VertDivider(),
              Expanded(child: _BotStat(d.visits.toString(), "Visits", kGoldDark,
                  onTap: () => _go(context, VisitsDetailScreen(period: period)))),
              _VertDivider(),
              Expanded(child: _BotStat(d.total.toString(), "Total", kGoldDark,
                  onTap: () => _go(context, TotalDetailScreen(
                    period: period, members: d.members,
                    revenue: d.revenue, visits: d.visits, total: d.total,
                  )))),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1.5, height: 40, color: kBorderSoft);
}

// ══════════════════════════════════════════════════════════════
// DATA MODELS
// ══════════════════════════════════════════════════════════════
class _PData {
  final int members, revenue, visits, radius5km, total;
  const _PData({
    required this.members, required this.revenue,
    required this.visits, required this.radius5km, required this.total,
  });
}

class _ActivityData {
  final String title, subtitle, value;
  final Color  valueColor, dot;
  final IconData icon;
  const _ActivityData(this.title, this.subtitle, this.value,
      this.valueColor, this.dot, this.icon);
}

// ══════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ══════════════════════════════════════════════════════════════
class _TapRadial extends StatefulWidget {
  final double value; final bool useGold;
  final IconData icon; final String label;
  final VoidCallback onTap;
  const _TapRadial({
    required this.value, required this.useGold,
    required this.icon, required this.label, required this.onTap,
  });
  @override
  State<_TapRadial> createState() => _TapRadialState();
}

class _TapRadialState extends State<_TapRadial>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _anim = Tween<double>(begin: 0, end: widget.value)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_TapRadial old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _anim = Tween<double>(begin: old.value, end: widget.value)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final track = widget.useGold ? kGold      : kText1;
    final ic    = widget.useGold ? kGoldDark  : kText1;
    final bg    = widget.useGold ? kGoldLight : kSurface2;
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(children: [
        Stack(alignment: Alignment.center, children: [
          SizedBox(width: 84, height: 84,
              child: AnimatedBuilder(animation: _anim,
                  builder: (_, __) => CircularProgressIndicator(
                    value: _anim.value, strokeWidth: 8,
                    strokeCap: StrokeCap.round, backgroundColor: kBorderSoft,
                    valueColor: AlwaysStoppedAnimation(track),
                  ))),
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(color: track.withOpacity(0.25), width: 1.5),
            ),
            child: Icon(widget.icon, color: ic, size: 22),
          ),
        ]),
        const SizedBox(height: 10),
        Text(widget.label, style: const TextStyle(color: kText2,
            fontSize: 11, fontWeight: FontWeight.w700)),
        AnimatedBuilder(animation: _anim, builder: (_, __) => Text(
            "${(_anim.value * 100).toInt()}%",
            style: const TextStyle(color: kText1, fontSize: 14,
                fontWeight: FontWeight.w900, letterSpacing: -0.3))),
      ]),
    );
  }
}

class _MiniRing extends StatefulWidget {
  final double value;
  const _MiniRing({required this.value});
  @override
  State<_MiniRing> createState() => _MiniRingState();
}

class _MiniRingState extends State<_MiniRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _anim = Tween<double>(begin: 0, end: widget.value)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_MiniRing old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _anim = Tween<double>(begin: old.value, end: widget.value)
          .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => CircularProgressIndicator(
      value: _anim.value, strokeWidth: 6, strokeCap: StrokeCap.round,
      backgroundColor: kGold.withOpacity(0.25),
      valueColor: const AlwaysStoppedAnimation(kGold),
    ),
  );
}

class _BotStat extends StatelessWidget {
  final String value, label; final Color color;
  final VoidCallback onTap;
  const _BotStat(this.value, this.label, this.color, {required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Text(value, style: _inter(16, FontWeight.w900, color, spacing: -0.6)),
      const SizedBox(height: 4),
      Text(label, style: _inter(9, FontWeight.w700, kText2, spacing: 0.6)),
      const SizedBox(height: 8),
      Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [kGoldLight, kGold],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(
              color: kGold.withOpacity(0.35), blurRadius: 8,
              offset: const Offset(0, 3))],
        ),
        child: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: kGoldDark),
      ),
    ]),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: const TextStyle(color: kText2, fontSize: 11,
          fontWeight: FontWeight.w800, letterSpacing: 1.8));
}

class PremiumRadial extends StatelessWidget {
  final double value; final bool useGold;
  final IconData icon; final String label;
  const PremiumRadial({super.key,
    required this.value, required this.useGold,
    required this.icon, required this.label,
  });
  @override
  Widget build(BuildContext context) {
    final trackColor = useGold ? kGold     : kText1;
    final iconColor  = useGold ? kGoldDark : kText1;
    final bgColor    = useGold ? kGoldLight : kSurface2;
    return Column(children: [
      Stack(alignment: Alignment.center, children: [
        SizedBox(width: 76, height: 76,
            child: CircularProgressIndicator(value: value, strokeWidth: 8,
                strokeCap: StrokeCap.round, backgroundColor: kBorderSoft,
                valueColor: AlwaysStoppedAnimation(trackColor))),
        Container(width: 48, height: 48,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22)),
      ]),
      const SizedBox(height: 10),
      Text(label, style: const TextStyle(color: kText2,
          fontSize: 11, fontWeight: FontWeight.w600)),
    ]);
  }
}

// ══════════════════════════════════════════════════════════════
// SHIMMER BADGE — Animated shine effect on LIVE DASHBOARD badge
// ══════════════════════════════════════════════════════════════
class _ShimmerBadge extends StatefulWidget {
  const _ShimmerBadge();
  @override
  State<_ShimmerBadge> createState() => _ShimmerBadgeState();
}

class _ShimmerBadgeState extends State<_ShimmerBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kGoldLight, kGoldLight.withOpacity(0.85), kGoldLight],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kGold.withOpacity(0.6), width: 1.5),
        boxShadow: [BoxShadow(
            color: kGold.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) {
          return ShaderMask(
            shaderCallback: (bounds) {
              final dx = _ctrl.value * 3 - 1;
              return LinearGradient(
                begin: Alignment(dx - 0.3, 0),
                end: Alignment(dx + 0.3, 0),
                colors: const [
                  Color(0x00000000), Color(0x66FFFFFF), Color(0x00000000),
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcATop,
            child: child,
          );
        },
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(
            color: kGoldDark, shape: BoxShape.circle,
            boxShadow: [BoxShadow(
                color: kGoldDark.withOpacity(0.7), blurRadius: 5)],
          )),
          const SizedBox(width: 6),
          Text("LIVE DASHBOARD",
              style: _inter(9, FontWeight.w900, kGoldDark, spacing: 1.5)),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PULSING DOT — Animated notification indicator
// ══════════════════════════════════════════════════════════════
class _PulsingDot extends StatefulWidget {
  final double size;
  final List<Color> colors;
  final Color borderColor;
  const _PulsingDot({required this.size, required this.colors, required this.borderColor});
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value.clamp(0.0, 1.0);
        final scale = 1.0 + 0.3 * t;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size, height: widget.size,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: widget.colors),
              shape: BoxShape.circle,
              border: Border.all(color: widget.borderColor, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: widget.colors.first.withOpacity((0.5 + 0.3 * t).clamp(0.0, 1.0)),
                  blurRadius: 8 + 6 * t,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}