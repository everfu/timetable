import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../theme/app_design_tokens.dart';
import 'settings/data_management_page.dart';
import 'settings/semester_settings_page.dart';
import 'settings/about_page.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onDataChanged;

  const SettingsScreen({super.key, required this.onDataChanged});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('设置'), centerTitle: true),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.s16,
          0,
          AppSpacing.s16,
          AppDimens.bottomNavReservedHeight(context),
        ),
        children: [
          // App 信息头部
          _buildAppHeader(isDark),
          const SizedBox(height: AppSpacing.s16),

          // 数据与学期
          _buildGroup(
            isDark: isDark,
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
              _buildDivider(isDark),
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
          const SizedBox(height: AppSpacing.s12),

          // 关于与帮助
          _buildGroup(
            isDark: isDark,
            children: [
              _buildNavTile(
                context: context,
                icon: TDIcons.info_circle,
                iconColor: AppTDColors.gray7,
                title: '关于',
                subtitle: '作者、版本、隐私与版权',
                isDark: isDark,
                page: const AboutPage(),
              ),
              _buildDivider(isDark),
              _buildNavTile(
                context: context,
                icon: TDIcons.help_circle,
                iconColor: AppTDColors.successColor,
                title: '帮助与反馈',
                subtitle: '常见问题与意见反馈',
                isDark: isDark,
                onTap: () => _showHelpFeedback(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark ? AppTDColors.bgContainerDark : AppTDColors.bgContainer,
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        boxShadow: TDShadows.base(isDark),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTDColors.brandColor1,
              borderRadius: BorderRadius.circular(AppRadius.extraLarge),
            ),
            child: Icon(
              TDIcons.education,
              color: AppTDColors.brandColor7,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '江软课',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTDColors.textPrimaryDark
                        : AppTDColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '江西软件职业技术大学课表',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppTDColors.textPlaceholderDark
                        : AppTDColors.textPlaceholder,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? AppTDColors.gray12 : AppTDColors.gray1,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: Text(
              'v1.0.0',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppTDColors.textSecondaryDark
                    : AppTDColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroup({required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTDColors.bgContainerDark : AppTDColors.bgContainer,
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        boxShadow: TDShadows.base(isDark),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildNavTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    Widget? page,
    VoidCallback? onTap,
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
      onTap: onTap ?? (page != null ? () => _push(context, page) : null),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 62,
      color: isDark ? AppTDColors.strokeDark : AppTDColors.stroke,
    );
  }

  void _showHelpFeedback(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('帮助与反馈'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('常见问题', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text('• 支持 .xls 和 .xlsx 格式的课表文件导入。'),
              SizedBox(height: 4),
              Text('• 导入前请确保文件格式正确，否则可能无法解析。'),
              SizedBox(height: 4),
              Text('• 如遇到问题，可尝试清空数据后重新导入。'),
              SizedBox(height: 16),
              Text('意见反馈', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 8),
              Text('如有建议或问题，欢迎通过应用内渠道联系我们。'),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('我知道了'),
          ),
        ],
      ),
    );
  }
}
