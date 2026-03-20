import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'add_package_screen.dart';

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

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  List availablePlans = [];
  List myPlans        = [];
  bool loading        = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final plans    = await ApiService.getGymPlans();
      final gymPlans = await ApiService.getMyGymPlans();
      if (mounted) {
        setState(() {
          availablePlans = (plans    as List?) ?? [];
          myPlans        = (gymPlans as List?) ?? [];
          loading        = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  // ── Icon picker based on plan name ───────────────────
  IconData _iconFor(String title) {
    final t = title.toLowerCase();
    if (t.contains("year") || t.contains("annual")) return Icons.emoji_events_outlined;
    if (t.contains("quarter"))                       return Icons.timelapse_outlined;
    if (t.contains("month"))                         return Icons.calendar_month_outlined;
    if (t.contains("premium") || t.contains("gold")) return Icons.workspace_premium_outlined;
    return Icons.fitness_center_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Column(
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
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAvailableTab(),
                  _buildMyPlansTab(),
                ],
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
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
      child: Column(
        children: [
          // Title row
          Row(
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
                  "Gym Packages",
                  style: TextStyle(
                    color: kText1,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // If available plans are loaded, go to Available Plans tab
                  // so trainer picks a base plan and taps "Add Plan".
                  // If already on Available Plans tab, just show a hint.
                  if (availablePlans.isNotEmpty) {
                    _tabController.animateTo(0);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        "Select a base plan below to add",
                        style: TextStyle(
                          color: kGoldDeep,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor: kGold,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      margin: const EdgeInsets.all(16),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 9),

                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Tab bar
          TabBar(
            controller: _tabController,
            indicatorColor: kGold,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: kGoldDark,
            unselectedLabelColor: kText2,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: "Available Plans"),
              Tab(text: "My Plans"),
            ],
          ),
        ],
      ),
    );
  }

  // ── AVAILABLE PLANS TAB ──────────────────────────────
  Widget _buildAvailableTab() {
    if (availablePlans.isEmpty) return _emptyState("No plans available");

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: availablePlans.length + 1, // +1 for hero card
      itemBuilder: (context, i) {
        if (i == 0) return _buildHeroCard(availablePlans.length, "Available");

        final plan  = Map<String, dynamic>.from(
            availablePlans[i - 1] as Map? ?? {});
        final title = plan["plan_name"]?.toString() ?? "Plan";
        final dur   =
        "${plan["duration"]?.toString() ?? ""} ${plan["billing_cycle"]?.toString() ?? ""}".trim();

        return _PlanCard(
          title:      title,
          duration:   dur,
          price:      "Set Price",
          isPriceSet: false,
          buttonText: "Add Plan",
          icon:       _iconFor(title),
          isPopular:  title.toLowerCase().contains("gold") ||
              title.toLowerCase().contains("premium"),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddPackageScreen(
                  planId:   (plan["id"] as num?)?.toInt() ?? 0,
                  planName: title,
                  isEdit:   false,
                ),
              ),
            ).then((_) => _loadData());
          },
        );
      },
    );
  }

  // ── MY PLANS TAB ──────────────────────────────────────
  Widget _buildMyPlansTab() {
    if (myPlans.isEmpty) return _emptyState("No plans added yet");

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: myPlans.length + 1,
      itemBuilder: (context, i) {
        if (i == 0) return _buildHeroCard(myPlans.length, "My Active");

        final plan    = Map<String, dynamic>.from(
            myPlans[i - 1] as Map? ?? {});
        final gymPlan = Map<String, dynamic>.from(
            plan["gym_plan"] as Map? ?? {});
        final title   = gymPlan["plan_name"]?.toString() ?? "Plan";
        final dur     =
        "${gymPlan["duration"]?.toString() ?? ""} ${gymPlan["billing_cycle"]?.toString() ?? ""}".trim();
        final price   = "₹${plan["custom_price"]?.toString() ?? "0"}";

        return _PlanCard(
          title:      title,
          duration:   dur,
          price:      price,
          isPriceSet: true,
          buttonText: "Edit Plan",
          icon:       _iconFor(title),
          isPopular:  false,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddPackageScreen(
                  planId:   (plan["id"] as num?)?.toInt() ?? 0,
                  planName: title,
                  isEdit:   true,
                  price:    plan["custom_price"],
                ),
              ),
            ).then((_) => _loadData());
          },
        );
      },
    );
  }

  // ── HERO CARD ─────────────────────────────────────────
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
                  Text(
                    "${label.toUpperCase()} PLANS",
                    style: const TextStyle(
                      color: kGoldDeep,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "$count Package${count == 1 ? "" : "s"}",
                    style: const TextStyle(
                      color: kText1,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Tap a plan to configure",
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
              child: const Icon(
                Icons.workspace_premium_outlined,
                color: kText1,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── EMPTY STATE ──────────────────────────────────────
  Widget _emptyState(String msg) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: kGoldLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.inbox_outlined,
                color: kGoldDark, size: 30),
          ),
          const SizedBox(height: 14),
          Text(msg,
              style: const TextStyle(color: kText2, fontSize: 13)),
        ],
      ),
    );
  }
}

// ── PLAN CARD ─────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  final String     title, duration, price, buttonText;
  final bool       isPriceSet, isPopular;
  final IconData   icon;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.duration,
    required this.price,
    required this.isPriceSet,
    required this.buttonText,
    required this.icon,
    required this.isPopular,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPopular ? kGoldBorder : kBorder,
          width: isPopular ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Top accent bar
          Container(
            height: 3,
            color: isPopular ? kGold : kText1,
          ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Header row
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isPopular ? kGoldLight : kSurface2,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon,
                        color: isPopular ? kGoldDark : kText2,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: kText1,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (isPopular)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kGoldLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kGoldBorder),
                        ),
                        child: const Text(
                          "POPULAR",
                          style: TextStyle(
                            color: kGoldDark,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 14),

                // Duration chip
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: kGoldLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kGoldBorder),
                  ),
                  child: Text(
                    duration,
                    style: const TextStyle(
                      color: kGoldDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Price
                Text(
                  price,
                  style: const TextStyle(
                    color: kText1,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isPriceSet ? "per billing cycle" : "custom pricing",
                  style: const TextStyle(
                    color: kText2,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 16),

                // Action button
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isPopular ? kGold : kSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isPopular ? kGold : kGoldBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        buttonText,
                        style: TextStyle(
                          color: isPopular ? kGoldDeep : kGoldDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
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