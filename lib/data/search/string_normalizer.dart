final class StringNormalizer {
  const StringNormalizer._();

  static const int _hangulBase = 0xAC00;
  static const int _hangulEnd = 0xD7A3;
  static const int _hangulSyllableCycle = 21 * 28;
  static const List<String> _initialConsonants = <String>[
    'ㄱ',
    'ㄲ',
    'ㄴ',
    'ㄷ',
    'ㄸ',
    'ㄹ',
    'ㅁ',
    'ㅂ',
    'ㅃ',
    'ㅅ',
    'ㅆ',
    'ㅇ',
    'ㅈ',
    'ㅉ',
    'ㅊ',
    'ㅋ',
    'ㅌ',
    'ㅍ',
    'ㅎ',
  ];

  static final RegExp _specialChars = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);
  static final RegExp _spaces = RegExp(r'\s+');
  static final RegExp _compatConsonant = RegExp(r'^[ㄱ-ㅎ]$');

  static String normalize(String input) {
    final lowercase = input.toLowerCase().trim();
    final removed = lowercase.replaceAll(_specialChars, ' ');
    final compact = removed.replaceAll(_spaces, ' ').trim();
    return compact;
  }

  static String normalizeNoSpace(String input) {
    return normalize(input).replaceAll(' ', '');
  }

  static String toInitialConsonants(String input) {
    final normalized = normalize(input);
    if (normalized.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    for (final rune in normalized.runes) {
      if (rune == 0x20) {
        continue;
      }
      if (rune >= _hangulBase && rune <= _hangulEnd) {
        final index = (rune - _hangulBase) ~/ _hangulSyllableCycle;
        buffer.write(_initialConsonants[index]);
        continue;
      }

      final char = String.fromCharCode(rune);
      if (_compatConsonant.hasMatch(char)) {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }
}
