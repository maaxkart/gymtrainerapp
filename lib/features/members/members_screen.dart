// lib/features/members/members_screen.dart

import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import 'add_member_screen.dart';

// ── PALETTE ──────────────────────────────────────────────────────────────────
const _gold    = Color(0xFFD5EB45);
const _goldDim = Color(0x26D5EB45);
const _bg      = Color(0xFF0A0B0F);
const _surface = Color(0xFF111318);
const _surface2= Color(0xFF181B22);
const _border  = Color(0xFF1F2330);
const _textPri = Color(0xFFF0F0F0);
const _textSec = Color(0xFF6B7280);
const _textTer = Color(0xFF383C47);
const _green   = Color(0xFF22C55E);
const _red     = Color(0xFFEF4444);




// ═════════════════════════════════════════════════════════════════════════════
// MEMBERS SCREEN
// ═════════════════════════════════════════════════════════════════════════════
class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen>
    with TickerProviderStateMixin {

  List _all      = [];
  List _filtered = [];
  bool _loading  = true;
  String _activeFilter = 'All';

  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  double _scrollOffset = 0;

  late AnimationController _entryCtrl;
  late AnimationController _ambientCtrl;

  final _filters = ['All', 'Active', 'Expired', 'Due'];

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800))
      ..forward();
    _ambientCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 5))
      ..repeat(reverse: true);
    _scrollCtrl.addListener(() =>
        setState(() => _scrollOffset = _scrollCtrl.offset));
    _loadMembers();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _ambientCtrl.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    try {
      final data = await ApiService.getMembers();
      if (!mounted) return;
      setState(() { _all = data; _filtered = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _search(String q) {
    _applyFilters(q.trim(), _activeFilter);
  }

  void _applyFilters(String q, String filter) {
    setState(() => _activeFilter = filter);
    final result = _all.where((m) {
      final name = (m['name'] ?? '').toLowerCase();
      final matchSearch = q.isEmpty || name.contains(q.toLowerCase());
      final matchFilter = filter == 'All'
          || (filter == 'Active' && (m['status'] ?? '') == 'active')
          || (filter == 'Expired' && (m['status'] ?? '') == 'expired')
          || (filter == 'Due' && !(m['paid'] ?? true));
      return matchSearch && matchFilter;
    }).toList();
    setState(() => _filtered = result);
  }

  // ── Stat helpers ──────────────────────────────────────────────────────────
  int get _activeCount => _all.where((m) => m['status'] == 'active').length;
  int get _expiredCount => _all.where((m) => m['status'] == 'expired').length;
  int get _dueCount => _all.where((m) => !(m['paid'] ?? true)).length;

  @override
  Widget build(BuildContext context) {
    final barProgress = (_scrollOffset / 50).clamp(0.0, 1.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        floatingActionButton: _buildFAB(),
        body: Stack(
          children: [
            // ── ambient glow ──────────────────────────────────────────────
            _AmbientBg(ctrl: _ambientCtrl),

            // ── CONTENT ──────────────────────────────────────────────────
            AnimatedBuilder(
              animation: _entryCtrl,
              builder: (_, child) {
                final t = CurvedAnimation(
                    parent: _entryCtrl, curve: Curves.easeOutCubic).value;
                return Opacity(
                    opacity: t,
                    child: Transform.translate(
                        offset: Offset(0, 18 * (1 - t)), child: child));
              },
              child: CustomScrollView(
                controller: _scrollCtrl,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // top space for app bar
                  const SliverToBoxAdapter(child: SizedBox(height: 90)),

                  // ── STATS ROW ──────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _StatsRow(
                      total: _all.length,
                      active: _activeCount,
                      expired: _expiredCount,
                      due: _dueCount,
                    ),
                  ),

                  // ── SEARCH ────────────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _SearchBar(
                      controller: _searchCtrl,
                      onChanged: _search,
                    ),
                  ),

                  // ── FILTER CHIPS ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _FilterRow(
                      filters: _filters,
                      active: _activeFilter,
                      onSelect: (f) => _applyFilters(
                          _searchCtrl.text.trim(), f),
                    ),
                  ),

                  // ── SECTION LABEL ─────────────────────────────────────
                  SliverToBoxAdapter(
                    child: _SectionLabel(
                      label: _activeFilter == 'All'
                          ? 'All Members'
                          : '$_activeFilter Members',
                      count: _filtered.length,
                    ),
                  ),

                  // ── LIST ──────────────────────────────────────────────
                  if (_loading)
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (_, i) => _SkeletonCard(index: i),
                        childCount: 6,
                      ),
                    )
                  else if (_filtered.isEmpty)
                    const SliverToBoxAdapter(child: _EmptyState())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (ctx, i) {
                            final m = _filtered[i];
                            return _StaggerItem(
                              index: i,
                              ctrl: _entryCtrl,
                              child: MemberCard(
                                name: m['name'] ?? '',
                                joinDate: m['join_date'] ?? '',
                                expiry: m['expiry_date'] ?? '',
                                attendance: (m['attendance'] ?? 0).toDouble(),
                                plan: m['plan'] ?? 'Basic',
                                paid: m['paid'] ?? false,
                                status: m['status'] ?? 'active',
                              ),
                            );
                          },
                          childCount: _filtered.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── FLOATING APP BAR ─────────────────────────────────────────
            _AppBar(progress: barProgress),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, a, b) => const AddMemberScreen(),
            transitionsBuilder: (_, a, b, child) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1), end: Offset.zero,
              ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 380),
          ),
        );
      },
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _gold,
          boxShadow: [
            BoxShadow(
              color: _gold.withOpacity(0.45),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.person_add_rounded, color: Colors.black, size: 24),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// FLOATING APP BAR
// ═════════════════════════════════════════════════════════════════════════════
class _AppBar extends StatelessWidget {
  final double progress;
  const _AppBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: _bg.withOpacity(0.75 + progress * 0.2),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.04 + progress * 0.04),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 60,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    // back
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: _surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: _border, width: 0.5),
                        ),
                        child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: _textPri, size: 15),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Members',
                        style: TextStyle(
                          color: _textPri,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    // sort icon
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: _surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: _border, width: 0.5),
                      ),
                      child: const Icon(Icons.sort_rounded,
                          color: _textSec, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// STATS ROW
// ═════════════════════════════════════════════════════════════════════════════
class _StatsRow extends StatelessWidget {
  final int total, active, expired, due;
  const _StatsRow({
    required this.total, required this.active,
    required this.expired, required this.due,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          _StatTile(value: '$total', label: 'Total', accent: _gold),
          const SizedBox(width: 10),
          _StatTile(value: '$active', label: 'Active', accent: _green),
          const SizedBox(width: 10),
          _StatTile(value: '$expired', label: 'Expired', accent: _red),
          const SizedBox(width: 10),
          _StatTile(value: '$due', label: 'Due', accent: const Color(0xFFF59E0B)),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value, label;
  final Color accent;
  const _StatTile({required this.value, required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border, width: 0.5),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                  color: accent,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                )),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                  color: _textSec,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                )),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SEARCH BAR
// ═════════════════════════════════════════════════════════════════════════════
class _SearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _focused = _focus.hasFocus));
  }

  @override
  void dispose() { _focus.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _focused ? _gold.withOpacity(0.5) : _border,
            width: _focused ? 1.0 : 0.5,
          ),
          boxShadow: _focused
              ? [BoxShadow(color: _gold.withOpacity(0.1), blurRadius: 20)]
              : [],
        ),
        height: 50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: _focused ? _gold : _textSec,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  onChanged: widget.onChanged,
                  style: const TextStyle(
                      color: _textPri, fontSize: 14, fontWeight: FontWeight.w500),
                  decoration: const InputDecoration(
                    hintText: 'Search members…',
                    hintStyle: TextStyle(color: _textTer, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (widget.controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    widget.controller.clear();
                    widget.onChanged('');
                  },
                  child: Icon(Icons.close_rounded, color: _textSec, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// FILTER ROW
// ═════════════════════════════════════════════════════════════════════════════
class _FilterRow extends StatelessWidget {
  final List<String> filters;
  final String active;
  final ValueChanged<String> onSelect;
  const _FilterRow({required this.filters, required this.active, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filters.length,
        itemBuilder: (_, i) {
          final f = filters[i];
          final isActive = f == active;
          return GestureDetector(
            onTap: () => onSelect(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? _gold : _surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? _gold : _border,
                  width: 0.5,
                ),
              ),
              child: Text(
                f,
                style: TextStyle(
                  color: isActive ? Colors.black : _textSec,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SECTION LABEL
// ═════════════════════════════════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String label;
  final int count;
  const _SectionLabel({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: _textPri,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _goldDim,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _gold.withOpacity(0.2), width: 0.5),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                  color: _gold, fontSize: 10, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// MEMBER CARD — ultra premium
// ═════════════════════════════════════════════════════════════════════════════
class MemberCard extends StatefulWidget {
  final String name, joinDate, expiry, plan, status;
  final double attendance;
  final bool paid;

  const MemberCard({
    super.key,
    required this.name,
    required this.joinDate,
    required this.expiry,
    required this.attendance,
    required this.plan,
    required this.paid,
    required this.status,
  });

  @override
  State<MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<MemberCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 80),
        reverseDuration: const Duration(milliseconds: 160));
  }

  @override
  void dispose() { _press.dispose(); super.dispose(); }

  Color get _planColor {
    switch (widget.plan.toLowerCase()) {
      case 'gold':    return const Color(0xFFFFB020);
      case 'premium': return const Color(0xFFA855F7);
      default:        return _textSec;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) => _press.reverse(),
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: _press,
        builder: (_, child) =>
            Transform.scale(scale: 1 - .02 * _press.value, child: child),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar
                    _Avatar(name: widget.name, plan: widget.plan),
                    const SizedBox(width: 14),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(
                              color: _textPri,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 11, color: _textTer),
                              const SizedBox(width: 4),
                              Text(
                                'Joined ${widget.joinDate}',
                                style: const TextStyle(
                                    color: _textSec,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.event_rounded,
                                  size: 11, color: _textTer),
                              const SizedBox(width: 4),
                              Text(
                                'Expires ${widget.expiry}',
                                style: TextStyle(
                                  color: widget.status == 'expired'
                                      ? _red.withOpacity(0.8)
                                      : _textSec,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Right column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Plan badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: _planColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: _planColor.withOpacity(0.3), width: 0.5),
                          ),
                          child: Text(
                            widget.plan,
                            style: TextStyle(
                              color: _planColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Paid badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.paid
                                ? _green.withOpacity(0.1)
                                : _red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: widget.paid
                                  ? _green.withOpacity(0.3)
                                  : _red.withOpacity(0.3),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.paid
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: widget.paid ? _green : _red,
                                size: 10,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.paid ? 'Paid' : 'Due',
                                style: TextStyle(
                                  color: widget.paid ? _green : _red,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Attendance bar
                _AttendanceBar(attendance: widget.attendance),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Avatar with initials ─────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String name, plan;
  const _Avatar({required this.name, required this.plan});

  String get _initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color get _bg {
    final colors = [
      const Color(0xFF1E2D1E), const Color(0xFF2D1E1E),
      const Color(0xFF1E1E2D), const Color(0xFF2D2A1E),
    ];
    return colors[name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50, height: 50,
      decoration: BoxDecoration(
        color: _bg,
        shape: BoxShape.circle,
        border: Border.all(
          color: plan.toLowerCase() == 'gold'
              ? const Color(0xFFFFB020).withOpacity(0.4)
              : plan.toLowerCase() == 'premium'
              ? const Color(0xFFA855F7).withOpacity(0.4)
              : _border,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          _initials,
          style: const TextStyle(
            color: _textPri,
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ─── Attendance progress bar ─────────────────────────────────────────────────
class _AttendanceBar extends StatelessWidget {
  final double attendance;
  const _AttendanceBar({required this.attendance});

  Color get _barColor {
    if (attendance >= 80) return _green;
    if (attendance >= 50) return _gold;
    return _red;
  }

  @override
  Widget build(BuildContext context) {
    final pct = (attendance / 100).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ATTENDANCE',
              style: TextStyle(
                color: _textTer,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              '${attendance.toInt()}%',
              style: TextStyle(
                color: _barColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: _surface2,
            valueColor: AlwaysStoppedAnimation(_barColor),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// SKELETON LOADER
// ═════════════════════════════════════════════════════════════════════════════
class _SkeletonCard extends StatefulWidget {
  final int index;
  const _SkeletonCard({required this.index});

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
  }
  @override void dispose() { _shimmer.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmer,
      builder: (_, __) {
        final t = _shimmer.value;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _border, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.lerp(_surface, _surface2, t),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 13,
                      decoration: BoxDecoration(
                        color: Color.lerp(_surface, _surface2, t),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Color.lerp(_surface, _surface2, t * 0.7),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ═════════════════════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _surface,
              border: Border.all(color: _border, width: 0.5),
            ),
            child: const Center(
              child: Icon(Icons.people_outline_rounded,
                  color: _textTer, size: 30),
            ),
          ),
          const SizedBox(height: 18),
          const Text('No members found',
              style: TextStyle(
                  color: _textPri,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3)),
          const SizedBox(height: 6),
          const Text('Try a different search or filter',
              style: TextStyle(color: _textSec, fontSize: 13),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// STAGGER ITEM
// ═════════════════════════════════════════════════════════════════════════════
class _StaggerItem extends StatelessWidget {
  final int index;
  final AnimationController ctrl;
  final Widget child;
  const _StaggerItem({required this.index, required this.ctrl, required this.child});

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.05).clamp(0.0, 0.7);
    final end   = (start + 0.4).clamp(0.0, 1.0);
    final anim  = CurvedAnimation(
      parent: ctrl,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (_, ch) => Opacity(
        opacity: anim.value.clamp(0, 1),
        child: Transform.translate(
            offset: Offset(0, 20 * (1 - anim.value)), child: ch),
      ),
      child: child,
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// AMBIENT BACKGROUND
// ═════════════════════════════════════════════════════════════════════════════
class _AmbientBg extends StatelessWidget {
  final AnimationController ctrl;
  const _AmbientBg({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) {
        final t = ctrl.value;
        return Stack(children: [
          Positioned(
            top: -80 + t * 14,
            right: -60,
            child: Container(
              width: 240, height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  _gold.withOpacity(0.04 + 0.02 * t),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: 200 - t * 10,
            left: -80,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  Colors.white.withOpacity(0.015 + 0.005 * t),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
        ]);
      },
    );
  }
}