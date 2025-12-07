import 'package:flutter/material.dart';

class ProtocolsScreen extends StatelessWidget {
  const ProtocolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SizedBox(height: 8),
        Text('Protocols', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ListTile(leading: Icon(Icons.science_outlined), title: Text('Disinfection & Sterilization')),
        ListTile(leading: Icon(Icons.delete_outline), title: Text('Waste Management')),
        ListTile(leading: Icon(Icons.clean_hands_outlined), title: Text('Hand Hygiene')),
      ],
    );
  }
}
