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
}
