import 'dart:convert';
import 'dart:ui';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import '../domain/models.dart';

// Conditional import for web-specific functionality
import 'export_service_web.dart' if (dart.library.io) 'export_service_mobile.dart' as platform;

class ExportService {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat _fileNameFormat = DateFormat('yyyyMMdd_HHmmss');

  // Export result model
  static const String _exportsSubfolder = 'exports';

  // Export single calculation with robust error handling
  static Future<ExportResult> exportSingleCalculation({
    required CalculationHistory calculation,
    required String format, // 'CSV' or 'XLSX'
    String? calculatorKey,
  }) async {
    return exportCalculations(
      calculations: [calculation],
      format: format,
      calculatorKey: calculatorKey ?? calculation.formulaId,
    );
  }



  // Export multiple calculations with robust error handling
  static Future<ExportResult> exportCalculations({
    required List<CalculationHistory> calculations,
    required String format,
    String? calculatorKey,
  }) async {
    if (calculations.isEmpty) {
      return ExportResult.error('No calculations to export');
    }

    try {
      // Generate file name with proper pattern
      final timestamp = _fileNameFormat.format(DateTime.now());
      final key = calculatorKey ?? 'calculator';
      final extension = format.toLowerCase();
      final fileName = 'ipc_${key}_$timestamp.$extension';

      if (kIsWeb) {
        // Web platform - direct download
        return await _exportForWeb(calculations, fileName, format);
      } else {
        // Mobile/Desktop platform - use file system
        return await _exportForMobile(calculations, fileName, format);
      }

    } catch (e, stackTrace) {
      debugPrint('Export error: $e');
      debugPrint('Stack trace: $stackTrace');
      return ExportResult.error('Export failed: ${e.toString()}');
    }
  }

  // Export for web platform (direct download + web share API if available)
  static Future<ExportResult> _exportForWeb(
    List<CalculationHistory> calculations,
    String fileName,
    String format,
  ) async {
    try {
      List<int> bytes;
      String mimeType;

      if (format.toUpperCase() == 'CSV') {
        final csvData = _generateCSVData(calculations);
        final csvString = const ListToCsvConverter().convert(csvData);
        bytes = utf8.encode(csvString);
        mimeType = 'text/csv';
      } else if (format.toUpperCase() == 'XLSX') {
        final excel = _generateExcelData(calculations);
        final excelBytes = excel.encode();
        if (excelBytes == null) {
          return ExportResult.error('Failed to generate Excel file');
        }
        bytes = excelBytes;
        mimeType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      } else {
        return ExportResult.error('Unsupported format: $format');
      }

      // Try Web Share API first (if supported and available)
      if (await platform.PlatformExportService.tryNativeShare(bytes, fileName, mimeType)) {
        return ExportResult.success(
          filePath: 'web_share',
          fileName: fileName,
          fileSize: bytes.length,
          format: format.toUpperCase(),
        );
      } else {
        // Fallback to direct download
        platform.PlatformExportService.downloadFile(bytes, fileName, mimeType);
        return ExportResult.success(
          filePath: 'web_download',
          fileName: fileName,
          fileSize: bytes.length,
          format: format.toUpperCase(),
        );
      }
    } catch (e) {
      return ExportResult.error('Web export failed: ${e.toString()}');
    }
  }



