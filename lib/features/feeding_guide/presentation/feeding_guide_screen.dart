import 'package:flutter/material.dart';

class FeedingGuideScreen extends StatelessWidget {
  const FeedingGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기본 급여 가이드')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          _GuideCard(
            title: '기본 종 그룹',
            lines: <String>['소형 앵무', '중형 앵무', '대형 앵무'],
          ),
          _GuideCard(
            title: '권장 비율(입문 기준)',
            lines: <String>[
              '펠렛 60~80%',
              '신선식 15~30%',
              '씨앗 5~10%',
            ],
          ),
          _GuideCard(
            title: '초보자 5가지 기본 원칙',
            lines: <String>[
              '주식은 펠렛 중심으로 유지하세요.',
              '새 식품은 한 번에 하나씩 소량 도입하세요.',
              '간식은 주식을 대체하지 않게 관리하세요.',
              '이상 반응이 보이면 즉시 중단하고 관찰하세요.',
              '불안하거나 증상이 있으면 진료기관 문의를 권장합니다.',
            ],
          ),
          _GuideCard(
            title: '이용 안내',
            lines: <String>[
              '본 가이드는 입문자를 위한 일반 원칙입니다.',
              '종/연령/질환/개체차에 따라 달라질 수 있습니다.',
              '로리/로리킷 등 식성이 뚜렷한 그룹은 별도 가이드가 필요합니다.',
            ],
          ),
          _GuideCard(
            title: '행동 가이드 예시(정량 아님)',
            lines: <String>[
              '간식으로만(주식 대체 X)',
              '처음 급여는 한 입 이하로 시작',
              '이상 반응 시 중단 및 문의 권장',
            ],
          ),
          SizedBox(height: 8),
          Text(
            '정량(그램/체중 기반/용량 계산)은 현재 제공하지 않습니다.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              ...lines.map((line) => Text('• $line')),
            ],
          ),
        ),
      ),
    );
  }
}
