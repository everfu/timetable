import 'package:flutter/material.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('设置'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(AppDimens.spaceM),
        children: [
          Card(
            child: Column(
              children: [
                _buildNavTile(
                  context: context,
                  icon: Icons.storage_outlined,
                  iconColor: colorScheme.primary,
                  title: '数据管理',
                  subtitle: '导入课表、清空数据',
                  isDark: isDark,
                  page: DataManagementPage(onDataChanged: onDataChanged),
                ),
                _buildDivider(isDark),
                _buildNavTile(
                  context: context,
                  icon: Icons.calendar_today_outlined,
                  iconColor: Colors.orange,
                  title: '学期设置',
                  subtitle: '设置学期开始日期',
                  isDark: isDark,
                  page: SemesterSettingsPage(onDataChanged: onDataChanged),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.spaceM),
          Card(
            child: Column(
              children: [
                _buildNavTile(
                  context: context,
                  icon: Icons.info_outline,
                  iconColor: Colors.grey,
                  title: '关于',
                  subtitle: '作者、版本、隐私与版权',
                  isDark: isDark,
                  page: const AboutPage(),
                ),
                _buildDivider(isDark),
                _buildNavTile(
                  context: context,
                  icon: Icons.help_outline,
                  iconColor: Colors.teal,
                  title: '帮助与反馈',
                  subtitle: '常见问题与意见反馈',
                  isDark: isDark,
                  onTap: () => _showHelpFeedback(context),
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
    Widget? page,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white38 : Colors.black45,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        size: 20,
        color: isDark ? Colors.white24 : Colors.black26,
      ),
      onTap: onTap ?? (page != null ? () => _push(context, page) : null),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 58,
      color: isDark ? Colors.white10 : const Color(0xFFE5E5EA),
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
