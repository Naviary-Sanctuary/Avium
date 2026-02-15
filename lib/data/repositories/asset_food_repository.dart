import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/food_db.dart';
import '../models/food_item.dart';
import '../search/search_service.dart';
import 'food_repository.dart';

class AssetFoodRepository implements FoodRepository {
  AssetFoodRepository({
    this.assetPath = 'assets/data/foods.v1_2_0.json',
    AssetBundle? assetBundle,
    SearchService? searchService,
  })  : _assetBundle = assetBundle ?? rootBundle,
        _searchService = searchService ?? const SearchService();

  final String assetPath;
  final AssetBundle _assetBundle;
  final SearchService _searchService;

  FoodDb? _db;

  @override
  Future<FoodDb> loadDb() async {
    if (_db != null) {
      return _db!;
    }

    final rawJson = await _assetBundle.loadString(assetPath);
    final map = jsonDecode(rawJson) as Map<String, dynamic>;
    _db = FoodDb.fromJson(map);
    return _db!;
  }

  @override
  FoodItem? getById(String id) {
    final db = _db;
    if (db == null) {
      return null;
    }

    for (final food in db.foods) {
      if (food.id == id) {
        return food;
      }
    }
    return null;
  }

  @override
  List<FoodItem> search(String query) {
    final db = _db;
    if (db == null) {
      return const <FoodItem>[];
    }
    return _searchService.search(db.foods, query);
  }

  @override
  List<String> suggest(String query, {int limit = 5}) {
    final db = _db;
    if (db == null) {
      return const <String>[];
    }
    return _searchService.suggest(db.foods, query, limit: limit);
  }
}
