import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../isolation/domain/organism_precaution.dart';
import 'isolation_repo.dart';

final isolationRepoProvider = Provider<IsolationRepo>((ref) => IsolationRepo());

class IsolationFilterState {
  final String query;
  final String? type; // Airborne / Droplet / Contact / Contact-Enteric / null for All
  const IsolationFilterState({this.query = '', this.type});

  // Important: allow explicitly clearing "type" to null
  IsolationFilterState copyWith({String? query, String? type, bool setTypeNull = false}) {
    return IsolationFilterState(
      query: query ?? this.query,
      type: setTypeNull ? null : (type ?? this.type),
    );
  }
}

final isolationFilterProvider =
    StateProvider<IsolationFilterState>((ref) => const IsolationFilterState());

final isolationAllProvider = FutureProvider<List<OrganismPrecaution>>((ref) async {
  final repo = ref.watch(isolationRepoProvider);
  return repo.loadAll();
});

final isolationFilteredProvider = Provider<AsyncValue<List<OrganismPrecaution>>>((ref) {
  final all = ref.watch(isolationAllProvider);
  final filter = ref.watch(isolationFilterProvider);
  return all.whenData((items) {
    final repo = ref.read(isolationRepoProvider);
    var out = repo.filterByType(items, filter.type);
    out = repo.search(out, filter.query);
    out.sort((a, b) => a.organism.compareTo(b.organism));
    return out;
  });
});
