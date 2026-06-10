import 'package:flutter/material.dart';

class TransportPill extends StatelessWidget {
  final String label;

  const TransportPill({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3EE),
        border: Border.all(color: const Color(0xFF1a1a1a), width: 1.5),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1a1a1a),
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}