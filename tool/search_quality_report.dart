import 'dart:convert';
import 'dart:io';

import 'package:avium/data/models/food_db.dart';
import 'package:avium/data/models/food_item.dart';
import 'package:avium/data/search/search_service.dart';

Future<void> main(List<String> args) async {
  final inputPath =
      _readArg(args, '--input') ?? 'assets/data/foods.v1_2_0.json';
  final minTop1 = double.parse(_readArg(args, '--min-top1') ?? '0.80');
  final minTop3 = double.parse(_readArg(args, '--min-top3') ?? '0.95');

  final file = File(inputPath);
  if (!file.existsSync()) {
    stderr.writeln('Data file not found: $inputPath');
    exitCode = 2;
    return;
  }

  final root = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  final db = FoodDb.fromJson(root);
  const service = SearchService();

  final cases = _buildCases(db);
  if (cases.isEmpty) {
    stderr.writeln('No query cases generated.');
    exitCode = 2;
    return;
  }

  final metricsByGroup = <String, _Metrics>{};
  var totalTop1 = 0;
  var totalTop3 = 0;

  for (final queryCase in cases) {
    final results = service.search(db.foods, queryCase.query);
    final top1Hit = results.isNotEmpty && results.first.id == queryCase.foodId;
    final top3Hit = results.take(3).any((food) => food.id == queryCase.foodId);
    final metrics = metricsByGroup.putIfAbsent(
      queryCase.group,
      _Metrics.new,
    );

    metrics.total++;
    if (top1Hit) {
      metrics.top1++;
      totalTop1++;
    }
    if (top3Hit) {
      metrics.top3++;
      totalTop3++;
    }
  }

  final totalCount = cases.length;
  final totalTop1Rate = totalTop1 / totalCount;
  final totalTop3Rate = totalTop3 / totalCount;

  stdout.writeln('cases: $totalCount');
  stdout.writeln(
    'overall_top1: ${_formatRate(totalTop1Rate)} ($totalTop1/$totalCount)',
  );
  stdout.writeln(
    'overall_top3: ${_formatRate(totalTop3Rate)} ($totalTop3/$totalCount)',
  );

  for (final entry in metricsByGroup.entries) {
    final metrics = entry.value;
    final groupTop1 = metrics.top1 / metrics.total;
    final groupTop3 = metrics.top3 / metrics.total;
    stdout.writeln(
      '${entry.key}_top1: ${_formatRate(groupTop1)} '
      '(${metrics.top1}/${metrics.total})',
    );
    stdout.writeln(
      '${entry.key}_top3: ${_formatRate(groupTop3)} '
      '(${metrics.top3}/${metrics.total})',
    );
  }

  if (totalTop1Rate < minTop1 || totalTop3Rate < minTop3) {
    stderr.writeln(
      'quality threshold failed '
      '(min-top1=$minTop1, min-top3=$minTop3)',
    );
    exitCode = 1;
  }
}

List<_QueryCase> _buildCases(FoodDb db) {
  final cases = <_QueryCase>[];
  for (final food in db.foods) {
    cases.add(
      _QueryCase(
        foodId: food.id,
        query: food.nameKo,
        group: 'ko_exact',
      ),
    );
    cases.add(
      _QueryCase(
        foodId: food.id,
        query: food.nameEn.toLowerCase(),
        group: 'en_exact',
      ),
    );

    final alias = food.aliases.isNotEmpty ? food.aliases.first : food.nameKo;
    cases.add(
      _QueryCase(
        foodId: food.id,
        query: alias,
        group: 'alias_exact',
      ),
    );

    final noSpaceQuery = food.nameEn.contains(' ')
        ? food.nameEn.replaceAll(' ', '')
        : _addSpaces(food.nameKo);
    cases.add(
      _QueryCase(
        foodId: food.id,
        query: noSpaceQuery,
        group: 'space_variant',
      ),
    );

    cases.add(
      _QueryCase(
        foodId: food.id,
        query: _oneEditTypo(food),
        group: 'typo_1edit',
      ),
    );
  }
  return cases;
}

String _oneEditTypo(FoodItem food) {
  final en = food.nameEn.toLowerCase().replaceAll(' ', '');
  if (en.length > 4) {
    return en.substring(0, en.length - 1);
  }
  final ko = food.nameKo;
  if (ko.length > 1) {
    return ko.substring(0, ko.length - 1);
  }
  return ko;
}

String _addSpaces(String value) {
  if (value.length <= 1) {
    return value;
  }
  return value.split('').join(' ');
}

String _formatRate(double value) => '${(value * 100).toStringAsFixed(1)}%';

String? _readArg(List<String> args, String name) {
  final index = args.indexOf(name);
  if (index == -1 || index + 1 >= args.length) {
    return null;
  }
  return args[index + 1];
}

class _QueryCase {
  const _QueryCase({
    required this.foodId,
    required this.query,
    required this.group,
  });

  final String foodId;
  final String query;
  final String group;
}

class _Metrics {
  int total = 0;
  int top1 = 0;
  int top3 = 0;
}
