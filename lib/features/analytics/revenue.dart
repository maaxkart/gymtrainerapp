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

class RevenueDetailScreen extends StatefulWidget {
  final String period;
  const RevenueDetailScreen({super.key, required this.period});
  @override
  State<RevenueDetailScreen> createState() => _RevenueDetailScreenState();
}

class _RevenueDetailScreenState extends State<RevenueDetailScreen> {
  String _filter = "All";

  final List<_Transaction> _txns = [
    _Transaction("Ravi Menon",       "Gold Plan Renewal",   "+₹2500", "12 Mar 2025", "10:30 AM", "UPI",    "Received"),
    _Transaction("Priya Nair",       "Silver Plan",         "+₹1500", "11 Mar 2025", "08:15 AM", "Cash",   "Received"),
    _Transaction("Sneha Ramesh",     "Basic Plan",          "+₹800",  "10 Mar 2025", "09:00 AM", "Card",   "Received"),
    _Transaction("Mohammed Farhan",  "Gold Plan New",       "+₹2500", "09 Mar 2025", "07:00 AM", "UPI",    "Received"),
    _Transaction("Kiran Thomas",     "Basic Plan Renewal",  "+₹800",  "08 Mar 2025", "11:00 AM", "Cash",   "Received"),
    _Transaction("Equipment Repair", "Treadmill Service",   "-₹3500", "07 Mar 2025", "02:00 PM", "NEFT",   "Expense"),
    _Transaction("Ananya Pillai",    "Gold Plan",           "+₹2500", "06 Mar 2025", "06:45 AM", "UPI",    "Received"),
    _Transaction("Electricity Bill", "March 2025",          "-₹2200", "05 Mar 2025", "12:00 PM", "Online", "Expense"),
  ];

  List<_Transaction> get _filtered => _filter == "All" ? _txns : _txns.where((t) => t.type == _filter).toList();

  int get _totalIn  => _txns.where((t) => t.type == "Received").fold(0, (s, t) => s + int.parse(t.amount.replaceAll(RegExp(r'[+₹,]'), '')));
  int get _totalOut => _txns.where((t) => t.type == "Expense").fold(0, (s, t)  => s + int.parse(t.amount.replaceAll(RegExp(r'[-₹,]'), '')));
  int get _net => _totalIn - _totalOut;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _buildHeader(context),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: ["All", "Received", "Expense"].map((f) {
                final sel = _filter == f;
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
                    child: Text(f, style: TextStyle(color: sel ? kGoldDark : kText2, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              physics: const BouncingScrollPhysics(),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _TxnCard(txn: _filtered[i]),
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
                Text("Revenue · ${widget.period}", style: const TextStyle(color: kText2, fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
                const Text("Revenue Details", style: TextStyle(color: kText1, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              ])),
            ]),
            const SizedBox(height: 16),
            // Summary cards
            Row(children: [
              Expanded(child: _RevCard("₹${_totalIn.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m)=>'${m[1]},')}", "Total In", Colors.green, Colors.green.withOpacity(0.08))),
              const SizedBox(width: 10),
              Expanded(child: _RevCard("₹${_totalOut.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m)=>'${m[1]},')}", "Total Out", Colors.red, Colors.red.withOpacity(0.08))),
              const SizedBox(width: 10),
              Expanded(child: _RevCard("₹${_net.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m)=>'${m[1]},')}", "Net Profit", kGoldDark, kGoldLight)),
            ]),
          ],
        ),
      ),
    ),
  );
}

class _Transaction {
  final String name, subtitle, amount, date, time, method, type;
  const _Transaction(this.name, this.subtitle, this.amount, this.date, this.time, this.method, this.type);
}

class _TxnCard extends StatelessWidget {
  final _Transaction txn;
  const _TxnCard({super.key, required this.txn});

  bool get _isIncome => txn.type == "Received";
  Color get _amtColor => _isIncome ? Colors.green : Colors.red;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: kSurface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: kBorder),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: Row(children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: _isIncome ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(_isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: _amtColor, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(txn.name, style: const TextStyle(color: kText1, fontSize: 14, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(txn.subtitle, style: const TextStyle(color: kText2, fontSize: 11)),
        const SizedBox(height: 5),
        Row(children: [
          const Icon(Icons.calendar_today_rounded, size: 10, color: kText2),
          const SizedBox(width: 4),
          Text("${txn.date}  ·  ${txn.time}", style: const TextStyle(color: kText2, fontSize: 10)),
          const SizedBox(width: 10),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(6)), child: Text(txn.method, style: const TextStyle(color: kText2, fontSize: 9, fontWeight: FontWeight.w700))),
        ]),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(txn.amount, style: TextStyle(color: _amtColor, fontSize: 15, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(color: _amtColor.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
          child: Text(txn.type, style: TextStyle(color: _amtColor, fontSize: 9, fontWeight: FontWeight.w700)),
        ),
      ]),
    ]),
  );
}

class _RevCard extends StatelessWidget {
  final String value, label; final Color color, bg;
  const _RevCard(this.value, this.label, this.color, this.bg);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: kText2, fontSize: 9, fontWeight: FontWeight.w700)),
    ]),
  );
}