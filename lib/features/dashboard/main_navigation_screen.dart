import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dashboard/home_page.dart';
import '../attendance/qr_screen.dart';
import '../profile/trainer_profile_screen.dart';
import '../attendance/attendance_screen.dart';
import '../chat/chat_screen.dart';
import '../chat/memebers_list.dart';
import '../equipment/equipment_screen.dart';
import '../payments/add_payment.dart';
import '../packages/packages_screen.dart';
import '../accounts/daybook_screen.dart';

// ── Brand tokens ──────────────────────────────────────────────
const kGold       = Color(0xFFC8DC32);
const kGoldDark   = Color(0xFF8FA000);
const kGoldDeep   = Color(0xFF3A4500);
const kGoldLight  = Color(0xFFF5F8D6);
const kBg         = Color(0xFFF7F7F5);
const kSurface    = Color(0xFFFFFFFF);
const kSurface2   = Color(0xFFF5F5F5);
const kBorder     = Color(0xFFEFEFEF);
const kText1      = Color(0xFF111111);
const kText2      = Color(0xFFCCCCCC);
const kGoldBorder = Color(0xFFE2EC8A);

// ═══════════════════════════════════════════════════════════════
// MAIN NAVIGATION SCREEN
// ═══════════════════════════════════════════════════════════════
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with SingleTickerProviderStateMixin {

  int _currentIndex = 0;

  final _screens = const [
    HomePage(),
    AttendanceScreen(),
    QrScreen(),
    ChatScreen(),
    TrainerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: kBg,
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: _buildNavBar(),
      ),
    );
  }

  // ── Nav Bar ─────────────────────────────────────────────────
  Widget _buildNavBar() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
            _NavIcon(
              icon: Icons.home_rounded,
              index: 0,
              activeIndex: _currentIndex,
              onTap: () => _setIndex(0),
            ),
            _NavIcon(
              icon: Icons.fact_check_rounded,
              index: 1,
              activeIndex: _currentIndex,
              onTap: () => _setIndex(1),
            ),
            _AddCenterButton(onTap: _onAddTap),
            _ScanButton(
              isActive: _currentIndex == 2,
              onTap: () => _setIndex(2),
            ),
            _NavIconBadge(
              icon: Icons.chat_bubble_outline_rounded,
              index: 3,
              activeIndex: _currentIndex,
              badgeCount: 2,
              onTap: () => _setIndex(3),
            ),
            _NavIcon(
              icon: Icons.person_rounded,
              index: 4,
              activeIndex: _currentIndex,
              onTap: () => _setIndex(4),
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

  void _onAddTap() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AddEntrySheet(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// NAV ICON (no text, ultra premium style)
// ═══════════════════════════════════════════════════════════════
class _NavIcon extends StatelessWidget {
  final IconData icon;
  final int index, activeIndex;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
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
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? kGoldLight : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: kGold.withOpacity(.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ]
              : [],
        ),
        child: Icon(
          icon,
          size: isActive ? 24 : 22,
          color: isActive ? kGoldDark : kText2,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// NAV ICON WITH BADGE (Chat)
// ═══════════════════════════════════════════════════════════════
class _NavIconBadge extends StatelessWidget {
  final IconData icon;
  final int index, activeIndex, badgeCount;
  final VoidCallback onTap;

  const _NavIconBadge({
    required this.icon,
    required this.index,
    required this.activeIndex,
    required this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = activeIndex == index;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive ? kGoldLight : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: kGold.withOpacity(.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
                  : [],
            ),
            child: Icon(
              icon,
              size: isActive ? 24 : 22,
              color: isActive ? kGoldDark : kText2,
            ),
          ),
          if (badgeCount > 0)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: kGold,
                  shape: BoxShape.circle,
                  border: Border.all(color: kSurface, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    color: kText1,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Keep your existing _AddCenterButton, _ScanButton, AddEntrySheet, etc. unchanged


// ═══════════════════════════════════════════════════════════════
// CENTER ADD BUTTON
// ═══════════════════════════════════════════════════════════════
class _AddCenterButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AddCenterButton({required this.onTap});

  @override
  State<_AddCenterButton> createState() => _AddCenterButtonState();
}

class _AddCenterButtonState extends State<_AddCenterButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    _ctrl.forward().then((_) => _ctrl.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: kGold,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kGoldDark, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: kGold.withOpacity(.45),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: kGoldDeep,
            size: 24,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// QR SCAN BUTTON
// ═══════════════════════════════════════════════════════════════
class _ScanButton extends StatelessWidget {
  final bool         isActive;
  final VoidCallback onTap;

  const _ScanButton({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isActive ? kGold : kGoldLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? kGold : kGoldBorder,
            width: isActive ? 0 : 1.5,
          ),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: kGold.withOpacity(.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            )
          ]
              : [],
        ),
        child: Icon(
          Icons.qr_code_scanner_rounded,
          color: isActive ? kGoldDeep : kGoldDark,
          size: 24,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ADD ENTRY BOTTOM SHEET  (shared — used by nav bar + home page)
// ═══════════════════════════════════════════════════════════════
class AddEntrySheet extends StatelessWidget {
  const AddEntrySheet({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = [
      _EntryOption(
        icon: Icons.payment_rounded,
        label: "Add Payment",
        subtitle: "Record fee / payment",
        gradient: const LinearGradient(
          colors: [Color(0xFF37474F), Color(0xFF263238)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        page: const AddPaymentScreen(),
      ),
      // _EntryOption(
      //   icon: Icons.person_add_rounded,
      //   label: "Add Member",
      //   subtitle: "Register new member",
      //   gradient: const LinearGradient(
      //     colors: [Color(0xFFC8DC32), Color(0xFF8FA000)],
      //     begin: Alignment.topLeft,
      //     end: Alignment.bottomRight,
      //   ),
      //   page: const MembersListScreen(showActive: true),
      // ),
      _EntryOption(
        icon: Icons.fitness_center_rounded,
        label: "Add Equipment",
        subtitle: "Log gym equipment",
        gradient: const LinearGradient(
          colors: [Color(0xFFE65C00), Color(0xFFB84400)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        page: const EquipmentScreen(),
      ),
      _EntryOption(
        icon: Icons.workspace_premium_rounded,
        label: "Add Package",
        subtitle: "Create membership plan",
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD54F), Color(0xFFF9A825)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        page: const PackagesScreen(),
      ),
      _EntryOption(
        icon: Icons.menu_book_rounded,
        label: "Day Book Entry",
        subtitle: "Add income / expense",
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        page: const DaybookScreen(),
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: kBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Sheet header
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kGold,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kGoldDark, width: 1.5),
              ),
              child: const Icon(Icons.add_rounded, color: kText1, size: 22),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Add Entry",
                  style: TextStyle(
                    color: kText1,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  "What would you like to add?",
                  style: TextStyle(color: kText2, fontSize: 11),
                ),
              ],
            ),
          ]),

          const SizedBox(height: 20),

          ...entries.map((e) => _EntryOptionTile(option: e)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// ENTRY OPTION MODEL
// ═══════════════════════════════════════════════════════════════
class _EntryOption {
  final IconData       icon;
  final String         label, subtitle;
  final LinearGradient gradient;
  final Widget         page;

  const _EntryOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.page,
  });
}

// ═══════════════════════════════════════════════════════════════
// ENTRY OPTION TILE
// ═══════════════════════════════════════════════════════════════
class _EntryOptionTile extends StatefulWidget {
  final _EntryOption option;
  const _EntryOptionTile({required this.option});

  @override
  State<_EntryOptionTile> createState() => _EntryOptionTileState();
}

class _EntryOptionTileState extends State<_EntryOptionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final glowColor = widget.option.gradient.colors.first;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 200), () {
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => widget.option.page),
            );
          }
        });
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: _pressed ? kSurface2 : kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _pressed ? glowColor.withOpacity(0.4) : kBorder,
          ),
        ),
        child: Row(children: [
          // Icon with gradient bg
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: widget.option.gradient,
              borderRadius: BorderRadius.circular(13),
              boxShadow: _pressed
                  ? [
                BoxShadow(
                  color: glowColor.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
                  : [],
            ),
            child: Icon(widget.option.icon, color: Colors.white, size: 22),
          ),

          const SizedBox(width: 14),

          // Label + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.option.label,
                  style: const TextStyle(
                    color: kText1,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.option.subtitle,
                  style: const TextStyle(color: kText2, fontSize: 11),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 13,
            color: kText2,
          ),
        ]),
      ),
    );
  }
}