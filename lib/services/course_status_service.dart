import '../models/course.dart';
import '../database/database_helper.dart';

/// 课程当前状态枚举
enum CourseStatus {
  inProgress, // 正在上课
  upcoming, // 即将上课（30分钟内）
  next, // 下节课（>30分钟）
  finished, // 今日课程已结束
  noCourse, // 今日无课
}

/// 锁屏卡片展示用的课程摘要
class CourseSummary {
  final CourseStatus status;
  final String statusLabel;
  final String courseName;
  final String classroom;
  final String timeRange;
  final String weekLabel;
  final String dateLabel;
  final int totalToday;

  const CourseSummary({
    required this.status,
    required this.statusLabel,
    this.courseName = '',
    this.classroom = '',
    this.timeRange = '',
    this.weekLabel = '',
    this.dateLabel = '',
    this.totalToday = 0,
  });

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'statusLabel': statusLabel,
    'courseName': courseName,
    'classroom': classroom,
    'timeRange': timeRange,
    'weekLabel': weekLabel,
    'dateLabel': dateLabel,
    'totalToday': totalToday,
  };
}

class CourseStatusService {
  static const _upcomingThresholdMinutes = 30;

  static const sectionTimes = {
    1: ('07:00', '08:00'),
    2: ('08:30', '10:05'),
    3: ('10:25', '12:00'),
    4: ('14:00', '15:35'),
    5: ('15:55', '17:30'),
    6: ('19:00', '20:35'),
  };

  static const _weekdays = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  /// 计算当前周次
  static int calculateCurrentWeek(DateTime? semesterStart) {
    if (semesterStart == null) return 1;
    final weekMonday = semesterStart.subtract(
      Duration(days: semesterStart.weekday - 1),
    );
    final diff = DateTime.now().difference(weekMonday).inDays;
    int week = (diff / 7).floor() + 1;
    if (week < 1) week = 1;
    if (week > 20) week = 20;
    return week;
  }

  /// 获取今日课程（已排序）
  static List<Course> getTodayCourses(
    List<Course> allCourses,
    int currentWeek,
  ) {
    final today = DateTime.now().weekday;
    return allCourses
        .where((c) => c.dayOfWeek == today && c.isInWeek(currentWeek))
        .toList()
      ..sort((a, b) => a.sectionIndex.compareTo(b.sectionIndex));
  }

  /// 将 "HH:mm" 转为当天分钟数
  static int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  /// 核心：计算当前课程状态摘要
  static CourseSummary computeSummary({
    required List<Course> todayCourses,
    required int currentWeek,
    DateTime? now,
  }) {
    now ??= DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final dateLabel = '${now.month}月${now.day}日 ${_weekdays[now.weekday]}';
    final weekType = currentWeek.isOdd ? '单周' : '双周';
    final weekLabel = '第$currentWeek周 · $weekType';

    if (todayCourses.isEmpty) {
      return CourseSummary(
        status: CourseStatus.noCourse,
        statusLabel: '今日无课',
        weekLabel: weekLabel,
        dateLabel: dateLabel,
      );
    }

    // 检查是否有正在上课的
    for (final course in todayCourses) {
      final times = sectionTimes[course.sectionIndex];
      if (times == null) continue;
      final startMin = _timeToMinutes(times.$1);
      final endMin = _timeToMinutes(times.$2);
      if (nowMinutes >= startMin && nowMinutes < endMin) {
        return CourseSummary(
          status: CourseStatus.inProgress,
          statusLabel: '正在上课',
          courseName: course.name,
          classroom: course.classroom,
          timeRange: '${times.$1} - ${times.$2}',
          weekLabel: weekLabel,
          dateLabel: dateLabel,
          totalToday: todayCourses.length,
        );
      }
    }

    // 找下一节还没结束的课
    for (final course in todayCourses) {
      final times = sectionTimes[course.sectionIndex];
      if (times == null) continue;
      final startMin = _timeToMinutes(times.$1);
      final endMin = _timeToMinutes(times.$2);
      if (nowMinutes < endMin) {
        // 还没结束，判断是即将上课还是下节课
        final diff = startMin - nowMinutes;
        final isUpcoming = diff <= _upcomingThresholdMinutes && diff > 0;
        return CourseSummary(
          status: isUpcoming ? CourseStatus.upcoming : CourseStatus.next,
          statusLabel: isUpcoming ? '即将上课' : '下节课',
          courseName: course.name,
          classroom: course.classroom,
          timeRange: isUpcoming
              ? '${times.$1} 开始'
              : '${times.$1} - ${times.$2}',
          weekLabel: weekLabel,
          dateLabel: dateLabel,
          totalToday: todayCourses.length,
        );
      }
    }

    // 所有课都结束了
    return CourseSummary(
      status: CourseStatus.finished,
      statusLabel: '今日课程已结束',
      weekLabel: weekLabel,
      dateLabel: dateLabel,
      totalToday: todayCourses.length,
    );
  }

  /// 一站式：从数据库读取并计算摘要
  static Future<CourseSummary> fetchCurrentSummary() async {
    final db = DatabaseHelper();
    final allCourses = await db.getAllCourses();
    final startStr = await db.getSetting('semesterStart');
    final semesterStart = startStr != null ? DateTime.tryParse(startStr) : null;
    final currentWeek = calculateCurrentWeek(semesterStart);
    final todayCourses = getTodayCourses(allCourses, currentWeek);
    return computeSummary(todayCourses: todayCourses, currentWeek: currentWeek);
  }
}
