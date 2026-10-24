import 'package:flutter/material.dart';

class SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const SectionLabel({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}
