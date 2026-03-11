import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../models/course.dart';
import '../models/task.dart';
import '../database/database_helper.dart';
import '../widgets/task_card.dart';
import '../widgets/task_editor_sheet.dart';
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
  List<Task> _pendingTasks = [];
  List<Task> _completedTasks = [];
  int _currentWeek = 1;
  bool _loading = true;
  bool _showCompleted = false;

  late AnimationController _animController;
  late Animation<double> _dateCardAnim;
  late Animation<double> _nextCourseAnim;
  late Animation<double> _courseListAnim;
  late Animation<double> _taskAreaAnim;

  static const _sectionTimes = CourseStatusService.sectionTimes;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _dateCardAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
    );
    _nextCourseAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.1, 0.5, curve: Curves.easeInOut),
    );
    _courseListAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeInOut),
    );
    _taskAreaAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeInOut),
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
    final pending = await _db.getPendingTasks();
    final completed = await _db.getCompletedTasks();

    final semesterStart = startStr != null ? DateTime.tryParse(startStr) : null;
    final currentWeek = CourseStatusService.calculateCurrentWeek(semesterStart);
    final todayCourses = CourseStatusService.getTodayCourses(
      allCourses,
      currentWeek,
    );

    setState(() {
      _todayCourses = todayCourses;
      _pendingTasks = pending;
      _completedTasks = completed;
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

  Future<void> _openTaskEditor({Task? task, String? linkedCourse}) async {
    final result = await TaskEditorSheet.show(
      context,
      initialTask: task,
      initialLinkedCourse: linkedCourse,
    );
    if (result == null) return;
    if (result == '__delete__' && task?.id != null) {
      await _db.deleteTask(task!.id!);
    } else if (result is Task) {
      if (result.id != null) {
        await _db.updateTask(result);
      } else {
        await _db.insertTask(result);
      }
    }
    await _loadData();
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
                  _buildAnimatedEntry(
                    animation: _dateCardAnim,
                    child: _buildDateCard(isDark),
                  ),
                  const SizedBox(height: AppSpacing.s12),

                  if (_nextCourse != null) ...[
                    _buildAnimatedEntry(
                      animation: _nextCourseAnim,
                      child: _buildNextCourseCard(_nextCourse!, isDark),
                    ),
                    const SizedBox(height: AppSpacing.s12),
                  ],

                  _buildAnimatedEntry(
                    animation: _courseListAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('今日课程', '${_todayCourses.length} 节'),
                        const SizedBox(height: AppSpacing.s8),
                        if (_todayCourses.isEmpty)
                          _buildEmptyCard(
                            '今天没有课，好好休息吧',
                            Icons.wb_sunny_outlined,
                          )
                        else
                          _buildCourseTimeline(isDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s16),

                  _buildAnimatedEntry(
                    animation: _taskAreaAnim,
                    child: _buildTaskSection(isDark),
                  ),
                ],
              ),
            ),
    );
  }

  // ─── 动画入场 ───

  Widget _buildAnimatedEntry({
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

  // ─── 日期卡 — 纯白 + 品牌色强调 ───

  Widget _buildDateCard(bool isDark) {
    final brand = AppTDColors.brandColor7;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark ? AppTDColors.bgContainerDark : AppTDColors.bgContainer,
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        boxShadow: TDShadows.base(isDark),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? AppTDColors.textSecondaryDark
                        : AppTDColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
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
                const SizedBox(height: 4),
                Text(
                  _weekLabel,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppTDColors.textPlaceholderDark
                        : AppTDColors.textPlaceholder,
                  ),
                ),
              ],
            ),
          ),
          // 课程数
          Container(
            width: 48,
            height: 48,
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
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: brand,
                    height: 1.1,
                  ),
                ),
                Text(
                  '节课',
                  style: TextStyle(
                    fontSize: 10,
                    color: brand.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section Title ───

  Widget _buildSectionTitle(String title, String trailing) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(
          title,
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
          trailing,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppTDColors.brandColor7,
          ),
        ),
      ],
    );
  }

  // ─── 下一节课卡片 — 左侧品牌色竖条 ───

  Widget _buildNextCourseCard(Course course, bool isDark) {
    final times = _sectionTimes[course.sectionIndex];
    final timeStr = times != null ? '${times.$1} - ${times.$2}' : '';
    final brand = AppTDColors.brandColor7;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTDColors.bgContainerDark : AppTDColors.bgContainer,
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        boxShadow: TDShadows.base(isDark),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 80,
            decoration: BoxDecoration(
              color: brand,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.extraLarge),
                bottomLeft: Radius.circular(AppRadius.extraLarge),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TDTag(
                        '即将上课',
                        theme: TDTagTheme.primary,
                        size: TDTagSize.small,
                      ),
                      const Spacer(),
                      if (timeStr.isNotEmpty)
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppTDColors.textPlaceholderDark
                                : AppTDColors.textPlaceholder,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTDColors.textPrimaryDark
                          : AppTDColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (course.classroom.isNotEmpty) ...[
                        Icon(
                          TDIcons.location,
                          size: 14,
                          color: isDark
                              ? AppTDColors.textPlaceholderDark
                              : AppTDColors.textPlaceholder,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          course.classroom,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppTDColors.textSecondaryDark
                                : AppTDColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (course.teacher.isNotEmpty) ...[
                        Icon(
                          TDIcons.user,
                          size: 14,
                          color: isDark
                              ? AppTDColors.textPlaceholderDark
                              : AppTDColors.textPlaceholder,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          course.teacher,
                          style: TextStyle(
                            fontSize: 13,
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
          ),
        ],
      ),
    );
  }

  // ─── 课程时间轴 ───

  Widget _buildCourseTimeline(bool isDark) {
    final brand = AppTDColors.brandColor7;
    final nextCourse = _nextCourse;

    return Column(
      children: List.generate(_todayCourses.length, (index) {
        final course = _todayCourses[index];
        final times = _sectionTimes[course.sectionIndex];
        final timeStr = times != null ? times.$1 : '';
        final endStr = times != null ? times.$2 : '';
        final isNext = course == nextCourse;
        final isLast = index == _todayCourses.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 时间
              SizedBox(
                width: 46,
                child: Column(
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isNext ? FontWeight.w600 : FontWeight.w400,
                        color: isNext
                            ? brand
                            : (isDark
                                  ? AppTDColors.textPlaceholderDark
                                  : AppTDColors.textPlaceholder),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      endStr,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppTDColors.textDisabledDark
                            : AppTDColors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
              // 时间轴线 + 节点
              SizedBox(
                width: 20,
                child: Column(
                  children: [
                    Container(
                      width: isNext ? 10 : 6,
                      height: isNext ? 10 : 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isNext ? brand : Colors.transparent,
                        border: Border.all(
                          color: isNext
                              ? brand
                              : (isDark
                                    ? AppTDColors.gray11
                                    : AppTDColors.gray4),
                          width: 1.5,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 1,
                          color: isDark
                              ? AppTDColors.gray11
                              : AppTDColors.gray3,
                        ),
                      ),
                  ],
                ),
              ),
              // 课程卡片
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTDColors.bgContainerDark
                          : AppTDColors.bgContainer,
                      borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                      boxShadow: TDShadows.base(isDark),
                      border: isNext
                          ? Border.all(
                              color: brand.withValues(alpha: 0.25),
                              width: 1,
                            )
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppTDColors.textPrimaryDark
                                : AppTDColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
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
                              const SizedBox(width: 10),
                            ],
                            if (course.teacher.isNotEmpty) ...[
                              Icon(
                                TDIcons.user,
                                size: 12,
                                color: isDark
                                    ? AppTDColors.textPlaceholderDark
                                    : AppTDColors.textPlaceholder,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                course.teacher,
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
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ─── 待办事项区域 ───

  Widget _buildTaskSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '待办事项',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTDColors.textPrimaryDark
                    : AppTDColors.textPrimary,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _openTaskEditor(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('新建'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (_pendingTasks.isEmpty && _completedTasks.isEmpty)
          _buildEmptyCard('暂无待办事项', Icons.check_circle_outline)
        else ...[
          ..._pendingTasks.map(
            (t) => TaskCard(
              task: t,
              onTap: () => _openTaskEditor(task: t),
              onToggle: () async {
                await _db.updateTask(
                  t.copyWith(isDone: true, updatedAt: DateTime.now()),
                );
                await _loadData();
              },
              onDelete: () async {
                await _db.deleteTask(t.id!);
                await _loadData();
              },
            ),
          ),
          if (_completedTasks.isNotEmpty) ...[
            const SizedBox(height: 4),
            InkWell(
              onTap: () => setState(() => _showCompleted = !_showCompleted),
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      _showCompleted ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: isDark
                          ? AppTDColors.textPlaceholderDark
                          : AppTDColors.textPlaceholder,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '已完成 (${_completedTasks.length})',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppTDColors.textPlaceholderDark
                            : AppTDColors.textPlaceholder,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showCompleted)
              ..._completedTasks.map(
                (t) => TaskCard(
                  task: t,
                  onTap: () => _openTaskEditor(task: t),
                  onToggle: () async {
                    await _db.updateTask(
                      t.copyWith(isDone: false, updatedAt: DateTime.now()),
                    );
                    await _loadData();
                  },
                  onDelete: () async {
                    await _db.deleteTask(t.id!);
                    await _loadData();
                  },
                ),
              ),
          ],
        ],
      ],
    );
  }

  // ─── 空状态 ───

  Widget _buildEmptyCard(String text, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: isDark ? AppTDColors.bgContainerDark : AppTDColors.bgContainer,
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        boxShadow: TDShadows.base(isDark),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 36,
            color: isDark ? AppTDColors.gray11 : AppTDColors.gray4,
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
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
