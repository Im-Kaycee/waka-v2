import 'package:hive_flutter/hive_flutter.dart';
import '../../models/landmark.dart';
import '../../models/correction.dart';
import '../../models/route_result.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
class HiveService {
  static const _routesBox = 'recent_routes';
  static const _landmarksBox = 'cached_landmarks';
  static const _correctionsBox = 'corrections';

static Future<void> init() async {
  await Hive.initFlutter();

  Hive.registerAdapter(LandmarkAdapter());
  Hive.registerAdapter(CorrectionAdapter());
  Hive.registerAdapter(RouteResultAdapter());

  await Hive.openBox<Landmark>(_landmarksBox);
  await Hive.openBox<Correction>(_correctionsBox);

  // open routes box with explicit migration handling
  await _openRoutesBox();
}

static Future<void> _openRoutesBox() async {
  try {
    await Hive.openBox<RouteResult>(_routesBox);
  } catch (e) {
    // stale schema — wipe manually and reopen
    final dir = await getApplicationDocumentsDirectory();
    final hivePath = '${dir.path}/$_routesBox.hive';
    final lockPath = '${dir.path}/$_routesBox.lock';

    final hiveFile = File(hivePath);
    final lockFile = File(lockPath);

    if (await hiveFile.exists()) await hiveFile.delete();
    if (await lockFile.exists()) await lockFile.delete();

    await Hive.openBox<RouteResult>(_routesBox);
  }
}

  // --- Routes ---

  Box<RouteResult> get _routes => Hive.box<RouteResult>(_routesBox);

  Future<void> saveRoute(RouteResult route) async {
    await _routes.put(route.id, route);
  }

  List<RouteResult> getRecentRoutes({int limit = 10}) {
    final all = _routes.values.toList();
    all.sort((a, b) => b.searchedAt.compareTo(a.searchedAt));
    return all.take(limit).toList();
  }

  // --- Landmarks ---

  Box<Landmark> get _landmarks => Hive.box<Landmark>(_landmarksBox);

  Future<void> saveLandmark(Landmark landmark) async {
    await _landmarks.put(landmark.localName.toLowerCase(), landmark);
  }

  List<Landmark> getAllLandmarks() => _landmarks.values.toList();

  // --- Corrections ---

  Box<Correction> get _corrections => Hive.box<Correction>(_correctionsBox);

  Future<void> saveCorrection(Correction correction) async {
    await _corrections.put(correction.id, correction);
    await saveLandmark(Landmark(
      localName: correction.correctedName,
      geocodeQuery: correction.correctedGeocode,
      verified: true,
    ));
  }

  List<Correction> getAllCorrections() => _corrections.values.toList();
}