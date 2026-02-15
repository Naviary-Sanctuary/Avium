import '../../core/types/avium_types.dart';

class SafetyCondition {
  const SafetyCondition({
    required this.labelKo,
    required this.part,
    required this.prep,
    required this.level,
    required this.noteKo,
    this.sourceIndexes = const <int>[],
  });

  final String labelKo;
  final PartType part;
  final PrepType prep;
  final SafetyLevel level;
  final String noteKo;
  final List<int> sourceIndexes;

  factory SafetyCondition.fromJson(Map<String, dynamic> json) {
    return SafetyCondition(
      labelKo: json['labelKo'] as String,
      part: PartType.fromJson(json['part'] as String),
      prep: PrepType.fromJson(json['prep'] as String),
      level: SafetyLevel.fromJson(json['level'] as String),
      noteKo: json['noteKo'] as String,
      sourceIndexes:
          (json['sourceIndexes'] as List<dynamic>? ?? const <dynamic>[])
              .map((value) => value is int ? value : int.parse('$value'))
              .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'labelKo': labelKo,
      'part': part.name,
      'prep': prep.name,
      'level': level.name,
      'noteKo': noteKo,
      if (sourceIndexes.isNotEmpty) 'sourceIndexes': sourceIndexes,
    };
  }
}
