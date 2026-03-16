import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'add_edit_equipment_sheet.dart';

const gold = Color(0xFFD5EB45);
const bg = Color(0xff0B0D12);
const card = Color(0xff12141A);

class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {

  List equipment = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadEquipment();
  }

  Future loadEquipment() async {

    final data = await ApiService.getEquipment();

    setState(() {
      equipment = data;
      loading = false;
    });
  }

  void openAddSheet() async {

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => const AddEditEquipmentSheet(),
    );

    loadEquipment();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text("Gym Equipment"),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: gold,
        onPressed: openAddSheet,
        child: const Icon(Icons.add,color: Colors.black),
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator(color: gold))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: equipment.length,
        itemBuilder: (_, i) {

          final item = equipment[i];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),

            child: Row(
              children: [

                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: gold.withOpacity(.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.fitness_center,color: gold),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        item["master"]["name"],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "Quantity : ${item["quantity"] ?? 0}",
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                ),

                Row(
                  children: [

                    IconButton(
                      icon: const Icon(Icons.edit, color: gold),
                      onPressed: () async {

                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: card,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                          ),
                          builder: (_) => AddEditEquipmentSheet(
                            equipmentId: item["id"],
                            masterId: item["equipment_master_id"],
                            quantity: int.tryParse(item["quantity"].toString()) ?? 0,
                          ),
                        );

                        loadEquipment();
                      },
                    ),

                    IconButton(
                      icon: const Icon(Icons.delete,color: Colors.red),
                      onPressed: () async {

                        await ApiService.deleteEquipment(item["id"]);
                        loadEquipment();

                      },
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}