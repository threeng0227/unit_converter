import 'package:hive_flutter/hive_flutter.dart';
import 'package:unit_converter_pro/core/constants/app_constants.dart';
import 'package:unit_converter_pro/core/services/currency_api_service.dart';
import 'package:unit_converter_pro/data/models/currency_cache.dart';

class CurrencyRepository {
  final _api = CurrencyApiService();

  Box<CurrencyCache> get _box =>
      Hive.box<CurrencyCache>(HiveBoxes.currencyRates);

  static const _cacheKey = 'latest';

  CurrencyCache? get _cached => _box.get(_cacheKey);

  /// Always fetch fresh from network.
  /// Falls back to cached data only when the network call fails.
  Future<Map<String, double>> getRates() async {
    try {
      final rates = await _api.fetchRates();
      await _box.put(
          _cacheKey, CurrencyCache(rates: rates, fetchedAt: DateTime.now()));
      return rates;
    } catch (_) {
      final cached = _cached;
      if (cached != null) return cached.rates;
      rethrow;
    }
  }

  /// Lightweight check: return cache if fresh (≤ 30 min old),
  /// otherwise fetch. Used for background auto-refresh.
  Future<Map<String, double>> getRatesCached() async {
    final cached = _cached;
    if (cached != null && !cached.isExpired) return cached.rates;
    return getRates();
  }

  List<String> get cachedCurrencies =>
      _cached?.rates.keys.toList() ?? [];

  DateTime? get lastUpdated => _cached?.fetchedAt;
}
