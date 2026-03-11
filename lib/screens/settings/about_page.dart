import 'package:flutter/material.dart';
import '../../theme/app_design_tokens.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String _appVersion = '1.0.0';
  static const String _authorName = '伍拾柒';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          const SizedBox(height: 20),

          // Logo
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark
                    ? AppTDColors.brandColor7.withValues(alpha: 0.15)
                    : AppTDColors.brandColor1,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.school_outlined,
                size: 36,
                color: AppTDColors.brandColor7,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // App 名称
          Center(
            child: Text(
              '江软课',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppTDColors.textPrimaryDark
                    : AppTDColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'v$_appVersion',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppTDColors.textPlaceholderDark
                    : AppTDColors.textPlaceholder,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              '江西软件职业技术大学课表',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppTDColors.textSecondaryDark
                    : AppTDColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(height: 36),

          // 作者
          _buildLabel('作者', isDark),
          const SizedBox(height: 4),
          Text(
            _authorName,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppTDColors.textPrimaryDark
                  : AppTDColors.textPrimary,
            ),
          ),

          const SizedBox(height: 24),

          // 隐私权益
          _buildLabel('隐私权益', isDark),
          const SizedBox(height: 6),
          _buildParagraph(
            '本应用主要用于个人课表管理。用户导入的课表文件与课程数据默认仅保存在本地设备中，'
            '不会主动上传至服务器。应用仅在用户主动选择文件时读取相关内容，用于解析课表信息。'
            '用户可随时通过设置页清空本地课程数据。',
            isDark,
          ),

          const SizedBox(height: 24),

          // 版权声明
          _buildLabel('版权声明', isDark),
          const SizedBox(height: 6),
          _buildParagraph(
            '本应用的界面设计、功能实现及相关内容著作权归作者所有。'
            '本应用仅供学习、交流与个人使用，未经授权不得用于商业用途。'
            '应用所使用的第三方开源组件，其版权归各自作者或组织所有。',
            isDark,
          ),

          const SizedBox(height: 40),

          // 底部
          Center(
            child: Text(
              'Made with Flutter',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppTDColors.textDisabledDark
                    : AppTDColors.textDisabled,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTDColors.brandColor7,
      ),
    );
  }

  Widget _buildParagraph(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.7,
        color: isDark
            ? AppTDColors.textSecondaryDark
            : AppTDColors.textSecondary,
      ),
    );
  }
}
