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
const kAmber     = Color(0xFFFFB300);
const kOrange    = Color(0xFFE65C00);

class TotalDetailScreen extends StatefulWidget {
  final String period;
  final int members, revenue, visits, total;

  const TotalDetailScreen({
    super.key,
    required this.period,
    required this.members,
    required this.revenue,
    required this.visits,
    required this.total,
  });

  @override
  State<TotalDetailScreen> createState() => _TotalDetailScreenState();
}

class _TotalDetailScreenState extends State<TotalDetailScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tab;
  String _filterType = "All";

  final List<_Activity> _activities = [
    _Activity("Ravi Menon joined",      "Gold Plan · New Member",       "Member",   "10:30 AM", "12 Mar", Icons.person_add_rounded,      Color(0xFF3DDC84), "+₹2500"),
    _Activity("Priya Nair renewed",     "Silver Plan · Renewal",        "Payment",  "08:15 AM", "12 Mar", Icons.currency_rupee_rounded,  kGold,             "+₹1500"),
    _Activity("App opened",             "Android · Mumbai",              "Visit",    "07:45 AM", "12 Mar", Icons.phone_android_rounded,   Color(0xFF1A73E8),  "Visit"),
    _Activity("Sneha Ramesh enrolled",  "Basic Plan · New Member",      "Member",   "06:48 AM", "12 Mar", Icons.person_add_rounded,      Color(0xFF3DDC84), "+₹800"),
    _Activity("App opened",             "iOS · Kochi",                   "Visit",    "07:00 AM", "11 Mar", Icons.apple_rounded,           kText1,             "Visit"),
    _Activity("Mohammed Farhan paid",   "Gold Plan · New",               "Payment",  "07:05 AM", "11 Mar", Icons.currency_rupee_rounded,  kGold,             "+₹2500"),
    _Activity("Equipment alert",        "Treadmill #2 · Maintenance",   "Alert",    "09:00 AM", "11 Mar", Icons.warning_amber_rounded,   kOrange,            "Check"),
    _Activity("Kiran Thomas renewed",   "Basic Plan · Renewal",         "Payment",  "11:00 AM", "10 Mar", Icons.currency_rupee_rounded,  kGold,             "+₹800"),
    _Activity("App opened",             "Web Browser · Thrissur",        "Visit",    "02:15 PM", "10 Mar", Icons.web_rounded,             Color(0xFF1A73E8),  "Visit"),
    _Activity("Ananya Pillai joined",   "Gold Plan · New Member",       "Member",   "11:22 AM", "09 Mar", Icons.person_add_rounded,      Color(0xFF3DDC84), "+₹2500"),
    _Activity("Electricity paid",       "March Bill · Expense",         "Expense",  "12:00 PM", "09 Mar", Icons.bolt_rounded,            kOrange,           "-₹2200"),
    _Activity("App opened",             "Android · Bangalore",           "Visit",    "05:30 PM", "08 Mar", Icons.phone_android_rounded,   Color(0xFF3DDC84), "Visit"),
  ];

  List<_Activity> get _filtered =>
      _filterType == "All" ? _activities : _activities.where((a) => a.type == _filterType).toList();

  // Type counts
  int _count(String t) => _activities.where((a) => a.type == t).length;

  // Colors per type
  Color _typeColor(String t) {
    switch (t) {
      case "Member":  return const Color(0xFF3DDC84);
      case "Payment": return kGoldDark;
      case "Visit":   return const Color(0xFF1A73E8);
      case "Alert":   return kOrange;
      case "Expense": return Colors.red;
      default:        return kText2;
    }
  }

  Color _typeBg(String t) => _typeColor(t).withOpacity(0.1);

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 5, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) {
        final types = ["All", "Member", "Payment", "Visit", "Alert"];
        setState(() => _filterType = types[_tab.index]);
      }
    });
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  String _fmtRevenue(int v) {
    if (v >= 100000) return "₹${(v/100000).toStringAsFixed(1)}L";
    if (v >= 1000)   return "₹${(v/1000).toStringAsFixed(0)}K";
    return "₹$v";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _buildHeader(context),
          _buildTabs(),
          const SizedBox(height: 8),
          Expanded(
            child: _filtered.isEmpty
                ? _emptyState()
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              physics: const BouncingScrollPhysics(),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _ActivityCard(
                activity: _filtered[i],
                typeColor: _typeColor(_filtered[i].type),
                typeBg: _typeBg(_filtered[i].type),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      color: kSurface,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: kSurface2,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kBorder),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: kText1),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TOTAL ACTIVITY · ${widget.period.toUpperCase()}",
                          style: const TextStyle(color: kText2, fontSize: 10, letterSpacing: 1.3, fontWeight: FontWeight.w700),
                        ),
                        const Text(
                          "Activity Overview",
                          style: TextStyle(color: kText1, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                        ),
                      ],
                    ),
                  ),
                  // Total badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      widget.total.toString(),
                      style: const TextStyle(color: kGoldDark, fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── 4-STAT SUMMARY ROW ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Row(
                children: [
                  Expanded(child: _SummaryBox(
                    widget.members.toString(), "Members",
                    Icons.people_rounded, const Color(0xFF3DDC84),
                    const Color(0xFF3DDC84).withOpacity(0.08),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _SummaryBox(
                    _fmtRevenue(widget.revenue), "Revenue",
                    Icons.currency_rupee_rounded, kGoldDark, kGoldLight,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _SummaryBox(
                    widget.visits.toString(), "Visits",
                    Icons.bar_chart_rounded, const Color(0xFF1A73E8),
                    const Color(0xFF1A73E8).withOpacity(0.08),
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _SummaryBox(
                    _count("Alert").toString(), "Alerts",
                    Icons.warning_amber_rounded, kOrange,
                    kOrange.withOpacity(0.08),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── BREAKDOWN BAR ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _BreakdownBar(
                members: widget.members,
                payments: _count("Payment"),
                visits: widget.visits,
                alerts: _count("Alert"),
                total: widget.total,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TAB BAR ───────────────────────────────────────────────
  Widget _buildTabs() {
    final types = ["All", "Member", "Payment", "Visit", "Alert"];
    final counts = [_activities.length, _count("Member"), _count("Payment"), _count("Visit"), _count("Alert")];

    return Container(
      color: kSurface,
      child: Column(
        children: [
          const Divider(color: kBorder, height: 0.5),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: List.generate(types.length, (i) {
                final sel = _filterType == types[i];
                final c = i == 0 ? kGoldDark : _typeColor(types[i]);
                final bg = i == 0 ? kGoldLight : _typeBg(types[i]);
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _filterType = types[i]);
                    _tab.animateTo(i);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? (i == 0 ? kGold : bg) : kSurface2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? (i == 0 ? kGold : c.withOpacity(0.35)) : kBorder,
                        width: sel ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          types[i],
                          style: TextStyle(
                            color: sel ? c : kText2,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: sel ? c.withOpacity(0.15) : kBorder,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            counts[i].toString(),
                            style: TextStyle(
                              color: sel ? c : kText2,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: kGoldLight, shape: BoxShape.circle), child: const Icon(Icons.search_off_rounded, color: kGoldDark, size: 28)),
      const SizedBox(height: 12),
      const Text("No activities found", style: TextStyle(color: kText2, fontSize: 14, fontWeight: FontWeight.w600)),
    ]),
  );
}

// ── Activity data model ───────────────────────────────────────
class _Activity {
  final String title, subtitle, type, time, date, value;
  final IconData icon;
  final Color iconColor;
  const _Activity(this.title, this.subtitle, this.type, this.time, this.date, this.icon, this.iconColor, this.value);
}

// ── Activity card ─────────────────────────────────────────────
class _ActivityCard extends StatelessWidget {
  final _Activity activity;
  final Color typeColor, typeBg;
  const _ActivityCard({super.key, required this.activity, required this.typeColor, required this.typeBg});

  bool get _isPositive => activity.value.startsWith("+");
  bool get _isNegative => activity.value.startsWith("-");

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          // Icon box
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: typeBg, borderRadius: BorderRadius.circular(14)),
            child: Icon(activity.icon, color: activity.iconColor, size: 20),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title,
                    style: const TextStyle(color: kText1, fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(activity.subtitle,
                    style: const TextStyle(color: kText2, fontSize: 11)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(activity.type,
                          style: TextStyle(color: typeColor, fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.access_time_rounded, size: 10, color: kText2),
                    const SizedBox(width: 3),
                    Text("${activity.time}  ·  ${activity.date}",
                        style: const TextStyle(color: kText2, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),

          // Value
          Text(
            activity.value,
            style: TextStyle(
              color: _isPositive ? Colors.green : _isNegative ? Colors.red : kText2,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Summary box (top row) ─────────────────────────────────────
class _SummaryBox extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color, bg;
  const _SummaryBox(this.value, this.label, this.icon, this.color, this.bg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        Text(label,
            style: const TextStyle(color: kText2, fontSize: 9, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

// ── Breakdown segmented bar ───────────────────────────────────
class _BreakdownBar extends StatelessWidget {
  final int members, payments, visits, alerts, total;
  const _BreakdownBar({
    required this.members, required this.payments,
    required this.visits,  required this.alerts, required this.total,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();

    final segments = [
      _Seg("Members",  members,  const Color(0xFF3DDC84)),
      _Seg("Payments", payments, kGold),
      _Seg("Visits",   visits,   const Color(0xFF1A73E8)),
      _Seg("Alerts",   alerts,   kOrange),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("BREAKDOWN",
            style: TextStyle(color: kText2, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.3)),
        const SizedBox(height: 8),
        // Segmented bar
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: SizedBox(
            height: 8,
            child: Row(
              children: segments.map((s) {
                final flex = s.count > 0 ? s.count : 0;
                return flex == 0
                    ? const SizedBox.shrink()
                    : Expanded(
                  flex: flex,
                  child: Container(color: s.color),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: segments.map((s) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
              const SizedBox(width: 5),
              Text(
                "${s.label} ${s.count}",
                style: const TextStyle(color: kText2, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          )).toList(),
        ),
      ],
    );
  }
}

class _Seg {
  final String label;
  final int count;
  final Color color;
  const _Seg(this.label, this.count, this.color);
}


// ─────────────────────────────────────────────────────────────
// HOW TO WIRE UP IN analytics_card_with_total.dart
//
// 1. Add import at top:
//    import '../analytics/total_detail_screen.dart';
//
// 2. Replace the Total _BotStat onTap:
//
//   Expanded(child: _BotStat(
//     d.total.toString(), "Total", kGoldDark,
//     onTap: () => _go(context, TotalDetailScreen(   // ← was onTap: () {}
//       period:  period,
//       members: d.members,
//       revenue: d.revenue,
//       visits:  d.visits,
//       total:   d.total,
//     )),
//   )),
// ─────────────────────────────────────────────────────────────