import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/pwa/pwa_install_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/state/app_state_scope.dart';
import '../../../core/types/avium_types.dart';
import '../../../core/widgets/safety_badge.dart';
import '../../../data/models/food_db.dart';
import '../../../data/models/food_item.dart';
import '../widgets/zero_result_notice.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;
  int _tabIndex = 0;
  bool _isShowingInitialDisclaimer = false;
  _RiskFilterOption _riskFilter = _RiskFilterOption.all;

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
        title: Text(
          'Avium',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
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
          final hasQuery = query.trim().isNotEmpty;
          final results = appState.searchResults;
          final filteredResults = _filterByRisk(results);
          final isZeroResult = hasQuery && results.isEmpty;
          final isFilterZeroResult =
              results.isNotEmpty && filteredResults.isEmpty;
          _showInitialDisclaimerIfNeeded(context, appState);

          return Column(
            children: <Widget>[
              Expanded(
                child: _tabIndex == 0
                    ? _HomeLanding(
                        foods: appState.allFoods,
                        onGoSearch: () {
                          setState(() {
                            _tabIndex = 1;
                          });
                        },
                        onOpenFood: (food) {
                          context.pushNamed(
                            'food-detail',
                            pathParameters: <String, String>{'id': food.id},
                          );
                        },
                      )
                    : _tabIndex == 1
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Column(
                              children: <Widget>[
                                _SearchField(
                                  controller: _controller,
                                  onChanged: appState.setQuery,
                                ),
                                const SizedBox(height: 10),
                                _RiskFilterBar(
                                  selected: _riskFilter,
                                  onSelected: (option) {
                                    setState(() {
                                      _riskFilter = option;
                                    });
                                  },
                                ),
                                if (_riskFilter != _RiskFilterOption.all)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Wrap(
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 8,
                                        children: <Widget>[
                                          Text(
                                            '현재 필터: ${_riskFilter.label}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _riskFilter =
                                                    _RiskFilterOption.all;
                                              });
                                            },
                                            child: const Text('필터 해제'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: isZeroResult
                                      ? SingleChildScrollView(
                                          child: ZeroResultNotice(
                                            onOpenEmergencyUnknown: () {
                                              context.pushNamed('emergency');
                                            },
                                            onOpenRequestTemplate: () {
                                              _openMailTemplate(
                                                context,
                                                query,
                                              );
                                            },
                                            suggestions: appState.suggestions,
                                            onSuggestionTap: (word) {
                                              _controller.text = word;
                                              appState.setQuery(word);
                                            },
                                          ),
                                        )
                                      : isFilterZeroResult
                                          ? const _RiskFilterEmptyState()
                                          : _ResultList(
                                              foods: filteredResults,
                                              onTapFood: (food) {
                                                context.pushNamed(
                                                  'food-detail',
                                                  pathParameters: <String,
                                                      String>{
                                                    'id': food.id,
                                                  },
                                                );
                                              },
                                            ),
                                ),
                              ],
                            ),
                          )
                        : _InfoTab(
                            meta: appState.meta,
                            onOpenGuide: () => context.pushNamed('guide'),
                            onOpenAppInfo: () => context.pushNamed('settings'),
                          ),
              ),
              NavigationBar(
                selectedIndex: _tabIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _tabIndex = index;
                  });
                },
                destinations: const <Widget>[
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: '홈',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.search_outlined),
                    selectedIcon: Icon(Icons.search),
                    label: '검색',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.info_outline),
                    selectedIcon: Icon(Icons.info),
                    label: '정보',
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showInitialDisclaimerIfNeeded(BuildContext context, AppState appState) {
    if (appState.hasSeenInitialDisclaimer || _isShowingInitialDisclaimer) {
      return;
    }
    _isShowingInitialDisclaimer = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || appState.hasSeenInitialDisclaimer) {
        _isShowingInitialDisclaimer = false;
        return;
      }
      appState.markInitialDisclaimerSeen();
      final installInfo = getPwaInstallInfo();
      final showInstallAction =
          installInfo.isMobileWeb && !installInfo.isStandalone;
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('처음 방문 안내'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Avium은 앵무새 급여 안전을 빠르게 확인하는 참고 앱입니다.',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '이용 안내',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text('• 검색 탭에서 음식명/자음으로 바로 찾을 수 있습니다.'),
                  const Text('• 상세에서 부위·형태를 선택하면 결과가 더 정확해집니다.'),
                  const Text('• 증상이 있으면 긴급 대응 확인으로 바로 이동하세요.'),
                  const Text('• 본 앱 정보는 참고용이며 진단/치료를 대체하지 않습니다.'),
                  if (showInstallAction) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      '모바일 브라우저에서는 홈 화면에 추가해 사용하면 '
                      '앱처럼 더 편리합니다. 아래 버튼으로 바로 진행하세요.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: <Widget>[
              if (showInstallAction)
                TextButton(
                  onPressed: () => _onTapAddToHomeScreen(context),
                  child: const Text('홈 화면에 추가하기'),
                ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('동의하고 시작하기'),
              ),
            ],
          );
        },
      );
      _isShowingInitialDisclaimer = false;
    });
  }

  Future<void> _onTapAddToHomeScreen(BuildContext context) async {
    final info = getPwaInstallInfo();
    if (!info.isMobileWeb || info.isStandalone) {
      return;
    }

    if (info.platform == PwaInstallPlatform.android && info.canPromptInstall) {
      await promptPwaInstall();
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설치 팝업을 열었습니다. 안내에 따라 진행해 주세요.')),
      );
      return;
    }

    if (!context.mounted) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return _AddToHomeGuideSheet(platform: info.platform);
      },
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
      'mailto:window95pill@gmail.com?subject=$subject&body=$body',
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

  List<FoodItem> _filterByRisk(List<FoodItem> foods) {
    final level = _riskFilter.level;
    if (level == null) {
      return foods;
    }
    return foods
        .where((food) => food.safetyLevel == level)
        .toList(growable: false);
  }
}

