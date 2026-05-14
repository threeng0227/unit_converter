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
