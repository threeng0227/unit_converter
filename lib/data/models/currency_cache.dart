import 'package:hive_flutter/hive_flutter.dart';
import 'package:unit_converter_pro/core/constants/app_constants.dart';

part 'currency_cache.g.dart';

@HiveType(typeId: HiveTypeIds.currencyCache)
class CurrencyCache extends HiveObject {
  @HiveField(0)
  final Map<String, double> rates;

  @HiveField(1)
  final DateTime fetchedAt;

  CurrencyCache({required this.rates, required this.fetchedAt});

  bool get isExpired {
    final age = DateTime.now().difference(fetchedAt);
    return age.inMinutes >= AppConstants.currencyCacheDurationMinutes;
  }
}
