import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/state/app_state_scope.dart';
import '../../../core/widgets/safety_badge.dart';
import '../../../data/models/food_item.dart';
import '../widgets/zero_result_notice.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

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
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          if (appState.isInitializing) {
            return const Center(child: CircularProgressIndicator());
          }

          if (appState.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('데이터 로딩에 실패했습니다.'),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: appState.initialize,
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            );
          }

          final query = appState.query;
          final results = appState.searchResults;
          final isZeroResult = query.isNotEmpty && results.isEmpty;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: <Widget>[
                _SearchField(
                  controller: _controller,
                  onChanged: appState.setQuery,
                ),
                const SizedBox(height: 12),
                if (isZeroResult)
                  ZeroResultNotice(
                    onOpenEmergencyUnknown: () {
                      context.pushNamed('emergency');
                    },
                    onOpenRequestTemplate: () {
                      _openMailTemplate(context, query);
                    },
                    suggestions: appState.suggestions,
                    onSuggestionTap: (word) {
                      _controller.text = word;
                      appState.setQuery(word);
                    },
                  )
                else
                  Expanded(
                    child: _ResultList(
                      foods: results,
                      onTapFood: (food) {
                        context.pushNamed(
                          'food-detail',
                          pathParameters: <String, String>{'id': food.id},
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openMailTemplate(BuildContext context, String query) async {
    final subject = Uri.encodeComponent('[Avium] 음식 정보 요청: $query');
    final body = Uri.encodeComponent(
      '음식명: $query\n'
      '가공 형태(알고 있다면): \n'
      '섭취 상황(선택): \n'
      '추가 메모: \n',
    );
    final uri = Uri.parse(
      'mailto:support@naviary.app?subject=$subject&body=$body',
    );

    if (!await launchUrl(uri)) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('메일 앱을 열 수 없습니다.')),
      );
    }
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: '음식 이름(한글/영문/별칭)',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({required this.foods, required this.onTapFood});

  final List<FoodItem> foods;
  final ValueChanged<FoodItem> onTapFood;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: foods.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final food = foods[index];
        return Card(
          child: ListTile(
            onTap: () => onTapFood(food),
            title: Text(food.nameKo),
            subtitle: Text(food.oneLinerKo),
            trailing: SafetyBadge(level: food.safetyLevel),
          ),
        );
      },
    );
  }
}
