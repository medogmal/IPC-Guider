import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../isolation/domain/organism_precaution.dart';

class IsolationRepo {
  static const _assetPath = 'assets/data/isolation_organisms.v1.json';

  Future<List<OrganismPrecaution>> loadAll() async {
    final raw = await rootBundle.loadString(_assetPath);
    final jsonMap = json.decode(raw) as Map<String, dynamic>;
    final list = (jsonMap['organisms'] as List).cast<Map<String, dynamic>>();
    return list.map((m) => OrganismPrecaution.fromMap(m)).toList();
    // ملاحظة: لاحقًا يمكن حفظ نسخة في Hive للعرض السريع أو التحديث
  }

  List<OrganismPrecaution> filterByType(
    List<OrganismPrecaution> items,
    String? type, // Airborne / Droplet / Contact / Contact-Enteric / Protective
  ) {
    if (type == null || type.isEmpty) return items;
    return items.where((o) => o.isolationTypes.contains(type)).toList();
  }

  List<OrganismPrecaution> search(
    List<OrganismPrecaution> items,
    String query,
  ) {
    if (query.trim().isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((o) {
      final hay = ('${o.organism} ${o.synonyms.join(' ')}').toLowerCase();
      return hay.contains(q);
    }).toList();
  }
}
