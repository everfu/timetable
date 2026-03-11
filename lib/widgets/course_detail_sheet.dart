import 'package:flutter/material.dart';
import 'package:tdesign_flutter/tdesign_flutter.dart';
import '../models/course.dart';
import '../models/task.dart';
import '../database/database_helper.dart';
import '../theme/app_design_tokens.dart';
import 'task_card.dart';
import 'task_editor_sheet.dart';

class CourseDetailSheet extends StatefulWidget {
  final Course course;

  const CourseDetailSheet({super.key, required this.course});

  static Future<void> show(BuildContext context, Course course) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CourseDetailSheet(course: course),
    );
  }

  @override
  State<CourseDetailSheet> createState() => _CourseDetailSheetState();
}

class _CourseDetailSheetState extends State<CourseDetailSheet> {
  final DatabaseHelper _db = DatabaseHelper();
  List<Task> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _db.getTasksByCourse(widget.course.name);
    if (!mounted) return;
    setState(() => _notes = notes);
  }

  Future<void> _openEditor({Task? task}) async {
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
    await _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weeksSorted = List<int>.from(course.weeks)..sort();
    final pendingCount = _notes.where((n) => !n.isDone).length;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppTDColors.bgContainerDark
                : AppTDColors.bgContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              // 拖拽指示条
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppTDColors.gray11 : AppTDColors.gray4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 课程名
              Text(
                course.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppTDColors.textPrimaryDark
                      : AppTDColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // 课程信息
              _buildInfoRow(
                TDIcons.user,
                '教师',
                course.teacher.isEmpty ? '未知' : course.teacher,
                isDark,
              ),
              _buildInfoRow(
                TDIcons.location,
                '教室',
                course.classroom.isEmpty ? '未知' : course.classroom,
                isDark,
              ),
              _buildInfoRow(
                TDIcons.calendar,
                '周次',
                course.weekTypeLabel,
                isDark,
              ),
              if (weeksSorted.isNotEmpty)
                _buildInfoRow(
                  TDIcons.calendar_2,
                  '详细周次',
                  weeksSorted.join(', '),
                  isDark,
                ),
              _buildInfoRow(
                TDIcons.time,
                '节次',
                course.sectionName.isEmpty
                    ? '未知'
                    : course.sectionName.replaceAll('\n', ' '),
                isDark,
              ),

              const SizedBox(height: 20),

              // 课程记事
              Row(
                children: [
                  Text(
                    '课程记事',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTDColors.textPrimaryDark
                          : AppTDColors.textPrimary,
                    ),
                  ),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppTDColors.brandColor7,
                        borderRadius: BorderRadius.circular(AppRadius.round),
                      ),
                      child: Text(
                        '$pendingCount',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _openEditor(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTDColors.brandColor7.withValues(alpha: 0.15)
                            : AppTDColors.brandColor1,
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            size: 15,
                            color: AppTDColors.brandColor7,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '添加',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTDColors.brandColor7,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_notes.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      '暂无记事，点击添加',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppTDColors.textPlaceholderDark
                            : AppTDColors.textPlaceholder,
                      ),
                    ),
                  ),
                )
              else
                ..._notes.map(
                  (note) => TaskCard(
                    task: note,
                    onTap: () => _openEditor(task: note),
                    onToggle: () async {
                      await _db.updateTask(
                        note.copyWith(
                          isDone: !note.isDone,
                          updatedAt: DateTime.now(),
                        ),
                      );
                      await _loadNotes();
                    },
                    onDelete: () async {
                      await _db.deleteTask(note.id!);
                      await _loadNotes();
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTDColors.brandColor7),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppTDColors.textSecondaryDark
                  : AppTDColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppTDColors.textPrimaryDark
                    : AppTDColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
