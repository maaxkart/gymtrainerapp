import 'package:flutter/material.dart';

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

// ── Static plan model ─────────────────────────────────
class GymPlan {
  final int    id;
  String       planName;
  int          duration;
  String       billingCycle; // "Month", "Months", "Year"
  double       price;
  bool         isPopular;

  GymPlan({
    required this.id,
    required this.planName,
    required this.duration,
    required this.billingCycle,
    required this.price,
    this.isPopular = false,
  });

  String get durationLabel => "$duration $billingCycle";
  String get priceLabel    => "₹${price.toStringAsFixed(0)}";
}

// ── Default built-in plans (editable) ─────────────────
List<GymPlan> _defaultPlans() => [
  GymPlan(id: 1, planName: "Monthly Basic",   duration: 1,  billingCycle: "Month",  price: 799),
  GymPlan(id: 2, planName: "Quarterly Plan",  duration: 3,  billingCycle: "Months", price: 2099, isPopular: true),
  GymPlan(id: 3, planName: "Half Yearly",     duration: 6,  billingCycle: "Months", price: 3799),
  GymPlan(id: 4, planName: "Annual Gold",     duration: 12, billingCycle: "Months", price: 6499, isPopular: true),
];

// ═══════════════════════════════════════════════════════
//  PACKAGES SCREEN
// ═══════════════════════════════════════════════════════
class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  // All plans live in a single list; "My Plans" = plans the gym has activated
  final List<GymPlan> _allPlans    = _defaultPlans();
  final List<GymPlan> _activePlans = [];   // plans the gym has "added"

  // ── Lifecycle ──────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────
  IconData _iconFor(String title) {
    final t = title.toLowerCase();
    if (t.contains("year")    || t.contains("annual"))  return Icons.emoji_events_outlined;
    if (t.contains("quarter"))                           return Icons.timelapse_outlined;
    if (t.contains("half")    || t.contains("6"))       return Icons.date_range_outlined;
    if (t.contains("month"))                             return Icons.calendar_month_outlined;
    if (t.contains("premium") || t.contains("gold"))    return Icons.workspace_premium_outlined;
    return Icons.fitness_center_outlined;
  }

  bool _isActive(GymPlan plan) => _activePlans.any((p) => p.id == plan.id);

  // ── Add / Edit plan via bottom sheet ───────────────
  void _openAddPlanSheet({GymPlan? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddPlanSheet(
        existing:   existing,
        onSave:     (plan) {
          setState(() {
            if (existing == null) {
              // New plan: add to master list
              _allPlans.add(plan);
            } else {
              // Edit: update in place
              final idx = _allPlans.indexWhere((p) => p.id == plan.id);
              if (idx != -1) _allPlans[idx] = plan;
              final aIdx = _activePlans.indexWhere((p) => p.id == plan.id);
              if (aIdx != -1) _activePlans[aIdx] = plan;
            }
          });
        },
      ),
    );
  }

  // ── Activate / deactivate a plan ───────────────────
  void _activatePlan(GymPlan plan) {
    setState(() => _activePlans.add(plan));
    ScaffoldMessenger.of(context).showSnackBar(_snack("${plan.planName} added to My Plans"));
  }

  void _deactivatePlan(GymPlan plan) {
    setState(() => _activePlans.removeWhere((p) => p.id == plan.id));
    ScaffoldMessenger.of(context).showSnackBar(_snack("${plan.planName} removed"));
  }

  void _deletePlan(GymPlan plan) {
    setState(() {
      _allPlans.removeWhere((p) => p.id == plan.id);
      _activePlans.removeWhere((p) => p.id == plan.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(_snack("${plan.planName} deleted"));
  }

  SnackBar _snack(String msg) => SnackBar(
    content: Text(msg,
        style: const TextStyle(color: kGoldDeep, fontWeight: FontWeight.w600)),
    backgroundColor: kGold,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    margin: const EdgeInsets.all(16),
  );

  // ── Build ──────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      floatingActionButton: _buildFAB(),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildMyPlansTab(), _buildAllPlansTab()],
            ),
          ),
        ],
      ),
    );
  }

  // ── FAB ────────────────────────────────────────────
  Widget _buildFAB() => FloatingActionButton.extended(
    onPressed: () => _openAddPlanSheet(),
    backgroundColor: kGold,
    foregroundColor: kGoldDeep,
    icon: const Icon(Icons.add_rounded),
    label: const Text("New Plan",
        style: TextStyle(fontWeight: FontWeight.w800)),
  );

  // ── TOP BAR ────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: kSurface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 15, color: kText1),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text("Gym Packages",
                    style: TextStyle(
                        color: kText1, fontSize: 16,
                        fontWeight: FontWeight.w800, letterSpacing: -0.3)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TabBar(
            controller: _tabController,
            indicatorColor: kGold,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: kGoldDark,
            unselectedLabelColor: kText2,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            tabs: [
              Tab(text: "My Plans (${_activePlans.length})"),
              Tab(text: "All Plans (${_allPlans.length})"),
            ],
          ),
        ],
      ),
    );
  }

  // ── MY PLANS TAB ───────────────────────────────────
  Widget _buildMyPlansTab() {
    if (_activePlans.isEmpty) {
      return _emptyState("No active plans yet",
          sub: "Go to 'All Plans' and tap Add to activate");
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _activePlans.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) return _buildHeroCard(_activePlans.length, "My Active");
        final plan = _activePlans[i - 1];
        return _PlanCard(
          plan:       plan,
          icon:       _iconFor(plan.planName),
          buttonText: "Edit",
          buttonColor: kGold,
          onTap:      () => _openAddPlanSheet(existing: plan),
          trailing: IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded,
                color: Colors.redAccent, size: 20),
            tooltip: "Remove from My Plans",
            onPressed: () => _deactivatePlan(plan),
          ),
        );
      },
    );
  }

  // ── ALL PLANS TAB ──────────────────────────────────
  Widget _buildAllPlansTab() {
    if (_allPlans.isEmpty) {
      return _emptyState("No plans created",
          sub: "Tap '+ New Plan' to create your first package");
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: _allPlans.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) return _buildHeroCard(_allPlans.length, "All");
        final plan    = _allPlans[i - 1];
        final active  = _isActive(plan);
        return _PlanCard(
          plan:        plan,
          icon:        _iconFor(plan.planName),
          buttonText:  active ? "Added ✓" : "Add Plan",
          buttonColor: active ? kSurface2 : kGold,
          onTap:       active ? null : () => _activatePlan(plan),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: kText2, size: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (v) {
              if (v == "edit")   _openAddPlanSheet(existing: plan);
              if (v == "delete") _deletePlan(plan);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: "edit",
                  child: Text("Edit Plan")),
              const PopupMenuItem(value: "delete",
                  child: Text("Delete", style: TextStyle(color: Colors.redAccent))),
            ],
          ),
        );
      },
    );
  }

  // ── HERO CARD ──────────────────────────────────────
  Widget _buildHeroCard(int count, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
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
                  Text("${label.toUpperCase()} PLANS",
                      style: const TextStyle(
                          color: kGoldDeep, fontSize: 10,
                          fontWeight: FontWeight.w700, letterSpacing: 1)),
                  const SizedBox(height: 6),
                  Text("$count Package${count == 1 ? '' : 's'}",
                      style: const TextStyle(
                          color: kText1, fontSize: 24,
                          fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  const Text("Tap a plan to manage",
                      style: TextStyle(
                          color: kGoldDeep, fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.workspace_premium_outlined,
                  color: kText1, size: 26),
            ),
          ],
        ),
      ),
    );
  }

  // ── EMPTY STATE ────────────────────────────────────
  Widget _emptyState(String msg, {String sub = ""}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
                color: kGoldLight, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.inbox_outlined, color: kGoldDark, size: 30),
          ),
          const SizedBox(height: 14),
          Text(msg,
              style: const TextStyle(color: kText1, fontSize: 14,
                  fontWeight: FontWeight.w700)),
          if (sub.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(sub,
                style: const TextStyle(color: kText2, fontSize: 12),
                textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
//  PLAN CARD
// ═══════════════════════════════════════════════════════
class _PlanCard extends StatelessWidget {
  final GymPlan     plan;
  final IconData    icon;
  final String      buttonText;
  final Color       buttonColor;
  final VoidCallback? onTap;
  final Widget?     trailing;

  const _PlanCard({
    required this.plan,
    required this.icon,
    required this.buttonText,
    required this.buttonColor,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: plan.isPopular ? kGoldBorder : kBorder,
          width: plan.isPopular ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(height: 3, color: plan.isPopular ? kGold : kText1),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: plan.isPopular ? kGoldLight : kSurface2,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon,
                          color: plan.isPopular ? kGoldDark : kText2, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(plan.planName,
                          style: const TextStyle(
                              color: kText1, fontSize: 15,
                              fontWeight: FontWeight.w800, letterSpacing: -0.2)),
                    ),
                    if (plan.isPopular)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kGoldLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kGoldBorder),
                        ),
                        child: const Text("POPULAR",
                            style: TextStyle(
                                color: kGoldDark, fontSize: 9,
                                fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                      ),
                    if (trailing != null) trailing!,
                  ],
                ),

                const SizedBox(height: 14),

                // Duration chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: kGoldLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kGoldBorder),
                  ),
                  child: Text(plan.durationLabel,
                      style: const TextStyle(
                          color: kGoldDark, fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),

                const SizedBox(height: 14),

                // Price
                Text(plan.priceLabel,
                    style: const TextStyle(
                        color: kText1, fontSize: 28,
                        fontWeight: FontWeight.w900, letterSpacing: -1)),
                const SizedBox(height: 3),
                const Text("per billing cycle",
                    style: TextStyle(color: kText2, fontSize: 11)),

                const SizedBox(height: 16),

                // Action button
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: buttonColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: buttonColor == kGold ? kGold : kGoldBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(buttonText,
                          style: TextStyle(
                            color: buttonColor == kGold ? kGoldDeep : kText2,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          )),
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
}

