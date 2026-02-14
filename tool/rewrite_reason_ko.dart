import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final inputPath =
      _readArg(args, '--input') ?? 'assets/data/foods.v1_2_0.json';

  final file = File(inputPath);
  if (!file.existsSync()) {
    stderr.writeln('Data file not found: $inputPath');
    exitCode = 2;
    return;
  }

  final root = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  final foods = (root['foods'] as List<dynamic>)
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList();

  var changed = 0;
  for (final food in foods) {
    final nextReasons = _buildReasonKo(food);
    final prevReasons = (food['reasonKo'] as List<dynamic>).cast<String>();
    if (!_sameList(prevReasons, nextReasons)) {
      food['reasonKo'] = nextReasons;
      changed++;
    }
  }

  root['foods'] = foods;
  final encoder = const JsonEncoder.withIndent('  ');
  await file.writeAsString('${encoder.convert(root)}\n');

  stdout.writeln('rewrote reasonKo for $changed foods');
}

List<String> _buildReasonKo(Map<String, dynamic> food) {
  final id = food['id'] as String;
  final nameKo = food['nameKo'] as String;
  final safetyLevel = food['safetyLevel'] as String;
  final category = food['category'] as String;
  final riskNotes = (food['riskNotesKo'] as List<dynamic>).cast<String>();
  final note = _normalizeSentence(
      riskNotes.isEmpty ? '첫 급여는 매우 소량으로 시작하세요' : riskNotes.first);

  if (id == 'foodChiliPepper') {
    return <String>[
      '고추 과육은 조류 식단에서 채소 보완식으로 자주 활용되며, '
          '수의학 급여 가이드에서도 red/green/hot peppers가 '
          '권장 목록에 포함됩니다.',
      '고추 과육은 일반 급여량에서 대체로 허용되지만, 잎·줄기와 '
          '양념/고농도 분말은 별도 위험 요인이므로 피해야 합니다. '
          '운영 원칙: $note.',
    ];
  }

  final dangerSpecific = _dangerSpecificReason(id, nameKo, note);
  if (dangerSpecific != null) {
    return dangerSpecific;
  }

  final cautionSpecific = _cautionSpecificReason(id, nameKo, category, note);
  if (cautionSpecific != null) {
    return cautionSpecific;
  }

  switch (safetyLevel) {
    case 'safe':
      return _safeFallbackReason(nameKo, category, note);
    case 'caution':
      return _cautionFallbackReason(nameKo, category, note);
    case 'danger':
      return <String>[
        '${_topic(nameKo)} 조류에서 안전 범위를 특정하기 어렵고 급성 악화 위험이 있어 급여 금지로 분류합니다.',
        '운영 원칙: $note. 실수 섭취 시 즉시 관찰 강도를 높이고 응급 모드를 확인하세요.',
      ];
    default:
      return <String>[
        '${_topic(nameKo)} 자료가 제한적이어서 보수적으로 접근해야 합니다.',
        '운영 원칙: $note.',
      ];
  }
}

