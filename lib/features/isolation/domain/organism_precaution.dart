class RefLink {
  final String label;
  final String url; // may be empty
  const RefLink({required this.label, this.url = ''});

  static RefLink fromAny(dynamic v) {
    if (v is Map) {
      final label = v['label']?.toString() ?? '';
      final url = v['url']?.toString() ?? '';
      return RefLink(label: label, url: url);
    }
    final s = v?.toString() ?? '';
    return RefLink(label: s, url: '');
  }
}

class OrganismPrecaution {
  final String id;
  final String organism;
  final List<String> synonyms;
  final List<String> isolationTypes;
  final List<String> ppe;
  final String durationText;
  final String discontinueNotes;
  final List<RefLink> references;         // ← changed to RefLink
  final String specialConsiderations;

  OrganismPrecaution({
    required this.id,
    required this.organism,
    required this.synonyms,
    required this.isolationTypes,
    required this.ppe,
    required this.durationText,
    required this.discontinueNotes,
    required this.references,
    this.specialConsiderations = '',
  });

  factory OrganismPrecaution.fromMap(Map<String, dynamic> map) {
    List<String> listStr(dynamic v) =>
        (v is List ? v.map((e) => e.toString()).toList() : <String>[]);
    String str(dynamic v) => v?.toString() ?? '';
    List<RefLink> listRef(dynamic v) =>
        (v is List ? v.map((e) => RefLink.fromAny(e)).toList() : <RefLink>[]);

    return OrganismPrecaution(
      id: str(map['id']),
      organism: str(map['organism']),
      synonyms: listStr(map['synonyms']),
      isolationTypes: listStr(map['isolationTypes']),
      ppe: listStr(map['ppe']),
      durationText: str(map['durationText']),
      discontinueNotes: str(map['discontinueNotes']),
      references: listRef(map['references']),
      specialConsiderations: str(map['specialConsiderations']),
    );
  }
}
