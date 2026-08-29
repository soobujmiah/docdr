import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

/// Generic CSV/XLSX reader for DocDr data-mapping and batch-generation workflows.
class DocDrDataService {
  static Future<List<Map<String, String>>> readRows(String path) async {
    if (path.toLowerCase().endsWith('.xlsx')) return _xlsx(path);
    return _csv(path);
  }

  static Future<List<Map<String, String>>> _csv(String path) async {
    final rows = const CsvToListConverter(shouldParseNumbers: false)
        .convert(await File(path).readAsString(encoding: utf8));
    if (rows.isEmpty) return [];
    final headers = rows.first.map((v) => _header(v.toString())).toList();
    return _maps(headers, rows.skip(1).map((r) => r.map((e) => e.toString()).toList()));
  }

  static Future<List<Map<String, String>>> _xlsx(String path) async {
    final workbook = Excel.decodeBytes(await File(path).readAsBytes());
    if (workbook.tables.isEmpty) return [];
    final sheet = workbook.tables.values.first;
    if (sheet.rows.isEmpty) return [];
    final rows = sheet.rows
        .map((row) => row.map((cell) => _cell(cell?.value)).toList())
        .toList();
    return _maps(rows.first.map(_header).toList(), rows.skip(1));
  }

  static String _cell(CellValue? value) {
    return switch (value) {
      null => '',
      TextCellValue() => value.value.toString(),
      FormulaCellValue() => value.formula.toString(),
      IntCellValue() => value.value.toString(),
      DoubleCellValue() => value.value.toString(),
      BoolCellValue() => value.value ? 'true' : 'false',
      DateCellValue() => value.asDateTimeLocal().toIso8601String().split('T').first,
      DateTimeCellValue() => value.asDateTimeLocal().toIso8601String(),
      TimeCellValue() => value.asDuration().toString(),
    };
  }

  static String _header(String value) => value
      .replaceAll('\uFEFF', '')
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9_]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  static List<Map<String, String>> _maps(
    List<String> headers,
    Iterable<List<String>> rows,
  ) {
    final output = <Map<String, String>>[];
    for (final row in rows) {
      final map = <String, String>{};
      var hasValue = false;
      for (var i = 0; i < headers.length; i++) {
        if (headers[i].isEmpty) continue;
        final value = i < row.length ? row[i].trim() : '';
        map[headers[i]] = value;
        hasValue |= value.isNotEmpty;
      }
      if (hasValue) output.add(map);
    }
    return output;
  }
}
