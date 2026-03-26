import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics/total.dart';
import '../analytics/member.dart';
import '../analytics/revenue.dart';
import '../analytics/visits.dart';
import  '../chat/memebers_list.dart';
import '../equipment/equipment_screen.dart';
import '../payments/payments_screen.dart';
import '../packages/packages_screen.dart';
import '../videos/videos_screen.dart';
import '../notifications/alert_screen.dart';

// ── Brand tokens ──────────────────────────────────────────────
const kGold       = Color(0xFFC8DC32);
const kGoldDark   = Color(0xFF8FA000);
const kGoldLight  = Color(0xFFF5F8D6);
const kBg         = Color(0xFFF7F7F5);
const kSurface    = Color(0xFFFFFFFF);
const kSurface2   = Color(0xFFF5F5F5);
const kBorder     = Color(0xFFEFEFEF);
const kText1      = Color(0xFF111111);
const kText2      = Color(0xFFAAAAAA);
const kAmber      = Color(0xFFFFB300);
const kOrange     = Color(0xFFE65C00);
const kOrangeDark = Color(0xFFB84400);

// ═══════════════════════════════════════════════════════════════
// HOME PAGE
// ═══════════════════════════════════════════════════════════════
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = "Trainer";
  String gym  = "My Gym";

  @override
  void initState() { super.initState(); _loadUser(); }

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
          const SliverToBoxAdapter(child: AnalyticsCard()),
          const SliverToBoxAdapter(child: HeroRevenueCard()),
          _buildGymStatsRow(),
          _buildQuickAccess(),
          _buildRecentActivity(),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  // ── HEADER ─────────────────────────────────────────────────
  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        color: kSurface,
        padding: const EdgeInsets.fromLTRB(20, 58, 20, 18),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(16)),
              alignment: Alignment.center,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : "T",
                style: const TextStyle(color: kText1, fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("WELCOME BACK",
                    style: TextStyle(color: kText2, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                const SizedBox(height: 2),
                Text(name, style: const TextStyle(color: kText1, fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                const SizedBox(height: 2),
                Text(gym, style: const TextStyle(color: kGoldDark, fontSize: 12, fontWeight: FontWeight.w600)),
              ]),
            ),
            GestureDetector(
              onTap: () { HapticFeedback.lightImpact(); Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertsScreen())); },
              child: Stack(clipBehavior: Clip.none, children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
                  child: const Icon(Icons.notifications_outlined, color: kText1, size: 20),
                ),
                Positioned(
                  top: 9, right: 9,
                  child: Container(width: 8, height: 8,
                      decoration: BoxDecoration(color: kGold, shape: BoxShape.circle, border: Border.all(color: kSurface, width: 1.5))),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // ── GYM STATS ROW ──────────────────────────────────────────
  // Each stat card is tappable → goes to a detail screen
  Widget _buildGymStatsRow() {
    final stats = [
      _StatData("40",   "My Jim Members",    kGoldDark,    Icons.people_rounded,
          const MembersListScreen(showActive: true)),         // shows all members

      _StatData("₹25K", "My Jim Revenue",    kText1,       Icons.currency_rupee_rounded,
          const _GymStatDetail(title: "My Gym Revenue", value: "₹25K",
              icon: Icons.currency_rupee_rounded, color: kText1,
              items: ["Ravi Menon – ₹2500", "Priya Nair – ₹1500",
                "Sneha Ramesh – ₹800", "Mohammed F – ₹2500", "Kiran Thomas – ₹800"])),

      _StatData("50",   "My Jim App Visits", kText1,       Icons.phone_android_rounded,
          const _GymStatDetail(title: "My Gym App Visits", value: "50",
              icon: Icons.phone_android_rounded, color: kText1,
              items: ["Android – 28 visits", "iOS – 15 visits", "Web – 7 visits"])),

      _StatData("30",   "Active",            Colors.green, Icons.check_circle_rounded,
          const MembersListScreen(showActive: true)),         // ← Active members

      _StatData("10",   "Inactive",          Colors.red,   Icons.cancel_rounded,
          const MembersListScreen(showActive: false)),        // ← Inactive members
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width > 600 ? 3 : 2;
            final itemWidth = (width - (10.0 * (crossAxisCount - 1))) / crossAxisCount;
            return Wrap(
              spacing: 10, runSpacing: 10,
              children: stats.map((s) => SizedBox(
                width: itemWidth,
                child: _TappableStatPill(data: s),
              )).toList(),
            );
          },
        ),
      ),
    );
  }

  // ── QUICK ACCESS ───────────────────────────────────────────
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

  // ── RECENT ACTIVITY ────────────────────────────────────────
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
              decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(22), border: Border.all(color: kBorder)),
              child: Column(
                children: items.asMap().entries.map((e) {
                  final isLast = e.key == items.length - 1;
                  final d = e.value;
                  return Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                      child: Row(children: [
                        Container(width: 7, height: 7, decoration: BoxDecoration(color: d.dot, shape: BoxShape.circle)),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(d.title, style: const TextStyle(color: kText1, fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 3),
                          Text(d.subtitle, style: const TextStyle(color: kText2, fontSize: 10)),
                        ])),
                        Text(d.value, style: TextStyle(color: d.valueColor, fontSize: 13, fontWeight: FontWeight.w800)),
                      ]),
                    ),
                    if (!isLast) const Divider(color: kBorder, height: 1, indent: 40),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tappable stat pill ─────────────────────────────────────────
