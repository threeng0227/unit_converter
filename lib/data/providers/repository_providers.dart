import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unit_converter_pro/data/repositories/currency_repository.dart';
import 'package:unit_converter_pro/data/repositories/history_repository.dart';

final historyRepositoryProvider = Provider((_) => HistoryRepository());
final currencyRepositoryProvider = Provider((_) => CurrencyRepository());
