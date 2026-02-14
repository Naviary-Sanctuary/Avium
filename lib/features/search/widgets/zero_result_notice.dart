import 'package:flutter/material.dart';

class ZeroResultNotice extends StatelessWidget {
  const ZeroResultNotice({
    required this.onOpenEmergencyUnknown,
    required this.onOpenRequestTemplate,
    required this.suggestions,
    required this.onSuggestionTap,
    super.key,
  });

  final VoidCallback onOpenEmergencyUnknown;
  final VoidCallback onOpenRequestTemplate;
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '검색 결과에 없는 음식이 안전하다는 뜻은 아닙니다.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              semanticsLabel: '중요 경고: 검색 결과에 없어도 안전을 의미하지 않습니다.',
            ),
            const SizedBox(height: 12),
            const Text(
              '성분/가공/첨가물/급여량을 확신하기 어렵다면 '
              '안전하다고 단정하지 말고 주의 깊게 살펴봐 주세요.\n'
              '불안하거나 증상이 있으면 진료기관 문의를 권장합니다.',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpenEmergencyUnknown,
                icon: const Icon(Icons.local_hospital_outlined),
                label: const Text('섭취 후 긴급 대응 확인'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onOpenRequestTemplate,
                icon: const Icon(Icons.mail_outline),
                label: const Text('정보 요청 템플릿(메일)'),
              ),
            ),
            if (suggestions.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                '비슷한 검색어',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestions
                    .map(
                      (word) => ActionChip(
                        label: Text(word),
                        onPressed: () => onSuggestionTap(word),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
