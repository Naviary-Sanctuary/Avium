import 'dart:convert';
import 'dart:io';

import 'package:avium/data/models/food_db.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FoodDb db;

  setUpAll(() async {
    final file = File('assets/data/foods.json');
    final raw = await file.readAsString();
    final map = jsonDecode(raw) as Map<String, dynamic>;
    db = FoodDb.fromJson(map);
  });

  test('oneLinerKo count and uniqueness are preserved', () {
    final oneLiners = db.foods.map((food) => food.oneLinerKo).toList();
    expect(oneLiners.length, 261);
    expect(oneLiners.toSet().length, oneLiners.length);
  });

  test('oneLinerKo does not include banned fixed templates', () {
    const bannedPhrases = <String>[
      '주의 급여가 필요합니다.',
      '과육은 주의 급여가 필요합니다.',
      '급여 금지입니다.',
    ];

    for (final food in db.foods) {
      for (final phrase in bannedPhrases) {
        expect(
          food.oneLinerKo.contains(phrase),
          isFalse,
          reason: '${food.id} includes banned phrase: $phrase',
        );
      }
    }
  });

  test('oneLinerKo does not start with name + 은/는 pattern', () {
    final leadingTopicMarker = RegExp(r'^[가-힣A-Za-z0-9()\\-]+(?:은|는)\\s');

    for (final food in db.foods) {
      expect(
        leadingTopicMarker.hasMatch(food.oneLinerKo),
        isFalse,
        reason: '${food.id} starts with forbidden topic marker',
      );
    }
  });

  test('danger items use high baseRisk', () {
    for (final food
        in db.foods.where((item) => item.safetyLevel.name == 'danger')) {
      expect(
        food.emergency.baseRisk.name,
        'high',
        reason: '${food.id} is danger but baseRisk is not high',
      );
    }
  });

  test('agreed processed-food safety overrides are preserved', () {
    final byId = {for (final food in db.foods) food.id: food};

    expect(byId['foodBread']?.safetyLevel.name, 'caution');
    expect(byId['foodJam']?.safetyLevel.name, 'caution');
    expect(byId['foodPasta']?.safetyLevel.name, 'safe');
    expect(byId['foodCouscous']?.safetyLevel.name, 'safe');
  });

  test('agreed nut and tofu overrides are preserved', () {
    final byId = {for (final food in db.foods) food.id: food};

    const expected = <String, ({String level, String baseRisk})>{
      'foodWalnut': (level: 'safe', baseRisk: 'low'),
      'foodCashew': (level: 'safe', baseRisk: 'low'),
      'foodHazelnut': (level: 'safe', baseRisk: 'low'),
      'foodPecan': (level: 'safe', baseRisk: 'low'),
      'foodPistachio': (level: 'safe', baseRisk: 'low'),
      'foodPeanutInShell': (level: 'safe', baseRisk: 'low'),
      'foodTofu': (level: 'safe', baseRisk: 'low'),
      'foodPeanut': (level: 'safe', baseRisk: 'low'),
      'foodMixedNuts': (level: 'caution', baseRisk: 'medium'),
      'foodTempeh': (level: 'caution', baseRisk: 'medium'),
    };

    for (final entry in expected.entries) {
      final item = byId[entry.key];
      expect(item, isNotNull, reason: '${entry.key} is missing');
      expect(
        item?.safetyLevel.name,
        entry.value.level,
        reason: '${entry.key} safetyLevel mismatch',
      );
      expect(
        item?.emergency.baseRisk.name,
        entry.value.baseRisk,
        reason: '${entry.key} baseRisk mismatch',
      );
    }
  });

  test('oxalate leafy greens remain caution', () {
    final byId = {for (final food in db.foods) food.id: food};
    const oxalateLeafyIds = <String>[
      'foodSpinach',
      'foodSilverBeet',
      'foodMustardGreens',
      'foodTurnipGreens',
      'foodBeetGreens',
    ];

    for (final id in oxalateLeafyIds) {
      expect(
        byId[id]?.safetyLevel.name,
        'caution',
        reason: '$id should remain caution',
      );
    }
  });
}
