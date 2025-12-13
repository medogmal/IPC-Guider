import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart' as excel_pkg;
import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as img;
import '../design/design_tokens.dart';

/// Unified export service for all IPC Guider tools
/// Provides consistent export functionality across calculators, visualization tools, and documentation tools
///
/// Follows EXPORT_STANDARDS.md for consistent branding, formatting, and content structure
class UnifiedExportService {
  // App metadata constants
  static const String appVersion = '0.2.0';
  static const String appName = 'IPC Guider';
  static const String appTagline = 'Infection Prevention & Control Professional Tool';

  // Logo cache
  static Uint8List? _cachedLogoBytes;
  static img.Image? _cachedLogoImage;

  /// Load app logo as bytes (cached for performance)
  static Future<Uint8List> _loadLogoBytes() async {
    if (_cachedLogoBytes != null) return _cachedLogoBytes!;

    final ByteData data = await rootBundle.load('assets/icons/ipc_icon.png');
    _cachedLogoBytes = data.buffer.asUint8List();
    return _cachedLogoBytes!;
  }

  /// Load app logo as image object (cached for performance)
  static Future<img.Image> _loadLogoImage() async {
    if (_cachedLogoImage != null) return _cachedLogoImage!;

    final bytes = await _loadLogoBytes();
    _cachedLogoImage = img.decodeImage(bytes);
    if (_cachedLogoImage == null) {
      throw Exception('Failed to decode logo image');
    }
    return _cachedLogoImage!;
  }

