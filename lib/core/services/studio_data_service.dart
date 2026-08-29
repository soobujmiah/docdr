import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';

/// Reads generic CSV/XLSX records for DocDr batch workflows.
class DocDrDataService {
  static Future<List<Map<String,String>>> readRows(String path) async {
    if (path.toLowerCase().endsWith('.xlsx')) return _xlsx(path);
    return _csv(path);
  }
  static Future<List<Map<String,String>>> _csv(String path) async {
    final rows=const CsvToListConverter(shouldParseNumbers:false).convert(await File(path).readAsString(encoding:utf8));
    if(rows.isEmpty)return [];
    final headers=rows.first.map((v)=>_header(v.toString())).toList();
    return _maps(headers,rows.skip(1).map((r)=>r.map((e)=>e.toString()).toList()));
  }
  static Future<List<Map<String,String>>> _xlsx(String path) async {
    final wb=Excel.decodeBytes(await File(path).readAsBytes()); if(wb.tables.isEmpty)return [];
    final sheet=wb.tables.values.first; if(sheet.rows.isEmpty)return [];
    final rows=sheet.rows.map((r)=>r.map((c)=>_cell(c?.value)).toList()).toList();
    return _maps(rows.first.map(_header).toList(),rows.skip(1));
  }
  static String _cell(CellValue? v)=>switch(v){null=>'',TextCellValue()=>v.value.toString(),FormulaCellValue()=>v.formula.toString(),IntCellValue()=>v.value.toString(),DoubleCellValue()=>v.value.toString(),BoolCellValue()=>v.value?'true':'false',DateCellValue()=>v.asDateTimeLocal().toIso8601String().split('T').first,DateTimeCellValue()=>v.asDateTimeLocal().toIso8601String(),TimeCellValue()=>v.asDuration().toString()};
  static String _header(String v)=>v.replaceAll('\uFEFF','').trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]+'),'_').replaceAll(RegExp(r'^_+|_+$'),'');
  static List<Map<String,String>> _maps(List<String> headers,Iterable<List<String>> rows){final out=<Map<String,String>>[];for(final row in rows){final m=<String,String>{};var has=false;for(var i=0;i<headers.length;i++){if(headers[i].isEmpty)continue;final v=i<row.length?row[i].trim():'';m[headers[i]]=v;has|=v.isNotEmpty;}if(has)out.add(m);}return out;}
}
