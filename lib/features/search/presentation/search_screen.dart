import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avium'),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.pushNamed('guide'),
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: '기본 급여 가이드',
          ),
          IconButton(
            onPressed: () => context.pushNamed('settings'),
            icon: const Icon(Icons.settings_outlined),
            tooltip: '설정',
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '검색 기능은 다음 PR에서 구현됩니다.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
