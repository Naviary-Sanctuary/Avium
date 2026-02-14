import '../../core/types/avium_types.dart';

class SafetyCondition {
  const SafetyCondition({
    required this.labelKo,
    required this.part,
    required this.prep,
    required this.level,
    required this.noteKo,
  });

  final String labelKo;
  final PartType part;
  final PrepType prep;
  final SafetyLevel level;
  final String noteKo;

  factory SafetyCondition.fromJson(Map<String, dynamic> json) {
    return SafetyCondition(
      labelKo: json['labelKo'] as String,
      part: PartType.fromJson(json['part'] as String),
      prep: PrepType.fromJson(json['prep'] as String),
      level: SafetyLevel.fromJson(json['level'] as String),
      noteKo: json['noteKo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'labelKo': labelKo,
      'part': part.name,
      'prep': prep.name,
      'level': level.name,
      'noteKo': noteKo,
    };
  }
}
