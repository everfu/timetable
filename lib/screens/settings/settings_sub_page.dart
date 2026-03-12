import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../../theme/app_design_tokens.dart';
import 'data_management_page.dart';
import 'semester_settings_page.dart';

class SettingsSubPage extends StatelessWidget {
  final VoidCallback onDataChanged;

  const SettingsSubPage({super.key, required this.onDataChanged});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('设置'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.s16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppTDColors.bgContainerDark
                  : AppTDColors.bgContainer,
              borderRadius: BorderRadius.circular(AppRadius.extraLarge),
              boxShadow: TDShadows.base(isDark),
            ),
            child: Column(
              children: [
                _buildNavTile(
                  context: context,
                  icon: TDIcons.server,
                  iconColor: AppTDColors.brandColor7,
                  title: '数据管理',
                  subtitle: '导入课表、清空数据',
                  isDark: isDark,
                  page: DataManagementPage(onDataChanged: onDataChanged),
                ),
                Divider(
                  height: 1,
                  indent: 62,
                  color: isDark ? AppTDColors.strokeDark : AppTDColors.stroke,
                ),
                _buildNavTile(
                  context: context,
                  icon: TDIcons.calendar,
                  iconColor: AppTDColors.warningColor,
                  title: '学期设置',
                  subtitle: '设置学期开始日期',
                  isDark: isDark,
                  page: SemesterSettingsPage(onDataChanged: onDataChanged),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required Widget page,
  }) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.large),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? AppTDColors.textPrimaryDark : AppTDColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark
              ? AppTDColors.textPlaceholderDark
              : AppTDColors.textPlaceholder,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 20,
        color: isDark ? AppTDColors.gray11 : AppTDColors.gray5,
      ),
      onTap: () => _push(context, page),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    );
  }
}
