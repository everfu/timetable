import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String _appVersion = '1.0.0';
  static const String _authorName = '伍拾柒';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                _buildTile(
                  icon: Icons.person_outline,
                  iconColor: colorScheme.primary,
                  title: '作者',
                  subtitle: _authorName,
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildTile(
                  icon: Icons.info_outline,
                  iconColor: Colors.grey,
                  title: '版本',
                  subtitle: _appVersion,
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildTile(
                  icon: Icons.privacy_tip_outlined,
                  iconColor: Colors.green,
                  title: '隐私权益',
                  subtitle: '查看应用数据与隐私说明',
                  onTap: () => _showPrivacyDialog(context),
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildTile(
                  icon: Icons.copyright_outlined,
                  iconColor: Colors.deepPurple,
                  title: '版权声明',
                  subtitle: '查看版权与使用说明',
                  onTap: () => _showCopyrightDialog(context),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showInfoDialog(
    BuildContext context, {
    required String title,
    required List<String> items,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text('• $item'),
                  ),
                )
                .toList(),
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

  Future<void> _showPrivacyDialog(BuildContext context) {
    return _showInfoDialog(
      context,
      title: '隐私权益',
      items: const [
        '本应用主要用于个人课表管理。',
        '用户导入的课表文件与课程数据默认仅保存在本地设备中，不会主动上传至服务器。',
        '应用仅在用户主动选择文件时读取相关内容，用于解析课表信息。',
        '用户可随时通过设置页清空本地课程数据。',
      ],
    );
  }

  Future<void> _showCopyrightDialog(BuildContext context) {
    return _showInfoDialog(
      context,
      title: '版权声明',
      items: const [
        '本应用的界面设计、功能实现及相关内容著作权归作者所有。',
        '本应用仅供学习、交流与个人使用，未经授权不得用于商业用途。',
        '应用所使用的第三方开源组件，其版权归各自作者或组织所有。',
      ],
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    final hasAction = onTap != null;
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
          color: hasAction
              ? (isDark ? Colors.white38 : Colors.black45)
              : (isDark ? Colors.white70 : Colors.black87),
        ),
      ),
      trailing: hasAction
          ? Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark ? Colors.white24 : Colors.black26,
            )
          : null,
      onTap: onTap,
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
}
