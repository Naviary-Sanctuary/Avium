import 'package:flutter/material.dart';

class MedicalDisclaimerBanner extends StatelessWidget {
  const MedicalDisclaimerBanner({required this.reviewedAt, super.key});

  final String reviewedAt;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text('검토: $reviewedAt'),
        const SizedBox(width: 8),
        Tooltip(
          message: '본 내용은 참고 정보이며 진단/치료를 대체하지 않습니다.',
          child: const Row(
            children: <Widget>[
              Icon(Icons.info_outline, size: 16),
              SizedBox(width: 4),
              Text('참고 정보'),
            ],
          ),
        ),
      ],
    );
  }
}
