import 'package:flutter/material.dart';

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
  // 0 = All, 1 = Paid, 2 = Due
  int _selectedTab = 0;

  // Sample data — replace with API data
  final List<Map<String, dynamic>> _payments = [
    {
      "name":    "Rahul Das",
      "plan":    "Gold Plan",
      "amount":  "₹2,000",
      "dueDate": "12 Feb",
      "due":     true,
    },
    {
      "name":    "Arjun Kumar",
      "plan":    "Premium Plan",
      "amount":  "₹3,000",
      "dueDate": "Paid",
      "due":     false,
    },
    {
      "name":    "Sneha Nair",
      "plan":    "Silver Plan",
      "amount":  "₹1,500",
      "dueDate": "18 Feb",
      "due":     true,
    },
    {
      "name":    "Vikram Raj",
      "plan":    "Gold Plan",
      "amount":  "₹2,000",
      "dueDate": "Paid",
      "due":     false,
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_selectedTab == 1) return _payments.where((p) => p["due"] == false).toList();
    if (_selectedTab == 2) return _payments.where((p) => p["due"] == true).toList();
    return _payments;
  }

  int get _paidCount => _payments.where((p) => p["due"] == false).length;
  int get _dueCount  => _payments.where((p) => p["due"] == true).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildTopBar(context),
          _buildBalanceCard(),
          _buildSummaryStrip(),
          _buildFilterTabs(),
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
                "Payments",
                style: TextStyle(
                  color: kText1,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: kGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "+ ADD",
                style: TextStyle(
                  color: kGoldDeep,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
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
          decoration: BoxDecoration(
            color: kGold,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "TOTAL BALANCE",
                style: TextStyle(
                  color: kGoldDeep,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "₹45,000",
                style: TextStyle(
                  color: kText1,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _BalStat("₹30K", "This Month"),
                  const SizedBox(width: 10),
                  _BalStat("₹8K",  "Pending"),
                  const SizedBox(width: 10),
                  _BalStat("₹5K",  "Today"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── SUMMARY STRIP ─────────────────────────────────────
  SliverToBoxAdapter _buildSummaryStrip() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            _SummaryCard(
              value:       _paidCount.toString(),
              label:       "Paid",
              accentColor: kGold,
              iconBg:      kGoldLight,
              icon:        Icons.check_circle_outline_rounded,
              iconColor:   kGoldDark,
            ),
            const SizedBox(width: 10),
            _SummaryCard(
              value:       _dueCount.toString(),
              label:       "Due",
              accentColor: kRed,
              iconBg:      kRedBg,
              icon:        Icons.access_time_rounded,
              iconColor:   kRed,
            ),
            const SizedBox(width: 10),
            _SummaryCard(
              value:       _payments.length.toString(),
              label:       "Total",
              accentColor: kText1,
              iconBg:      kSurface2,
              icon:        Icons.people_outline_rounded,
              iconColor:   kText1,
            ),
          ],
        ),
      ),
    );
  }

  // ── FILTER TABS ──────────────────────────────────────
  SliverToBoxAdapter _buildFilterTabs() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kBorder, width: 1.5),
          ),
          child: Row(
            children: [
              _FilterTab(label: "All",  index: 0, selected: _selectedTab, onTap: (i) => setState(() => _selectedTab = i)),
              _FilterTab(label: "Paid", index: 1, selected: _selectedTab, onTap: (i) => setState(() => _selectedTab = i)),
              _FilterTab(label: "Due",  index: 2, selected: _selectedTab, onTap: (i) => setState(() => _selectedTab = i)),
            ],
          ),
        ),
      ),
    );
  }

  // ── SECTION LABEL ─────────────────────────────────────
  SliverToBoxAdapter _buildSectionLabel() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 18, 16, 10),
        child: Text(
          "TRANSACTIONS",
          style: TextStyle(
            color: kText2,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  // ── PAYMENT LIST ─────────────────────────────────────
  SliverList _buildPaymentList() {
    final list = _filtered;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, i) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: _PaymentCard(data: list[i]),
        ),
        childCount: list.length,
      ),
    );
  }
}

// ── BAL STAT ─────────────────────────────────────────────────
class _BalStat extends StatelessWidget {
  final String value, label;
  const _BalStat(this.value, this.label);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                color: kText1,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              )),
          const SizedBox(height: 3),
          Text(label.toUpperCase(),
              style: const TextStyle(
                color: kGoldDeep,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              )),
        ],
      ),
    ),
  );
}

// ── SUMMARY CARD ─────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String value, label;
  final Color  accentColor, iconBg, iconColor;
  final IconData icon;

  const _SummaryCard({
    required this.value,
    required this.label,
    required this.accentColor,
    required this.iconBg,
    required this.icon,
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
          Container(height: 3, color: accentColor),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(height: 8),
                Text(value,
                    style: const TextStyle(
                      color: kText1,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    )),
                const SizedBox(height: 2),
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

// ── FILTER TAB ───────────────────────────────────────────────
class _FilterTab extends StatelessWidget {
  final String   label;
  final int      index, selected;
  final void Function(int) onTap;

  const _FilterTab({
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? kGold : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? kGoldDeep : kText2,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── PAYMENT CARD ─────────────────────────────────────────────
class _PaymentCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PaymentCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final bool   isDue    = data["due"] as bool? ?? false;
    final String name     = data["name"]?.toString()    ?? "";
    final String plan     = data["plan"]?.toString()    ?? "";
    final String amount   = data["amount"]?.toString()  ?? "";
    final String dueDate  = data["dueDate"]?.toString() ?? "";

    final Color stripeColor = isDue ? kRed  : kGold;
    final Color amtColor    = isDue ? kRed  : kGoldDark;
    final Color borderColor = isDue ? kRedBorder : kGoldBorder;

    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // Status stripe
          Container(
            width: 5,
            height: 90,
            color: stripeColor,
          ),

          // Info section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 0, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                        color: kText1,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 3),
                  Text(plan,
                      style: const TextStyle(
                        color: kText2,
                        fontSize: 11,
                      )),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: stripeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isDue ? "Due on $dueDate" : "Paid successfully",
                        style: TextStyle(
                          color: amtColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Amount + action
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(amount,
                    style: TextStyle(
                      color: amtColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    )),
                const SizedBox(height: 8),
                if (isDue)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: kGold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Collect",
                      style: TextStyle(
                        color: kGoldDeep,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: kGoldLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kGoldBorder),
                    ),
                    child: const Text(
                      "✓ Paid",
                      style: TextStyle(
                        color: kGoldDark,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}