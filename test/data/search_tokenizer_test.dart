import 'package:avium/data/search/search_tokenizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('derives normalized tokens with and without spaces', () {
    final tokens = SearchTokenizer.deriveTokens(
      nameKo: '고구마',
      nameEn: 'Sweet Potato',
      aliases: const <String>[' sweet  potato ', '고 구 마'],
    );

    expect(tokens, contains('sweet potato'));
    expect(tokens, contains('sweetpotato'));
    expect(tokens, contains('고구마'));
  });
}
