import '../models/food_db.dart';
import '../models/food_item.dart';

abstract class FoodRepository {
  Future<FoodDb> loadDb();

  List<FoodItem> search(String query);

  List<String> suggest(String query, {int limit = 5});

  FoodItem? getById(String id);
}
