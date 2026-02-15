import 'dart:convert';

import 'package:avium/data/repositories/asset_food_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads pre-expanded data and resolves by id', () async {
    final repository = AssetFoodRepository(
      assetBundle: _FakeAssetBundle(_expandedDbJson),
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

final String _expandedDbJson = jsonEncode(
  <String, dynamic>{
    'meta': <String, dynamic>{
      'dataVersion': '1.2.0',
      'reviewedAt': '2026-02-15',
      'distributionPolicyKo': <String>[],
    },
    'foods': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'foodApple__flesh',
        'nameKo': '사과 (과육)',
        'nameEn': 'Apple (Flesh)',
        'aliases': <String>['apple', '사과', '사과 과육'],
        'category': 'fruit',
        'foodType': 'whole',
        'safetyLevel': 'safe',
        'oneLinerKo': '과육은 소량 급여 가능',
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
        ],
        'portionsKo': <String, dynamic>{
          'allowedParts': <String>['과육'],
          'avoidParts': <String>[],
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
            'title': 'flesh source',
            'year': 2026,
            'url': 'https://example.com/flesh',
          },
        ],
        'search': <String, dynamic>{
          'tokens': <String>['사과', '사과 과육', 'apple'],
        },
        'emergency': <String, dynamic>{
          'baseRisk': 'medium',
          'whatToDoKo': <String>['테스트'],
          'watchForKo': <String>['테스트'],
          'escalationTriggersKo': <String>['테스트'],
        },
      },
      <String, dynamic>{
        'id': 'foodApple__seeds',
        'nameKo': '사과 (씨앗)',
        'nameEn': 'Apple (Seeds)',
        'aliases': <String>['apple', '사과', '사과 씨앗'],
        'category': 'fruit',
        'foodType': 'whole',
        'safetyLevel': 'danger',
        'oneLinerKo': '씨앗은 급여 금지',
        'reasonKo': <String>['테스트 이유'],
        'riskNotesKo': <String>['테스트 주의'],
        'safetyConditions': <Map<String, dynamic>>[
          <String, dynamic>{
            'labelKo': '씨앗(모든 형태)',
            'part': 'seeds',
            'prep': 'any',
            'level': 'danger',
            'noteKo': '씨앗은 급여 금지',
          },
        ],
        'portionsKo': <String, dynamic>{
          'allowedParts': <String>[],
          'avoidParts': <String>['씨앗'],
          'frequency': '급여 금지',
          'notes': <String>[],
          'examplesKo': <String>[],
        },
        'confusables': <Map<String, dynamic>>[],
        'evidenceLevel': 'medium',
        'reviewedAt': '2026-02-15',
        'sources': <Map<String, dynamic>>[
          <String, dynamic>{
            'type': 'test',
            'title': 'seed source',
            'year': 2026,
            'url': 'https://example.com/seed',
          },
        ],
        'search': <String, dynamic>{
          'tokens': <String>['사과', '사과 씨앗', 'apple'],
        },
        'emergency': <String, dynamic>{
          'baseRisk': 'high',
          'whatToDoKo': <String>['테스트'],
          'watchForKo': <String>['테스트'],
          'escalationTriggersKo': <String>['테스트'],
        },
      },
    ],
  },
);
