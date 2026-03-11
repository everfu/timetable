import 'dart:io';
import 'package:excel/excel.dart' as xlsx;
import 'package:excel2003/excel2003.dart';
import '../models/course.dart';

/// xlsx/xls 解析服务，自动检测格式
class XlsxParser {
  static final Map<String, int> _dayKeywords = {
    '星期一': 1,
    '周一': 1,
    'monday': 1,
    'mon': 1,
    '星期二': 2,
    '周二': 2,
    'tuesday': 2,
    'tue': 2,
    '星期三': 3,
    '周三': 3,
    'wednesday': 3,
    'wed': 3,
    '星期四': 4,
    '周四': 4,
    'thursday': 4,
    'thu': 4,
    '星期五': 5,
    '周五': 5,
    'friday': 5,
    'fri': 5,
    '星期六': 6,
    '周六': 6,
    'saturday': 6,
    'sat': 6,
    '星期日': 7,
    '周日': 7,
    '星期天': 7,
    'sunday': 7,
    'sun': 7,
  };

  /// 大节名称映射
  static const List<String> defaultSectionNames = [
    '早课(01,02)',
    '第一大节(03,04)',
    '第二大节(05,06)',
    '第三大节(07,08)',
    '第四大节(09,10)',
    '第五大节(11,12)',
  ];

  /// 从文件路径解析
  static Future<List<Course>> parseFile(String filePath) async {
    final ext = filePath.toLowerCase();
    if (ext.endsWith('.xls') && !ext.endsWith('.xlsx')) {
      return _parseXls(filePath);
    } else {
      final bytes = await File(filePath).readAsBytes();
      return _parseXlsx(bytes);
    }
  }

  /// 从字节数据解析 xlsx
  static List<Course> parseBytes(List<int> bytes) {
    return _parseXlsx(bytes);
  }

  /// 解析 .xls (BIFF8) 文件
  static List<Course> _parseXls(String filePath) {
    final reader = XlsReader(filePath);
    reader.open();

    if (reader.sheetCount == 0) return [];
    final sheet = reader.sheet(0);

    // 转为二维字符串数组
    final rows = <List<String>>[];
    for (int r = sheet.firstRow; r < sheet.lastRow; r++) {
      final row = <String>[];
      for (int c = sheet.firstCol; c < sheet.lastCol; c++) {
        final val = sheet.cell(r, c);
        row.add(val?.toString().trim() ?? '');
      }
      rows.add(row);
    }

    return _parseRows(rows);
  }

  /// 解析 .xlsx (OOXML) 文件
  static List<Course> _parseXlsx(List<int> bytes) {
    final excel = xlsx.Excel.decodeBytes(bytes);
    final sheetObj = excel.tables[excel.tables.keys.first]!;

    final rows = <List<String>>[];
    for (final row in sheetObj.rows) {
      rows.add(
        row.map((cell) {
          if (cell == null || cell.value == null) return '';
          return cell.value.toString().trim();
        }).toList(),
      );
    }

    return _parseRows(rows);
  }

  /// 核心解析逻辑：从二维字符串数组提取课程
  static List<Course> _parseRows(List<List<String>> rows) {
    if (rows.length < 3) return [];

    // 1. 找到表头行（包含"星期一"等关键词的行）
    int headerRow = -1;
    for (int r = 0; r < rows.length && r < 5; r++) {
      for (final cell in rows[r]) {
        if (_matchDay(cell.toLowerCase()) != null) {
          headerRow = r;
          break;
        }
      }
      if (headerRow >= 0) break;
    }
    if (headerRow < 0) return [];

    // 2. 解析表头，获取每列对应的星期
    final colDayMap = <int, int>{};
    for (int c = 0; c < rows[headerRow].length; c++) {
      final day = _matchDay(rows[headerRow][c].toLowerCase());
      if (day != null) colDayMap[c] = day;
    }
    if (colDayMap.isEmpty) return [];

    // 3. 遍历数据行（表头之后的每行 = 一个大节）
    final courses = <Course>[];
    int sectionIdx = 0;

    for (int r = headerRow + 1; r < rows.length; r++) {
      final row = rows[r];
      if (row.isEmpty) continue;

      // 从第一列提取大节名称
      final firstCol = row[0].trim();
      if (firstCol.isEmpty) continue;

      sectionIdx++;
      if (sectionIdx > 6) break; // 最多6个大节

      // 提取大节显示名（取第一行文字）
      final sectionName = _extractSectionName(firstCol, sectionIdx);

      // 遍历每天的格子
      for (final entry in colDayMap.entries) {
        final c = entry.key;
        final day = entry.value;
        if (c >= row.length) continue;

        final cellContent = row[c].trim();
        if (cellContent.isEmpty) continue;

        // 一个格子可能有多门课（用 \n\n 分隔）
        final courseParts = _splitMultipleCourses(cellContent);
        for (final part in courseParts) {
          final parsed = _parseCourseBlock(part);
          if (parsed != null) {
            courses.add(
              Course(
                name: parsed.name,
                teacher: parsed.teacher,
                classroom: parsed.classroom,
                dayOfWeek: day,
                sectionIndex: sectionIdx,
                sectionName: sectionName,
                weeks: parsed.weeks,
              ),
            );
          }
        }
      }
    }

    return courses;
  }

