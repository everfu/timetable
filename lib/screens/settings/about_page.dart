import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_design_tokens.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _version = '1.0.0';
  static const _author = '伍拾柒';
  static const _repo = 'https://github.com/everfu/timetable';
  static const _license = 'AGPL-3.0';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppTDColors.textPrimaryDark
        : AppTDColors.textPrimary;
    final textSecondary = isDark
        ? AppTDColors.textSecondaryDark
        : AppTDColors.textSecondary;
    final textPlaceholder = isDark
        ? AppTDColors.textPlaceholderDark
        : AppTDColors.textPlaceholder;
    final textDisabled = isDark
        ? AppTDColors.textDisabledDark
        : AppTDColors.textDisabled;
    final brand = AppTDColors.brandColor7;

    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          const SizedBox(height: 16),

          // ─── Logo + 名称 + 版本 ───
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/icon.png',
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              '江软课',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'v$_version',
              style: TextStyle(fontSize: 13, color: textPlaceholder),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '江西软件职业技术大学课表',
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
          ),

          const SizedBox(height: 32),

          // ─── 开源协议 ───
          _buildSectionLabel('开源协议', brand),
          const SizedBox(height: 6),
          _buildParagraph(
            '本项目基于 GNU Affero General Public License v3.0 '
            '($_license) 开源发布。',
            textSecondary,
          ),
          const SizedBox(height: 6),
          _buildParagraph(
            '你可以自由地使用、复制、修改和分发本软件及其源代码，'
            '但必须满足以下条件：',
            textSecondary,
          ),
          const SizedBox(height: 6),
          _buildBullet('修改后的代码必须以相同的 AGPL-3.0 协议开源。', textSecondary),
          _buildBullet('如果你通过网络提供基于本软件的服务，必须向用户公开完整的源代码。', textSecondary),
          _buildBullet('必须保留原始的版权声明和许可证信息。', textSecondary),
          const SizedBox(height: 6),
          _buildParagraph(
            '完整协议文本请参阅：\nhttps://www.gnu.org/licenses/agpl-3.0.html',
            textPlaceholder,
          ),

          const SizedBox(height: 24),

          // ─── 作者 ───
          _buildSectionLabel('作者', brand),
          const SizedBox(height: 6),
          Text(
            _author,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
          ),

          const SizedBox(height: 24),

          // ─── 源代码 ───
          _buildSectionLabel('源代码', brand),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              Clipboard.setData(const ClipboardData(text: _repo));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已复制仓库地址'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _repo,
                    style: TextStyle(
                      fontSize: 14,
                      color: brand,
                      decoration: TextDecoration.underline,
                      decorationColor: brand.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.copy, size: 14, color: textPlaceholder),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ─── 隐私政策 ───
          _buildSectionLabel('隐私政策', brand),
          const SizedBox(height: 6),
          _buildBullet('本应用主要用于个人课表管理，所有数据仅保存在本地设备中。', textSecondary),
          _buildBullet('应用不会主动收集、上传或共享任何用户数据。', textSecondary),
          _buildBullet('仅在用户主动选择文件时读取相关内容，用于解析课表信息。', textSecondary),
          _buildBullet('用户可随时通过设置页清空本地所有数据。', textSecondary),

          const SizedBox(height: 24),

          // ─── 致谢 ───
          _buildSectionLabel('致谢', brand),
          const SizedBox(height: 6),
          _buildParagraph('感谢以下开源项目的支持：', textSecondary),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildTechTag('Flutter', isDark),
              _buildTechTag('TDesign Flutter', isDark),
              _buildTechTag('SQLite', isDark),
              _buildTechTag('Dart', isDark),
            ],
          ),
          const SizedBox(height: 6),
          _buildParagraph('感谢所有开源社区的贡献者，让这个项目成为可能。', textSecondary),

          const SizedBox(height: 36),

          // ─── 底部版权 ───
          Divider(color: isDark ? AppTDColors.strokeDark : AppTDColors.stroke),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Copyright \u00A9 2026 $_author',
              style: TextStyle(fontSize: 12, color: textDisabled),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Licensed under $_license',
              style: TextStyle(fontSize: 11, color: textDisabled),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Made with Flutter',
              style: TextStyle(fontSize: 11, color: textDisabled),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, Color color) {
    return Text(
      text,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
    );
  }

  Widget _buildParagraph(String text, Color color) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, height: 1.7, color: color),
    );
  }

  Widget _buildBullet(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 8),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.5),
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, height: 1.6, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechTag(String name, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppTDColors.gray12 : AppTDColors.gray1,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark
              ? AppTDColors.textSecondaryDark
              : AppTDColors.textSecondary,
        ),
      ),
    );
  }
}
