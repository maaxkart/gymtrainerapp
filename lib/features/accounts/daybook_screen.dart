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
const kRed        = Color(0xFFC62828);
const kRedBg      = Color(0xFFFFF3F3);
const kRedBorder  = Color(0xFFFFCDD2);
const kGoldGlow   = Color(0x35C8DC32);
const kGreenBg    = Color(0xFFF1FBF1);
const kGreenBdr   = Color(0xFFB9E4BA);

class DaybookScreen extends StatefulWidget {
  const DaybookScreen({super.key});
  @override
  State<DaybookScreen> createState() => _DaybookScreenState();
}

class _DaybookScreenState extends State<DaybookScreen>
    with TickerProviderStateMixin {
  late final AnimationController _reveal =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..forward();
  late final AnimationController _pulse =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))
    ..repeat(reverse: true);

  DateTime _date = DateTime(2025, 6, 28);

  static const _catMeta = <String, Map<String, dynamic>>{
    'Membership': {'icon': Icons.card_membership_rounded,    'color': Color(0xFF5A6E00), 'bg': Color(0xFFF5F8D6)},
    'Training':   {'icon': Icons.sports_gymnastics_rounded,  'color': Color(0xFF1565C0), 'bg': Color(0xFFE3F2FD)},
    'Supplement': {'icon': Icons.local_pharmacy_rounded,     'color': Color(0xFF00695C), 'bg': Color(0xFFE0F2F1)},
    'Equipment':  {'icon': Icons.fitness_center_rounded,     'color': Color(0xFF4527A0), 'bg': Color(0xFFEDE7F6)},
    'Utility':    {'icon': Icons.bolt_rounded,               'color': Color(0xFFF57F17), 'bg': Color(0xFFFFFDE7)},
    'Locker':     {'icon': Icons.lock_rounded,               'color': Color(0xFF6A1B9A), 'bg': Color(0xFFF3E5F5)},
    'Guest':      {'icon': Icons.confirmation_number_rounded,'color': Color(0xFF00838F), 'bg': Color(0xFFE0F7FA)},
    'Payroll':    {'icon': Icons.people_alt_rounded,         'color': Color(0xFF37474F), 'bg': Color(0xFFECEFF1)},
    'Supplies':   {'icon': Icons.shopping_bag_rounded,       'color': Color(0xFFC62828), 'bg': Color(0xFFFCE4EC)},
    'Other':      {'icon': Icons.more_horiz_rounded,         'color': Color(0xFF757575), 'bg': Color(0xFFF5F5F5)},
  };

  static const _modeMeta = <String, Map<String, dynamic>>{
    'UPI':  {'color': Color(0xFF7C3AED), 'bg': Color(0xFFF3E8FF), 'icon': Icons.qr_code_rounded},
    'Cash': {'color': Color(0xFF2E7D32), 'bg': Color(0xFFF1FBF1), 'icon': Icons.payments_rounded},
    'NEFT': {'color': Color(0xFF1565C0), 'bg': Color(0xFFE3F2FD), 'icon': Icons.account_balance_rounded},
    'Card': {'color': Color(0xFF00695C), 'bg': Color(0xFFE0F2F1), 'icon': Icons.credit_card_rounded},
  };

  final Map<String, List<Map<String, dynamic>>> _data = {
    '2025-06-28': [
      {'time': '09:15 AM', 'desc': 'Gold Membership · Arjun Kumar',   'cat': 'Membership', 'type': 'cr', 'amount': 3500.0,  'mode': 'UPI',  'note': 'June renewal'},
      {'time': '10:30 AM', 'desc': 'Protein Supplement Walk-in',      'cat': 'Supplement', 'type': 'cr', 'amount': 850.0,   'mode': 'Cash', 'note': ''},
      {'time': '11:45 AM', 'desc': 'Electricity Bill Payment',        'cat': 'Utility',    'type': 'dr', 'amount': 4500.0,  'mode': 'NEFT', 'note': 'June bill'},
      {'time': '02:00 PM', 'desc': 'Elite PT Session · Meera Nair',  'cat': 'Training',   'type': 'cr', 'amount': 2000.0,  'mode': 'UPI',  'note': '4 sessions pkg'},
      {'time': '03:30 PM', 'desc': 'Cleaning Supplies',               'cat': 'Supplies',   'type': 'dr', 'amount': 650.0,   'mode': 'Cash', 'note': ''},
      {'time': '05:15 PM', 'desc': 'Quarterly Plan · Rohit Sharma',  'cat': 'Membership', 'type': 'cr', 'amount': 5000.0,  'mode': 'Card', 'note': '3-month plan'},
      {'time': '07:00 PM', 'desc': 'Guest Pass · 2 Visitors',         'cat': 'Guest',      'type': 'cr', 'amount': 400.0,   'mode': 'Cash', 'note': ''},
    ],
    '2025-06-27': [
      {'time': '08:00 AM', 'desc': 'Elite Membership · Sunita Pillai','cat': 'Membership', 'type': 'cr', 'amount': 3500.0,  'mode': 'UPI',  'note': 'June renewal'},
      {'time': '10:00 AM', 'desc': 'Olympic Dumbbell Set Purchase',   'cat': 'Equipment',  'type': 'dr', 'amount': 8200.0,  'mode': 'NEFT', 'note': '20kg set ×2'},
      {'time': '12:30 PM', 'desc': 'Annual Locker · Anand Raj',      'cat': 'Locker',     'type': 'cr', 'amount': 500.0,   'mode': 'Cash', 'note': 'Monthly'},
      {'time': '04:00 PM', 'desc': 'PT Session · Deepa Varma',        'cat': 'Training',   'type': 'cr', 'amount': 2000.0,  'mode': 'UPI',  'note': ''},
    ],
    '2025-06-26': [
      {'time': '09:00 AM', 'desc': 'Classic Membership · Priya Menon','cat': 'Membership', 'type': 'cr', 'amount': 3500.0,  'mode': 'UPI',  'note': ''},
      {'time': '11:00 AM', 'desc': 'Staff Advance · Helper',          'cat': 'Payroll',    'type': 'dr', 'amount': 2000.0,  'mode': 'Cash', 'note': 'Against salary'},
      {'time': '02:30 PM', 'desc': 'Multi-item Supplement Sale',      'cat': 'Supplement', 'type': 'cr', 'amount': 1200.0,  'mode': 'Card', 'note': ''},
    ],
  };

  String get _key =>
      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}';
  List<Map<String, dynamic>> get _entries => _data[_key] ?? [];
  double get _dayIn  => _entries.where((e) => e['type'] == 'cr').fold(0.0, (s, e) => s + (e['amount'] as double));
  double get _dayOut => _entries.where((e) => e['type'] == 'dr').fold(0.0, (s, e) => s + (e['amount'] as double));
  double get _net    => _dayIn - _dayOut;

  final _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  final _days   = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];

  void _shift(int d) {
    setState(() { _date = _date.add(Duration(days: d)); });
    _reveal.forward(from: 0);
  }

  @override
  void dispose() { _reveal.dispose(); _pulse.dispose(); super.dispose(); }

  String _fmtAmt(double v) => v >= 100000
      ? '${(v / 100000).toStringAsFixed(2)}L'
      : v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : v.toStringAsFixed(0);

  String _nowTime() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m ${now.hour < 12 ? "AM" : "PM"}';
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(context),
              _buildDateBar(),
              _buildSummaryCards(),
              _buildListHeader(),
              _entries.isEmpty ? _buildEmpty() : _buildList(),
              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
          Positioned(
            bottom: 28, left: 20, right: 20,
            child: _buildFab(context),
          ),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) => SliverToBoxAdapter(
    child: Container(
      color: kSurface,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 14, 20, 16),
      child: Row(
        children: [
          _IconBtn(Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context)),
          Expanded(
            child: Column(
              children: [
                Text('DAY BOOK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    foreground: Paint()
                      ..shader = const LinearGradient(colors: [kGoldDark, kGold]).createShader(const Rect.fromLTWH(0, 0, 200, 20)),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_days[_date.weekday % 7]}, ${_date.day} ${_months[_date.month - 1]} ${_date.year}',
                  style: const TextStyle(color: kText2, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          _IconBtn(Icons.calendar_month_rounded, () async {
            final p = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime(2024),
              lastDate: DateTime.now(),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.light(primary: kGoldDark, onPrimary: Colors.white),
                ),
                child: child!,
              ),
            );
            if (p != null) { setState(() => _date = p); _reveal.forward(from: 0); }
          }),
        ],
      ),
    ),
  );

  // ── DATE NAV BAR ─────────────────────────────────────
  Widget _buildDateBar() => SliverToBoxAdapter(
    child: Container(
      color: kSurface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          _ShiftBtn(Icons.chevron_left_rounded, () => _shift(-1)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulse,
                  builder: (_, __) => Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _entries.isNotEmpty
                          ? kGold.withOpacity(0.5 + 0.5 * _pulse.value)
                          : kBorder,
                      boxShadow: _entries.isNotEmpty
                          ? [BoxShadow(color: kGold.withOpacity(0.4 * _pulse.value), blurRadius: 8, spreadRadius: 2)]
                          : [],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _entries.isEmpty ? 'No entries today' : '${_entries.length} transactions',
                  style: const TextStyle(color: kText2, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          _ShiftBtn(Icons.chevron_right_rounded, () => _shift(1)),
        ],
      ),
    ),
  );

  // ── SUMMARY CARDS ────────────────────────────────────
  Widget _buildSummaryCards() => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          // Main net card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kGoldDeep, Color(0xFF7A9400)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [BoxShadow(color: kGoldGlow, blurRadius: 24, offset: const Offset(0, 8))],
            ),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('NET BALANCE', style: TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 2)),
                      const SizedBox(height: 4),
                      Text('₹${_fmtAmt(_net.abs())}',
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1, height: 1),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _net >= 0 ? Colors.white.withOpacity(0.2) : kRed.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _net >= 0 ? 'SURPLUS' : 'DEFICIT',
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Sub cards row
          Row(
            children: [
              Expanded(child: _SubCard(
                icon: Icons.south_rounded,
                label: 'RECEIPTS',
                value: '₹${_fmtAmt(_dayIn)}',
                accent: kGreen,
                bg: kGreenBg,
                border: kGreenBdr,
              )),
              const SizedBox(width: 10),
              Expanded(child: _SubCard(
                icon: Icons.north_rounded,
                label: 'PAYMENTS',
                value: '₹${_fmtAmt(_dayOut)}',
                accent: kRed,
                bg: kRedBg,
                border: kRedBorder,
              )),
            ],
          ),
        ],
      ),
    ),
  );

  // ── LIST HEADER ───────────────────────────────────────
  Widget _buildListHeader() => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Container(width: 3, height: 14,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [kGold, kGoldDark], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          const Text('TRANSACTIONS', style: TextStyle(color: kText2, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
          const Spacer(),
          if (_entries.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: kGoldLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: kGoldBorder)),
              child: Text('${_entries.length} records', style: const TextStyle(color: kGoldDark, fontSize: 9, fontWeight: FontWeight.w800)),
            ),
        ],
      ),
    ),
  );

  // ── EMPTY STATE ───────────────────────────────────────
  Widget _buildEmpty() => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: kGoldLight, borderRadius: BorderRadius.circular(28),
              border: Border.all(color: kGoldBorder, width: 1.5),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: kGoldDark, size: 34),
          ),
          const SizedBox(height: 18),
          const Text('Nothing recorded yet', style: TextStyle(color: kText1, fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Tap ADD ENTRY below to begin', style: TextStyle(color: kText2, fontSize: 12)),
        ],
      ),
    ),
  );

  // ── TRANSACTION LIST ──────────────────────────────────
  Widget _buildList() => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate((ctx, i) {
        final e    = _entries[i];
        final isCr = e['type'] == 'cr';
        final cat  = _catMeta[e['cat']] ?? _catMeta['Other']!;
        final mode = _modeMeta[e['mode']] ?? _modeMeta['Cash']!;

        return AnimatedBuilder(
          animation: _reveal,
          builder: (_, child) {
            final t = CurvedAnimation(
              parent: _reveal,
              curve: Interval(
                (i * 0.07).clamp(0, 0.6),
                ((i * 0.07) + 0.4).clamp(0, 1.0),
                curve: Curves.easeOutQuart,
              ),
            );
            return FadeTransition(
              opacity: t,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.12), end: Offset.zero).animate(t),
                child: child,
              ),
            );
          },
          child: _TxCard(
            entry: e,
            isCr: isCr,
            cat: cat,
            mode: mode,
            fmtAmt: _fmtAmt,
            isLast: i == _entries.length - 1,
          ),
        );
      }, childCount: _entries.length),
    ),
  );

  // ── FAB ───────────────────────────────────────────────
  Widget _buildFab(BuildContext context) => GestureDetector(
    onTap: () => _showAddSheet(context),
    child: Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [kGold, Color(0xFFDAF03C)]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: kGoldGlow, blurRadius: 20, offset: const Offset(0, 6)),
          BoxShadow(color: kGold.withOpacity(0.25), blurRadius: 40, offset: const Offset(0, 14)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(color: kGoldDeep.withOpacity(0.18), borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.add_rounded, color: kGoldDeep, size: 18),
          ),
          const SizedBox(width: 12),
          const Text('ADD ENTRY',
            style: TextStyle(color: kGoldDeep, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          ),
        ],
      ),
    ),
  );

  // ── ADD ENTRY SHEET ───────────────────────────────────
  void _showAddSheet(BuildContext context) {
    final descCtrl   = TextEditingController();
    final amountCtrl = TextEditingController();
    String type = 'cr';
    String mode = 'UPI';
    String cat  = 'Membership';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setM) {
        return Container(
          decoration: const BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(ctx).viewInsets.bottom + 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Row(children: [
                Container(width: 42, height: 42, decoration: BoxDecoration(color: kGoldLight, borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.add_rounded, color: kGoldDark, size: 22)),
                const SizedBox(width: 12),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('New Entry', style: TextStyle(color: kText1, fontSize: 18, fontWeight: FontWeight.w900)),
                  Text('${_days[_date.weekday % 7]}, ${_date.day} ${_months[_date.month - 1]}',
                      style: const TextStyle(color: kText2, fontSize: 11)),
                ]),
              ]),
              const SizedBox(height: 20),
              // Type toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
                child: Row(children: [
                  _TypeToggleBtn('Receipt', Icons.arrow_circle_down_rounded, type == 'cr', kGreen, kGreenBg, () => setM(() => type = 'cr')),
                  const SizedBox(width: 4),
                  _TypeToggleBtn('Payment', Icons.arrow_circle_up_rounded,   type == 'dr', kRed,   kRedBg,   () => setM(() => type = 'dr')),
                ]),
              ),
              const SizedBox(height: 14),
              _FieldInput(descCtrl,   'Description', Icons.edit_outlined),
              const SizedBox(height: 10),
              _FieldInput(amountCtrl, 'Amount (₹)', Icons.currency_rupee_rounded, numeric: true),
              const SizedBox(height: 16),
              const Text('PAYMENT MODE', style: TextStyle(color: kText2, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Row(children: ['UPI','Cash','NEFT','Card'].map((m) {
                final sel  = mode == m;
                final meta = _modeMeta[m]!;
                return Expanded(child: GestureDetector(
                  onTap: () => setM(() => mode = m),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? meta['bg'] as Color : kSurface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sel ? (meta['color'] as Color).withOpacity(0.4) : kBorder),
                    ),
                    child: Column(children: [
                      Icon(meta['icon'] as IconData, size: 18, color: sel ? meta['color'] as Color : kText2),
                      const SizedBox(height: 4),
                      Text(m, style: TextStyle(color: sel ? meta['color'] as Color : kText2, fontSize: 9, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                ));
              }).toList()),
              const SizedBox(height: 16),
              const Text('CATEGORY', style: TextStyle(color: kText2, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: _catMeta.keys.map((c) {
                  final sel  = cat == c;
                  final meta = _catMeta[c]!;
                  return GestureDetector(
                    onTap: () => setM(() => cat = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: sel ? meta['bg'] as Color : kSurface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: sel ? (meta['color'] as Color).withOpacity(0.35) : kBorder),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(meta['icon'] as IconData, size: 12, color: sel ? meta['color'] as Color : kText2),
                        const SizedBox(width: 5),
                        Text(c, style: TextStyle(color: sel ? meta['color'] as Color : kText2, fontSize: 10, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  final amt = double.tryParse(amountCtrl.text);
                  if (descCtrl.text.isEmpty || amt == null) return;
                  setState(() {
                    _data[_key] ??= [];
                    _data[_key]!.add({
                      'time': _nowTime(), 'desc': descCtrl.text,
                      'cat': cat, 'type': type, 'amount': amt, 'mode': mode, 'note': '',
                    });
                    _reveal.forward(from: 0);
                  });
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: double.infinity, height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [kGold, Color(0xFFD9EE3A)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: kGoldGlow, blurRadius: 18, offset: const Offset(0, 6))],
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.check_circle_rounded, color: kGoldDeep, size: 18),
                    SizedBox(width: 8),
                    Text('SAVE ENTRY', style: TextStyle(color: kGoldDeep, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Transaction card ──────────────────────────────────
class _TxCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final bool isCr, isLast;
  final Map<String, dynamic> cat, mode;
  final String Function(double) fmtAmt;
  const _TxCard({required this.entry, required this.isCr, required this.isLast,
    required this.cat, required this.mode, required this.fmtAmt});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isCr ? kGoldBorder.withOpacity(0.5) : kRedBorder.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          // Color stripe
          Container(height: 3,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: isCr ? [kGoldLight, kGold, kGoldLight] : [kRedBorder, kRed.withOpacity(0.4), kRedBorder]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                // Category icon
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: cat['bg'] as Color,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: (cat['color'] as Color).withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry['desc'], style: const TextStyle(color: kText1, fontSize: 13, fontWeight: FontWeight.w700, height: 1.3)),
                      const SizedBox(height: 4),
                      Row(children: [
                        // Time
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(6)),
                          child: Text(entry['time'], style: const TextStyle(color: kText2, fontSize: 9, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 6),
                        // Mode chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: mode['bg'] as Color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(mode['icon'] as IconData, size: 9, color: mode['color'] as Color),
                            const SizedBox(width: 3),
                            Text(entry['mode'], style: TextStyle(color: mode['color'] as Color, fontSize: 9, fontWeight: FontWeight.w800)),
                          ]),
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(children: [
                      Icon(isCr ? Icons.add_rounded : Icons.remove_rounded, size: 12, color: isCr ? kGreen : kRed),
                      Text('₹${fmtAmt(entry['amount'] as double)}',
                        style: TextStyle(color: isCr ? kGreen : kRed, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isCr ? kGoldLight : kRedBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isCr ? kGoldBorder : kRedBorder),
                      ),
                      child: Text(isCr ? 'RECEIPT' : 'PAYMENT',
                        style: TextStyle(color: isCr ? kGoldDark : kRed, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small reusables ───────────────────────────────────
class _SubCard extends StatelessWidget {
  final IconData icon; final String label, value;
  final Color accent, bg, border;
  const _SubCard({required this.icon, required this.label, required this.value,
    required this.accent, required this.bg, required this.border});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: BoxDecoration(
      color: bg, borderRadius: BorderRadius.circular(18),
      border: Border.all(color: border),
      boxShadow: [BoxShadow(color: accent.withOpacity(0.1), blurRadius: 14)],
    ),
    child: Row(children: [
      Container(width: 38, height: 38,
        decoration: BoxDecoration(color: accent.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: accent, size: 18),
      ),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: accent.withOpacity(0.7), fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(color: accent, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: -0.4)),
      ]),
    ]),
  );
}

class _IconBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _IconBtn(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 40, height: 40,
      decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(13), border: Border.all(color: kBorder)),
      child: Icon(icon, size: 16, color: kText1),
    ),
  );
}

class _ShiftBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _ShiftBtn(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 38, height: 38,
      decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(12), border: Border.all(color: kBorder)),
      child: Icon(icon, color: kText1, size: 22),
    ),
  );
}

class _TypeToggleBtn extends StatelessWidget {
  final String label; final IconData icon; final bool sel;
  final Color ac, abg; final VoidCallback onTap;
  const _TypeToggleBtn(this.label, this.icon, this.sel, this.ac, this.abg, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: sel ? abg : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: sel ? ac.withOpacity(0.4) : Colors.transparent),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 16, color: sel ? ac : kText2),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: sel ? ac : kText2, fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
    ),
  ));
}

class _FieldInput extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint; final IconData icon; final bool numeric;
  const _FieldInput(this.ctrl, this.hint, this.icon, {this.numeric = false});
  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    keyboardType: numeric ? TextInputType.number : TextInputType.text,
    style: const TextStyle(color: kText1, fontSize: 14, fontWeight: FontWeight.w600),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: kText2),
      prefixIcon: Icon(icon, color: kGoldDark, size: 18),
      filled: true, fillColor: kSurface2,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kGoldBorder, width: 1.5)),
    ),
  );
}