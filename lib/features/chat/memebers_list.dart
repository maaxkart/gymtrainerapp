import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'chat_screen.dart';

// ── Brand tokens ───────────────────────────────────────────────
const kGold       = Color(0xFFC8DC32);
const kGoldDark   = Color(0xFF8FA000);
const kGoldDeep   = Color(0xFF5C6900);
const kGoldLight  = Color(0xFFF5F8D6);
const kGoldGlow   = Color(0x28C8DC32);
const kBg         = Color(0xFFF7F7F5);
const kSurface    = Color(0xFFFFFFFF);
const kSurface2   = Color(0xFFF5F5F5);
const kSurface3   = Color(0xFFEFEFEF);
const kBorder     = Color(0xFFEFEFEF);
const kBorder2    = Color(0xFFE0E0E0);
const kText1      = Color(0xFF111111);
const kText2      = Color(0xFFAAAAAA);
const kText3      = Color(0xFFCCCCCC);
const kGreen      = Color(0xFF22C55E);
const kRed        = Color(0xFFEF4444);

// ── Member model ───────────────────────────────────────────────
class GymMember {
  final String name, plan, phone, avatar;
  final bool   isActive;
  final double distanceKm;
  final String lastSeen;

  const GymMember({
    required this.name,
    required this.plan,
    required this.phone,
    required this.avatar,
    required this.isActive,
    required this.distanceKm,
    required this.lastSeen,
  });
}

// ── Sample data ────────────────────────────────────────────────
const _activeMembers = [
  GymMember(name: "Ravi Menon",     plan: "Gold Plan",   phone: "+91 98765 43210", avatar: "RM", isActive: true,  distanceKm: 1.2, lastSeen: "Just now"),
  GymMember(name: "Priya Nair",     plan: "Silver Plan", phone: "+91 91234 56789", avatar: "PN", isActive: true,  distanceKm: 2.8, lastSeen: "5 mins ago"),
  GymMember(name: "Sneha Ramesh",   plan: "Basic Plan",  phone: "+91 99887 76655", avatar: "SR", isActive: true,  distanceKm: 0.9, lastSeen: "12 mins ago"),
  GymMember(name: "Mohammed Fasal", plan: "Gold Plan",   phone: "+91 88776 65544", avatar: "MF", isActive: true,  distanceKm: 4.1, lastSeen: "30 mins ago"),
  GymMember(name: "Kiran Thomas",   plan: "Basic Plan",  phone: "+91 77665 54433", avatar: "KT", isActive: true,  distanceKm: 3.5, lastSeen: "1 hr ago"),
];

const _inactiveMembers = [
  GymMember(name: "Ajith Kumar",   plan: "Gold Plan",   phone: "+91 98765 11111", avatar: "AK", isActive: false, distanceKm: 6.3, lastSeen: "3 days ago"),
  GymMember(name: "Divya Suresh",  plan: "Silver Plan", phone: "+91 91234 22222", avatar: "DS", isActive: false, distanceKm: 8.1, lastSeen: "1 week ago"),
  GymMember(name: "Rohit Sharma",  plan: "Basic Plan",  phone: "+91 99887 33333", avatar: "RS", isActive: false, distanceKm: 5.5, lastSeen: "2 weeks ago"),
];

// ═══════════════════════════════════════════════════════════════
// MEMBERS LIST SCREEN
// ═══════════════════════════════════════════════════════════════
class MembersListScreen extends StatefulWidget {
  final bool showActive;
  const MembersListScreen({super.key, required this.showActive});

  @override
  State<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  List<GymMember> get _filtered {
    final base = widget.showActive ? _activeMembers : _inactiveMembers;
    if (_search.isEmpty) return base;
    return base
        .where((m) => m.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final members = _filtered;
    final isActive = widget.showActive;
    final accentColor = isActive ? kGreen : kRed;
    final label = isActive ? "Active Members" : "Inactive Members";

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: kBg,
        body: Column(children: [
          _buildHeader(context, label, accentColor, members.length),
          _buildSearchBar(),
          if (isActive) _buildNearbyBadge(members),
          Expanded(child: _buildList(members, accentColor)),
        ]),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────
  Widget _buildHeader(
      BuildContext context, String label, Color accent, int count) {
    return Container(
      color: kSurface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
          child: Row(children: [
            // Back button
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: kSurface2,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: kBorder2),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 15, color: kText1),
              ),
            ),
            const SizedBox(width: 16),

            // Title block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                        color: kText3,
                        fontSize: 9,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                        color: kText1,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6),
                  ),
                ],
              ),
            ),

            // Count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withOpacity(0.2)),
              ),
              child: Row(children: [
                Container(
                  width: 7, height: 7,
                  decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                ),
                const SizedBox(width: 7),
                Text(
                  "$count",
                  style: TextStyle(
                      color: accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w900),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Search bar ─────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      color: kSurface,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: kSurface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kBorder),
        ),
        child: TextField(
          onChanged: (v) => setState(() => _search = v),
          style: const TextStyle(color: kText1, fontSize: 14),
          decoration: const InputDecoration(
            hintText: "Search members…",
            hintStyle: TextStyle(color: kText3, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: kText3, size: 18),
            border: InputBorder.none,
            contentPadding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          ),
        ),
      ),
    );
  }

  // ── Nearby badge ──────────────────────────────────────────
  Widget _buildNearbyBadge(List<GymMember> members) {
    final nearbyCount = members.where((m) => m.distanceKm <= 5.0).length;
    return Container(
      color: kSurface,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: kGoldGlow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kGold.withOpacity(0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.location_on_rounded, color: kGold, size: 13),
            const SizedBox(width: 6),
            Text(
              "Within 5km: $nearbyCount members",
              style: const TextStyle(
                  color: kGoldDark, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ]),
        ),
      ]),
    );
  }

  // ── Member list ───────────────────────────────────────────
  Widget _buildList(List<GymMember> members, Color accentColor) {
    if (members.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.search_off_rounded, color: kText3, size: 40),
          const SizedBox(height: 12),
          const Text("No members found",
              style: TextStyle(color: kText3, fontSize: 14)),
        ]),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: _fadeCtrl,
            curve: Interval(i * 0.08, (i * 0.08 + 0.5).clamp(0, 1),
                curve: Curves.easeOut),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
                begin: const Offset(0, 0.18), end: Offset.zero)
                .animate(CurvedAnimation(
                parent: _fadeCtrl,
                curve: Interval(i * 0.08, (i * 0.08 + 0.5).clamp(0, 1),
                    curve: Curves.easeOut))),
            child: _MemberCard(member: members[i], accentColor: accentColor),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MEMBER CARD