List<String>? _dangerSpecificReason(String id, String nameKo, String note) {
  const persinIds = <String>{'foodAvocado'};
  if (persinIds.contains(id)) {
    return <String>[
      '아보카도에는 페르신(persin)이 포함되어 조류에서 심근 손상, 호흡곤란, 급성 허탈 위험이 보고됩니다.',
      '소량이라도 개체별 반응이 급격할 수 있으므로 절대 급여하지 마세요. 운영 원칙: $note.',
    ];
  }

  const methylxanthineIds = <String>{
    'foodChocolate',
    'foodCocoa',
    'foodHotChocolate',
  };
  if (methylxanthineIds.contains(id)) {
    return <String>[
      '$nameKo에는 테오브로민·카페인(메틸크산틴)이 포함되어 조류에서 부정맥, 떨림, 경련, 급사 위험을 높일 수 있습니다.',
      '가공품은 당류와 지방까지 함께 높아 독성 부담이 더 커집니다. 운영 원칙: $note.',
    ];
  }

  const caffeineIds = <String>{
    'foodCoffee',
    'foodTea',
    'foodEnergyDrink',
    'foodMatcha',
  };
  if (caffeineIds.contains(id)) {
    return <String>[
      '$nameKo의 카페인은 체중이 작은 조류에서 심박수 급상승, 과흥분, 신경계 이상을 유발할 수 있습니다.',
      '특히 농축 음료는 당류·첨가물까지 동반되어 위험이 커지므로 급여 금지입니다. 운영 원칙: $note.',
    ];
  }

  const alliumIds = <String>{
    'foodOnion',
    'foodGarlic',
    'foodLeek',
    'foodScallion',
    'foodChive',
  };
  if (alliumIds.contains(id)) {
    return <String>[
      '${_topic(nameKo)} 알리움(Allium) 계열로, 산화성 황화합물이 적혈구 손상을 일으켜 빈혈·무기력·호흡 악화를 유발할 수 있습니다.',
      '가열해도 위험 성분이 완전히 사라지지 않아 조리 여부와 무관하게 금지합니다. 운영 원칙: $note.',
    ];
  }

  const alcoholIds = <String>{'foodAlcohol'};
  if (alcoholIds.contains(id)) {
    return <String>[
      '알코올(에탄올)은 조류의 신경계와 간 대사에 급격한 부담을 주어 저체온, 실조, 호흡저하를 유발할 수 있습니다.',
      '소량도 안전하다고 볼 근거가 부족하므로 절대 급여하지 마세요. 운영 원칙: $note.',
    ];
  }

  const xylitolIds = <String>{'foodXylitol'};
  if (xylitolIds.contains(id)) {
    return <String>[
      '자일리톨은 소동물에서 급성 저혈당 및 간 손상과 연관되며, 조류의 안전 용량은 확립되어 있지 않습니다.',
      '무설탕 표기 제품에 숨어 있는 경우가 많아 노출 자체를 피해야 합니다. 운영 원칙: $note.',
    ];
  }

  const rawBeanIds = <String>{'foodUncookedBeans'};
  if (rawBeanIds.contains(id)) {
    return <String>[
      '생콩에는 피토헤마글루티닌(lectin) 등 열에 약한 독성 성분이 있어 소화기 자극과 전신 악화를 유발할 수 있습니다.',
      '완전히 익히지 않은 형태는 금지하고, 조리된 콩도 소량 기준으로만 검토해야 합니다. 운영 원칙: $note.',
    ];
  }

  const cassavaIds = <String>{'foodCassava'};
  if (cassavaIds.contains(id)) {
    return <String>[
      '카사바는 시안배당체(cyanogenic glycosides)를 함유해 전처리·가열이 불충분하면 청산 노출 위험이 있습니다.',
      '가정 급여 환경에서 안전 처리 일관성을 담보하기 어려워 금지 항목으로 둡니다. 운영 원칙: $note.',
    ];
  }

  const highSaltIds = <String>{
    'foodSoySauce',
    'foodFishSauce',
    'foodInstantNoodle',
    'foodChips',
    'foodSportsDrink',
  };
  if (highSaltIds.contains(id)) {
    return <String>[
      '${_topic(nameKo)} 나트륨 농도가 높아 조류의 체액 균형을 무너뜨리고 신장·신경계 부담을 빠르게 키울 수 있습니다.',
      '사람용 가공식품은 염분·향미첨가물이 중첩되므로 급여 금지로 관리합니다. 운영 원칙: $note.',
    ];
  }

  const sodaIds = <String>{'foodSoda'};
  if (sodaIds.contains(id)) {
    return <String>[
      '탄산음료는 고당분·산성 성분·카페인이 겹쳐 조류의 대사 및 위장에 복합 부담을 줍니다.',
      '영양 이득 없이 급성 반응 위험만 높이므로 급여 금지입니다. 운영 원칙: $note.',
    ];
  }

  const candyIds = <String>{'foodCandy'};
  if (candyIds.contains(id)) {
    return <String>[
      '사탕은 농축 당류와 인공첨가물이 높고, 제품에 따라 자일리톨 등 독성 감미료가 포함될 수 있습니다.',
      '점착성 식감은 구강·소화기 부담까지 키우므로 급여 금지로 분류합니다. 운영 원칙: $note.',
    ];
  }

  return null;
}

