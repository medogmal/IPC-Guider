import 'dart:convert';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/history_entry.dart';

class HistoryExportService {
  // Export to CSV format
  static Future<Uint8List> exportToCsv(List<HistoryEntry> entries) async {
    if (entries.isEmpty) {
      throw ExportException('No entries to export');
    }

    final headers = [
      'Date',
      'Tool Type',
      'Title',
      'Inputs',
      'Result',
      'Notes',
      'Context',
      'Tags',
    ];

    final rows = <List<String>>[headers];

    for (final entry in entries) {
      final inputsText = entry.inputs.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('; ');

      rows.add([
        _formatDateTime(entry.timestamp),
        entry.toolType,
        entry.title,
        inputsText,
        entry.result,
        entry.notes,
        entry.contextTag ?? '',
        entry.tags.join(', '),
      ]);
    }

    final csvString = const ListToCsvConverter().convert(rows);
    return Uint8List.fromList(utf8.encode(csvString));
  }

  // Export to Excel format
  static Future<Uint8List> exportToExcel(List<HistoryEntry> entries) async {
    if (entries.isEmpty) {
      throw ExportException('No entries to export');
    }

    final excel = Excel.createExcel();
    final sheet = excel['History'];
    
    // Remove default sheet if it exists
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    // Headers
    final headers = [
      'Date',
      'Tool Type',
      'Title',
      'Inputs',
      'Result',
      'Notes',
      'Context',
      'Tags',
    ];

    // Add headers with formatting
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.blue50,
        fontColorHex: ExcelColor.black,
      );
    }

    // Add data rows
    for (int rowIndex = 0; rowIndex < entries.length; rowIndex++) {
      final entry = entries[rowIndex];
      final inputsText = entry.inputs.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('; ');

      final rowData = [
        _formatDateTime(entry.timestamp),
        entry.toolType,
        entry.title,
        inputsText,
        entry.result,
        entry.notes,
        entry.contextTag ?? '',
        entry.tags.join(', '),
      ];

      for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: colIndex,
          rowIndex: rowIndex + 1,
        ));
        cell.value = TextCellValue(rowData[colIndex]);
      }
    }

    // Auto-fit columns
    for (int i = 0; i < headers.length; i++) {
      sheet.setColumnAutoFit(i);
    }

    return Uint8List.fromList(excel.encode()!);
  }

  // Export to PDF format (simplified table)
  static Future<Uint8List> exportToPdf(List<HistoryEntry> entries) async {
    if (entries.isEmpty) {
      throw ExportException('No entries to export');
    }

    // For now, create a simple text-based PDF content
    // In a real implementation, you'd use a PDF library like pdf
    final buffer = StringBuffer();
    buffer.writeln('IPC Guider - History Export');
    buffer.writeln('Generated: ${_formatDateTime(DateTime.now())}');
    buffer.writeln('Total Entries: ${entries.length}');
    buffer.writeln('');
    buffer.writeln('=' * 80);
    buffer.writeln('');

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      buffer.writeln('Entry ${i + 1}:');
      buffer.writeln('Date: ${_formatDateTime(entry.timestamp)}');
      buffer.writeln('Tool: ${entry.toolType} - ${entry.title}');
      buffer.writeln('Result: ${entry.result}');
      
      if (entry.inputs.isNotEmpty) {
        buffer.writeln('Inputs:');
        entry.inputs.forEach((key, value) {
          buffer.writeln('  • $key: $value');
        });
      }
      
      if (entry.notes.isNotEmpty) {
        buffer.writeln('Notes: ${entry.notes}');
      }
      
      if (entry.contextTag != null && entry.contextTag!.isNotEmpty) {
        buffer.writeln('Context: ${entry.contextTag}');
      }
      
      if (entry.tags.isNotEmpty) {
        buffer.writeln('Tags: ${entry.tags.join(', ')}');
      }
      
      buffer.writeln('');
      buffer.writeln('-' * 40);
      buffer.writeln('');
    }

    return Uint8List.fromList(utf8.encode(buffer.toString()));
  }

  // Share exported data using system share sheet
  static Future<void> shareExport({
    required List<HistoryEntry> entries,
    required ExportFormat format,
    String? customFileName,
  }) async {
    if (entries.isEmpty) {
      throw ExportException('No entries to export');
    }

    try {
      Uint8List data;
      String fileName;
      String mimeType;

      switch (format) {
        case ExportFormat.csv:
          data = await exportToCsv(entries);
          fileName = customFileName ?? 'ipc_history_${_getTimestamp()}.csv';
          mimeType = 'text/csv';
          break;
        case ExportFormat.excel:
          data = await exportToExcel(entries);
          fileName = customFileName ?? 'ipc_history_${_getTimestamp()}.xlsx';
          mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
          break;
        case ExportFormat.pdf:
          data = await exportToPdf(entries);
          fileName = customFileName ?? 'ipc_history_${_getTimestamp()}.pdf';
          mimeType = 'application/pdf';
          break;
      }

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(data);

      // Share using system share sheet
      await Share.shareXFiles(
        [XFile(file.path, mimeType: mimeType)],
        subject: 'IPC Guider History Export',
        text: 'History export containing ${entries.length} entries',
      );

      // Clean up temporary file after a delay
      Future.delayed(const Duration(minutes: 5), () {
        try {
          if (file.existsSync()) {
            file.deleteSync();
          }
        } catch (e) {
          // Ignore cleanup errors
        }
      });
    } catch (e) {
      throw ExportException('Failed to export data: $e');
    }
  }

  // Get export statistics
  static Map<String, dynamic> getExportStatistics(List<HistoryEntry> entries) {
    if (entries.isEmpty) {
      return {
        'totalEntries': 0,
        'toolTypes': <String, int>{},
        'dateRange': null,
        'estimatedSize': '0 KB',
      };
    }

    final toolTypes = <String, int>{};
    DateTime? earliest, latest;

    for (final entry in entries) {
      toolTypes[entry.toolType] = (toolTypes[entry.toolType] ?? 0) + 1;
      
      if (earliest == null || entry.timestamp.isBefore(earliest)) {
        earliest = entry.timestamp;
      }
      if (latest == null || entry.timestamp.isAfter(latest)) {
        latest = entry.timestamp;
      }
    }

    // Estimate file size (rough calculation)
    final avgEntrySize = 500; // bytes per entry (rough estimate)
    final estimatedBytes = entries.length * avgEntrySize;
    final estimatedSize = estimatedBytes < 1024
        ? '$estimatedBytes B'
        : estimatedBytes < 1024 * 1024
            ? '${(estimatedBytes / 1024).toStringAsFixed(1)} KB'
            : '${(estimatedBytes / (1024 * 1024)).toStringAsFixed(1)} MB';

    return {
      'totalEntries': entries.length,
      'toolTypes': toolTypes,
      'dateRange': earliest != null && latest != null
          ? '${_formatDate(earliest)} - ${_formatDate(latest)}'
          : null,
      'estimatedSize': estimatedSize,
    };
  }

  // Format datetime for display
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // Format date only
  static String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  // Get timestamp for filename
  static String _getTimestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
           '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
  }
}

// Export formats
enum ExportFormat {
  csv,
  excel,
  pdf,
}

// Export exception
class ExportException implements Exception {
  final String message;
  ExportException(this.message);
  
  @override
  String toString() => 'ExportException: $message';
}
