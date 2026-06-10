import 'package:flutter/material.dart';
import 'transport_pill.dart';

class StepCard extends StatelessWidget {
  final int index;
  final String instruction;
  final String label;
  final String transport;
  final bool isLast;

  const StepCard({
    super.key,
    required this.index,
    required this.instruction,
    required this.label,
    required this.transport,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isHighlight = index == 1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isHighlight
                    ? const Color(0xFF283618)
                    : Colors.white,
                border: Border.all(
                  color: const Color(0xFF1a1a1a),
                  width: 2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF1a1a1a),
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isHighlight
                        ? const Color(0xFFF5F3EE)
                        : const Color(0xFF1a1a1a),
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 52,
                color: const Color(0xFF1a1a1a),
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: const Color(0xFF1a1a1a), width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF1a1a1a),
                  offset: Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instruction,
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1a1a1a),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'SpaceGrotesk',
                    fontSize: 11,
                    color: Color(0xFF888780),
                  ),
                ),
                const SizedBox(height: 8),
                TransportPill(label: transport),
              ],
            ),
          ),
        ),
      ],
    );
  }
}