  // Export for mobile/desktop platform
  static Future<ExportResult> _exportForMobile(
    List<CalculationHistory> calculations,
    String fileName,
    String format,
  ) async {
    try {
      // Get app documents directory for persistent storage
      final appDocDir = await getApplicationDocumentsDirectory();
      final exportsDir = Directory('${appDocDir.path}/$_exportsSubfolder');

      // Ensure exports directory exists
      if (!await exportsDir.exists()) {
        await exportsDir.create(recursive: true);
      }

      final file = File('${exportsDir.path}/$fileName');

      // Export based on format
      if (format.toUpperCase() == 'CSV') {
        await _exportToCSV(calculations, file);
      } else if (format.toUpperCase() == 'XLSX') {
        await _exportToXLSX(calculations, file);
      } else {
        return ExportResult.error('Unsupported format: $format');
      }

      // Verify file was created
      if (!await file.exists()) {
        return ExportResult.error('File creation failed');
      }

      final fileSize = await file.length();

      // Share the file immediately using native share sheet
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'IPC Calculator Export - $fileName',
        subject: 'Calculator Results Export',
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
      );

      return ExportResult.success(
        filePath: file.path,
        fileName: fileName,
        fileSize: fileSize,
        format: format.toUpperCase(),
      );
    } catch (e) {
      return ExportResult.error('Mobile export failed: ${e.toString()}');
    }
  }



  // Generate CSV data (shared between web and mobile)
  static List<List<String>> _generateCSVData(List<CalculationHistory> calculations) {
    final List<List<String>> csvData = [];

    // Headers - exact order as specified
    final headers = [
      'date',
      'patient name',
      'ID',
      'MRN',
      'location',
    ];

    // Add input column headers (sorted for consistency)
    final Set<String> allInputKeys = {};
    for (final calc in calculations) {
      allInputKeys.addAll(calc.inputs.keys);
    }
    final sortedInputKeys = allInputKeys.toList()..sort();
    headers.addAll(sortedInputKeys);

    // Add result column
    headers.add('result (with unit)');

    csvData.add(headers);

    // Data rows with professional formatting
    for (final calc in calculations) {
      final row = <String>[
        _dateFormat.format(calc.timestamp),
        '', // patient name - empty for manual entry
        '', // ID - empty for manual entry
        '', // MRN - empty for manual entry
        '', // location - empty for manual entry
      ];

      // Add input values with proper formatting
      for (final inputKey in sortedInputKeys) {
        final value = calc.inputs[inputKey];
        if (value is num) {
          row.add(_formatNumber(value));
        } else {
          row.add(value?.toString() ?? '');
        }
      }

      // Add result with unit (properly formatted)
      row.add('${_formatNumber(calc.result)} ${calc.unit}');

      csvData.add(row);
    }

    return csvData;
  }

  // Export to CSV with professional formatting (mobile only)
  static Future<void> _exportToCSV(
    List<CalculationHistory> calculations,
    File file,
  ) async {
    final csvData = _generateCSVData(calculations);
    final csvString = const ListToCsvConverter().convert(csvData);
    await file.writeAsString(csvString, encoding: utf8);
  }

  // Generate Excel data (shared between web and mobile)
  static Excel _generateExcelData(List<CalculationHistory> calculations) {
    // Create Excel workbook
    final excel = Excel.createExcel();
    final sheet = excel['IPC Calculator Export'];

    // Headers - exact order as specified
    final headers = [
      'date',
      'patient name',
      'ID',
      'MRN',
      'location',
    ];

    // Add input column headers (sorted for consistency)
    final Set<String> allInputKeys = {};
    for (final calc in calculations) {
      allInputKeys.addAll(calc.inputs.keys);
    }
    final sortedInputKeys = allInputKeys.toList()..sort();
    headers.addAll(sortedInputKeys);

    // Add result column
    headers.add('result (with unit)');

    // Write headers with formatting
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        fontSize: 12,
      );
    }

    // Write data rows with proper formatting
    for (int rowIndex = 0; rowIndex < calculations.length; rowIndex++) {
      final calc = calculations[rowIndex];
      int colIndex = 0;

      // Date
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex++, rowIndex: rowIndex + 1))
          .value = TextCellValue(_dateFormat.format(calc.timestamp));

      // Empty fields for manual entry
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex++, rowIndex: rowIndex + 1))
          .value = TextCellValue(''); // patient name
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex++, rowIndex: rowIndex + 1))
          .value = TextCellValue(''); // ID
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex++, rowIndex: rowIndex + 1))
          .value = TextCellValue(''); // MRN
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex++, rowIndex: rowIndex + 1))
          .value = TextCellValue(''); // location

      // Input values with proper formatting
      for (final inputKey in sortedInputKeys) {
        final value = calc.inputs[inputKey];
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex++, rowIndex: rowIndex + 1));
        if (value is num) {
          cell.value = TextCellValue(_formatNumber(value));
        } else {
          cell.value = TextCellValue(value?.toString() ?? '');
        }
      }

      // Result with unit (properly formatted)
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: colIndex++, rowIndex: rowIndex + 1))
          .value = TextCellValue('${_formatNumber(calc.result)} ${calc.unit}');
    }

    return excel;
  }

  // Export to XLSX with professional formatting (mobile only)
  static Future<void> _exportToXLSX(
    List<CalculationHistory> calculations,
    File file,
  ) async {
    final excel = _generateExcelData(calculations);
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    } else {
      throw Exception('Failed to encode Excel file');
    }
  }

  // Get list of exported files from the exports directory
  static Future<List<ExportedFile>> getExportedFiles() async {
    if (kIsWeb) {
      // Web platform doesn't have persistent file storage
      // Return empty list for now - could implement localStorage tracking later
      return [];
    }

    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final exportsDir = Directory('${appDocDir.path}/$_exportsSubfolder');

      if (!await exportsDir.exists()) {
        return [];
      }

      final files = await exportsDir.list().where((entity) => entity is File).cast<File>().toList();
      final exportedFiles = <ExportedFile>[];

      for (final file in files) {
        final stat = await file.stat();
        final fileName = file.path.split('/').last;
        final extension = fileName.split('.').last.toUpperCase();

        exportedFiles.add(ExportedFile(
          fileName: fileName,
          filePath: file.path,
          fileSize: stat.size,
          format: extension,
          timestamp: stat.modified,
        ));
      }

      // Sort by timestamp (newest first)
      exportedFiles.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return exportedFiles;

    } catch (e) {
      debugPrint('Error getting exported files: $e');
      return [];
    }
  }

  // Delete an exported file
  static Future<bool> deleteExportedFile(String filePath) async {
    if (kIsWeb) {
      // Web platform doesn't have persistent file storage
      return false;
    }

    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  // Share an existing exported file
  static Future<void> shareExportedFile(String filePath) async {
    if (kIsWeb) {
      // Web platform doesn't support re-sharing files
      throw Exception('Re-sharing not supported on web platform');
    }

    try {
      final file = File(filePath);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'IPC Calculator Export',
          sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
        );
      }
    } catch (e) {
      debugPrint('Error sharing file: $e');
      throw Exception('Failed to share file');
    }
  }

  // Check if native sharing is supported
  static bool get supportsNativeSharing {
    return platform.PlatformExportService.supportsNativeSharing;
  }

  // Get sharing capability description for user
  static String get sharingCapabilityDescription {
    return platform.PlatformExportService.sharingCapabilityDescription;
  }

  // Format numbers for display
  static String _formatNumber(num value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    } else {
      return value.toStringAsFixed(2);
    }
  }

  // Get export preview data
  static List<Map<String, String>> getExportPreview(List<CalculationHistory> calculations) {
    if (calculations.isEmpty) return [];

    final List<Map<String, String>> preview = [];

    // Get all unique input keys
    final Set<String> allInputKeys = {};
    for (final calc in calculations) {
      allInputKeys.addAll(calc.inputs.keys);
    }

    for (final calc in calculations) {
      final Map<String, String> row = {
        'date': _dateFormat.format(calc.timestamp),
        'formula': calc.formulaName,
        'domain': calc.domain,
        'result': '${_formatNumber(calc.result)} ${calc.unit}',
      };

      // Add input values
      for (final inputKey in allInputKeys) {
        final value = calc.inputs[inputKey];
        if (value is num) {
          row[inputKey] = _formatNumber(value);
        } else {
          row[inputKey] = value?.toString() ?? '';
        }
      }

      preview.add(row);
    }

    return preview;
  }
}

// Export result model
class ExportResult {
  final bool success;
  final String? filePath;
  final String? fileName;
  final int? fileSize;
  final String? format;
  final String? errorMessage;

  const ExportResult._({
    required this.success,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.format,
    this.errorMessage,
  });

  factory ExportResult.success({
    required String filePath,
    required String fileName,
    required int fileSize,
    required String format,
  }) {
    return ExportResult._(
      success: true,
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      format: format,
    );
  }

  factory ExportResult.error(String message) {
    return ExportResult._(
      success: false,
      errorMessage: message,
    );
  }
}

// Exported file model
class ExportedFile {
  final String fileName;
  final String filePath;
  final int fileSize;
  final String format;
  final DateTime timestamp;

  const ExportedFile({
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.format,
    required this.timestamp,
  });

  String get formattedSize {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
