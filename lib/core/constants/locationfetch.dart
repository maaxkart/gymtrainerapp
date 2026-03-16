import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../features/auth/trainer_onboarding_screen.dart';

const gold = Color(0xFFD5EB45);

class LocationDetectScreen extends StatefulWidget {
  const LocationDetectScreen({super.key});

  @override
  State<LocationDetectScreen> createState() => _LocationDetectScreenState();
}

class _LocationDetectScreenState extends State<LocationDetectScreen>
    with SingleTickerProviderStateMixin {

  bool isLoading = true;

  String address = "";
  double latitude = 0;
  double longitude = 0;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    fetchLocation();
  }

  Future<void> fetchLocation() async {

    bool serviceEnabled;
    LocationPermission permission;

    /// check GPS
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enable GPS")),
      );
      return;
    }

    /// check permission
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission permanently denied")),
      );
      return;
    }

    /// GET GPS POSITION
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    latitude = position.latitude;
    longitude = position.longitude;

    /// convert to address
    List<Placemark> placemarks =
    await placemarkFromCoordinates(latitude, longitude);

    Placemark place = placemarks[0];

    String fullAddress =
        "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";

    setState(() {
      address = fullAddress;
      isLoading = false;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    /// PASS ADDRESS + LATITUDE + LONGITUDE
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => TrainerOnboardingScreen(
          address: address,
          latitude: latitude,
          longitude: longitude,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  Color(0xff0B0D12),
                  Color(0xff141821),
                  Color(0xff1C1F2A),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [
                  0.0,
                  _controller.value,
                  1.0,
                ],
              ),
            ),

            child: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),

                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 25,
                        sigmaY: 25,
                      ),

                      child: Container(
                        padding: const EdgeInsets.all(30),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),

                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFD5EB45),
                                    Color(0xFFB7D933),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: gold.withOpacity(0.6),
                                    blurRadius: 40,
                                    spreadRadius: 5,
                                  )
                                ],
                              ),

                              child: const Icon(
                                Icons.location_on,
                                size: 60,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 30),

                            const Text(
                              "Detecting Your Location",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 15),

                            isLoading
                                ? const CircularProgressIndicator(color: gold)
                                : Column(
                              children: [

                                Text(
                                  address,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),

                                const SizedBox(height: 15),

                                const Text(
                                  "Location Confirmed ✓",
                                  style: TextStyle(
                                    color: gold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}