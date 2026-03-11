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
      duration: const Duration(milliseconds: 800),
    );
    _dateCardAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _nextCourseAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.1, 0.45, curve: Curves.easeOut),
    );
    _courseListAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );
    _taskAreaAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 0.75, curve: Curves.easeOut),
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
                padding: EdgeInsets.fromLTRB(16, 0, 16, bottomReserved),
                children: [
                  // 日期信息卡
                  FadeTransition(
                    opacity: _dateCardAnim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(_dateCardAnim),
                      child: _buildDateCard(isDark, colorScheme),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 下一节课高亮
                  if (_nextCourse != null) ...[
                    FadeTransition(
                      opacity: _nextCourseAnim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.08),
                          end: Offset.zero,
                        ).animate(_nextCourseAnim),
                        child: _buildNextCourseCard(
                          _nextCourse!,
                          isDark,
                          colorScheme,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // 今日课程列表
                  FadeTransition(
                    opacity: _courseListAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('今日课程'),
                        const SizedBox(height: 8),
                        if (_todayCourses.isEmpty)
                          _buildEmptyCard(
                            '今天没有课，好好休息吧',
                            Icons.wb_sunny_outlined,
                          )
                        else
                          ..._todayCourses.map(
                            (c) => _buildCourseItem(c, isDark),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 待办事项
                  FadeTransition(
                    opacity: _taskAreaAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              '待办事项',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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

  Widget _buildDateCard(bool isDark, ColorScheme colorScheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dateLabel,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _weekLabel,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_todayCourses.length} 节课',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildNextCourseCard(
    Course course,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final times = _sectionTimes[course.sectionIndex];
    final timeStr = times != null ? '${times.$1} - ${times.$2}' : '';

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  '即将上课',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              course.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                if (course.classroom.isNotEmpty) ...[
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.7,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    course.classroom,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseItem(Course course, bool isDark) {
    final times = _sectionTimes[course.sectionIndex];
    final timeStr = times != null ? '${times.$1}\n${times.$2}' : '';
    final isNext = course == _nextCourse;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(
                timeStr,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white38 : Colors.black38,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 3,
              height: 40,
              decoration: BoxDecoration(
                color: isNext
                    ? Theme.of(context).colorScheme.primary
                    : (isDark ? Colors.white12 : Colors.black12),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
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
                            color: isDark ? Colors.white38 : Colors.black38,
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
                            color: isDark ? Colors.white38 : Colors.black38,
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
      ),
    );
  }

  Widget _buildEmptyCard(String text, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Column(
            children: [
              Icon(
                icon,
                size: 40,
                color: isDark ? Colors.white24 : Colors.black12,
              ),
              const SizedBox(height: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
