import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/api_service.dart';

const gold = Color(0xFFD5EB45);
const bg = Color(0xff0B0D12);
const surface = Color(0xff161A23);

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {

  String? qrToken;
  int? exerciseId;

  List exercises = [];
  Map? verifiedUser;

  bool loading = false;
  bool scanned = false;

  bool isGymOpen = true;

  @override
  void initState() {
    super.initState();
    loadExercises();
  }

  Future loadExercises() async {
    final data = await ApiService.getExerciseMaster();

    setState(() {
      exercises = data;
    });
  }

  Future verifyUser() async {

    if (qrToken == null || exerciseId == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Scan QR and select exercise")),
      );

      return;
    }

    setState(() => loading = true);

    final res = await ApiService.verifyCheckin(
      token: qrToken!,
      exerciseId: exerciseId!,
    );

    setState(() {
      loading = false;
      verifiedUser = res["data"];
      scanned = false;
      qrToken = null;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(res["message"])));
  }

  Future toggleGymStatus() async {

    final res = await ApiService.toggleGymStatus();

    setState(() {
      isGymOpen = res["is_open"];
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(res["message"])));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: bg,
        title: const Text("QR Attendance"),

        actions: [

          GestureDetector(
            onTap: toggleGymStatus,

            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),

              decoration: BoxDecoration(
                color: isGymOpen ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),

              child: Row(
                children: [

                  Icon(
                    isGymOpen ? Icons.lock_open : Icons.lock,
                    size: 16,
                    color: Colors.white,
                  ),

                  const SizedBox(width: 6),

                  Text(
                    isGymOpen ? "OPEN" : "CLOSED",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),

      body: isGymOpen
          ? ListView(
        padding: const EdgeInsets.all(20),

        children: [

          /// QR SCANNER
          Container(
            height: 260,

            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20),
            ),

            child: Stack(
              children: [

                MobileScanner(

                  onDetect: (BarcodeCapture capture) {

                    if (scanned) return;

                    final String? code =
                        capture.barcodes.first.rawValue;

                    if (code != null) {

                      scanned = true;

                      setState(() {
                        qrToken = code;
                      });
                    }
                  },
                ),


                /// SCAN FRAME
                Center(
                  child: Container(
                    width: 220,
                    height: 220,

                    decoration: BoxDecoration(
                      border: Border.all(
                        color: gold,
                        width: 3,
                      ),

                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// EXERCISE DROPDOWN
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),

            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(14),
            ),

            child: DropdownButton(
              value: exerciseId,
              dropdownColor: surface,
              underline: const SizedBox(),
              hint: const Text("Select Exercise"),

              isExpanded: true,

              items: exercises.map((e) {

                return DropdownMenuItem(
                  value: e["id"],
                  child: Text(e["name"]),
                );

              }).toList(),

              onChanged: (val) {
                setState(() {
                  exerciseId = val as int;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          /// VERIFY BUTTON
          SizedBox(
            height: 50,

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: Colors.black,
              ),

              onPressed: loading ? null : verifyUser,

              child: loading
                  ? const CircularProgressIndicator(
                color: Colors.black,
              )
                  : const Text("Verify Check-in"),
            ),
          ),
        ],
      )

          : const Center(
        child: Text(
          "Gym Closed",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}