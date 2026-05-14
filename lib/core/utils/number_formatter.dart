import 'package:intl/intl.dart';

abstract class NumberFormatter {
  static final _fmt = NumberFormat('#,##0.##########');
  static final _compact = NumberFormat.compact();

  static String format(double value) {
    if (value.isNaN || value.isInfinite) return '—';
    if (value.abs() >= 1e13 || (value.abs() < 1e-6 && value != 0)) {
      return _compact.format(value);
    }
    return _fmt.format(value);
  }

  static String formatInput(String raw) => raw;
}
