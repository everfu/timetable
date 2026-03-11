import 'package:flutter/material.dart';
import '../../database/database_helper.dart';
import '../../services/widget_sync_service.dart';

class SemesterSettingsPage extends StatefulWidget {
  final VoidCallback onDataChanged;

  const SemesterSettingsPage({super.key, required this.onDataChanged});

  @override
  State<SemesterSettingsPage> createState() => _SemesterSettingsPageState();
}

class _SemesterSettingsPageState extends State<SemesterSettingsPage> {
  final DatabaseHelper _db = DatabaseHelper();
  DateTime? _semesterStart;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final startStr = await _db.getSetting('semesterStart');
    setState(() {
      _semesterStart = startStr != null ? DateTime.tryParse(startStr) : null;
    });
  }

  Future<void> _setSemesterStart() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _semesterStart ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      helpText: '选择学期开始日期',
    );
    if (picked != null) {
      await _db.setSetting('semesterStart', picked.toIso8601String());
      await _loadSettings();
      widget.onDataChanged();
      await WidgetSyncService.syncAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('学期设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.orange,
                  size: 18,
                ),
              ),
              title: const Text(
                '学期开始日期',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                _semesterStart != null
                    ? '${_semesterStart!.year}/${_semesterStart!.month}/${_semesterStart!.day}'
                    : '未设置',
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
              onTap: _setSemesterStart,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
