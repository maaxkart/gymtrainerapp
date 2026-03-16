import 'package:flutter/material.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;

  const PremiumCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff1C1F2E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}