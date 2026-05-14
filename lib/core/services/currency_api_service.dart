import 'package:dio/dio.dart';
import 'package:unit_converter_pro/core/constants/app_constants.dart';

class CurrencyApiService {
  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 8),
  ));

  /// Returns a map of currency code → rate relative to USD.
  Future<Map<String, double>> fetchRates() async {
    final url = '${AppConstants.currencyApiBase}/USD';
    final response = await _dio.get<Map<String, dynamic>>(url);
    final data = response.data;
    if (data == null || data['result'] != 'success') {
      throw Exception('Currency API error');
    }
    final raw = data['rates'] as Map<String, dynamic>;
    return raw.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }
}
