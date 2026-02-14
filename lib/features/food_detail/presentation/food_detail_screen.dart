import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/state/app_state_scope.dart';
import '../../../core/types/avium_types.dart';
import '../../../core/widgets/medical_disclaimer_banner.dart';
import '../../../core/widgets/mixed_processed_warning_banner.dart';
import '../../../core/widgets/safety_badge.dart';
import '../../../data/models/food_item.dart';
import '../../../data/models/safety_condition.dart';
import '../domain/safety_condition_matcher.dart';

class FoodDetailScreen extends StatefulWidget {
  const FoodDetailScreen({required this.foodId, super.key});

  final String foodId;

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  static const _matcher = SafetyConditionMatcher();

  PartType? _selectedPart;
  PrepType? _selectedPrep;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final food = appState.getById(widget.foodId);

    if (food == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('음식 상세')),
        body: const Center(child: Text('음식 정보를 찾을 수 없습니다.')),
      );
    }

    final result = _matcher.match(
      representativeLevel: food.safetyLevel,
      conditions: food.safetyConditions,
      selectedPart: _selectedPart,
      selectedPrep: _selectedPrep,
    );

    return Scaffold(
      appBar: AppBar(title: Text(food.nameKo)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (food.foodType == FoodType.mixed ||
                food.foodType == FoodType.processed)
              const MixedProcessedWarningBanner(),
            _FirstView(food: food, level: result.resolvedLevel),
            const SizedBox(height: 16),
            if (food.safetyConditions.isNotEmpty)
              _ConditionSelector(
                selectedPart: _selectedPart,
                selectedPrep: _selectedPrep,
                options: food.safetyConditions,
                onPartSelected: (part) {
                  setState(() {
                    _selectedPart = part;
                  });
                },
                onPrepSelected: (prep) {
                  setState(() {
                    _selectedPrep = prep;
                  });
                },
              ),
            if (!result.isComplete && food.safetyConditions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '조건 선택이 완전하지 않아 보수적으로 표시됩니다.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (result.isAmbiguous)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '조건이 애매해 보수적으로 상향된 결과를 표시합니다.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (food.safetyConditions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(result.note),
              ),
            const SizedBox(height: 20),
            _Section(title: '왜?', lines: food.reasonKo),
            _Section(title: '조건', lines: food.riskNotesKo),
            _PortionSection(food: food),
            if (food.confusables.isNotEmpty)
              _Section(
                title: '혼동 주의(confusables)',
                lines: food.confusables
                    .map((item) => '${item.nameKo}: ${item.noteKo}')
                    .toList(growable: false),
              ),
            _EvidenceSection(food: food),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  context.pushNamed(
                    'emergency',
                    queryParameters: <String, String>{'foodId': food.id},
                  );
                },
                icon: const Icon(Icons.local_hospital_outlined),
                label: const Text('실수로 먹었어요'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FirstView extends StatelessWidget {
  const _FirstView({required this.food, required this.level});

  final FoodItem food;
  final SafetyLevel level;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        food.nameKo,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                        food.nameEn,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                SafetyBadge(level: level),
              ],
            ),
            const SizedBox(height: 10),
            Text(food.oneLinerKo),
            const SizedBox(height: 8),
            MedicalDisclaimerBanner(reviewedAt: food.reviewedAt),
          ],
        ),
      ),
    );
  }
}

class _ConditionSelector extends StatelessWidget {
  const _ConditionSelector({
    required this.selectedPart,
    required this.selectedPrep,
    required this.options,
    required this.onPartSelected,
    required this.onPrepSelected,
  });

  final PartType? selectedPart;
  final PrepType? selectedPrep;
  final List<SafetyCondition> options;
  final ValueChanged<PartType?> onPartSelected;
  final ValueChanged<PrepType?> onPrepSelected;

  @override
  Widget build(BuildContext context) {
    final partOptions = options
        .map((item) => item.part)
        .toSet()
        .toList(growable: false)
      ..sort((a, b) => a.index.compareTo(b.index));
    final prepOptions = options
        .map((item) => item.prep)
        .toSet()
        .toList(growable: false)
      ..sort((a, b) => a.index.compareTo(b.index));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '조건 선택',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text('부위', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: partOptions
              .map(
                (part) => ChoiceChip(
                  label: Text(part.labelKo),
                  selected: selectedPart == part,
                  onSelected: (selected) {
                    onPartSelected(selected ? part : null);
                  },
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 10),
        Text('형태·조리', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: prepOptions
              .map(
                (prep) => ChoiceChip(
                  label: Text(prep.labelKo),
                  selected: selectedPrep == prep,
                  onSelected: (selected) {
                    onPrepSelected(selected ? prep : null);
                  },
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          ...lines.map((line) => Text('• $line')),
        ],
      ),
    );
  }
}

class _PortionSection extends StatelessWidget {
  const _PortionSection({required this.food});

  final FoodItem food;

  @override
  Widget build(BuildContext context) {
    final lines = <String>[
      '가능 부위: ${food.portionsKo.allowedParts.join(', ')}',
      '피할 부위: ${food.portionsKo.avoidParts.join(', ')}',
      '빈도: ${food.portionsKo.frequency}',
      ...food.portionsKo.notes,
      ...food.portionsKo.examplesKo,
    ].where((line) => line.trim().isNotEmpty).toList(growable: false);

    return _Section(title: '급여 팁', lines: lines);
  }
}

class _EvidenceSection extends StatelessWidget {
  const _EvidenceSection({required this.food});

  final FoodItem food;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('근거/검토 정보'),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      children: <Widget>[
        Text('evidenceLevel: ${food.evidenceLevel.name}'),
        Text('reviewedAt: ${food.reviewedAt}'),
        const SizedBox(height: 6),
        ...food.sources.map((source) {
          return Text('• ${source.title} (${source.year})');
        }),
      ],
    );
  }
}
