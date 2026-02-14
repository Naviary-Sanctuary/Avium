import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/state/app_state_scope.dart';
import '../../../core/types/avium_types.dart';
import '../../../data/models/food_item.dart';
import '../../food_detail/domain/safety_condition_matcher.dart';
import '../domain/emergency_risk_engine.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key, this.foodId});

  final String? foodId;

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  static const _engine = EmergencyRiskEngine();
  static const _conditionMatcher = SafetyConditionMatcher();

  TimeBucket _timeBucket = TimeBucket.justNow;
  PartType? _partType;
  PrepType? _prepType;
  final Set<String> _selectedSymptoms = <String>{};

  static const List<String> _symptoms = <String>[
    '호흡 이상',
    '경련',
    '의식 저하/반응 없음',
    '급격한 무기력(움직이지 않음 수준)',
    '지속 구토/역류(반복)',
    '식욕 저하',
    '묽은 변',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedFood = _resolveFood();

    final baseRisk =
        selectedFood?.emergency.baseRisk ?? EmergencyRiskLevel.medium;
    final conditionMatch = selectedFood == null
        ? null
        : _conditionMatcher.match(
            representativeLevel: selectedFood.safetyLevel,
            conditions: selectedFood.safetyConditions,
            selectedPart: _partType,
            selectedPrep: _prepType,
          );
    final adjustedRisk = _adjustedBaseRisk(
      baseRisk: baseRisk,
      conditionMatch: conditionMatch,
    );
    final conditionNotice = _buildConditionNotice(
      selectedFood: selectedFood,
      baseRisk: baseRisk,
      adjustedRisk: adjustedRisk,
      conditionMatch: conditionMatch,
    );

    final assessment = _engine.evaluate(
      baseRisk: adjustedRisk,
      timeBucket: _timeBucket,
      selectedSymptoms: _selectedSymptoms,
    );

    final actions = selectedFood?.emergency.whatToDoKo ??
        const <String>[
          '추가 섭취를 막고 상태 변화를 관찰하세요.',
          '불안하거나 증상이 있으면 진료기관 문의를 권장합니다.',
        ];
    final watchFor = selectedFood?.emergency.watchForKo ??
        const <String>['호흡 이상', '경련', '무기력', '구토/역류'];
    final triggers = selectedFood?.emergency.escalationTriggersKo ??
        const <String>['호흡 이상, 경련, 반응 저하가 있으면 즉시 문의를 권장합니다.'];
    final shouldShowAssessment =
        selectedFood != null || _selectedSymptoms.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('긴급 대응 확인')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    '조류 진료 가능 병원/수의사 연락을 권장합니다.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text('증상이 없더라도 불안하면 바로 문의하세요.'),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () => _openHospitalFinder(context),
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('주변 앵무새 병원 찾기'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _TimeBucketField(
            value: _timeBucket,
            onChanged: (value) {
              setState(() {
                _timeBucket = value;
              });
            },
          ),
          if (selectedFood != null && selectedFood.safetyConditions.isNotEmpty)
            _ConditionInput(
              food: selectedFood,
              selectedPart: _partType,
              selectedPrep: _prepType,
              onPartChanged: (value) {
                setState(() {
                  _partType = value;
                });
              },
              onPrepChanged: (value) {
                setState(() {
                  _prepType = value;
                });
              },
            ),
          const SizedBox(height: 16),
          Text('증상 체크(선택)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._symptoms.map((symptom) {
            final checked = _selectedSymptoms.contains(symptom);
            return CheckboxListTile(
              dense: true,
              value: checked,
              title: Text(symptom),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedSymptoms.add(symptom);
                  } else {
                    _selectedSymptoms.remove(symptom);
                  }
                });
              },
            );
          }),
          const SizedBox(height: 8),
          const Text(
            '증상/섭취 시간을 바꾸면 결과가 바로 갱신됩니다.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (shouldShowAssessment)
            _AssessmentCard(
              assessment: assessment,
              actions: actions,
              watchFor: watchFor,
              triggers: triggers,
              conditionNotice: conditionNotice,
            )
          else
            const _AssessmentHintCard(),
        ],
      ),
    );
  }

  EmergencyRiskLevel _adjustedBaseRisk({
    required EmergencyRiskLevel baseRisk,
    required SafetyConditionMatchResult? conditionMatch,
  }) {
    if (conditionMatch == null || !conditionMatch.isComplete) {
      return baseRisk;
    }

    final floorByCondition = switch (conditionMatch.resolvedLevel) {
      SafetyLevel.safe => EmergencyRiskLevel.low,
      SafetyLevel.caution => EmergencyRiskLevel.medium,
      SafetyLevel.danger => EmergencyRiskLevel.high,
    };

    if (floorByCondition.severity > baseRisk.severity) {
      return floorByCondition;
    }
    return baseRisk;
  }

  String? _buildConditionNotice({
    required FoodItem? selectedFood,
    required EmergencyRiskLevel baseRisk,
    required EmergencyRiskLevel adjustedRisk,
    required SafetyConditionMatchResult? conditionMatch,
  }) {
    if (selectedFood == null || selectedFood.safetyConditions.isEmpty) {
      return null;
    }
    if (conditionMatch == null || !conditionMatch.isComplete) {
      return '부위와 형태·조리를 모두 선택하면 위험도에 반영됩니다.';
    }
    if (adjustedRisk.severity > baseRisk.severity) {
      return '선택한 조건을 반영해 위험도를 보수적으로 상향했습니다.';
    }
    return '선택한 조건을 반영해 위험도를 계산했습니다.';
  }

  FoodItem? _resolveFood() {
    final state = AppStateScope.of(context);
    final id = widget.foodId;
    if (id == null) {
      return null;
    }
    return state.getById(id);
  }

  Future<void> _openHospitalFinder(BuildContext context) async {
    final uri = Uri.parse('https://www.angmorning.com/hospitals/');
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (opened || !context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('병원 찾기 페이지를 열 수 없습니다.')),
    );
  }
}

