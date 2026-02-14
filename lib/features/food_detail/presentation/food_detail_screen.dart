import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/state/app_state_scope.dart';
import '../../../core/types/avium_types.dart';
import '../../../core/widgets/medical_disclaimer_banner.dart';
import '../../../core/widgets/mixed_processed_warning_banner.dart';
import '../../../core/widgets/safety_badge.dart';
import '../../../data/models/food_item.dart';
import '../../../data/models/safety_condition.dart';
import '../../../data/models/source_reference.dart';
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
                title: '헷갈리기 쉬운 음식',
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
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.fact_check_outlined, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  '근거/검토 정보',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                Chip(
                  avatar: const Icon(Icons.shield_outlined, size: 16),
                  label: Text('근거 수준 ${_evidenceLabelKo(food.evidenceLevel)}'),
                ),
                Chip(
                  avatar: const Icon(Icons.event_note_outlined, size: 16),
                  label: Text('검토일 ${food.reviewedAt}'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...food.sources.map((source) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SourceItem(
                  source: source,
                  onOpen: source.url == null
                      ? null
                      : () => _openSourceUrl(context, source.url!),
                ),
              );
            }),
            const SizedBox(height: 2),
            Text(
              '본 내용은 참고 정보이며 진단/치료를 대체하지 않습니다.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String _evidenceLabelKo(EvidenceLevel level) {
    return switch (level) {
      EvidenceLevel.high => '높음',
      EvidenceLevel.medium => '보통',
      EvidenceLevel.low => '낮음',
    };
  }

  Future<void> _openSourceUrl(BuildContext context, String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('원문 주소가 올바르지 않습니다.')),
      );
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (opened || !context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('원문 링크를 열 수 없습니다.')),
    );
  }
}

class _SourceItem extends StatelessWidget {
  const _SourceItem({required this.source, required this.onOpen});

  final SourceReference source;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final yearLabel = source.year == null ? '' : ' (${source.year})';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.menu_book_outlined,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${source.title}$yearLabel',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          if (source.publisher != null ||
              source.authors.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              _publisherLine(source),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              Chip(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                label: Text(_sourceTypeLabel(source.type)),
              ),
              if (source.url != null)
                ActionChip(
                  avatar: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('원문 보기'),
                  onPressed: onOpen,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _sourceTypeLabel(String rawType) {
    return switch (rawType) {
      'reference' => '참고문헌',
      'hospital-guide' => '동물병원 가이드',
      'education-guide' => '교육 가이드',
      'veterinary-article' => '수의학 아티클',
      'welfare-guide' => '복지기관 가이드',
      _ => '참고 자료',
    };
  }

  String _publisherLine(SourceReference source) {
    final authorLabel = source.authors.isEmpty ? '' : source.authors.join(', ');
    if (source.publisher == null || source.publisher!.trim().isEmpty) {
      return authorLabel;
    }
    if (authorLabel.isEmpty) {
      return source.publisher!;
    }
    return '${source.publisher!} · $authorLabel';
  }
}
