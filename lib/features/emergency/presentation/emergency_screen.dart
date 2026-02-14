import 'package:flutter/material.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key, this.foodId});

  final String? foodId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('응급 모드')),
      body: Center(
        child: Text('foodId: ${foodId ?? 'unknownFood'}'),
      ),
    );
  }
}