class _TimeBucketField extends StatelessWidget {
  const _TimeBucketField({required this.value, required this.onChanged});

  final TimeBucket value;
  final ValueChanged<TimeBucket> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<TimeBucket>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: '섭취 시간(선택)',
        border: OutlineInputBorder(),
      ),
      items: TimeBucket.values.map((bucket) {
        return DropdownMenuItem<TimeBucket>(
          value: bucket,
          child: Text(_bucketLabel(bucket)),
        );
      }).toList(growable: false),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }

  String _bucketLabel(TimeBucket bucket) {
    return switch (bucket) {
      TimeBucket.justNow => '방금',
      TimeBucket.within1h => '1시간 이내',
      TimeBucket.within6h => '6시간 이내',
      TimeBucket.unknown => '모름',
    };
  }
}

class _ConditionInput extends StatelessWidget {
  const _ConditionInput({
    required this.food,
    required this.selectedPart,
    required this.selectedPrep,
    required this.onPartChanged,
    required this.onPrepChanged,
  });

  final FoodItem food;
  final PartType? selectedPart;
  final PrepType? selectedPrep;
  final ValueChanged<PartType?> onPartChanged;
  final ValueChanged<PrepType?> onPrepChanged;

  @override
  Widget build(BuildContext context) {
    final parts = food.safetyConditions
        .map((condition) => condition.part)
        .toSet()
        .toList(growable: false)
      ..sort((a, b) => a.index.compareTo(b.index));
    final preps = food.safetyConditions
        .map((condition) => condition.prep)
        .toSet()
        .toList(growable: false)
      ..sort((a, b) => a.index.compareTo(b.index));

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: <Widget>[
          DropdownButtonFormField<PartType>(
            initialValue: selectedPart,
            hint: const Text('부위 선택(선택)'),
            items: parts
                .map(
                  (part) => DropdownMenuItem<PartType>(
                    value: part,
                    child: Text(part.labelKo),
                  ),
                )
                .toList(growable: false),
            onChanged: onPartChanged,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<PrepType>(
            initialValue: selectedPrep,
            hint: const Text('형태·조리 선택(선택)'),
            items: preps
                .map(
                  (prep) => DropdownMenuItem<PrepType>(
                    value: prep,
                    child: Text(prep.labelKo),
                  ),
                )
                .toList(growable: false),
            onChanged: onPrepChanged,
          ),
        ],
      ),
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({
    required this.assessment,
    required this.actions,
    required this.watchFor,
    required this.triggers,
    required this.conditionNotice,
  });

  final EmergencyAssessment assessment;
  final List<String> actions;
  final List<String> watchFor;
  final List<String> triggers;
  final String? conditionNotice;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '위험도: ${assessment.riskLevel.labelKo}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(assessment.recommendation),
            if (conditionNotice != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(conditionNotice!),
              ),
            if (assessment.isTimeUnknownConservative)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text('시간 모름 상태로 보수적 권고를 추가했습니다.'),
              ),
            const SizedBox(height: 12),
            Text('즉시 행동 가이드', style: Theme.of(context).textTheme.titleSmall),
            ...actions.take(3).toList().asMap().entries.map((entry) {
              final index = entry.key + 1;
              return Text('$index. ${entry.value}');
            }),
            const SizedBox(height: 8),
            Text('관찰 체크', style: Theme.of(context).textTheme.titleSmall),
            ...watchFor.map((item) => Text('• $item')),
            const SizedBox(height: 8),
            Text('즉시 진료 권고 기준', style: Theme.of(context).textTheme.titleSmall),
            ...triggers.map((item) => Text('• $item')),
            const SizedBox(height: 8),
            const Text(
              '가정 처치/투약/구토 유도/치료법 안내는 제공하지 않습니다.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssessmentHintCard extends StatelessWidget {
  const _AssessmentHintCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            Icon(Icons.info_outline),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                '증상을 먼저 선택하면 긴급 권고가 표시됩니다.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
