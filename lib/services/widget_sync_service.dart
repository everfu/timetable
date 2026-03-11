import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'course_status_service.dart';
import '../database/database_helper.dart';

/// 负责将课程摘要和待办数据同步到系统 Widget（iOS WidgetKit / Android AppWidget）
class WidgetSyncService {
  // iOS
  static const String _appGroupId = 'group.efu.me.timetable';
  static const String _fileName = 'widget_course.json';
  static const MethodChannel _iosChannel = MethodChannel(
    'efu.me.timetable/widget',
  );

  // Android
  static const MethodChannel _androidChannel = MethodChannel(
    'me.efu.jvtus.timetable/widget',
  );

  // ─── iOS helpers ───

  static Future<String?> _getAppGroupPath() async {
    if (!Platform.isIOS) return null;
    try {
      final path = await _iosChannel.invokeMethod<String>(
        'getAppGroupPath',
        _appGroupId,
      );
      return path;
    } catch (_) {
      return null;
    }
  }

  static Future<void> _reloadIOSWidget() async {
    try {
      await _iosChannel.invokeMethod('reloadWidget');
    } catch (_) {}
  }

  // ─── 同步所有 Widget 数据 ───

  /// 同步课程和待办数据到桌面/锁屏 Widget
  static Future<void> syncAll() async {
    try {
      final db = DatabaseHelper();

      // 课程摘要
      final summary = await CourseStatusService.fetchCurrentSummary();

      // 待办事项
      final pendingTasks = await db.getPendingTasks();
      final taskList = pendingTasks
          .take(2)
          .map((t) => {'title': t.title, 'priority': t.priority.name})
          .toList();

      if (Platform.isIOS) {
        // iOS 只同步课程数据（待办可后续扩展）
        final iosJson = jsonEncode(summary.toJson());
        final groupPath = await _getAppGroupPath();
        if (groupPath == null) return;
        final file = File('$groupPath/$_fileName');
        await file.writeAsString(iosJson);
        await _reloadIOSWidget();
      } else if (Platform.isAndroid) {
        // Android 合并课程 + 待办为一份 JSON
        final combined = {
          ...summary.toJson(),
          'tasks': taskList,
          'taskTotal': pendingTasks.length,
        };
        final json = jsonEncode(combined);
        await _androidChannel.invokeMethod('updateWidget', {'json': json});
      }
    } catch (_) {
      // 静默失败，不影响主 App
    }
  }
}