// ═══════════════════════════════════════════════════════
//  ADD / EDIT PLAN BOTTOM SHEET
// ═══════════════════════════════════════════════════════
class _AddPlanSheet extends StatefulWidget {
  final GymPlan?               existing;
  final void Function(GymPlan) onSave;

  const _AddPlanSheet({this.existing, required this.onSave});

  @override
  State<_AddPlanSheet> createState() => _AddPlanSheetState();
}

class _AddPlanSheetState extends State<_AddPlanSheet> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _priceCtrl    = TextEditingController();
  final _durationCtrl = TextEditingController();

  String _billingCycle = "Month";
  bool   _isPopular    = false;

  static const _cycles = ["Day", "Week", "Month", "Months", "Year"];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final p = widget.existing!;
      _nameCtrl.text     = p.planName;
      _priceCtrl.text    = p.price.toStringAsFixed(0);
      _durationCtrl.text = p.duration.toString();
      _billingCycle      = p.billingCycle;
      _isPopular         = p.isPopular;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final plan = GymPlan(
      id:           widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch,
      planName:     _nameCtrl.text.trim(),
      duration:     int.parse(_durationCtrl.text.trim()),
      billingCycle: _billingCycle,
      price:        double.parse(_priceCtrl.text.trim()),
      isPopular:    _isPopular,
    );
    widget.onSave(plan);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit   = widget.existing != null;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                    color: kBorder,
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),

            Text(isEdit ? "Edit Plan" : "Add New Plan",
                style: const TextStyle(
                    color: kText1, fontSize: 18,
                    fontWeight: FontWeight.w900, letterSpacing: -0.3)),
            const SizedBox(height: 4),
            Text(isEdit
                ? "Update the details for this package"
                : "Create a custom gym package",
                style: const TextStyle(color: kText2, fontSize: 12)),

            const SizedBox(height: 24),

            // Plan name
            _label("Plan Name"),
            _input(
              controller: _nameCtrl,
              hint:       "e.g. Monthly Basic",
              validator:  (v) => (v?.trim().isEmpty ?? true) ? "Enter a name" : null,
            ),

            const SizedBox(height: 16),

            // Duration row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Duration"),
                      _input(
                        controller: _durationCtrl,
                        hint:       "e.g. 3",
                        keyboard:   TextInputType.number,
                        validator:  (v) {
                          if (v?.trim().isEmpty ?? true) return "Required";
                          if (int.tryParse(v!.trim()) == null) return "Number only";
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("Billing Cycle"),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: kSurface2,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: kBorder),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value:   _billingCycle,
                            items:   _cycles.map((c) =>
                                DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (v) =>
                                setState(() => _billingCycle = v ?? _billingCycle),
                            style: const TextStyle(
                                color: kText1, fontSize: 14,
                                fontWeight: FontWeight.w600),
                            dropdownColor: kSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Price
            _label("Price (₹)"),
            _input(
              controller: _priceCtrl,
              hint:       "e.g. 1499",
              keyboard:   TextInputType.number,
              prefix:     const Padding(
                padding: EdgeInsets.only(left: 14, right: 8),
                child: Text("₹",
                    style: TextStyle(
                        color: kGoldDark, fontSize: 16,
                        fontWeight: FontWeight.w800)),
              ),
              validator: (v) {
                if (v?.trim().isEmpty ?? true) return "Enter a price";
                if (double.tryParse(v!.trim()) == null) return "Invalid number";
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Popular toggle
            GestureDetector(
              onTap: () => setState(() => _isPopular = !_isPopular),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: _isPopular ? kGoldLight : kSurface2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: _isPopular ? kGoldBorder : kBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isPopular
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: _isPopular ? kGoldDark : kText2, size: 20,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Mark as Popular",
                              style: TextStyle(
                                  color: kText1, fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                          Text("Shows a 'POPULAR' badge on the card",
                              style: TextStyle(color: kText2, fontSize: 11)),
                        ],
                      ),
                    ),
                    Switch(
                      value:             _isPopular,
                      onChanged:         (v) => setState(() => _isPopular = v),
                      activeColor:       kGoldDark,
                      activeTrackColor:  kGold,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save button
            GestureDetector(
              onTap: _save,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: kGold,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(isEdit ? "Save Changes" : "Add Plan",
                      style: const TextStyle(
                          color: kGoldDeep, fontSize: 15,
                          fontWeight: FontWeight.w900, letterSpacing: 0.2)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Small helpers ───────────────────────────────────
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
        style: const TextStyle(color: kText1, fontSize: 12,
            fontWeight: FontWeight.w700)),
  );

  Widget _input({
    required TextEditingController controller,
    required String                 hint,
    TextInputType   keyboard   = TextInputType.text,
    Widget?         prefix,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller:  controller,
        keyboardType: keyboard,
        validator:   validator,
        style: const TextStyle(
            color: kText1, fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText:       hint,
          hintStyle:      const TextStyle(color: kText2, fontSize: 13),
          prefixIcon:     prefix,
          filled:         true,
          fillColor:      kSurface2,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:   const BorderSide(color: kBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:   const BorderSide(color: kBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:   const BorderSide(color: kGold, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:   const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:   const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
        ),
      );
}