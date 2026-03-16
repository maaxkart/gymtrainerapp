import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'add_package_screen.dart';

const gold = Color(0xFFD5EB45);
const bg = Color(0xff0B0D12);

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  List availablePlans = [];
  List myPlans = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadData();
  }

  Future<void> loadData() async {
    try {
      final plans = await ApiService.getGymPlans();
      final gymPlans = await ApiService.getMyGymPlans();

      setState(() {
        availablePlans = plans;
        myPlans = gymPlans;
        loading = false;
      });

    } catch (e) {
      loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text("Gym Packages"),

        bottom: TabBar(
          controller: _tabController,
          indicatorColor: gold,
          labelColor: gold,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: "Available Plans"),
            Tab(text: "My Plans"),
          ],
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator(color: gold))
          : TabBarView(
        controller: _tabController,
        children: [

          /// AVAILABLE PLANS
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: availablePlans.length,
            itemBuilder: (context, index) {

              final plan = availablePlans[index];

              return _planCard(
                title: plan["plan_name"],
                duration:
                "${plan["duration"]} ${plan["billing_cycle"]}",
                price: "Set Price",
                buttonText: "Add Plan",
                onTap: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddPackageScreen(
                        planId: plan["id"],
                        planName: plan["plan_name"],
                        isEdit: false,
                      ),
                    ),
                  ).then((_) => loadData());
                },
              );
            },
          ),

          /// MY PLANS
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myPlans.length,
            itemBuilder: (context, index) {

              final plan = myPlans[index];

              return _planCard(
                title: plan["gym_plan"]["plan_name"],
                duration:
                "${plan["gym_plan"]["duration"]} ${plan["gym_plan"]["billing_cycle"]}",
                price: "₹ ${plan["custom_price"]}",
                buttonText: "Edit Plan",
                onTap: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddPackageScreen(
                        planId: plan["id"],
                        planName: plan["gym_plan"]["plan_name"],
                        isEdit: true,
                        price: plan["custom_price"],
                      ),
                    ),
                  ).then((_) => loadData());
                },
              );
            },
          ),
        ],
      ),
    );
  }

  /// PREMIUM PLAN CARD

  Widget _planCard({
    required String title,
    required String duration,
    required String price,
    required String buttonText,
    required VoidCallback onTap,
  }) {

    IconData icon = Icons.workspace_premium;

    if (title.toLowerCase().contains("month")) {
      icon = Icons.calendar_month;
    } else if (title.toLowerCase().contains("quarter")) {
      icon = Icons.timelapse;
    } else if (title.toLowerCase().contains("year")) {
      icon = Icons.emoji_events;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: const Color(0xff161A23),
        borderRadius: BorderRadius.circular(16),

        border: Border.all(
          color: Colors.white.withOpacity(.05),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.4),
            blurRadius: 20,
          )
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// HEADER
          Row(
            children: [

              Container(
                height: 40,
                width: 40,

                decoration: BoxDecoration(
                  color: gold.withOpacity(.15),
                  borderRadius: BorderRadius.circular(10),
                ),

                child: Icon(icon, color: gold, size: 20),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),

          const SizedBox(height: 14),

          /// DURATION CHIP
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

            decoration: BoxDecoration(
              color: gold.withOpacity(.12),
              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              duration,
              style: const TextStyle(
                color: gold,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 14),

          /// PRICE
          Text(
            price,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: gold,
            ),
          ),

          const SizedBox(height: 16),

          /// BUTTON
          SizedBox(
            width: double.infinity,

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.black,
                padding:
                const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onPressed: onTap,

              child: Text(
                buttonText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}