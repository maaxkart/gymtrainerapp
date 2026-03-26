import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/chat/memebers_list.dart';

// ── Brand tokens ───────────────────────────────────────────────
const _kGold      = Color(0xFFC8DC32);
const _kGoldDark  = Color(0xFF8FA000);
const _kGoldDeep  = Color(0xFF5C6900);
const _kGoldLight = Color(0xFFF5F8D6);
const _kGoldGlow  = Color(0x28C8DC32);
const _kBg        = Color(0xFFF7F7F5);
const _kSurface   = Color(0xFFFFFFFF);
const _kSurface2  = Color(0xFFF5F5F5);
const _kSurface3  = Color(0xFFEFEFEF);
const _kBorder    = Color(0xFFEFEFEF);
const _kBorder2   = Color(0xFFE0E0E0);
const _kText1     = Color(0xFF111111);
const _kText2     = Color(0xFFAAAAAA);
const _kText3     = Color(0xFFCCCCCC);
const _kGreen     = Color(0xFF22C55E);
const _kRed       = Color(0xFFEF4444);

// ═══════════════════════════════════════════════════════════════
// ENTRY POINT — routes to Inbox or DM
// ═══════════════════════════════════════════════════════════════
class ChatScreen extends StatelessWidget {
  final GymMember? member;
  const ChatScreen({super.key, this.member});

  @override
  Widget build(BuildContext context) {
    return member != null
        ? _DMPage(member: member!)
        : const _InboxPage();
  }
}

// ═══════════════════════════════════════════════════════════════
// INBOX PAGE
// ═══════════════════════════════════════════════════════════════
class _InboxPage extends StatefulWidget {
  const _InboxPage();

  @override
  State<_InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<_InboxPage>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  late AnimationController _fadeCtrl;
  String _query = '';

  // ── All members ───────────────────────────────────────────
  final List<_InboxItem> _items = [
    _InboxItem(member: const GymMember(name: "Ravi Menon",     plan: "Gold Plan",   phone: "+91 98765 43210", avatar: "RM", isActive: true,  distanceKm: 1.2, lastSeen: "Just now"),    preview: "Thanks coach! See you tomorrow 💪",   unread: 0),
    _InboxItem(member: const GymMember(name: "Priya Nair",     plan: "Silver Plan", phone: "+91 91234 56789", avatar: "PN", isActive: true,  distanceKm: 2.8, lastSeen: "5 mins ago"),  preview: "Can I change my session time?",        unread: 2),
    _InboxItem(member: const GymMember(name: "Sneha Ramesh",   plan: "Basic Plan",  phone: "+91 99887 76655", avatar: "SR", isActive: true,  distanceKm: 0.9, lastSeen: "12 mins ago"), preview: "Okay I will come by 7AM",              unread: 0),
    _InboxItem(member: const GymMember(name: "Mohammed Fasal", plan: "Gold Plan",   phone: "+91 88776 65544", avatar: "MF", isActive: true,  distanceKm: 4.1, lastSeen: "30 mins ago"), preview: "Payment done ✅",                      unread: 0),
    _InboxItem(member: const GymMember(name: "Kiran Thomas",   plan: "Basic Plan",  phone: "+91 77665 54433", avatar: "KT", isActive: true,  distanceKm: 3.5, lastSeen: "1 hr ago"),    preview: "Is the gym open on Sunday?",           unread: 1),
    _InboxItem(member: const GymMember(name: "Ajith Kumar",    plan: "Gold Plan",   phone: "+91 98765 11111", avatar: "AK", isActive: false, distanceKm: 6.3, lastSeen: "3 days ago"),  preview: "I'll renew next month",                unread: 0),
    _InboxItem(member: const GymMember(name: "Divya Suresh",   plan: "Silver Plan", phone: "+91 91234 22222", avatar: "DS", isActive: false, distanceKm: 8.1, lastSeen: "1 week ago"),  preview: "Not feeling well this week",           unread: 0),
    _InboxItem(member: const GymMember(name: "Rohit Sharma",   plan: "Basic Plan",  phone: "+91 99887 33333", avatar: "RS", isActive: false, distanceKm: 5.5, lastSeen: "2 weeks ago"), preview: "Please hold my membership",            unread: 0),
  ];

