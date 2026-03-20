import 'package:flutter/material.dart';
import '../../services/api_service.dart';

// ── Brand tokens ──────────────────────────────────────
const kGold       = Color(0xFFC8DC32);
const kGoldDark   = Color(0xFF8FA000);
const kGoldDeep   = Color(0xFF3A4500);
const kGoldLight  = Color(0xFFF5F8D6);
const kGoldBorder = Color(0xFFE2EC8A);
const kSurface    = Color(0xFFFFFFFF);
const kSurface2   = Color(0xFFF7F7F5);
const kBorder     = Color(0xFFEFEFEF);
const kText1      = Color(0xFF111111);
const kText2      = Color(0xFFAAAAAA);
const kRed        = Color(0xFFE53935);
const kRedBg      = Color(0xFFFFF3F3);
const kRedBorder  = Color(0xFFFFE0E0);

class AddAlertSheet extends StatefulWidget {
  const AddAlertSheet({super.key});

  @override
  State<AddAlertSheet> createState() => _AddAlertSheetState();
}

class _AddAlertSheetState extends State<AddAlertSheet> {
  final _titleController   = TextEditingController();
  final _messageController = TextEditingController();

  DateTime? _expiry;
  bool      _saving = false;

  // Selected alert type
  _AlertType _type = _AlertType.info;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(()   => setState(() {}));
    _messageController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context:     context,
      firstDate:   DateTime.now(),
      lastDate:    DateTime(2100),
      initialDate: _expiry ?? DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary:   kGold,
            onPrimary: kGoldDeep,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null && mounted) {
      setState(() => _expiry = date);
    }
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      _showSnack("Please enter a title", isError: true);
      return;
    }
    if (_messageController.text.trim().isEmpty) {
      _showSnack("Please enter a message", isError: true);
      return;
    }
    if (_expiry == null) {
      _showSnack("Please select an expiry date", isError: true);
      return;
    }

    setState(() => _saving = true);

    try {
      final res = await ApiService.addAlert(
        title:     _titleController.text.trim(),
        message:   _messageController.text.trim(),
        expiresAt: _expiry!.toIso8601String(),
      );

      final status  = res["status"]?.toString()  ?? "";
      final message = res["message"]?.toString() ?? "Done";

      if (!mounted) return;

      if (status == "success") {
        Navigator.pop(context);
      } else {
        setState(() => _saving = false);
        _showSnack(message, isError: true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        _showSnack("Something went wrong. Try again.", isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: TextStyle(
                color:      isError ? kRed : kGoldDeep,
                fontWeight: FontWeight.w600)),
        backgroundColor: isError ? kRedBg : kGold,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String get _formattedExpiry {
    if (_expiry == null) return "";
    return "${_expiry!.day} ${_monthName(_expiry!.month)} ${_expiry!.year}";
  }

  String _monthName(int m) {
    const months = [
      "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[m];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: kGoldLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: kGoldDark,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Create Alert",
                        style: TextStyle(
                          color:        kText1,
                          fontSize:     18,
                          fontWeight:   FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Notify your gym members",
                        style: TextStyle(
                            color: kText2, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // ── Alert Type Selector ──────────────────────
            const _FieldLabel("Alert Type"),
            const SizedBox(height: 8),
            Row(
              children: _AlertType.values.map((t) {
                final isSelected = _type == t;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(
                          right: t != _AlertType.values.last ? 8 : 0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? t.color.withOpacity(.12)
                            : kSurface2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? t.color
                              : kBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(t.icon,
                              color: isSelected
                                  ? t.color
                                  : kText2,
                              size: 18),
                          const SizedBox(height: 4),
                          Text(
                            t.label,
                            style: TextStyle(
                              color:      isSelected ? t.color : kText2,
                              fontSize:   10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // ── Title ────────────────────────────────────
            const _FieldLabel("Title"),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color:        kSurface,
                borderRadius: BorderRadius.circular(16),
                border:       Border.all(
                  color: _titleController.text.isNotEmpty
                      ? kGoldBorder : kBorder,
                  width: _titleController.text.isNotEmpty
                      ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: kGoldLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.title_rounded,
                          color: kGoldDark, size: 15),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _titleController,
                      style: const TextStyle(
                        color:      kText1,
                        fontSize:   14,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        hintText: "e.g. Gym Closed on Sunday",
                        hintStyle: TextStyle(
                            color: kText2, fontSize: 14),
                        border:   InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Message ───────────────────────────────────
            const _FieldLabel("Message"),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color:        kSurface,
                borderRadius: BorderRadius.circular(16),
                border:       Border.all(color: kBorder),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                            14, 14, 0, 0),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: kGoldLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.notes_rounded,
                              color: kGoldDark, size: 15),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          maxLines:   4,
                          maxLength:  180,
                          style: const TextStyle(
                            color:    kText1,
                            fontSize: 14,
                            height:   1.5,
                          ),
                          decoration: const InputDecoration(
                            hintText: "Write your alert message…",
                            hintStyle:
                            TextStyle(color: kText2, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.fromLTRB(
                                12, 14, 14, 14),
                            counterText: "",
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Char counter
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "${_messageController.text.length} / 180",
                          style: const TextStyle(
                              color: kText2, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Expiry Date ───────────────────────────────
            const _FieldLabel("Expiry Date"),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _expiry != null ? kGoldLight : kSurface2,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _expiry != null ? kGoldBorder : kBorder,
                    width: _expiry != null ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _expiry != null
                            ? kGold
                            : kSurface,
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                            color: _expiry != null
                                ? kGold
                                : kBorder),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size:  16,
                        color: _expiry != null
                            ? kGoldDeep
                            : kText2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            _expiry != null
                                ? _formattedExpiry
                                : "Select expiry date",
                            style: TextStyle(
                              color: _expiry != null
                                  ? kGoldDeep
                                  : kText2,
                              fontSize:   14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (_expiry != null)
                            const Text(
                              "Tap to change",
                              style: TextStyle(
                                  color: kGoldDark,
                                  fontSize: 10),
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: _expiry != null ? kGoldDark : kText2,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Send Button ──────────────────────────────
            GestureDetector(
              onTap: _saving ? null : _save,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 56,
                decoration: BoxDecoration(
                  color: _saving ? kGold.withOpacity(.7) : kGold,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: _saving
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
                      Icon(Icons.send_rounded,
                          color: kGoldDeep, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Send Alert",
                        style: TextStyle(
                          color:        kGoldDeep,
                          fontSize:     15,
                          fontWeight:   FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
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

// ── ALERT TYPE ENUM ───────────────────────────────────────────
enum _AlertType {
  info,
  warning,
  urgent;

  String get label {
    switch (this) {
      case _AlertType.info:    return "Info";
      case _AlertType.warning: return "Reminder";
      case _AlertType.urgent:  return "Urgent";
    }
  }

  IconData get icon {
    switch (this) {
      case _AlertType.info:    return Icons.info_outline_rounded;
      case _AlertType.warning: return Icons.warning_amber_outlined;
      case _AlertType.urgent:  return Icons.notifications_active_outlined;
    }
  }

  Color get color {
    switch (this) {
      case _AlertType.info:    return const Color(0xFF8FA000);
      case _AlertType.warning: return const Color(0xFFE65100);
      case _AlertType.urgent:  return const Color(0xFFE53935);
    }
  }
}

// ── FIELD LABEL ───────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      color:        kText2,
      fontSize:     10,
      fontWeight:   FontWeight.w700,
      letterSpacing: 1.5,
    ),
  );
}