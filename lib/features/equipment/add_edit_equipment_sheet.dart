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

class AddEditEquipmentSheet extends StatefulWidget {
  final int? equipmentId;
  final int? masterId;
  final int? quantity;

  const AddEditEquipmentSheet({
    super.key,
    this.equipmentId,
    this.masterId,
    this.quantity,
  });

  @override
  State<AddEditEquipmentSheet> createState() =>
      _AddEditEquipmentSheetState();
}

class _AddEditEquipmentSheetState extends State<AddEditEquipmentSheet> {
  List equipmentMaster = [];
  int? selectedId;
  int  qty     = 1;
  bool loading = true;
  bool saving  = false;

  @override
  void initState() {
    super.initState();
    _loadMaster();
  }

  Future<void> _loadMaster() async {
    try {
      final data = await ApiService.getEquipmentMaster();
      if (mounted) {
        setState(() {
          equipmentMaster = (data as List?) ?? [];
          loading         = false;
          if (widget.masterId != null)  selectedId = widget.masterId;
          if (widget.quantity != null)  qty        = widget.quantity!;
        });
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _save() async {
    if (selectedId == null) {
      _showSnack("Please select an equipment type", isError: true);
      return;
    }
    if (qty <= 0) {
      _showSnack("Quantity must be at least 1", isError: true);
      return;
    }

    setState(() => saving = true);

    try {
      if (widget.equipmentId == null) {
        await ApiService.addEquipment(
          equipmentId: selectedId!,
          quantity:    qty,
        );
      } else {
        await ApiService.updateEquipment(
          id:          widget.equipmentId!,
          equipmentId: selectedId!,
          quantity:    qty,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => saving = false);
        _showSnack("Something went wrong", isError: true);
      }
    }
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

  // ── Safe master lookup ─────────────────────────────
  String get _selectedName {
    if (selectedId == null) return "";
    try {
      final match = equipmentMaster.firstWhere(
            (e) => (e["id"] as num?)?.toInt() == selectedId,
        orElse: () => null,
      );
      return match?["name"]?.toString() ?? "";
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.equipmentId != null;

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: loading
            ? const SizedBox(
          height: 180,
          child: Center(
            child: CircularProgressIndicator(
                color: kGold, strokeWidth: 2.5),
          ),
        )
            : Column(
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

            // Title
            Text(
              isEdit ? "Update Equipment" : "Add Equipment",
              style: const TextStyle(
                color: kText1,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isEdit
                  ? "Edit the equipment details below"
                  : "Select an item and set the quantity",
              style: const TextStyle(
                  color: kText2, fontSize: 12),
            ),

            const SizedBox(height: 22),

            // ── Equipment Dropdown ──────────────
            const _FieldLabel("Equipment Type"),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: kSurface2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selectedId != null ? kGoldBorder : kBorder,
                  width: selectedId != null ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: kGoldLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.fitness_center_outlined,
                      color: kGoldDark,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: selectedId,
                        hint: const Text(
                          "Select equipment",
                          style: TextStyle(
                              color: kText2, fontSize: 14),
                        ),
                        isExpanded: true,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: kText2,
                        ),
                        dropdownColor: kSurface,
                        borderRadius: BorderRadius.circular(16),
                        items: equipmentMaster
                            .map<DropdownMenuItem<int>>((raw) {
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
                        onChanged: (v) =>
                            setState(() => selectedId = v),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ── Quantity ────────────────────────
            const _FieldLabel("Quantity"),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: kSurface2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kGoldBorder, width: 2),
              ),
              child: Row(
                children: [
                  // Hash icon
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: kGoldLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      "#",
                      style: TextStyle(
                        color: kGoldDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Count display
                  Expanded(
                    child: Text(
                      qty.toString(),
                      style: const TextStyle(
                        color: kText1,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  // +/- buttons
                  Row(
                    children: [
                      _QtyButton(
                        icon: Icons.remove_rounded,
                        onTap: () {
                          if (qty > 1) setState(() => qty--);
                        },
                      ),
                      const SizedBox(width: 8),
                      _QtyButton(
                        icon: Icons.add_rounded,
                        onTap: () => setState(() => qty++),
                        isPrimary: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // ── Save Button ─────────────────────
            GestureDetector(
              onTap: saving ? null : _save,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 56,
                decoration: BoxDecoration(
                  color: saving ? kGold.withOpacity(.7) : kGold,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: saving
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
                        isEdit
                            ? Icons.edit_rounded
                            : Icons.add_circle_outline_rounded,
                        color: kGoldDeep,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEdit
                            ? "Update Equipment"
                            : "Save Equipment",
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
          ],
        ),
      ),
    );
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
      color: kText2,
      fontSize: 10,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.5,
    ),
  );
}

// ── QTY BUTTON ────────────────────────────────────────────────
class _QtyButton extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  final bool         isPrimary;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isPrimary ? kGold : kGoldLight,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(
        icon,
        color: kGoldDeep,
        size: 18,
      ),
    ),
  );
}