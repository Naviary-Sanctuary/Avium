import 'package:flutter/foundation.dart';

import '../../data/models/food_db.dart';
import '../../data/models/food_item.dart';
import '../../data/repositories/asset_food_repository.dart';
import '../../data/repositories/food_repository.dart';

class AppState extends ChangeNotifier {
  AppState({FoodRepository? repository})
      : _repository = repository ?? AssetFoodRepository();

  final FoodRepository _repository;

  FoodDb? _db;
  String _query = '';
  bool _isInitializing = false;
  Object? _error;

  bool get isInitializing => _isInitializing;
  Object? get error => _error;
  String get query => _query;
  FoodDbMeta? get meta => _db?.meta;

  List<FoodItem> get searchResults {
    final db = _db;
    if (db == null) {
      return const <FoodItem>[];
    }

    if (_query.trim().isEmpty) {
      return db.foods;
    }

    return _repository.search(_query);
  }

  List<String> get suggestions {
    final db = _db;
    if (db == null || _query.trim().isEmpty) {
      return const <String>[];
    }
    return _repository.suggest(_query, limit: 3);
  }

  Future<void> initialize() async {
    if (_db != null || _isInitializing) {
      return;
    }

    _isInitializing = true;
    _error = null;
    notifyListeners();

    try {
      _db = await _repository.loadDb();
    } catch (error) {
      _error = error;
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  void setQuery(String value) {
    if (_query == value) {
      return;
    }
    _query = value;
    notifyListeners();
  }

  FoodItem? getById(String id) {
    return _repository.getById(id);
  }
}
