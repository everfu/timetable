import 'package:flutter/material.dart';
import '../models/task.dart';

class AppColors {
  static const seed = Color(0xFF5B6CF0);

  static const priorityHigh = Color(0xFFEF4444);
  static const priorityMedium = Color(0xFFF59E0B);
  static const priorityLow = Color(0xFF9CA3AF);

  static const typeHomework = Color(0xFF3B82F6);
  static const typeExam = Color(0xFFEF4444);
  static const typeReview = Color(0xFF10B981);
  static const typeOther = Color(0xFF6B7280);

  static Color priorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return priorityHigh;
      case TaskPriority.medium:
        return priorityMedium;
      case TaskPriority.low:
        return priorityLow;
    }
  }

  static Color typeColor(TaskType type) {
    switch (type) {
      case TaskType.homework:
        return typeHomework;
      case TaskType.exam:
        return typeExam;
      case TaskType.review:
        return typeReview;
      case TaskType.other:
        return typeOther;
    }
  }
}

class AppDimens {
  static const radiusS = 8.0;
  static const radiusM = 12.0;
  static const radiusL = 16.0;
  static const radiusXL = 20.0;
  static const radiusRound = 24.0;

  static const spaceXS = 4.0;
  static const spaceS = 8.0;
  static const spaceM = 12.0;
  static const spaceL = 16.0;
  static const spaceXL = 20.0;
  static const spaceXXL = 24.0;

  static const floatingNavHeight = 64.0;
  static const floatingNavBottomMargin = 16.0;
  static const floatingNavContentGap = 24.0;

  static double bottomNavReservedHeight(BuildContext context) {
    return MediaQuery.of(context).padding.bottom +
        floatingNavHeight +
        floatingNavBottomMargin +
        floatingNavContentGap;
  }
}
