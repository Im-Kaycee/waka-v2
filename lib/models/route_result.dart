import 'package:hive_flutter/hive_flutter.dart';

part 'route_result.g.dart';

@HiveType(typeId: 2)
class RouteResult extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String originLabel;

  @HiveField(2)
  final String destinationLabel;

  @HiveField(3)
  final List<String> stopLabels;

  @HiveField(4)
  final String summary;

  @HiveField(5)
  final DateTime searchedAt;

  @HiveField(6)
  final String originalQuery;

  RouteResult({
    required this.id,
    required this.originLabel,
    required this.destinationLabel,
    required this.stopLabels,
    required this.summary,
    required this.searchedAt,
    required this.originalQuery,
  });
}