List<String>? _cautionSpecificReason(
  String id,
  String nameKo,
  String category,
  String note,
) {
  const pitSeedRiskIds = <String>{
    'foodApple',
    'foodPear',
    'foodApricot',
    'foodPeach',
    'foodPlum',
    'foodNectarine',
    'foodCherry',
    'foodMango',
    'foodPersimmon',
  };
  if (pitSeedRiskIds.contains(id)) {
    return <String>[
      '$nameKo 과육은 비교적 안전할 수 있지만 씨·핵에는 청산배당체 계열 위험 성분 또는 질식 위험이 있습니다.',
      '씨·핵·심지를 완전히 제거한 과육만 제한적으로 급여해야 합니다. 운영 원칙: $note.',
    ];
  }

  const citrusIds = <String>{
    'foodOrange',
    'foodGrapefruit',
    'foodLemon',
    'foodLime',
    'foodMandarin',
    'foodTangerine',
    'foodBloodOrange',
    'foodClementine',
    'foodYuzu',
    'foodCalamansi',
    'foodPomelo',
    'foodKumquat',
    'foodUgliFruit',
  };
  if (citrusIds.contains(id)) {
    return <String>[
      '${_topic(nameKo)} 산도와 정유 성분 농도가 높아 일부 개체에서 모이주머니·위장 자극을 유발할 수 있습니다.',
      '과일 간식 범위에서 매우 소량으로만 테스트하고 반응을 확인해야 합니다. 운영 원칙: $note.',
    ];
  }

  const nutIds = <String>{
    'foodAlmond',
    'foodPeanut',
    'foodMixedNuts',
    'foodSunflowerSeed',
    'foodPeanutInShell',
    'foodWalnut',
    'foodCashew',
    'foodHazelnut',
    'foodPecan',
    'foodPistachio',
  };
  if (nutIds.contains(id)) {
    return <String>[
      '${_topic(nameKo)} 지방 밀도가 높아 과량 급여 시 비만·지방간·영양 불균형 위험이 빠르게 증가합니다.',
      '무염·무가공 소량만 사용하고 산패·곰팡이(아플라톡신) 가능성을 항상 확인해야 합니다. 운영 원칙: $note.',
    ];
  }

  const juiceDrinkIds = <String>{
    'foodAppleJuice',
    'foodOrangeJuice',
    'foodGrapeJuice',
    'foodTomatoJuice',
    'foodCoconutWater',
    'foodElectrolyteDrink',
    'foodHerbalTea',
    'foodBubbleTea',
    'foodKombucha',
  };
  if (juiceDrinkIds.contains(id)) {
    return <String>[
      '${_topic(nameKo)} 액상 형태로 당류·산도·첨가물이 빠르게 흡수되어 혈당 및 소화기 부담을 키울 수 있습니다.',
      '섬유질 완충이 없는 음료는 일상 급여보다 회피가 안전하며, 필요 시에도 극소량만 고려하세요. 운영 원칙: $note.',
    ];
  }

  const highOxalateGreensIds = <String>{
    'foodSpinach',
    'foodCollardGreens',
    'foodMustardGreens',
    'foodTurnipGreens',
    'foodBeetGreens',
  };
  if (highOxalateGreensIds.contains(id)) {
    return <String>[
      '${_topic(nameKo)} 수산(옥살산) 또는 미네랄 결합 성분이 높아 칼슘 이용률에 영향을 줄 수 있습니다.',
      '연속 급여를 피하고 다른 녹황색 채소와 교차 급여하는 방식이 안전합니다. 운영 원칙: $note.',
    ];
  }

  const nightshadeIds = <String>{
    'foodTomato',
    'foodEggplant',
    'foodChiliPepper',
  };
  if (nightshadeIds.contains(id)) {
    return <String>[
      '${_topic(nameKo)} 과육 자체는 제한 급여가 가능해도 잎·줄기 등 식물체에는 솔라닌 계열 위험 성분이 존재할 수 있습니다.',
      '식물체 비가식 부위를 완전히 제거한 뒤 소량 급여하는 보수적 접근이 필요합니다. 운영 원칙: $note.',
    ];
  }

  const beanIds = <String>{
    'foodLentils',
    'foodChickpeas',
    'foodBlackBean',
    'foodKidneyBean',
    'foodPintoBean',
    'foodLimaBean',
    'foodNavyBean',
    'foodMungBean',
    'foodAdzukiBean',
    'foodSoybean',
    'foodEdamame',
  };
  if (beanIds.contains(id)) {
    return <String>[
      '${_topic(nameKo)} 단백질원으로 활용 가능하지만 생·반생 상태에서는 렉틴/소화 저해 성분이 부담이 될 수 있습니다.',
      '완전 가열 후 무염으로 소량 급여해야 하며 주식 대체로 사용하면 안 됩니다. 운영 원칙: $note.',
    ];
  }

  const cookedAnimalProteinIds = <String>{
    'foodCookedChicken',
    'foodCookedTurkey',
    'foodCookedSalmon',
    'foodCookedTuna',
    'foodEgg',
  };
  if (cookedAnimalProteinIds.contains(id)) {
    return <String>[
      '${_topic(nameKo)} 조리 상태에 따라 단백질 보완용으로 사용할 수 있지만 지방·염분·조리첨가물 영향이 큽니다.',
      '완전히 익힌 무양념 조리 기준을 지키고 아주 소량 간헐 급여로 제한해야 합니다. 운영 원칙: $note.',
    ];
  }

  const dairyIds = <String>{'foodYogurt', 'foodCheese'};
  if (dairyIds.contains(id)) {
    return <String>[
      '${_topic(nameKo)} 유당과 지방, 가공첨가물 때문에 조류에서 소화 불편 또는 설사 위험이 있습니다.',
      '무가당·무첨가 제품도 간식 수준의 극소량만 허용하는 보수적 관리가 필요합니다. 운영 원칙: $note.',
    ];
  }

  const dryOrSugaryFruitIds = <String>{
    'foodDate',
    'foodPrune',
    'foodRaisin',
    'foodFig',
    'foodHoneydew',
    'foodCanaryMelon',
    'foodCoconut',
    'foodJam',
    'foodHoney',
  };
  if (dryOrSugaryFruitIds.contains(id)) {
    return <String>[
      '${_topic(nameKo)} 당밀도가 높아 소량이라도 일일 열량과 혈당 부담을 빠르게 올릴 수 있습니다.',
      '정기 급여보다 드문 보상 간식으로 제한하고 주식 비중을 침해하지 않게 관리해야 합니다. 운영 원칙: $note.',
    ];
  }

  const starchProcessedIds = <String>{
    'foodBread',
    'foodCookie',
    'foodCracker',
    'foodPasta',
    'foodCouscous',
    'foodCornmeal',
    'foodPolenta',
    'foodSemolina',
    'foodQuinoa',
    'foodMillet',
    'foodChiaSeed',
  };
  if (starchProcessedIds.contains(id)) {
    return <String>[
      '${_topic(nameKo)} 전분 비중이 높거나 가공도가 높아 소화 속도와 영양 균형에 영향을 줄 수 있습니다.',
      '무염·무양념·완전 조리 조건에서만 소량 보완식으로 사용해야 합니다. 운영 원칙: $note.',
    ];
  }

  const herbIds = <String>{
    'foodMint',
    'foodOregano',
    'foodThyme',
    'foodRosemary',
    'foodParsley',
    'foodFennel',
    'foodMilkThistle',
  };
  if (herbIds.contains(id)) {
    return <String>[
      '${_topic(nameKo)} 향기 성분과 정유 농도가 있어 개체에 따라 모이주머니·위장 자극 또는 기호성 거부가 발생할 수 있습니다.',
      '향신채소류는 미량 테스트 후 반응을 확인하는 방식으로만 급여해야 합니다. 운영 원칙: $note.',
    ];
  }

  const ambiguousMushroomIds = <String>{'foodMushroom'};
  if (ambiguousMushroomIds.contains(id)) {
    return <String>[
      '${_topic(nameKo)} 종·유통 상태에 따라 독성 편차가 커서 식별 오류 시 심각한 문제가 발생할 수 있습니다.',
      '야생 채집 버섯은 배제하고, 식용 버섯도 익힌 형태를 소량으로 제한해야 합니다. 운영 원칙: $note.',
    ];
  }

  if (category == 'fruit') {
    return <String>[
      '${_topic(nameKo)} 과일군 특성상 당분·유기산 비중이 높아 과량 급여 시 장내 발효와 영양 불균형을 만들 수 있습니다.',
      '과육 중심으로 소량만 제공하고 주식(균형 사료) 비율을 우선 유지해야 합니다. 운영 원칙: $note.',
    ];
  }

  if (category == 'vegetable') {
    return <String>[
      '${_topic(nameKo)} 채소로 활용 가능하지만 섬유질·식물성 화합물 농도에 따라 소화 반응 차이가 큽니다.',
      '세척·손질 후 소량으로 시작하고 이상 반응이 없을 때만 범위를 넓히세요. 운영 원칙: $note.',
    ];
  }

  if (category == 'grain') {
    return <String>[
      '${_topic(nameKo)} 곡물군으로 탄수화물 비중이 높아 과량 급여 시 칼로리 편중과 미량영양소 불균형이 생길 수 있습니다.',
      '익힌 무양념 상태에서만 보완식으로 소량 사용해야 합니다. 운영 원칙: $note.',
    ];
  }

  if (category == 'drink') {
    return <String>[
      '${_topic(nameKo)} 음료 특성상 성분 농도를 통제하기 어렵고 첨가당·향료·산미료가 동반될 가능성이 높습니다.',
      '일반 급수 대체로 사용하지 말고 노출 자체를 최소화하는 편이 안전합니다. 운영 원칙: $note.',
    ];
  }

  return null;
}