class _StatData {
  final String value, label;
  final Color color;
  final IconData icon;
  final Widget page;

  const _StatData(this.value, this.label, this.color, this.icon, this.page);
}

class _TappableStatPill extends StatefulWidget {
  final _StatData data;
  const _TappableStatPill({super.key, required this.data});
  @override
  State<_TappableStatPill> createState() => _TappableStatPillState();
}

class _TappableStatPillState extends State<_TappableStatPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final isRevenue = d.label.toLowerCase().contains("revenue");

    return GestureDetector(
      onTapDown:   (_) { HapticFeedback.lightImpact(); setState(() => _pressed = true); },
      onTapUp:     (_) { setState(() => _pressed = false); Navigator.push(context, MaterialPageRoute(builder: (_) => d.page)); },
      onTapCancel: ()  => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: _pressed
              ? kGoldLight
              : (isRevenue ? kSurface : kSurface2),          // white bg for revenue
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isRevenue ? kGold : (_pressed ? kGold : kBorder),
            width: isRevenue ? 1.8 : 1,
          ),
          boxShadow: isRevenue
              ? [
            BoxShadow(color: kGold.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 5)),
            BoxShadow(color: kGold.withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 8)),
          ]
              : [],
        ),
        child: Column(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: isRevenue ? kGoldLight : d.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(d.icon, color: isRevenue ? kGoldDark : d.color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(d.value,
              style: TextStyle(
                color: isRevenue ? kGoldDark : d.color,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              )),
          const SizedBox(height: 3),
          Text(d.label.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isRevenue ? kGoldDark : kText2,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              )),
          const SizedBox(height: 4),
          Icon(Icons.arrow_forward_ios_rounded,
              size: 9, color: isRevenue ? kGoldDark : kText2),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// GYM STAT DETAIL SCREEN  (generic — used by all 5 stat tiles)
// ═══════════════════════════════════════════════════════════════
class _GymStatDetail extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final List<String> items;
  const _GymStatDetail({
    required this.title, required this.value, required this.icon,
    required this.color, required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          // Header
          Container(
            color: kSurface,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: kText1),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(title.toUpperCase(), style: const TextStyle(color: kText2, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
                        Text(title, style: const TextStyle(color: kText1, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                      ])),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(12)),
                        child: Row(children: [
                          Icon(icon, color: kGoldDark, size: 16),
                          const SizedBox(width: 6),
                          Text(value, style: const TextStyle(color: kGoldDark, fontSize: 15, fontWeight: FontWeight.w900)),
                        ]),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          const Divider(color: kBorder, height: 0.5),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(items[i], style: const TextStyle(color: kText1, fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HERO REVENUE CARD — Today / Week / Month only (Year removed)
// ═══════════════════════════════════════════════════════════════
class HeroRevenueCard extends StatefulWidget {
  const HeroRevenueCard({super.key});
  @override
  State<HeroRevenueCard> createState() => _HeroRevenueCardState();
}

class _HeroRevenueCardState extends State<HeroRevenueCard>
    with SingleTickerProviderStateMixin {

  // ← Year removed
  final List<_RevData> _items = const [
    _RevData(period: "Today", label: "MY JIM'S TODAY'S REVENUE",   amount: "₹4,200",    trend: "18% from yesterday", isUp: true),
    _RevData(period: "Week",  label: "MY JIM'S THIS WEEK'S REVENUE", amount: "₹28,500",  trend: "12% from last week", isUp: true),
    _RevData(period: "Month", label: "MY JIM'S THIS MONTH'S REVENUE", amount: "₹1,05,000", trend: "9% from last month", isUp: true),
  ];

  int    _current = 0;
  Timer? _autoTimer;
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _startTimer();
  }

  void _startTimer() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) _switchTo((_current + 1) % _items.length);
    });
  }

  void _switchTo(int index) {
    if (index == _current) return;
    HapticFeedback.selectionClick();
    _fadeCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(() => _current = index);
      _fadeCtrl.forward();
    });
  }

  @override
  void dispose() { _autoTimer?.cancel(); _fadeCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final d = _items[_current];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onHorizontalDragEnd: (det) {
          _autoTimer?.cancel();
          if ((det.primaryVelocity ?? 0) < 0) _switchTo((_current + 1) % _items.length);
          else _switchTo((_current - 1 + _items.length) % _items.length);
          _startTimer();
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kGold,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: kGold.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_items.length, (i) {
                        final sel = _current == i;
                        return GestureDetector(
                          onTap: () { _autoTimer?.cancel(); _switchTo(i); _startTimer(); },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: sel ? kText1 : Colors.black.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(_items[i].period,
                                style: TextStyle(color: sel ? kGold : kGoldDark, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.3)),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.1), borderRadius: BorderRadius.circular(13)),
                  child: const Icon(Icons.currency_rupee_rounded, color: kText1, size: 20),
                ),
              ]),
              const SizedBox(height: 18),
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.label, style: const TextStyle(color: kGoldDark, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                    const SizedBox(height: 6),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      transitionBuilder: (child, anim) => SlideTransition(
                        position: Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
                            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: Text(d.amount, key: ValueKey(d.amount),
                          style: const TextStyle(color: kText1, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1, height: 1)),
                    ),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(d.isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                          color: d.isUp ? kGoldDark : kOrangeDark, size: 13),
                      const SizedBox(width: 4),
                      Text("${d.isUp ? '+' : '−'}${d.trend}",
                          style: TextStyle(color: d.isUp ? kGoldDark : kOrangeDark, fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_items.length, (i) {
                  final sel = _current == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: sel ? 22 : 6, height: 6,
                    decoration: BoxDecoration(
                        color: sel ? kText1 : Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(99)),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RevData {
  final String period, label, amount, trend;
  final bool isUp;
  const _RevData({required this.period, required this.label, required this.amount, required this.trend, required this.isUp});
}

// ═══════════════════════════════════════════════════════════════
// ANALYTICS CARD — Today / Week / Month only (Year removed)
//                  Total banner now shows app visits + 5km radius
// ═══════════════════════════════════════════════════════════════
class AnalyticsCard extends StatefulWidget {
  const AnalyticsCard({super.key});
  @override
  State<AnalyticsCard> createState() => _AnalyticsCardState();
}

class _AnalyticsCardState extends State<AnalyticsCard>
    with SingleTickerProviderStateMixin {

  // ← "Year" removed
  final List<String> _periods = ["Today", "Week", "Month"];
  int _sel = 2;
  late TabController _tab;

  final Map<String, _PData> _data = {
    "Today": _PData(members: 8,   revenue: 4200,   visits: 34,   radius5km: 18,  total: 42),
    "Week":  _PData(members: 22,  revenue: 18500,  visits: 210,  radius5km: 110, total: 232),
    "Month": _PData(members: 120, revenue: 35000,  visits: 700,  radius5km: 380, total: 820),
  };

  final Map<String, _PData> _max = {
    "Today": _PData(members: 50,   revenue: 10000,  visits: 100,   radius5km: 50,  total: 160),
    "Week":  _PData(members: 60,   revenue: 30000,  visits: 500,   radius5km: 200, total: 560),
    "Month": _PData(members: 150,  revenue: 50000,  visits: 1000,  radius5km: 500, total: 1200),
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: kBorder),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [

            // TOP BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: Row(
                children: [
                  const Text("Power Gym Analytics",
                      style: TextStyle(color: kText1, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                  const Spacer(),
                  Container(
                    height: 32,
                    decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(10), border: Border.all(color: kBorder)),
                    child: TabBar(
                      controller: _tab,
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      padding: const EdgeInsets.all(3),
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(7)),
                      labelColor: kGoldDark,
                      unselectedLabelColor: kText2,
                      labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                      unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      dividerColor: Colors.transparent,
                      tabs: _periods.map((p) => Tab(text: p, height: 26)).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3 RADIAL RINGS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _TapRadial(value: mPct, useGold: true,  icon: Icons.people_outline,    label: "Members",  onTap: () => _go(context, MembersDetailScreen(period: period))),
                  _TapRadial(value: rPct, useGold: false, icon: Icons.currency_rupee,    label: "Revenue",  onTap: () => _go(context, RevenueDetailScreen(period: period))),
                  _TapRadial(value: vPct, useGold: true,  icon: Icons.bar_chart_rounded, label: "Power Gym Visits", onTap: () => _go(context, VisitsDetailScreen(period: period))),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── TOTAL BANNER — now shows visits + 5km radius ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kGoldLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kGold.withOpacity(0.45), width: 0.8),
                ),
                child: Column(
                  children: [

                    // Row 1: Total label + mini ring
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.leaderboard_rounded, color: kGoldDark, size: 16),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("TOTAL · ${_periods[_sel].toUpperCase()}",
                            style: const TextStyle(color: kGoldDark, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                        const SizedBox(height: 3),
                        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(d.total.toString(),
                              style: const TextStyle(color: kText1, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.8)),
                          const SizedBox(width: 6),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 3),
                            child: Text("activities", style: TextStyle(color: kText2, fontSize: 11, fontWeight: FontWeight.w500)),
                          ),
                        ]),
                      ])),
                      Stack(alignment: Alignment.center, children: [
                        SizedBox(width: 46, height: 46, child: _MiniRing(value: tPct)),
                        Text("${(tPct * 100).toInt()}%",
                            style: const TextStyle(color: kGoldDark, fontSize: 9, fontWeight: FontWeight.w800)),
                      ]),
                    ]),

                    const SizedBox(height: 12),
                    Divider(color: kGold.withOpacity(0.25), height: 0.5),
                    const SizedBox(height: 12),

                    // Row 2: Total App Visits + 5km radius
                    Row(children: [

                      // Total app visits
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _go(context, VisitsDetailScreen(period: period)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kGold.withOpacity(0.25)),
                            ),
                            child: Row(children: [
                              Container(
                                width: 34, height: 34,
                                decoration: BoxDecoration(color: kGoldLight, borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.phone_android_rounded, color: kGoldDark, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(d.visits.toString(),
                                    style: const TextStyle(color: kText1, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                                const Text("Total Power Gym Visits",
                                    style: TextStyle(color: kText2, fontSize: 9, fontWeight: FontWeight.w600)),
                              ])),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: kText2),
                            ]),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Within 5km radius
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kGold.withOpacity(0.25)),
                          ),
                          child: Row(children: [
                            Container(
                              width: 34, height: 34,
                              decoration: BoxDecoration(color: kGoldLight, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.location_on_rounded, color: kGoldDark, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(d.radius5km.toString(),
                                  style: const TextStyle(color: kText1, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                              const Text("Power Gym Nearby Users",
                                  style: TextStyle(color: kText2, fontSize: 9, fontWeight: FontWeight.w600)),
                            ])),
                          ]),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),
            const Divider(color: kBorder, height: 1),
            const SizedBox(height: 12),

            // BOTTOM 4-STAT ROW
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: Row(children: [
                Expanded(child: _BotStat(d.members.toString(),   "Members", kGoldDark, onTap: () => _go(context, MembersDetailScreen(period: period)))),
                Container(width: 0.5, height: 30, color: kBorder),
                Expanded(child: _BotStat(_fmtRevenue(d.revenue), "Revenue", kText1,    onTap: () => _go(context, RevenueDetailScreen(period: period)))),
                Container(width: 0.5, height: 30, color: kBorder),
                Expanded(child: _BotStat(d.visits.toString(),    "Visits",  kGoldDark, onTap: () => _go(context, VisitsDetailScreen(period: period)))),
                Container(width: 0.5, height: 30, color: kBorder),
                Expanded(child: _BotStat(d.total.toString(),     "Total",   kGoldDark,
                    onTap: () => _go(context, TotalDetailScreen(period: period, members: d.members, revenue: d.revenue, visits: d.visits, total: d.total)))),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════
class _PData {
  final int members, revenue, visits, radius5km, total;
  const _PData({required this.members, required this.revenue, required this.visits, required this.radius5km, required this.total});
}

class _ActivityData {
  final String title, subtitle, value;
  final Color  valueColor, dot;
  const _ActivityData(this.title, this.subtitle, this.value, this.valueColor, this.dot);
}

// ═══════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════

class _TapRadial extends StatefulWidget {
  final double value; final bool useGold; final IconData icon; final String label; final VoidCallback onTap;
  const _TapRadial({required this.value, required this.useGold, required this.icon, required this.label, required this.onTap});
  @override
  State<_TapRadial> createState() => _TapRadialState();
}

class _TapRadialState extends State<_TapRadial> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _anim = Tween<double>(begin: 0, end: widget.value).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(_TapRadial old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _anim = Tween<double>(begin: old.value, end: widget.value).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final track = widget.useGold ? kGold : kText1;
    final ic    = widget.useGold ? kGoldDark : kText1;
    final bg    = widget.useGold ? kGoldLight : kSurface2;
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(children: [
        Stack(alignment: Alignment.center, children: [
          SizedBox(width: 72, height: 72,
              child: AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => CircularProgressIndicator(
                    value: _anim.value, strokeWidth: 6, strokeCap: StrokeCap.round,
                    backgroundColor: kBorder, valueColor: AlwaysStoppedAnimation(track)),
              )),
          Container(width: 44, height: 44, decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(widget.icon, color: ic, size: 18)),
        ]),
        const SizedBox(height: 7),
        Text(widget.label, style: const TextStyle(color: kText2, fontSize: 10, fontWeight: FontWeight.w600)),
        AnimatedBuilder(
          animation: _anim,
          builder: (_, __) => Text("${(_anim.value * 100).toInt()}%",
              style: const TextStyle(color: kText1, fontSize: 11, fontWeight: FontWeight.w800)),
        ),
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

class _MiniRingState extends State<_MiniRing> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _anim = Tween<double>(begin: 0, end: widget.value).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }
  @override
  void didUpdateWidget(_MiniRing old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _anim = Tween<double>(begin: old.value, end: widget.value).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
      _ctrl.forward(from: 0);
    }
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => CircularProgressIndicator(
        value: _anim.value, strokeWidth: 4, strokeCap: StrokeCap.round,
        backgroundColor: kGold.withOpacity(0.25),
        valueColor: const AlwaysStoppedAnimation(kGold)),
  );
}

class _BotStat extends StatelessWidget {
  final String value, label; final Color color; final VoidCallback onTap;
  const _BotStat(this.value, this.label, this.color, {required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: kText2, fontSize: 8, letterSpacing: 0.5, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      const Icon(Icons.arrow_forward_ios_rounded, size: 9, color: kText2),
    ]),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: const TextStyle(color: kText2, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5));
}

