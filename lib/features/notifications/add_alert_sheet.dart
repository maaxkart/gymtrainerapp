import 'package:flutter/material.dart';
import '../../services/api_service.dart';

const gold = Color(0xFFD5EB45);
const card = Color(0xff12141A);

class AddAlertSheet extends StatefulWidget {
  const AddAlertSheet({super.key});

  @override
  State<AddAlertSheet> createState() => _AddAlertSheetState();
}

class _AddAlertSheetState extends State<AddAlertSheet> {

  final titleController = TextEditingController();
  final messageController = TextEditingController();

  DateTime? expiry;

  Future pickDate() async {

    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => expiry = date);
    }
  }

  Future save() async {

    if (titleController.text.isEmpty ||
        messageController.text.isEmpty ||
        expiry == null) {
      return;
    }

    final res = await ApiService.addAlert(
      title: titleController.text,
      message: messageController.text,
      expiresAt: expiry.toString(),
    );

    if (res["status"] == "success") {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res["message"])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),

      child: Container(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Text(
              "Create Alert",
              style: TextStyle(
                fontSize: 18,
                color: gold,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Title",
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: messageController,
              maxLength: 180,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Message",
              ),
            ),

            const SizedBox(height: 14),

            ElevatedButton(
              onPressed: pickDate,
              child: Text(
                expiry == null
                    ? "Select Expiry Date"
                    : expiry.toString(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                minimumSize:
                const Size(double.infinity, 50),
              ),
              onPressed: save,
              child: const Text(
                "Send Alert",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}