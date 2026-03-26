import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../payments/add_payment.dart';
import '../payments/balance_detailpage.dart'; // ← import the new page

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
const kRed        = Color(0xFFE53935);
const kRedBg      = Color(0xFFFFF3F3);
const kRedBorder  = Color(0xFFFFE0E0);
const kRedText    = Color(0xFFC62828);

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});
  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _payments = [
    {"name": "Rahul Das",    "plan": "Gold Plan",    "package": "Monthly",      "amount": "₹2,000",  "dueDate": "12 Feb", "due": true,  "regFee": false, "category": "thisMonth"},
    {"name": "Arjun Kumar",  "plan": "Premium Plan", "package": "Half Yearly",  "amount": "₹9,000",  "dueDate": "Paid",   "due": false, "regFee": false, "category": "thisMonth"},
    {"name": "Sneha Nair",   "plan": "Silver Plan",  "package": "Monthly",      "amount": "₹1,500",  "dueDate": "18 Feb", "due": true,  "regFee": false, "category": "pending"},
    {"name": "Vikram Raj",   "plan": "Gold Plan",    "package": "Yearly",       "amount": "₹15,000", "dueDate": "Paid",   "due": false, "regFee": false, "category": "thisMonth"},
    {"name": "Pooja Menon",  "plan": "Basic Plan",   "package": "Registration", "amount": "₹500",    "dueDate": "Paid",   "due": false, "regFee": true,  "category": "today"},
    {"name": "Ravi Sharma",  "plan": "Gold Plan",    "package": "Half Yearly",  "amount": "₹8,500",  "dueDate": "25 Feb", "due": true,  "regFee": false, "category": "pending"},
    {"name": "Meera Pillai", "plan": "Silver Plan",  "package": "Monthly",      "amount": "₹1,500",  "dueDate": "Paid",   "due": false, "regFee": false, "category": "today"},
    {"name": "Anil Verma",   "plan": "Gold Plan",    "package": "Quarterly",    "amount": "₹5,000",  "dueDate": "Paid",   "due": false, "regFee": false, "category": "thisMonth"},
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_selectedTab == 1) return _payments.where((p) => p["due"] == false).toList();
    if (_selectedTab == 2) return _payments.where((p) => p["due"] == true).toList();
    return _payments;
  }

  int get _paidCount         => _payments.where((p) => p["due"] == false).length;
  int get _dueCount          => _payments.where((p) => p["due"] == true).length;
  List<Map<String, dynamic>> get _thisMonthList => _payments.where((p) => p["category"] == "thisMonth").toList();
  List<Map<String, dynamic>> get _pendingList   => _payments.where((p) => p["category"] == "pending").toList();
  List<Map<String, dynamic>> get _todayList     => _payments.where((p) => p["category"] == "today").toList();

  void _goToDetail({
    required String title,
    required String totalAmount,
    required List<Map<String, dynamic>> items,
    required BalanceType type,
  }) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BalanceDetailPage(
          title: title,
          totalAmount: totalAmount,
          items: items,
          type: type,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildTopBar(context),
          _buildBalanceCard(),
          _buildFilterCards(),
          _buildSectionLabel(),
          _buildPaymentList(),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  // ── TOP BAR ──────────────────────────────────────────
  SliverToBoxAdapter _buildTopBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          color: kSurface,
          border: Border(bottom: BorderSide(color: kBorder)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: kSurface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorder),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: kText1),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text("Payments",
                  style: TextStyle(color: kText1, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
            ),
            GestureDetector(
              onTap: () async {
                HapticFeedback.lightImpact();
                final result = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPaymentScreen()),
                );
                if (result != null) setState(() => _payments.add(result));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(12)),
                child: const Text("+ ADD",
                    style: TextStyle(color: kGoldDeep, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── BALANCE CARD ─────────────────────────────────────
  SliverToBoxAdapter _buildBalanceCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("TOTAL BALANCE",
                  style: TextStyle(color: kGoldDeep, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
              const SizedBox(height: 6),
              const Text("₹45,000",
                  style: TextStyle(color: kText1, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1.5)),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _goToDetail(
                        title: "This Month",
                        totalAmount: "₹30K",
                        items: _thisMonthList,
                        type: BalanceType.thisMonth,
                      ),
                      child: const _BalStat("₹30K", "This Month"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _goToDetail(
                        title: "Pending",
                        totalAmount: "₹8K",
                        items: _pendingList,
                        type: BalanceType.pending,
                      ),
                      child: const _BalStat("₹8K", "Pending"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _goToDetail(
                        title: "Today",
                        totalAmount: "₹5K",
                        items: _todayList,
                        type: BalanceType.today,
                      ),
                      child: const _BalStat("₹5K", "Today"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── FILTER CARDS ──────────────────────────────────────
  SliverToBoxAdapter _buildFilterCards() {
    final tabs = [
      _TabInfo("All",  _payments.length, kText1,    kSurface2,  Icons.list_rounded),
      _TabInfo("Paid", _paidCount,        kGoldDark, kGoldLight, Icons.check_circle_rounded),
      _TabInfo("Due",  _dueCount,         kRed,      kRedBg,     Icons.access_time_rounded),
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final t   = tabs[i];
            final sel = _selectedTab == i;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedTab = i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  margin: EdgeInsets.only(right: i < tabs.length - 1 ? 10 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                  decoration: BoxDecoration(
                    color: sel ? (i == 0 ? kText1 : i == 1 ? kGold : kRed) : kSurface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: sel ? Colors.transparent : kBorder,
                      width: 1,
                    ),
                    boxShadow: sel
                        ? [BoxShadow(
                      color: (i == 0 ? kText1 : i == 1 ? kGold : kRed).withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )]
                        : [],
                  ),
                  child: Column(
                    children: [
                      Icon(t.icon, size: 20,
                          color: sel ? (i == 1 ? kGoldDeep : Colors.white) : t.color),
                      const SizedBox(height: 8),
                      Text(t.count.toString(),
                          style: TextStyle(
                            color: sel ? (i == 1 ? kGoldDeep : Colors.white) : kText1,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          )),
                      const SizedBox(height: 2),
                      Text(t.label.toUpperCase(),
                          style: TextStyle(
                            color: sel ? (i == 1 ? kGoldDeep : Colors.white70) : kText2,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          )),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── SECTION LABEL ─────────────────────────────────────
  SliverToBoxAdapter _buildSectionLabel() {
    final label = _selectedTab == 0
        ? "ALL TRANSACTIONS"
        : _selectedTab == 1
        ? "PAID TRANSACTIONS"
        : "DUE TRANSACTIONS";
    final count = _filtered.length;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(
                  color: kText2, fontSize: 10,
                  fontWeight: FontWeight.w700, letterSpacing: 1.5,
                )),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(20)),
              child: Text("$count records",
                  style: const TextStyle(color: kText2, fontSize: 10, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  // ── PAYMENT LIST ──────────────────────────────────────
  SliverList _buildPaymentList() {
    final list = _filtered;
    if (list.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate([
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(color: kSurface2, shape: BoxShape.circle),
                  child: Icon(
                    _selectedTab == 1
                        ? Icons.check_circle_outline_rounded
                        : Icons.access_time_rounded,
                    size: 28, color: kText2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _selectedTab == 1 ? "No paid records" : "No due records",
                  style: const TextStyle(
                    color: kText2, fontSize: 14, fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ]),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (ctx, i) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: _PaymentCard(data: list[i]),
        ),
        childCount: list.length,
      ),
    );
  }
}

// ── Tab info model ────────────────────────────────────────────
class _TabInfo {
  final String label;
  final int count;
  final Color color, bg;
  final IconData icon;
  const _TabInfo(this.label, this.count, this.color, this.bg, this.icon);
}

// ── BAL STAT ─────────────────────────────────────────────────
class _BalStat extends StatelessWidget {
  final String value, label;
  const _BalStat(this.value, this.label);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(.1),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      children: [
        Text(value,
            style: const TextStyle(
              color: kText1, fontSize: 16,
              fontWeight: FontWeight.w900, letterSpacing: -0.5,
            )),
        const SizedBox(height: 3),
        Text(label.toUpperCase(),
            style: const TextStyle(
              color: kGoldDeep, fontSize: 8,
              fontWeight: FontWeight.w700, letterSpacing: 0.8,
            )),
        const SizedBox(height: 4),
        const Icon(Icons.arrow_forward_ios_rounded, color: kGoldDeep, size: 9),
      ],
    ),
  );
}

// ── PAYMENT CARD ─────────────────────────────────────────────
class _PaymentCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PaymentCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final bool   isDue   = data["due"] as bool? ?? false;
    final bool   isReg   = data["regFee"] as bool? ?? false;
    final String name    = data["name"]?.toString()    ?? "";
    final String plan    = data["plan"]?.toString()    ?? "";
    final String pkg     = data["package"]?.toString() ?? "";
    final String amount  = data["amount"]?.toString()  ?? "";
    final String dueDate = data["dueDate"]?.toString() ?? "";

    final Color stripeColor = isDue ? kRed  : kGold;
    final Color amtColor    = isDue ? kRed  : kGoldDark;
    final Color borderColor = isDue ? kRedBorder : kGoldBorder;

    Color pkgColor = kGoldDark;
    Color pkgBg    = kGoldLight;
    if (pkg == "Half Yearly")  { pkgColor = const Color(0xFF1565C0); pkgBg = const Color(0xFFE3F2FD); }
    if (pkg == "Yearly")       { pkgColor = const Color(0xFF4A148C); pkgBg = const Color(0xFFF3E5F5); }
    if (pkg == "Registration") { pkgColor = const Color(0xFF00695C); pkgBg = const Color(0xFFE0F2F1); }
    if (pkg == "Quarterly")    { pkgColor = const Color(0xFF00695C); pkgBg = const Color(0xFFE0F2F1); }

    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          Container(width: 5, height: 100, color: stripeColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 0, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                        color: kText1, fontSize: 14, fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 3),
                  Text(plan, style: const TextStyle(color: kText2, fontSize: 11)),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: pkgBg, borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(pkg,
                            style: TextStyle(
                              color: pkgColor, fontSize: 9, fontWeight: FontWeight.w700,
                            )),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 5, height: 5,
                        decoration: BoxDecoration(color: stripeColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isDue ? "Due $dueDate" : isReg ? "Registration" : "Paid",
                        style: TextStyle(
                          color: amtColor, fontSize: 10, fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount,
                    style: TextStyle(
                      color: amtColor, fontSize: 15,
                      fontWeight: FontWeight.w900, letterSpacing: -0.3,
                    )),
                const SizedBox(height: 8),
                isDue
                    ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: kGold, borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text("Collect",
                      style: TextStyle(
                        color: kGoldDeep, fontSize: 11, fontWeight: FontWeight.w800,
                      )),
                )
                    : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: kGoldLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kGoldBorder),
                  ),
                  child: const Text("✓ Paid",
                      style: TextStyle(
                        color: kGoldDark, fontSize: 11, fontWeight: FontWeight.w800,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}