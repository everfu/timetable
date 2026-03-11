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
          color: AppTDColors.errorColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.s8),
        decoration: BoxDecoration(
          color: isDark ? AppTDColors.bgContainerDark : AppTDColors.bgContainer,
          borderRadius: BorderRadius.circular(AppRadius.extraLarge),
          boxShadow: TDShadows.base(isDark),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.extraLarge),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 优先级色条
                  Container(
                    width: 3,
                    height: 40,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: task.isDone
                          ? (isDark ? AppTDColors.gray12 : AppTDColors.gray3)
                          : pColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
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
                                    fontWeight: FontWeight.w500,
                                    color: AppTDColors.brandColor7,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s4),
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
                                ? (isDark
                                      ? AppTDColors.textDisabledDark
                                      : AppTDColors.textDisabled)
                                : (isDark
                                      ? AppTDColors.textPrimaryDark
                                      : AppTDColors.textPrimary),
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
                              color: isDark
                                  ? AppTDColors.textPlaceholderDark
                                  : AppTDColors.textPlaceholder,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        // 截止时间
                        if (task.deadline != null && !task.isDone) ...[
                          const SizedBox(height: AppSpacing.s4),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 12,
                                color: _isOverdue
                                    ? AppTDColors.errorColor
                                    : (isDark
                                          ? AppTDColors.textDisabledDark
                                          : AppTDColors.textDisabled),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                _deadlineText,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: _isOverdue
                                      ? AppTDColors.errorColor
                                      : (isDark
                                            ? AppTDColors.textDisabledDark
                                            : AppTDColors.textDisabled),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s8),
                  // 完成按钮
                  GestureDetector(
                    onTap: onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.isDone
                            ? AppTDColors.successColor
                            : Colors.transparent,
                        border: Border.all(
                          color: task.isDone
                              ? AppTDColors.successColor
                              : (isDark
                                    ? AppTDColors.gray11
                                    : AppTDColors.gray5),
                          width: 1.5,
                        ),
                      ),
                      child: task.isDone
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
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
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(AppRadius.small),
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
