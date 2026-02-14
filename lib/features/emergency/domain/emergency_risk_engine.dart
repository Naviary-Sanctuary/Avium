import '../../../core/types/avium_types.dart';

class EmergencyAssessment {
  const EmergencyAssessment({
    required this.riskLevel,
    required this.recommendation,
    required this.isTimeUnknownConservative,
  });

  final EmergencyRiskLevel riskLevel;
  final String recommendation;
  final bool isTimeUnknownConservative;
}

class EmergencyRiskEngine {
  const EmergencyRiskEngine();

  static const triggerSymptoms = <String>{
    '호흡 이상',
    '경련',
    '의식 저하/반응 없음',
    '급격한 무기력(움직이지 않음 수준)',
    '지속 구토/역류(반복)',
  };

  EmergencyAssessment evaluate({
    required EmergencyRiskLevel baseRisk,
    required TimeBucket timeBucket,
    required Set<String> selectedSymptoms,
  }) {
    final hasTriggerSymptom =
        selectedSymptoms.any((symptom) => triggerSymptoms.contains(symptom));
    final symptomCount = selectedSymptoms.length;

    final level = _calculateRiskLevel(
      baseRisk: baseRisk,
      hasTriggerSymptom: hasTriggerSymptom,
      symptomCount: symptomCount,
    );

    final conservativeByUnknownTime = timeBucket == TimeBucket.unknown;
    final recommendation = _recommendationText(
      level,
      conservativeByUnknownTime: conservativeByUnknownTime,
    );

    return EmergencyAssessment(
      riskLevel: level,
      recommendation: recommendation,
      isTimeUnknownConservative: conservativeByUnknownTime,
    );
  }

  EmergencyRiskLevel _calculateRiskLevel({
    required EmergencyRiskLevel baseRisk,
    required bool hasTriggerSymptom,
    required int symptomCount,
  }) {
    if (hasTriggerSymptom) {
      return EmergencyRiskLevel.high;
    }
    if (baseRisk == EmergencyRiskLevel.high) {
      return EmergencyRiskLevel.high;
    }
    if (baseRisk == EmergencyRiskLevel.medium && symptomCount >= 2) {
      return EmergencyRiskLevel.high;
    }
    if (baseRisk == EmergencyRiskLevel.medium && symptomCount == 1) {
      return EmergencyRiskLevel.medium;
    }
    if (baseRisk == EmergencyRiskLevel.low && symptomCount >= 2) {
      return EmergencyRiskLevel.medium;
    }
    return baseRisk;
  }

  String _recommendationText(
    EmergencyRiskLevel level, {
    required bool conservativeByUnknownTime,
  }) {
    final core = switch (level) {
      EmergencyRiskLevel.low => '우선 상태를 관찰하고 변화가 있으면 문의하세요.',
      EmergencyRiskLevel.medium => '가능한 빠르게 조류 진료 가능 기관 문의를 권장합니다.',
      EmergencyRiskLevel.high => '지체하지 말고 조류 진료 가능 기관에 즉시 연락하세요.',
    };

    if (!conservativeByUnknownTime) {
      return core;
    }

    return '$core 섭취 시간을 모르면 더 보수적으로 대응하세요.';
  }
}
