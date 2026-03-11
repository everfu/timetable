import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/task.dart';
import '../database/database_helper.dart';
import 'task_card.dart';
import 'task_editor_sheet.dart';

class CourseDetailSheet extends StatefulWidget {
  final Course course;

  const CourseDetailSheet({super.key, required this.course});

  static Future<void> show(BuildContext context, Course course) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CourseDetailSheet(course: course),
    );
  }

  @override
  State<CourseDetailSheet> createState() => _CourseDetailSheetState();
}

class _CourseDetailSheetState extends State<CourseDetailSheet> {
  final DatabaseHelper _db = DatabaseHelper();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _db.getTasksByCourse(widget.course.name);
    if (!mounted) return;
    setState(() => _tasks = tasks);
  }

  Future<void> _openTaskEditor({Task? task}) async {
    final result = await TaskEditorSheet.show(
      context,
      initialTask: task,
      initialLinkedCourse: widget.course.name,
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
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weeksSorted = List<int>.from(course.weeks)..sort();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              course.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.person_outline,
              '教师',
              course.teacher.isEmpty ? '未知' : course.teacher,
            ),
            _buildInfoRow(
              Icons.location_on_outlined,
              '教室',
              course.classroom.isEmpty ? '未知' : course.classroom,
            ),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              '周次',
              course.weekTypeLabel,
            ),
            if (weeksSorted.isNotEmpty)
              _buildInfoRow(
                Icons.date_range_outlined,
                '详细周次',
                weeksSorted.join(', '),
              ),
            _buildInfoRow(
              Icons.access_time_outlined,
              '节次',
              course.sectionName.isEmpty
                  ? '未知'
                  : course.sectionName.replaceAll('\n', ' '),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text(
                  '课程任务',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _openTaskEditor(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('添加'),
                ),
              ],
            ),
            if (_tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    '暂无任务',
                    style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                ),
              )
            else
              ..._tasks.map(
                (task) => TaskCard(
                  task: task,
                  onTap: () => _openTaskEditor(task: task),
                  onToggle: () async {
                    await _db.updateTask(
                      task.copyWith(
                        isDone: !task.isDone,
                        updatedAt: DateTime.now(),
                      ),
                    );
                    await _loadTasks();
                  },
                  onDelete: () async {
                    await _db.deleteTask(task.id!);
                    await _loadTasks();
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
