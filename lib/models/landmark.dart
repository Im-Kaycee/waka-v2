import 'package:hive_flutter/hive_flutter.dart';

part 'landmark.g.dart';

@HiveType(typeId: 0)
class Landmark extends HiveObject {
  @HiveField(0)
  final String localName;

  @HiveField(1)
  final String geocodeQuery;

  @HiveField(2)
  final double? lat;

  @HiveField(3)
  final double? lng;

  @HiveField(4)
  final bool verified;

  Landmark({
    required this.localName,
    required this.geocodeQuery,
    this.lat,
    this.lng,
    this.verified = false,
  });
}