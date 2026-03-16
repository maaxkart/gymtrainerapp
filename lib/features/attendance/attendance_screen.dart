import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

const gold = Color(0xFFD5EB45);
const bg = Color(0xff0B0D12);
const card = Color(0xff12141A);

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with TickerProviderStateMixin {

  List liveUsers = [];
  List history = [];

  bool loading = true;

  int total = 0;
  int checkedIn = 0;
  int pending = 0;

  late TabController tabController;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 3, vsync: this);

    loadData();

    refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
          (timer) => loadData(),
    );
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    tabController.dispose();
    super.dispose();
  }

  Future loadData() async {

    setState(() => loading = true);

    final live = await ApiService.getLiveUsers();
    final hist = await ApiService.getAttendanceHistory();

    liveUsers = live;
    history = hist;

    checkedIn = liveUsers.length;
    total = history.length;
    pending = history.where((e) => e["check_out"] == null).length;

    setState(() => loading = false);
  }

  Future checkout(int id) async {
    await ApiService.checkOutUser(id);
    loadData();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: bg,
        title: const Text(
          "Attendance Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [

          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

            decoration: BoxDecoration(
              color: gold,
              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              "$checkedIn LIVE",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],

        bottom: TabBar(
          controller: tabController,
          indicatorColor: gold,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Overview"),
            Tab(text: "Checked-in"),
            Tab(text: "Pending"),
          ],
        ),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator(color: gold))
          : Column(
        children: [

          /// PREMIUM DASHBOARD
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [

                Expanded(child: statCard("Total", total, Icons.groups)),

                const SizedBox(width: 12),

                Expanded(child: statCard("Live", checkedIn, Icons.bolt)),

                const SizedBox(width: 12),

                Expanded(child: statCard("Pending", pending, Icons.timer)),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                overview(),
                checkedInList(),
                pendingList(),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// PREMIUM CARD
  Widget statCard(String title, int value, IconData icon) {

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff151821),
            Color(0xff1D212C),
          ],
        ),
        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color: gold.withOpacity(.15),
            blurRadius: 20,
            spreadRadius: 1,
          )
        ],
      ),

      child: Column(
        children: [

          Icon(icon, color: gold, size: 26),

          const SizedBox(height: 8),

          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 22,
              color: gold,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }

  /// OVERVIEW TAB
  Widget overview() {

    if (history.isEmpty) {
      return const Center(
        child: Text(
          "No attendance today",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: history.length,
      itemBuilder: (_, i) {

        final user = history[i];

        return memberTile(
          name: user["user"]["name"],
          exercise: user["exercise"]["name"],
          checkin: user["check_in"],
          checkout: user["check_out"],
        );
      },
    );
  }

  /// LIVE USERS
  Widget checkedInList() {

    if (liveUsers.isEmpty) {
      return const Center(
        child: Text(
          "No active members",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: liveUsers.length,
      itemBuilder: (_, i) {

        final user = liveUsers[i];

        return Dismissible(

          key: Key(user["id"].toString()),

          direction: DismissDirection.endToStart,

          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: gold,
            child: const Icon(Icons.logout, color: Colors.black),
          ),

          onDismissed: (_) => checkout(user["id"]),

          child: memberTile(
            name: user["user"]["name"],
            exercise: user["exercise"]["name"],
            checkin: user["check_in"],
            checkout: null,
          ),
        );
      },
    );
  }

  /// PENDING USERS
  Widget pendingList() {

    final pendingUsers =
    history.where((e) => e["check_out"] == null).toList();

    if (pendingUsers.isEmpty) {
      return const Center(
        child: Text(
          "No pending checkout",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: pendingUsers.length,
      itemBuilder: (_, i) {

        final user = pendingUsers[i];

        return memberTile(
          name: user["user"]["name"],
          exercise: user["exercise"]["name"],
          checkin: user["check_in"],
          checkout: null,
        );
      },
    );
  }

  /// PREMIUM MEMBER TILE
  Widget memberTile({
    required String name,
    required String exercise,
    required String checkin,
    String? checkout,
  }) {

    final active = checkout == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active ? gold.withOpacity(.4) : Colors.white12,
        ),
      ),

      child: ListTile(

        leading: CircleAvatar(
          radius: 22,
          backgroundColor: gold,
          child: Text(
            name[0],
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        title: Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(
          exercise,
          style: const TextStyle(color: Colors.white54),
        ),

        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Text(
              "IN $checkin",
              style: const TextStyle(color: gold),
            ),

            const SizedBox(height: 4),

            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),

              decoration: BoxDecoration(
                color: active
                    ? Colors.orange.withOpacity(.2)
                    : Colors.green.withOpacity(.2),
                borderRadius: BorderRadius.circular(6),
              ),

              child: Text(
                active ? "ACTIVE" : "DONE",
                style: TextStyle(
                  fontSize: 11,
                  color: active ? Colors.orange : Colors.green,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}