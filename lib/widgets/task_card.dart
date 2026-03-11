import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_design_tokens.dart';

class TaskCard extends StatefulWidget {
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
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  double _dragExtent = 0;
  static const _deleteThreshold = 72.0;
  static const _actionWidth = 64.0;

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent = (_dragExtent + details.delta.dx).clamp(
        -_deleteThreshold,
        0,
      );
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_dragExtent.abs() > _deleteThreshold * 0.6) {
      // 展开删除按钮
      setState(() => _dragExtent = -_actionWidth);
    } else {
      // 回弹
      setState(() => _dragExtent = 0);
    }
  }

  void _resetDrag() {
    setState(() => _dragExtent = 0);
  }

  void _handleDelete() {
    _resetDrag();
    widget.onDelete?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Stack(
        children: [
          // 删除操作区域（底层）
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerRight,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _dragExtent.abs() > 10 ? 1.0 : 0.0,
                child: GestureDetector(
                  onTap: _handleDelete,
                  child: Container(
                    width: _actionWidth,
                    decoration: BoxDecoration(
                      color: AppTDColors.errorColor,
                      borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(height: 2),
                        Text(
                          '删除',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 前景卡片
          GestureDetector(
            onTap: () {
              if (_dragExtent != 0) {
                _resetDrag();
              } else {
                widget.onTap?.call();
              }
            },
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              transform: Matrix4.translationValues(_dragExtent, 0, 0),
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
                    onTap: widget.onToggle,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 1, right: 10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.task.isDone
                              ? AppTDColors.brandColor7
                              : Colors.transparent,
                          border: Border.all(
                            color: widget.task.isDone
                                ? AppTDColors.brandColor7
                                : (isDark
                                      ? AppTDColors.gray11
                                      : AppTDColors.gray5),
                            width: 1.5,
                          ),
                        ),
                        child: widget.task.isDone
                            ? const Icon(
                                Icons.check,
                                size: 13,
                                color: Colors.white,
                              )
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
                          widget.task.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                            decoration: widget.task.isDone
                                ? TextDecoration.lineThrough
                                : null,
                            color: widget.task.isDone
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
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            if (widget.task.linkedCourse != null &&
                                widget.task.linkedCourse!.isNotEmpty) ...[
                              Icon(
                                Icons.book_outlined,
                                size: 10,
                                color: AppTDColors.brandColor7.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                widget.task.linkedCourse!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTDColors.brandColor7.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _timeLabel {
    final d = widget.task.updatedAt;
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
