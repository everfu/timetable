import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_design_tokens.dart';

class TaskEditorSheet {
  static Future<dynamic> show(
    BuildContext context, {
    Task? initialTask,
    String? initialLinkedCourse,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NoteEditorBody(initialTask: initialTask),
    );
  }
}

class _NoteEditorBody extends StatefulWidget {
  final Task? initialTask;

  const _NoteEditorBody({this.initialTask});

  @override
  State<_NoteEditorBody> createState() => _NoteEditorBodyState();
}

class _NoteEditorBodyState extends State<_NoteEditorBody> {
  late TextEditingController _controller;
  bool get _isEdit => widget.initialTask != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTask?.title ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    if (_isEdit) {
      Navigator.pop(
        context,
        widget.initialTask!.copyWith(title: text, updatedAt: now),
      );
    } else {
      Navigator.pop(context, Task.note(text));
    }
  }

  void _delete() {
    Navigator.pop(context, '__delete__');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: isDark ? AppTDColors.bgContainerDark : AppTDColors.bgContainer,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.extraLarge),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖拽指示条
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppTDColors.gray11 : AppTDColors.gray4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // 标题
              Row(
                children: [
                  Text(
                    _isEdit ? '编辑记事' : '新建记事',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTDColors.textPrimaryDark
                          : AppTDColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  if (_isEdit)
                    GestureDetector(
                      onTap: _delete,
                      child: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: AppTDColors.errorColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // 输入框
              TextField(
                controller: _controller,
                autofocus: true,
                maxLines: 4,
                minLines: 2,
                textInputAction: TextInputAction.newline,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: isDark
                      ? AppTDColors.textPrimaryDark
                      : AppTDColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '写点什么...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppTDColors.textPlaceholderDark
                        : AppTDColors.textPlaceholder,
                  ),
                  filled: true,
                  fillColor: isDark ? AppTDColors.gray13 : AppTDColors.gray1,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 16),

              // 保存按钮
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTDColors.brandColor7,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.extraLarge),
                    ),
                  ),
                  child: Text(
                    _isEdit ? '保存' : '添加',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
