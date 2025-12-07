import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/outbreak_group.dart';
import '../../data/repositories/outbreak_group_repository.dart';

// Repository provider
final outbreakGroupRepositoryProvider = Provider<OutbreakGroupRepository>((ref) {
  return OutbreakGroupRepository();
});

// Index provider (loads main index)
final outbreakGroupsIndexProvider = FutureProvider<OutbreakGroupsIndex>((ref) async {
  final repository = ref.read(outbreakGroupRepositoryProvider);
  return repository.loadIndex();
});

// Group data provider (loads specific group data)
final groupDataProvider = FutureProvider.family<GroupData, String>((ref, dataFile) async {
  final repository = ref.read(outbreakGroupRepositoryProvider);
  return repository.loadGroupData(dataFile);
});

// Search provider (searches across all pathogens)
final pathogenSearchProvider = FutureProvider.family<List<PathogenSearchResult>, String>((ref, query) async {
  final repository = ref.read(outbreakGroupRepositoryProvider);
  return repository.searchPathogens(query);
});

