import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  static const calcHistory = 'calc_history';
  static const bundleRecords = 'bundle_records';
  static const auditRecords = 'audit_records';
  static const outbreakNotes = 'outbreak_notes';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(calcHistory);
    await Hive.openBox(bundleRecords);
    await Hive.openBox(auditRecords);
    await Hive.openBox(outbreakNotes);
  }
}
