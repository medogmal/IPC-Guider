import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart';

/// Standardized export service for the IPC Guider app
/// Follows the CodeGear-1 protocol for professional exports that open cleanly in Excel
class ExportService {
  /// Exports data to Excel format (.xlsx)
  static Future<void> exportToExcel({
    required List<Map<String, dynamic>> data,
    required String fileName,
    required List<String> headers,
    required List<String> columnKeys,
    String? sheetName,
  }) async {
    try {
      // Create a new Excel workbook
      final excel = Excel.createExcel();
      final sheet = excel[sheetName ?? 'Data'];

      // Add headers
      sheet.appendRow(headers.map((header) => TextCellValue(header)).toList());

      // Add data rows
      for (final row in data) {
        final values = columnKeys.map((key) {
          final value = row[key];
          return TextCellValue(value?.toString() ?? '');
        }).toList();
        sheet.appendRow(values);
      }

      // Save to temporary directory
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName.xlsx');
      final bytes = excel.save();
      await file.writeAsBytes(bytes!);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path, name: fileName)],
        subject: 'Export from IPC Guider',
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error exporting to Excel: $e');
      }
      rethrow;
    }
  }

  /// Exports data to CSV format
  static Future<void> exportToCSV({
    required List<Map<String, dynamic>> data,
    required String fileName,
    required List<String> headers,
    required List<String> columnKeys,
  }) async {
    try {
      // Create CSV content
      final StringBuffer buffer = StringBuffer();

      // Add headers
      buffer.writeln(headers.join(','));

      // Add data rows
      for (final row in data) {
        final values = columnKeys.map((key) {
          final value = row[key];
          return _escapeCsvValue(value?.toString() ?? '');
        }).toList();
        buffer.writeln(values.join(','));
      }

      // Save to temporary directory
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName.csv');
      await file.writeAsString(buffer.toString());

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path, name: fileName)],
        subject: 'Export from IPC Guider',
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error exporting to CSV: $e');
      }
      rethrow;
    }
  }

  /// Escapes CSV values that contain special characters
  static String _escapeCsvValue(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Exports calculator results with professional formatting
  static Future<void> exportCalculatorResults({
    required String calculatorName,
    required String formula,
    required Map<String, dynamic> inputs,
    required dynamic result,
    required String interpretation,
    List<Map<String, dynamic>>? references,
    String? fileName,
  }) async {
    try {
      final data = [
        {
          'Calculator': calculatorName,
          'Formula': formula,
          'Inputs': _formatInputs(inputs),
          'Result': _formatResult(result),
          'Interpretation': interpretation,
          'References': _formatReferences(references),
        }
      ];

      await exportToExcel(
        data: data,
        fileName: fileName ?? '${calculatorName}_results',
        headers: ['Calculator', 'Formula', 'Inputs', 'Result', 'Interpretation', 'References'],
        columnKeys: ['Calculator', 'Formula', 'Inputs', 'Result', 'Interpretation', 'References'],
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error exporting calculator results: $e');
      }
      rethrow;
    }
  }

  /// Formats inputs for display
  static String _formatInputs(Map<String, dynamic> inputs) {
    final buffer = StringBuffer();
    inputs.forEach((key, value) {
      buffer.write('$key: $value, ');
    });
    return buffer.toString().replaceAll(RegExp(r',\s*$'), '');
  }

  /// Formats results with appropriate units
  static String _formatResult(dynamic result) {
    if (result is double) {
      return result.toStringAsFixed(2);
    }
    return result.toString();
  }

  /// Formats references for display
  static String _formatReferences(List<Map<String, dynamic>>? references) {
    if (references == null || references.isEmpty) {
      return '';
    }

    final buffer = StringBuffer();
    for (final ref in references) {
      buffer.write('${ref['label']}: ${ref['url']}, ');
    }
    return buffer.toString().replaceAll(RegExp(r',\s*$'), '');
  }
}
