import 'string_normalizer.dart';

final class SearchTokenizer {
  const SearchTokenizer._();

  static List<String> deriveTokens({
    required String nameKo,
    required String nameEn,
    required List<String> aliases,
  }) {
    final tokenSet = <String>{};
    final candidates = <String>[nameKo, nameEn, ...aliases];

    for (final candidate in candidates) {
      final normalized = StringNormalizer.normalize(candidate);
      final noSpace = StringNormalizer.normalizeNoSpace(candidate);
      if (normalized.isNotEmpty) {
        tokenSet.add(normalized);
      }
      if (noSpace.isNotEmpty) {
        tokenSet.add(noSpace);
      }
    }

    return tokenSet.toList()..sort();
  }
}
