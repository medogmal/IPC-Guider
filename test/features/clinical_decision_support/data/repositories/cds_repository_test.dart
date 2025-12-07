import 'package:flutter_test/flutter_test.dart';
import 'package:ipc_guider/features/clinical_decision_support/data/repositories/cds_repository.dart';

void main() {
  late CDSRepository repository;

  setUp(() {
    repository = CDSRepository();
  });

  group('CDSRepository', () {
    test('getAllCategories returns correct number of categories', () async {
      // getAllCategories is a Future in the repository definition I saw earlier? 
      // Wait, I saw `Future<List<CDSCategory>> getAllCategories() async` in the view_file output of cds_repository.dart
      // So I must await it.
      final categories = await repository.getAllCategories();
      expect(categories.length, 12);
    });

    test('getAllCategories returns categories with correct IDs', () async {
      final categories = await repository.getAllCategories();
      final ids = categories.map((c) => c.id).toList();
      
      expect(ids, contains('lower-respiratory'));
      expect(ids, contains('urinary-genitourinary'));
      expect(ids, contains('sexually-transmitted-infections'));
      expect(ids, contains('skin-soft-tissue'));
      expect(ids, contains('intra-abdominal-infections'));
      expect(ids, contains('bloodstream-infections'));
      expect(ids, contains('cns-infections'));
      expect(ids, contains('bone-joint-infections'));
      expect(ids, contains('eye-infections'));
      expect(ids, contains('immunocompromised-infections'));
      expect(ids, contains('travel-tropical-medicine'));
      expect(ids, contains('surgical-prophylaxis'));
    });

    test('getAllCategories returns categories with non-empty names and descriptions', () async {
      final categories = await repository.getAllCategories();
      for (var category in categories) {
        expect(category.name, isNotEmpty);
        expect(category.description, isNotEmpty);
        expect(category.icon, isNotNull);
        expect(category.color, isNotNull);
      }
    });
  });
}
