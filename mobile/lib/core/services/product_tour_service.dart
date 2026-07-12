import 'package:supabase_flutter/supabase_flutter.dart';
import 'tour_dismiss_store.dart';

class ProductTourService implements TourDismissStore {
  ProductTourService._internal();
  static final ProductTourService instance = ProductTourService._internal();
  static const _table = 'product_tour_dismissed';
  final SupabaseClient _client = Supabase.instance.client;
  Set<String>? _dismissedCache;
  Future<void>? _preloadFuture;
  String? get _userId => _client.auth.currentUser?.id;
  Future<void> preload() {
    if (_preloadFuture != null) return _preloadFuture!;
    _preloadFuture = _loadFromSupabase();
    return _preloadFuture!;
  }

  Future<void> _loadFromSupabase() async {
    final uid = _userId;
    if (uid == null) {
      _dismissedCache = {};
      return;
    }
    try {
      final rows =
          await _client.from(_table).select('tour_key').eq('user_id', uid);
      _dismissedCache = {
        for (final row in rows as List) row['tour_key'] as String,
      };
    } catch (_) {
      _dismissedCache ??= {};
    }
  }

  @override
  Future<bool> isDismissed(String tourKey) async {
    if (_dismissedCache == null) {
      await preload();
    }
    return _dismissedCache?.contains(tourKey) ?? false;
  }

  @override
  Future<void> markDismissed(String tourKey) async {
    _dismissedCache ??= {};
    _dismissedCache!.add(tourKey);

    final uid = _userId;
    if (uid == null) return;

    try {
      await _client.from(_table).upsert({
        'user_id': uid,
        'tour_key': tourKey,
        'dismissed_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {
    }
  }
  void reset() {
    _dismissedCache = null;
    _preloadFuture = null;
  }
}