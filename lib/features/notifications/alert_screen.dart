import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'add_alert_sheet.dart';

const gold = Color(0xFFD5EB45);
const bg = Color(0xff0B0D12);
const card = Color(0xff12141A);

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
    loadAlerts();
  }

  Future loadAlerts() async {

    final data = await ApiService.getAlerts();

    print("ALERT COUNT: ${data.length}");

    setState(() {
      alerts = data;
      loading = false;
    });
  }

  void openAddSheet() async {

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => const AddAlertSheet(),
    );

    loadAlerts();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text("Gym Alerts"),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: gold,
        onPressed: openAddSheet,
        child: const Icon(Icons.add, color: Colors.black),
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(color: gold),
      )
          : alerts.isEmpty
          ? const Center(
        child: Text(
          "No alerts available",
          style: TextStyle(color: Colors.white54),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: alerts.length,
        itemBuilder: (_, i) {

          final alert = alerts[i];

          return AlertTile(
            title: alert["title"],
            message: alert["message"],
            expiry: alert["expires_at"],
          );
        },
      ),
    );
  }
}

class AlertTile extends StatelessWidget {

  final String title;
  final String message;
  final String expiry;

  const AlertTile({
    required this.title,
    required this.message,
    required this.expiry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
            child: Icon(Icons.notifications,
                color: Colors.white),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Expires: $expiry",
                  style: const TextStyle(
                    fontSize: 11,
                    color: gold,
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