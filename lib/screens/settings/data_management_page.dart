import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../database/database_helper.dart';
import '../../models/course.dart';
import '../../services/widget_sync_service.dart';
import '../../services/xlsx_parser.dart';

class DataManagementPage extends StatefulWidget {
  final VoidCallback onDataChanged;

  const DataManagementPage({super.key, required this.onDataChanged});

  @override
  State<DataManagementPage> createState() => _DataManagementPageState();
}

class _DataManagementPageState extends State<DataManagementPage> {
  final DatabaseHelper _db = DatabaseHelper();
  int _courseCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final courses = await _db.getAllCourses();
    setState(() => _courseCount = courses.length);
  }

  Future<void> _importXlsx() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );
      if (result == null || result.files.isEmpty) return;

      List<Course> courses;
      final file = result.files.first;

      if (file.path != null) {
        courses = await XlsxParser.parseFile(file.path!);
      } else if (file.bytes != null) {
        courses = XlsxParser.parseBytes(file.bytes!);
      } else {
        _showSnackBar('无法读取文件');
        return;
      }

      if (courses.isEmpty) {
        _showSnackBar('未解析到课程数据，请检查文件格式');
        return;
      }

      if (_courseCount > 0 && mounted) {
        final replace = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('导入课表'),
            content: Text('解析到 ${courses.length} 门课程。\n是否替换现有课表？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('替换'),
              ),
            ],
          ),
        );
        if (replace != true) return;
      }

      await _db.clearAllCourses();
      await _db.insertCourses(courses);
      await _loadData();
      widget.onDataChanged();
      await WidgetSyncService.syncAll();
      _showSnackBar('成功导入 ${courses.length} 门课程');
    } catch (e) {
      _showSnackBar('导入失败: $e');
    }
  }

  Future<void> _clearAllCourses() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空课表'),
        content: const Text('确定要清空所有课程数据吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _db.clearAllCourses();
      await _loadData();
      widget.onDataChanged();
      await WidgetSyncService.syncAll();
      _showSnackBar('已清空所有课程');
    }
  }

  void _showSnackBar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('数据管理')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                _buildTile(
                  icon: Icons.file_upload_outlined,
                  iconColor: colorScheme.primary,
                  title: '导入课表',
                  subtitle: '支持 .xls / .xlsx 格式',
                  onTap: _importXlsx,
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildTile(
                  icon: Icons.delete_outline,
                  iconColor: Colors.red,
                  title: '清空课表',
                  subtitle: '$_courseCount 门课程',
                  onTap: _courseCount > 0 ? _clearAllCourses : null,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
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
    final enabled = onTap != null;
    return ListTile(
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: enabled ? iconColor : Colors.grey, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: enabled ? null : (isDark ? Colors.white38 : Colors.black38),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white38 : Colors.black45,
        ),
      ),
      trailing: onTap != null
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
