import 'package:flutter/material.dart';

class FeedingGuideScreen extends StatelessWidget {
  const FeedingGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기본 급여 가이드')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('급여 가이드 내용은 다음 PR에서 구현됩니다.'),
      ),
    );
  }
}
