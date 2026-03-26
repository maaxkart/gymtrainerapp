import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

// ─────────────────────────────────────────────────────
//  BALANCE DETAIL PAGE
// ─────────────────────────────────────────────────────
class BalanceDetailPage extends StatelessWidget {
  final String title;        // "This Month" / "Pending" / "Today"
  final String totalAmount;  // "₹30K"
  final List<Map<String, dynamic>> items;
  final BalanceType type;

  const BalanceDetailPage({
    super.key,
    required this.title,
    required this.totalAmount,
    required this.items,
    required this.type,
  });

  Color get _accent => type == BalanceType.pending ? kRed : kGoldDark;
  Color get _accentBg => type == BalanceType.pending ? kRedBg : kGoldLight;
  Color get _accentBorder => type == BalanceType.pending ? kRedBorder : kGoldBorder;
  IconData get _icon => type == BalanceType.pending
      ? Icons.access_time_rounded
      : type == BalanceType.today
      ? Icons.today_rounded
      : Icons.calendar_month_rounded;

  int get _paidCount => items.where((p) => p["due"] == false).length;
  int get _dueCount  => items.where((p) => p["due"] == true).length;

  String get _totalRaw {
    // Sum amounts (strip ₹ and commas)
    int sum = 0;
    for (final p in items) {
      final raw = (p["amount"] ?? "0")
          .toString()
          .replaceAll("₹", "")
          .replaceAll(",", "")
          .trim();
      sum += int.tryParse(raw) ?? 0;
    }
    return "₹${_formatAmount(sum)}";
  }

  String _formatAmount(int v) {
    if (v >= 100000) return "${(v / 100000).toStringAsFixed(1)}L";
    if (v >= 1000)   return "${(v / 1000).toStringAsFixed(1)}K";
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _buildTopBar(context),
          _buildHeroCard(),
          _buildStatStrip(),
          _buildListLabel(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  // ── TOP BAR ────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
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
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: kText1, fontSize: 16,
                fontWeight: FontWeight.w800, letterSpacing: -0.3,
              ),
            ),
          ),
          // Accent badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: _accentBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accentBorder),
            ),
            child: Row(
              children: [
                Icon(_icon, color: _accent, size: 13),
                const SizedBox(width: 5),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: _accent, fontSize: 10,
                    fontWeight: FontWeight.w800, letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HERO CARD ──────────────────────────────────────
  Widget _buildHeroCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: type == BalanceType.pending ? kRed : kGold,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${title.toUpperCase()} TOTAL",
                    style: TextStyle(
                      color: type == BalanceType.pending
                          ? Colors.white70
                          : kGoldDeep,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _totalRaw,
                    style: TextStyle(
                      color: type == BalanceType.pending
                          ? Colors.white
                          : kText1,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${items.length} transactions",
                    style: TextStyle(
                      color: type == BalanceType.pending
                          ? Colors.white60
                          : kGoldDeep,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _icon,
                color: type == BalanceType.pending ? Colors.white : kText1,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── STAT STRIP ─────────────────────────────────────
  Widget _buildStatStrip() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          _MiniStat(
            value: items.length.toString(),
            label: "Total",
            icon: Icons.receipt_long_rounded,
            iconBg: kGoldLight,
            iconColor: kGoldDark,
            accentColor: kGold,
          ),
          const SizedBox(width: 10),
          _MiniStat(
            value: _paidCount.toString(),
            label: "Paid",
            icon: Icons.check_circle_rounded,
            iconBg: kGoldLight,
            iconColor: kGoldDark,
            accentColor: kGold,
          ),
          const SizedBox(width: 10),
          _MiniStat(
            value: _dueCount.toString(),
            label: "Due",
            icon: Icons.access_time_rounded,
            iconBg: kRedBg,
            iconColor: kRed,
            accentColor: kRed,
          ),
        ],
      ),
    );
  }

  // ── LIST LABEL ─────────────────────────────────────
  Widget _buildListLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        children: [
          Text(
            "TRANSACTIONS",
            style: const TextStyle(
              color: kText2, fontSize: 10,
              fontWeight: FontWeight.w700, letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: kSurface2, borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${items.length} records",
              style: const TextStyle(
                color: kText2, fontSize: 10, fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── LIST ───────────────────────────────────────────
  Widget _buildList() {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: kGoldLight, borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.inbox_outlined, color: kGoldDark, size: 30),
            ),
            const SizedBox(height: 14),
            const Text(
              "No transactions found",
              style: TextStyle(color: kText2, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: items.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _PaymentCard(data: items[i]),
      ),
    );
  }
}

// ── BALANCE TYPE ENUM ────────────────────────────────
enum BalanceType { thisMonth, pending, today }

// ── MINI STAT CARD ───────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String   value, label;
  final IconData icon;
  final Color    iconBg, iconColor, accentColor;

  const _MiniStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.accentColor,
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
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Column(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: iconColor, size: 17),
                ),
                const SizedBox(height: 8),
                Text(value,
                    style: const TextStyle(
                      color: kText1, fontSize: 20,
                      fontWeight: FontWeight.w900, letterSpacing: -0.5,
                    )),
                const SizedBox(height: 3),
                Text(label.toUpperCase(),
                    style: const TextStyle(
                      color: kText2, fontSize: 8,
                      fontWeight: FontWeight.w700, letterSpacing: 1,
                    )),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ── PAYMENT CARD ─────────────────────────────────────
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
          // Status stripe
          Container(width: 5, height: 100, color: stripeColor),

          // Info
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
                  Text(plan,
                      style: const TextStyle(color: kText2, fontSize: 11)),
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

          // Amount + action
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