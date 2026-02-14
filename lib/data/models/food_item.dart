import '../../core/types/avium_types.dart';
import 'confusable_item.dart';
import 'emergency_profile.dart';
import 'portion_guide.dart';
import 'safety_condition.dart';
import 'source_reference.dart';

class FoodItem {
  const FoodItem({
    required this.id,
    required this.nameKo,
    required this.nameEn,
    required this.aliases,
    required this.category,
    required this.foodType,
    required this.safetyLevel,
    required this.oneLinerKo,
    required this.reasonKo,
    required this.riskNotesKo,
    required this.safetyConditions,
    required this.portionsKo,
    required this.confusables,
    required this.evidenceLevel,
    required this.reviewedAt,
    required this.sources,
    required this.searchTokens,
    required this.emergency,
  });

  final String id;
  final String nameKo;
  final String nameEn;
  final List<String> aliases;
  final String category;
  final FoodType foodType;
  final SafetyLevel safetyLevel;
  final String oneLinerKo;
  final List<String> reasonKo;
  final List<String> riskNotesKo;
  final List<SafetyCondition> safetyConditions;
  final PortionGuide portionsKo;
  final List<ConfusableItem> confusables;
  final EvidenceLevel evidenceLevel;
  final String reviewedAt;
  final List<SourceReference> sources;
  final List<String> searchTokens;
  final EmergencyProfile emergency;

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    final search = Map<String, dynamic>.from(
      json['search'] as Map<dynamic, dynamic>,
    );
    return FoodItem(
      id: json['id'] as String,
      nameKo: json['nameKo'] as String,
      nameEn: json['nameEn'] as String,
      aliases: (json['aliases'] as List<dynamic>).cast<String>(),
      category: json['category'] as String,
      foodType: FoodType.fromJson(json['foodType'] as String),
      safetyLevel: SafetyLevel.fromJson(json['safetyLevel'] as String),
      oneLinerKo: json['oneLinerKo'] as String,
      reasonKo: (json['reasonKo'] as List<dynamic>).cast<String>(),
      riskNotesKo: (json['riskNotesKo'] as List<dynamic>).cast<String>(),
      safetyConditions: (json['safetyConditions'] as List<dynamic>)
          .map((item) {
            return SafetyCondition.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            );
          })
          .toList(),
      portionsKo: PortionGuide.fromJson(
        Map<String, dynamic>.from(
          json['portionsKo'] as Map<dynamic, dynamic>,
        ),
      ),
      confusables: (json['confusables'] as List<dynamic>)
          .map((item) {
            return ConfusableItem.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            );
          })
          .toList(),
      evidenceLevel: EvidenceLevel.fromJson(json['evidenceLevel'] as String),
      reviewedAt: json['reviewedAt'] as String,
      sources: (json['sources'] as List<dynamic>)
          .map((item) {
            return SourceReference.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            );
          })
          .toList(),
      searchTokens: (search['tokens'] as List<dynamic>).cast<String>(),
      emergency: EmergencyProfile.fromJson(
        Map<String, dynamic>.from(
          json['emergency'] as Map<dynamic, dynamic>,
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'nameKo': nameKo,
      'nameEn': nameEn,
      'aliases': aliases,
      'category': category,
      'foodType': foodType.name,
      'safetyLevel': safetyLevel.name,
      'oneLinerKo': oneLinerKo,
      'reasonKo': reasonKo,
      'riskNotesKo': riskNotesKo,
      'safetyConditions': safetyConditions.map((item) => item.toJson()).toList(),
      'portionsKo': portionsKo.toJson(),
      'confusables': confusables.map((item) => item.toJson()).toList(),
      'evidenceLevel': evidenceLevel.name,
      'reviewedAt': reviewedAt,
      'sources': sources.map((item) => item.toJson()).toList(),
      'search': <String, dynamic>{
        'tokens': searchTokens,
      },
      'emergency': emergency.toJson(),
    };
  }
}
