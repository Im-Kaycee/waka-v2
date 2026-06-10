import 'package:hive_flutter/hive_flutter.dart';

part 'correction.g.dart';

@HiveType(typeId: 1)
class Correction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String originalName;

  @HiveField(2)
  final String correctedName;

  @HiveField(3)
  final String correctedGeocode;

  @HiveField(4)
  final DateTime createdAt;

  Correction({
    required this.id,
    required this.originalName,
    required this.correctedName,
    required this.correctedGeocode,
    required this.createdAt,
  });
}