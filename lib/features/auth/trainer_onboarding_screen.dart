import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../gymregistration/register.dart';

const gold = Color(0xFFD5EB45);
const bg = Color(0xff0B0D12);
const card = Color(0xff12141A);

class TrainerOnboardingScreen extends StatefulWidget {

  final String address;
  final double latitude;
  final double longitude;

  const TrainerOnboardingScreen({
    super.key,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<TrainerOnboardingScreen> createState() =>
      _TrainerOnboardingScreenState();
}

class _TrainerOnboardingScreenState
    extends State<TrainerOnboardingScreen> {

  final PageController _controller = PageController();

  int page = 0;

  /// facilities from API
  List<Map<String, dynamic>> facilities = [];

  bool loading = true;

  /// store facility IDs
  List<int> selectedFacilities = [];

  /// facility images
  final Map<String, String> facilityImages = {

    "Personal Training":
    "https://images.unsplash.com/photo-1550345332-09e3ac987658",

    "Yoga & Pilates":
    "https://images.unsplash.com/photo-1599447421416-3414500d18a5",

    "Cardio & Strength":
    "https://images.unsplash.com/photo-1583454110551-21f2fa2afe61",

    "Wellness & Recovery":
    "https://images.unsplash.com/photo-1599058917765-a780eda07a3e",
  };

  @override
  void initState() {
    super.initState();
    loadFacilities();
  }

  /// LOAD FACILITIES FROM API
  Future<void> loadFacilities() async {

    try {

      final data = await ApiService.getFacilities();

      setState(() {
        facilities = List<Map<String, dynamic>>.from(data);
        loading = false;
      });

    } catch (e) {

      debugPrint("Facility API Error: $e");

      setState(() {
        loading = false;
      });
    }
  }

  /// NEXT PAGE
  void nextPage() {

    if (page == facilities.length - 1) {

      if (selectedFacilities.isEmpty) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please select at least one facility"),
          ),
        );

        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GymRegistrationScreen(
            selectedFacilities: selectedFacilities,
            address: widget.address,
            latitude: widget.latitude,
            longitude: widget.longitude,
          ),
        ),
      );

    } else {

      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: bg,
      bottomNavigationBar: _bottomButton(),

      body: loading
          ? const Center(
          child: CircularProgressIndicator(color: gold))

          : Stack(
        children: [

          /// PAGE VIEW
          PageView(
            controller: _controller,
            onPageChanged: (i) {
              setState(() => page = i);
            },

            children: facilities.map((facility) {

              final name = facility["name"];
              final id = facility["id"];

              return _buildPage(
                image: facilityImages[name] ??
                    "https://images.unsplash.com/photo-1571902943202-507ec2618e8f",
                title: name,
                facilityId: id,
              );

            }).toList(),
          ),

          /// STEP INDICATOR
          Positioned(
            top: 60,
            left: 0,
            right: 0,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: List.generate(
                facilities.length,
                    (i) => AnimatedContainer(
                  duration:
                  const Duration(milliseconds: 300),

                  margin: const EdgeInsets.symmetric(horizontal: 4),

                  height: 6,
                  width: page == i ? 28 : 10,

                  decoration: BoxDecoration(
                    color: page == i ? gold : Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// PAGE UI
  Widget _buildPage({
    required String image,
    required String title,
    required int facilityId,
  }) {

    final isSelected =
    selectedFacilities.contains(facilityId);

    return Stack(
      fit: StackFit.expand,
      children: [

        Image.network(image, fit: BoxFit.cover),

        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.85),
                Colors.black.withOpacity(0.6),
                Colors.black.withOpacity(0.9),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        SafeArea(
          child: Column(
            children: [

              /// SKIP


              const Spacer(),

              /// CARD
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: card.withOpacity(0.9),

                  border: Border.all(color: Colors.white10),

                  boxShadow: [
                    BoxShadow(
                      color: gold.withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: -10,
                    )
                  ],
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// SELECT BUTTON
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        isSelected ? gold : card,

                        padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 14),

                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(30),
                        ),
                      ),

                      onPressed: () {

                        setState(() {

                          if (selectedFacilities.contains(facilityId)) {
                            selectedFacilities.remove(facilityId);
                          } else {
                            selectedFacilities.add(facilityId);
                          }

                        });
                      },

                      child: Text(
                        isSelected
                            ? "Selected"
                            : "Select Facility",

                        style: TextStyle(
                          color: isSelected
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  /// BOTTOM BUTTON
  Widget _bottomButton() {

    return Padding(
      padding: const EdgeInsets.all(16),

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,

          padding:
          const EdgeInsets.symmetric(vertical: 16),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),

        onPressed: nextPage,

        child: Text(
          page == facilities.length - 1
              ? "Finish"
              : "Continue",

          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}