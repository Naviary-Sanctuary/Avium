import 'package:flutter/material.dart';

class MixedProcessedWarningBanner extends StatelessWidget {
  const MixedProcessedWarningBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            Text(
              '혼합/가공식품 주의',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text('• 혼합/가공식품은 성분·첨가물·염분·지방이 변동될 수 있습니다.'),
            Text('• 문제가 되는 성분군이 섞이기 쉬워 보수적 판단이 필요합니다.'),
            Text('• 조합이 불명확하면 급여하지 않는 것을 기본으로 하세요.'),
            Text('• 확신이 없거나 증상이 있으면 진료기관 문의를 권장합니다.'),
          ],
        ),
      ),
    );
  }
}