List<String> _safeFallbackReason(String nameKo, String category, String note) {
  switch (category) {
    case 'fruit':
      return <String>[
        '$nameKo 과육은 수분과 식이섬유 보완에 도움이 되지만 과일 특성상 당분이 있어 소량 원칙이 필요합니다.',
        '주식 대체가 아닌 간헐 보완 간식으로 운영하세요. 운영 원칙: $note.',
      ];
    case 'vegetable':
      return <String>[
        '${_topic(nameKo)} 조류 식단 다양성에 유용한 채소군으로, 세척·손질 후 급여하면 비교적 안전합니다.',
        '다만 특정 채소 편식을 피하고 여러 채소를 교차 급여하는 방식이 더 안정적입니다. 운영 원칙: $note.',
      ];
    case 'grain':
      return <String>[
        '${_topic(nameKo)} 에너지 보완용 곡물로 활용 가능하지만 반드시 익히고 무양념으로 제공해야 합니다.',
        '균형 사료를 기본으로 두고 곡물은 보조 비율로 유지하세요. 운영 원칙: $note.',
      ];
    default:
      return <String>[
        '${_topic(nameKo)} 현재 자료 기준에서 비교적 안전 범주이나 급여량과 형태 관리가 필요합니다.',
        '처음에는 아주 소량으로 반응을 확인해 개인차를 점검하세요. 운영 원칙: $note.',
      ];
  }
}

