import 'package:flutter/material.dart';

class BundlesListScreen extends StatelessWidget {
  const BundlesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SizedBox(height: 8),
        Text('Infection Control Bundles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ListTile(leading: Icon(Icons.health_and_safety_outlined), title: Text('CLABSI Bundle')),
        ListTile(leading: Icon(Icons.water_drop_outlined), title: Text('CAUTI Bundle')),
        ListTile(leading: Icon(Icons.air_outlined), title: Text('VAP Bundle')),
        ListTile(leading: Icon(Icons.medical_services_outlined), title: Text('SSI Bundle')),
        ListTile(leading: Icon(Icons.bug_report_outlined), title: Text('C. difficile Bundle')),
        ListTile(leading: Icon(Icons.cleaning_services_outlined), title: Text('Environmental Cleaning')),
      ],
    );
  }
}
