import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

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

class PnlScreen extends StatefulWidget {
  const PnlScreen({super.key});
  @override
  State<PnlScreen> createState() => _PnlScreenState();
}

class _PnlScreenState extends State<PnlScreen> with TickerProviderStateMixin {
  late final AnimationController _gaugeCtrl =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..forward();
  late final AnimationController _barsCtrl =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();

  int _period = 2;
  final _periods = ["APR '25", "MAY '25", "JUN '25"];

  final _income = <Map<String, dynamic>>[
    {'label': 'Membership Fees',   'amount': 87500.0, 'icon': Icons.card_membership_rounded,    'color': const Color(0xFF5A6E00), 'bg': const Color(0xFFF5F8D6)},
    {'label': 'Personal Training', 'amount': 24000.0, 'icon': Icons.sports_gymnastics_rounded,  'color': const Color(0xFF1565C0), 'bg': const Color(0xFFE3F2FD)},
    {'label': 'Supplement Sales',  'amount': 11200.0, 'icon': Icons.local_pharmacy_rounded,     'color': const Color(0xFF00695C), 'bg': const Color(0xFFE0F2F1)},
    {'label': 'Locker Rentals',    'amount': 4800.0,  'icon': Icons.lock_rounded,               'color': const Color(0xFF4527A0), 'bg': const Color(0xFFEDE7F6)},
    {'label': 'Guest Passes',      'amount': 2100.0,  'icon': Icons.confirmation_number_rounded, 'color': const Color(0xFFE65100), 'bg': const Color(0xFFFFF3E0)},
  ];

  final _expenses = <Map<String, dynamic>>[
    {'label': 'Staff Salaries',    'amount': 45000.0, 'icon': Icons.people_alt_rounded,         'color': const Color(0xFF6A1B9A), 'bg': const Color(0xFFF3E5F5)},
    {'label': 'Utilities',         'amount': 9200.0,  'icon': Icons.bolt_rounded,               'color': const Color(0xFFF57F17), 'bg': const Color(0xFFFFFDE7)},
    {'label': 'Equipment Maint.',  'amount': 5500.0,  'icon': Icons.build_circle_rounded,       'color': const Color(0xFF1565C0), 'bg': const Color(0xFFE3F2FD)},
    {'label': 'Inventory Stock',   'amount': 12000.0, 'icon': Icons.inventory_2_rounded,        'color': const Color(0xFFC62828), 'bg': const Color(0xFFFCE4EC)},
    {'label': 'Rent',              'amount': 18000.0, 'icon': Icons.apartment_rounded,          'color': const Color(0xFF37474F), 'bg': const Color(0xFFECEFF1)},
    {'label': 'Marketing',         'amount': 3200.0,  'icon': Icons.campaign_rounded,           'color': const Color(0xFF00838F), 'bg': const Color(0xFFE0F7FA)},
    {'label': 'Miscellaneous',     'amount': 1800.0,  'icon': Icons.more_horiz_rounded,         'color': const Color(0xFF757575), 'bg': const Color(0xFFF5F5F5)},
  ];

  double get _tIncome   => _income.fold(0, (s, e) => s + (e['amount'] as double));
  double get _tExpenses => _expenses.fold(0, (s, e) => s + (e['amount'] as double));
  double get _netProfit => _tIncome - _tExpenses;
  double get _margin    => (_netProfit / _tIncome).clamp(0.0, 1.0);

  @override
  void dispose() { _gaugeCtrl.dispose(); _barsCtrl.dispose(); super.dispose(); }

