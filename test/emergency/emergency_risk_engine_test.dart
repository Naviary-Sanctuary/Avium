import 'package:avium/core/types/avium_types.dart';
import 'package:avium/features/emergency/domain/emergency_risk_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = EmergencyRiskEngine();

  test('rule 1: trigger symptom forces high', () {
    final result = engine.evaluate(
      baseRisk: EmergencyRiskLevel.low,
      timeBucket: TimeBucket.justNow,
      selectedSymptoms: const <String>{'호흡 이상'},
    );

    expect(result.riskLevel, EmergencyRiskLevel.high);
  });

  test('rule 2: high base risk keeps high', () {
    final result = engine.evaluate(
      baseRisk: EmergencyRiskLevel.high,
      timeBucket: TimeBucket.within1h,
      selectedSymptoms: const <String>{},
    );

    expect(result.riskLevel, EmergencyRiskLevel.high);
  });

  test('rule 3: medium base risk with 2+ symptoms becomes high', () {
    final result = engine.evaluate(
      baseRisk: EmergencyRiskLevel.medium,
      timeBucket: TimeBucket.within6h,
      selectedSymptoms: const <String>{'식욕 저하', '묽은 변'},
    );

    expect(result.riskLevel, EmergencyRiskLevel.high);
  });

  test('rule 4: medium base risk with 1 symptom keeps medium', () {
    final result = engine.evaluate(
      baseRisk: EmergencyRiskLevel.medium,
      timeBucket: TimeBucket.within1h,
      selectedSymptoms: const <String>{'식욕 저하'},
    );

    expect(result.riskLevel, EmergencyRiskLevel.medium);
  });

  test('rule 5: low base risk with 2+ symptoms becomes medium', () {
    final result = engine.evaluate(
      baseRisk: EmergencyRiskLevel.low,
      timeBucket: TimeBucket.within1h,
      selectedSymptoms: const <String>{'식욕 저하', '묽은 변'},
    );

    expect(result.riskLevel, EmergencyRiskLevel.medium);
  });

  test('rule 6: otherwise keep base risk', () {
    final result = engine.evaluate(
      baseRisk: EmergencyRiskLevel.low,
      timeBucket: TimeBucket.within6h,
      selectedSymptoms: const <String>{},
    );

    expect(result.riskLevel, EmergencyRiskLevel.low);
  });

  test('unknown time adds conservative recommendation text', () {
    final result = engine.evaluate(
      baseRisk: EmergencyRiskLevel.low,
      timeBucket: TimeBucket.unknown,
      selectedSymptoms: const <String>{},
    );

    expect(result.isTimeUnknownConservative, isTrue);
    expect(result.recommendation, contains('섭취 시간을 모르면'));
  });
}
