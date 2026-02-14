import 'package:flutter/material.dart';

import '../../../core/state/app_state_scope.dart';
import '../../../core/types/avium_types.dart';
import '../../../data/models/food_item.dart';
import '../domain/emergency_risk_engine.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key, this.foodId});

  final String? foodId;

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  static const _engine = EmergencyRiskEngine();

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
    final assessment = _engine.evaluate(
      baseRisk: baseRisk,
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

    return Scaffold(
      appBar: AppBar(title: const Text('응급 모드')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                '조류 진료 가능 병원/수의사 연락을 권장합니다.',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '선택 음식: ${selectedFood?.nameKo ?? '음식 미상(unknownFood)'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 12),
          _AssessmentCard(
            assessment: assessment,
            actions: actions,
            watchFor: watchFor,
            triggers: triggers,
          ),
        ],
      ),
    );
  }

  FoodItem? _resolveFood() {
    final state = AppStateScope.of(context);
    final id = widget.foodId;
    if (id == null || id == 'unknownFood') {
      return null;
    }
    return state.getById(id);
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
  });

  final EmergencyAssessment assessment;
  final List<String> actions;
  final List<String> watchFor;
  final List<String> triggers;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'riskLevel: ${assessment.riskLevel.label}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(assessment.recommendation),
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
            Text('진료 권고 트리거', style: Theme.of(context).textTheme.titleSmall),
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