  /// 提取大节名称
  static String _extractSectionName(String raw, int index) {
    // 原始格式如 "第一大节\n(03,04)\n08:30-10:05"
    final lines = raw.split('\n');
    final name = lines[0].trim();
    if (name.isNotEmpty) {
      // 尝试提取时间信息
      String time = '';
      for (final line in lines) {
        if (RegExp(r'\d{1,2}:\d{2}').hasMatch(line)) {
          time = line.trim();
          break;
        }
      }
      if (time.isNotEmpty) return '$name\n$time';
      return name;
    }
    if (index <= defaultSectionNames.length) {
      return defaultSectionNames[index - 1];
    }
    return '第$index节';
  }

  /// 分割一个格子中的多门课程
  static List<String> _splitMultipleCourses(String content) {
    // 用连续两个换行分割
    final parts = content.split(RegExp(r'\n\s*\n'));
    return parts.where((p) => p.trim().isNotEmpty).toList();
  }

  /// 解析单门课程文本块
  static _ParsedCourse? _parseCourseBlock(String block) {
    final lines = block
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) return null;

    String name = lines[0];
    String teacher = '';
    String classroom = '';
    List<int> weeks = [];

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i];

      // 检测周次信息：包含 ([周]) 或 [xx-xx节]
      if (line.contains('周') && (line.contains('[') || line.contains('('))) {
        weeks = _parseWeeks(line);
      }
      // 检测教室：通常包含字母+数字组合如 A9-509
      else if (RegExp(r'[A-Za-z]\d|教室|楼|室|号').hasMatch(line) &&
          classroom.isEmpty) {
        classroom = line;
      }
      // 其他视为教师
      else if (teacher.isEmpty && !line.contains('[') && !line.contains('节')) {
        teacher = line;
      }
    }

    // 如果课程名为空或太短，跳过
    if (name.isEmpty || name.length < 2) return null;

    return _ParsedCourse(
      name: name,
      teacher: teacher,
      classroom: classroom,
      weeks: weeks,
    );
  }

  /// 解析周次字符串
  /// 支持格式：
  ///   "1-16([周])[03-04节]"  → [1,2,3,...,16]
  ///   "1,3,5,7,9,11,13,15([周])[03-04节]" → [1,3,5,7,9,11,13,15]
  ///   "2,4,6,8,10,12,14,16([周])[07-08节]" → [2,4,6,8,10,12,14,16]
  static List<int> _parseWeeks(String text) {
    // 提取 ([周]) 前面的部分
    final weekMatch = RegExp(
      r'([\d,\-\s]+)\s*\(\s*\[?\s*周\s*\]?\s*\)',
    ).firstMatch(text);
    if (weekMatch == null) {
      // 尝试其他格式
      final altMatch = RegExp(r'([\d,\-\s]+)\s*周').firstMatch(text);
      if (altMatch == null) return [];
      return _parseWeekNumbers(altMatch.group(1)!);
    }
    return _parseWeekNumbers(weekMatch.group(1)!);
  }

  /// 解析周次数字部分
  /// "1-16" → [1..16]
  /// "1,3,5,7,9,11,13,15" → [1,3,5,7,9,11,13,15]
  static List<int> _parseWeekNumbers(String numStr) {
    final result = <int>[];
    final parts = numStr.split(',');

    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.contains('-')) {
        final range = trimmed.split('-');
        if (range.length == 2) {
          final start = int.tryParse(range[0].trim());
          final end = int.tryParse(range[1].trim());
          if (start != null && end != null) {
            for (int i = start; i <= end; i++) {
              result.add(i);
            }
          }
        }
      } else {
        final num = int.tryParse(trimmed);
        if (num != null) result.add(num);
      }
    }

    return result;
  }

  static int? _matchDay(String text) {
    for (final entry in _dayKeywords.entries) {
      if (text.contains(entry.key)) return entry.value;
    }
    return null;
  }
}

class _ParsedCourse {
  final String name;
  final String teacher;
  final String classroom;
  final List<int> weeks;

  _ParsedCourse({
    required this.name,
    this.teacher = '',
    this.classroom = '',
    this.weeks = const [],
  });
}
