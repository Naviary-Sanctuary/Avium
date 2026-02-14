import 'dart:convert';
import 'dart:io';

import 'package:avium/data/models/food_db.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses bundled food db schema', () async {
    final file = File('assets/data/foods.v1_2_0.json');
    final raw = await file.readAsString();
    final map = jsonDecode(raw) as Map<String, dynamic>;

    final db = FoodDb.fromJson(map);

    expect(db.meta.dataVersion, '1.2.0');
    expect(db.foods.length, greaterThanOrEqualTo(30));
    expect(
      db.foods.where((food) => food.id == 'foodApple').length,
      1,
    );
  });

  test('every food has at least one traceable source url', () async {
    final file = File('assets/data/foods.v1_2_0.json');
    final raw = await file.readAsString();
    final map = jsonDecode(raw) as Map<String, dynamic>;

    final db = FoodDb.fromJson(map);

    for (final food in db.foods) {
      expect(food.sources, isNotEmpty, reason: '${food.id} has no sources');
      for (final source in food.sources) {
        expect(source.url, isNotNull, reason: '${food.id} source url missing');
        expect(
          source.url!.startsWith('https://'),
          isTrue,
          reason: '${food.id} source url is invalid',
        );
      }
    }
  });
}
