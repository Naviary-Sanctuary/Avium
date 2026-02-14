import 'package:flutter/material.dart';

class FoodDetailScreen extends StatelessWidget {
  const FoodDetailScreen({required this.foodId, super.key});

  final String foodId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('음식 상세')),
      body: Center(
        child: Text('foodId: $foodId'),
      ),
    );
  }
}
