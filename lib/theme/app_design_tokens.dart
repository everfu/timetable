import 'package:flutter/material.dart';
import '../models/task.dart';

/// TDesign 品牌色阶
class AppTDColors {
  // 品牌色阶 (TDesign Blue)
  static const brandColor1 = Color(0xFFF2F3FF);
  static const brandColor2 = Color(0xFFD9E1FF);
  static const brandColor3 = Color(0xFFB5C7FF);
  static const brandColor4 = Color(0xFF8EABFF);
  static const brandColor5 = Color(0xFF618DFF);
  static const brandColor6 = Color(0xFF366EF4);
  static const brandColor7 = Color(0xFF0052D9); // brandNormalColor
  static const brandColor8 = Color(0xFF003CAB);

  // 功能色
  static const errorColor = Color(0xFFD54941);
  static const warningColor = Color(0xFFE37318);
  static const successColor = Color(0xFF2BA471);

  // 灰阶
  static const gray1 = Color(0xFFF3F3F3);
  static const gray2 = Color(0xFFEEEEEE);
  static const gray3 = Color(0xFFE8E8E8);
  static const gray4 = Color(0xFFDDDDDD);
  static const gray5 = Color(0xFFC6C6C6);
  static const gray6 = Color(0xFFA6A6A6);
  static const gray7 = Color(0xFF8B8B8B);
  static const gray8 = Color(0xFF777777);
  static const gray9 = Color(0xFF5E5E5E);
  static const gray10 = Color(0xFF4B4B4B);
  static const gray11 = Color(0xFF393939);
  static const gray12 = Color(0xFF2C2C2C);
  static const gray13 = Color(0xFF242424);
  static const gray14 = Color(0xFF181818);

  // 文字色 (浅色模式)
  static const textPrimary = Color(0xE5000000); // 90%
  static const textSecondary = Color(0x99000000); // 60%
  static const textPlaceholder = Color(0x66000000); // 40%
  static const textDisabled = Color(0x42000000); // 26%

  // 文字色 (深色模式)
  static const textPrimaryDark = Color(0xFFFFFFFF);
  static const textSecondaryDark = Color(0x8CFFFFFF); // 55%
  static const textPlaceholderDark = Color(0x59FFFFFF); // 35%
  static const textDisabledDark = Color(0x38FFFFFF); // 22%

  // 背景色
  static const bgPage = Color(0xFFF3F3F3);
  static const bgContainer = Color(0xFFFFFFFF);
  static const bgPageDark = Color(0xFF181818);
  static const bgContainerDark = Color(0xFF242424);
  static const bgSecondaryDark = Color(0xFF2C2C2C);

  // 分割线
  static const stroke = Color(0xFFE8E8E8);
  static const strokeDark = Color(0xFF393939);
}

/// 任务相关颜色（保留）
class AppColors {
  static const seed = Color(0xFF0052D9);

  static const priorityHigh = Color(0xFFD54941);
  static const priorityMedium = Color(0xFFE37318);
  static const priorityLow = Color(0xFF9CA3AF);

  static const typeHomework = Color(0xFF0052D9);
  static const typeExam = Color(0xFFD54941);
  static const typeReview = Color(0xFF2BA471);
  static const typeOther = Color(0xFF8B8B8B);

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

/// TDesign 圆角体系
class AppRadius {
  static const small = 3.0;
  static const medium = 6.0;
  static const large = 9.0;
  static const extraLarge = 12.0;
  static const round = 999.0;
}

/// TDesign 间距体系
class AppSpacing {
  static const s4 = 4.0;
  static const s8 = 8.0;
  static const s12 = 12.0;
  static const s16 = 16.0;
  static const s24 = 24.0;
  static const s32 = 32.0;
  static const s40 = 40.0;
  static const s48 = 48.0;
}

/// TDesign 阴影体系
class TDShadows {
  static List<BoxShadow> base(bool isDark) => isDark
      ? []
      : const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 5,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ];

  static List<BoxShadow> middle(bool isDark) => isDark
      ? []
      : const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 14,
            spreadRadius: 2,
            offset: Offset(0, 3),
          ),
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 8),
          ),
        ];

  static List<BoxShadow> top(bool isDark) => isDark
      ? []
      : const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 30,
            spreadRadius: 5,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            spreadRadius: -5,
            offset: Offset(0, 8),
          ),
        ];
}

/// 兼容旧代码的别名
class AppDimens {
  static const radiusS = AppRadius.small;
  static const radiusM = AppRadius.extraLarge;
  static const radiusL = 16.0;

  static const spaceXS = AppSpacing.s4;
  static const spaceS = AppSpacing.s8;
  static const spaceM = AppSpacing.s12;
  static const spaceL = AppSpacing.s16;
  static const spaceXL = AppSpacing.s24;

  static const floatingNavHeight = 56.0;
  static const floatingNavBottomMargin = 16.0;
  static const floatingNavContentGap = 20.0;

  static double bottomNavReservedHeight(BuildContext context) {
    return MediaQuery.of(context).padding.bottom +
        floatingNavHeight +
        floatingNavBottomMargin +
        floatingNavContentGap;
  }
}
