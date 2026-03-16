import 'package:flutter/material.dart';

import '../dashboard/home_page.dart';
import '../attendance/qr_screen.dart';
import '../profile/trainer_profile_screen.dart';
import '../attendance/attendance_screen.dart';

const gold = Color(0xFFD5EB45);
const bg = Color(0xff0B0D12);
const card = Color(0xff12141A);

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State {

  int currentIndex = 0;

  final screens = const [
    HomePage(), // index 0
    AttendanceScreen(), // index 1
    QrScreen(), // index 2
    TrainerProfileScreen(), // index 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      /// PAGE VIEW
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),

      /// BOTTOM NAV
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: gold.withOpacity(0.15),
                blurRadius: 25,
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              /// HOME
              _navItem(Icons.home_rounded, 0),

              /// ATTENDANCE
              _navItem(Icons.fact_check_rounded, 1),

              /// SCAN BUTTON
              _scanButton(),

              /// PROFILE
              _navItem(Icons.person_rounded, 3),
            ],
          ),
        ),
      ),
    );

  }

  /// NAV ITEM
  Widget _navItem(IconData icon, int index) {

    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive
              ? gold.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          size: 26,
          color: isActive ? gold : Colors.white54,
        ),
      ),
    );

  }

  /// SCAN BUTTON
  Widget _scanButton() {

    final isActive = currentIndex == 2;

    return GestureDetector(
      onTap: () => setState(() => currentIndex = 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isActive
              ? const LinearGradient(
            colors: [gold, Color(0xFFD5EB45)],
          )
              : null,
          color: isActive ? null : card,
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? gold.withOpacity(0.6)
                  : Colors.transparent,
              blurRadius: isActive ? 30 : 0,
            )
          ],
        ),
        child: Icon(
          Icons.qr_code_scanner,
          color: isActive ? Colors.black : Colors.white54,
          size: 28,
        ),
      ),
    );

  }
}