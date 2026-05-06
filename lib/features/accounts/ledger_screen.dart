import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Brand tokens (unchanged) ──────────────────────────
const kGold       = Color(0xFFC8DC32);
const kGoldDark   = Color(0xFF8FA000);
const kGoldDeep   = Color(0xFF5A6E00);
const kGoldLight  = Color(0xFFF5F8D6);
const kGoldBorder = Color(0xFFE2EC8A);
const kBg         = Color(0xFFF7F7F5);
const kSurface    = Color(0xFFFFFFFF);
const kSurface2   = Color(0xFFF5F5F5);
const kBorder     = Color(0xFFEFEFEF);
const kText1      = Color(0xFF111111);
const kText2      = Color(0xFFAAAAAA);
const kGreen      = Color(0xFF2E7D32);
const kGreenBg    = Color(0xFFF1FBF1);
const kGreenBdr   = Color(0xFFB9E4BA);
const kRed        = Color(0xFFC62828);
const kRedBg      = Color(0xFFFFF3F3);
const kRedBorder  = Color(0xFFFFCDD2);
const kGoldGlow   = Color(0x40C8DC32);

// ── Column widths ─────────────────────────────────────
// 5 columns + 4 dividers × 0.5px = _totalW
const double _cDate   = 50.0;
const double _cDesc   = 162.0;
const double _cVch    = 88.0;
const double _cDr     = 76.0;
const double _cCr     = 76.0;
const double _totalW  = _cDate + _cDesc + _cVch + _cDr + _cCr + (0.5 * 4);

