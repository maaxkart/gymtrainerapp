import 'package:flutter/material.dart';
import '../../services/api_service.dart';

const gold = Color(0xFFD5EB45);
const card = Color(0xff12141A);

class AddEditEquipmentSheet extends StatefulWidget {

  final int? equipmentId;
  final int? masterId;
  final int? quantity;

  const AddEditEquipmentSheet({
    super.key,
    this.equipmentId,
    this.masterId,
    this.quantity,
  });

  @override
  State<AddEditEquipmentSheet> createState() => _AddEditEquipmentSheetState();
}

class _AddEditEquipmentSheetState extends State<AddEditEquipmentSheet> {

  List equipmentMaster = [];
  int? selectedId;

  final qtyController = TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadMaster();
  }

  Future loadMaster() async {

    final data = await ApiService.getEquipmentMaster();

    setState(() {
      equipmentMaster = data;
      loading = false;
    });

    if(widget.masterId != null){
      selectedId = widget.masterId;
    }

    if(widget.quantity != null){
      qtyController.text = widget.quantity.toString();
    }
  }

  Future save() async {

    if (selectedId == null || qtyController.text.isEmpty) return;

    if(widget.equipmentId == null){

      await ApiService.addEquipment(
        equipmentId: selectedId!,
        quantity: int.parse(qtyController.text),
      );

    }else{

      await ApiService.updateEquipment(
        id: widget.equipmentId!,
        equipmentId: selectedId!,
        quantity: int.parse(qtyController.text),
      );

    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),

      child: Container(
        padding: const EdgeInsets.all(20),

        child: loading
            ? const Center(child: CircularProgressIndicator(color: gold))
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Text(
              widget.equipmentId == null
                  ? "Add Equipment"
                  : "Update Equipment",
              style: const TextStyle(
                color: gold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<int>(

              dropdownColor: card,

              decoration: const InputDecoration(
                labelText: "Select Equipment",
              ),

              value: selectedId,

              items: equipmentMaster.map<DropdownMenuItem<int>>((e) {

                return DropdownMenuItem<int>(
                  value: e["id"],
                  child: Text(
                    e["name"],
                    style: const TextStyle(color: Colors.white),
                  ),
                );

              }).toList(),

              onChanged: (v) {
                setState(() => selectedId = v);
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Quantity",
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                minimumSize: const Size(double.infinity,50),
              ),
              onPressed: save,
              child: const Text(
                "Save Equipment",
                style: TextStyle(color: Colors.black),
              ),
            ),

            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}