import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import '../api/api_client.dart';
import '../api/models/saved_break.dart';
import '../auth/auth_controller.dart';
import '../core/storage_keys.dart';
import 'api_provider.dart';

/// Local-first saved breaks. When the user is authenticated, changes are
/// pushed to the backend and the full set is merged (last-write-wins) on login.
/// When logged out it behaves as a purely on-device list (offline).
class SavedBreaksNotifier extends Notifier<List<SavedBreak>> {
  @override
  List<SavedBreak> build() => _load();

  ApiClient get _api => ref.read(apiClientProvider);

  bool get _authed =>
      ref.read(authControllerProvider).valueOrNull?.isAuthenticated ?? false;

  List<SavedBreak> _load() {
    try {
      if (!storageReady) return [];
      final raw = GetStorage().read<String>(StorageKeys.savedBreaks);
      if (raw == null) return [];
      return (jsonDecode(raw) as List)
          .map((e) => SavedBreak.fromJson(e as Map<String, dynamic>))
          .where((b) => b.deletedAt == null)
          .toList();
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

  Future<void> _push(List<SavedBreak> breaks) async {
    if (!_authed) return;
    try {
      await _api.syncSavedBreaks(breaks);
    } catch (_) {/* offline: stays local until next sync */}
  }

  void add(SavedBreak b) {
    if (state.any((x) => x.id == b.id)) return;
    final stamped =
        b.copyWith(updatedAt: DateTime.now().toUtc(), deletedAt: null);
    state = [...state, stamped];
    _persist();
    _push([stamped]);
  }

  void remove(String id) {
    final existing = state.where((x) => x.id == id).toList();
    state = state.where((x) => x.id != id).toList();
    _persist();
    if (existing.isNotEmpty) {
      // Push a tombstone so the deletion propagates to other devices.
      final now = DateTime.now().toUtc();
      _push([existing.first.copyWith(updatedAt: now, deletedAt: now)]);
    }
  }

  /// On login: push the local set, then adopt the server's authoritative set.
  Future<void> onLogin() async {
    try {
      final stamped = [
        for (final b in state)
          b.updatedAt == null
              ? b.copyWith(updatedAt: DateTime.now().toUtc())
              : b
      ];
      final merged = await _api.syncSavedBreaks(stamped);
      state = merged.where((b) => b.deletedAt == null).toList();
      _persist();
    } catch (_) {/* offline: keep local set */}
  }
}

final savedBreaksProvider =
    NotifierProvider<SavedBreaksNotifier, List<SavedBreak>>(
        SavedBreaksNotifier.new);