class _RiskFilterEmptyState extends StatelessWidget {
  const _RiskFilterEmptyState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            Text(
              '선택한 위험도에 맞는 결과가 없습니다.',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 6),
            Text('위험도 필터를 변경하거나 전체로 돌려보세요.'),
          ],
        ),
      ),
    );
  }
}

class _AddToHomeGuideSheet extends StatelessWidget {
  const _AddToHomeGuideSheet({required this.platform});

  final PwaInstallPlatform platform;

  @override
  Widget build(BuildContext context) {
    final isIos = platform == PwaInstallPlatform.iosSafari;
    final title = isIos ? 'iPhone 홈 화면 추가' : 'Android 홈 화면 추가';
    final steps = isIos
        ? const <String>[
            'Safari 하단의 공유 버튼(□↑)을 누르세요.',
            '"홈 화면에 추가"를 선택하세요.',
            '추가 후 홈 화면에서 Avium을 실행하세요.',
          ]
        : const <String>[
            '브라우저 메뉴(⋮)를 여세요.',
            '"앱 설치" 또는 "홈 화면에 추가"를 선택하세요.',
            '추가 후 홈 화면에서 Avium을 실행하세요.',
          ];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            ...steps.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('• $step'),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskFilterBar extends StatelessWidget {
  const _RiskFilterBar({
    required this.selected,
    required this.onSelected,
  });

  final _RiskFilterOption selected;
  final ValueChanged<_RiskFilterOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          '위험도',
          style: Theme.of(context)
              .textTheme
              .labelLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _RiskFilterOption.values.map((option) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    selected: option == selected,
                    label: Text(option.label),
                    tooltip: '${option.label} 위험도만 보기',
                    onSelected: (_) => onSelected(option),
                  ),
                );
              }).toList(growable: false),
            ),
          ),
        ),
      ],
    );
  }
}

enum _RiskFilterOption {
  all(null, '전체'),
  safe(SafetyLevel.safe, '안전'),
  caution(SafetyLevel.caution, '주의'),
  danger(SafetyLevel.danger, '위험');

  const _RiskFilterOption(this.level, this.label);

  final SafetyLevel? level;
  final String label;
}

class _HomeLanding extends StatelessWidget {
  const _HomeLanding({
    required this.foods,
    required this.onGoSearch,
    required this.onOpenFood,
  });

  final List<FoodItem> foods;
  final VoidCallback onGoSearch;
  final ValueChanged<FoodItem> onOpenFood;

