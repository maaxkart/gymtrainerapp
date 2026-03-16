import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../members/members_screen.dart';
import '../equipment/equipment_screen.dart';
import '../payments/payments_screen.dart';
import '../packages/packages_screen.dart';
import '../videos/videos_screen.dart';
import '../notifications/alert_screen.dart';

const gold = Color(0xFFD5EB45);
const bg = Color(0xff0B0D12);
const card = Color(0xff12141A);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String name = "Trainer";
  String gym = "My Gym";

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {

    final prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString("name") ?? "Trainer";
      gym = prefs.getString("gym") ?? "Gym";
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bg,

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          /// PREMIUM HEADER
          SliverAppBar(
            backgroundColor: bg,
            expandedHeight: 150,
            pinned: true,

            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black,
                      gold.withOpacity(0.08),
                      Colors.black
                    ],
                  ),
                ),

                child: Row(
                  children: [

                    /// PROFILE
                    Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: gold, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: gold.withOpacity(.4),
                            blurRadius: 20,
                          )
                        ],
                      ),
                      child: const Icon(Icons.person,color: Colors.white),
                    ),

                    const SizedBox(width: 14),

                    /// USER
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        const Text(
                          "Welcome Back 👋",
                          style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12
                          ),
                        ),

                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: gold,
                          ),
                        ),

                        Text(
                          gym,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white54
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    /// NOTIFICATION
                    GestureDetector(
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AlertsScreen()),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.notifications,color: gold),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          /// KPI SECTION
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [

                  Expanded(child: PremiumKpiCard(
                      "Members","120",Icons.people)),

                  SizedBox(width: 12),

                  Expanded(child: PremiumKpiCard(
                      "Revenue","₹35K",Icons.currency_rupee)),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: const [

                  Expanded(child: PremiumKpiCard(
                      "Attendance","98%",Icons.bar_chart)),

                  SizedBox(width: 12),

                  Expanded(child: PremiumKpiCard(
                      "Dues","₹8K",Icons.warning)),
                ],
              ),
            ),
          ),

          /// QUICK LINKS
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color: gold.withOpacity(.15),
                      blurRadius: 20,
                    )
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Quick Access",
                      style: TextStyle(
                        color: gold,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),

                      children: const [

                        QuickLink(icon: Icons.fitness_center,title: "Equipment",page: EquipmentScreen()),
                        QuickLink(icon: Icons.workspace_premium,title: "Plans",page: PackagesScreen()),
                        QuickLink(icon: Icons.payments,title: "Payments",page: PaymentsScreen()),
                        QuickLink(icon: Icons.video_library,title: "Videos",page: VideosScreen()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// SCHEDULE
          SliverToBoxAdapter(
            child: _section(
              "Today’s Schedule",
              Column(
                children: const [

                  PremiumScheduleTile("Weight Training","06:00 AM"),
                  PremiumScheduleTile("Crossfit","07:00 AM"),
                ],
              ),
            ),
          ),

          /// ALERT
          SliverToBoxAdapter(
            child: _section(
              "Renewal Alerts",
              const Column(
                children: [

                  RenewalTile(name: "Rahul",daysLeft: "2 days left"),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120))
        ],
      ),
    );
  }

  static Widget _section(String title, Widget child){

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Text(
            title,
            style: const TextStyle(
              color: gold,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 16),

          child
        ],
      ),
    );
  }
}

class PremiumKpiCard extends StatelessWidget {

  final String title;
  final String value;
  final IconData icon;

  const PremiumKpiCard(this.title,this.value,this.icon,{super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gold.withOpacity(.15),
            card
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),

      child: Column(
        children: [

          Icon(icon,color: gold),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
                color: gold,
                fontWeight: FontWeight.bold,
                fontSize: 20
            ),
          ),

          Text(
            title,
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 12
            ),
          )
        ],
      ),
    );
  }
}

class QuickLink extends StatelessWidget {

  final IconData icon;
  final String title;
  final Widget page;

  const QuickLink({
    required this.icon,
    required this.title,
    required this.page,
    super.key
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },

      child: Column(
        children: [

          Container(
            height: 52,
            width: 52,

            decoration: BoxDecoration(
              color: gold.withOpacity(.12),
              borderRadius: BorderRadius.circular(16),
            ),

            child: Icon(icon,color: gold),
          ),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(
                fontSize: 11,
                color: Colors.white70
            ),
          )
        ],
      ),
    );
  }
}
class PremiumScheduleTile extends StatelessWidget {

  final String title;
  final String time;

  const PremiumScheduleTile(this.title, this.time, {super.key});

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gold.withOpacity(.2)),
      ),

      child: Row(
        children: [

          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: gold.withOpacity(.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.fitness_center,color: gold),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                Text(
                  time,
                  style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12),
                ),
              ],
            ),
          ),

          const Icon(Icons.arrow_forward_ios,size: 14,color: gold)

        ],
      ),
    );
  }
}
class RenewalTile extends StatelessWidget {

  final String name;
  final String daysLeft;

  const RenewalTile({
    required this.name,
    required this.daysLeft,
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withOpacity(.3)),
      ),

      child: Row(
        children: [

          const CircleAvatar(
            backgroundColor: Colors.redAccent,
            child: Icon(Icons.warning,color: Colors.white),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),

            decoration: BoxDecoration(
              color: Colors.red.withOpacity(.15),
              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              daysLeft,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}