import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

const gold = Color(0xFFD5EB45);
const bg = Color(0xff0B0D12);
const card = Color(0xff161A23);

class AddPackageScreen extends StatefulWidget {
  final int planId;
  final String planName;
  final bool isEdit;
  final String? price;

  const AddPackageScreen({
    super.key,
    required this.planId,
    required this.planName,
    required this.isEdit,
    this.price,
  });

  @override
  State<AddPackageScreen> createState() => _AddPackageScreenState();
}

class _AddPackageScreenState extends State<AddPackageScreen> {

  final priceController = TextEditingController();
  bool loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.price != null) {
      priceController.text = widget.price!;
    }
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  Future<void> savePlan() async {

    if (loading) return;

    if (priceController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter price")),
      );

      return;
    }

    setState(() => loading = true);

    try {

      Map response;

      if (widget.isEdit) {

        response = await ApiService.updateGymPlan(
          gymPlanId: widget.planId,
          price: priceController.text,
          active: true,
        );

      } else {

        response = await ApiService.addGymPlan(
          adminPlanId: widget.planId,
          customPrice: priceController.text,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(response["message"])));

      Navigator.pop(context);

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bg,

      body: CustomScrollView(
        slivers: [

          /// PREMIUM HEADER
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            backgroundColor: bg,

            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gold.withOpacity(.35),
                      bg
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),

                child: Align(
                  alignment: Alignment.bottomLeft,

                  child: Text(
                    widget.planName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// PLAN CARD
                  Container(
                    padding: const EdgeInsets.all(20),

                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color: gold.withOpacity(.1),
                          blurRadius: 25,
                        )
                      ],
                    ),

                    child: Row(
                      children: [

                        Container(
                          padding: const EdgeInsets.all(12),

                          decoration: BoxDecoration(
                            color: gold.withOpacity(.15),
                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.workspace_premium,
                            color: gold,
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Text(
                            widget.planName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4),

                          decoration: BoxDecoration(
                            color: gold,
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: const Text(
                            "PREMIUM",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Set Custom Price",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// GLASS INPUT
                  ClipRRect(
                    borderRadius: BorderRadius.circular(22),

                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                          sigmaX: 25,
                          sigmaY: 25),

                      child: Container(
                        padding: const EdgeInsets.all(22),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.05),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withOpacity(.08),
                          ),
                        ),

                        child: Row(
                          children: [

                            const Text(
                              "₹",
                              style: TextStyle(
                                fontSize: 34,
                                color: gold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: TextField(
                                controller: priceController,
                                keyboardType: TextInputType.number,

                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: gold,
                                ),

                                decoration: const InputDecoration(
                                  hintText: "Enter price",
                                  hintStyle: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white38,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// CTA BUTTON
                  SizedBox(
                    width: double.infinity,

                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFD5EB45),
                            Color(0xFFB7D933),
                          ],
                        ),
                      ),

                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              vertical: 16),
                        ),

                        onPressed: loading ? null : savePlan,

                        child: loading
                            ? const CircularProgressIndicator(
                          color: Colors.black,
                        )
                            : Text(
                          widget.isEdit
                              ? "Update Plan"
                              : "Add Plan",
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}