import '../../core/types/avium_types.dart';
import '../models/food_db.dart';
import '../models/food_item.dart';
import '../models/portion_guide.dart';
import '../models/safety_condition.dart';
import '../models/source_reference.dart';

/// Expands foods with condition rules into part-specific entries.
class FoodPartVariantBuilder {
  const FoodPartVariantBuilder();

  /// Returns a new database where foods with `safetyConditions` are split
  /// into part-based items such as `사과 (과육)` and `사과 (씨앗)`.
  FoodDb build(FoodDb source) {
    final expandedFoods = <FoodItem>[];
    for (final food in source.foods) {
      expandedFoods.addAll(_expandFood(food));
    }

    return FoodDb(meta: source.meta, foods: expandedFoods);
  }

  List<FoodItem> _expandFood(FoodItem food) {
    if (food.safetyConditions.isEmpty) {
      return <FoodItem>[food];
    }

    final groups = <PartType, List<SafetyCondition>>{};
    for (final condition in food.safetyConditions) {
      groups.putIfAbsent(condition.part, () => <SafetyCondition>[]);
      groups[condition.part]!.add(condition);
    }

    final parts = groups.keys.toList(growable: false)
      ..sort((a, b) => a.index.compareTo(b.index));
    return parts
        .map((part) => _buildPartVariant(food, part, groups[part]!))
        .toList(growable: false);
  }

  FoodItem _buildPartVariant(
    FoodItem food,
    PartType part,
    List<SafetyCondition> conditions,
  ) {
    final partLabel = part.labelKo;
    final partLevel = _maxLevel(conditions);
    final aliases = _unique(
      <String>[
        ...food.aliases,
        '${food.nameKo} $partLabel',
        '${food.nameKo}$partLabel',
      ],
    );
    final searchTokens = _unique(
      <String>[
        ...food.searchTokens,
        partLabel,
        '${food.nameKo} $partLabel',
        '${food.nameKo}($partLabel)',
      ],
    );
    final conditionNotes = conditions
        .map((condition) => condition.noteKo.trim())
        .where((note) => note.isNotEmpty)
        .toList(growable: false);
    final reasons = _unique(
      <String>[
        ...food.reasonKo,
        '$partLabel 기준으로 분리된 항목입니다.',
        ...conditionNotes,
      ],
    );
    final riskNotes = _unique(<String>[...food.riskNotesKo, ...conditionNotes]);

    return FoodItem(
      id: '${food.id}__${part.name}',
      nameKo: '${food.nameKo} ($partLabel)',
      nameEn: '${food.nameEn} (${_partLabelEn(part)})',
      aliases: aliases,
      category: food.category,
      foodType: food.foodType,
      safetyLevel: partLevel,
      oneLinerKo:
          conditionNotes.isEmpty ? food.oneLinerKo : conditionNotes.first,
      reasonKo: reasons,
      riskNotesKo: riskNotes,
      safetyConditions: conditions,
      portionsKo: _buildPortionGuide(
        base: food.portionsKo,
        part: part,
        partLevel: partLevel,
      ),
      confusables: food.confusables,
      evidenceLevel: food.evidenceLevel,
      reviewedAt: food.reviewedAt,
      sources: _resolvePartSources(food.sources, conditions),
      searchTokens: searchTokens,
      emergency: food.emergency,
    );
  }

  PortionGuide _buildPortionGuide({
    required PortionGuide base,
    required PartType part,
    required SafetyLevel partLevel,
  }) {
    final partLabel = part.labelKo;
    final matchedAllowed = base.allowedParts
        .where((value) => _matchesPartLabel(value, partLabel))
        .toList(growable: false);
    final matchedAvoid = base.avoidParts
        .where((value) => _matchesPartLabel(value, partLabel))
        .toList(growable: false);

    final allowedParts = matchedAllowed.isNotEmpty
        ? matchedAllowed
        : partLevel == SafetyLevel.safe
            ? <String>[partLabel]
            : const <String>[];
    final avoidParts = matchedAvoid.isNotEmpty
        ? matchedAvoid
        : partLevel == SafetyLevel.danger
            ? <String>[partLabel]
            : const <String>[];

    return PortionGuide(
      allowedParts: allowedParts,
      avoidParts: avoidParts,
      frequency: partLevel == SafetyLevel.danger ? '급여 금지' : base.frequency,
      notes: base.notes,
      examplesKo: base.examplesKo,
    );
  }

  SafetyLevel _maxLevel(List<SafetyCondition> conditions) {
    var maxLevel = SafetyLevel.safe;
    for (final condition in conditions) {
      if (condition.level.severity > maxLevel.severity) {
        maxLevel = condition.level;
      }
    }
    return maxLevel;
  }

  bool _matchesPartLabel(String value, String partLabel) {
    final left = _normalizeForMatch(value);
    final right = _normalizeForMatch(partLabel);
    if (left.isEmpty || right.isEmpty) {
      return false;
    }
    return left.contains(right) || right.contains(left);
  }

  String _normalizeForMatch(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9가-힣]'), '');
  }

  String _partLabelEn(PartType part) {
    return switch (part) {
      PartType.flesh => 'Flesh',
      PartType.seeds => 'Seeds',
      PartType.peel => 'Peel',
      PartType.pit => 'Pit',
      PartType.leaf => 'Leaf',
      PartType.stem => 'Stem',
      PartType.sprout => 'Sprout',
      PartType.unknown => 'Other',
    };
  }

  List<String> _unique(List<String> values) {
    final normalizedSeen = <String>{};
    final result = <String>[];
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final key = trimmed.toLowerCase();
      if (!normalizedSeen.add(key)) {
        continue;
      }
      result.add(trimmed);
    }
    return result;
  }

  List<SourceReference> _resolvePartSources(
    List<SourceReference> allSources,
    List<SafetyCondition> conditions,
  ) {
    final indexes = <int>{};
    for (final condition in conditions) {
      indexes.addAll(condition.sourceIndexes);
    }
    if (indexes.isEmpty) {
      return allSources;
    }

    final resolved = <SourceReference>[];
    for (final index in indexes.toList()..sort()) {
      if (index < 0 || index >= allSources.length) {
        continue;
      }
      resolved.add(allSources[index]);
    }

    return resolved.isEmpty ? allSources : resolved;
  }
}
