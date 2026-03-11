import 'package:flutter/material.dart';
import '../models/course.dart';
import '../database/database_helper.dart';
import '../widgets/timetable_grid.dart';
import '../widgets/course_detail_sheet.dart';
import '../services/course_status_service.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => TimetableScreenState();
}

class TimetableScreenState extends State<TimetableScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  List<Course> _courses = [];
  int _currentWeek = 1;
  int _initialWeek = 1;
  bool _loading = true;
  DateTime? _semesterStart;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> refresh() async => _loadData();

  Future<void> _loadData() async {
    final courses = await _db.getAllCourses();
    final startStr = await _db.getSetting('semesterStart');

    final semStart = startStr != null ? DateTime.tryParse(startStr) : null;
    final currentWeek = CourseStatusService.calculateCurrentWeek(semStart);

    setState(() {
      _courses = courses;
      _currentWeek = currentWeek;
      _initialWeek = currentWeek;
      _semesterStart = semStart;
      _loading = false;
    });
  }

  DateTime? _getMondayOfWeek(int week) {
    if (_semesterStart == null) return null;
    final semMonday = _semesterStart!.subtract(
      Duration(days: _semesterStart!.weekday - 1),
    );
    return semMonday.add(Duration(days: (week - 1) * 7));
  }

  void _changeWeek(int delta) {
    final next = _currentWeek + delta;
    if (next < 1 || next > 20) return;
    setState(() => _currentWeek = next);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('课表')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildWeekSelector(isDark),
                Expanded(
                  child: _courses.isEmpty
                      ? _buildEmptyState(isDark)
                      : TimetableGrid(
                          courses: _courses,
                          currentWeek: _currentWeek,
                          semesterStart: _semesterStart,
                          onCourseTap: (course) {
                            CourseDetailSheet.show(context, course);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildWeekSelector(bool isDark) {
    final monday = _getMondayOfWeek(_currentWeek);
    final sunday = monday?.add(const Duration(days: 6));
    final primary = Theme.of(context).colorScheme.primary;
    final isCurrentWeek = _currentWeek == _initialWeek;

    String dateRange = '';
    if (monday != null && sunday != null) {
      dateRange =
          '${monday.month}/${monday.day} - ${sunday.month}/${sunday.day}';
    }
    final weekType = _currentWeek.isOdd ? '单周' : '双周';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : const Color(0xFFE8E8ED),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _currentWeek > 1 ? () => _changeWeek(-1) : null,
            icon: const Icon(Icons.chevron_left, size: 22),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Column(
                key: ValueKey(_currentWeek),
                children: [
                  Text(
                    '第$_currentWeek周',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateRange.isNotEmpty ? '$dateRange · $weekType' : weekType,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isCurrentWeek)
            TextButton(
              onPressed: () => setState(() => _currentWeek = _initialWeek),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                visualDensity: VisualDensity.compact,
                backgroundColor: primary.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                '本周',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ),
          IconButton(
            onPressed: _currentWeek < 20 ? () => _changeWeek(1) : null,
            icon: const Icon(Icons.chevron_right, size: 22),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 56,
            color: isDark ? Colors.white12 : Colors.black12,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无课表数据',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '前往设置页导入 xls/xlsx 文件',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white30 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}
