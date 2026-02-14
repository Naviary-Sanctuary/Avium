import 'dart:convert';
import 'dart:io';

import 'package:avium/data/models/food_db.dart';
import 'package:avium/data/search/search_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FoodDb db;
  const service = SearchService();

  setUpAll(() async {
    final file = File('assets/data/foods.v1_2_0.json');
    final raw = await file.readAsString();
    db = FoodDb.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  });

  test('prefix match ranks first', () {
    final results = service.search(db.foods, '사과');

    expect(results.first.id, 'foodApple');
  });

  test('contains match works', () {
    final results = service.search(db.foods, '보카');

    expect(results.map((food) => food.id), contains('foodAvocado'));
  });

  test('fuzzy fallback works for typos', () {
    final results = service.search(db.foods, '아보카도오');

    expect(results.map((food) => food.id), contains('foodAvocado'));
  });
}
