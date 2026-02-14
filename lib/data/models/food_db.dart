import 'food_item.dart';

class FoodDbMeta {
  const FoodDbMeta({
    required this.dataVersion,
    required this.reviewedAt,
    required this.distributionPolicyKo,
  });

  final String dataVersion;
  final String reviewedAt;
  final List<String> distributionPolicyKo;

  factory FoodDbMeta.fromJson(Map<String, dynamic> json) {
    return FoodDbMeta(
      dataVersion: json['dataVersion'] as String,
      reviewedAt: json['reviewedAt'] as String,
      distributionPolicyKo:
          (json['distributionPolicyKo'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'dataVersion': dataVersion,
      'reviewedAt': reviewedAt,
      'distributionPolicyKo': distributionPolicyKo,
    };
  }
}

class FoodDb {
  const FoodDb({required this.meta, required this.foods});

  final FoodDbMeta meta;
  final List<FoodItem> foods;

  factory FoodDb.fromJson(Map<String, dynamic> json) {
    return FoodDb(
      meta: FoodDbMeta.fromJson(
        Map<String, dynamic>.from(json['meta'] as Map<dynamic, dynamic>),
      ),
      foods: (json['foods'] as List<dynamic>)
          .map((item) {
            return FoodItem.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            );
          })
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'meta': meta.toJson(),
      'foods': foods.map((item) => item.toJson()).toList(),
    };
  }
}
