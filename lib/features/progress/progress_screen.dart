import 'package:flutter/material.dart';
import '../../shared/widgets/premium_card.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Member Progress')),
      body: PremiumCard(
        child: Column(
          children: const [
            ListTile(title: Text("Weight"), trailing: Text("78 KG")),
            ListTile(title: Text("BMI"), trailing: Text("22.3")),
            ListTile(title: Text("Fat %"), trailing: Text("18%")),
          ],
        ),
      ),
    );
  }
}