class LedgerEntry {
  final String date, particulars, voucherNo, type;
  final String? mode, cat;
  final double debit, credit, balance;
  const LedgerEntry({
    required this.date, required this.particulars, required this.voucherNo,
    required this.type, this.mode, this.cat,
    required this.debit, required this.credit, required this.balance,
  });
}

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});
  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen>
    with TickerProviderStateMixin {
  late final AnimationController _reveal =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  int _tab = 0;
  String _month = 'JUN 2025';
  final _months = ['APR 2025', 'MAY 2025', 'JUN 2025'];

  static const List<LedgerEntry> _all = [
    LedgerEntry(date:'01/06', particulars:'Opening Balance',              voucherNo:'OB-001',  type:'ob', debit:0,     credit:0,     balance:35000),
    LedgerEntry(date:'03/06', particulars:'Gold Membership · Arjun Kumar',voucherNo:'RCP-001', type:'cr', mode:'UPI',  cat:'Membership', debit:0,    credit:3500,  balance:38500),
    LedgerEntry(date:'05/06', particulars:'Electricity Bill Payment',     voucherNo:'PAY-001', type:'dr', mode:'NEFT', cat:'Utility',    debit:4500, credit:0,     balance:34000),
    LedgerEntry(date:'07/06', particulars:'Elite PT · Priya Menon',       voucherNo:'RCP-002', type:'cr', mode:'UPI',  cat:'Training',   debit:0,    credit:5000,  balance:39000),
    LedgerEntry(date:'10/06', particulars:'Quarterly Plan · Rahul',       voucherNo:'RCP-003', type:'cr', mode:'Card', cat:'Membership', debit:0,    credit:9000,  balance:48000),
    LedgerEntry(date:'12/06', particulars:'Olympic Barbell Set',          voucherNo:'PAY-002', type:'dr', mode:'NEFT', cat:'Equipment',  debit:8200, credit:0,     balance:39800),
    LedgerEntry(date:'14/06', particulars:'PT Session · Sunita V.',       voucherNo:'RCP-004', type:'cr', mode:'Cash', cat:'Training',   debit:0,    credit:2000,  balance:41800),
    LedgerEntry(date:'16/06', particulars:'Whey Protein Stock',           voucherNo:'PAY-003', type:'dr', mode:'NEFT', cat:'Inventory',  debit:12000,credit:0,     balance:29800),
    LedgerEntry(date:'18/06', particulars:'Premium Plan · Vikram',        voucherNo:'RCP-005', type:'cr', mode:'UPI',  cat:'Membership', debit:0,    credit:7500,  balance:37300),
    LedgerEntry(date:'20/06', particulars:'Staff Payroll — June',         voucherNo:'PAY-004', type:'dr', mode:'NEFT', cat:'Payroll',    debit:45000,credit:0,     balance:-7700),
    LedgerEntry(date:'21/06', particulars:'Annual Locker · Deepa Raj',    voucherNo:'RCP-006', type:'cr', mode:'Cash', cat:'Facilities', debit:0,    credit:3600,  balance:-4100),
    LedgerEntry(date:'23/06', particulars:'Cleaning Supplies',            voucherNo:'PAY-005', type:'dr', mode:'Cash', cat:'Supplies',   debit:650,  credit:0,     balance:-4750),
    LedgerEntry(date:'25/06', particulars:'Half-Yearly Plan · Meena',     voucherNo:'RCP-007', type:'cr', mode:'UPI',  cat:'Membership', debit:0,    credit:9000,  balance:4250),
    LedgerEntry(date:'27/06', particulars:'Equipment Maintenance',        voucherNo:'PAY-006', type:'dr', mode:'Cash', cat:'Equipment',  debit:2200, credit:0,     balance:2050),
    LedgerEntry(date:'28/06', particulars:'Gold Membership · Sana K.',    voucherNo:'RCP-008', type:'cr', mode:'UPI',  cat:'Membership', debit:0,    credit:3500,  balance:5550),
    LedgerEntry(date:'30/06', particulars:'Closing Balance',              voucherNo:'CB-001',  type:'cb', debit:0,     credit:0,         balance:5550),
  ];

  List<LedgerEntry> get _filtered {
    if (_tab == 1) return _all.where((e) => e.type == 'cr' || e.type == 'ob' || e.type == 'cb').toList();
    if (_tab == 2) return _all.where((e) => e.type == 'dr' || e.type == 'ob' || e.type == 'cb').toList();
    return _all;
  }

  double get _totalCr   => _all.where((e) => e.type == 'cr').fold(0.0, (s, e) => s + e.credit);
  double get _totalDr   => _all.where((e) => e.type == 'dr').fold(0.0, (s, e) => s + e.debit);
  double get _closingBal => _all.last.balance;

  String _fmt(double v) {
    if (v.abs() >= 100000) return '₹${(v / 100000).toStringAsFixed(2)}L';
    if (v.abs() >= 1000)   return '₹${(v / 1000).toStringAsFixed(2)}K';
    return '₹${v.toStringAsFixed(2)}';
  }
  String _fmtS(double v) {
    if (v == 0) return '—';
    if (v.abs() >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
    if (v.abs() >= 1000)   return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  void dispose() { _reveal.dispose(); _hScroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _buildHeader(context),
          _buildKpiStrip(),
          _buildControls(),
          Expanded(child: _buildTable()),
          _buildFooter(),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) => Container(
    color: kSurface,
    padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 14),
    child: Row(children: [
      _IBtn(Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context)),
      Expanded(
        child: Column(children: [
          ShaderMask(
            shaderCallback: (r) => const LinearGradient(colors: [kGoldDark, kGold, kGoldDeep]).createShader(r),
            child: const Text('LEDGER ACCOUNT',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 3.5)),
          ),
          const SizedBox(height: 4),
          Container(height: 2, width: 70,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.transparent, kGold, Colors.transparent]),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ]),
      ),
      _GoldAction('EXPORT', () {}),
    ]),
  );

  // ── KPI STRIP ─────────────────────────────────────────
  Widget _buildKpiStrip() {
    final isPos = _closingBal >= 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kGoldDeep, Color(0xFF7A9400)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: kGoldGlow, blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Row(children: [
        _KpiBubble('RECEIPTS',  _fmt(_totalCr),           kGold,    false),
        _KpiBubble('PAYMENTS',  _fmt(_totalDr),           const Color(0xFFFF8A80), false),
        _KpiBubble('CLOSING',   _fmt(_closingBal.abs()),  isPos ? kGold : const Color(0xFFFF8A80), true),
      ]),
    );
  }

  // ── CONTROLS ──────────────────────────────────────────
  Widget _buildControls() => Container(
    color: kSurface,
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month pills
        Row(children: [
          const Icon(Icons.calendar_month_rounded, size: 13, color: kText2),
          const SizedBox(width: 8),
          ..._months.map((m) {
            final sel = _month == m;
            return GestureDetector(
              onTap: () => setState(() => _month = m),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? kGold : kSurface2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? kGoldDark : kBorder, width: sel ? 1.5 : 1),
                ),
                child: Text(m, style: TextStyle(color: sel ? kGoldDeep : kText2, fontSize: 10, fontWeight: FontWeight.w800)),
              ),
            );
          }),
        ]),
        const SizedBox(height: 10),
        // Tab bar
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(13), border: Border.all(color: kBorder)),
          child: Row(children: [
            _TabChip('ALL',    Icons.format_list_bulleted_rounded, 0, _tab, (v) { setState(() => _tab = v); _reveal.forward(from: 0); }),
            _TabChip('CREDIT', Icons.south_rounded,               1, _tab, (v) { setState(() => _tab = v); _reveal.forward(from: 0); }),
            _TabChip('DEBIT',  Icons.north_rounded,               2, _tab, (v) { setState(() => _tab = v); _reveal.forward(from: 0); }),
          ]),
        ),
      ],
    ),
  );

  // ── TABLE ─────────────────────────────────────────────
  final ScrollController _hScroll = ScrollController();

  Widget _buildTable() {
    final entries = _filtered;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: [
          // Header scrolls in sync with body
          SingleChildScrollView(
            controller: _hScroll,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: _buildTableHeader(),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _reveal,
              builder: (_, __) => SingleChildScrollView(
                // vertical scroll
                physics: const BouncingScrollPhysics(),
                child: SingleChildScrollView(
                  // horizontal scroll — drives the header via listener
                  scrollDirection: Axis.horizontal,
                  controller: _hScroll,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: _totalW,
                    child: Column(
                      children: List.generate(entries.length, (i) {
                        final t = CurvedAnimation(
                          parent: _reveal,
                          curve: Interval((i * 0.055).clamp(0, 0.65), ((i * 0.055) + 0.35).clamp(0, 1.0), curve: Curves.easeOutQuart),
                        );
                        return FadeTransition(
                          opacity: t,
                          child: SlideTransition(
                            position: Tween(begin: const Offset(0.03, 0), end: Offset.zero).animate(t),
                            child: _buildRow(entries[i], i),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildTableHeader() => Container(
    width: _totalW,
    decoration: const BoxDecoration(
      color: kGoldDeep,
      borderRadius: BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
    ),
    child: _tableRowRaw(
      date:    _hCell('DATE',        align: TextAlign.center),
      desc:    _hCell('PARTICULARS', align: TextAlign.left),
      voucher: _hCell('VOUCHER',     align: TextAlign.center),
      debit:   _hCell('DEBIT ₹',    align: TextAlign.right),
      credit:  _hCell('CREDIT ₹',   align: TextAlign.right),
      divColor: kGold.withOpacity(0.3),
    ),
  );

  Widget _hCell(String t, {TextAlign align = TextAlign.left}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
    child: Text(t, textAlign: align, style: const TextStyle(color: kGold, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
  );

  Widget _buildRow(LedgerEntry e, int idx) {
    final isOb   = e.type == 'ob';
    final isCb   = e.type == 'cb';
    final isCr   = e.type == 'cr';
    final isDr   = e.type == 'dr';
    final isSp   = isOb || isCb;
    final isEven = idx % 2 == 0;

    Color rowBg;
    if (isSp)      rowBg = kGoldLight;
    else if (isCr) rowBg = isEven ? kGreenBg : kSurface;
    else if (isDr) rowBg = isEven ? kRedBg   : kSurface;
    else           rowBg = kSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _totalW,
          color: rowBg,
          child: _tableRowRaw(
            date: _dCell(
              e.date,
              style: TextStyle(
                color: isSp ? kGoldDeep : isCr ? kGreen : isDr ? kRed : kText2,
                fontSize: 11, fontWeight: isSp ? FontWeight.w800 : FontWeight.w700,
              ),
              align: TextAlign.center,
            ),
            desc: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(children: [
                if (!isSp && e.cat != null) ...[
                  Container(width: 22, height: 22,
                    decoration: BoxDecoration(color: _catColor(e.cat!).withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                    child: Icon(_catIcon(e.cat!), size: 12, color: _catColor(e.cat!)),
                  ),
                  const SizedBox(width: 6),
                ],
                if (isSp) ...[
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: kGoldDark, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(e.particulars, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: isSp ? kGoldDeep : kText1, fontSize: 11,
                      fontWeight: isSp ? FontWeight.w800 : FontWeight.w600,
                      fontStyle: isSp ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
              ]),
            ),
            voucher: Center(
              child: isSp ? const SizedBox() : Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isCr ? kGreen : kRed).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(e.voucherNo, style: TextStyle(color: isCr ? kGreen : kRed, fontSize: 8, fontWeight: FontWeight.w800)),
                ),
                if (e.mode != null) ...[
                  const SizedBox(height: 3),
                  Text(e.mode!, style: const TextStyle(color: kText2, fontSize: 8, fontWeight: FontWeight.w600)),
                ],
              ]),
            ),
            debit: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: isCb ? Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('Cl.Bal', style: TextStyle(color: kText2, fontSize: 7, fontWeight: FontWeight.w700)),
                  Text(_fmtS(_closingBal.abs()), style: TextStyle(color: _closingBal >= 0 ? kGreen : kRed, fontSize: 11, fontWeight: FontWeight.w900)),
                ]) : isOb ? Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('Op.Bal', style: TextStyle(color: kText2, fontSize: 7, fontWeight: FontWeight.w700)),
                  const Text('35.0K', style: TextStyle(color: kGoldDeep, fontSize: 11, fontWeight: FontWeight.w900)),
                ]) : e.debit > 0
                    ? Text(_fmtS(e.debit), style: const TextStyle(color: kRed, fontSize: 12, fontWeight: FontWeight.w800))
                    : const Text('—', style: TextStyle(color: kText2, fontSize: 12)),
              ),
            ),
            credit: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: (isOb || isCb)
                    ? const SizedBox()
                    : e.credit > 0
                    ? Text(_fmtS(e.credit), style: const TextStyle(color: kGreen, fontSize: 12, fontWeight: FontWeight.w800))
                    : const Text('—', style: TextStyle(color: kText2, fontSize: 12)),
              ),
            ),
            divColor: kBorder,
          ),
        ),
        Container(height: 0.5, color: kBorder),
      ],
    );
  }

  Widget _dCell(String text, {TextStyle? style, TextAlign align = TextAlign.left}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
    child: Text(text, textAlign: align, style: style),
  );

  Widget _tableRowRaw({
    required Widget date, required Widget desc, required Widget voucher,
    required Widget debit, required Widget credit, required Color divColor,
  }) {
    Widget div = Container(width: 0.5, color: divColor);
    return Row(children: [
      SizedBox(width: _cDate,  child: date),
      div,
      SizedBox(width: _cDesc,  child: desc),
      div,
      SizedBox(width: _cVch,   child: IntrinsicHeight(child: Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: voucher)))),
      div,
      SizedBox(width: _cDr,    child: IntrinsicHeight(child: Align(alignment: Alignment.center, child: debit))),
      div,
      SizedBox(width: _cCr,    child: IntrinsicHeight(child: Align(alignment: Alignment.center, child: credit))),
    ]);
  }

  // ── FOOTER TOTALS ─────────────────────────────────────
  Widget _buildFooter() => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    decoration: const BoxDecoration(
      color: kGoldDeep,
      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)),
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _hScroll,
      physics: const NeverScrollableScrollPhysics(),
      child: SizedBox(
        width: _totalW,
        child: Row(children: [
          SizedBox(width: _cDate,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
              child: Text('TOTAL', style: TextStyle(color: kGold, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
          Container(width: 0.5, color: kGold.withOpacity(0.3)),
          SizedBox(width: _cDesc),
          Container(width: 0.5, color: kGold.withOpacity(0.3)),
          SizedBox(width: _cVch),
          Container(width: 0.5, color: kGold.withOpacity(0.3)),
          SizedBox(width: _cDr,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('DR', style: TextStyle(color: Color(0xFFFFCDD2), fontSize: 7, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(_fmtS(_totalDr), style: const TextStyle(color: Color(0xFFFF8A80), fontSize: 13, fontWeight: FontWeight.w900)),
              ]),
            ),
          ),
          Container(width: 0.5, color: kGold.withOpacity(0.3)),
          SizedBox(width: _cCr,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('CR', style: TextStyle(color: Color(0xFFB9F6CA), fontSize: 7, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(_fmtS(_totalCr), style: const TextStyle(color: Color(0xFF69F0AE), fontSize: 13, fontWeight: FontWeight.w900)),
              ]),
            ),
          ),
        ]),
      ),
    ),
  );

  Color _catColor(String cat) {
    switch (cat) {
      case 'Membership': return kGoldDark;
      case 'Training':   return const Color(0xFF1565C0);
      case 'Equipment':  return const Color(0xFF6A1B9A);
      case 'Utility':    return const Color(0xFFF57F17);
      case 'Inventory':
      case 'Supplies':   return const Color(0xFFC62828);
      case 'Payroll':    return const Color(0xFF37474F);
      case 'Facilities': return const Color(0xFF1565C0);
      default:           return kText2;
    }
  }

  IconData _catIcon(String cat) {
    switch (cat) {
      case 'Membership': return Icons.card_membership_rounded;
      case 'Training':   return Icons.sports_gymnastics_rounded;
      case 'Equipment':  return Icons.fitness_center_rounded;
      case 'Utility':    return Icons.bolt_rounded;
      case 'Inventory':
      case 'Supplies':   return Icons.inventory_2_rounded;
      case 'Payroll':    return Icons.people_alt_rounded;
      case 'Facilities': return Icons.meeting_room_rounded;
      default:           return Icons.more_horiz_rounded;
    }
  }
}

