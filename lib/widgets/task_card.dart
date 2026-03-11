import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_design_tokens.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggle,
    this.onDelete,
  });

  bool get _isOverdue =>
      task.deadline != null &&
      task.deadline!.isBefore(DateTime.now()) &&
      !task.isDone;

  String get _deadlineText {
    if (task.deadline == null) return '';
    final d = task.deadline!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = target.difference(today).inDays;
    if (diff < 0) return '已过期 ${-diff} 天';
    if (diff == 0) return '今天截止';
    if (diff == 1) return '明天截止';
    if (diff <= 7) return '$diff 天后截止';
    return '${d.month}/${d.day} 截止';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pColor = AppColors.priorityColor(task.priority);
    final tColor = AppColors.typeColor(task.type);

    return Dismissible(
      key: Key('task_${task.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppDimens.spaceS),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spaceM,
              vertical: AppDimens.spaceM,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 优先级色条
                Container(
                  width: 3,
                  height: 44,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: task.isDone
                        ? (isDark ? Colors.white12 : Colors.black12)
                        : pColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: AppDimens.spaceS),
                // 内容
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标签行
                      Row(
                        children: [
                          _buildTypeChip(tColor, isDark),
                          if (task.linkedCourse != null &&
                              task.linkedCourse!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                task.linkedCourse!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppDimens.spaceXS),
                      // 标题
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: task.isDone
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isDone
                              ? (isDark ? Colors.white38 : Colors.black38)
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // 描述
                      if (task.description.isNotEmpty && !task.isDone) ...[
                        const SizedBox(height: 2),
                        Text(
                          task.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white38 : Colors.black45,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      // 截止时间
                      if (task.deadline != null) ...[
                        const SizedBox(height: AppDimens.spaceXS),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 12,
                              color: _isOverdue
                                  ? AppColors.priorityHigh
                                  : (isDark ? Colors.white38 : Colors.black38),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              _deadlineText,
                              style: TextStyle(
                                fontSize: 11,
                                color: _isOverdue
                                    ? AppColors.priorityHigh
                                    : (isDark
                                          ? Colors.white38
                                          : Colors.black38),
                                fontWeight: _isOverdue
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppDimens.spaceS),
                // 完成按钮
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isDone ? Colors.green : Colors.transparent,
                      border: Border.all(
                        color: task.isDone
                            ? Colors.green
                            : (isDark ? Colors.white24 : Colors.black26),
                        width: 2,
                      ),
                    ),
                    child: task.isDone
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        task.type.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
