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
}
