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

class VisitsDetailScreen extends StatefulWidget {
  final String period;
  const VisitsDetailScreen({super.key, required this.period});
  @override
  State<VisitsDetailScreen> createState() => _VisitsDetailScreenState();
}

class _VisitsDetailScreenState extends State<VisitsDetailScreen> {
  String _search = "";

  final List<_Visit> _visits = [
    _Visit("V-001", "Ravi Menon",       "Android 14",     "10:32 AM", "12 Mar 2025", "Mumbai, MH",   "192.168.1.10", "Gold"),
    _Visit("V-002", "Priya Nair",       "iOS 17",          "08:17 AM", "12 Mar 2025", "Kochi, KL",    "192.168.1.22", "Silver"),
    _Visit("V-003", "Sneha Ramesh",     "Android 13",     "06:48 AM", "12 Mar 2025", "Pune, MH",     "10.0.0.5",     "Basic"),
    _Visit("V-004", "Mohammed Farhan",  "iOS 16",          "07:05 AM", "11 Mar 2025", "Kochi, KL",    "192.168.0.45", "Gold"),
    _Visit("V-005", "Kiran Thomas",     "Web Browser",    "09:00 AM", "11 Mar 2025", "Thrissur, KL", "203.0.113.12", "Basic"),
    _Visit("V-006", "Ananya Pillai",    "Android 14",     "11:22 AM", "11 Mar 2025", "Bangalore, KA","192.168.2.88", "Gold"),
    _Visit("V-007", "Ajith Kumar",      "iOS 17",          "02:15 PM", "10 Mar 2025", "Chennai, TN",  "172.16.0.1",   "Gold"),
    _Visit("V-008", "Divya Suresh",     "Web Browser",    "05:30 PM", "10 Mar 2025", "Kochi, KL",    "192.168.1.99", "Silver"),
    _Visit("V-009", "Ravi Menon",       "Android 14",     "08:00 AM", "09 Mar 2025", "Mumbai, MH",   "192.168.1.10", "Gold"),
    _Visit("V-010", "Priya Nair",       "iOS 17",          "07:45 AM", "08 Mar 2025", "Kochi, KL",    "192.168.1.22", "Silver"),
  ];

  List<_Visit> get _filtered => _visits.where((v) =>
  v.name.toLowerCase().contains(_search.toLowerCase()) ||
      v.id.toLowerCase().contains(_search.toLowerCase()) ||
      v.location.toLowerCase().contains(_search.toLowerCase())
  ).toList();

  // Count per platform
  int _count(String platform) => _visits.where((v) => v.platform.contains(platform)).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _buildHeader(context),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(color: kText1, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Search by name, ID, location...",
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
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              physics: const BouncingScrollPhysics(),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _VisitCard(visit: _filtered[i]),
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
                Text("App Visits · ${widget.period}", style: const TextStyle(color: kText2, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
                const Text("Visit Log", style: TextStyle(color: kText1, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(8)),
                child: Text(_visits.length.toString(), style: const TextStyle(color: kGoldDark, fontSize: 13, fontWeight: FontWeight.w900)),
              ),
            ]),
            const SizedBox(height: 14),
            // Platform stats
            Row(children: [
              _PlatformChip(Icons.android_rounded, "Android", _count("Android"), const Color(0xFF3DDC84), const Color(0xFF3DDC84).withOpacity(0.1)),
              const SizedBox(width: 8),
              _PlatformChip(Icons.apple_rounded, "iOS", _count("iOS"), kText1, kSurface2),
              const SizedBox(width: 8),
              _PlatformChip(Icons.web_rounded, "Web", _count("Web"), const Color(0xFF1A73E8), const Color(0xFF1A73E8).withOpacity(0.1)),
            ]),
          ],
        ),
      ),
    ),
  );
}

class _Visit {
  final String id, name, platform, time, date, location, ip, plan;
  const _Visit(this.id, this.name, this.platform, this.time, this.date, this.location, this.ip, this.plan);
}

class _VisitCard extends StatelessWidget {
  final _Visit visit;
  const _VisitCard({super.key, required this.visit});

  Color get _platformColor =>
      visit.platform.contains("Android") ? const Color(0xFF3DDC84) :
      visit.platform.contains("iOS") ? kText1 : const Color(0xFF1A73E8);

  IconData get _platformIcon =>
      visit.platform.contains("Android") ? Icons.android_rounded :
      visit.platform.contains("iOS") ? Icons.apple_rounded : Icons.web_rounded;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kSurface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: kBorder),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: _platformColor.withOpacity(0.1), borderRadius: BorderRadius.circular(13)),
            child: Icon(_platformIcon, color: _platformColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(visit.name, style: const TextStyle(color: kText1, fontSize: 14, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: kGoldLight, borderRadius: BorderRadius.circular(6)), child: Text(visit.plan, style: const TextStyle(color: kGoldDark, fontSize: 9, fontWeight: FontWeight.w700))),
            ]),
            const SizedBox(height: 2),
            Text(visit.platform, style: const TextStyle(color: kText2, fontSize: 11)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(visit.time, style: const TextStyle(color: kText1, fontSize: 12, fontWeight: FontWeight.w700)),
            Text(visit.date, style: const TextStyle(color: kText2, fontSize: 10)),
          ]),
        ]),
        const SizedBox(height: 12),
        const Divider(color: kBorder, height: 0.5),
        const SizedBox(height: 10),
        // Detail row
        Row(children: [
          _DetailItem(Icons.tag_rounded, "ID", visit.id),
          const SizedBox(width: 16),
          _DetailItem(Icons.location_on_rounded, "Location", visit.location),
          const SizedBox(width: 16),
          _DetailItem(Icons.router_rounded, "IP", visit.ip),
        ]),
      ],
    ),
  );
}

class _DetailItem extends StatelessWidget {
  final IconData icon; final String label, value;
  const _DetailItem(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 11, color: kText2),
    const SizedBox(width: 4),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: kText2, fontSize: 8, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
      Text(value, style: const TextStyle(color: kText1, fontSize: 10, fontWeight: FontWeight.w700)),
    ]),
  ]);
}

class _PlatformChip extends StatelessWidget {
  final IconData icon; final String label; final int count; final Color color, bg;
  const _PlatformChip(this.icon, this.label, this.count, this.color, this.bg);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 14),
      const SizedBox(width: 5),
      Text("$label: $count", style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    ]),
  );
}