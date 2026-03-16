import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../shared/widgets/premium_card.dart';

const gold = Color(0xFFD5EB45);
const bg = Color(0xff0F1115);
const card = Color(0xff1A1D24);

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {

  List members = [];
  List filteredMembers = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadMembers();
  }

  Future loadMembers() async {

    try {

      final data = await ApiService.getMembers();

      setState(() {
        members = data;
        filteredMembers = data;
        loading = false;
      });

    } catch (e) {

      setState(() {
        loading = false;
      });
    }
  }

  /// SEARCH MEMBERS
  void searchMembers(String value) {

    final result = members.where((m) {
      final name = (m["name"] ?? "").toLowerCase();
      return name.contains(value.toLowerCase());
    }).toList();

    setState(() {
      filteredMembers = result;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bg,

      /// APPBAR
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),

            child: AppBar(
              title: const Text("Members"),
              backgroundColor: Colors.black.withOpacity(0.3),
              elevation: 0,
            ),
          ),
        ),
      ),

      body: Column(
        children: [

          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16),

            child: TextField(
              onChanged: searchMembers,

              decoration: InputDecoration(
                hintText: "Search members...",
                prefixIcon: const Icon(Icons.search, color: gold),

                filled: true,
                fillColor: card,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// MEMBER LIST
          Expanded(

            child: loading
                ? const Center(
                child: CircularProgressIndicator(color: gold))

                : ListView.builder(

              padding: const EdgeInsets.only(bottom: 20),

              itemCount: filteredMembers.length,

              itemBuilder: (_, i) {

                final member = filteredMembers[i];

                return UltraMemberCard(
                  name: member["name"] ?? "",
                  joinDate: member["join_date"] ?? "",
                  expiry: member["expiry_date"] ?? "",
                  attendance: member["attendance"] ?? 0,
                  plan: member["plan"] ?? "Basic",
                  paid: member["paid"] ?? false,
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class UltraMemberCard extends StatelessWidget {

  final String name;
  final String joinDate;
  final String expiry;
  final double attendance;
  final String plan;
  final bool paid;

  const UltraMemberCard({
    super.key,
    required this.name,
    required this.joinDate,
    required this.expiry,
    required this.attendance,
    required this.plan,
    required this.paid,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gold.withOpacity(0.15)),
      ),

      child: PremiumCard(
        child: Row(
          children: [

            const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xff1E212A),
              child: Icon(Icons.person, color: Colors.white70),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Joined $joinDate • Exp $expiry",
                    style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12),
                  ),
                ],
              ),
            ),

            Text(
              "${attendance.toInt()}%",
              style: const TextStyle(color: gold),
            ),

            const SizedBox(width: 10),

            Icon(
              paid ? Icons.check_circle : Icons.error,
              color: paid ? Colors.green : Colors.red,
              size: 18,
            ),

            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}