  String _fmt(double v) => v >= 100000
      ? '${(v / 100000).toStringAsFixed(2)}L'
      : v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : v.toStringAsFixed(0);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          _buildPeriodSelector(),
          _buildResultCard(),
          _buildTwoKpi(),
          _buildSection('INCOME STREAMS', _income, true),
          _buildSection('COST CENTRES',   _expenses, false),
          _buildNetSummary(),
        ],
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) => SliverToBoxAdapter(
    child: Container(
      color: kSurface,
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 14, 20, 16),
      child: Row(children: [
        _NavBtn(Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context)),
        Expanded(
          child: Column(children: [
            ShaderMask(
              shaderCallback: (r) => const LinearGradient(colors: [kGoldDark, kGold, kGoldDeep]).createShader(r),
              child: const Text('P & L ACCOUNT',
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
        _NavBtn(Icons.ios_share_rounded, () {}),
      ]),
    ),
  );

  // ── PERIOD SELECTOR ───────────────────────────────────
  Widget _buildPeriodSelector() => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
        ),
        child: Row(children: List.generate(_periods.length, (i) {
          final sel = i == _period;
          return Expanded(child: GestureDetector(
            onTap: () { setState(() => _period = i); _gaugeCtrl.forward(from: 0); _barsCtrl.forward(from: 0); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: sel ? kGold : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: sel ? [const BoxShadow(color: kGoldGlow, blurRadius: 14)] : [],
              ),
              child: Text(_periods[i],
                textAlign: TextAlign.center,
                style: TextStyle(color: sel ? kGoldDeep : kText2, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
              ),
            ),
          ));
        })),
      ),
    ),
  );

  // ── BIG RESULT CARD ───────────────────────────────────
  Widget _buildResultCard() {
    final isProfit = _netProfit > 0;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: isProfit
                ? const LinearGradient(colors: [kGoldDeep, Color(0xFF7A9400)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                : const LinearGradient(colors: [Color(0xFF8B1A1A), kRed], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(color: isProfit ? kGoldGlow : kRed.withOpacity(0.2), blurRadius: 32, offset: const Offset(0, 10)),
            ],
          ),
          child: Row(
            children: [
              // Arc gauge
              SizedBox(
                width: 120, height: 80,
                child: AnimatedBuilder(
                  animation: _gaugeCtrl,
                  builder: (_, __) => CustomPaint(
                    painter: _MiniArcPainter(
                      progress: CurvedAnimation(parent: _gaugeCtrl, curve: Curves.easeOutCubic).value,
                      margin: _margin, isProfit: isProfit,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isProfit ? 'NET PROFIT' : 'NET LOSS',
                          style: const TextStyle(color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text('₹${_fmt(_netProfit.abs())}',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1, height: 1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${_periods[_period]} · ${(_margin * 100).toStringAsFixed(1)}% margin',
                      style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── TWO KPI BLOCKS ────────────────────────────────────
  Widget _buildTwoKpi() => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(children: [
        Expanded(child: _KpiCard(Icons.trending_up_rounded,   'INCOME',  _tIncome,   kGreen, kGreenBg, kGreenBdr)),
        const SizedBox(width: 10),
        Expanded(child: _KpiCard(Icons.trending_down_rounded, 'EXPENSE', _tExpenses, kRed,   kRedBg,   kRedBorder)),
      ]),
    ),
  );

  // ── SECTION ───────────────────────────────────────────
  Widget _buildSection(String title, List<Map<String, dynamic>> items, bool isIncome) {
    final total = items.fold<double>(0, (s, e) => s + (e['amount'] as double));
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                Container(width: 3, height: 16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: isIncome ? [kGold, kGoldDark] : [kRed, kRed.withOpacity(0.4)],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(color: kText2, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
              ]),
              Text('₹${_fmt(total)}',
                style: TextStyle(color: isIncome ? kGoldDark : kRed, fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ]),
            const SizedBox(height: 14),
            // Items
            Container(
              decoration: BoxDecoration(
                color: kSurface, borderRadius: BorderRadius.circular(22),
                border: Border.all(color: kBorder),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Column(children: items.asMap().entries.map((entry) {
                final i    = entry.key;
                final item = entry.value;
                final pct  = (item['amount'] as double) / total;
                final isLast = i == items.length - 1;
                return Column(children: [
                  AnimatedBuilder(
                    animation: _barsCtrl,
                    builder: (_, __) {
                      final t = CurvedAnimation(
                        parent: _barsCtrl,
                        curve: Interval((i * 0.09).clamp(0, 0.65), ((i * 0.09) + 0.35).clamp(0, 1.0), curve: Curves.easeOutCubic),
                      );
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                        child: Row(children: [
                          // Icon
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: item['bg'] as Color,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [BoxShadow(color: (item['color'] as Color).withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 3))],
                            ),
                            child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(item['label'] as String,
                                style: const TextStyle(color: kText1, fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 7),
                              Stack(children: [
                                Container(height: 4,
                                  decoration: BoxDecoration(
                                    color: (item['color'] as Color).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: pct * t.value,
                                  child: Container(height: 4,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: isIncome ? [kGold, kGoldDark] : [kRed.withOpacity(0.5), kRed]),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ]),
                            ]),
                          ),
                          const SizedBox(width: 12),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text('₹${_fmt(item['amount'] as double)}',
                              style: const TextStyle(color: kText1, fontSize: 14, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: isIncome ? kGoldLight : kRedBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: isIncome ? kGoldBorder : kRedBorder),
                              ),
                              child: Text('${(pct * 100).toStringAsFixed(1)}%',
                                style: TextStyle(color: isIncome ? kGoldDark : kRed, fontSize: 9, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ]),
                        ]),
                      );
                    },
                  ),
                  if (!isLast) Container(height: 0.5, margin: const EdgeInsets.symmetric(horizontal: 14), color: kBorder),
                ]);
              }).toList()),
            ),
          ],
        ),
      ),
    );
  }

  // ── NET SUMMARY ───────────────────────────────────────
  Widget _buildNetSummary() {
    final isProfit = _netProfit > 0;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: isProfit
                ? const LinearGradient(colors: [kGoldLight, kGoldBorder], begin: Alignment.topLeft, end: Alignment.bottomRight)
                : const LinearGradient(colors: [kRedBg, kRedBorder], begin: Alignment.topLeft, end: Alignment.bottomRight),
            border: Border.all(color: isProfit ? kGoldBorder : kRedBorder, width: 1.5),
            boxShadow: [BoxShadow(color: isProfit ? kGoldGlow : kRed.withOpacity(0.12), blurRadius: 20, offset: const Offset(0, 6))],
          ),
          child: Row(children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: isProfit ? kGold : kRed,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: isProfit ? kGoldGlow : kRed.withOpacity(0.3), blurRadius: 14)],
              ),
              child: Icon(isProfit ? Icons.emoji_events_rounded : Icons.warning_amber_rounded,
                  color: isProfit ? kGoldDeep : Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isProfit ? 'NET PROFIT' : 'NET LOSS',
                style: TextStyle(color: isProfit ? kGoldDark : kRed, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 2),
              ),
              const SizedBox(height: 2),
              const Text('For the current period', style: TextStyle(color: kText2, fontSize: 10)),
            ])),
            Text('₹${_fmt(_netProfit.abs())}',
              style: TextStyle(color: isProfit ? kGoldDeep : kRed, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -1),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Mini arc gauge ────────────────────────────────────
class _MiniArcPainter extends CustomPainter {
  final double progress, margin; final bool isProfit;
  const _MiniArcPainter({required this.progress, required this.margin, required this.isProfit});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height;
    final r  = size.width * 0.44;

    // Track
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      math.pi, math.pi, false,
      Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );
    // Fill
    final sweep = math.pi * margin * progress;
    if (sweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        math.pi, sweep, false,
        Paint()
          ..color = Colors.white.withOpacity(0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round,
      );
    }
    // Pct text
    final pct = '${(margin * 100 * progress).toStringAsFixed(0)}%';
    final tp = TextPainter(
      text: TextSpan(text: pct, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height - 14));
    final sub = TextPainter(
      text: const TextSpan(text: 'MARGIN', style: TextStyle(color: Colors.white54, fontSize: 7, fontWeight: FontWeight.w700, letterSpacing: 2)),
      textDirection: TextDirection.ltr,
    )..layout();
    sub.paint(canvas, Offset(cx - sub.width / 2, cy - 10));
  }

  @override
  bool shouldRepaint(_MiniArcPainter o) => o.progress != progress;
}

// ── Sub-widgets ───────────────────────────────────────
class _NavBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _NavBtn(this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(width: 40, height: 40,
      decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(13), border: Border.all(color: kBorder)),
      child: Icon(icon, size: 16, color: kText1),
    ),
  );
}

class _KpiCard extends StatelessWidget {
  final IconData icon; final String label; final double amount;
  final Color accent, bg, border;
  const _KpiCard(this.icon, this.label, this.amount, this.accent, this.bg, this.border);
  @override
  Widget build(BuildContext context) {
    String fmt(double v) => v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}K' : v.toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [BoxShadow(color: accent.withOpacity(0.1), blurRadius: 14)],
      ),
      child: Row(children: [
        Container(width: 40, height: 40,
          decoration: BoxDecoration(color: accent.withOpacity(0.12), borderRadius: BorderRadius.circular(13)),
          child: Icon(icon, color: accent, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: accent.withOpacity(0.7), fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text('₹${fmt(amount)}', style: TextStyle(color: accent, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          ),
        ])),
      ]),
    );
  }
}