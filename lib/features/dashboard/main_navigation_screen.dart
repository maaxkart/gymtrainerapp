import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dashboard/home_page.dart';
import '../attendance/qr_screen.dart';
import '../profile/trainer_profile_screen.dart';
import '../attendance/attendance_screen.dart';

// ── Brand tokens ──────────────────────────────────────
const kGold      = Color(0xFFC8DC32);
const kGoldDark  = Color(0xFF8FA000);
const kGoldDeep  = Color(0xFF3A4500);
const kGoldLight = Color(0xFFF5F8D6);
const kBg        = Color(0xFFF7F7F5);
const kSurface   = Color(0xFFFFFFFF);
const kBorder    = Color(0xFFEFEFEF);
const kText1     = Color(0xFF111111);
const kText2     = Color(0xFFCCCCCC);

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen>
    with SingleTickerProviderStateMixin {

  int _currentIndex = 0;

  // Tab labels for accessibility
  static const _labels = ["Home", "Attendance", "QR Scan", "Profile"];

  final _screens = const [
    HomePage(),
    AttendanceScreen(),
    QrScreen(),
    TrainerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: kBg,
        extendBody: true,

        // ── Page body ─────────────────────────────────
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),

        // ── Bottom nav bar ────────────────────────────
        bottomNavigationBar: _buildNavBar(),
      ),
    );
  }

  Widget _buildNavBar() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        padding: const EdgeInsets.symmetric(
            horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon:        Icons.home_rounded,
              label:       _labels[0],
              index:       0,
              activeIndex: _currentIndex,
              onTap: () => _setIndex(0),
            ),
            _NavItem(
              icon:        Icons.fact_check_rounded,
              label:       _labels[1],
              index:       1,
              activeIndex: _currentIndex,
              onTap: () => _setIndex(1),
            ),

            // Center QR scan button
            _ScanButton(
              isActive: _currentIndex == 2,
              onTap:    () => _setIndex(2),
            ),

            _NavItem(
              icon:        Icons.person_rounded,
              label:       _labels[3],
              index:       3,
              activeIndex: _currentIndex,
              onTap: () => _setIndex(3),
            ),
          ],
        ),
      ),
    );
  }

  void _setIndex(int i) {
    if (_currentIndex == i) return;
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = i);
  }
}

// ── NAV ITEM ──────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final int      index;
  final int      activeIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.activeIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = activeIndex == index;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve:    Curves.easeOutCubic,
        padding:  const EdgeInsets.symmetric(
            horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:        isActive ? kGoldLight : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: isActive
        // Active: icon + label side by side
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: kGoldDark),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color:      kGoldDark,
                fontSize:   12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        )
        // Inactive: icon only
            : Icon(icon, size: 22, color: kText2),
      ),
    );
  }
}

// ── SCAN BUTTON ───────────────────────────────────────────────
class _ScanButton extends StatelessWidget {
  final bool         isActive;
  final VoidCallback onTap;

  const _ScanButton({
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve:    Curves.easeOutCubic,
        width:    56,
        height:   56,
        decoration: BoxDecoration(
          color:        isActive ? kGold : kGoldLight,
          borderRadius: BorderRadius.circular(20),
          border:       Border.all(
            color: isActive ? kGold : kGoldBorder,
            width: isActive ? 0   : 1.5,
          ),
          boxShadow: isActive
              ? [
            BoxShadow(
              color:     kGold.withOpacity(.4),
              blurRadius: 16,
              offset:    const Offset(0, 6),
            ),
          ]
              : [],
        ),
        child: Icon(
          Icons.qr_code_scanner_rounded,
          color: isActive ? kGoldDeep : kGoldDark,
          size:  26,
        ),
      ),
    );
  }
}

// ── helper constant exposed for use in _ScanButton ────────────
const kGoldBorder = Color(0xFFE2EC8A);