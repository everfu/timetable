import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_design_tokens.dart';

class TypeChip extends StatelessWidget {
  final TaskType type;

  const TypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.typeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        type.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
