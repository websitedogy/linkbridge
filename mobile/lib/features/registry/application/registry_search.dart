import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrySearchEntry {
  const RegistrySearchEntry({
    required this.query,
    required this.kind,
    required this.found,
  });

  final String query;
  final String kind;
  final bool found;
}

class RegistrySearchHistory extends Notifier<List<RegistrySearchEntry>> {
  @override
  List<RegistrySearchEntry> build() => const [];

  void add(RegistrySearchEntry entry) {
    final next = [
      entry,
      ...state.where(
        (item) => item.query != entry.query || item.kind != entry.kind,
      ),
    ];
    state = next.take(8).toList();
  }
}

final registrySearchHistoryProvider =
    NotifierProvider<RegistrySearchHistory, List<RegistrySearchEntry>>(
      RegistrySearchHistory.new,
    );

class SavedRegistry extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void toggle(String key) {
    final next = {...state};
    if (!next.add(key)) next.remove(key);
    state = next;
  }
}

final savedRegistryProvider = NotifierProvider<SavedRegistry, Set<String>>(
  SavedRegistry.new,
);
