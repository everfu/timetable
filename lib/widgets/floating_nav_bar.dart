import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_design_tokens.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(Icons.today_outlined, Icons.today, '今日'),
    _NavItem(Icons.table_chart_outlined, Icons.table_chart, '课表'),
    _NavItem(Icons.settings_outlined, Icons.settings, '设置'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brand = AppTDColors.brandColor7;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.round),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: AppDimens.floatingNavHeight,
            decoration: BoxDecoration(
              color: isDark
                  ? AppTDColors.bgSecondaryDark.withValues(alpha: 0.88)
                  : AppTDColors.bgContainer.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(AppRadius.round),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                _items.length,
                (i) => _buildItem(context, i, _items[i], isDark, brand),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    _NavItem item,
    bool isDark,
    Color brand,
  ) {
    final selected = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? (isDark
                    ? brand.withValues(alpha: 0.15)
                    : AppTDColors.brandColor1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                selected ? item.activeIcon : item.icon,
                key: ValueKey(selected),
                size: 22,
                color: selected
                    ? brand
                    : (isDark ? AppTDColors.gray7 : AppTDColors.gray6),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: selected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: brand,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}