// ═══════════════════════════════════════════════════════════════
class _MemberCard extends StatefulWidget {
  final GymMember member;
  final Color accentColor;
  const _MemberCard({required this.member, required this.accentColor});

  @override
  State<_MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<_MemberCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.member;
    final isNear = m.distanceKm <= 5.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _pressed ? kBorder2 : kBorder,
            ),
          ),
          child: Row(children: [
            // ── Avatar block ───────────────────────
            _AvatarBlock(member: m, isNear: isNear),
            const SizedBox(width: 14),

            // ── Info block ─────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + nearby
                  Row(children: [
                    Expanded(
                      child: Text(m.name,
                          style: const TextStyle(
                              color: kText1,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3)),
                    ),
                    if (isNear) _NearbyBadge(dist: m.distanceKm),
                  ]),
                  const SizedBox(height: 3),

                  // Plan
                  Text(m.plan,
                      style: const TextStyle(
                          color: kText3,
                          fontSize: 11,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),

                  // Meta row
                  Row(children: [
                    const Icon(Icons.access_time_rounded,
                        size: 11, color: kText3),
                    const SizedBox(width: 4),
                    Text(m.lastSeen,
                        style: const TextStyle(
                            color: kText3, fontSize: 11)),
                    const SizedBox(width: 10),
                    const Icon(Icons.location_on_rounded,
                        size: 11, color: kText3),
                    const SizedBox(width: 4),
                    Text("${m.distanceKm} km",
                        style: const TextStyle(
                            color: kText3, fontSize: 11)),
                  ]),
                  const SizedBox(height: 8),

                  // Status pill
                  _StatusPill(isActive: m.isActive),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // ── Chat button ────────────────────────
            _ChatButton(member: m),
          ]),
        ),
      ),
    );
  }
}

// ── Avatar block ──────────────────────────────────────────────
class _AvatarBlock extends StatelessWidget {
  final GymMember member;
  final bool isNear;
  const _AvatarBlock({required this.member, required this.isNear});

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      // Gold ring for nearby
      if (isNear)
        Container(
          width: 54, height: 54,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [kGold, kGoldDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
                color: kSurface, shape: BoxShape.circle,
                border: Border.all(color: kBg, width: 1)),
            child: _avatarInner(member.avatar),
          ),
        )
      else
        Container(
          width: 54, height: 54,
          decoration: BoxDecoration(
            color: kSurface2,
            shape: BoxShape.circle,
            border: Border.all(color: kBorder2),
          ),
          child: _avatarInner(member.avatar, subtle: true),
        ),

      // Online dot
      Positioned(
        bottom: 2, right: 2,
        child: Container(
          width: 13, height: 13,
          decoration: BoxDecoration(
            color: member.isActive ? kGreen : kSurface3,
            shape: BoxShape.circle,
            border: Border.all(color: kBg, width: 2.5),
          ),
        ),
      ),
    ]);
  }

  Widget _avatarInner(String initials, {bool subtle = false}) {
    return Center(
      child: Text(initials,
          style: TextStyle(
              color: subtle ? kText2 : kGoldDark,
              fontSize: 14,
              fontWeight: FontWeight.w900)),
    );
  }
}

// ── Nearby badge ───────────────────────────────────────────────
class _NearbyBadge extends StatelessWidget {
  final double dist;
  const _NearbyBadge({required this.dist});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: kGoldGlow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kGold.withOpacity(0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.location_on_rounded, color: kGold, size: 9),
        const SizedBox(width: 3),
        Text("${dist}km",
            style: const TextStyle(
                color: kGoldDark, fontSize: 9, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

// ── Status pill ───────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  final bool isActive;
  const _StatusPill({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? kGreen.withOpacity(0.1)
            : kRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: isActive
                ? kGreen.withOpacity(0.2)
                : kRed.withOpacity(0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 5, height: 5,
          decoration: BoxDecoration(
              color: isActive ? kGreen : kRed, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          isActive ? "Active" : "Inactive",
          style: TextStyle(
              color: isActive ? kGreen : kRed,
              fontSize: 10,
              fontWeight: FontWeight.w700),
        ),
      ]),
    );
  }
}

// ── Chat button ───────────────────────────────────────────────
class _ChatButton extends StatefulWidget {
  final GymMember member;
  const _ChatButton({required this.member});

  @override
  State<_ChatButton> createState() => _ChatButtonState();
}

class _ChatButtonState extends State<_ChatButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(member: widget.member),
            ));
      },
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: _pressed ? kGold.withOpacity(0.9) : kGoldGlow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: _pressed
                    ? kGold
                    : kGold.withOpacity(0.3)),
          ),
          child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: kGold, size: 18),
        ),
      ),
    );
  }
}