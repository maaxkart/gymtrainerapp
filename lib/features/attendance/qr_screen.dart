import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/api_service.dart';

// ── Original Brand tokens (light theme) ──────────────────
const kGold        = Color(0xFFC8DC32);
const kGoldDark    = Color(0xFF8FA000);
const kGoldDeep    = Color(0xFF3A4500);
const kGoldLight   = Color(0xFFF5F8D6);
const kGoldBorder  = Color(0xFFE2EC8A);
const kBg          = Color(0xFFF7F7F5);
const kSurface     = Color(0xFFFFFFFF);
const kSurface2    = Color(0xFFF5F5F5);
const kBorder      = Color(0xFFEFEFEF);
const kText1       = Color(0xFF111111);
const kText2       = Color(0xFFAAAAAA);
const kText3       = Color(0xFFCCCCCC);
const kGreen       = Color(0xFF4CAF50);
const kGreenBg     = Color(0xFFE8F5E9);
const kGreenBorder = Color(0xFFA5D6A7);
const kGreenText   = Color(0xFF2E7D32);
const kRed         = Color(0xFFE53935);
const kRedBg       = Color(0xFFFFF3F3);
const kRedBorder   = Color(0xFFFFCDD2);
const kRedText     = Color(0xFFC62828);

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> with TickerProviderStateMixin {

  // ── State ────────────────────────────────────────────
  String? qrToken;
  bool    scanned       = false;
  Map?    verifiedUser;
  bool    loading       = false;
  bool    isGymOpen     = true;
  int     todayCheckins = 0;
  bool    _countLoading = true;

  // ── Animation controllers ────────────────────────────
  AnimationController? _pulseCtrl;
  AnimationController? _scanSuccessCtrl;
  AnimationController? _verifyBtnCtrl;
  Animation<double>?   _pulseAnim;
  Animation<double>?   _scanSuccessAnim;
  Animation<double>?   _scanSlideAnim;
  Animation<double>?   _verifyScaleAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl!, curve: Curves.easeInOut),
    );

    _scanSuccessCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scanSuccessAnim = CurvedAnimation(
      parent: _scanSuccessCtrl!,
      curve: Curves.elasticOut,
    );
    _scanSlideAnim = Tween<double>(begin: 24, end: 0).animate(
      CurvedAnimation(parent: _scanSuccessCtrl!, curve: Curves.easeOutCubic),
    );

    _verifyBtnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _verifyScaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _verifyBtnCtrl!, curve: Curves.easeIn),
    );

    _loadCheckinCount();
  }

  @override
  void dispose() {
    _pulseCtrl?.dispose();
    _scanSuccessCtrl?.dispose();
    _verifyBtnCtrl?.dispose();
    super.dispose();
  }

  Future<void> _loadCheckinCount() async {
    try {
      final live = await ApiService.getLiveUsers();
      if (mounted) {
        setState(() {
          todayCheckins = (live as List?)?.length ?? 0;
          _countLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _countLoading = false);
    }
  }

  Future<void> _verifyUser() async {
    if (qrToken == null) {
      _showSnack("Scan a QR code first", isError: true);
      return;
    }
    await _verifyBtnCtrl?.forward();
    await _verifyBtnCtrl?.reverse();
    HapticFeedback.heavyImpact();
    setState(() => loading = true);

    try {
      final res = await ApiService.verifyCheckin(token: qrToken!);
      final Map<String, dynamic> resMap =
      Map<String, dynamic>.from(res as Map? ?? {});
      final dynamic rawData = resMap["data"];
      final Map<String, dynamic>? userData = rawData != null
          ? Map<String, dynamic>.from(rawData as Map)
          : null;
      final String message = (resMap["message"] ?? "Done").toString();

      if (mounted) {
        setState(() {
          loading      = false;
          verifiedUser = userData;
          scanned      = false;
          qrToken      = null;
          if (verifiedUser != null) todayCheckins++;
        });
        HapticFeedback.lightImpact();
        _showSnack(message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => loading = false);
        _showSnack("Verification failed. Please try again.", isError: true);
      }
    }
  }

  Future<void> _toggleGymStatus() async {
    HapticFeedback.selectionClick();
    try {
      final res = await ApiService.toggleGymStatus();
      final Map<String, dynamic> resMap =
      Map<String, dynamic>.from(res as Map? ?? {});
      final bool open      = (resMap["is_open"] as bool?) ?? isGymOpen;
      final String message = (resMap["message"] ?? "Status updated").toString();
      if (mounted) {
        setState(() => isGymOpen = open);
        _showSnack(message);
      }
    } catch (_) {
      _showSnack("Could not update gym status.", isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isError
                    ? kRed.withOpacity(0.12)
                    : kGoldDeep.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: isError ? kRed : kGoldDeep,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: TextStyle(
                  color: isError ? kRedText : kGoldDeep,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? kRedBg : kGoldLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
              color: isError ? kRedBorder : kGoldBorder, width: 1.5),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        elevation: 0,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: isGymOpen ? _buildOpenBody() : _buildClosedBody(),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────
  // TOP BAR
  // ────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        boxShadow: [
          BoxShadow(
            color: kText1.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 58, 20, 16),
      child: Row(
        children: [
          _TapScaleWidget(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: kSurface2,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kBorder, width: 1.5),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: kText1,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "QR Attendance",
                  style: TextStyle(
                    color: kText1,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Scan & verify members instantly",
                  style: TextStyle(
                    color: kText2,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _TapScaleWidget(
            onTap: _toggleGymStatus,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: isGymOpen ? kGreenBg : kRedBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isGymOpen ? kGreenBorder : kRedBorder,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PulseDot(
                    color: isGymOpen ? kGreen : kRed,
                    pulse: isGymOpen,
                    pulseAnim: _pulseAnim,
                    pulseCtrl: _pulseCtrl,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    isGymOpen ? "OPEN" : "CLOSED",
                    style: TextStyle(
                      color: isGymOpen ? kGreenText : kRedText,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────
  // OPEN BODY
  // ────────────────────────────────────────────────────
  Widget _buildOpenBody() {
    return ListView(
      key: const ValueKey('open'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      children: [
        _buildStatsCard(),
        const SizedBox(height: 14),
        _buildScannerCard(),
        const SizedBox(height: 12),
        if (verifiedUser != null) ...[
          _buildVerifiedCard(),
          const SizedBox(height: 12),
        ],
        _buildVerifyButton(),
      ],
    );
  }

  // ────────────────────────────────────────────────────
  // STATS CARD
  // ────────────────────────────────────────────────────
  Widget _buildStatsCard() {
    return Container(
      decoration: BoxDecoration(
        color: kGold,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: kGold.withOpacity(0.5),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: kGold.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 22,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: kGoldDeep.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Text(
                          "TODAY'S CHECK-INS",
                          style: TextStyle(
                            color: kGoldDeep,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _countLoading
                          ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: kGoldDeep,
                        ),
                      )
                          : Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "$todayCheckins",
                            style: const TextStyle(
                              color: kGoldDeep,
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              height: 1,
                              letterSpacing: -2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Padding(
                            padding: EdgeInsets.only(bottom: 7),
                            child: Text(
                              "members",
                              style: TextStyle(
                                color: kGoldDeep,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: kGoldDeep,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            "Live — updates on each scan",
                            style: TextStyle(
                              color: kGoldDeep,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: kGoldDeep.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: const Icon(
                    Icons.group_outlined,
                    color: kGoldDeep,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────
  // SCANNER CARD
  // ────────────────────────────────────────────────────
  Widget _buildScannerCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: scanned ? kGoldBorder : kBorder,
          width: scanned ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: scanned
                ? kGold.withOpacity(0.2)
                : kText1.withOpacity(0.05),
            blurRadius: scanned ? 28 : 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kGoldLight,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: kGoldBorder, width: 1.5),
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded,
                      color: kGoldDark, size: 19),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Scan Member QR",
                    style: TextStyle(
                      color: kText1,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: kGoldLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kGoldBorder, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PulseDot(
                        color: kGreen,
                        pulse: true,
                        pulseAnim: _pulseAnim,
                        pulseCtrl: _pulseCtrl,
                        size: 6,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "LIVE",
                        style: TextStyle(
                          color: kGoldDark,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(height: 1.5, color: kBorder),

          // Camera
          SizedBox(
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  onDetect: (BarcodeCapture capture) {
                    if (scanned) return;
                    if (capture.barcodes.isEmpty) return;
                    final String? code =
                        capture.barcodes.first.rawValue;
                    if (code != null && code.isNotEmpty) {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        scanned = true;
                        qrToken = code;
                      });
                      _scanSuccessCtrl?.forward(from: 0);
                    }
                  },
                ),
                Positioned.fill(
                  child: CustomPaint(painter: _VignettePainter()),
                ),
                AnimatedBuilder(
                  animation: _pulseCtrl ?? kAlwaysCompleteAnimation,
                  builder: (_, __) => SizedBox(
                    width: 210,
                    height: 210,
                    child: CustomPaint(
                      painter: _ScanFramePainter(
                        progress: scanned
                            ? 1.0
                            : (_pulseAnim?.value ?? 1.0),
                        scanned: scanned,
                      ),
                    ),
                  ),
                ),
                if (!scanned) const _ScanLineWidget(),
                if (!scanned)
                  Positioned(
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.1)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.center_focus_weak_rounded,
                              color: Colors.white54, size: 12),
                          SizedBox(width: 6),
                          Text(
                            "Point at member's QR code",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // QR Scanned Banner
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: qrToken != null
                ? AnimatedBuilder(
              animation:
              _scanSuccessCtrl ?? kAlwaysCompleteAnimation,
              builder: (_, __) => Transform.translate(
                offset: Offset(0, _scanSlideAnim?.value ?? 0),
                child: Opacity(
                  opacity: (_scanSuccessAnim?.value ?? 1.0)
                      .clamp(0.0, 1.0),
                  child: _buildScannedBanner(),
                ),
              ),
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ── Scanned Banner ──────────────────────────────────
  Widget _buildScannedBanner() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: const BoxDecoration(
        color: kGoldLight,
        border:
        Border(top: BorderSide(color: kGoldBorder, width: 1.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: kGold.withOpacity(0.22),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kGoldBorder, width: 1.5),
            ),
            child: const Icon(Icons.qr_code_2_rounded,
                color: kGoldDark, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: kGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "QR Code Scanned",
                      style: TextStyle(
                        color: kGoldDeep,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: kGreenBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: kGreenBorder),
                      ),
                      child: const Text(
                        "✓ READY",
                        style: TextStyle(
                          color: kGreenText,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  qrToken!.length > 28
                      ? '${qrToken!.substring(0, 28)}…'
                      : qrToken!,
                  style: const TextStyle(
                    color: kText2,
                    fontSize: 10,
                    fontFamily: 'monospace',
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          _TapScaleWidget(
            onTap: () {
              setState(() {
                qrToken = null;
                scanned = false;
              });
              _scanSuccessCtrl?.reverse();
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: kRedBg,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: kRedBorder, width: 1.5),
              ),
              child: const Icon(Icons.close_rounded,
                  color: kRed, size: 15),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────
  // VERIFIED USER CARD
  // ────────────────────────────────────────────────────
  Widget _buildVerifiedCard() {
    final Map<String, dynamic> user =
    Map<String, dynamic>.from(verifiedUser as Map? ?? {});
    final name     = user["name"]?.toString() ?? "Member";
    final initials = name.trim().isNotEmpty
        ? name.trim().split(" ").map((w) => w[0]).take(2).join()
        : "M";

    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: kGreenBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kGreen.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Green header stripe
          Container(
            padding: const EdgeInsets.fromLTRB(18, 13, 18, 13),
            decoration: const BoxDecoration(
              color: kGreenBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded,
                    color: kGreen, size: 16),
                const SizedBox(width: 7),
                const Text(
                  "MEMBER VERIFIED",
                  style: TextStyle(
                    color: kGreenText,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Text(
                  TimeOfDay.now().format(context),
                  style: const TextStyle(
                    color: kGreenText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: kGreenBorder),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: kGold,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: kGold.withOpacity(0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials.toUpperCase(),
                    style: const TextStyle(
                      color: kGoldDeep,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: kText1,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kGoldLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: kGoldBorder, width: 1.5),
                        ),
                        child: Text(
                          (user["plan"]?.toString() ?? "STANDARD")
                              .toUpperCase(),
                          style: const TextStyle(
                            color: kGoldDark,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: kBorder),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
            child: Column(
              children: [
                _InfoRow(
                  "Check-in Time",
                  TimeOfDay.now().format(context),
                  icon: Icons.access_time_filled_rounded,
                  iconColor: kGoldDark,
                  iconBg: kGoldLight,
                ),
                if (user["valid_until"] != null) ...[
                  const SizedBox(height: 6),
                  _InfoRow(
                    "Valid Until",
                    user["valid_until"].toString(),
                    icon: Icons.event_available_rounded,
                    iconColor: kGreenText,
                    iconBg: kGreenBg,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _InfoRow(String label, String value,
      {required IconData icon,
        required Color iconColor,
        required Color iconBg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: kSurface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: kText2,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ),
          Text(
            value,
            style: const TextStyle(
              color: kText1,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────
  // VERIFY BUTTON
  // ────────────────────────────────────────────────────
  Widget _buildVerifyButton() {
    final bool ready = qrToken != null && !loading;

    return AnimatedBuilder(
      animation: _verifyBtnCtrl ?? kAlwaysCompleteAnimation,
      builder: (_, __) => Transform.scale(
        scale: _verifyScaleAnim?.value ?? 1.0,
        child: GestureDetector(
          onTap: loading ? null : _verifyUser,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 62,
            decoration: BoxDecoration(
              color: ready ? kGold : kSurface2,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: ready ? kGoldBorder : kBorder,
                width: 1.5,
              ),
              boxShadow: ready
                  ? [
                BoxShadow(
                  color: kGold.withOpacity(0.55),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: kGold.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
                  : [],
            ),
            child: Center(
              child: loading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: kGoldDeep,
                ),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      ready
                          ? Icons.verified_rounded
                          : Icons.qr_code_scanner_rounded,
                      color: ready ? kGoldDeep : kText2,
                      size: 20,
                      key: ValueKey(ready),
                    ),
                  ),
                  const SizedBox(width: 10),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      ready
                          ? "Verify Check-in"
                          : "Scan QR to Continue",
                      key: ValueKey(ready),
                      style: TextStyle(
                        color: ready ? kGoldDeep : kText2,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────
  // CLOSED BODY
  // ────────────────────────────────────────────────────
  Widget _buildClosedBody() {
    return Center(
      key: const ValueKey('closed'),
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: kRedBg,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: kRedBorder, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: kRed.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  color: kRed, size: 40),
            ),
            const SizedBox(height: 28),
            const Text(
              "Gym is Closed",
              style: TextStyle(
                color: kText1,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Tap below to open the gym\nand enable QR check-ins.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kText2,
                fontSize: 14,
                height: 1.7,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 36),
            _TapScaleWidget(
              onTap: _toggleGymStatus,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 36, vertical: 17),
                decoration: BoxDecoration(
                  color: kGold,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: kGold.withOpacity(0.55),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Text(
                  "Open Gym Now",
                  style: TextStyle(
                    color: kGoldDeep,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── PULSE DOT ─────────────────────────────────────────────
class _PulseDot extends StatelessWidget {
  final Color                color;
  final bool                 pulse;
  final Animation<double>?   pulseAnim;
  final AnimationController? pulseCtrl;
  final double               size;

  const _PulseDot({
    required this.color,
    required this.pulse,
    this.pulseAnim,
    this.pulseCtrl,
    this.size = 7,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseCtrl ?? kAlwaysCompleteAnimation,
      builder: (_, __) => Transform.scale(
        scale: pulse ? (pulseAnim?.value ?? 1.0) : 1.0,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: pulse
                ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 5)]
                : [],
          ),
        ),
      ),
    );
  }
}

// ── TAP SCALE WIDGET ──────────────────────────────────────
class _TapScaleWidget extends StatefulWidget {
  final Widget       child;
  final VoidCallback onTap;

  const _TapScaleWidget({required this.child, required this.onTap});

  @override
  State<_TapScaleWidget> createState() => _TapScaleWidgetState();
}

class _TapScaleWidgetState extends State<_TapScaleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) async {
        await _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}

// ── SCAN LINE ─────────────────────────────────────────────
class _ScanLineWidget extends StatefulWidget {
  const _ScanLineWidget();

  @override
  State<_ScanLineWidget> createState() => _ScanLineWidgetState();
}

class _ScanLineWidgetState extends State<_ScanLineWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Positioned(
        top: 30 + (196 * _anim.value),
        child: Container(
          width: 210,
          height: 2.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                kGold.withOpacity(0.8),
                kGold,
                kGold.withOpacity(0.8),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: kGold.withOpacity(0.55),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── VIGNETTE OVERLAY ──────────────────────────────────────
class _VignettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.36);
    const boxSize = 210.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final hole = Rect.fromLTWH(
        cx - boxSize / 2, cy - boxSize / 2, boxSize, boxSize);
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
          RRect.fromRectAndRadius(hole, const Radius.circular(14)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_VignettePainter old) => false;
}

// ── SCAN FRAME PAINTER ────────────────────────────────────
class _ScanFramePainter extends CustomPainter {
  final double progress;
  final bool   scanned;

  _ScanFramePainter({required this.progress, required this.scanned});

  @override
  void paint(Canvas canvas, Size size) {
    final color = scanned ? kGreen : kGold;

    final paint = Paint()
      ..color = color
      ..strokeWidth = scanned ? 4.0 : 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3 * progress)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    const corner = 32.0;
    const r = 10.0;

    void seg(Offset a, Offset b) {
      canvas.drawLine(a, b, glowPaint);
      canvas.drawLine(a, b, paint);
    }

    void arc(Rect rect, double start, double sweep) {
      canvas.drawArc(rect, start, sweep, false, glowPaint);
      canvas.drawArc(rect, start, sweep, false, paint);
    }

    // Top-left
    seg(Offset(r, 0), Offset(corner, 0));
    arc(const Rect.fromLTWH(0, 0, r * 2, r * 2), math.pi, -math.pi / 2);
    seg(Offset(0, r), Offset(0, corner));

    // Top-right
    seg(Offset(size.width - corner, 0), Offset(size.width - r, 0));
    arc(Rect.fromLTWH(size.width - r * 2, 0, r * 2, r * 2), -math.pi / 2, -math.pi / 2);
    seg(Offset(size.width, r), Offset(size.width, corner));

    // Bottom-left
    seg(Offset(0, size.height - corner), Offset(0, size.height - r));
    arc(Rect.fromLTWH(0, size.height - r * 2, r * 2, r * 2), math.pi / 2, math.pi / 2);
    seg(Offset(r, size.height), Offset(corner, size.height));

    // Bottom-right
    seg(Offset(size.width, size.height - corner), Offset(size.width, size.height - r));
    arc(Rect.fromLTWH(size.width - r * 2, size.height - r * 2, r * 2, r * 2), 0, math.pi / 2);
    seg(Offset(size.width - corner, size.height), Offset(size.width - r, size.height));
  }

  @override
  bool shouldRepaint(_ScanFramePainter old) =>
      old.progress != progress || old.scanned != scanned;
}