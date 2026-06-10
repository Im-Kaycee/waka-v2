import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'prompt_builder.dart';
import '../../models/route_result.dart';

class GeminiService {
  final PromptBuilder _promptBuilder;
  late final GenerativeModel _model;

  GeminiService(this._promptBuilder, String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-3.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.1,
        responseMimeType: 'application/json',
      ),
    );
  }

  Future<GeminiRouteResponse> resolveRoute(String userQuery) async {
    final systemPrompt = _promptBuilder.buildSystemPrompt();

    final response = await _model.generateContent([
      Content.system(systemPrompt),
      Content.text(userQuery),
    ]);

    final raw = response.text;

    if (raw == null || raw.isEmpty) {
      throw Exception('Empty response from Gemini');
    }

    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return GeminiRouteResponse.fromJson(json);
    } catch (e) {
      throw Exception('Failed to parse Gemini response: $e\n\nRaw: $raw');
    }
  }
}

class GeminiRouteResponse {
  final bool understood;
  final RouteLocation origin;
  final RouteLocation destination;
  final List<RouteStop> stops;
  final String summary;
  final bool ambiguous;
  final String? clarificationNeeded;

  GeminiRouteResponse({
    required this.understood,
    required this.origin,
    required this.destination,
    required this.stops,
    required this.summary,
    required this.ambiguous,
    this.clarificationNeeded,
  });

  factory GeminiRouteResponse.fromJson(Map<String, dynamic> json) {
    return GeminiRouteResponse(
      understood: json['understood'] ?? false,
      origin: RouteLocation.fromJson(json['origin']),
      destination: RouteLocation.fromJson(json['destination']),
      stops: (json['stops'] as List<dynamic>? ?? [])
          .map((s) => RouteStop.fromJson(s as Map<String, dynamic>))
          .toList(),
      summary: json['summary'] ?? '',
      ambiguous: json['ambiguous'] ?? false,
      clarificationNeeded: json['clarification_needed'],
    );
  }
}

class RouteLocation {
  final String label;
  final String query;

  RouteLocation({required this.label, required this.query});

  factory RouteLocation.fromJson(Map<String, dynamic> json) {
    return RouteLocation(
      label: json['label'] ?? '',
      query: json['query'] ?? '',
    );
  }
}

class RouteStop {
  final String label;
  final String instruction;
  final String transport;

  RouteStop({
    required this.label,
    required this.instruction,
    required this.transport,
  });

  factory RouteStop.fromJson(Map<String, dynamic> json) {
    return RouteStop(
      label: json['label'] ?? '',
      instruction: json['instruction'] ?? '',
      transport: json['transport'] ?? 'cab',
    );
  }
}