  List<_InboxItem> get _nearby {
    final list = _items.where((i) => i.member.distanceKm <= 5.0).toList();
    list.sort((a, b) => a.member.distanceKm.compareTo(b.member.distanceKm));
    return list;
  }

  List<_InboxItem> get _filtered => _query.isEmpty
      ? _items
      : _items.where((i) => i.member.name.toLowerCase().contains(_query.toLowerCase())).toList();

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _kBg,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App bar ─────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

            // ── Search ──────────────────────────────────────
            SliverToBoxAdapter(child: _buildSearch()),

            // ── Nearby story row ─────────────────────────────
            if (_query.isEmpty)
              SliverToBoxAdapter(child: _buildNearbyRow()),

            // ── Section label ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
                child: Text(
                  "ALL MESSAGES",
                  style: const TextStyle(
                      color: _kText3,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4),
                ),
              ),
            ),

            // ── Chat rows ────────────────────────────────────
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                  final item = _filtered[i];
                  return _DismissibleRow(
                    item: item,
                    index: i,
                    onDelete: () => setState(() => _items.remove(item)),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(ctx, _pageRoute(
                          _DMPage(member: item.member)));
                    },
                  );
                },
                childCount: _filtered.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: Row(children: [
          Expanded(
            child: Text("Messages",
                style: const TextStyle(
                    color: _kText1,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6)),
          ),
          GestureDetector(
            onTap: () => HapticFeedback.lightImpact(),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _kSurface2,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: _kBorder2),
              ),
              child: const Icon(Icons.edit_outlined, color: _kGold, size: 17),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Container(
        decoration: BoxDecoration(
          color: _kSurface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(color: _kText1, fontSize: 14),
          decoration: const InputDecoration(
            hintText: "Search messages…",
            hintStyle: TextStyle(color: _kText3, fontSize: 14),
            prefixIcon: Icon(Icons.search_rounded, color: _kText3, size: 18),
            border: InputBorder.none,
            contentPadding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyRow() {
    final nearby = _items
        .where((i) => i.member.distanceKm <= 5.0)
        .toList()
      ..sort((a, b) => a.member.distanceKm.compareTo(b.member.distanceKm));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        child: Row(children: [
          Container(
            width: 6, height: 6,
            decoration: const BoxDecoration(
                color: _kGold, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          const Text("NEARBY  ·  WITHIN 5KM",
              style: TextStyle(
                  color: _kGold,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2)),
        ]),
      ),
      SizedBox(
        height: 92,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: nearby.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (ctx, i) => _StoryBubble(
            item: nearby[i],
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(ctx,
                  _pageRoute(_DMPage(member: nearby[i].member)));
            },
          ),
        ),
      ),
      const SizedBox(height: 16),
      const Divider(color: _kBorder, height: 1),
    ]);
  }
}

// ── Story bubble ──────────────────────────────────────────────
class _StoryBubble extends StatefulWidget {
  final _InboxItem item;
  final VoidCallback onTap;
  const _StoryBubble({required this.item, required this.onTap});

  @override
  State<_StoryBubble> createState() => _StoryBubbleState();
}

class _StoryBubbleState extends State<_StoryBubble> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.item.member;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Column(children: [
          // Gradient ring
          Container(
            width: 62, height: 62,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_kGold, _kGoldDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: BoxDecoration(
                  color: _kSurface, shape: BoxShape.circle,
                  border: Border.all(color: _kBg, width: 1.5)),
              child: Center(
                child: Text(m.avatar,
                    style: const TextStyle(
                        color: _kGoldDark, fontSize: 13, fontWeight: FontWeight.w900)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(m.name.split(" ").first,
              style: const TextStyle(
                  color: _kText2, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 1),
          Text("${m.distanceKm}km",
              style: const TextStyle(
                  color: _kGoldDark, fontSize: 9, fontWeight: FontWeight.w800)),
        ]),
      ),
    );
  }
}

