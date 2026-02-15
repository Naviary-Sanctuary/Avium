import 'dart:convert';
import 'dart:io';

import 'package:avium/data/models/food_db.dart';
import 'package:avium/data/search/search_service.dart';

Future<void> main(List<String> args) async {
  final inputPath = _readArg(args, '--input') ?? 'assets/data/foods.json';
  final file = File(inputPath);

  if (!file.existsSync()) {
    stderr.writeln('Data file not found: $inputPath');
    exitCode = 2;
    return;
  }

  final root = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  final db = FoodDb.fromJson(root);
  const service = SearchService();

  const querySet = <String>[
    '사과',
    'apple',
    '아보카도',
    'avocad',
    'sweet potato',
    '고구마',
    '믹스넛',
    '없는음식',
  ];

  final stopwatch = Stopwatch()..start();
  const loops = 400;
  var totalHits = 0;

  for (var i = 0; i < loops; i++) {
    for (final query in querySet) {
      totalHits += service.search(db.foods, query).length;
    }
  }

  stopwatch.stop();
  final totalMs = stopwatch.elapsedMicroseconds / 1000;
  final operations = loops * querySet.length;
  final avgMs = totalMs / operations;

  stdout.writeln('operations: $operations');
  stdout.writeln('total_hits: $totalHits');
  stdout.writeln('total_ms: ${totalMs.toStringAsFixed(2)}');
  stdout.writeln('avg_ms_per_query: ${avgMs.toStringAsFixed(4)}');

  if (avgMs > 300) {
    stderr.writeln('average query time exceeded 300ms target.');
    exitCode = 1;
  }
}

String? _readArg(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index == -1 || index + 1 >= args.length) {
    return null;
  }
  return args[index + 1];
}
