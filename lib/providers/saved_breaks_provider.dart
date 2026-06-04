import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import '../api/models/saved_break.dart';
import '../core/storage_keys.dart';

class SavedBreaksNotifier extends Notifier<List<SavedBreak>> {
  @override
  List<SavedBreak> build() => _load();

  List<SavedBreak> _load() {
    try {
      if (!storageReady) return [];
      final raw = GetStorage().read<String>(StorageKeys.savedBreaks);
      if (raw == null) return [];
      final list = (jsonDecode(raw) as List)
          .map((e) => SavedBreak.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } catch (_) {
      return [];
    }
  }

  void _persist() {
    try {
      if (!storageReady) return;
      GetStorage().write(
        StorageKeys.savedBreaks,
        jsonEncode(state.map((e) => e.toJson()).toList()),
      );
    } catch (_) {/* no-op in tests */}
  }

  void add(SavedBreak b) {
    if (state.any((x) => x.id == b.id)) return;
    state = [...state, b];
    _persist();
  }

  void remove(String id) {
    state = state.where((x) => x.id != id).toList();
    _persist();
  }
}

final savedBreaksProvider =
    NotifierProvider<SavedBreaksNotifier, List<SavedBreak>>(
        SavedBreaksNotifier.new);
