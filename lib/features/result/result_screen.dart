import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/gemini/gemini_service.dart';
import '../../core/maps/maps_service.dart';
import 'correction_sheet.dart';
import '../../widgets/step_card.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final GeminiRouteResponse response;

  const ResultScreen({super.key, required this.response});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  final _mapsService = MapsService();
  List<LatLng> _points = [];
  LatLng? _origin;
  LatLng? _destination;
  bool _loadingMap = true;
  bool _showSteps = true;

  @override
  void initState() {
    super.initState();
    _geocodePoints();
  }

Future<void> _geocodePoints() async {
  final origin = await _mapsService.geocode(widget.response.origin.query);
  final destination = await _mapsService.geocode(widget.response.destination.query);


  if (origin != null && destination != null) {
    final geometry = await _mapsService.getRoadGeometry(origin, destination);
    if (mounted) {
      setState(() {
        _origin = origin;
        _destination = destination;
        _points = geometry;
        _loadingMap = false;
      });
    }
  } else {
    if (mounted) setState(() => _loadingMap = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildMap(),
            _buildToggle(),
            Expanded(
              child: _showSteps ? _buildSteps() : _buildOverview(),
            ),
            _buildWrongButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF283618),
        border: Border(
          bottom: BorderSide(color: Color(0xFF1a1a1a), width: 2.5),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3EE),
                border: Border.all(color: const Color(0xFF1a1a1a), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF1a1a1a),
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 16,
                color: Color(0xFF1a1a1a),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.response.origin.label} → ${widget.response.destination.label}'
                      .toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFF5F3EE),
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${widget.response.stops.length} stops',
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 11,
                    color: Color(0xFF8FAF6A),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_loadingMap) {
      return Container(
        height: 200,
        color: const Color(0xFFE8E6E0),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF283618),
            strokeWidth: 2,
          ),
        ),
      );
    }

    final center = _origin != null && _destination != null
        ? _mapsService.midpoint(_origin!, _destination!)
        : const LatLng(9.0579, 7.4951);

    final zoom = _origin != null && _destination != null
        ? _mapsService.boundingZoom(_origin!, _destination!)
        : 12.0;

    return Container(
      height: 200,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF1a1a1a), width: 2.5),
        ),
      ),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: zoom,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.yourname.waka',
          ),
          if (_points.length >= 2)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _points,
                  strokeWidth: 4,
                  color: const Color(0xFF283618),
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              if (_origin != null)
                Marker(
                  point: _origin!,
                  width: 20,
                  height: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1a1a1a),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFFF5F3EE), width: 2.5),
                    ),
                  ),
                ),
              if (_destination != null)
                Marker(
                  point: _destination!,
                  width: 20,
                  height: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF283618),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0xFF1a1a1a), width: 2.5),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          _toggleBtn('STEPS', _showSteps,
              () => setState(() => _showSteps = true)),
          const SizedBox(width: 8),
          _toggleBtn('OVERVIEW', !_showSteps,
              () => setState(() => _showSteps = false)),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF283618) : Colors.white,
            border: Border.all(color: const Color(0xFF1a1a1a), width: 2),
            boxShadow: active
                ? const [
                    BoxShadow(
                      color: Color(0xFF1a1a1a),
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: active
                  ? const Color(0xFFF5F3EE)
                  : const Color(0xFF1a1a1a),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSteps() {
  final stops = widget.response.stops;
  return ListView.builder(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
    itemCount: stops.length,
    itemBuilder: (context, i) => StepCard(
      index: i,
      instruction: stops[i].instruction,
      label: stops[i].label,
      transport: stops[i].transport,
      isLast: i == stops.length - 1,
    ),
  );
}

  Widget _buildOverview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF1a1a1a), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF1a1a1a),
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          widget.response.summary,
          style: const TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 14,
            color: Color(0xFF1a1a1a),
            height: 1.7,
          ),
        ),
      ),
    );
  }

  Widget _buildWrongButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF1a1a1a), width: 2),
        ),
      ),
      child: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: const Color(0xFFF5F3EE),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Color(0xFF1a1a1a), width: 2),
          ),
          builder: (_) => CorrectionSheet(stops: widget.response.stops),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFCEBEB),
            border: Border.all(color: const Color(0xFFA32D2D), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFA32D2D),
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 14,
                color: Color(0xFFA32D2D),
              ),
              SizedBox(width: 8),
              Text(
                'A STOP IS WRONG — CORRECT IT',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFA32D2D),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}