import 'package:excel/excel.dart';

/// xlsx 课表模板生成服务
class TemplateGenerator {
  static const List<String> _dayHeaders = ['星期一', '星期二', '星期三', '星期四', '星期五'];
  static const List<String> _sectionNames = [
    '早课\n(01,02)',
    '第一大节\n(03,04)',
    '第二大节\n(05,06)',
    '第三大节\n(07,08)',
    '第四大节\n(09,10)',
    '第五大节\n(11,12)',
  ];

  /// 生成空白课表模板，返回字节数据
  static List<int> generateTemplateBytes() {
    final excel = Excel.createExcel();
    final sheetName = '课表模板';
    excel.rename(excel.getDefaultSheet()!, sheetName);
    final sheet = excel[sheetName];

    final headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#4472C4'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      fontSize: 12,
    );

    final sectionStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#D9E2F3'),
      fontSize: 10,
      textWrapping: TextWrapping.WrapText,
    );

    final dataStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      fontSize: 10,
      textWrapping: TextWrapping.WrapText,
    );

    // 左上角
    final cornerCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
    );
    cornerCell.value = TextCellValue('节次');
    cornerCell.cellStyle = headerStyle;

    sheet.setColumnWidth(0, 16);
    for (int c = 0; c < _dayHeaders.length; c++) {
      sheet.setColumnWidth(c + 1, 22);
    }

    // 星期表头
    for (int c = 0; c < _dayHeaders.length; c++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: c + 1, rowIndex: 0),
      );
      cell.value = TextCellValue(_dayHeaders[c]);
      cell.cellStyle = headerStyle;
    }

    // 大节行
    for (int r = 0; r < _sectionNames.length; r++) {
      final sectionCell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: r + 1),
      );
      sectionCell.value = TextCellValue(_sectionNames[r]);
      sectionCell.cellStyle = sectionStyle;

      for (int c = 0; c < _dayHeaders.length; c++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: c + 1, rowIndex: r + 1),
        );
        // 填入示例
        if (r == 1 && c == 0) {
          cell.value = TextCellValue('高等数学\n张老师\n1-16([周])[03-04节]\nA9-509');
        } else if (r == 1 && c == 1) {
          cell.value = TextCellValue(
            '大学英语\n李老师\n1,3,5,7,9,11,13,15([周])[03-04节]\nB203',
          );
        }
        cell.cellStyle = dataStyle;
      }
    }

    // 说明 sheet
    const infoSheetName = '填写说明';
    excel[infoSheetName];
    final infoSheet = excel[infoSheetName];
    infoSheet.setColumnWidth(0, 65);

    final infoTitleStyle = CellStyle(bold: true, fontSize: 14);
    final infoStyle = CellStyle(fontSize: 11);

    final instructions = [
      ('课表填写说明', infoTitleStyle),
      ('', infoStyle),
      ('1. 在"课表模板"工作表中填写课程信息', infoStyle),
      ('2. 每个格子的格式（每项一行）：', infoStyle),
      ('   课程名', infoStyle),
      ('   教师', infoStyle),
      ('   周次([周])[节次]', infoStyle),
      ('   教室', infoStyle),
      ('', infoStyle),
      ('3. 周次格式示例：', infoStyle),
      ('   1-16([周])[03-04节]        → 第1到16周都有', infoStyle),
      ('   1,3,5,7,9,11,13,15([周])   → 单周有课', infoStyle),
      ('   2,4,6,8,10,12,14,16([周])  → 双周有课', infoStyle),
      ('', infoStyle),
      ('4. 同一格子有多门课时，用空行分隔', infoStyle),
      ('5. 也可以直接从教务系统导出的 xls/xlsx 文件导入', infoStyle),
    ];

    for (int i = 0; i < instructions.length; i++) {
      final cell = infoSheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i),
      );
      cell.value = TextCellValue(instructions[i].$1);
      cell.cellStyle = instructions[i].$2;
    }

    final bytes = excel.save();
    if (bytes == null) throw Exception('生成模板失败');
    return bytes;
  }
}
