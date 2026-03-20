import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

// ── Brand tokens ──────────────────────────────────────
const kGold       = Color(0xFFC8DC32);
const kGoldDark   = Color(0xFF8FA000);
const kGoldDeep   = Color(0xFF3A4500);
const kGoldLight  = Color(0xFFF5F8D6);
const kGoldBorder = Color(0xFFE2EC8A);
const kBg         = Color(0xFFF7F7F5);
const kSurface    = Color(0xFFFFFFFF);
const kSurface2   = Color(0xFFF5F5F5);
const kBorder     = Color(0xFFEFEFEF);
const kText1      = Color(0xFF111111);
const kText2      = Color(0xFFAAAAAA);
const kGreen      = Color(0xFF4CAF50);
const kGreenBg    = Color(0xFFE8F5E9);
const kGreenText  = Color(0xFF2E7D32);
const kOrange     = Color(0xFFFF9800);
const kOrangeBg   = Color(0xFFFFF3E0);
const kOrangeText = Color(0xFFE65100);

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with TickerProviderStateMixin {

  List liveUsers = [];
  List history   = [];
  bool loading   = true;

  int total     = 0;
  int checkedIn = 0;
  int pending   = 0;

  late TabController _tabController;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
          (_) => _loadData(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => loading = true);

    final live = await ApiService.getLiveUsers();
    final hist = await ApiService.getAttendanceHistory();

    liveUsers = live;
    history   = hist;
    checkedIn = liveUsers.length;
    total     = history.length;
    pending   = history.where((e) => e["check_out"] == null).length;

    setState(() => loading = false);
  }

  Future<void> _checkout(int id) async {
    await ApiService.checkOutUser(id);
    _loadData();
  }

  // ── SAFE HELPERS ─────────────────────────────────────
  String _safeName(dynamic user) =>
      (user?["user"]?["name"] ?? "Member").toString();

  String _safeExercise(dynamic user) =>
      (user?["exercise"]?["name"] ?? "Exercise").toString();

  String _safeCheckin(dynamic user) =>
      (user?["check_in"] ?? "--:--").toString();

  String? _safeCheckout(dynamic user) =>
      user?["check_out"]?.toString();

  String _safeId(dynamic user) =>
      (user?["id"] ?? 0).toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _buildTopBar(),
          if (loading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(color: kGold, strokeWidth: 2.5),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  _buildHeroCard(),
                  _buildStatStrip(),
                  _buildSwipeHint(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _overviewTab(),
                        _checkedInTab(),
                        _pendingTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── TOP BAR ──────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
      child: Column(
        children: [
          // Title row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: kSurface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 15,
                    color: kText1,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  "Attendance",
                  style: TextStyle(
                    color: kText1,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              // Live pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: kGoldLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kGoldBorder),
                ),
                child: Row(
                  children: [
                    _PulseDot(),
                    const SizedBox(width: 6),
                    Text(
                      "${checkedIn.toString()} LIVE",
                      style: const TextStyle(
                        color: kGoldDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Tab bar
          TabBar(
            controller: _tabController,
            indicatorColor: kGold,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: kGoldDark,
            unselectedLabelColor: kText2,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: "Overview"),
              Tab(text: "Checked-in"),
              Tab(text: "Pending"),
            ],
          ),
        ],
      ),
    );
  }

  // ── HERO CARD ─────────────────────────────────────────
  Widget _buildHeroCard() {
    return Padding(
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
                children: [
                  const Text(
                    "TODAY'S ATTENDANCE",
                    style: TextStyle(
                      color: kGoldDeep,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${total.toString()} Members",
                    style: const TextStyle(
                      color: kText1,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "↑ Refreshes every 10 sec",
                    style: TextStyle(
                      color: kGoldDeep,
                      fontSize: 11,
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
              child: const Icon(Icons.group_outlined, color: kText1, size: 26),
            ),
          ],
        ),
      ),
    );
  }

  // ── STAT STRIP ────────────────────────────────────────
  Widget _buildStatStrip() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _StatCard(
            value: total.toString(),
            label: "Total",
            icon: Icons.people_outline_rounded,
            accentColor: kGold,
            iconBg: kGoldLight,
            iconColor: kGoldDark,
          ),
          const SizedBox(width: 10),
          _StatCard(
            value: checkedIn.toString(),
            label: "Live",
            icon: Icons.bolt_rounded,
            accentColor: kText1,
            iconBg: kSurface2,
            iconColor: kText1,
          ),
          const SizedBox(width: 10),
          _StatCard(
            value: pending.toString(),
            label: "Pending",
            icon: Icons.timer_outlined,
            accentColor: kOrange,
            iconBg: kOrangeBg,
            iconColor: kOrangeText,
          ),
        ],
      ),
    );
  }

  // ── SWIPE HINT ────────────────────────────────────────
  Widget _buildSwipeHint() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: const [
          Icon(Icons.swipe_left_outlined, size: 14, color: kText2),
          SizedBox(width: 6),
          Text(
            "Swipe left to check out a member",
            style: TextStyle(color: kText2, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── TABS ──────────────────────────────────────────────
  Widget _overviewTab() {
    if (history.isEmpty) return _emptyState("No attendance records today");
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: history.length,
      itemBuilder: (_, i) {
        final u = history[i];
        return _MemberTile(
          name:     _safeName(u),
          exercise: _safeExercise(u),
          checkin:  _safeCheckin(u),
          checkout: _safeCheckout(u),
        );
      },
    );
  }

  Widget _checkedInTab() {
    if (liveUsers.isEmpty) return _emptyState("No active members right now");
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: liveUsers.length,
      itemBuilder: (_, i) {
        final u = liveUsers[i];
        return Dismissible(
          key: Key(_safeId(u)),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: kGold,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.logout_rounded, color: kGoldDeep, size: 20),
                SizedBox(width: 8),
                Text(
                  "Check Out",
                  style: TextStyle(
                    color: kGoldDeep,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          onDismissed: (_) => _checkout(u["id"] as int),
          child: _MemberTile(
            name:     _safeName(u),
            exercise: _safeExercise(u),
            checkin:  _safeCheckin(u),
            checkout: null,
          ),
        );
      },
    );
  }

  Widget _pendingTab() {
    final pendingUsers = history.where((e) => e["check_out"] == null).toList();
    if (pendingUsers.isEmpty) return _emptyState("No pending checkouts 🎉");
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: pendingUsers.length,
      itemBuilder: (_, i) {
        final u = pendingUsers[i];
        return _MemberTile(
          name:     _safeName(u),
          exercise: _safeExercise(u),
          checkin:  _safeCheckin(u),
          checkout: null,
          forcePending: true,
        );
      },
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: kGoldLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.inbox_outlined,
                color: kGoldDark, size: 30),
          ),
          const SizedBox(height: 14),
          Text(msg,
              style: const TextStyle(color: kText2, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── PULSING DOT ───────────────────────────────────────────────
class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _anim,
    child: Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: kGold,
        shape: BoxShape.circle,
      ),
    ),
  );
}

