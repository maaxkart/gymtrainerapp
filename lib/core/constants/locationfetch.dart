import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../features/auth/trainer_onboarding_screen.dart';

const primaryGreen = Color(0xFFC8DC32);
const lightGreen = Color(0xFFC8DC32);
const bgWhite = Color(0xFFF7F9FC);

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

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enable GPS")),
      );
      return;
    }

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

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    latitude = position.latitude;
    longitude = position.longitude;

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
      backgroundColor: bgWhite,

      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {

          return Stack(
            children: [

              /// 🌿 BACKGROUND
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF7F9FC),
                      Color(0xFFE8F5E9),
                      Color(0xFFD0F0E0),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),

              /// 🌿 GLOW
              Positioned(
                top: -80,
                left: -60,
                child: glowCircle(primaryGreen),
              ),

              Positioned(
                bottom: -100,
                right: -60,
                child: glowCircle(lightGreen),
              ),

              /// 🧊 CARD
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),

                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 20,
                          sigmaY: 20,
                        ),

                        child: Container(
                          padding: const EdgeInsets.all(30),

                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(30),
                          ),

                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              /// ICON
                              Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [primaryGreen, lightGreen],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryGreen.withOpacity(0.4),
                                      blurRadius: 30,
                                    )
                                  ],
                                ),

                                child: const Icon(
                                  Icons.location_on,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 30),

                              const Text(
                                "Detecting Your Location",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),

                              const SizedBox(height: 15),

                              isLoading
                                  ? const CircularProgressIndicator(
                                color: primaryGreen,
                              )
                                  : Column(
                                children: [

                                  Text(
                                    address,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 16,
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  const Text(
                                    "Location Confirmed ✓",
                                    style: TextStyle(
                                      color: primaryGreen,
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
            ],
          );
        },
      ),
    );
  }

  Widget glowCircle(Color color) {

    return Container(
      height: 220,
      width: 220,

      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(.2),
      ),
    );
  }
}