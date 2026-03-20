import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'add_alert_sheet.dart';

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
const kOrange     = Color(0xFFFF9800);
const kOrangeBg   = Color(0xFFFFF3E0);
const kOrangeBorder = Color(0xFFFFE0B2);
const kOrangeText = Color(0xFFE65100);

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List alerts = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    try {
      final data = await ApiService.getAlerts();
      if (mounted) {
        setState(() {
          alerts  = (data as List?) ?? [];
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _openAddSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(28)),
      ),
      builder: (_) => const AddAlertSheet(),
    );
    _loadAlerts();
  }

  // ── Determine alert type from expiry / title ──────
  _AlertType _typeFor(Map<String, dynamic> alert) {
    final title = alert["title"]?.toString().toLowerCase() ?? "";
    if (title.contains("urgent") ||
        title.contains("close") ||
        title.contains("emergency")) {
      return _AlertType.urgent;
    }
    if (title.contains("reminder") ||
        title.contains("fee") ||
        title.contains("due") ||
        title.contains("warn")) {
      return _AlertType.warning;
    }
    return _AlertType.info;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopBar(),
              if (loading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: kGold, strokeWidth: 2.5),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                        16, 16, 16, 100),
                    children: [
                      _buildHeroCard(),
                      const SizedBox(height: 14),
                      const _SectionLabel("All Alerts"),
                      if (alerts.isEmpty)
                        _buildEmptyState()
                      else
                        ...alerts.map((raw) {
                          final alert = Map<String, dynamic>
                              .from(raw as Map? ?? {});
                          return Padding(
                            padding: const EdgeInsets.only(
                                bottom: 10),
                            child: _AlertTile(
                              title:   alert["title"]
                                  ?.toString() ?? "",
                              message: alert["message"]
                                  ?.toString() ?? "",
                              expiry:  alert["expires_at"]
                                  ?.toString() ?? "",
                              type:    _typeFor(alert),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
            ],
          ),

          // Premium FAB
          Positioned(
            bottom: 28,
            right: 20,
            child: GestureDetector(
              onTap: _openAddSheet,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: kGold,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: kGold.withOpacity(.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: kGoldDeep,
                  size: 26,
                ),
              ),
            ),
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
              "Gym Alerts",
              style: TextStyle(
                color: kText1,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          // Alert count badge
          GestureDetector(
            onTap: _openAddSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: kGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.add_rounded,
                      color: kGoldDeep, size: 14),
                  SizedBox(width: 4),
                  Text(
                    "New",
                    style: TextStyle(
                      color: kGoldDeep,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
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

  // ── HERO CARD ─────────────────────────────────────────
  Widget _buildHeroCard() {
    // Count alerts expiring today
    final today    = DateTime.now();
    final expiring = alerts.where((a) {
      try {
        final exp = DateTime.parse(
            (a["expires_at"] ?? "").toString());
        return exp.year  == today.year &&
            exp.month == today.month &&
            exp.day   == today.day;
      } catch (_) {
        return false;
      }
    }).length;

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
                  "ACTIVE ALERTS",
                  style: TextStyle(
                    color: kGoldDeep,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${alerts.length} Alert${alerts.length == 1 ? '' : 's'}",
                  style: const TextStyle(
                    color: kText1,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expiring > 0
                      ? "$expiring expiring today"
                      : "All alerts are active",
                  style: const TextStyle(
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
            child: const Icon(
              Icons.notifications_outlined,
              color: kText1,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 50),
    child: Center(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: kGoldLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              color: kGoldDark,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          const Text("No alerts yet",
              style: TextStyle(color: kText2, fontSize: 13)),
          const SizedBox(height: 6),
          const Text("Tap + to create a gym alert",
              style: TextStyle(color: kText2, fontSize: 11)),
        ],
      ),
    ),
  );
}

// ── ALERT TYPE ────────────────────────────────────────────────
enum _AlertType { urgent, warning, info }

// ── SECTION LABEL ────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: kText2,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    ),
  );
}

// ── ALERT TILE ────────────────────────────────────────────────
class _AlertTile extends StatelessWidget {
  final String     title, message, expiry;
  final _AlertType type;

  const _AlertTile({
    required this.title,
    required this.message,
    required this.expiry,
    required this.type,
  });

  Color get _stripeColor {
    switch (type) {
      case _AlertType.urgent:  return kRed;
      case _AlertType.warning: return kOrange;
      case _AlertType.info:    return kGold;
    }
  }

  Color get _borderColor {
    switch (type) {
      case _AlertType.urgent:  return kRedBorder;
      case _AlertType.warning: return kOrangeBorder;
      case _AlertType.info:    return kGoldBorder;
    }
  }

  Color get _iconBg {
    switch (type) {
      case _AlertType.urgent:  return kRedBg;
      case _AlertType.warning: return kOrangeBg;
      case _AlertType.info:    return kGoldLight;
    }
  }

  Color get _iconColor {
    switch (type) {
      case _AlertType.urgent:  return kRed;
      case _AlertType.warning: return kOrangeText;
      case _AlertType.info:    return kGoldDark;
    }
  }

  Color get _expiryColor {
    switch (type) {
      case _AlertType.urgent:  return kRed;
      case _AlertType.warning: return kOrangeText;
      case _AlertType.info:    return kGoldDark;
    }
  }

  String get _badgeLabel {
    switch (type) {
      case _AlertType.urgent:  return "URGENT";
      case _AlertType.warning: return "REMINDER";
      case _AlertType.info:    return "INFO";
    }
  }

  IconData get _icon {
    switch (type) {
      case _AlertType.urgent:  return Icons.notifications_active_outlined;
      case _AlertType.warning: return Icons.warning_amber_outlined;
      case _AlertType.info:    return Icons.info_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:        kSurface,
        borderRadius: BorderRadius.circular(20),
        border:       Border(
          left:   BorderSide(color: _stripeColor, width: 4),
          top:    BorderSide(color: _borderColor),
          right:  BorderSide(color: _borderColor),
          bottom: BorderSide(color: _borderColor),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _iconBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(_icon, color: _iconColor, size: 20),
          ),

          const SizedBox(width: 12),

          // Body
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: kText1,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: kText2,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 11,
                          color: _expiryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Expires $expiry",
                          style: TextStyle(
                            color:      _expiryColor,
                            fontSize:   10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: _iconBg,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: _borderColor),
                      ),
                      child: Text(
                        _badgeLabel,
                        style: TextStyle(
                          color:      _iconColor,
                          fontSize:   9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
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