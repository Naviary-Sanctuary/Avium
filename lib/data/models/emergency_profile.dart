import '../../core/types/avium_types.dart';

class EmergencyProfile {
  const EmergencyProfile({
    required this.baseRisk,
    required this.whatToDoKo,
    required this.watchForKo,
    required this.escalationTriggersKo,
  });

  final EmergencyRiskLevel baseRisk;
  final List<String> whatToDoKo;
  final List<String> watchForKo;
  final List<String> escalationTriggersKo;

  factory EmergencyProfile.fromJson(Map<String, dynamic> json) {
    return EmergencyProfile(
      baseRisk: EmergencyRiskLevel.fromJson(json['baseRisk'] as String),
      whatToDoKo: (json['whatToDoKo'] as List<dynamic>).cast<String>(),
      watchForKo: (json['watchForKo'] as List<dynamic>).cast<String>(),
      escalationTriggersKo:
          (json['escalationTriggersKo'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'baseRisk': baseRisk.name,
      'whatToDoKo': whatToDoKo,
      'watchForKo': watchForKo,
      'escalationTriggersKo': escalationTriggersKo,
    };
  }
}
