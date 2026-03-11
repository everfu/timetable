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
        padding: EdgeInsets.fromLTRB(
          AppDimens.spaceL,
          0,
          AppDimens.spaceL,
          AppDimens.bottomNavReservedHeight(context),
        ),
        children: [
          // 装饰性 header 卡片
          _buildHeaderCard(isDark, colorScheme),
          const SizedBox(height: 16),

          // 数据与学期
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              boxShadow: AppShadows.cardSubtle(isDark),
            ),
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
          const SizedBox(height: 16),

          // 关于与帮助
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radiusM),
              boxShadow: AppShadows.cardSubtle(isDark),
            ),
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

  Widget _buildHeaderCard(bool isDark, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppGradients.primaryDark : AppGradients.primary,
        borderRadius: AppBorderRadius.featureCard,
        boxShadow: AppShadows.elevated(isDark),
      ),
      child: Stack(
        children: [
          // 装饰圆
          Positioned(
            top: -15,
            right: -5,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: 30,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // App 图标
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '江软课',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '江西软件职业技术大学课表',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.1,
        ),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 62,
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
