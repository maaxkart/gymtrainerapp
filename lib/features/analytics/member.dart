import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const kGold      = Color(0xFFC8DC32);
const kGoldDark  = Color(0xFF8FA000);
const kGoldLight = Color(0xFFF5F8D6);
const kBg        = Color(0xFFF7F7F5);
const kSurface   = Color(0xFFFFFFFF);
const kSurface2  = Color(0xFFF5F5F5);
const kBorder    = Color(0xFFEFEFEF);
const kText1     = Color(0xFF111111);
const kText2     = Color(0xFFAAAAAA);

class MembersDetailScreen extends StatefulWidget {
  final String period;
  const MembersDetailScreen({super.key, required this.period});
  @override
  State<MembersDetailScreen> createState() => _MembersDetailScreenState();
}

class _MembersDetailScreenState extends State<MembersDetailScreen> {
  String _search = "";
  String _filter = "All";

  final List<_Member> _members = [
    _Member("Ravi Menon",      "Gold Plan",   "Active",   "₹2500", "12 Mar 2025", "15 Apr 2025", "10:30 AM"),
    _Member("Priya Nair",      "Silver Plan", "Active",   "₹1500", "05 Mar 2025", "05 Apr 2025", "08:15 AM"),
    _Member("Ajith Kumar",     "Gold Plan",   "Inactive", "₹2500", "01 Feb 2025", "01 Mar 2025", "—"),
    _Member("Sneha Ramesh",    "Basic Plan",  "Active",   "₹800",  "20 Mar 2025", "20 Apr 2025", "06:45 AM"),
    _Member("Mohammed Farhan", "Gold Plan",   "Active",   "₹2500", "18 Mar 2025", "18 Apr 2025", "07:00 AM"),
    _Member("Divya Suresh",    "Silver Plan", "Expired",  "₹1500", "15 Jan 2025", "15 Feb 2025", "—"),
    _Member("Kiran Thomas",    "Basic Plan",  "Active",   "₹800",  "10 Mar 2025", "10 Apr 2025", "09:00 AM"),
    _Member("Ananya Pillai",   "Gold Plan",   "Active",   "₹2500", "22 Mar 2025", "22 Apr 2025", "11:00 AM"),
  ];

  List<_Member> get _filtered => _members.where((m) {
    final matchSearch = m.name.toLowerCase().contains(_search.toLowerCase());
    final matchFilter = _filter == "All" || m.status == _filter;
    return matchSearch && matchFilter;
  }).toList();

  int get _activeCount   => _members.where((m) => m.status == "Active").length;
  int get _inactiveCount => _members.where((m) => m.status == "Inactive").length;
  int get _expiredCount  => _members.where((m) => m.status == "Expired").length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _buildHeader(context),
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: kText1, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Search members...",
                hintStyle: const TextStyle(color: kText2, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: kText2, size: 20),
                filled: true, fillColor: kSurface,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kBorder)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kGold, width: 1.5)),
              ),
            ),
          ),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: ["All", "Active", "Inactive", "Expired"].map((f) {
                final sel = _filter == f;
                final count = f == "All" ? _members.length : f == "Active" ? _activeCount : f == "Inactive" ? _inactiveCount : _expiredCount;
                return GestureDetector(
                  onTap: () { HapticFeedback.lightImpact(); setState(() => _filter = f); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? kGold : kSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? kGold : kBorder),
                    ),
                    child: Row(children: [
                      Text(f, style: TextStyle(color: sel ? kGoldDark : kText2, fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: sel ? kGoldDark.withOpacity(0.15) : kSurface2, borderRadius: BorderRadius.circular(99)),
                        child: Text(count.toString(), style: TextStyle(color: sel ? kGoldDark : kText2, fontSize: 9, fontWeight: FontWeight.w800)),
                      ),
                    ]),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          // List
          Expanded(
            child: _filtered.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: kGoldLight, shape: BoxShape.circle), child: const Icon(Icons.search_off_rounded, color: kGoldDark, size: 28)),
              const SizedBox(height: 12),
              const Text("No members found", style: TextStyle(color: kText2, fontSize: 14, fontWeight: FontWeight.w600)),
            ]))
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              physics: const BouncingScrollPhysics(),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _MemberCard(member: _filtered[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Container(
    color: kSurface,
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)), child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: kText1)),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Members · ${widget.period}", style: const TextStyle(color: kText2, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
                const Text("All Members", style: TextStyle(color: kText1, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(8)),
                child: Text(_members.length.toString(), style: const TextStyle(color: kGoldDark, fontSize: 13, fontWeight: FontWeight.w900)),
              ),
            ]),
            const SizedBox(height: 16),
            // Summary row
            Row(children: [
              _SummaryChip("${_activeCount} Active", Colors.green, Colors.green.withOpacity(0.1)),
              const SizedBox(width: 8),
              _SummaryChip("${_inactiveCount} Inactive", Colors.orange, Colors.orange.withOpacity(0.1)),
              const SizedBox(width: 8),
              _SummaryChip("${_expiredCount} Expired", Colors.red, Colors.red.withOpacity(0.1)),
            ]),
          ],
        ),
      ),
    ),
  );
}

class _Member {
  final String name, plan, status, fee, joinDate, expiry, lastSeen;
  const _Member(this.name, this.plan, this.status, this.fee, this.joinDate, this.expiry, this.lastSeen);
}

class _MemberCard extends StatelessWidget {
  final _Member member;
  const _MemberCard({super.key, required this.member});

  Color get _statusColor => member.status == "Active" ? Colors.green : member.status == "Expired" ? Colors.red : Colors.orange;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kSurface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: kBorder),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))],
    ),
    child: Row(children: [
      Container(
        width: 46, height: 46,
        decoration: BoxDecoration(color: kGoldLight, shape: BoxShape.circle, border: Border.all(color: kGold.withOpacity(0.4), width: 1.5)),
        child: Center(child: Text(member.name[0].toUpperCase(), style: const TextStyle(color: kGoldDark, fontSize: 18, fontWeight: FontWeight.w900))),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(member.name, style: const TextStyle(color: kText1, fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(member.status, style: TextStyle(color: _statusColor, fontSize: 9, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 3),
          Text("${member.plan}  ·  Joined ${member.joinDate}", style: const TextStyle(color: kText2, fontSize: 11)),
          const SizedBox(height: 5),
          Row(children: [
            const Icon(Icons.calendar_today_rounded, size: 10, color: kText2),
            const SizedBox(width: 4),
            Text("Expires: ${member.expiry}", style: const TextStyle(color: kText2, fontSize: 10)),
            const SizedBox(width: 12),
            const Icon(Icons.access_time_rounded, size: 10, color: kText2),
            const SizedBox(width: 4),
            Text("Last: ${member.lastSeen}", style: const TextStyle(color: kText2, fontSize: 10)),
          ]),
        ]),
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(member.fee, style: const TextStyle(color: kGoldDark, fontSize: 14, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: kText2),
      ]),
    ]),
  );
}

class _SummaryChip extends StatelessWidget {
  final String label; final Color color, bg;
  const _SummaryChip(this.label, this.color, this.bg);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
  );
}