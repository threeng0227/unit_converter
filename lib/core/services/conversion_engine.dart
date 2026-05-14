import 'package:unit_converter_pro/core/constants/converter_categories.dart';

abstract class ConversionEngine {
  static double convert({
    required ConverterCategory category,
    required String fromUnit,
    required String toUnit,
    required double value,
    Map<String, double>? currencyRates,
  }) {
    if (fromUnit == toUnit) return value;
    return switch (category) {
      ConverterCategory.length => _length(fromUnit, toUnit, value),
      ConverterCategory.weight => _weight(fromUnit, toUnit, value),
      ConverterCategory.temperature => _temperature(fromUnit, toUnit, value),
      ConverterCategory.area => _area(fromUnit, toUnit, value),
      ConverterCategory.speed => _speed(fromUnit, toUnit, value),
      ConverterCategory.currency => _currency(fromUnit, toUnit, value, currencyRates ?? {}),
      ConverterCategory.dataStorage => _dataStorage(fromUnit, toUnit, value),
    };
  }

  // ── Length (base: meter) ──────────────────────────────────────────────────
  static const _lengthToMeter = <String, double>{
    'Millimeter': 0.001,
    'Centimeter': 0.01,
    'Meter': 1.0,
    'Kilometer': 1000.0,
    'Inch': 0.0254,
    'Foot': 0.3048,
    'Yard': 0.9144,
    'Mile': 1609.344,
    'Nautical Mile': 1852.0,
  };

  static double _length(String from, String to, double v) =>
      v * _lengthToMeter[from]! / _lengthToMeter[to]!;

  // ── Weight (base: kilogram) ───────────────────────────────────────────────
  static const _weightToKg = <String, double>{
    'Milligram': 0.000001,
    'Gram': 0.001,
    'Kilogram': 1.0,
    'Metric Ton': 1000.0,
    'Ounce': 0.0283495,
    'Pound': 0.453592,
    'Stone': 6.35029,
    'US Ton': 907.185,
    'Imperial Ton': 1016.05,
  };

  static double _weight(String from, String to, double v) =>
      v * _weightToKg[from]! / _weightToKg[to]!;

  // ── Temperature (special formulas) ───────────────────────────────────────
  static double _temperature(String from, String to, double v) {
    final celsius = switch (from) {
      'Celsius' => v,
      'Fahrenheit' => (v - 32) * 5 / 9,
      'Kelvin' => v - 273.15,
      'Rankine' => (v - 491.67) * 5 / 9,
      _ => v,
    };
    return switch (to) {
      'Celsius' => celsius,
      'Fahrenheit' => celsius * 9 / 5 + 32,
      'Kelvin' => celsius + 273.15,
      'Rankine' => (celsius + 273.15) * 9 / 5,
      _ => celsius,
    };
  }

  // ── Area (base: m²) ───────────────────────────────────────────────────────
  static const _areaToM2 = <String, double>{
    'Square Millimeter': 0.000001,
    'Square Centimeter': 0.0001,
    'Square Meter': 1.0,
    'Square Kilometer': 1e6,
    'Hectare': 10000.0,
    'Square Inch': 0.00064516,
    'Square Foot': 0.092903,
    'Square Yard': 0.836127,
    'Acre': 4046.86,
    'Square Mile': 2.59e6,
  };

  static double _area(String from, String to, double v) =>
      v * _areaToM2[from]! / _areaToM2[to]!;

  // ── Speed (base: m/s) ─────────────────────────────────────────────────────
  static const _speedToMs = <String, double>{
    'Meter/second': 1.0,
    'Kilometer/hour': 0.277778,
    'Mile/hour': 0.44704,
    'Foot/second': 0.3048,
    'Knot': 0.514444,
    'Mach': 343.0,
  };

  static double _speed(String from, String to, double v) =>
      v * _speedToMs[from]! / _speedToMs[to]!;

  // ── Currency (live rates, base: USD) ──────────────────────────────────────
  static double _currency(String from, String to, double v, Map<String, double> rates) {
    if (rates.isEmpty) return v;
    final fromRate = rates[from] ?? 1.0;
    final toRate = rates[to] ?? 1.0;
    return v / fromRate * toRate;
  }

  // ── Data Storage (base: byte) ─────────────────────────────────────────────
  static const _storageToByte = <String, double>{
    'Bit': 0.125,
    'Byte': 1.0,
    'Kilobyte': 1024.0,
    'Megabyte': 1048576.0,
    'Gigabyte': 1073741824.0,
    'Terabyte': 1099511627776.0,
    'Petabyte': 1.1259e15,
    'Kibibyte': 1024.0,
    'Mebibyte': 1048576.0,
    'Gibibyte': 1073741824.0,
  };

  static double _dataStorage(String from, String to, double v) =>
      v * _storageToByte[from]! / _storageToByte[to]!;

