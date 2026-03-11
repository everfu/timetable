// 保留旧枚举以兼容数据库已有数据
enum TaskType {
  homework,
  exam,
  review,
  other;

  String get label {
    switch (this) {
      case homework:
        return '作业';
      case exam:
        return '考试';
      case review:
        return '复习';
      case other:
        return '其他';
    }
  }

  static TaskType fromString(String s) {
    switch (s) {
      case 'homework':
        return homework;
      case 'exam':
        return exam;
      case 'review':
        return review;
      default:
        return other;
    }
  }
}

enum TaskPriority {
  high,
  medium,
  low;

  static TaskPriority fromString(String s) {
    switch (s) {
      case 'high':
        return high;
      case 'low':
        return low;
      default:
        return medium;
    }
  }
}

/// 简化的记事模型，复用 tasks 表
class Task {
  final int? id;
  final String title; // 记事内容
  final String description;
  final String? linkedCourse;
  final TaskType type;
  final TaskPriority priority;
  final DateTime? deadline;
  final DateTime? remindAt;
  final bool isDone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    this.id,
    required this.title,
    this.description = '',
    this.linkedCourse,
    this.type = TaskType.other,
    this.priority = TaskPriority.medium,
    this.deadline,
    this.remindAt,
    this.isDone = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 快速创建记事（必须关联课程）
  factory Task.note(String content, {required String linkedCourse}) {
    final now = DateTime.now();
    return Task(
      title: content,
      linkedCourse: linkedCourse,
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'linkedCourse': linkedCourse,
      'type': type.name,
      'priority': priority.name,
      'deadline': deadline?.toIso8601String(),
      'remindAt': remindAt?.toIso8601String(),
      'isDone': isDone ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      linkedCourse: map['linkedCourse'] as String?,
      type: TaskType.fromString((map['type'] as String?) ?? 'other'),
      priority: TaskPriority.fromString(
        (map['priority'] as String?) ?? 'medium',
      ),
      deadline: map['deadline'] != null
          ? DateTime.tryParse(map['deadline'] as String)
          : null,
      remindAt: map['remindAt'] != null
          ? DateTime.tryParse(map['remindAt'] as String)
          : null,
      isDone: (map['isDone'] as int?) == 1,
      createdAt:
          DateTime.tryParse((map['createdAt'] as String?) ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse((map['updatedAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? isDone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      linkedCourse: linkedCourse,
      type: type,
      priority: priority,
      deadline: deadline,
      remindAt: remindAt,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