class PremiumRadial extends StatelessWidget {
  final double value; final bool useGold; final IconData icon; final String label;
  const PremiumRadial({super.key, required this.value, required this.useGold, required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    final trackColor = useGold ? kGold : kText1;
    final iconColor  = useGold ? kGoldDark : kText1;
    final bgColor    = useGold ? kGoldLight : kSurface2;
    return Column(children: [
      Stack(alignment: Alignment.center, children: [
        SizedBox(width: 70, height: 70,
            child: CircularProgressIndicator(value: value, strokeWidth: 6, strokeCap: StrokeCap.round,
                backgroundColor: kBorder, valueColor: AlwaysStoppedAnimation(trackColor))),
        Container(width: 42, height: 42, decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18)),
      ]),
      const SizedBox(height: 9),
      Text(label, style: const TextStyle(color: kText2, fontSize: 10, fontWeight: FontWeight.w500)),
    ]);
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon; final String label; final Color bg, iconColor; final Widget page;
  const _QuickTile(this.icon, this.label, this.bg, this.iconColor, this.page);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () { HapticFeedback.lightImpact(); Navigator.push(context, MaterialPageRoute(builder: (_) => page)); },
    child: SizedBox(width: 76, child: Column(children: [
      Container(width: 56, height: 56,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18), border: Border.all(color: kBorder)),
          child: Icon(icon, color: iconColor, size: 22)),
      const SizedBox(height: 8),
      Text(label, textAlign: TextAlign.center,
          style: const TextStyle(color: kText2, fontSize: 11, fontWeight: FontWeight.w500)),
    ])),
  );
}