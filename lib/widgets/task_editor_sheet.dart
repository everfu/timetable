import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task.dart';
import '../theme/app_design_tokens.dart';

class TaskEditorSheet extends StatefulWidget {
  final Task? initialTask;
  final String? initialLinkedCourse;

  const TaskEditorSheet({
    super.key,
    this.initialTask,
    this.initialLinkedCourse,
  });

  static Future<Object?> show(
    BuildContext context, {
    Task? initialTask,
    String? initialLinkedCourse,
  }) {
    return showModalBottomSheet<Object?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskEditorSheet(
        initialTask: initialTask,
        initialLinkedCourse: initialLinkedCourse,
      ),
    );
  }

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _db = DatabaseHelper();

  List<String> _courseOptions = [];
  String? _linkedCourse;
  TaskType _type = TaskType.other;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _deadline;
  bool _loadingCourses = true;

  bool get _isEditing => widget.initialTask != null;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _titleController.text = task?.title ?? '';
    _descriptionController.text = task?.description ?? '';
    _linkedCourse = task?.linkedCourse ?? widget.initialLinkedCourse;
    _type = task?.type ?? TaskType.other;
    _priority = task?.priority ?? TaskPriority.medium;
    _deadline = task?.deadline;
    _loadCourses();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    final courses = await _db.getDistinctCourseNames();
    if (!mounted) return;
    setState(() {
      _courseOptions = courses;
      _loadingCourses = false;
    });
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline ?? now),
    );

    setState(() {
      _deadline = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 23,
        time?.minute ?? 59,
      );
    });
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final now = DateTime.now();
    final task = Task(
      id: widget.initialTask?.id,
      title: title,
      description: _descriptionController.text.trim(),
      linkedCourse: _linkedCourse,
      type: _type,
      priority: _priority,
      deadline: _deadline,
      remindAt: widget.initialTask?.remindAt,
      isDone: widget.initialTask?.isDone ?? false,
      createdAt: widget.initialTask?.createdAt ?? now,
      updatedAt: now,
    );

    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.6,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.extraLarge),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
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
              Row(
                children: [
                  Text(
                    _isEditing ? '编辑事项' : '新建事项',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  FilledButton(onPressed: _save, child: const Text('保存')),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '输入标题...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Divider(height: 24),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: '添加详细描述...',
                  border: InputBorder.none,
                ),
                maxLines: 4,
                minLines: 2,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
              const Divider(height: 28),
              _buildPropertyRow(
                icon: Icons.category_outlined,
                label: '类型',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TaskType.values
                      .map(
                        (type) => ChoiceChip(
                          label: Text(type.label),
                          selected: _type == type,
                          onSelected: (_) => setState(() => _type = type),
                        ),
                      )
                      .toList(),
                ),
              ),
              _buildPropertyRow(
                icon: Icons.flag_outlined,
                label: '优先级',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TaskPriority.values
                      .map(
                        (priority) => ChoiceChip(
                          label: Text(priority.label),
                          selected: _priority == priority,
                          onSelected: (_) =>
                              setState(() => _priority = priority),
                        ),
                      )
                      .toList(),
                ),
              ),
              _buildPropertyRow(
                icon: Icons.calendar_today_outlined,
                label: '截止时间',
                child: InkWell(
                  onTap: _pickDeadline,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _deadline != null
                          ? '${_deadline!.year}/${_deadline!.month}/${_deadline!.day} ${_deadline!.hour.toString().padLeft(2, '0')}:${_deadline!.minute.toString().padLeft(2, '0')}'
                          : '点击选择',
                      style: TextStyle(
                        color: _deadline != null
                            ? null
                            : (isDark ? Colors.white38 : Colors.black38),
                      ),
                    ),
                  ),
                ),
              ),
              _buildPropertyRow(
                icon: Icons.book_outlined,
                label: '关联课程',
                child: _loadingCourses
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: _courseOptions.contains(_linkedCourse)
                              ? _linkedCourse
                              : null,
                          isExpanded: true,
                          hint: const Text('无关联课程'),
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('无关联课程'),
                            ),
                            ..._courseOptions.map(
                              (course) => DropdownMenuItem<String?>(
                                value: course,
                                child: Text(course),
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _linkedCourse = value);
                          },
                        ),
                      ),
              ),
              _buildPropertyRow(
                icon: Icons.notifications_outlined,
                label: '提醒',
                child: Text(
                  '暂不支持',
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ),
              if (_isEditing) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context, '__delete__'),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    '删除此事项',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildPropertyRow({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: isDark ? Colors.white54 : Colors.black54),
          const SizedBox(width: 10),
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );
  }
}
