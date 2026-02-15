import 'dart:convert';
import 'dart:io';

import 'package:avium/data/search/search_tokenizer.dart';

Future<void> main(List<String> args) async {
  final checkMode = args.contains('--check');
  final inputPath = _readArg(args, '--input') ?? 'assets/data/foods.json';

  final file = File(inputPath);
  if (!file.existsSync()) {
    stderr.writeln('Data file not found: $inputPath');
    exitCode = 2;
    return;
  }

  final content = await file.readAsString();
  final root = jsonDecode(content) as Map<String, dynamic>;
  final foods = (root['foods'] as List<dynamic>).map((item) {
    return Map<String, dynamic>.from(item as Map<dynamic, dynamic>);
  }).toList();
  root['foods'] = foods;

  var changed = false;
  for (final food in foods) {
    final tokens = SearchTokenizer.deriveTokens(
      nameKo: food['nameKo'] as String,
      nameEn: food['nameEn'] as String,
      aliases: (food['aliases'] as List<dynamic>).cast<String>(),
    );

    final search = Map<String, dynamic>.from(
      food['search'] as Map<String, dynamic>? ?? <String, dynamic>{},
    );
    final existing = (search['tokens'] as List<dynamic>? ?? const <dynamic>[])
        .cast<String>()
      ..sort();
    if (_equals(existing, tokens)) {
      continue;
    }

    search['tokens'] = tokens;
    food['search'] = search;
    changed = true;
  }

  if (!changed) {
    stdout.writeln('search.tokens already up to date.');
    return;
  }

  if (checkMode) {
    stderr.writeln('search.tokens is outdated. Run generator.');
    exitCode = 1;
    return;
  }

  final encoder = const JsonEncoder.withIndent('  ');
  await file.writeAsString('${encoder.convert(root)}\n');
  stdout.writeln('Updated search.tokens in $inputPath');
}

String? _readArg(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index == -1 || index + 1 >= args.length) {
    return null;
  }
  return args[index + 1];
}

bool _equals(List<String> left, List<String> right) {
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
