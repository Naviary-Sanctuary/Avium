import 'package:flutter/material.dart';

class MedicalDisclaimerBanner extends StatelessWidget {
  const MedicalDisclaimerBanner({required this.reviewedAt, super.key});

  final String reviewedAt;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        Text('검토: $reviewedAt'),
        Tooltip(
          message: '탭하면 참고 안내를 확인할 수 있습니다.',
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
            onPressed: () => _showDisclaimerBottomSheet(context),
            icon: const Icon(Icons.info_outline, size: 16),
            label: const Text('참고정보 보기'),
          ),
        ),
      ],
    );
  }

  Future<void> _showDisclaimerBottomSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '참고 안내',
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('콘텐츠 마지막 검토일: $reviewedAt'),
                const SizedBox(height: 8),
                const Text('• 이 정보는 참고용입니다.'),
                const Text('• 진단/치료/처방을 대신하지 않습니다.'),
                const Text('• 이상 증상이 있으면 즉시 진료기관에 문의하세요.'),
              ],
            ),
          ),
        );
      },
    );
  }
}
