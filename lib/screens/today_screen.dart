import 'package:flutter/material.dart';
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
      duration: const Duration(milliseconds: 900),
    );
    _dateCardAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.4, curve: Curves.fastOutSlowIn),
    );
    _nextCourseAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.15, 0.5, curve: Curves.fastOutSlowIn),
    );
    _courseListAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.25, 0.65, curve: Curves.fastOutSlowIn),
    );
    _taskAreaAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.35, 0.8, curve: Curves.fastOutSlowIn),
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
    final colorScheme = Theme.of(context).colorScheme;
    final bottomReserved = AppDimens.bottomNavReservedHeight(context);

    return Scaffold(
      appBar: AppBar(title: const Text('今日')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, 0, 20, bottomReserved),
                children: [
                  // 日期信息卡 — 渐变 + 不对称圆角
                  _buildAnimatedEntry(
                    animation: _dateCardAnim,
                    child: _buildDateCard(isDark, colorScheme),
                  ),
                  const SizedBox(height: 16),

                  // 下一节课高亮
                  if (_nextCourse != null) ...[
                    _buildAnimatedEntry(
                      animation: _nextCourseAnim,
                      child: _buildNextCourseCard(
                        _nextCourse!,
                        isDark,
                        colorScheme,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 今日课程列表 — 时间轴样式
                  _buildAnimatedEntry(
                    animation: _courseListAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('今日课程', '${_todayCourses.length} 节'),
                        const SizedBox(height: 10),
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
                  const SizedBox(height: 20),

                  // 待办事项
                  _buildAnimatedEntry(
                    animation: _taskAreaAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '待办事项',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.18,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF253840),
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: () => _openTaskEditor(),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('新建'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (_pendingTasks.isEmpty && _completedTasks.isEmpty)
                          _buildEmptyCard('暂无待办事项', Icons.check_circle_outline)
                        else ...[
                          ..._pendingTasks.map(
                            (t) => TaskCard(
                              task: t,
                              onTap: () => _openTaskEditor(task: t),
                              onToggle: () async {
                                await _db.updateTask(
                                  t.copyWith(
                                    isDone: true,
                                    updatedAt: DateTime.now(),
                                  ),
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
                              onTap: () => setState(
                                () => _showCompleted = !_showCompleted,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _showCompleted
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      size: 18,
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.black38,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '已完成 (${_completedTasks.length})',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.black38,
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
                                      t.copyWith(
                                        isDone: false,
                                        updatedAt: DateTime.now(),
                                      ),
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
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ─── 动画入场包装器 ───

  Widget _buildAnimatedEntry({
    required Animation<double> animation,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => FadeTransition(
        opacity: animation,
        child: Transform.translate(
          offset: Offset(0, 30 * (1.0 - animation.value)),
          child: child,
        ),
      ),
    );
  }

  // ─── 日期卡 — 渐变 + 不对称圆角 + 装饰圆 ───

  Widget _buildDateCard(bool isDark, ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppGradients.primaryDark : AppGradients.primary,
        borderRadius: AppBorderRadius.featureCard,
        boxShadow: AppShadows.elevated(isDark),
      ),
      child: Stack(
        children: [
          // 装饰圆
          Positioned(
            top: -20,
            right: -10,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            right: 40,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          // 内容
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _dateLabel,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _weekLabel,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                // 课程数圆形指示器
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_todayCourses.length}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        '节课',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Section Title — 参考 TitleView ───

  Widget _buildSectionTitle(String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.18,
            color: isDark ? Colors.white : const Color(0xFF253840),
          ),
        ),
        const Spacer(),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  // ─── 下一节课卡片 — 渐变左边框 + 装饰元素 ───

  Widget _buildNextCourseCard(
    Course course,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final times = _sectionTimes[course.sectionIndex];
    final timeStr = times != null ? '${times.$1} - ${times.$2}' : '';

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: AppBorderRadius.standard,
        boxShadow: AppShadows.card(isDark),
      ),
      child: Row(
        children: [
          // 渐变左边框
          Container(
            width: 4,
            height: 90,
            decoration: BoxDecoration(
              gradient: isDark
                  ? AppGradients.courseHighlightDark
                  : AppGradients.courseHighlight,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: isDark
                              ? AppGradients.courseHighlightDark
                              : AppGradients.courseHighlight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '即将上课',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (timeStr.isNotEmpty)
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white38 : Colors.black38,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    course.name,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: isDark ? Colors.white : const Color(0xFF253840),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (course.classroom.isNotEmpty) ...[
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          course.classroom,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 14),
                      ],
                      if (course.teacher.isNotEmpty) ...[
                        Icon(
                          Icons.person_outline,
                          size: 13,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          course.teacher,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white54 : Colors.black54,
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
    final primary = Theme.of(context).colorScheme.primary;
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
              // 时间轴左侧
              SizedBox(
                width: 50,
                child: Column(
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                        color: isNext
                            ? primary
                            : (isDark ? Colors.white38 : Colors.black38),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      endStr,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white24 : Colors.black26,
                      ),
                    ),
                  ],
                ),
              ),
              // 时间轴线 + 节点
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    Container(
                      width: isNext ? 12 : 8,
                      height: isNext ? 12 : 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isNext ? primary : Colors.transparent,
                        border: Border.all(
                          color: isNext
                              ? primary
                              : (isDark ? Colors.white24 : Colors.black12),
                          width: 2,
                        ),
                        boxShadow: isNext
                            ? [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 1.5,
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                      ),
                  ],
                ),
              ),
              // 课程卡片
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                      borderRadius: BorderRadius.circular(AppDimens.radiusM),
                      boxShadow: isNext
                          ? AppShadows.card(isDark)
                          : AppShadows.cardSubtle(isDark),
                      border: isNext
                          ? Border.all(
                              color: primary.withValues(alpha: 0.3),
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
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF253840),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (course.classroom.isNotEmpty) ...[
                              Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                course.classroom,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            if (course.teacher.isNotEmpty) ...[
                              Icon(
                                Icons.person_outline,
                                size: 12,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                course.teacher,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54,
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

  // ─── 空状态卡片 ───

  Widget _buildEmptyCard(String text, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        boxShadow: AppShadows.cardSubtle(isDark),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : const Color(0xFFF2F3F8),
            ),
            child: Icon(
              icon,
              size: 28,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}