// ── Dismissible row with swipe-to-delete ─────────────────────
class _DismissibleRow extends StatelessWidget {
  final _InboxItem item;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  const _DismissibleRow({
    required this.item,
    required this.index,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.member.name),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_kBg, _kRed.withOpacity(0.15), _kRed.withOpacity(0.28)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: _kRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kRed.withOpacity(0.3)),
            ),
            child: const Icon(Icons.delete_outline_rounded,
                color: _kRed, size: 20),
          ),
          const SizedBox(height: 5),
          const Text("Delete",
              style: TextStyle(
                  color: _kRed, fontSize: 10, fontWeight: FontWeight.w700)),
        ]),
      ),
      confirmDismiss: (dir) async {
        HapticFeedback.mediumImpact();
        return await showDialog<bool>(
          context: context,
          barrierColor: Colors.black.withOpacity(0.7),
          builder: (_) => _DeleteDialog(name: item.member.name),
        ) ?? false;
      },
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        onDelete();
      },
      child: _InboxRow(item: item, onTap: onTap),
    );
  }
}

// ── Delete confirmation dialog ────────────────────────────────
class _DeleteDialog extends StatelessWidget {
  final String name;
  const _DeleteDialog({required this.name});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _kSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
                color: _kRed.withOpacity(0.12),
                shape: BoxShape.circle),
            child: const Icon(Icons.delete_outline_rounded,
                color: _kRed, size: 24),
          ),
          const SizedBox(height: 16),
          const Text("Delete Conversation",
              style: TextStyle(
                  color: _kText1,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            "Remove your chat with $name? This can't be undone.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: _kText2, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context, false),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: _kSurface2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _kBorder2),
                  ),
                  child: const Center(
                    child: Text("Cancel",
                        style: TextStyle(
                            color: _kText1,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.pop(context, true),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: _kRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _kRed.withOpacity(0.3)),
                  ),
                  child: const Center(
                    child: Text("Delete",
                        style: TextStyle(
                            color: _kRed,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

// ── Inbox row ─────────────────────────────────────────────────
class _InboxRow extends StatefulWidget {
  final _InboxItem item;
  final VoidCallback onTap;
  const _InboxRow({required this.item, required this.onTap});

  @override
  State<_InboxRow> createState() => _InboxRowState();
}

class _InboxRowState extends State<_InboxRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.item.member;
    final unread = widget.item.unread;
    final isNear = m.distanceKm <= 5.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _pressed ? _kSurface.withOpacity(0.6) : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(children: [
          // Avatar
          Stack(clipBehavior: Clip.none, children: [
            isNear
                ? Container(
              width: 56, height: 56,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [_kGold, _kGoldDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(2),
              child: Container(
                decoration: BoxDecoration(
                    color: _kSurface, shape: BoxShape.circle,
                    border: Border.all(color: _kBg, width: 1.5)),
                child: Center(
                  child: Text(m.avatar,
                      style: const TextStyle(
                          color: _kGold,
                          fontSize: 14,
                          fontWeight: FontWeight.w900)),
                ),
              ),
            )
                : Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: _kSurface2,
                shape: BoxShape.circle,
                border: Border.all(color: _kBorder2),
              ),
              child: Center(
                child: Text(m.avatar,
                    style: const TextStyle(
                        color: _kText2,
                        fontSize: 14,
                        fontWeight: FontWeight.w900)),
              ),
            ),
            // Online dot
            Positioned(
              bottom: 2, right: 2,
              child: Container(
                width: 13, height: 13,
                decoration: BoxDecoration(
                  color: m.isActive ? _kGreen : _kSurface3,
                  shape: BoxShape.circle,
                  border: Border.all(color: _kBg, width: 2.5),
                ),
              ),
            ),
          ]),
          const SizedBox(width: 14),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(m.name,
                        style: TextStyle(
                          color: unread > 0 ? Colors.white : _kText1,
                          fontSize: 15,
                          fontWeight: unread > 0
                              ? FontWeight.w800
                              : FontWeight.w600,
                          letterSpacing: -0.2,
                        )),
                  ),
                  Text(m.lastSeen,
                      style: TextStyle(
                        color: unread > 0 ? _kGold : _kText3,
                        fontSize: 10,
                        fontWeight: unread > 0
                            ? FontWeight.w700
                            : FontWeight.w400,
                      )),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  Expanded(
                    child: Text(widget.item.preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: unread > 0 ? _kText1 : _kText2,
                          fontSize: 12,
                          fontWeight: unread > 0
                              ? FontWeight.w500
                              : FontWeight.w400,
                        )),
                  ),
                  if (unread > 0)
                    Container(
                      width: 20, height: 20,
                      margin: const EdgeInsets.only(left: 8),
                      decoration: const BoxDecoration(
                          color: _kGold, shape: BoxShape.circle),
                      child: Center(
                        child: Text(unread.toString(),
                            style: const TextStyle(
                                color: Color(0xFF111111),
                                fontSize: 9,
                                fontWeight: FontWeight.w900)),
                      ),
                    ),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  _statusPill(m.isActive),
                  if (isNear) ...[
                    const SizedBox(width: 6),
                    _nearbyPill(m.distanceKm),
                  ],
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _statusPill(bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: active
            ? _kGreen.withOpacity(0.1)
            : _kRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: active
              ? _kGreen.withOpacity(0.2)
              : _kRed.withOpacity(0.2),
        ),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 5, height: 5,
          decoration: BoxDecoration(
              color: active ? _kGreen : _kRed, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(active ? "Active" : "Inactive",
            style: TextStyle(
                color: active ? _kGreen : _kRed,
                fontSize: 9,
                fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _nearbyPill(double dist) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _kGoldGlow,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: _kGold.withOpacity(0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.location_on_rounded, color: _kGold, size: 9),
        const SizedBox(width: 3),
        Text("${dist}km",
            style: const TextStyle(
                color: _kGoldDark, fontSize: 9, fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

// ── Inbox item model ───────────────────────────────────────────
class _InboxItem {
  final GymMember member;
  final String preview;
  final int unread;
  _InboxItem({required this.member, required this.preview, required this.unread});
}

// ═══════════════════════════════════════════════════════════════
// DM PAGE
// ═══════════════════════════════════════════════════════════════
class _DMPage extends StatefulWidget {
  final GymMember member;
  const _DMPage({required this.member});

  @override
  State<_DMPage> createState() => _DMPageState();
}

class _DMPageState extends State<_DMPage> with TickerProviderStateMixin {
  final _ctrl   = TextEditingController();
  final _scroll = ScrollController();
  bool _showSuggestions = true;
  bool _showTyping = false;

  late AnimationController _typingCtrl;

  static const _quickReplies = [
    "Your membership expires soon! 🔔",
    "Great progress this week 💪",
    "See you at 7AM tomorrow!",
    "Payment received ✅",
    "Upgrade to Gold Plan?",
    "Miss you at the gym 🏋️",
  ];

  final List<_Msg> _msgs = [
    _Msg(text: "Hey! Welcome to Power Gym 💪",                   me: false, minAgo: 12),
    _Msg(text: "Hi coach! Checking my plan details.",             me: true,  minAgo: 10),
    _Msg(text: "You're on Gold Plan — valid till 30 Apr 2025 ✅", me: false, minAgo: 9),
  ];

  @override
  void initState() {
    super.initState();
    _typingCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _typingCtrl.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _msgs.add(_Msg(text: text.trim(), me: true, minAgo: 0));
      _showSuggestions = false;
      _showTyping = true;
    });
    _ctrl.clear();
    _scrollDown();

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final replies = [
        "Got it! I'll sort that out 👍",
        "Sure thing!",
        "Thanks for letting me know 💪",
        "Awesome! See you soon 🏋️",
        "On it! 🔥",
      ];
      final reply = replies[DateTime.now().second % replies.length];
      setState(() {
        _showTyping = false;
        _msgs.add(_Msg(text: reply, me: false, minAgo: 0));
      });
      _scrollDown();
    });
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOut);
      }
    });
  }

  String _fmtTime(int minAgo) {
    final t = DateTime.now().subtract(Duration(minutes: minAgo));
    return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.member;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: _kBg,
        body: Column(children: [
          _buildHeader(context, m),
          const Divider(color: _kBorder, height: 1),
          Expanded(child: _buildMessages()),
          if (_showSuggestions) _buildQuickReplies(),
          _buildInputBar(),
        ]),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, GymMember m) {
    return Container(
      color: _kSurface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
          child: Row(children: [
            // Back
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: _kSurface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kBorder2),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 14, color: _kText1),
              ),
            ),
            const SizedBox(width: 12),

            // Avatar
            Stack(clipBehavior: Clip.none, children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: _kSurface3,
                  shape: BoxShape.circle,
                  border: Border.all(color: _kBorder2),
                ),
                child: Center(
                  child: Text(m.avatar,
                      style: const TextStyle(
                          color: _kGold,
                          fontSize: 12,
                          fontWeight: FontWeight.w900)),
                ),
              ),
              if (m.isActive)
                Positioned(
                  bottom: 0, right: 0,
                  child: Container(
                    width: 11, height: 11,
                    decoration: BoxDecoration(
                      color: _kGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: _kSurface, width: 2),
                    ),
                  ),
                ),
            ]),
            const SizedBox(width: 12),

            // Name + status
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.name,
                    style: const TextStyle(
                        color: _kText1,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3)),
                const SizedBox(height: 2),
                Row(children: [
                  if (m.isActive) ...[
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(
                          color: _kGreen, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 5),
                    Text("Active now",
                        style: TextStyle(
                            color: _kGreen.withOpacity(0.9),
                            fontSize: 11)),
                  ] else
                    const Text("Inactive",
                        style: TextStyle(color: _kText3, fontSize: 11)),
                  if (m.distanceKm <= 5.0) ...[
                    const Text("  ·  ",
                        style: TextStyle(color: _kText3, fontSize: 11)),
                    const Icon(Icons.location_on_rounded,
                        color: _kGold, size: 11),
                    Text(" ${m.distanceKm}km",
                        style: const TextStyle(
                            color: _kGold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ],
                ]),
              ]),
            ),

            // Info
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: _kSurface2,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: _kBorder),
              ),
              child: const Icon(Icons.info_outline_rounded,
                  color: _kText2, size: 17),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Messages list ──────────────────────────────────────────
  Widget _buildMessages() {
    return ListView.builder(
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      physics: const BouncingScrollPhysics(),
      itemCount: _msgs.length + (_showTyping ? 1 : 0),
      itemBuilder: (_, i) {
        if (_showTyping && i == _msgs.length) {
          return _buildTypingIndicator();
        }
        return _buildBubble(_msgs[i]);
      },
    );
  }

  // ── Bubble ─────────────────────────────────────────────────
  Widget _buildBubble(_Msg msg) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(msg.me ? (1 - v) * 20 : (1 - v) * -20, 0),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          mainAxisAlignment:
          msg.me ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!msg.me) ...[
              Container(
                width: 26, height: 26,
                decoration: const BoxDecoration(
                    color: _kSurface3, shape: BoxShape.circle),
                child: Center(
                  child: Text(widget.member.avatar[0],
                      style: const TextStyle(
                          color: _kGold,
                          fontSize: 9,
                          fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: msg.me
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onLongPress: () {
                      HapticFeedback.mediumImpact();
                      _showBubbleActions(context, msg);
                    },
                    child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.65),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 11),
                      decoration: BoxDecoration(
                        color: msg.me ? _kGold : _kSurface2,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(msg.me ? 18 : 4),
                          bottomRight: Radius.circular(msg.me ? 4 : 18),
                        ),
                        border: msg.me
                            ? null
                            : Border.all(color: _kBorder2),
                        boxShadow: msg.me
                            ? [BoxShadow(
                            color: _kGold.withOpacity(0.18),
                            blurRadius: 12, offset: const Offset(0, 4))]
                            : null,
                      ),
                      child: Text(msg.text,
                          style: TextStyle(
                              color: msg.me
                                  ? const Color(0xFF111111)
                                  : _kText1,
                              fontSize: 14,
                              height: 1.4)),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(_fmtTime(msg.minAgo),
                        style: const TextStyle(
                            color: _kText3, fontSize: 9)),
                  ),
                ],
              ),
            ),
            if (msg.me) const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  // ── Typing indicator ───────────────────────────────────────
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(
          width: 26, height: 26,
          decoration: const BoxDecoration(
              color: _kSurface3, shape: BoxShape.circle),
          child: Center(
            child: Text(widget.member.avatar[0],
                style: const TextStyle(
                    color: _kGoldDark, fontSize: 9, fontWeight: FontWeight.w900)),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _kSurface2,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(color: _kBorder2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              return AnimatedBuilder(
                animation: _typingCtrl,
                builder: (_, __) {
                  final delay = i * 0.2;
                  final t = ((_typingCtrl.value - delay) % 1.0).abs();
                  final y = (t < 0.5 ? t : 1 - t) * -6.0;
                  return Container(
                    margin: EdgeInsets.only(
                        right: i < 2 ? 4 : 0, bottom: y < 0 ? -y : 0),
                    width: 6, height: 6,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                          _kText3, _kGoldDark, (t < 0.5 ? t : 1 - t) * 2),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ]),
    );
  }

  // ── Bubble long-press menu ─────────────────────────────────
  void _showBubbleActions(BuildContext context, _Msg msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BubbleActionsSheet(msg: msg),
    );
  }

  // ── Quick replies ──────────────────────────────────────────
  Widget _buildQuickReplies() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickReplies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _send(_quickReplies[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _kBorder2),
            ),
            child: Text(_quickReplies[i],
                style: const TextStyle(
                    color: _kText1,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      ),
    );
  }

  // ── Input bar ─────────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      decoration: const BoxDecoration(
        color: _kBg,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: SafeArea(
        top: false,
        child: Row(children: [
          // Camera
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: _kSurface2,
                shape: BoxShape.circle,
                border: Border.all(color: _kBorder)),
            child: const Icon(Icons.camera_alt_outlined,
                color: _kText2, size: 17),
          ),
          const SizedBox(width: 10),

          // Text field pill
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _kSurface2,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: _kBorder),
              ),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(color: _kText1, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: "Message…",
                      hintStyle: TextStyle(color: _kText3, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 11),
                    ),
                    onSubmitted: _send,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(children: const [
                    Icon(Icons.emoji_emotions_outlined,
                        color: _kText3, size: 19),
                    SizedBox(width: 6),
                    Icon(Icons.mic_none_rounded, color: _kText3, size: 19),
                  ]),
                ),
              ]),
            ),
          ),
          const SizedBox(width: 10),

          // Send button
          GestureDetector(
            onTap: () => _send(_ctrl.text),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _kGold,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _kGold.withOpacity(0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded,
                  color: Color(0xFF111111), size: 17),
            ),
          ),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BUBBLE ACTIONS BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════
