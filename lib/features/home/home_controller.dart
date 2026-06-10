import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/gemini/gemini_service.dart';
import '../../core/gemini/prompt_builder.dart';
import '../../core/storage/hive_service.dart';
import '../../models/landmark.dart';
import '../../models/route_result.dart';
import '../../core/config.dart';

class HomeState {
  final String from;
  final String to;
  final bool isLoading;
  final String? error;
  final List<RouteResult> recentRoutes;
  final List<Landmark> landmarks;

  const HomeState({
    this.from = '',
    this.to = '',
    this.isLoading = false,
    this.error,
    this.recentRoutes = const [],
    this.landmarks = const [],
  });

  HomeState copyWith({
    String? from,
    String? to,
    bool? isLoading,
    String? error,
    List<RouteResult>? recentRoutes,
    List<Landmark>? landmarks,
  }) {
    return HomeState(
      from: from ?? this.from,
      to: to ?? this.to,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      recentRoutes: recentRoutes ?? this.recentRoutes,
      landmarks: landmarks ?? this.landmarks,
    );
  }
}

class HomeController extends StateNotifier<HomeState> {
  final HiveService _hive;
  late final GeminiService _gemini;

  HomeController(this._hive) : super(const HomeState()) {
    final promptBuilder = PromptBuilder(_hive);
    _gemini = GeminiService(promptBuilder, AppConfig.geminiApiKey);
    _loadCached();
  }

  void _loadCached() {
    state = state.copyWith(
      recentRoutes: _hive.getRecentRoutes(limit: 5),
      landmarks: _hive.getAllLandmarks(),
    );
  }

  void setFrom(String value) => state = state.copyWith(from: value);
  void setTo(String value) => state = state.copyWith(to: value);

  Future<GeminiRouteResponse?> search() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final query = '${state.from} to ${state.to}';
      final response = await _gemini.resolveRoute(query);

      if (response.ambiguous) {
        state = state.copyWith(
          isLoading: false,
          error: response.clarificationNeeded,
        );
        return null;
      }

      final existing = _hive
          .getRecentRoutes(limit: 100)
          .where((r) =>
              r.originLabel.toLowerCase() == response.origin.label.toLowerCase() &&
              r.destinationLabel.toLowerCase() ==
                  response.destination.label.toLowerCase())
          .toList();

      for (final dupe in existing) {
        await dupe.delete();
      }

      await _hive.saveRoute(RouteResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        originLabel: response.origin.label,
        destinationLabel: response.destination.label,
        stopLabels: response.stops.map((s) => s.label).toList(),
        summary: response.summary,
        searchedAt: DateTime.now(),
        originalQuery: '${state.from} to ${state.to}',
      ));

      await _hive.saveLandmark(Landmark(
        localName: response.origin.label.toLowerCase(),
        geocodeQuery: response.origin.query,
      ));
      await _hive.saveLandmark(Landmark(
        localName: response.destination.label.toLowerCase(),
        geocodeQuery: response.destination.query,
      ));

      _loadCached();

      state = state.copyWith(isLoading: false);
      return response;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong. Try again.',
      );
      return null;
    }
  }

  Future<GeminiRouteResponse?> requery(RouteResult route) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _gemini.resolveRoute(route.originalQuery);
      state = state.copyWith(isLoading: false);
      return response;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Something went wrong. Try again.',
      );
      return null;
    }
  }
}

final homeControllerProvider =
    StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController(HiveService());
});