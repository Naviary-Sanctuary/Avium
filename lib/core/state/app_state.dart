import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/food_db.dart';
import '../../data/models/food_item.dart';
import '../../data/repositories/asset_food_repository.dart';
import '../../data/repositories/food_repository.dart';

typedef PreferencesLoader = Future<SharedPreferences?> Function();

class AppState extends ChangeNotifier {
  AppState({
    FoodRepository? repository,
    PreferencesLoader? preferencesLoader,
  })  : _repository = repository ?? AssetFoodRepository(),
        _preferencesLoader = preferencesLoader ?? _defaultPreferencesLoader;

  static const String _disclaimerSeenKey = 'has_seen_initial_disclaimer_v2';

  final FoodRepository _repository;
  final PreferencesLoader _preferencesLoader;

  FoodDb? _db;
  String _query = '';
  bool _isInitializing = false;
  bool _hasSeenInitialDisclaimer = false;
  SharedPreferences? _preferences;
  Object? _error;

  bool get isInitializing => _isInitializing;
  Object? get error => _error;
  String get query => _query;
  FoodDbMeta? get meta => _db?.meta;
  List<FoodItem> get allFoods => _db?.foods ?? const <FoodItem>[];
  bool get hasSeenInitialDisclaimer => _hasSeenInitialDisclaimer;

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
      _preferences ??= await _preferencesLoader();
      _hasSeenInitialDisclaimer =
          _preferences?.getBool(_disclaimerSeenKey) ?? false;
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

  void markInitialDisclaimerSeen() {
    if (_hasSeenInitialDisclaimer) {
      return;
    }
    _hasSeenInitialDisclaimer = true;
    _preferences?.setBool(_disclaimerSeenKey, true);
    notifyListeners();
  }

  void resetInitialDisclaimerSeen() {
    _hasSeenInitialDisclaimer = false;
    _preferences?.remove(_disclaimerSeenKey);
    notifyListeners();
  }

  FoodItem? getById(String id) {
    return _repository.getById(id);
  }

  static Future<SharedPreferences?> _defaultPreferencesLoader() async {
    return SharedPreferences.getInstance();
  }
}
