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

/// 柔和阴影 — 参考 Best-Flutter-UI-Templates
class AppShadows {
  static List<BoxShadow> card(bool isDark) => [
    BoxShadow(
      color: isDark
          ? Colors.black.withValues(alpha: 0.25)
          : Colors.grey.withValues(alpha: 0.15),
      offset: const Offset(1.1, 1.1),
      blurRadius: 10.0,
    ),
  ];

  static List<BoxShadow> cardSubtle(bool isDark) => [
    BoxShadow(
      color: isDark
          ? Colors.black.withValues(alpha: 0.18)
          : Colors.grey.withValues(alpha: 0.08),
      offset: const Offset(0, 2),
      blurRadius: 8.0,
    ),
  ];

  static List<BoxShadow> elevated(bool isDark) => [
    BoxShadow(
      color: isDark
          ? Colors.black.withValues(alpha: 0.35)
          : Colors.grey.withValues(alpha: 0.2),
      offset: const Offset(1.1, 1.1),
      blurRadius: 16.0,
    ),
  ];
}

/// 渐变色
class AppGradients {
  // 主色渐变（蓝紫）
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B6CF0), Color(0xFF8B5CF6)],
  );

  // 暖色渐变（橙粉）
  static const warm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFFFAB76)],
  );

  // 冷色渐变（蓝青）
  static const cool = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
  );

  // 深色模式主色渐变
  static const primaryDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3D4DB7), Color(0xFF6D3FC0)],
  );

  // 课程高亮渐变
  static const courseHighlight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );

  static const courseHighlightDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A5BC7), Color(0xFF5E3A8A)],
  );
}

/// 不对称圆角 — 参考 Best-Flutter-UI-Templates 的特色设计
class AppBorderRadius {
  /// 右上角大圆角卡片
  static final featureCard = BorderRadius.only(
    topLeft: Radius.circular(AppDimens.radiusM),
    bottomLeft: Radius.circular(AppDimens.radiusM),
    bottomRight: Radius.circular(AppDimens.radiusM),
    topRight: Radius.circular(48),
  );

  /// 标准圆角
  static final standard = BorderRadius.circular(AppDimens.radiusM);
}