class _BubbleActionsSheet extends StatelessWidget {
  final _Msg msg;
  const _BubbleActionsSheet({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _kBorder2),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Drag handle
        Container(
          margin: const EdgeInsets.only(top: 10),
          width: 36, height: 4,
          decoration: BoxDecoration(
              color: _kSurface3, borderRadius: BorderRadius.circular(2)),
        ),

        // Reaction row
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ["❤️", "😂", "🔥", "💪", "👍", "😮"].map((e) =>
                GestureDetector(
                  onTap: () { HapticFeedback.lightImpact(); Navigator.pop(context); },
                  child: Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: _kSurface2,
                      shape: BoxShape.circle,
                      border: Border.all(color: _kBorder),
                    ),
                    child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                  ),
                )
            ).toList(),
          ),
        ),

        const Divider(color: _kBorder, height: 1),

        // Actions
        _sheetAction(context, Icons.reply_rounded, "Reply", onTap: () => Navigator.pop(context)),
        const Divider(color: _kBorder, height: 1, indent: 56),
        _sheetAction(context, Icons.copy_rounded, "Copy", onTap: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Copied to clipboard"),
              backgroundColor: _kSurface2,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }),
        const Divider(color: _kBorder, height: 1, indent: 56),
        _sheetAction(context, Icons.forward_rounded, "Forward", onTap: () => Navigator.pop(context)),
        const Divider(color: _kBorder, height: 1, indent: 56),
        _sheetAction(context, Icons.delete_outline_rounded, "Delete",
            color: _kRed,
            onTap: () => Navigator.pop(context)),

        const SizedBox(height: 12),
      ]),
    );
  }

  Widget _sheetAction(BuildContext context, IconData icon, String label,
      {Color? color, VoidCallback? onTap}) {
    final c = color ?? _kText1;
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap?.call(); },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: (color ?? _kGold).withOpacity(0.08),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: c, size: 17),
          ),
          const SizedBox(width: 14),
          Text(label, style: TextStyle(color: c, fontSize: 15, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

// ── Message model ─────────────────────────────────────────────
class _Msg {
  final String text;
  final bool   me;
  final int    minAgo;
  _Msg({required this.text, required this.me, required this.minAgo});
}

// ── Page route helper ─────────────────────────────────────────
Route _pageRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, anim, __) => page,
    transitionsBuilder: (_, anim, __, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 280),
  );
}