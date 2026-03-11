import 'package:flutter/material.dart';
import '../models/course.dart';
import 'course_cell.dart';

class TimetableGrid extends StatelessWidget {
  final List<Course> courses;
  final int currentWeek;
  final DateTime? semesterStart;
  final void Function(Course course)? onCourseTap;

  static const double headerHeight = 56;
  static const double timeColWidth = 40;
  static const double cellHeight = 100;

  static const List<String> _dayLabels = ['一', '二', '三', '四', '五', '六', '日'];

  const TimetableGrid({
    super.key,
    required this.courses,
    required this.currentWeek,
    this.semesterStart,
    this.onCourseTap,
  });

  List<Course> get _filteredCourses {
    return courses.where((c) => c.isInWeek(currentWeek)).toList();
  }

  int get _totalDays {
    if (courses.isEmpty) return 5;
    final maxDay = courses
        .map((c) => c.dayOfWeek)
        .reduce((a, b) => a > b ? a : b);
    return maxDay > 5 ? 7 : 5;
  }

  List<_SectionInfo> get _sections {
    final map = <int, String>{};
    for (final c in courses) {
      if (!map.containsKey(c.sectionIndex)) {
        map[c.sectionIndex] = c.sectionName;
      }
    }
    if (map.isEmpty) {
      return List.generate(6, (i) => _SectionInfo(i + 1, '第${i + 1}节'));
    }
    final keys = map.keys.toList()..sort();
    return keys.map((k) => _SectionInfo(k, map[k]!)).toList();
  }

  DateTime? get _weekMonday {
    if (semesterStart == null) return null;
    final semMonday = semesterStart!.subtract(
      Duration(days: semesterStart!.weekday - 1),
    );
    return semMonday.add(Duration(days: (currentWeek - 1) * 7));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCourses;
    final totalDays = _totalDays;
    final sections = _sections;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final monday = _weekMonday;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 计算今天是第几列 (0-based), -1 表示不在本周
    int todayCol = -1;
    if (monday != null) {
      for (int d = 0; d < totalDays; d++) {
        final date = monday.add(Duration(days: d));
        if (DateTime(date.year, date.month, date.day) == today) {
          todayCol = d;
          break;
        }
      }
    }

    final Map<String, Course> courseMap = {};
    for (final course in filtered) {
      final key = '${course.dayOfWeek}-${course.sectionIndex}';
      if (!courseMap.containsKey(key)) {
        courseMap[key] = course;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final dayColWidth = (constraints.maxWidth - timeColWidth) / totalDays;

        return Column(
          children: [
            // 日期头部
            _buildHeader(
              context,
              dayColWidth,
              totalDays,
              monday,
              today,
              todayCol,
              isDark,
            ),
            // 课程区域
            Expanded(
              child: SingleChildScrollView(
                child: Stack(
                  children: [
                    // 今日列高亮背景
                    if (todayCol >= 0)
                      Positioned(
                        left: timeColWidth + todayCol * dayColWidth,
                        top: 0,
                        bottom: 0,
                        width: dayColWidth,
                        child: Container(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.03)
                              : Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.04),
                        ),
                      ),
                    // 网格内容
                    Column(
                      children: [
                        for (final section in sections)
                          _buildRow(
                            section,
                            dayColWidth,
                            totalDays,
                            courseMap,
                            isDark,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    double dayColWidth,
    int totalDays,
    DateTime? monday,
    DateTime today,
    int todayCol,
    bool isDark,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF2F2F7),
      ),
      child: Row(
        children: [
          // 左上角：月份
          SizedBox(
            width: timeColWidth,
            height: headerHeight,
            child: Center(
              child: monday != null
                  ? Text(
                      '${monday.month}月',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white30 : Colors.black38,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          // 每天一列
          for (int d = 0; d < totalDays; d++)
            SizedBox(
              width: dayColWidth,
              height: headerHeight,
              child: _buildDayHeader(
                d,
                monday,
                today,
                todayCol == d,
                primaryColor,
                isDark,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayHeader(
    int dayIndex,
    DateTime? monday,
    DateTime today,
    bool isToday,
    Color primaryColor,
    bool isDark,
  ) {
    final date = monday?.add(Duration(days: dayIndex));

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 星期
        Text(
          _dayLabels[dayIndex],
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isToday
                ? primaryColor
                : (isDark ? Colors.white38 : Colors.black38),
          ),
        ),
        const SizedBox(height: 4),
        // 日期数字
        if (date != null)
          Container(
            width: 28,
            height: 28,
            decoration: isToday
                ? BoxDecoration(color: primaryColor, shape: BoxShape.circle)
                : null,
            alignment: Alignment.center,
            child: Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color: isToday
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRow(
    _SectionInfo section,
    double dayColWidth,
    int totalDays,
    Map<String, Course> courseMap,
    bool isDark,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左侧节次标签
        SizedBox(
          width: timeColWidth,
          height: cellHeight,
          child: Center(
            child: Text(
              section.shortName,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white24 : Colors.black26,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        // 每天一格
        for (int day = 1; day <= totalDays; day++)
          _buildCell(day, section.index, dayColWidth, courseMap),
      ],
    );
  }

  Widget _buildCell(
    int day,
    int sectionIndex,
    double dayColWidth,
    Map<String, Course> courseMap,
  ) {
    final key = '$day-$sectionIndex';
    final course = courseMap[key];

    if (course != null) {
      return SizedBox(
        width: dayColWidth,
        height: cellHeight,
        child: CourseCell(
          course: course,
          cellHeight: cellHeight,
          onTap: onCourseTap != null ? () => onCourseTap!(course) : null,
        ),
      );
    }

    // 无课：留白
    return SizedBox(width: dayColWidth, height: cellHeight);
  }
}

class _SectionInfo {
  final int index;
  final String name;
  _SectionInfo(this.index, this.name);

  String get shortName {
    final lines = name.split('\n');
    return lines[0];
  }
}
