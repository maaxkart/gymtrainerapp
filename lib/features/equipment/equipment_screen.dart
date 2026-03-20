import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'add_edit_equipment_sheet.dart';

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
const kOrange     = Color(0xFFFF9800);
const kOrangeBg   = Color(0xFFFFF3E0);
const kOrangeBorder = Color(0xFFFFCC80);
const kOrangeText = Color(0xFFE65100);

class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  List equipment = [];
  bool loading   = true;

  @override
  void initState() {
    super.initState();
    _loadEquipment();
  }

  Future<void> _loadEquipment() async {
    try {
      final data = await ApiService.getEquipment();
      if (mounted) {
        setState(() {
          equipment = (data as List?) ?? [];
          loading   = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  // ── Open add sheet ────────────────────────────────────
  Future<void> _openAddSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const AddEditEquipmentSheet(),
    );
    _loadEquipment();
  }

  // ── Open edit sheet ───────────────────────────────────
  Future<void> _openEditSheet(dynamic item) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AddEditEquipmentSheet(
        equipmentId: (item["id"] as num?)?.toInt(),
        masterId:    (item["equipment_master_id"] as num?)?.toInt(),
        quantity:    int.tryParse(item["quantity"].toString()) ?? 0,
      ),
    );
    _loadEquipment();
  }

  // ── Delete with confirm dialog ────────────────────────
  Future<void> _deleteEquipment(dynamic item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Remove Equipment",
          style: TextStyle(
            color: kText1,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          "Remove ${(item["master"]?["name"] ?? "this item").toString()} from your gym?",
          style: const TextStyle(color: kText2, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel",
                style: TextStyle(color: kText2)),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(ctx, true),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: kRed,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Remove",
                style: TextStyle(
                  color: kSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );

    if (confirm == true) {
      await ApiService.deleteEquipment(item["id"]);
      _loadEquipment();
    }
  }

  // ── Stats helpers ─────────────────────────────────────
  int get _lowStockCount =>
      equipment.where((e) {
        final qty = int.tryParse(e["quantity"].toString()) ?? 0;
        return qty <= 3;
      }).length;

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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    children: [
                      _buildHeroCard(),
                      const SizedBox(height: 14),
                      _buildSectionLabel(),
                      ...equipment.map((item) =>
                          _EquipmentCard(
                            item:     item,
                            onEdit:   () => _openEditSheet(item),
                            onDelete: () => _deleteEquipment(item),
                          )),
                      if (equipment.isEmpty) _buildEmptyState(),
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
              "Gym Equipment",
              style: TextStyle(
                color: kText1,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          // Item count badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: kGoldLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kGoldBorder),
            ),
            child: Text(
              "${equipment.length} Items",
              style: const TextStyle(
                color: kGoldDark,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HERO CARD ─────────────────────────────────────────
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
                  "TOTAL EQUIPMENT",
                  style: TextStyle(
                    color: kGoldDeep,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${equipment.length} Items",
                  style: const TextStyle(
                    color: kText1,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _lowStockCount > 0
                      ? "$_lowStockCount item${_lowStockCount > 1 ? 's' : ''} need restocking"
                      : "All items well stocked",
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
              Icons.fitness_center_outlined,
              color: kText1,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel() => const Padding(
    padding: EdgeInsets.only(bottom: 10),
    child: Text(
      "ALL EQUIPMENT",
      style: TextStyle(
        color: kText2,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    ),
  );

  Widget _buildEmptyState() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
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
            child: const Icon(Icons.fitness_center_outlined,
                color: kGoldDark, size: 30),
          ),
          const SizedBox(height: 14),
          const Text(
            "No equipment added yet",
            style: TextStyle(color: kText2, fontSize: 13),
          ),
          const SizedBox(height: 6),
          const Text(
            "Tap + to add your first item",
            style: TextStyle(color: kText2, fontSize: 11),
          ),
        ],
      ),
    ),
  );
}

// ── EQUIPMENT CARD ────────────────────────────────────────────
class _EquipmentCard extends StatelessWidget {
  final dynamic      item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EquipmentCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String name = (item["master"]?["name"] ?? "Equipment").toString();
    final int    qty  = int.tryParse(item["quantity"].toString()) ?? 0;
    final bool   isLow = qty <= 3;

    final String initials = name.trim().isNotEmpty
        ? name.trim().split(" ").map((w) => w[0]).take(2).join().toUpperCase()
        : "EQ";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLow ? kOrangeBorder : kBorder,
          width: isLow ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [

          // Icon / avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isLow ? kOrangeBg : kGoldLight,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                color: isLow ? kOrangeText : kGoldDark,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                      color: kText1,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 3),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                        color: kText2, fontSize: 11),
                    children: [
                      const TextSpan(text: "Quantity: "),
                      TextSpan(
                        text: qty.toString(),
                        style: TextStyle(
                          color: isLow ? kOrangeText : kGoldDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: isLow ? kOrangeBg : kGoldLight,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: isLow ? kOrangeBorder : kGoldBorder,
                    ),
                  ),
                  child: Text(
                    isLow ? "Low Stock" : "Good Stock",
                    style: TextStyle(
                      color: isLow ? kOrangeText : kGoldDark,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Action buttons
          Column(
            children: [
              // Edit
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: kGoldLight,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: kGoldDark,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Delete
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: kRedBg,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: kRed,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}