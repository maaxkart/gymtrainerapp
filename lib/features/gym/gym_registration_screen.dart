import 'package:flutter/material.dart';
import '../../shared/widgets/premium_card.dart';

class GymRegistrationScreen extends StatelessWidget {
  const GymRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gym Registration')),
      body: SingleChildScrollView(
        child: PremiumCard(
          child: Column(
            children: const [
              TextField(decoration: InputDecoration(labelText: "Gym Name")),
              TextField(decoration: InputDecoration(labelText: "Location")),
              TextField(decoration: InputDecoration(labelText: "Amenities")),
              TextField(decoration: InputDecoration(labelText: "Programs")),
              SizedBox(height: 20),
              ElevatedButton(onPressed: null, child: Text("Submit"))
            ],
          ),
        ),
      ),
    );
  }
}