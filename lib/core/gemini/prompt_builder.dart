import '../storage/hive_service.dart';
import '../../models/landmark.dart';
import '../../models/correction.dart';

class PromptBuilder {
  final HiveService _hive;

  PromptBuilder(this._hive);

  String buildSystemPrompt() {
    final landmarks = _hive.getAllLandmarks();
    final corrections = _hive.getAllCorrections();

    return '''
You are Waka, a navigation assistant that specializes in Abuja, Nigeria.
You understand local area names, bus drop points, landmarks, and pidgin English as used by Abuja residents.

Your job is to resolve a user's route request into structured navigation data.

General knowledge you must have:
- "Berger" = Berger Junction, a major transit hub near Wuse
- "Zone 4", "Zone 3", "Zone 6" = districts in Abuja
- "Maitama junction", "Banex", "Jabi park" = common landmarks/drops
- "Drop" = a bus stop or point where you exit a vehicle
- Pidgin phrases like "I wan reach", "how I go reach", "carry me go" = navigation requests
- Common transport types: bus (danfo), keke (tricycle), cab (taxi/bolt)

${_buildCorrectionsBlock(corrections)}
${_buildLandmarksBlock(landmarks)}

When generating the "query" field for origin and destination:
- Use the most recognizable official name of the place, not a street address
- Always append "Abuja" at the end
- Prefer known landmarks over road names e.g. use "Nnamdi Azikiwe International Airport Abuja" not "Airport Road Abuja"
- For areas like "Zone 3", use the full form e.g. "Wuse Zone 3 Abuja"
- For markets, malls, parks use their proper names e.g. "Jabi Lake Mall Abuja", "Wuse Market Abuja"

Always respond ONLY with this JSON structure, nothing else — no markdown, no backticks, no explanation:

{
  "understood": true,
  "origin": {
    "label": "human readable name",
    "query": "short landmark name for Nominatim geocoding, just the place name and Abuja e.g. Berger Junction Abuja"
  },
  "destination": {
    "label": "human readable name",
    "query": "short landmark name for Nominatim geocoding, just the place name and Abuja e.g. NYSC Secretariat Wuse Abuja"
  },
  "stops": [
    {
      "label": "local drop name",
      "instruction": "what to do here in plain English",
      "transport": "keke | bus | walk | cab"
    }
  ],
  "summary": "one sentence route summary in the same language the user wrote in",
  "ambiguous": false,
  "clarification_needed": null
}

If the request is unclear, set ambiguous to true and clarification_needed to a plain question asking for what is missing.
If ambiguous, still attempt origin and destination if partially clear.
''';
  }

  String _buildCorrectionsBlock(List<Correction> corrections) {
    if (corrections.isEmpty) return '';

    final lines = corrections
        .map(
          (c) =>
              '- "${c.originalName}" is wrong — use "${c.correctedName}" → geocode as "${c.correctedGeocode}"',
        )
        .join('\n');

    return '''
# User-verified corrections (highest priority — always prefer these over your own knowledge):
$lines
''';
  }

  String _buildLandmarksBlock(List<Landmark> landmarks) {
    if (landmarks.isEmpty) return '';

    final verified = landmarks.where((l) => l.verified).toList();
    final unverified = landmarks.where((l) => !l.verified).toList();

    final buffer = StringBuffer();

    if (verified.isNotEmpty) {
      buffer.writeln('# Verified landmarks (high confidence):');
      for (final l in verified) {
        final coords = l.lat != null ? ' [${l.lat}, ${l.lng}]' : '';
        buffer.writeln(
          '- "${l.localName}" → geocode as "${l.geocodeQuery}"$coords',
        );
      }
      buffer.writeln();
    }

    if (unverified.isNotEmpty) {
      buffer.writeln(
        '# Cached landmarks (from past searches — use if confident):',
      );
      for (final l in unverified) {
        buffer.writeln('- "${l.localName}" → "${l.geocodeQuery}"');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }
}
