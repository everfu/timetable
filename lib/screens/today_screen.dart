import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../models/course.dart';
import '../database/database_helper.dart';
import '../widgets/course_detail_sheet.dart';
import '../services/course_status_service.dart';
import '../services/widget_sync_service.dart';
import '../theme/app_design_tokens.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => TodayScreenState();
}

class TodayScreenState extends State<TodayScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseHelper _db = DatabaseHelper();
  List<Course> _todayCourses = [];
  Map<String, int> _noteCounts = {};
  int _currentWeek = 1;
  bool _loading = true;

  late AnimationController _animController;
  late Animation<double> _headerAnim;
  late Animation<double> _courseAnim;

  static const _sectionTimes = CourseStatusService.sectionTimes;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _headerAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    );
    _courseAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeInOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> refresh() async => _loadData();

  Future<void> _loadData() async {
    final allCourses = await _db.getAllCourses();
    final startStr = await _db.getSetting('semesterStart');
    final noteCounts = await _db.getPendingNoteCounts();

    final semesterStart = startStr != null ? DateTime.tryParse(startStr) : null;
    final currentWeek = CourseStatusService.calculateCurrentWeek(semesterStart);
    final todayCourses = CourseStatusService.getTodayCourses(
      allCourses,
      currentWeek,
    );

    setState(() {
      _todayCourses = todayCourses;
      _noteCounts = noteCounts;
      _currentWeek = currentWeek;
      _loading = false;
    });

    _animController.forward(from: 0);
    WidgetSyncService.syncAll();
  }

  String get _dateLabel {
    final now = DateTime.now();
    const weekdays = ['', '周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return '${now.month}月${now.day}日 ${weekdays[now.weekday]}';
  }

  String get _weekLabel {
    final type = _currentWeek.isOdd ? '单周' : '双周';
    return '第$_currentWeek周 · $type';
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了';
    if (hour < 9) return '早上好';
    if (hour < 12) return '上午好';
    if (hour < 14) return '中午好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }

  Course? get _nextCourse {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    for (final course in _todayCourses) {
      final times = _sectionTimes[course.sectionIndex];
      if (times == null) continue;
      final endParts = times.$2.split(':');
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);
      if (nowMinutes < endMinutes) return course;
    }
    return null;
  }

  Future<void> _openCourseDetail(Course course) async {
    await CourseDetailSheet.show(context, course);
    // 从详情页返回后刷新记事数
    final noteCounts = await _db.getPendingNoteCounts();
    if (mounted) setState(() => _noteCounts = noteCounts);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomReserved = AppDimens.bottomNavReservedHeight(context);

    return Scaffold(
      appBar: AppBar(title: const Text('今日')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.s16,
                  0,
                  AppSpacing.s16,
                  bottomReserved,
                ),
                children: [
                  _buildAnimated(
                    animation: _headerAnim,
                    child: _buildHeaderCard(isDark),
                  ),
                  const SizedBox(height: AppSpacing.s16),
                  _buildAnimated(
                    animation: _courseAnim,
                    child: _buildCourseSection(isDark),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAnimated({
    required Animation<double> animation,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => FadeTransition(
        opacity: animation,
        child: Transform.translate(
          offset: Offset(0, 12 * (1.0 - animation.value)),
          child: child,
        ),
      ),
    );
  }

  // ─── 头部卡片：日期 + 下一节课 ───

  Widget _buildHeaderCard(bool isDark) {
    final brand = AppTDColors.brandColor7;
    final next = _nextCourse;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark ? AppTDColors.bgContainerDark : AppTDColors.bgContainer,
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        boxShadow: TDShadows.base(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppTDColors.textSecondaryDark
                            : AppTDColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _dateLabel,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTDColors.textPrimaryDark
                            : AppTDColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _weekLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppTDColors.textPlaceholderDark
                            : AppTDColors.textPlaceholder,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? brand.withValues(alpha: 0.15)
                      : AppTDColors.brandColor1,
                  borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_todayCourses.length}',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: brand,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      '节课',
                      style: TextStyle(
                        fontSize: 9,
                        color: brand.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (next != null) ...[
            Divider(
              height: 24,
              color: isDark ? AppTDColors.strokeDark : AppTDColors.stroke,
            ),
            _buildNextCourseRow(next, isDark, brand),
          ],
        ],
      ),
    );
  }

  Widget _buildNextCourseRow(Course course, bool isDark, Color brand) {
    final times = _sectionTimes[course.sectionIndex];
    final timeStr = times != null ? '${times.$1} - ${times.$2}' : '';

    return GestureDetector(
      onTap: () => _openCourseDetail(course),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: brand,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: brand,
                        borderRadius: BorderRadius.circular(AppRadius.small),
                      ),
                      child: const Text(
                        '即将上课',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        course.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppTDColors.textPrimaryDark
                              : AppTDColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (timeStr.isNotEmpty) ...[
                      Icon(
                        TDIcons.time,
                        size: 12,
                        color: isDark
                            ? AppTDColors.textPlaceholderDark
                            : AppTDColors.textPlaceholder,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTDColors.textSecondaryDark
                              : AppTDColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    if (course.classroom.isNotEmpty) ...[
                      Icon(
                        TDIcons.location,
                        size: 12,
                        color: isDark
                            ? AppTDColors.textPlaceholderDark
                            : AppTDColors.textPlaceholder,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        course.classroom,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTDColors.textSecondaryDark
                              : AppTDColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 今日课程列表 ───

  Widget _buildCourseSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '今日课程',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTDColors.textPrimaryDark
                    : AppTDColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '${_todayCourses.length} 节',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTDColors.brandColor7,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_todayCourses.isEmpty)
          _buildEmpty(isDark)
        else
          ..._todayCourses.map((c) => _buildCourseItem(c, isDark)),
      ],
    );
  }

  Widget _buildCourseItem(Course course, bool isDark) {
    final times = _sectionTimes[course.sectionIndex];
    final timeStr = times != null ? times.$1 : '';
    final isNext = course == _nextCourse;
    final brand = AppTDColors.brandColor7;
    final noteCount = _noteCounts[course.name] ?? 0;

    return GestureDetector(
      onTap: () => _openCourseDetail(course),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppTDColors.bgContainerDark : AppTDColors.bgContainer,
          borderRadius: BorderRadius.circular(AppRadius.extraLarge),
          boxShadow: TDShadows.base(isDark),
          border: isNext
              ? Border.all(color: brand.withValues(alpha: 0.2), width: 1)
              : null,
        ),
        child: Row(
          children: [
            // 时间
            SizedBox(
              width: 42,
              child: Text(
                timeStr,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isNext ? FontWeight.w600 : FontWeight.w400,
                  color: isNext
                      ? brand
                      : (isDark
                            ? AppTDColors.textPlaceholderDark
                            : AppTDColors.textPlaceholder),
                ),
              ),
            ),
            // 竖线
            Container(
              width: 2,
              height: 32,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isNext
                    ? brand
                    : (isDark ? AppTDColors.gray11 : AppTDColors.gray3),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            // 课程信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTDColors.textPrimaryDark
                          : AppTDColors.textPrimary,
                    ),
                  ),
                  if (course.classroom.isNotEmpty || course.teacher.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        [
                          if (course.classroom.isNotEmpty) course.classroom,
                          if (course.teacher.isNotEmpty) course.teacher,
                        ].join(' · '),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTDColors.textPlaceholderDark
                              : AppTDColors.textPlaceholder,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 记事数角标
            if (noteCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? brand.withValues(alpha: 0.15)
                      : AppTDColors.brandColor1,
                  borderRadius: BorderRadius.circular(AppRadius.round),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_note, size: 12, color: brand),
                    const SizedBox(width: 2),
                    Text(
                      '$noteCount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: brand,
                      ),
                    ),
                  ],
                ),
              ),
            // 箭头
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: isDark ? AppTDColors.gray11 : AppTDColors.gray5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: isDark ? AppTDColors.bgContainerDark : AppTDColors.bgContainer,
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        boxShadow: TDShadows.base(isDark),
      ),
      child: Column(
        children: [
          Icon(
            Icons.wb_sunny_outlined,
            size: 32,
            color: isDark ? AppTDColors.gray11 : AppTDColors.gray4,
          ),
          const SizedBox(height: 6),
          Text(
            '今天没有课，好好休息吧',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppTDColors.textPlaceholderDark
                  : AppTDColors.textPlaceholder,
            ),
          ),
        ],
      ),
    );
  }
}