  @override
  Widget build(BuildContext context) {
    if (foods.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final today = DateTime.now();
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 640;
        final itemCount = isWide ? 4 : 2;
        final recommendFoods = _pickDailyItems(
          foods.where((food) => food.safetyLevel == SafetyLevel.safe).toList(),
          today,
          count: itemCount,
        );
        final riskyFoods = _pickDailyItems(
          foods
              .where((food) => food.safetyLevel == SafetyLevel.danger)
              .toList(),
          today,
          count: itemCount,
        );

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              '매일 급여 전, 먼저 확인하세요',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '추천/위험 음식은 매일 바뀝니다.',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      FilledButton.icon(
                        onPressed: onGoSearch,
                        icon: const Icon(Icons.search),
                        label: const Text('검색 시작'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    _DailyFoodSectionCard(
                      title: '오늘의 추천 음식',
                      foods: recommendFoods,
                      onOpenFood: onOpenFood,
                    ),
                    const SizedBox(height: 10),
                    _DailyFoodSectionCard(
                      title: '오늘의 위험 음식',
                      foods: riskyFoods,
                      onOpenFood: onOpenFood,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<FoodItem> _pickDailyItems(
    List<FoodItem> candidates,
    DateTime dateTime, {
    required int count,
  }) {
    if (candidates.isEmpty) {
      return const <FoodItem>[];
    }

    final dayKey = dateTime.year * 400 +
        dateTime.difference(DateTime(dateTime.year)).inDays;
    final selected = <FoodItem>[];
    final usedIndexes = <int>{};

    var offset = 0;
    while (selected.length < count && usedIndexes.length < candidates.length) {
      final index = (dayKey + offset) % candidates.length;
      if (usedIndexes.add(index)) {
        selected.add(candidates[index]);
      }
      offset++;
    }

    return selected;
  }
}

class _DailyFoodSectionCard extends StatelessWidget {
  const _DailyFoodSectionCard({
    required this.title,
    required this.foods,
    required this.onOpenFood,
  });

  final String title;
  final List<FoodItem> foods;
  final ValueChanged<FoodItem> onOpenFood;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ...foods.map(
              (food) => _CompactFoodTile(
                food: food,
                onTap: () => onOpenFood(food),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactFoodTile extends StatelessWidget {
  const _CompactFoodTile({
    required this.food,
    required this.onTap,
  });

  final FoodItem food;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        button: true,
        label: '${food.nameKo} 상세 보기',
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        food.nameKo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        food.oneLinerKo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SafetyBadge(level: food.safetyLevel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({
    required this.meta,
    required this.onOpenGuide,
    required this.onOpenAppInfo,
  });

  final FoodDbMeta? meta;
  final VoidCallback onOpenGuide;
  final VoidCallback onOpenAppInfo;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '앱 정보',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                const Text('Avium은 Naviary에서 제공하는 오프라인 참고 앱입니다.'),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: _openNaviarySite,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('naviary.io 방문'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _openHospitalFinderSite,
                  icon: const Icon(Icons.local_hospital_outlined),
                  label: const Text('주변 앵무새 병원 찾기'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onOpenGuide,
                  icon: const Icon(Icons.menu_book_outlined),
                  label: const Text('기본 급여 가이드 열기'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onOpenAppInfo,
                  icon: const Icon(Icons.info_outline),
                  label: const Text('앱 정보 자세히'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  '이용 안내',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text('• 이 앱은 의료 앱이 아니며 진단/치료를 제공하지 않습니다.'),
                Text('• 절대적인 판단 기준으로 사용하지 마세요.'),
                Text('• 불안하거나 증상이 있으면 즉시 진료기관에 문의하세요.'),
              ],
            ),
          ),
        ),
        if (meta != null) ...<Widget>[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '콘텐츠 기준 정보',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text('콘텐츠 버전: ${meta!.dataVersion}'),
                  Text('마지막 검토일: ${meta!.reviewedAt}'),
                  const SizedBox(height: 8),
                  const Text('• 이 정보는 앱에 포함된 기준 데이터입니다.'),
                  const Text('• 최신 상황은 진료기관 안내를 우선해 주세요.'),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _openNaviarySite() async {
    final uri = Uri.parse('https://naviary.io');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openHospitalFinderSite() async {
    final uri = Uri.parse('https://www.angmorning.com/hospitals/');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '음식 검색 입력',
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: '검색 (예: 사과, banana, ㅅㄱ)',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
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
