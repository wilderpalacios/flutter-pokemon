import 'package:flutter/material.dart';

class TypeChip extends StatelessWidget {
  final String type;

  const TypeChip({super.key, required this.type});

  static const _typeColors = {
    'fire':     Color(0xFFFF513D),
    'water':    Color(0xFF274DEA),
    'electric': Color(0xFFFFD600),
    'grass':    Color(0xFF5DAD5F),
    'poison':   Color(0xFF8B5CF6),
    'psychic':  Color(0xFFFF6B9D),
    'ice':      Color(0xFF74D7EE),
    'dragon':   Color(0xFF274DEA),
    'dark':     Color(0xFF3B2F2F),
    'fairy':    Color(0xFFFFB3C6),
    'fighting': Color(0xFFCC3300),
    'flying':   Color(0xFF8EB9FC),
    'ghost':    Color(0xFF6B4FA0),
    'bug':      Color(0xFF8BC34A),
    'rock':     Color(0xFF9E8B6B),
    'ground':   Color(0xFFD4A96A),
    'steel':    Color(0xFF90A4AE),
    'normal':   Color(0xFFBDBDBD),
  };

  static Color colorForType(String type) =>
      _typeColors[type] ?? const Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    final color = colorForType(type);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          type,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
