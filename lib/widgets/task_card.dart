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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key('note_${task.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppTDColors.errorColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? AppTDColors.bgContainerDark
                : AppTDColors.bgContainer,
            borderRadius: BorderRadius.circular(AppRadius.extraLarge),
            boxShadow: TDShadows.base(isDark),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 勾选按钮
              GestureDetector(
                onTap: onToggle,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(top: 1, right: 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isDone
                          ? AppTDColors.brandColor7
                          : Colors.transparent,
                      border: Border.all(
                        color: task.isDone
                            ? AppTDColors.brandColor7
                            : (isDark ? AppTDColors.gray11 : AppTDColors.gray5),
                        width: 1.5,
                      ),
                    ),
                    child: task.isDone
                        ? const Icon(Icons.check, size: 13, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              // 内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
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
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _timeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppTDColors.textDisabledDark
                            : AppTDColors.textDisabled,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _timeLabel {
    final d = task.updatedAt;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) {
      return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    }
    if (diff == 1) return '昨天';
    if (diff < 7) return '$diff 天前';
    return '${d.month}/${d.day}';
  }
}
