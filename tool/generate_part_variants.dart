import 'dart:convert';
import 'dart:io';

import 'package:avium/data/models/food_db.dart';
import 'package:avium/data/transform/food_part_variant_builder.dart';

Future<void> main(List<String> args) async {
  final inputPath =
      _readArg(args, '--input') ?? 'assets/data/foods.v1_2_0.json';
  final outputPath =
      _readArg(args, '--output') ?? 'assets/data/foods.v1_2_0.expanded.json';

  final inputFile = File(inputPath);
  if (!inputFile.existsSync()) {
    stderr.writeln('Input data file not found: $inputPath');
    exitCode = 2;
    return;
  }

  final raw = await inputFile.readAsString();
  final root = jsonDecode(raw) as Map<String, dynamic>;
  final baseDb = FoodDb.fromJson(root);
  const builder = FoodPartVariantBuilder();
  final expandedDb = builder.build(baseDb);

  final encoded =
      const JsonEncoder.withIndent('  ').convert(expandedDb.toJson());
  final outputFile = File(outputPath);
  await outputFile.writeAsString('$encoded\n');

  stdout.writeln(
    'Generated part-variant data: ${expandedDb.foods.length} items -> '
    '$outputPath',
  );
}

String? _readArg(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index == -1 || index + 1 >= args.length) {
    return null;
  }
  return args[index + 1];
}
