import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/api_service.dart';

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
const kGreen      = Color(0xFF4CAF50);
const kGreenBg    = Color(0xFFE8F5E9);
const kGreenBorder= Color(0xFFA5D6A7);
const kGreenText  = Color(0xFF2E7D32);
const kRed        = Color(0xFFE53935);
const kRedBg      = Color(0xFFFFF3F3);
const kRedBorder  = Color(0xFFFFCDD2);
const kRedText    = Color(0xFFC62828);

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {

  // ── Scanner state ─────────────────────────────────
  String? qrToken;
  int?    exerciseId;
  bool    scanned  = false;

  // ── API data ──────────────────────────────────────
  List exercises    = [];
  Map? verifiedUser;

  // ── UI state ──────────────────────────────────────
  bool loading      = false;  // verify button loading
  bool isGymOpen    = true;

  // ── Live check-in count from API ──────────────────
  int  todayCheckins  = 0;
  bool _countLoading  = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _loadCheckinCount();
  }

  // ── Load exercise master list ─────────────────────
  Future<void> _loadExercises() async {
    try {
      final data = await ApiService.getExerciseMaster();
      if (mounted) {
        setState(() => exercises = (data as List?) ?? []);
      }
    } catch (_) {
      if (mounted) setState(() => exercises = []);
    }
  }

  // ── Fetch real check-in count from getLiveUsers ───
  // Same API that AttendanceScreen uses — no static values.
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

  // ── Verify QR check-in ────────────────────────────
  Future<void> _verifyUser() async {
    if (qrToken == null || exerciseId == null) {
      _showSnack("Scan a QR code and select an exercise first", isError: true);
      return;
    }
    setState(() => loading = true);

    try {
      final res = await ApiService.verifyCheckin(
        token: qrToken!,
        exerciseId: exerciseId!,
      );

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
          // Increment locally after successful verify
          if (verifiedUser != null) todayCheckins++;
        });
        _showSnack(message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => loading = false);
        _showSnack("Verification failed. Please try again.", isError: true);
      }
    }
  }

  // ── Toggle gym open / closed ──────────────────────
  Future<void> _toggleGymStatus() async {
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

  // ── Snackbar helper ───────────────────────────────
  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: TextStyle(
            color: isError ? kRed : kGoldDeep,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: isError ? kRedBg : kGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: isGymOpen ? _buildOpenBody() : _buildClosedBody(),
          ),
        ],
      ),
    );
  }

  // ── TOP BAR ──────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 16),
      child: Row(
        children: [
          // Back button
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
              "QR Attendance",
              style: TextStyle(
                color: kText1,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),

          // Open / Closed toggle pill
          GestureDetector(
            onTap: _toggleGymStatus,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isGymOpen ? kGreenBg : kRedBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isGymOpen ? kGreenBorder : kRedBorder,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isGymOpen ? kGreen : kRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isGymOpen ? "OPEN" : "CLOSED",
                    style: TextStyle(
                      color: isGymOpen ? kGreenText : kRedText,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
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

  // ── OPEN BODY ──────────────────────────────────────────
  Widget _buildOpenBody() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeroCard(),
        const SizedBox(height: 14),
        _buildScannerCard(),
        const SizedBox(height: 12),
        _buildExerciseDropdown(),
        const SizedBox(height: 12),
        if (verifiedUser != null) ...[
          _buildVerifiedCard(),
          const SizedBox(height: 12),
        ],
        _buildVerifyButton(),
        const SizedBox(height: 30),
      ],
    );
  }

  // ── HERO CARD — live count from API ────────────────────
  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kGold,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "TODAY'S CHECK-INS",
                  style: TextStyle(
                    color: kGoldDeep,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),

                // Shows spinner while API loads, then real count
                _countLoading
                    ? const SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: kGoldDeep,
                  ),
                )
                    : Text(
                  "${todayCheckins.toString()} Members",
                  style: const TextStyle(
                    color: kText1,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 4),
                const Text(
                  "Live — updates on each scan",
                  style: TextStyle(
                    color: kGoldDeep,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.group_outlined, color: kText1, size: 26),
          ),
        ],
      ),
    );
  }

  // ── SCANNER CARD ───────────────────────────────────────
  Widget _buildScannerCard() {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Scan Member QR",
                  style: TextStyle(
                    color: kText1,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kGoldLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kGoldBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: kGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "LIVE",
                        style: TextStyle(
                          color: kGoldDark,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: kBorder, height: 1),

          // Camera viewport
          SizedBox(
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [

                // MobileScanner — guard against empty barcodes list
                MobileScanner(
                  onDetect: (BarcodeCapture capture) {
                    if (scanned) return;
                    if (capture.barcodes.isEmpty) return;
                    final String? code =
                        capture.barcodes.first.rawValue;
                    if (code != null && code.isNotEmpty) {
                      scanned = true;
                      setState(() => qrToken = code);
                    }
                  },
                ),

                // Gold corner frame
                SizedBox(
                  width: 190,
                  height: 190,
                  child: CustomPaint(painter: _ScanFramePainter()),
                ),

                // Hint pill
                Positioned(
                  bottom: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Point camera at member's QR code",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scanned token row
          if (qrToken != null)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 12),
              decoration: const BoxDecoration(
                color: kGoldLight,
                border: Border(top: BorderSide(color: kGoldBorder)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: kGold,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "QR Detected — ${qrToken!.length > 20 ? '${qrToken!.substring(0, 20)}…' : qrToken!}",
                      style: const TextStyle(
                        color: kGoldDeep,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      qrToken = null;
                      scanned = false;
                    }),
                    child: const Text(
                      "✕ Clear",
                      style: TextStyle(
                        color: kRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
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

  // ── EXERCISE DROPDOWN ──────────────────────────────────
  Widget _buildExerciseDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kGoldLight,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.fitness_center_outlined,
                color: kGoldDark, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: exerciseId,
                hint: const Text(
                  "Select Exercise Type",
                  style: TextStyle(color: kText2, fontSize: 14),
                ),
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: kText2,
                ),
                dropdownColor: kSurface,
                borderRadius: BorderRadius.circular(16),
                items: exercises.map<DropdownMenuItem<int>>((raw) {
                  final e  = Map<String, dynamic>.from(
                      raw as Map? ?? {});
                  final id = (e["id"] as num?)?.toInt() ?? 0;
                  final nm = e["name"]?.toString() ?? "";
                  return DropdownMenuItem<int>(
                    value: id,
                    child: Text(
                      nm,
                      style: const TextStyle(
                        color: kText1,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) =>
                    setState(() => exerciseId = val),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── VERIFIED USER CARD ─────────────────────────────────
  Widget _buildVerifiedCard() {
    final Map<String, dynamic> user =
    Map<String, dynamic>.from(verifiedUser as Map? ?? {});
    final name     = user["name"]?.toString() ?? "Member";
    final initials = name.trim().isNotEmpty
        ? name.trim().split(" ").map((w) => w[0]).take(2).join()
        : "M";

    // Exercise name lookup — safe
    String exerciseName = "—";
    try {
      final match = exercises.firstWhere(
            (raw) {
          final e = Map<String, dynamic>.from(raw as Map? ?? {});
          return (e["id"] as num?)?.toInt() == exerciseId;
        },
        orElse: () => <String, dynamic>{"name": "—"},
      );
      exerciseName =
          Map<String, dynamic>.from(match as Map? ?? {})["name"]
              ?.toString() ??
              "—";
    } catch (_) {}

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: kGold,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials.toUpperCase(),
                  style: const TextStyle(
                    color: kGoldDeep,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Name + plan badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: kText1,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: kGoldLight,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: kGoldBorder),
                      ),
                      child: Text(
                        (user["plan"]?.toString() ?? "STANDARD")
                            .toUpperCase(),
                        style: const TextStyle(
                          color: kGoldDark,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Verified badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kGreenBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kGreenBorder),
                ),
                child: const Text(
                  "✓ Verified",
                  style: TextStyle(
                    color: kGreenText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: kBorder, height: 1),
          const SizedBox(height: 10),

          _InfoRow("Exercise",    exerciseName),
          _InfoRow("Check-in",   TimeOfDay.now().format(context)),
          if (user["valid_until"] != null)
            _InfoRow("Valid Until", user["valid_until"].toString()),
        ],
      ),
    );
  }

  Widget _InfoRow(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key,
              style: const TextStyle(color: kText2, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                color: kText1,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              )),
        ],
      ),
    );
  }

  // ── VERIFY BUTTON ─────────────────────────────────────
  Widget _buildVerifyButton() {
    return GestureDetector(
      onTap: loading ? null : _verifyUser,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: loading ? kGold.withOpacity(.7) : kGold,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: kGoldDeep,
            ),
          )
              : Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_circle_outline_rounded,
                  color: kGoldDeep, size: 20),
              SizedBox(width: 8),
              Text(
                "Verify Check-in",
                style: TextStyle(
                  color: kGoldDeep,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── CLOSED BODY ────────────────────────────────────────
  Widget _buildClosedBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: kRedBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: kRedBorder),
              ),
              child: const Icon(Icons.lock_outline_rounded,
                  color: kRed, size: 36),
            ),
            const SizedBox(height: 20),
            const Text(
              "Gym is Closed",
              style: TextStyle(
                color: kText1,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Tap the button below to open the gym\nand enable check-ins.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: kText2, fontSize: 13, height: 1.6),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: _toggleGymStatus,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: kGold,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "Open Gym Now",
                  style: TextStyle(
                    color: kGoldDeep,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
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

// ── SCAN FRAME PAINTER ───────────────────────────────────────
class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC8DC32)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const corner = 24.0;
    const r      = 8.0;

    // Top-left
    canvas.drawLine(Offset(r, 0), Offset(corner, 0), paint);
    canvas.drawLine(Offset(0, r), Offset(0, corner), paint);
    canvas.drawArc(const Rect.fromLTWH(0, 0, r * 2, r * 2),
        3.14159, -3.14159 / 2, false, paint);

    // Top-right
    canvas.drawLine(
        Offset(size.width - corner, 0), Offset(size.width - r, 0), paint);
    canvas.drawLine(
        Offset(size.width, r), Offset(size.width, corner), paint);
    canvas.drawArc(
        Rect.fromLTWH(size.width - r * 2, 0, r * 2, r * 2),
        -3.14159 / 2, -3.14159 / 2, false, paint);

    // Bottom-left
    canvas.drawLine(
        Offset(0, size.height - corner), Offset(0, size.height - r), paint);
    canvas.drawLine(
        Offset(r, size.height), Offset(corner, size.height), paint);
    canvas.drawArc(
        Rect.fromLTWH(0, size.height - r * 2, r * 2, r * 2),
        3.14159 / 2, 3.14159 / 2, false, paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height - corner),
        Offset(size.width, size.height - r), paint);
    canvas.drawLine(Offset(size.width - corner, size.height),
        Offset(size.width - r, size.height), paint);
    canvas.drawArc(
        Rect.fromLTWH(
            size.width - r * 2, size.height - r * 2, r * 2, r * 2),
        0, 3.14159 / 2, false, paint);
  }

  @override
  bool shouldRepaint(_ScanFramePainter old) => false;
}