  // ── Unit symbols ─────────────────────────────────────────────────────────
  static const _symbols = <String, String>{
    // Length
    'Millimeter': 'mm', 'Centimeter': 'cm', 'Meter': 'm',
    'Kilometer': 'km', 'Inch': 'in', 'Foot': 'ft',
    'Yard': 'yd', 'Mile': 'mi', 'Nautical Mile': 'nmi',
    // Weight
    'Milligram': 'mg', 'Gram': 'g', 'Kilogram': 'kg',
    'Metric Ton': 't', 'Ounce': 'oz', 'Pound': 'lb', 'Stone': 'st',
    // Temperature
    'Celsius': '°C', 'Fahrenheit': '°F', 'Kelvin': 'K', 'Rankine': '°R',
    // Area
    'Square Millimeter': 'mm²', 'Square Centimeter': 'cm²',
    'Square Meter': 'm²', 'Square Kilometer': 'km²',
    'Hectare': 'ha', 'Square Inch': 'in²', 'Square Foot': 'ft²',
    'Square Yard': 'yd²', 'Acre': 'ac', 'Square Mile': 'mi²',
    // Speed
    'Meter/second': 'm/s', 'Kilometer/hour': 'km/h',
    'Mile/hour': 'mph', 'Foot/second': 'ft/s', 'Knot': 'kn', 'Mach': 'Ma',
    // Data
    'Bit': 'b', 'Byte': 'B', 'Kilobyte': 'KB', 'Megabyte': 'MB',
    'Gigabyte': 'GB', 'Terabyte': 'TB', 'Petabyte': 'PB',
    'Kibibyte': 'KiB', 'Mebibyte': 'MiB', 'Gibibyte': 'GiB',
    // Currency
    'USD': r'$', 'EUR': '€', 'GBP': '£', 'JPY': '¥', 'CNY': '¥',
    'VND': '₫', 'KRW': '₩', 'INR': '₹', 'THB': '฿', 'RUB': '₽',
    'TRY': '₺', 'BRL': 'R\$', 'MXN': 'MX\$', 'IDR': 'Rp',
    'MYR': 'RM', 'SGD': 'S\$', 'HKD': 'HK\$', 'AUD': 'A\$',
    'CAD': 'CA\$', 'CHF': 'Fr', 'SEK': 'kr', 'NOK': 'kr',
    'DKK': 'kr', 'NZD': 'NZ\$', 'ZAR': 'R', 'AED': 'د.إ',
    'SAR': '﷼', 'EGP': 'E£', 'NGN': '₦', 'PKR': '₨',
    'BDT': '৳', 'TWD': 'NT\$', 'CZK': 'Kč', 'PLN': 'zł',
    'HUF': 'Ft', 'ILS': '₪', 'CLP': 'CL\$', 'PHP': '₱',
    'COP': 'CO\$', 'ARS': 'AR\$',
  };

  static const _namesVi = <String, String>{
    // Length
    'Millimeter': 'Milimét', 'Centimeter': 'Centimét', 'Meter': 'Mét',
    'Kilometer': 'Kilômét', 'Inch': 'Inch', 'Foot': 'Feet',
    'Yard': 'Yard', 'Mile': 'Dặm', 'Nautical Mile': 'Hải lý',
    // Weight
    'Milligram': 'Miligam', 'Gram': 'Gam', 'Kilogram': 'Kilôgam',
    'Metric Ton': 'Tấn', 'Ounce': 'Ounce', 'Pound': 'Pound',
    'Stone': 'Stone', 'US Ton': 'Tấn Mỹ', 'Imperial Ton': 'Tấn Anh',
    // Temperature
    'Celsius': 'Độ C', 'Fahrenheit': 'Độ F',
    'Kelvin': 'Kelvin', 'Rankine': 'Rankine',
    // Area
    'Square Millimeter': 'Milimét vuông', 'Square Centimeter': 'Centimét vuông',
    'Square Meter': 'Mét vuông', 'Square Kilometer': 'Kilômét vuông',
    'Hectare': 'Héc ta', 'Square Inch': 'Inch vuông',
    'Square Foot': 'Feet vuông', 'Square Yard': 'Yard vuông',
    'Acre': 'Mẫu Anh', 'Square Mile': 'Dặm vuông',
    // Speed
    'Meter/second': 'Mét/giây', 'Kilometer/hour': 'Kilômét/giờ',
    'Mile/hour': 'Dặm/giờ', 'Foot/second': 'Feet/giây',
    'Knot': 'Hải lý/giờ', 'Mach': 'Mach',
    // Data
    'Bit': 'Bit', 'Byte': 'Byte', 'Kilobyte': 'Kilobyte',
    'Megabyte': 'Megabyte', 'Gigabyte': 'Gigabyte',
    'Terabyte': 'Terabyte', 'Petabyte': 'Petabyte',
    'Kibibyte': 'Kibibyte', 'Mebibyte': 'Mebibyte', 'Gibibyte': 'Gibibyte',
  };

  static String localizedName(String unit, String langCode) =>
      langCode == 'vi' ? (_namesVi[unit] ?? unit) : unit;

  static String symbolFor(String unit) {
    final s = _symbols[unit];
    return s != null ? ' ($s)' : '';
  }

  static String displayName(String unit) => '$unit${symbolFor(unit)}';

  // ── Unit lists per category ───────────────────────────────────────────────
  static List<String> unitsFor(ConverterCategory category) => switch (category) {
        ConverterCategory.length => _lengthToMeter.keys.toList(),
        ConverterCategory.weight => _weightToKg.keys.toList(),
        ConverterCategory.temperature => ['Celsius', 'Fahrenheit', 'Kelvin', 'Rankine'],
        ConverterCategory.area => _areaToM2.keys.toList(),
        ConverterCategory.speed => _speedToMs.keys.toList(),
        ConverterCategory.currency => [],
        ConverterCategory.dataStorage => _storageToByte.keys.toList(),
      };
}
