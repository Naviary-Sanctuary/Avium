final class StringNormalizer {
  const StringNormalizer._();

  static final RegExp _specialChars = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);
  static final RegExp _spaces = RegExp(r'\s+');

  static String normalize(String input) {
    final lowercase = input.toLowerCase().trim();
    final removed = lowercase.replaceAll(_specialChars, ' ');
    final compact = removed.replaceAll(_spaces, ' ').trim();
    return compact;
  }

  static String normalizeNoSpace(String input) {
    return normalize(input).replaceAll(' ', '');
  }
}
