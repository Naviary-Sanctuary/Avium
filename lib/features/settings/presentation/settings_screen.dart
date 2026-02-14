import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('데이터 버전 정보는 다음 PR에서 연결됩니다.'),
      ),
    );
  }
}
