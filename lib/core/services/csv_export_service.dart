import 'dart:typed_data';
import 'dart:ui';
import 'package:share_plus/share_plus.dart';

class CsvExportService {
  static Future<void> exportSingleCalculation({
    required String calculatorName,
    required String formula,
    required Map<String, String> inputs,
    required double result,
    required String unit,
    required DateTime date,
  }) async {
    try {
      final csvContent = _generateSingleCalculationCsv(
        calculatorName, formula, inputs, result, unit, date
      );
      
      final filename = 'calculation_${calculatorName.replaceAll(' ', '_')}_${_formatDateForFilename(date)}.csv';
      
      await _shareCSV(csvContent, filename);
    } catch (e) {
      throw Exception('Failed to export CSV file: $e');
    }
  }

  static Future<void> exportMultipleCalculations(List<Map<String, dynamic>> calculations) async {
    try {
      final csvContent = _generateMultipleCalculationsCsv(calculations);
      final filename = 'calculation_history_${_formatDateForFilename(DateTime.now())}.csv';
      
      await _shareCSV(csvContent, filename);
    } catch (e) {
      throw Exception('Failed to export CSV file: $e');
    }
  }

  static String _generateSingleCalculationCsv(
    String calculatorName,
    String formula,
    Map<String, String> inputs,
    double result,
    String unit,
    DateTime date,
  ) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('IPC Calculator Results');
    buffer.writeln('');
    
    // Calculator info
    buffer.writeln('Calculator,"$calculatorName"');
    buffer.writeln('Formula,"${_escapeCsv(formula)}"');
    buffer.writeln('Date,"${_formatDate(date)}"');
    buffer.writeln('');
    
    // Input values
    buffer.writeln('Input Values');
    buffer.writeln('Parameter,Value');
    for (final entry in inputs.entries) {
      buffer.writeln('${_escapeCsv(entry.key)},${_escapeCsv(entry.value)}');
    }
    buffer.writeln('');
    
    // Result
    buffer.writeln('Result');
    buffer.writeln('Value,Unit');
    buffer.writeln('$result,$unit');
    
    return buffer.toString();
  }

  static String _generateMultipleCalculationsCsv(List<Map<String, dynamic>> calculations) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('IPC Calculator History');
    buffer.writeln('Total Calculations: ${calculations.length}');
    buffer.writeln('Export Date: ${_formatDate(DateTime.now())}');
    buffer.writeln('');
    
    // Column headers
    buffer.writeln('Date,Calculator,Formula,Inputs,Result,Unit');
    
    // Data rows
    for (final calc in calculations) {
      final date = DateTime.tryParse(calc['date'] ?? '') ?? DateTime.now();
      final calculatorName = calc['calculator'] ?? '';
      final formula = calc['formula_text'] ?? calc['formula'] ?? '';
      
      // Format inputs
      final inputs = calc['inputs'] as Map<String, dynamic>? ?? {};
      final inputsText = inputs.entries
          .map((e) => '${e.key}: ${e.value}')
          .join('; ');
      
      final result = calc['result']?.toString() ?? '';
      final unit = calc['unit'] ?? '';
      
      buffer.writeln(
        '${_formatDate(date)},${_escapeCsv(calculatorName)},${_escapeCsv(formula)},${_escapeCsv(inputsText)},$result,$unit'
      );
    }
    
    return buffer.toString();
  }

  static String _escapeCsv(String value) {
    // Escape quotes and wrap in quotes if contains comma, quote, or newline
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  static Future<void> _shareCSV(String csvContent, String filename) async {
    final bytes = Uint8List.fromList(csvContent.codeUnits);
    
    final xFile = XFile.fromData(
      bytes,
      name: filename,
      mimeType: 'text/csv',
    );
    
    await Share.shareXFiles(
      [xFile],
      text: 'IPC Calculator Results - $filename',
      subject: 'IPC Calculator Export',
      sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
           '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  static String _formatDateForFilename(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}_'
           '${date.hour.toString().padLeft(2, '0')}${date.minute.toString().padLeft(2, '0')}';
  }
}
