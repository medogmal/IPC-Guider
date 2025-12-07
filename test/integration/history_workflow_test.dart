import 'package:flutter_test/flutter_test.dart';
import 'package:ipc_guider/features/outbreak/data/models/history_entry.dart';
import 'package:ipc_guider/features/outbreak/data/repositories/history_repository.dart';
import 'package:ipc_guider/features/outbreak/data/services/history_export_service.dart';

/// Integration test for the complete history workflow:
/// 1. Save operation from calculator/outbreak tool
/// 2. Entry appears in unified history
/// 3. Bulk selection of entries
/// 4. Export selected entries
void main() {
  group('History Workflow Integration Tests', () {
    late HistoryRepository repository;

    setUp(() async {
      repository = HistoryRepository();
      await repository.initialize();
      // Clear any existing entries
      final allEntries = repository.getAllEntries();
      for (final entry in allEntries) {
        await repository.deleteEntry(entry.id);
      }
    });

    tearDown(() async {
      // Clean up
      final allEntries = repository.getAllEntries();
      for (final entry in allEntries) {
        await repository.deleteEntry(entry.id);
      }
    });

    test('Step 1: Save calculator result to unified history', () async {
      // Simulate saving from CLABSI Calculator
      final entry = HistoryEntry.fromCalculator(
        calculatorName: 'CLABSI Rate Calculator',
        inputs: {
          'CLABSI Cases': '5',
          'Central Line Days': '1000',
        },
        result: 'Rate: 5.00 per 1,000 central line days',
        notes: 'Test entry',
        tags: ['hai', 'clabsi', 'surveillance', 'infection-rate'],
      );

      await repository.addEntry(entry);

      // Verify entry was saved
      final allEntries = repository.getAllEntries();
      expect(allEntries.length, 1);
      expect(allEntries.first.title, 'CLABSI Rate Calculator');
      expect(allEntries.first.toolType, 'Calculator');
    });

    test('Step 2: Multiple tools save to unified history', () async {
      // Save from multiple calculators
      final clabsiEntry = HistoryEntry.fromCalculator(
        calculatorName: 'CLABSI Rate Calculator',
        inputs: {'CLABSI Cases': '5', 'Central Line Days': '1000'},
        result: 'Rate: 5.00 per 1,000 central line days',
        notes: '',
        tags: ['hai', 'clabsi', 'surveillance', 'infection-rate'],
      );

      final cautiEntry = HistoryEntry.fromCalculator(
        calculatorName: 'CAUTI Rate Calculator',
        inputs: {'CAUTI Cases': '3', 'Urinary Catheter Days': '800'},
        result: 'Rate: 3.75 per 1,000 urinary catheter days',
        notes: '',
        tags: ['hai', 'cauti', 'surveillance', 'infection-rate'],
      );

      final ssiEntry = HistoryEntry.fromCalculator(
        calculatorName: 'SSI Rate Calculator',
        inputs: {'SSI Cases': '2', 'Total Procedures': '100'},
        result: 'Rate: 2.00%',
        notes: '',
        tags: ['hai', 'ssi', 'surveillance', 'infection-rate'],
      );

      await repository.addEntry(clabsiEntry);
      await repository.addEntry(cautiEntry);
      await repository.addEntry(ssiEntry);

      // Verify all entries are in unified history
      final allEntries = repository.getAllEntries();
      expect(allEntries.length, 3);
      
      // Verify entries are sorted by timestamp (newest first)
      expect(allEntries[0].title, 'SSI Rate Calculator');
      expect(allEntries[1].title, 'CAUTI Rate Calculator');
      expect(allEntries[2].title, 'CLABSI Rate Calculator');
    });

    test('Step 3: Bulk selection of entries', () async {
      // Add 10 entries
      for (int i = 0; i < 10; i++) {
        final entry = HistoryEntry.fromCalculator(
          calculatorName: 'Test Calculator $i',
          inputs: {'Input': '$i'},
          result: 'Result: $i',
          notes: '',
          tags: ['test'],
        );
        await repository.addEntry(entry);
      }

      final allEntries = repository.getAllEntries();
      expect(allEntries.length, 10);

      // Simulate bulk selection (select first 5 entries)
      final selectedIds = allEntries.take(5).map((e) => e.id).toSet();
      expect(selectedIds.length, 5);

      // Verify selected entries can be retrieved
      final selectedEntries = allEntries
          .where((entry) => selectedIds.contains(entry.id))
          .toList();
      expect(selectedEntries.length, 5);
    });

    test('Step 4: Export selected entries to CSV', () async {
      // Add test entries
      final entries = [
        HistoryEntry.fromCalculator(
          calculatorName: 'CLABSI Rate Calculator',
          inputs: {'CLABSI Cases': '5', 'Central Line Days': '1000'},
          result: 'Rate: 5.00 per 1,000 central line days',
          notes: 'Q1 2024',
          tags: ['hai', 'clabsi'],
        ),
        HistoryEntry.fromCalculator(
          calculatorName: 'CAUTI Rate Calculator',
          inputs: {'CAUTI Cases': '3', 'Urinary Catheter Days': '800'},
          result: 'Rate: 3.75 per 1,000 urinary catheter days',
          notes: 'Q1 2024',
          tags: ['hai', 'cauti'],
        ),
      ];

      for (final entry in entries) {
        await repository.addEntry(entry);
      }

      // Export to CSV
      final csvData = await HistoryExportService.exportToCsv(entries);
      expect(csvData.isNotEmpty, true);

      // Verify CSV contains expected data
      final csvString = String.fromCharCodes(csvData);
      expect(csvString.contains('CLABSI Rate Calculator'), true);
      expect(csvString.contains('CAUTI Rate Calculator'), true);
      expect(csvString.contains('Date'), true);
      expect(csvString.contains('Tool Type'), true);
    });

    test('Step 5: Export selected entries to Excel', () async {
      // Add test entries
      final entries = [
        HistoryEntry.fromCalculator(
          calculatorName: 'DDD Calculator',
          inputs: {'Antibiotic': 'Ceftriaxone', 'Total Grams': '1000'},
          result: 'DDD: 500',
          notes: '',
          tags: ['antimicrobial-stewardship', 'ddd'],
        ),
        HistoryEntry.fromCalculator(
          calculatorName: 'Bundle Compliance Calculator',
          inputs: {'Compliant': '95', 'Total': '100'},
          result: 'Compliance: 95.00%',
          notes: '',
          tags: ['ipc', 'compliance'],
        ),
      ];

      for (final entry in entries) {
        await repository.addEntry(entry);
      }

      // Export to Excel
      final excelData = await HistoryExportService.exportToExcel(entries);
      expect(excelData.isNotEmpty, true);
      expect(excelData.length > 100, true); // Excel files are larger
    });

    test('Step 6: Complete workflow - Save, Select, Export', () async {
      // Step 1: Save entries from different tools
      final calculatorEntry = HistoryEntry.fromCalculator(
        calculatorName: 'CLABSI Rate Calculator',
        inputs: {'CLABSI Cases': '5', 'Central Line Days': '1000'},
        result: 'Rate: 5.00 per 1,000 central line days',
        notes: '',
        tags: ['hai', 'clabsi', 'surveillance', 'infection-rate'],
      );

      final outbreakEntry = HistoryEntry.fromOutbreakTool(
        toolName: 'Attack Rate Calculator',
        inputs: {'Cases': '10', 'Population': '100'},
        result: 'Attack Rate: 10.00%',
        notes: '',
        tags: ['outbreak', 'attack-rate', 'epidemiology'],
      );

      await repository.addEntry(calculatorEntry);
      await repository.addEntry(outbreakEntry);

      // Step 2: Verify entries in unified history
      final allEntries = repository.getAllEntries();
      expect(allEntries.length, 2);

      // Step 3: Select all entries
      final selectedIds = allEntries.map((e) => e.id).toSet();
      expect(selectedIds.length, 2);

      // Step 4: Export selected entries
      final selectedEntries = allEntries
          .where((entry) => selectedIds.contains(entry.id))
          .toList();

      final csvData = await HistoryExportService.exportToCsv(selectedEntries);
      expect(csvData.isNotEmpty, true);

      final csvString = String.fromCharCodes(csvData);
      expect(csvString.contains('CLABSI Rate Calculator'), true);
      expect(csvString.contains('Attack Rate Calculator'), true);
      expect(csvString.contains('Calculator'), true);
      expect(csvString.contains('Outbreak Tool'), true);
    });

    test('Step 7: Export statistics calculation', () async {
      // Add diverse entries
      final entries = [
        HistoryEntry.fromCalculator(
          calculatorName: 'CLABSI Rate Calculator',
          inputs: {'CLABSI Cases': '5', 'Central Line Days': '1000'},
          result: 'Rate: 5.00',
          notes: '',
          tags: ['hai', 'clabsi'],
        ),
        HistoryEntry.fromCalculator(
          calculatorName: 'CAUTI Rate Calculator',
          inputs: {'CAUTI Cases': '3', 'Urinary Catheter Days': '800'},
          result: 'Rate: 3.75',
          notes: '',
          tags: ['hai', 'cauti'],
        ),
        HistoryEntry.fromOutbreakTool(
          toolName: 'Attack Rate Calculator',
          inputs: {'Cases': '10', 'Population': '100'},
          result: 'Attack Rate: 10.00%',
          notes: '',
          tags: ['outbreak'],
        ),
      ];

      for (final entry in entries) {
        await repository.addEntry(entry);
      }

      // Get export statistics
      final stats = HistoryExportService.getExportStatistics(entries);
      
      expect(stats['totalEntries'], 3);
      expect(stats['toolTypes'], isA<Map<String, int>>());
      expect((stats['toolTypes'] as Map)['Calculator'], 2);
      expect((stats['toolTypes'] as Map)['Outbreak Tool'], 1);
      expect(stats['estimatedSize'], isNotNull);
    });

    test('Step 8: Bulk delete after export', () async {
      // Add entries
      for (int i = 0; i < 5; i++) {
        final entry = HistoryEntry.fromCalculator(
          calculatorName: 'Test Calculator $i',
          inputs: {'Input': '$i'},
          result: 'Result: $i',
          notes: '',
          tags: ['test'],
        );
        await repository.addEntry(entry);
      }

      var allEntries = repository.getAllEntries();
      expect(allEntries.length, 5);

      // Select and delete first 3 entries
      final selectedIds = allEntries.take(3).map((e) => e.id).toList();
      for (final id in selectedIds) {
        await repository.deleteEntry(id);
      }

      // Verify deletion
      allEntries = repository.getAllEntries();
      expect(allEntries.length, 2);
    });
  });
}

