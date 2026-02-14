enum SafetyLevel {
  safe,
  caution,
  danger;

  static SafetyLevel fromJson(String raw) {
    return values.firstWhere((level) => level.name == raw);
  }

  String get label {
    switch (this) {
      case SafetyLevel.safe:
        return 'Safe';
      case SafetyLevel.caution:
        return 'Caution';
      case SafetyLevel.danger:
        return 'Danger';
    }
  }

  int get severity {
    switch (this) {
      case SafetyLevel.safe:
        return 0;
      case SafetyLevel.caution:
        return 1;
      case SafetyLevel.danger:
        return 2;
    }
  }
}

enum EmergencyRiskLevel {
  low,
  medium,
  high;

  static EmergencyRiskLevel fromJson(String raw) {
    return values.firstWhere((level) => level.name == raw);
  }

  String get label {
    switch (this) {
      case EmergencyRiskLevel.low:
        return 'Low';
      case EmergencyRiskLevel.medium:
        return 'Medium';
      case EmergencyRiskLevel.high:
        return 'High';
    }
  }
}

enum FoodType {
  whole,
  mixed,
  processed;

  static FoodType fromJson(String raw) {
    return values.firstWhere((type) => type.name == raw);
  }
}

enum EvidenceLevel {
  high,
  medium,
  low;

  static EvidenceLevel fromJson(String raw) {
    return values.firstWhere((level) => level.name == raw);
  }
}

enum PartType {
  flesh,
  seeds,
  peel,
  pit,
  leaf,
  stem,
  sprout,
  unknown;

  static PartType fromJson(String raw) {
    return values.firstWhere((type) => type.name == raw);
  }
}

enum PrepType {
  raw,
  cooked,
  dried,
  juice,
  any;

  static PrepType fromJson(String raw) {
    return values.firstWhere((type) => type.name == raw);
  }
}

enum TimeBucket {
  justNow,
  within1h,
  within6h,
  unknown,
}