  /// Add watermark to screenshot (logo + timestamp)
  /// Returns watermarked image as PNG bytes
  static Future<Uint8List> addWatermarkToScreenshot({
    required Uint8List screenshotBytes,
    String? customText,
  }) async {
    try {
      // Decode screenshot
      final screenshot = img.decodeImage(screenshotBytes);
      if (screenshot == null) {
        throw Exception('Failed to decode screenshot');
      }

      // Load and resize logo to 16x16
      final logo = await _loadLogoImage();
      final smallLogo = img.copyResize(logo, width: 16, height: 16);

      // Calculate watermark position (bottom-right corner with 10px padding)
      final logoX = screenshot.width - smallLogo.width - 10;
      final logoY = screenshot.height - smallLogo.height - 10;

      // Composite logo onto screenshot with 80% opacity
      img.compositeImage(
        screenshot,
        smallLogo,
        dstX: logoX,
        dstY: logoY,
        blend: img.BlendMode.alpha,
      );

      // Add timestamp text next to logo
      final timestamp = DateTime.now().toString().split('.')[0];
      final watermarkText = customText ?? '$appName | $timestamp';

      // Draw text (positioned to the left of logo)
      final textX = logoX - 200;
      final textY = logoY + 2;

      img.drawString(
        screenshot,
        watermarkText,
        font: img.arial14,
        x: textX,
        y: textY,
        color: img.ColorRgb8(100, 100, 100), // Gray color
      );

      // Encode back to PNG
      return Uint8List.fromList(img.encodePng(screenshot));
    } catch (e) {
      // If watermarking fails, return original screenshot
      debugPrint('Watermark failed: $e');
      return screenshotBytes;
    }
  }
  /// Export data as CSV file (proper file, not text)
  /// Automatically adds metadata header per EXPORT_STANDARDS.md
  static Future<bool> exportAsCSV({
    required BuildContext context,
    required String filename,
    required String csvContent,
    String? shareText,
    String? toolName,
    String? facilityName,
  }) async {
    try {
      // Add metadata header per EXPORT_STANDARDS.md
      final timestamp = DateTime.now().toString().split('.')[0];
      final metadataHeader = StringBuffer();
      metadataHeader.writeln('# $appName - ${toolName ?? filename}');
      metadataHeader.writeln('# $appTagline');
      metadataHeader.writeln('# Generated: $timestamp');
      metadataHeader.writeln('# App Version: $appVersion');
      if (facilityName != null && facilityName.isNotEmpty) {
        metadataHeader.writeln('# Facility: $facilityName');
      }
      metadataHeader.writeln('#');

      // Combine metadata header with CSV content
      final fullContent = metadataHeader.toString() + csvContent;

      // Convert CSV string to bytes (UTF-8 with BOM for Excel compatibility)
      final bytes = utf8.encode('\uFEFF$fullContent'); // BOM for UTF-8

      // Create XFile with proper MIME type
      final file = XFile.fromData(
        Uint8List.fromList(bytes),
        name: '$filename.csv',
        mimeType: 'text/csv',
      );

      // Share the file
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : const Rect.fromLTWH(0, 0, 1, 1);
      await Share.shareXFiles(
        [file],
        text: shareText ?? '$appName Export - $filename',
        sharePositionOrigin: origin,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text('CSV exported successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Export failed: ${e.toString()}'),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return false;
    }
  }

  /// Export calculator results as PDF
  /// Enhanced with logo, app version, optional chart embedding per EXPORT_STANDARDS.md
  static Future<bool> exportCalculatorAsPDF({
    required BuildContext context,
    required String toolName,
    required Map<String, dynamic> inputs,
    required Map<String, dynamic> results,
    String? interpretation,
    List<String>? references,
    String? formula,
    Map<String, dynamic>? benchmark,
    String? recommendations,
    Uint8List? chartImage,        // NEW: Optional chart to embed
    String? facilityName,          // NEW: Optional facility context
    String? unitName,              // NEW: Optional unit/department
    String? generatedBy,           // NEW: Optional user name
    Map<String, dynamic>? statisticalAnalysis, // NEW: CI, p-values, etc.
  }) async {
    try {
      final pdf = pw.Document();
      final timestamp = DateTime.now();

      // Load logo for header
      final logoBytes = await _loadLogoBytes();
      final logoImage = pw.MemoryImage(logoBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context pdfContext) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Enhanced Header with Logo per EXPORT_STANDARDS.md
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#4A90A4'), // Brand color
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Logo (24x24 per standards)
                      pw.Image(logoImage, width: 24, height: 24),
                      pw.SizedBox(width: 12),
                      // Header text
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              appName.toUpperCase(),
                              style: pw.TextStyle(
                                fontSize: 14,
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              appTagline,
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Container(
                              height: 1,
                              color: PdfColor.fromInt(0x4DFFFFFF), // White with 30% opacity
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              toolName,
                              style: pw.TextStyle(
                                fontSize: 20,
                                color: PdfColors.white,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              'Generated: ${_formatDateTime(timestamp)}',
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.white,
                              ),
                            ),
                            pw.Text(
                              'App Version: $appVersion',
                              style: const pw.TextStyle(
                                fontSize: 9,
                                color: PdfColors.white,
                              ),
                            ),
                            if (facilityName != null && facilityName.isNotEmpty) ...[
                              pw.Text(
                                'Facility: $facilityName',
                                style: const pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColors.white,
                                ),
                              ),
                            ],
                            if (unitName != null && unitName.isNotEmpty) ...[
                              pw.Text(
                                'Unit/Department: $unitName',
                                style: const pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColors.white,
                                ),
                              ),
                            ],
                            if (generatedBy != null && generatedBy.isNotEmpty) ...[
                              pw.Text(
                                'Generated By: $generatedBy',
                                style: const pw.TextStyle(
                                  fontSize: 9,
                                  color: PdfColors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 24),

                // Formula Section (if provided)
                if (formula != null) ...[
                  pw.Text(
                    'FORMULA',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1a2332'),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#FFF3E0'),
                      border: pw.Border.all(color: PdfColor.fromHex('#FF9800')),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      formula,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#E65100'),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 24),
                ],

                // Input Values Section
                pw.Text(
                  'INPUT VALUES',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#1a2332'),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColor.fromHex('#e0e0e0')),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: inputs.entries.map((entry) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 4),
                        child: pw.Row(
                          children: [
                            pw.Container(
                              width: 6,
                              height: 6,
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex('#2196F3'),
                                shape: pw.BoxShape.circle,
                              ),
                            ),
                            pw.SizedBox(width: 8),
                            pw.Text(
                              '${entry.key}: ',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Text('${entry.value}'),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                
                pw.SizedBox(height: 24),
                
                // Results Section
                pw.Text(
                  'RESULTS',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#1a2332'),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('#e3f2fd'),
                    border: pw.Border.all(color: PdfColor.fromHex('#2196F3')),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: results.entries.map((entry) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 4),
                        child: pw.Row(
                          children: [
                            pw.Container(
                              width: 6,
                              height: 6,
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex('#4CAF50'),
                                shape: pw.BoxShape.circle,
                              ),
                            ),
                            pw.SizedBox(width: 8),
                            pw.Text(
                              '${entry.key}: ',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Text('${entry.value}'),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

                // Statistical Analysis Section (if provided) - NEW per EXPORT_STANDARDS.md
                if (statisticalAnalysis != null && statisticalAnalysis.isNotEmpty) ...[
                  pw.SizedBox(height: 24),
                  pw.Text(
                    'STATISTICAL ANALYSIS',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1a2332'),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F3E5F5'),
                      border: pw.Border.all(color: PdfColor.fromHex('#9C27B0')),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: statisticalAnalysis.entries.map((entry) {
                        return pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 4),
                          child: pw.Row(
                            children: [
                              pw.Container(
                                width: 6,
                                height: 6,
                                decoration: pw.BoxDecoration(
                                  color: PdfColor.fromHex('#9C27B0'),
                                  shape: pw.BoxShape.circle,
                                ),
                              ),
                              pw.SizedBox(width: 8),
                              pw.Text(
                                '${entry.key}: ',
                                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                              ),
                              pw.Text('${entry.value}'),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                // Benchmark Comparison Section (if provided)
                if (benchmark != null) ...[
                  pw.SizedBox(height: 24),
                  pw.Text(
                    'BENCHMARK COMPARISON',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1a2332'),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: _getBenchmarkBackgroundColor(benchmark['status']),
                      border: pw.Border.all(
                        color: _getBenchmarkBorderColor(benchmark['status']),
                        width: 2,
                      ),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Text(
                              'Target: ',
                              style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                            pw.Text(
                              '${benchmark['target']} ${benchmark['unit'] ?? ''}',
                              style: const pw.TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                        if (benchmark['source'] != null) ...[
                          pw.SizedBox(height: 4),
                          pw.Row(
                            children: [
                              pw.Text(
                                'Source: ',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.Text(
                                '${benchmark['source']}',
                                style: const pw.TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                        pw.SizedBox(height: 8),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: pw.BoxDecoration(
                            color: _getBenchmarkStatusColor(benchmark['status']),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(
                            'Status: ${benchmark['status']}',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Recommendations Section (if provided)
                if (recommendations != null) ...[
                  pw.SizedBox(height: 24),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#FFF9C4'),
                      border: pw.Border.all(
                        color: PdfColor.fromHex('#FBC02D'),
                        width: 2,
                      ),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Container(
                              width: 20,
                              height: 20,
                              decoration: pw.BoxDecoration(
                                color: PdfColor.fromHex('#F57C00'),
                                shape: pw.BoxShape.circle,
                              ),
                              child: pw.Center(
                                child: pw.Text(
                                  '!',
                                  style: pw.TextStyle(
                                    fontSize: 14,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.white,
                                  ),
                                ),
                              ),
                            ),
                            pw.SizedBox(width: 8),
                            pw.Text(
                              'RECOMMENDED ACTIONS',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex('#E65100'),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          recommendations,
                          style: const pw.TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],

                // Interpretation Section (if provided)
                if (interpretation != null) ...[
                  pw.SizedBox(height: 24),
                  pw.Text(
                    'CLINICAL INTERPRETATION',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1a2332'),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColor.fromHex('#e0e0e0')),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      interpretation,
                      style: const pw.TextStyle(fontSize: 11),
                    ),
                  ),
                ],

                // References Section (if provided)
                if (references != null && references.isNotEmpty) ...[
                  pw.SizedBox(height: 24),
                  pw.Text(
                    'REFERENCES',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1a2332'),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  ...references.map((ref) => pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 12, bottom: 4),
                    child: pw.Text(
                      '• $ref',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  )),
                ],

                pw.Spacer(),

                // Enhanced Footer per EXPORT_STANDARDS.md
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Generated by $appName v$appVersion',
                      style: pw.TextStyle(
                        fontSize: 8,
                        color: PdfColor.fromHex('#757575'),
                      ),
                    ),
                    pw.Text(
                      'Page 1',
                      style: pw.TextStyle(
                        fontSize: 8,
                        color: PdfColor.fromHex('#757575'),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  appTagline,
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: PdfColor.fromHex('#757575'),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Add chart page if provided (NEW per EXPORT_STANDARDS.md)
      if (chartImage != null) {
        final chart = pw.MemoryImage(chartImage);
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(20),
            build: (pw.Context pdfContext) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Chart page header
                  pw.Text(
                    'VISUAL ANALYSIS',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#1a2332'),
                    ),
                  ),
                  pw.SizedBox(height: 16),

                  // Chart image (centered and scaled to fit)
                  pw.Expanded(
                    child: pw.Center(
                      child: pw.Image(
                        chart,
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 16),

                  // Footer
                  pw.Divider(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Generated by $appName v$appVersion',
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColor.fromHex('#757575'),
                        ),
                      ),
                      pw.Text(
                        'Page 2',
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: PdfColor.fromHex('#757575'),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      }

      // Save and share PDF
      final bytes = await pdf.save();
      final filename = '${toolName.replaceAll(' ', '_').toLowerCase()}_${timestamp.millisecondsSinceEpoch}';
      
      final file = XFile.fromData(
        bytes,
        name: '$filename.pdf',
        mimeType: 'application/pdf',
      );
      
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : const Rect.fromLTWH(0, 0, 1, 1);
      await Share.shareXFiles(
        [file],
        text: 'IPC Guider - $toolName Results',
        sharePositionOrigin: origin,
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text('PDF exported successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF export failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
  }

  /// Export calculator results as Excel
  /// Enhanced with colored header, app version, optional context per EXPORT_STANDARDS.md
  static Future<bool> exportCalculatorAsExcel({
    required BuildContext context,
    required String toolName,
    required Map<String, dynamic> inputs,
    required Map<String, dynamic> results,
    String? interpretation,
    String? formula,
    Map<String, dynamic>? benchmark,
    String? recommendations,
    String? facilityName,          // NEW: Optional facility context
    String? unitName,              // NEW: Optional unit/department
    Map<String, dynamic>? statisticalAnalysis, // NEW: CI, p-values, etc.
  }) async {
    try {
      final excel = excel_pkg.Excel.createExcel();
      final timestamp = DateTime.now();

      // Remove default sheet
      excel.delete('Sheet1');

      // Create Results sheet
      final sheet = excel['Results'];

      // Enhanced Header per EXPORT_STANDARDS.md
      // Row 1: App name and tool name (colored header)
      final headerCell = sheet.cell(excel_pkg.CellIndex.indexByString('A1'));
      headerCell.value = excel_pkg.TextCellValue('$appName - $toolName');
      headerCell.cellStyle = excel_pkg.CellStyle(
        backgroundColorHex: excel_pkg.ExcelColor.fromInt(0xFF4A90A4), // Brand color
        fontColorHex: excel_pkg.ExcelColor.white,
        bold: true,
        fontSize: 14,
      );

      // Merge cells for header (A1:D1)
      sheet.merge(excel_pkg.CellIndex.indexByString('A1'), excel_pkg.CellIndex.indexByString('D1'));

      // Row 2: Tagline
      final taglineCell = sheet.cell(excel_pkg.CellIndex.indexByString('A2'));
      taglineCell.value = excel_pkg.TextCellValue(appTagline);
      taglineCell.cellStyle = excel_pkg.CellStyle(
        backgroundColorHex: excel_pkg.ExcelColor.fromInt(0xFF4A90A4),
        fontColorHex: excel_pkg.ExcelColor.white,
        fontSize: 10,
      );
      sheet.merge(excel_pkg.CellIndex.indexByString('A2'), excel_pkg.CellIndex.indexByString('D2'));

      // Row 3: Metadata
      sheet.appendRow([excel_pkg.TextCellValue('Generated: ${_formatDateTime(timestamp)}')]);
      sheet.appendRow([excel_pkg.TextCellValue('App Version: $appVersion')]);
      if (facilityName != null && facilityName.isNotEmpty) {
        sheet.appendRow([excel_pkg.TextCellValue('Facility: $facilityName')]);
      }
      if (unitName != null && unitName.isNotEmpty) {
        sheet.appendRow([excel_pkg.TextCellValue('Unit/Department: $unitName')]);
      }
      sheet.appendRow([excel_pkg.TextCellValue('')]);

      // Formula section
      if (formula != null) {
        sheet.appendRow([excel_pkg.TextCellValue('FORMULA')]);
        sheet.appendRow([excel_pkg.TextCellValue(formula)]);
        sheet.appendRow([excel_pkg.TextCellValue('')]);
      }

      // Input section
      sheet.appendRow([excel_pkg.TextCellValue('INPUT VALUES')]);
      for (final entry in inputs.entries) {
        sheet.appendRow([
          excel_pkg.TextCellValue(entry.key),
          excel_pkg.TextCellValue(entry.value.toString()),
        ]);
      }
      sheet.appendRow([excel_pkg.TextCellValue('')]);

      // Results section
      sheet.appendRow([excel_pkg.TextCellValue('RESULTS')]);
      for (final entry in results.entries) {
        sheet.appendRow([
          excel_pkg.TextCellValue(entry.key),
          excel_pkg.TextCellValue(entry.value.toString()),
        ]);
      }

      // Benchmark section
      if (benchmark != null) {
        sheet.appendRow([excel_pkg.TextCellValue('')]);
        sheet.appendRow([excel_pkg.TextCellValue('BENCHMARK COMPARISON')]);
        sheet.appendRow([
          excel_pkg.TextCellValue('Target'),
          excel_pkg.TextCellValue('${benchmark['target']} ${benchmark['unit'] ?? ''}'),
        ]);
        if (benchmark['source'] != null) {
          sheet.appendRow([
            excel_pkg.TextCellValue('Source'),
            excel_pkg.TextCellValue('${benchmark['source']}'),
          ]);
        }
        sheet.appendRow([
          excel_pkg.TextCellValue('Status'),
          excel_pkg.TextCellValue('${benchmark['status']}'),
        ]);
      }

      // Statistical Analysis section (NEW per EXPORT_STANDARDS.md)
      if (statisticalAnalysis != null && statisticalAnalysis.isNotEmpty) {
        sheet.appendRow([excel_pkg.TextCellValue('')]);
        sheet.appendRow([excel_pkg.TextCellValue('STATISTICAL ANALYSIS')]);
        for (final entry in statisticalAnalysis.entries) {
          sheet.appendRow([
            excel_pkg.TextCellValue(entry.key),
            excel_pkg.TextCellValue(entry.value.toString()),
          ]);
        }
      }

      // Recommendations section
      if (recommendations != null) {
        sheet.appendRow([excel_pkg.TextCellValue('')]);
        sheet.appendRow([excel_pkg.TextCellValue('RECOMMENDED ACTIONS')]);
        sheet.appendRow([excel_pkg.TextCellValue(recommendations)]);
      }

      // Interpretation section
      if (interpretation != null) {
        sheet.appendRow([excel_pkg.TextCellValue('')]);
        sheet.appendRow([excel_pkg.TextCellValue('CLINICAL INTERPRETATION')]);
        sheet.appendRow([excel_pkg.TextCellValue(interpretation)]);
      }

      // Save and share
      final bytes = excel.encode();
      if (bytes == null) throw Exception('Failed to encode Excel file');

      final filename = '${toolName.replaceAll(' ', '_').toLowerCase()}_${timestamp.millisecondsSinceEpoch}';

      final file = XFile.fromData(
        Uint8List.fromList(bytes),
        name: '$filename.xlsx',
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );

      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : const Rect.fromLTWH(0, 0, 1, 1);
      await Share.shareXFiles(
        [file],
        text: 'IPC Guider - $toolName Results',
        sharePositionOrigin: origin,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text('Excel exported successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel export failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
  }

  /// Export visualization data as Excel with chart data
  static Future<bool> exportVisualizationAsExcel({
    required BuildContext context,
    required String toolName,
    required List<String> headers,
    required List<List<dynamic>> data,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final excel = excel_pkg.Excel.createExcel();
      final timestamp = DateTime.now();

      // Remove default sheet
      excel.delete('Sheet1');

      // Create Data sheet
      final sheet = excel['Data'];

      // Metadata section
      if (metadata != null) {
        sheet.appendRow([excel_pkg.TextCellValue('METADATA')]);
        for (final entry in metadata.entries) {
          sheet.appendRow([
            excel_pkg.TextCellValue(entry.key),
            excel_pkg.TextCellValue(entry.value.toString()),
          ]);
        }
        sheet.appendRow([excel_pkg.TextCellValue('')]);
      }

      // Data section
      sheet.appendRow([excel_pkg.TextCellValue('DATA')]);
      sheet.appendRow(headers.map((h) => excel_pkg.TextCellValue(h)).toList());

      for (final row in data) {
        sheet.appendRow(row.map((cell) => excel_pkg.TextCellValue(cell.toString())).toList());
      }

      // Save and share
      final bytes = excel.encode();
      if (bytes == null) throw Exception('Failed to encode Excel file');

      final filename = '${toolName.replaceAll(' ', '_').toLowerCase()}_${timestamp.millisecondsSinceEpoch}';

      final file = XFile.fromData(
        Uint8List.fromList(bytes),
        name: '$filename.xlsx',
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      );

      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : const Rect.fromLTWH(0, 0, 1, 1);
      await Share.shareXFiles(
        [file],
        text: 'IPC Guider - $toolName Data',
        sharePositionOrigin: origin,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text('Excel exported successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel export failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
  }

  /// Helper: Format DateTime for display
  static String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
           '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Export calculator results as CSV
  static Future<bool> exportCalculatorAsCSV({
    required BuildContext context,
    required String toolName,
    required Map<String, dynamic> inputs,
    required Map<String, dynamic> results,
    String? interpretation,
    String? formula,
    Map<String, dynamic>? benchmark,
    String? recommendations,
  }) async {
    try {
      final timestamp = DateTime.now();
      final csvContent = StringBuffer();

      // Header
      csvContent.writeln('IPC Guider - $toolName');
      csvContent.writeln('Generated: ${_formatDateTime(timestamp)}');
      csvContent.writeln('');

      // Formula section
      if (formula != null) {
        csvContent.writeln('FORMULA');
        csvContent.writeln('"$formula"');
        csvContent.writeln('');
      }

      // Inputs section
      csvContent.writeln('INPUTS');
      csvContent.writeln('Parameter,Value');
      for (final entry in inputs.entries) {
        csvContent.writeln('${entry.key},${entry.value}');
      }
      csvContent.writeln('');

      // Results section
      csvContent.writeln('RESULTS');
      csvContent.writeln('Metric,Value');
      for (final entry in results.entries) {
        csvContent.writeln('${entry.key},${entry.value}');
      }
      csvContent.writeln('');

      // Benchmark section
      if (benchmark != null) {
        csvContent.writeln('BENCHMARK COMPARISON');
        csvContent.writeln('Metric,Value');
        csvContent.writeln('Target,"${benchmark['target']} ${benchmark['unit'] ?? ''}"');
        if (benchmark['source'] != null) {
          csvContent.writeln('Source,${benchmark['source']}');
        }
        csvContent.writeln('Status,${benchmark['status']}');
        csvContent.writeln('');
      }

      // Recommendations section
      if (recommendations != null) {
        csvContent.writeln('RECOMMENDED ACTIONS');
        csvContent.writeln('"$recommendations"');
        csvContent.writeln('');
      }

      // Interpretation section
      if (interpretation != null) {
        csvContent.writeln('INTERPRETATION');
        csvContent.writeln('"$interpretation"');
      }

      final filename = '${toolName.replaceAll(' ', '_').toLowerCase()}_${timestamp.millisecondsSinceEpoch}';

      return await exportAsCSV(
        context: context,
        filename: filename,
        csvContent: csvContent.toString(),
        shareText: 'IPC Guider - $toolName Results',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('CSV export failed: ${e.toString()}'),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return false;
    }
  }

  /// Export calculator results as plain text
  static Future<bool> exportCalculatorAsText({
    required BuildContext context,
    required String toolName,
    required Map<String, dynamic> inputs,
    required Map<String, dynamic> results,
    String? interpretation,
    List<String>? references,
    String? formula,
    Map<String, dynamic>? benchmark,
    String? recommendations,
  }) async {
    try {
      final timestamp = DateTime.now();
      final textContent = StringBuffer();

      // Enhanced Header per EXPORT_STANDARDS.md
      textContent.writeln('═══════════════════════════════════════════════════════════');
      textContent.writeln('$appName - $toolName'.toUpperCase());
      textContent.writeln(appTagline);
      textContent.writeln('═══════════════════════════════════════════════════════════');
      textContent.writeln('Generated: ${_formatDateTime(timestamp)}');
      textContent.writeln('App Version: $appVersion');
      textContent.writeln('═══════════════════════════════════════════════════════════');
      textContent.writeln('');

      // Formula section
      if (formula != null) {
        textContent.writeln('───────────────────────────────────────');
        textContent.writeln('FORMULA');
        textContent.writeln('───────────────────────────────────────');
        textContent.writeln(formula);
        textContent.writeln('');
      }

      // Inputs section
      textContent.writeln('───────────────────────────────────────');
      textContent.writeln('INPUTS');
      textContent.writeln('───────────────────────────────────────');
      for (final entry in inputs.entries) {
        textContent.writeln('${entry.key}: ${entry.value}');
      }
      textContent.writeln('');

      // Results section
      textContent.writeln('───────────────────────────────────────');
      textContent.writeln('RESULTS');
      textContent.writeln('───────────────────────────────────────');
      for (final entry in results.entries) {
        textContent.writeln('${entry.key}: ${entry.value}');
      }
      textContent.writeln('');

      // Benchmark section
      if (benchmark != null) {
        textContent.writeln('───────────────────────────────────────');
        textContent.writeln('BENCHMARK COMPARISON');
        textContent.writeln('───────────────────────────────────────');
        textContent.writeln('Target: ${benchmark['target']} ${benchmark['unit'] ?? ''}');
        if (benchmark['source'] != null) {
          textContent.writeln('Source: ${benchmark['source']}');
        }
        textContent.writeln('Status: ${benchmark['status']}');
        textContent.writeln('');
      }

      // Recommendations section
      if (recommendations != null) {
        textContent.writeln('───────────────────────────────────────');
        textContent.writeln('RECOMMENDED ACTIONS');
        textContent.writeln('───────────────────────────────────────');
        textContent.writeln(recommendations);
        textContent.writeln('');
      }

      // Interpretation section
      if (interpretation != null) {
        textContent.writeln('───────────────────────────────────────');
        textContent.writeln('INTERPRETATION');
        textContent.writeln('───────────────────────────────────────');
        textContent.writeln(interpretation);
        textContent.writeln('');
      }

      // References section
      if (references != null && references.isNotEmpty) {
        textContent.writeln('───────────────────────────────────────');
        textContent.writeln('REFERENCES');
        textContent.writeln('───────────────────────────────────────');
        for (int i = 0; i < references.length; i += 2) {
          if (i + 1 < references.length) {
            textContent.writeln('${i ~/ 2 + 1}. ${references[i]}');
            textContent.writeln('   ${references[i + 1]}');
          }
        }
        textContent.writeln('');
      }

      // Enhanced Footer per EXPORT_STANDARDS.md
      textContent.writeln('═══════════════════════════════════════════════════════════');
      textContent.writeln('Generated by $appName v$appVersion');
      textContent.writeln(appTagline);
      textContent.writeln('═══════════════════════════════════════════════════════════');

      // Convert to bytes
      final bytes = utf8.encode(textContent.toString());
      final filename = '${toolName.replaceAll(' ', '_').toLowerCase()}_${timestamp.millisecondsSinceEpoch}';

      // Create XFile
      final file = XFile.fromData(
        Uint8List.fromList(bytes),
        name: '$filename.txt',
        mimeType: 'text/plain',
      );

      // Share the file
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null ? (box.localToGlobal(Offset.zero) & box.size) : const Rect.fromLTWH(0, 0, 1, 1);
      await Share.shareXFiles(
        [file],
        text: 'IPC Guider - $toolName Results',
        sharePositionOrigin: origin,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text('Text file exported successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Text export failed: ${e.toString()}'),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return false;
    }
  }

  /// Helper function to get benchmark background color based on status
  static PdfColor _getBenchmarkBackgroundColor(String? status) {
    if (status == null) return PdfColor.fromHex('#F5F5F5');

    final statusLower = status.toLowerCase();
    if (statusLower.contains('meet') || statusLower.contains('below') || statusLower.contains('acceptable')) {
      return PdfColor.fromHex('#E8F5E9'); // Light green
    } else if (statusLower.contains('above') || statusLower.contains('exceed') || statusLower.contains('high')) {
      return PdfColor.fromHex('#FFEBEE'); // Light red
    } else if (statusLower.contains('close') || statusLower.contains('near')) {
      return PdfColor.fromHex('#FFF9C4'); // Light yellow
    }
    return PdfColor.fromHex('#F5F5F5'); // Default gray
  }

  /// Helper function to get benchmark border color based on status
  static PdfColor _getBenchmarkBorderColor(String? status) {
    if (status == null) return PdfColor.fromHex('#E0E0E0');

    final statusLower = status.toLowerCase();
    if (statusLower.contains('meet') || statusLower.contains('below') || statusLower.contains('acceptable')) {
      return PdfColor.fromHex('#4CAF50'); // Green
    } else if (statusLower.contains('above') || statusLower.contains('exceed') || statusLower.contains('high')) {
      return PdfColor.fromHex('#F44336'); // Red
    } else if (statusLower.contains('close') || statusLower.contains('near')) {
      return PdfColor.fromHex('#FBC02D'); // Yellow
    }
    return PdfColor.fromHex('#E0E0E0'); // Default gray
  }

  /// Helper function to get benchmark status badge color
  static PdfColor _getBenchmarkStatusColor(String? status) {
    if (status == null) return PdfColor.fromHex('#757575');

    final statusLower = status.toLowerCase();
    if (statusLower.contains('meet') || statusLower.contains('below') || statusLower.contains('acceptable')) {
      return PdfColor.fromHex('#4CAF50'); // Green
    } else if (statusLower.contains('above') || statusLower.contains('exceed') || statusLower.contains('high')) {
      return PdfColor.fromHex('#F44336'); // Red
    } else if (statusLower.contains('close') || statusLower.contains('near')) {
      return PdfColor.fromHex('#FF9800'); // Orange
    }
    return PdfColor.fromHex('#757575'); // Default gray
  }
}

