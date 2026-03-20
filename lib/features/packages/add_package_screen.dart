import 'package:flutter/material.dart';
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
const kRed        = Color(0xFFE53935);
const kRedBg      = Color(0xFFFFF3F3);
const kRedBorder  = Color(0xFFFFE0E0);

class AddPackageScreen extends StatefulWidget {
  final int     planId;
  final String  planName;
  final bool    isEdit;
  final dynamic price;

  const AddPackageScreen({
    super.key,
    required this.planId,
    required this.planName,
    required this.isEdit,
    this.price,
  });

  @override
  State<AddPackageScreen> createState() => _AddPackageScreenState();
}

class _AddPackageScreenState extends State<AddPackageScreen> {
  final _priceController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.price != null) {
      _priceController.text = widget.price.toString();
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  // ── Icon helper ──────────────────────────────────────
  IconData get _planIcon {
    final t = widget.planName.toLowerCase();
    if (t.contains("year") || t.contains("annual")) return Icons.emoji_events_outlined;
    if (t.contains("quarter"))                       return Icons.timelapse_outlined;
    if (t.contains("month"))                         return Icons.calendar_month_outlined;
    if (t.contains("premium") || t.contains("gold")) return Icons.workspace_premium_outlined;
    return Icons.fitness_center_outlined;
  }

  bool get _isPopular =>
      widget.planName.toLowerCase().contains("gold") ||
          widget.planName.toLowerCase().contains("premium");

  // ── Save / Update ────────────────────────────────────
  Future<void> _savePlan() async {
    if (_loading) return;
    if (_priceController.text.trim().isEmpty) {
      _showSnack("Please enter a price", isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final Map response;

      if (widget.isEdit) {
        response = await ApiService.updateGymPlan(
          gymPlanId: widget.planId,
          price:     _priceController.text.trim(),
          active:    true,
        );
      } else {
        response = await ApiService.addGymPlan(
          adminPlanId: widget.planId,
          customPrice: _priceController.text.trim(),
        );
      }

      if (!mounted) return;
      _showSnack((response["message"] ?? "Done").toString());
      Navigator.pop(context);

    } catch (_) {
      if (mounted) _showSnack("Something went wrong", isError: true);
    }

    if (mounted) setState(() => _loading = false);
  }

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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildCoverStrip(),
                  _buildBody(),
                ],
              ),
            ),
          ),
          _buildSaveBar(),
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
          Expanded(
            child: Text(
              widget.isEdit ? "Edit Package" : "Add Package",
              style: const TextStyle(
                color: kText1,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── COVER STRIP ──────────────────────────────────────
  Widget _buildCoverStrip() {
    return Stack(
      children: [
        Container(
          height: 100,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kGold, Color(0xFFDDED60), kGoldLight],
              stops: [0, 0.55, 1],
            ),
          ),
        ),
        CustomPaint(
          size: const Size(double.infinity, 100),
          painter: _HatchPainter(),
        ),
      ],
    );
  }

  // ── BODY ─────────────────────────────────────────────
  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Plan info card — overlaps cover strip
          Transform.translate(
            offset: const Offset(0, -28),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _isPopular ? kGoldBorder : kBorder,
                  width: _isPopular ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: kGold.withOpacity(.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _isPopular ? kGoldLight : kSurface2,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _planIcon,
                      color: _isPopular ? kGoldDark : kText2,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.planName,
                      style: const TextStyle(
                        color: kText1,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: kGold,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Text(
                      "PREMIUM",
                      style: TextStyle(
                        color: kGoldDeep,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Compensate transform offset
          const SizedBox(height: 0),

          // Set Price label
          const _SectionLabel("Set Custom Price"),
          const SizedBox(height: 10),

          // Price input card
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kGoldBorder, width: 2),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "₹",
                  style: TextStyle(
                    color: kGold,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: kText1,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      height: 1,
                    ),
                    decoration: const InputDecoration(
                      hintText: "0",
                      hintStyle: TextStyle(
                        color: kText2,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                        height: 1,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                // Clear button
                if (_priceController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() =>
                        _priceController.clear()),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: kSurface2,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close_rounded,
                          size: 14, color: kText2),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kGoldLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kGoldBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: kGoldDark,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.isEdit
                        ? "Update the price to change what members are charged."
                        : "Set your custom price for this plan. Members will see this rate.",
                    style: const TextStyle(
                      color: kGoldDark,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Remove plan button (edit mode only)
          if (widget.isEdit)
            GestureDetector(
              onTap: () {
                // TODO: implement delete
                Navigator.pop(context);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: kRedBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kRedBorder),
                ),
                child: const Center(
                  child: Text(
                    "Remove Plan",
                    style: TextStyle(
                      color: kRed,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── SAVE BAR ─────────────────────────────────────────
  Widget _buildSaveBar() {
    return Container(
      decoration: const BoxDecoration(
        color: kBg,
        border: Border(top: BorderSide(color: kBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: GestureDetector(
        onTap: _loading ? null : _savePlan,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            color: _loading ? kGold.withOpacity(.7) : kGold,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: _loading
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
              children: [
                Icon(
                  widget.isEdit
                      ? Icons.edit_rounded
                      : Icons.add_circle_outline_rounded,
                  color: kGoldDeep,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.isEdit ? "Update Plan" : "Add Plan",
                  style: const TextStyle(
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
      ),
    );
  }
}

// ── HATCH PAINTER ────────────────────────────────────────────
class _HatchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..strokeWidth = 1;
    const spacing = 14.0;
    for (double i = -size.height;
    i < size.width + size.height;
    i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HatchPainter old) => false;
}

// ── SECTION LABEL ────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      color: kText2,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    ),
  );
}