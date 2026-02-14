import 'package:avium/data/search/string_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes case, spacing, and symbols', () {
    final normalized = StringNormalizer.normalize('  ApPlE!!  Pie  ');

    expect(normalized, 'apple pie');
  });

  test('normalizes without spaces when requested', () {
    final normalized = StringNormalizer.normalizeNoSpace('고 구 마');

    expect(normalized, '고구마');
  });

  test('extracts initial consonants from hangul syllables', () {
    final initials = StringNormalizer.toInitialConsonants('사 과');

    expect(initials, 'ㅅㄱ');
  });

  test('keeps only consonant jamo for jamo input', () {
    final initials = StringNormalizer.toInitialConsonants('ㅇㅂㅋㄷ');

    expect(initials, 'ㅇㅂㅋㄷ');
  });
}
