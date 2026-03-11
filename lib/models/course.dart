class Course {
  final int? id;
  final String name;
  final String teacher;
  final String classroom;
  final int dayOfWeek; // 1-7
  final int sectionIndex; // 大节序号 1-6
  final String sectionName; // "早课(01,02)" 等
  final List<int> weeks; // 具体哪些周有课 [1,3,5,7,9,11,13,15]

  const Course({
    this.id,
    required this.name,
    this.teacher = '',
    this.classroom = '',
    required this.dayOfWeek,
    required this.sectionIndex,
    this.sectionName = '',
    this.weeks = const [],
  });

  /// 判断某周是否有这门课
  bool isInWeek(int weekNum) {
    if (weeks.isEmpty) return true; // 没有周次信息则默认全周
    return weeks.contains(weekNum);
  }

  /// 周次简写标签
  String get weekTypeLabel {
    if (weeks.isEmpty) return '全周';
    final sorted = List<int>.from(weeks)..sort();

    // 检查是否全周 1-16
    if (sorted.length >= 16) return '全周';

    // 检查是否纯单周
    if (sorted.every((w) => w.isOdd)) return '单周';
    // 检查是否纯双周
    if (sorted.every((w) => w.isEven)) return '双周';

    // 尝试连续范围表示
    if (_isConsecutive(sorted)) {
      return '${sorted.first}-${sorted.last}周';
    }

    // 其他情况直接列出
    if (sorted.length <= 4) {
      return '${sorted.join(",")}周';
    }
    return '${sorted.first}-${sorted.last}周';
  }

  bool _isConsecutive(List<int> list) {
    for (int i = 1; i < list.length; i++) {
      if (list[i] != list[i - 1] + 1) return false;
    }
    return true;
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'teacher': teacher,
      'classroom': classroom,
      'dayOfWeek': dayOfWeek,
      'sectionIndex': sectionIndex,
      'sectionName': sectionName,
      'weeks': weeks.join(','),
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    final weeksStr = (map['weeks'] as String?) ?? '';
    final weeks = weeksStr.isEmpty
        ? <int>[]
        : weeksStr
              .split(',')
              .map((s) => int.tryParse(s.trim()) ?? 0)
              .where((w) => w > 0)
              .toList();

    return Course(
      id: map['id'] as int?,
      name: map['name'] as String,
      teacher: (map['teacher'] as String?) ?? '',
      classroom: (map['classroom'] as String?) ?? '',
      dayOfWeek: map['dayOfWeek'] as int,
      sectionIndex: map['sectionIndex'] as int,
      sectionName: (map['sectionName'] as String?) ?? '',
      weeks: weeks,
    );
  }

  Course copyWith({
    int? id,
    String? name,
    String? teacher,
    String? classroom,
    int? dayOfWeek,
    int? sectionIndex,
    String? sectionName,
    List<int>? weeks,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      classroom: classroom ?? this.classroom,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      sectionIndex: sectionIndex ?? this.sectionIndex,
      sectionName: sectionName ?? this.sectionName,
      weeks: weeks ?? this.weeks,
    );
  }
}
