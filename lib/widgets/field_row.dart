import 'package:flutter/material.dart';

class FieldRow extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Color dotColor;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const FieldRow({
    super.key,
    required this.controller,
    required this.hint,
    required this.dotColor,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF1a1a1a), width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              border: dotColor != const Color(0xFF1a1a1a)
                  ? Border.all(color: const Color(0xFF1a1a1a), width: 2)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                fontFamily: 'SpaceGrotesk',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1a1a1a),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 13,
                  color: Color(0xFFB4B2A9),
                  fontWeight: FontWeight.w400,
                ),
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Icon(
              Icons.close,
              size: 14,
              color: Color(0xFFB4B2A9),
            ),
          ),
        ],
      ),
    );
  }
}