// ── Reusables ─────────────────────────────────────────
class _KpiBubble extends StatelessWidget {
  final String label, value; final Color valueColor; final bool highlight;
  const _KpiBubble(this.label, this.value, this.valueColor, this.highlight);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: highlight
          ? BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(14))
          : null,
      child: Column(children: [
        Text(value, style: TextStyle(color: valueColor, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
      ]),
    ),
  );
}

class _TabChip extends StatelessWidget {
  final String label; final IconData icon; final int idx, tab; final ValueChanged<int> onTap;
  const _TabChip(this.label, this.icon, this.idx, this.tab, this.onTap);
  @override
  Widget build(BuildContext context) {
    final sel = tab == idx;
    return Expanded(child: GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(idx); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: sel ? kGold : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 12, color: sel ? kGoldDeep : kText2),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(color: sel ? kGoldDeep : kText2, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
        ]),
      ),
    ));
  }
}

class _IBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _IBtn(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 40, height: 40,
      decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(13), border: Border.all(color: kBorder)),
      child: Icon(icon, size: 15, color: kText1),
    ),
  );
}

class _GoldAction extends StatelessWidget {
  final String label; final VoidCallback onTap;
  const _GoldAction(this.label, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: kGoldGlow, blurRadius: 12)]),
      child: Text(label, style: const TextStyle(color: kGoldDeep, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
    ),
  );
}