import '../models/food_item.dart';
import 'string_normalizer.dart';

class SearchService {
  const SearchService({this.fuzzyCandidateLimit = 30});

  final int fuzzyCandidateLimit;
  static final RegExp _singleJamoPattern = RegExp(r'^[ㄱ-ㅎㅏ-ㅣ]+$');

  List<FoodItem> search(List<FoodItem> foods, String query) {
    final normalized = StringNormalizer.normalize(query);
    final noSpace = StringNormalizer.normalizeNoSpace(query);
    if (normalized.isEmpty || noSpace.isEmpty) {
      return foods;
    }

    final scored = <_ScoredFood>[];
    for (final food in foods) {
      final tokens = _collectTokens(food);
      final prefixScore = _prefixScore(tokens, normalized, noSpace);
      if (prefixScore != null) {
        scored.add(_ScoredFood(food, 0, prefixScore));
        continue;
      }

      final containsScore = _containsScore(tokens, normalized, noSpace);
      if (containsScore != null) {
        scored.add(_ScoredFood(food, 1, containsScore));
      }
    }

    if (scored.isEmpty) {
      if (!_shouldUseFuzzy(noSpace)) {
        return const <FoodItem>[];
      }
      final fuzzy = _fuzzyCandidates(foods, noSpace);
      return fuzzy
          .take(fuzzyCandidateLimit)
          .map((entry) => entry.food)
          .toList();
    }

    scored.sort(_sortByBucket);
    return scored.map((entry) => entry.food).toList();
  }

  List<String> suggest(List<FoodItem> foods, String query, {int limit = 3}) {
    final searchResults = search(foods, query);
    if (searchResults.isNotEmpty) {
      return searchResults
          .take(limit)
          .map((item) => item.nameKo)
          .toList(growable: false);
    }

    final queryNoSpace = StringNormalizer.normalizeNoSpace(query);
    if (!_shouldUseFuzzy(queryNoSpace)) {
      return const <String>[];
    }
    final fuzzy = _fuzzyCandidates(foods, queryNoSpace);
    return fuzzy.take(limit).map((entry) => entry.food.nameKo).toList();
  }

  bool _shouldUseFuzzy(String queryNoSpace) {
    if (queryNoSpace.length < 2) {
      return false;
    }
    if (_singleJamoPattern.hasMatch(queryNoSpace)) {
      return false;
    }
    return true;
  }

  List<_FuzzyEntry> _fuzzyCandidates(
      List<FoodItem> foods, String queryNoSpace) {
    final candidates = <_FuzzyEntry>[];
    for (final food in foods) {
      final tokens = _collectTokens(food);
      final bestDistance = tokens
          .map((token) => _levenshtein(queryNoSpace, token))
          .reduce((a, b) => a < b ? a : b);
      final maxDistance =
          queryNoSpace.length <= 3 ? 1 : queryNoSpace.length ~/ 3;
      if (bestDistance <= maxDistance) {
        candidates.add(_FuzzyEntry(food, bestDistance));
      }
    }
    candidates.sort((a, b) {
      final byDistance = a.distance.compareTo(b.distance);
      if (byDistance != 0) {
        return byDistance;
      }
      return a.food.nameKo.compareTo(b.food.nameKo);
    });
    return candidates;
  }

  Set<String> _collectTokens(FoodItem food) {
    return <String>{
      StringNormalizer.normalize(food.nameKo),
      StringNormalizer.normalizeNoSpace(food.nameKo),
      StringNormalizer.normalize(food.nameEn),
      StringNormalizer.normalizeNoSpace(food.nameEn),
      ...food.aliases.map(StringNormalizer.normalize),
      ...food.aliases.map(StringNormalizer.normalizeNoSpace),
      ...food.searchTokens.map(StringNormalizer.normalize),
      ...food.searchTokens.map(StringNormalizer.normalizeNoSpace),
    }..removeWhere((value) => value.isEmpty);
  }

  int? _prefixScore(Set<String> tokens, String query, String queryNoSpace) {
    int? best;
    for (final token in tokens) {
      final tokenNoSpace = StringNormalizer.normalizeNoSpace(token);
      final startsWith =
          token.startsWith(query) || tokenNoSpace.startsWith(queryNoSpace);
      if (!startsWith) {
        continue;
      }
      final gap = tokenNoSpace.length - queryNoSpace.length;
      if (best == null || gap < best) {
        best = gap;
      }
    }
    return best;
  }

  int? _containsScore(Set<String> tokens, String query, String queryNoSpace) {
    int? best;
    for (final token in tokens) {
      final tokenNoSpace = StringNormalizer.normalizeNoSpace(token);
      final contains =
          token.contains(query) || tokenNoSpace.contains(queryNoSpace);
      if (!contains) {
        continue;
      }
      final index = tokenNoSpace.indexOf(queryNoSpace);
      if (index < 0) {
        continue;
      }
      if (best == null || index < best) {
        best = index;
      }
    }
    return best;
  }

  int _sortByBucket(_ScoredFood a, _ScoredFood b) {
    final byBucket = a.bucket.compareTo(b.bucket);
    if (byBucket != 0) {
      return byBucket;
    }
    final byScore = a.score.compareTo(b.score);
    if (byScore != 0) {
      return byScore;
    }
    return a.food.nameKo.compareTo(b.food.nameKo);
  }

  int _levenshtein(String left, String right) {
    if (left == right) {
      return 0;
    }
    if (left.isEmpty) {
      return right.length;
    }
    if (right.isEmpty) {
      return left.length;
    }

    final previous = List<int>.generate(right.length + 1, (index) => index);
    final current = List<int>.filled(right.length + 1, 0);

    for (var i = 1; i <= left.length; i++) {
      current[0] = i;
      for (var j = 1; j <= right.length; j++) {
        final substitutionCost = left[i - 1] == right[j - 1] ? 0 : 1;
        current[j] = [
          current[j - 1] + 1,
          previous[j] + 1,
          previous[j - 1] + substitutionCost,
        ].reduce((a, b) => a < b ? a : b);
      }
      for (var j = 0; j < current.length; j++) {
        previous[j] = current[j];
      }
    }

    return previous[right.length];
  }
}

class _ScoredFood {
  const _ScoredFood(this.food, this.bucket, this.score);

  final FoodItem food;
  final int bucket;
  final int score;
}

class _FuzzyEntry {
  const _FuzzyEntry(this.food, this.distance);

  final FoodItem food;
  final int distance;
}