// ── STAT CARD ─────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String   value, label;
  final IconData icon;
  final Color    accentColor, iconBg, iconColor;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // accent bar
          Container(height: 3, color: accentColor),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: iconColor, size: 17),
                ),
                const SizedBox(height: 8),
                Text(value,
                    style: const TextStyle(
                      color: kText1,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    )),
                const SizedBox(height: 3),
                Text(label.toUpperCase(),
                    style: const TextStyle(
                      color: kText2,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    )),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ── MEMBER TILE ───────────────────────────────────────────────
class _MemberTile extends StatelessWidget {
  final String  name, exercise, checkin;
  final String? checkout;
  final bool    forcePending;

  const _MemberTile({
    required this.name,
    required this.exercise,
    required this.checkin,
    this.checkout,
    this.forcePending = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive  = checkout == null && !forcePending;
    final isDone    = checkout != null;
    final isPending = forcePending || (checkout == null && !isActive);

    final initials  = name.trim().isNotEmpty
        ? name.trim().split(" ").map((w) => w[0]).take(2).join().toUpperCase()
        : "M";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? kGoldBorder : kBorder,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isActive ? kGold : kSurface2,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                color: isActive ? kGoldDeep : kText2,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Name + exercise
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                      color: kText1,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 3),
                Text(exercise,
                    style: const TextStyle(color: kText2, fontSize: 11)),
              ],
            ),
          ),

          // Time + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isDone ? "OUT ${checkout!}" : "IN $checkin",
                style: TextStyle(
                  color: isDone
                      ? kGreenText
                      : isActive
                      ? kGoldDark
                      : kOrangeText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: isDone
                      ? kGreenBg
                      : isActive
                      ? kGoldLight
                      : kOrangeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isDone ? "DONE" : isActive ? "ACTIVE" : "PENDING",
                  style: TextStyle(
                    color: isDone
                        ? kGreenText
                        : isActive
                        ? kGoldDark
                        : kOrangeText,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}