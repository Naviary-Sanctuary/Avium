class PortionGuide {
  const PortionGuide({
    required this.allowedParts,
    required this.avoidParts,
    required this.frequency,
    required this.notes,
    required this.examplesKo,
  });

  final List<String> allowedParts;
  final List<String> avoidParts;
  final String frequency;
  final List<String> notes;
  final List<String> examplesKo;

  factory PortionGuide.fromJson(Map<String, dynamic> json) {
    return PortionGuide(
      allowedParts: (json['allowedParts'] as List<dynamic>).cast<String>(),
      avoidParts: (json['avoidParts'] as List<dynamic>).cast<String>(),
      frequency: json['frequency'] as String,
      notes: (json['notes'] as List<dynamic>).cast<String>(),
      examplesKo: (json['examplesKo'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'allowedParts': allowedParts,
      'avoidParts': avoidParts,
      'frequency': frequency,
      'notes': notes,
      'examplesKo': examplesKo,
    };
  }
}
