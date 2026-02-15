import 'dart:convert';

import 'package:avium/data/repositories/asset_food_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads and expands foods with part-based ids', () async {
    final repository = AssetFoodRepository(
      assetBundle: _FakeAssetBundle(_sampleDbJson),
    );

    final db = await repository.loadDb();
    final names = db.foods.map((food) => food.nameKo).toList(growable: false);

    expect(names, contains('사과 (과육)'));
    expect(names, contains('사과 (씨앗)'));
    expect(repository.getById('foodApple__flesh'), isNotNull);
    expect(repository.getById('foodApple__seeds'), isNotNull);
  });
}

class _FakeAssetBundle extends CachingAssetBundle {
  _FakeAssetBundle(this._rawJson);

  final String _rawJson;

  @override
  Future<ByteData> load(String key) {
    throw UnimplementedError();
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return _rawJson;
  }

  @override
  Future<ImmutableBuffer> loadBuffer(String key) {
    throw UnimplementedError();
  }
}

final String _sampleDbJson = jsonEncode(
  <String, dynamic>{
    'meta': <String, dynamic>{
      'dataVersion': '1.2.0',
      'reviewedAt': '2026-02-15',
      'distributionPolicyKo': <String>[],
    },
    'foods': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'foodApple',
        'nameKo': '사과',
        'nameEn': 'Apple',
        'aliases': <String>['apple', '사과'],
        'category': 'fruit',
        'foodType': 'whole',
        'safetyLevel': 'caution',
        'oneLinerKo': '사과 테스트',
        'reasonKo': <String>['테스트 이유'],
        'riskNotesKo': <String>['테스트 주의'],
        'safetyConditions': <Map<String, dynamic>>[
          <String, dynamic>{
            'labelKo': '과육(생)',
            'part': 'flesh',
            'prep': 'raw',
            'level': 'safe',
            'noteKo': '과육은 소량 급여 가능',
          },
          <String, dynamic>{
            'labelKo': '씨앗(모든 형태)',
            'part': 'seeds',
            'prep': 'any',
            'level': 'danger',
            'noteKo': '씨앗은 급여 금지',
          },
        ],
        'portionsKo': <String, dynamic>{
          'allowedParts': <String>['과육'],
          'avoidParts': <String>['씨앗'],
          'frequency': '가끔 소량',
          'notes': <String>[],
          'examplesKo': <String>[],
        },
        'confusables': <Map<String, dynamic>>[],
        'evidenceLevel': 'medium',
        'reviewedAt': '2026-02-15',
        'sources': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'test',
            'title': 'test',
            'year': 2026,
            'url': 'https://example.com',
          },
        ],
        'search': <String, dynamic>{
          'tokens': <String>['사과', 'apple'],
        },
        'emergency': <String, dynamic>{
          'baseRisk': 'medium',
          'whatToDoKo': <String>['테스트'],
          'watchForKo': <String>['테스트'],
          'escalationTriggersKo': <String>['테스트'],
        },
      },
    ],
  },
);
