import 'dart:ui';
import 'package:flutter/material.dart';

const gold = Color(0xFFD5EB45);
const bg = Color(0xff0B0D12);
const card = Color(0xff12141A);

class AddMemberScreen extends StatelessWidget {
  const AddMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      bottomNavigationBar: _saveButton(),

      body: Stack(
        children: [

          /// 🔥 HEADER GRADIENT
          Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  gold.withOpacity(0.25),
                  bg,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// 💎 CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  _appBar(),

                  const SizedBox(height: 20),

                  _profilePicker(),

                  const SizedBox(height: 30),

                  _glassForm(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  /// 💎 APP BAR
  Widget _appBar() {
    return Row(
      children: const [
        BackButton(color: Colors.white),
        SizedBox(width: 10),
        Text("Add Member",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
      ],
    );
  }

  /// 👤 PROFILE
  Widget _profilePicker() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: gold, width: 2),
          ),
          child: const CircleAvatar(
            radius: 50,
            backgroundColor: card,
            child: Icon(Icons.person, size: 45, color: Colors.white54),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: gold,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.camera_alt, size: 18, color: Colors.black),
        )
      ],
    );
  }

  /// 💎 GLASS FORM
  Widget _glassForm() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: card.withOpacity(0.7),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [

              _field("Full Name", Icons.person),
              _field("Phone Number", Icons.phone),
              _field("Email", Icons.email),

              const SizedBox(height: 20),

              _sectionTitle("Select Plan"),

              Row(
                children: const [
                  Expanded(child: _planCard("Basic")),
                  SizedBox(width: 10),
                  Expanded(child: _planCard("Gold")),
                  SizedBox(width: 10),
                  Expanded(child: _planCard("Premium")),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: _dateButton("Join Date")),
                  const SizedBox(width: 10),
                  Expanded(child: _dateButton("Expiry Date")),
                ],
              ),

              const SizedBox(height: 20),

              _field("Fees Paid", Icons.currency_rupee),

              const SizedBox(height: 20),

              _sectionTitle("Payment Status"),

              Row(
                children: const [
                  Expanded(child: _statusCard("Paid")),
                  SizedBox(width: 10),
                  Expanded(child: _statusCard("Due")),
                ],
              ),

              const SizedBox(height: 20),

              _field("Notes", Icons.note, maxLines: 3),
            ],
          ),
        ),
      ),
    );
  }

  /// 🧩 INPUT FIELD
  Widget _field(String hint, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: gold),
          filled: true,
          fillColor: Colors.black.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// 🧩 TITLE
  Widget _sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  /// 💎 SAVE BUTTON
  Widget _saveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {},
        child: const Text("Save Member",
            style:
            TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

/// 🏷 PLAN CARD
class _planCard extends StatelessWidget {
  final String text;
  const _planCard(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(text,
            style: const TextStyle(
                color: gold, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

/// 📅 DATE BUTTON
class _dateButton extends StatelessWidget {
  final String text;
  const _dateButton(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(text, style: const TextStyle(color: gold)),
      ),
    );
  }
}

/// 💰 STATUS CARD
class _statusCard extends StatelessWidget {
  final String text;
  const _statusCard(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(text,
            style: const TextStyle(
                color: gold, fontWeight: FontWeight.bold)),
      ),
    );
  }
}