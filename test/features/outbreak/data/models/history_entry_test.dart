import 'package:flutter_test/flutter_test.dart';
import 'package:ipc_guider/features/outbreak/data/models/history_entry.dart';

void main() {
  group('HistoryEntry', () {
    test('should create calculator entry with factory constructor', () {
      final entry = HistoryEntry.fromCalculator(
        calculatorName: 'Test Calculator',
        inputs: {'input1': 'value1', 'input2': 'value2'},
        result: 'Test Result',
        notes: 'Test Notes',
        tags: ['test', 'calculator'],
      );

      expect(entry.title, equals('Test Calculator'));
      expect(entry.toolType, equals('Calculator'));
      expect(entry.inputs, equals({'input1': 'value1', 'input2': 'value2'}));
      expect(entry.result, equals('Test Result'));
      expect(entry.notes, equals('Test Notes'));
      expect(entry.tags, equals(['test', 'calculator']));
    });

    test('should create checklist entry with factory constructor', () {
      final entry = HistoryEntry.fromChecklist(
        checklistName: 'Test Checklist',
        responses: {'item1': 'completed', 'item2': 'pending'},
        completionStatus: '50% Complete',
        notes: 'Test Notes',
        tags: ['test', 'checklist'],
      );

      expect(entry.title, equals('Test Checklist'));
      expect(entry.toolType, equals('Checklist'));
      expect(entry.inputs, equals({'item1': 'completed', 'item2': 'pending'}));
      expect(entry.result, equals('50% Complete'));
      expect(entry.notes, equals('Test Notes'));
      expect(entry.tags, equals(['test', 'checklist']));
    });

    test('should create case definition entry manually', () {
      final entry = HistoryEntry(
        timestamp: DateTime.now(),
        toolType: 'Case Definition',
        title: 'Test Case',
        inputs: {'clinical': 'fever, cough', 'epidemiological': 'exposure'},
        result: 'Suspected',
        notes: 'Test Notes',
        tags: ['test', 'case-definition'],
      );

      expect(entry.title, equals('Test Case'));
      expect(entry.toolType, equals('Case Definition'));
      expect(entry.inputs, equals({'clinical': 'fever, cough', 'epidemiological': 'exposure'}));
      expect(entry.result, equals('Suspected'));
      expect(entry.notes, equals('Test Notes'));
      expect(entry.tags, equals(['test', 'case-definition']));
    });

    test('should create chart entry with factory constructor', () {
      final entry = HistoryEntry.fromChart(
        chartType: 'histogram',
        parameters: {'variable': 'age', 'bins': '10'},
        summary: 'Generated histogram with 100 data points',
        notes: 'Test Notes',
        tags: ['test', 'chart'],
      );

      expect(entry.title, equals('histogram'));
      expect(entry.toolType, equals('Chart'));
      expect(entry.inputs, equals({'variable': 'age', 'bins': '10'}));
      expect(entry.result, equals('Generated histogram with 100 data points'));
      expect(entry.notes, equals('Test Notes'));
      expect(entry.tags, equals(['test', 'chart']));
    });

    test('should match search query in title', () {
      final entry = HistoryEntry.fromCalculator(
        calculatorName: 'Attack Rate Calculator',
        inputs: {},
        result: '',
      );

      expect(entry.matchesSearch('attack'), isTrue);
      expect(entry.matchesSearch('ATTACK'), isTrue);
      expect(entry.matchesSearch('rate'), isTrue);
      expect(entry.matchesSearch('xyz'), isFalse);
    });

    test('should match search query in result', () {
      final entry = HistoryEntry.fromCalculator(
        calculatorName: 'Test Calculator',
        inputs: {},
        result: '25.5% (95% CI: 20.1% - 30.9%)',
      );

      expect(entry.matchesSearch('25.5'), isTrue);
      expect(entry.matchesSearch('CI'), isTrue);
      expect(entry.matchesSearch('xyz'), isFalse);
    });

    test('should check if entry has tag', () {
      final entry = HistoryEntry.fromCalculator(
        calculatorName: 'Test Calculator',
        inputs: {},
        result: '',
        tags: ['epidemiology', 'attack-rate'],
      );

      expect(entry.hasTag('epidemiology'), isTrue);
      expect(entry.hasTag('attack-rate'), isTrue);
      expect(entry.hasTag('xyz'), isFalse);
    });

    test('should convert to JSON and back', () {
      final originalEntry = HistoryEntry.fromCalculator(
        calculatorName: 'Test Calculator',
        inputs: {'cases': '10', 'population': '100'},
        result: '10%',
        notes: 'Test notes',
        tags: ['test'],
      );

      final json = originalEntry.toJson();
      final recreatedEntry = HistoryEntry.fromJson(json);

      expect(recreatedEntry.id, equals(originalEntry.id));
      expect(recreatedEntry.title, equals(originalEntry.title));
      expect(recreatedEntry.toolType, equals(originalEntry.toolType));
      expect(recreatedEntry.inputs, equals(originalEntry.inputs));
      expect(recreatedEntry.notes, equals(originalEntry.notes));
      expect(recreatedEntry.tags, equals(originalEntry.tags));
      expect(recreatedEntry.timestamp, equals(originalEntry.timestamp));
    });
  });
}
