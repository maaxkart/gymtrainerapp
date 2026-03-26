import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

// ── Package model ─────────────────────────────────────────────
class _Package {
  final String id, label, duration, price;
  final IconData icon;
  final Color color, bg;
  const _Package({required this.id, required this.label, required this.duration, required this.price, required this.icon, required this.color, required this.bg});
}

// ── Fee type model ────────────────────────────────────────────
class _FeeType {
  final String id, label, hint;
  final IconData icon;
  final Color color, bg;
  const _FeeType({required this.id, required this.label, required this.hint, required this.icon, required this.color, required this.bg});
}

class AddPaymentScreen extends StatefulWidget {
  const AddPaymentScreen({super.key});
  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {

  final _nameCtrl   = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl   = TextEditingController();

  String _selectedFeeType = "monthly";
  String _selectedPackage = "gold";
  String _paymentMethod   = "cash";
  bool   _isDue           = false;
  DateTime? _dueDate;

  // ── Fee types ─────────────────────────────────────────────
  final List<_FeeType> _feeTypes = const [
    _FeeType(id: "registration", label: "Registration",  hint: "One-time joining fee",  icon: Icons.app_registration_rounded, color: Color(0xFF00695C), bg: Color(0xFFE0F2F1)),
    _FeeType(id: "monthly",      label: "Monthly",       hint: "Monthly subscription",  icon: Icons.calendar_month_rounded,   color: kGoldDark,          bg: kGoldLight),
    _FeeType(id: "half_yearly",  label: "Half Yearly",   hint: "6-month subscription",  icon: Icons.event_repeat_rounded,     color: Color(0xFF1565C0),  bg: Color(0xFFE3F2FD)),
    _FeeType(id: "yearly",       label: "Yearly",        hint: "Annual subscription",   icon: Icons.workspace_premium_rounded, color: Color(0xFF4A148C), bg: Color(0xFFF3E5F5)),
  ];

  // ── Packages ──────────────────────────────────────────────
  final List<_Package> _packages = const [
    _Package(id: "basic",   label: "Basic Plan",   duration: "Access to floor",     price: "₹800",   icon: Icons.fitness_center_rounded, color: kText2,           bg: kSurface2),
    _Package(id: "silver",  label: "Silver Plan",  duration: "Floor + cardio",      price: "₹1,500", icon: Icons.star_half_rounded,      color: Color(0xFF607D8B), bg: Color(0xFFECEFF1)),
    _Package(id: "gold",    label: "Gold Plan",    duration: "All + trainer",       price: "₹2,000", icon: Icons.star_rounded,           color: kGoldDark,         bg: kGoldLight),
    _Package(id: "premium", label: "Premium Plan", duration: "All + diet + sauna",  price: "₹3,000", icon: Icons.workspace_premium_rounded, color: Color(0xFF4A148C), bg: Color(0xFFF3E5F5)),
  ];

  // Auto-fill amount when fee type + package changes
  void _autoFillAmount() {
    final pkg = _packages.firstWhere((p) => p.id == _selectedPackage);
    final base = int.tryParse(pkg.price.replaceAll(RegExp(r'[₹,]'), '')) ?? 0;
    int amount = base;
    if (_selectedFeeType == "registration") amount = 500;
    else if (_selectedFeeType == "half_yearly") amount = base * 6 ~/ 1000 * 850; // slight discount
    else if (_selectedFeeType == "yearly")      amount = base * 10; // 2 months free
    _amountCtrl.text = "₹${_fmt(amount)}";
  }

  String _fmt(int v) {
    final s = v.toString();
    if (s.length > 3) return "${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}";
    return s;
  }

  Future<void> _pickDueDate() async {
    HapticFeedback.lightImpact();
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: kGoldDark),
        ),
        child: child!,
      ),
    );
    if (d != null) setState(() => _dueDate = d);
  }

  @override
  void initState() {
    super.initState();
    _autoFillAmount();
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _amountCtrl.dispose(); _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // ── 1. MEMBER INFO ──────────────────────
                  _SectionCard(
                    icon: Icons.person_rounded,
                    color: kGoldDark,
                    bg: kGoldLight,
                    title: "Member Details",
                    child: _InputField(
                      controller: _nameCtrl,
                      hint: "Enter member name",
                      icon: Icons.badge_rounded,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── 2. FEE TYPE ─────────────────────────
                  _SectionCard(
                    icon: Icons.category_rounded,
                    color: kGoldDark,
                    bg: kGoldLight,
                    title: "Fee Type",
                    child: Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _feeTypes.map((ft) {
                        final sel = _selectedFeeType == ft.id;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() { _selectedFeeType = ft.id; _autoFillAmount(); });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: sel ? ft.color : ft.bg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: sel ? ft.color : kBorder,
                                width: sel ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(ft.icon, size: 16, color: sel ? Colors.white : ft.color),
                                const SizedBox(width: 7),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ft.label,
                                        style: TextStyle(
                                          color: sel ? Colors.white : ft.color,
                                          fontSize: 12, fontWeight: FontWeight.w800,
                                        )),
                                    Text(ft.hint,
                                        style: TextStyle(
                                          color: sel ? Colors.white70 : kText2,
                                          fontSize: 9,
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Hide package selector for registration fee
                  if (_selectedFeeType != "registration") ...[
                    const SizedBox(height: 14),

                    // ── 3. PACKAGE ────────────────────────
                    _SectionCard(
                      icon: Icons.workspace_premium_rounded,
                      color: kGoldDark,
                      bg: kGoldLight,
                      title: "Select Package",
                      child: Column(
                        children: _packages.map((pkg) {
                          final sel = _selectedPackage == pkg.id;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() { _selectedPackage = pkg.id; _autoFillAmount(); });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: sel ? pkg.color.withOpacity(0.07) : kSurface2,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: sel ? pkg.color.withOpacity(0.5) : kBorder,
                                  width: sel ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38, height: 38,
                                    decoration: BoxDecoration(color: pkg.bg, borderRadius: BorderRadius.circular(11)),
                                    child: Icon(pkg.icon, color: pkg.color, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(pkg.label,
                                            style: TextStyle(
                                              color: sel ? kText1 : kText1,
                                              fontSize: 13, fontWeight: FontWeight.w800,
                                            )),
                                        Text(pkg.duration,
                                            style: const TextStyle(color: kText2, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(pkg.price,
                                          style: TextStyle(
                                            color: sel ? pkg.color : kText2,
                                            fontSize: 14, fontWeight: FontWeight.w900,
                                          )),
                                      Text("/mo", style: const TextStyle(color: kText2, fontSize: 9)),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 20, height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: sel ? pkg.color : Colors.transparent,
                                      border: Border.all(
                                        color: sel ? pkg.color : kBorder, width: 1.5,
                                      ),
                                    ),
                                    child: sel ? const Icon(Icons.check_rounded, color: Colors.white, size: 12) : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // ── 4. AMOUNT ─────────────────────────────
                  _SectionCard(
                    icon: Icons.currency_rupee_rounded,
                    color: kGoldDark,
                    bg: kGoldLight,
                    title: "Amount",
                    child: _InputField(
                      controller: _amountCtrl,
                      hint: "₹ Enter amount",
                      icon: Icons.currency_rupee_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── 5. PAYMENT METHOD ─────────────────────
                  _SectionCard(
                    icon: Icons.payment_rounded,
                    color: kGoldDark,
                    bg: kGoldLight,
                    title: "Payment Method",
                    child: Row(
                      children: ["Cash", "UPI", "Card", "NEFT"].map((m) {
                        final id  = m.toLowerCase();
                        final sel = _paymentMethod == id;
                        return GestureDetector(
                          onTap: () { HapticFeedback.lightImpact(); setState(() => _paymentMethod = id); },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: sel ? kGold : kSurface2,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: sel ? kGold : kBorder, width: sel ? 1.5 : 1),
                            ),
                            child: Text(m,
                                style: TextStyle(
                                  color: sel ? kGoldDeep : kText2,
                                  fontSize: 12, fontWeight: FontWeight.w700,
                                )),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── 6. STATUS TOGGLE ──────────────────────
                  _SectionCard(
                    icon: Icons.toggle_on_rounded,
                    color: kGoldDark,
                    bg: kGoldLight,
                    title: "Payment Status",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: ["Paid", "Due"].map((s) {
                            final isDue = s == "Due";
                            final sel   = _isDue == isDue;
                            return GestureDetector(
                              onTap: () { HapticFeedback.lightImpact(); setState(() => _isDue = isDue); },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: sel ? (isDue ? kRed : kGold) : kSurface2,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: sel ? (isDue ? kRed : kGold) : kBorder,
                                    width: sel ? 1.5 : 1,
                                  ),
                                ),
                                child: Text(s,
                                    style: TextStyle(
                                      color: sel ? (isDue ? Colors.white : kGoldDeep) : kText2,
                                      fontSize: 13, fontWeight: FontWeight.w800,
                                    )),
                              ),
                            );
                          }).toList(),
                        ),
                        // Show date picker when Due
                        if (_isDue) ...[
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: _pickDueDate,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                              decoration: BoxDecoration(
                                color: _dueDate != null ? kRedBg : kSurface2,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _dueDate != null ? kRed.withOpacity(0.35) : kBorder,
                                  width: _dueDate != null ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded, size: 16,
                                      color: _dueDate != null ? kRed : kText2),
                                  const SizedBox(width: 10),
                                  Text(
                                    _dueDate == null
                                        ? "Select due date"
                                        : "${_dueDate!.day} ${_monthName(_dueDate!.month)} ${_dueDate!.year}",
                                    style: TextStyle(
                                      color: _dueDate != null ? kRed : kText2,
                                      fontSize: 13, fontWeight: _dueDate != null ? FontWeight.w700 : FontWeight.w400,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_dueDate != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(color: kRed, borderRadius: BorderRadius.circular(8)),
                                      child: const Text("Change", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── 7. NOTE (optional) ────────────────────
                  _SectionCard(
                    icon: Icons.notes_rounded,
                    color: kGoldDark,
                    bg: kGoldLight,
                    title: "Note (optional)",
                    child: TextField(
                      controller: _noteCtrl,
                      maxLines: 2,
                      style: const TextStyle(color: kText1, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Add a note...",
                        hintStyle: const TextStyle(color: kText2, fontSize: 13),
                        filled: true, fillColor: kSurface2,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorder)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kBorder)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kGold, width: 1.5)),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── SAVE BUTTON ───────────────────────────
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      if (_nameCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text("Please enter member name"),
                          backgroundColor: kRed,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ));
                        return;
                      }
                      final pkg = _packages.firstWhere((p) => p.id == _selectedPackage);
                      final ft  = _feeTypes.firstWhere((f) => f.id == _selectedFeeType);
                      Navigator.pop(context, {
                        "name":    _nameCtrl.text.trim(),
                        "plan":    pkg.label,
                        "package": ft.label,
                        "amount":  _amountCtrl.text.trim(),
                        "dueDate": _isDue
                            ? (_dueDate != null ? "${_dueDate!.day} ${_monthName(_dueDate!.month)}" : "TBD")
                            : "Paid",
                        "due":     _isDue,
                        "regFee":  _selectedFeeType == "registration",
                        "method":  _paymentMethod,
                        "note":    _noteCtrl.text.trim(),
                      });
                    },
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: kGold,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: kGold.withOpacity(0.45), blurRadius: 18, offset: const Offset(0, 7))],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded, color: kGoldDeep, size: 20),
                          SizedBox(width: 10),
                          Text("Save Payment",
                              style: TextStyle(color: kGoldDeep, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.2)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: kText2, fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int m) => ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"][m-1];

  // ── HEADER ────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) => Container(
    color: kSurface,
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 15, color: kText1),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("ADD PAYMENT", style: TextStyle(color: kText2, fontSize: 10, letterSpacing: 1.3, fontWeight: FontWeight.w700)),
                  Text("New Transaction", style: TextStyle(color: kText1, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: kGoldLight, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.currency_rupee_rounded, color: kGoldDark, size: 20),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── SECTION CARD ─────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  final String title;
  final Widget child;
  const _SectionCard({required this.icon, required this.color, required this.bg, required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: kSurface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: kBorder),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9)), child: Icon(icon, color: color, size: 16)),
          const SizedBox(width: 9),
          Text(title, style: const TextStyle(color: kText1, fontSize: 13, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 14),
        Divider(color: kBorder, height: 0.5),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

// ── INPUT FIELD ───────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  const _InputField({required this.controller, required this.hint, required this.icon, this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    style: const TextStyle(color: kText1, fontSize: 14, fontWeight: FontWeight.w600),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: kText2, fontSize: 13),
      prefixIcon: Icon(icon, color: kText2, size: 18),
      filled: true, fillColor: kSurface2,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kGold, width: 1.5)),
    ),
  );
}