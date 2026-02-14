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

  String get labelKo {
    switch (this) {
      case EmergencyRiskLevel.low:
        return '낮음';
      case EmergencyRiskLevel.medium:
        return '보통';
      case EmergencyRiskLevel.high:
        return '높음';
    }
  }

  int get severity {
    switch (this) {
      case EmergencyRiskLevel.low:
        return 0;
      case EmergencyRiskLevel.medium:
        return 1;
      case EmergencyRiskLevel.high:
        return 2;
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

  String get labelKo {
    return switch (this) {
      PartType.flesh => '과육',
      PartType.seeds => '씨앗',
      PartType.peel => '껍질',
      PartType.pit => '씨',
      PartType.leaf => '잎',
      PartType.stem => '줄기',
      PartType.sprout => '새싹',
      PartType.unknown => '기타',
    };
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

  String get labelKo {
    return switch (this) {
      PrepType.raw => '생',
      PrepType.cooked => '익힘',
      PrepType.dried => '건조',
      PrepType.juice => '주스',
      PrepType.any => '조리/형태 무관',
    };
  }
}

enum TimeBucket {
  justNow,
  within1h,
  within6h,
  unknown,
}