List<String> _cautionFallbackReason(
    String nameKo, String category, String note) {
  switch (category) {
    case 'fruit':
      return <String>[
        '${_topic(nameKo)} 과육 자체는 급여 가능할 수 있으나 당분·산도·씨/껍질 변수 때문에 개체차가 큽니다.',
        '손질 기준을 엄격히 지키고 매우 소량부터 반응을 확인해야 합니다. 운영 원칙: $note.',
      ];
    case 'vegetable':
      return <String>[
        '${_topic(nameKo)} 채소군이지만 성분 농도나 섬유 구조에 따라 소화기 부담을 줄 수 있어 주의가 필요합니다.',
        '세척·손질·조리 여부를 관리하고 소량 단계적으로 도입하세요. 운영 원칙: $note.',
      ];
    case 'grain':
      return <String>[
        '${_topic(nameKo)} 전분 비중이 높거나 가공도 영향이 있어 급여량 관리가 중요합니다.',
        '무양념 조리와 소량 빈도 제한을 지켜 보완식으로만 사용하세요. 운영 원칙: $note.',
      ];
    case 'drink':
      return <String>[
        '${_topic(nameKo)} 액상 제형 특성상 당류·산미료·첨가물 노출이 빠르게 증가할 수 있습니다.',
        '기본 수분 공급은 물로 유지하고 음료성 식품은 최소화하세요. 운영 원칙: $note.',
      ];
    default:
      return <String>[
        '${_topic(nameKo)} 조류 대상 안전 자료가 제한적이어서 보수적 급여 기준이 필요합니다.',
        '양·빈도·형태를 엄격히 제한하고 이상 신호가 있으면 즉시 중단하세요. 운영 원칙: $note.',
      ];
  }
}

String _normalizeSentence(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return '첫 급여는 매우 소량으로 시작하세요';
  }
  return trimmed.endsWith('.')
      ? trimmed.substring(0, trimmed.length - 1)
      : trimmed;
}

String _topic(String word) {
  final trimmed = word.trimRight();
  if (trimmed.isEmpty) {
    return word;
  }

  final codePoint = trimmed.runes.last;
  const hangulStart = 0xAC00;
  const hangulEnd = 0xD7A3;
  if (codePoint < hangulStart || codePoint > hangulEnd) {
    return '$word는';
  }

  final hasJong = ((codePoint - hangulStart) % 28) != 0;
  return '$word${hasJong ? '은' : '는'}';
}

String? _readArg(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index == -1 || index + 1 >= args.length) {
    return null;
  }
  return args[index + 1];
}

bool _sameList(List<String> left, List<String> right) {
  if (left.length != right.length) {
    return false;
  }
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) {
      return false;
    }
  }
  return true;
}
