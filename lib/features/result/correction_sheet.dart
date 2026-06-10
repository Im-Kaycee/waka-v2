import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/gemini/gemini_service.dart';
import '../../core/storage/hive_service.dart';
import '../../models/correction.dart';

class CorrectionSheet extends ConsumerStatefulWidget {
  final List<RouteStop> stops;

  const CorrectionSheet({super.key, required this.stops});

  @override
  ConsumerState<CorrectionSheet> createState() => _CorrectionSheetState();
}

class _CorrectionSheetState extends ConsumerState<CorrectionSheet> {
  RouteStop? _selectedStop;
  final _correctedNameController = TextEditingController();
  final _hive = HiveService();
  bool _saved = false;

  @override
  void dispose() {
    _correctedNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F3EE),
          border: Border(
            top: BorderSide(color: Color(0xFF1a1a1a), width: 2.5),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'CORRECT A STOP',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1a1a1a),
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'TAP THE WRONG STOP BELOW',
                        style: TextStyle(
                          fontFamily: 'SpaceGrotesk',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF888780),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: const Color(0xFF1a1a1a), width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF1a1a1a),
                          offset: Offset(2, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Color(0xFF1a1a1a),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...widget.stops.map((stop) => _buildStopOption(stop)),
            if (_selectedStop != null) ...[
              const SizedBox(height: 20),
              const Text(
                'WHAT SHOULD IT BE?',
                style: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF888780),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: const Color(0xFF1a1a1a), width: 2),
                ),
                child: TextField(
                  controller: _correctedNameController,
                  autofocus: true,
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1a1a1a),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Berger Junction',
                    hintStyle: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 13,
                      color: Color(0xFFB4B2A9),
                    ),
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _saved ? null : _saveCorrection,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _saved
                        ? const Color(0xFF283618).withOpacity(0.6)
                        : const Color(0xFF283618),
                    border: Border.all(
                        color: const Color(0xFF1a1a1a), width: 2),
                    boxShadow: _saved
                        ? null
                        : const [
                            BoxShadow(
                              color: Color(0xFF1a1a1a),
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                  ),
                  child: Text(
                    _saved ? 'SAVED!' : 'SAVE CORRECTION',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFF5F3EE),
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildStopOption(RouteStop stop) {
    final isSelected = _selectedStop == stop;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedStop = isSelected ? null : stop;
        _correctedNameController.clear();
      }),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFCEBEB) : Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFFA32D2D)
                : const Color(0xFF1a1a1a),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFA32D2D)
                  : const Color(0xFF1a1a1a),
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stop.label,
                    style: TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFFA32D2D)
                          : const Color(0xFF1a1a1a),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    stop.instruction,
                    style: const TextStyle(
                      fontFamily: 'SpaceGrotesk',
                      fontSize: 11,
                      color: Color(0xFF888780),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.close,
                size: 14,
                color: Color(0xFFA32D2D),
              )
            else
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color(0xFFD3D1C7), width: 1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCorrection() async {
    final corrected = _correctedNameController.text.trim();
    if (_selectedStop == null || corrected.isEmpty) return;

    await _hive.saveCorrection(Correction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      originalName: _selectedStop!.label,
      correctedName: corrected,
      correctedGeocode: '$corrected, Abuja, Nigeria',
      createdAt: DateTime.now(),
    ));

    setState(() => _saved = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) Navigator.pop(context);
  }
}