import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unit_converter_pro/core/constants/converter_categories.dart';
import 'package:unit_converter_pro/core/services/conversion_engine.dart';
import 'package:unit_converter_pro/data/models/history_entry.dart';
import 'package:unit_converter_pro/data/providers/repository_providers.dart';
import 'package:unit_converter_pro/features/history/history_provider.dart'
    show historyProvider;

final currencyRatesProvider = FutureProvider<Map<String, double>>((ref) async {
  // Always fetch fresh; cache is only the offline fallback
  final rates = await ref.read(currencyRepositoryProvider).getRates();

  // Auto-refresh every 30 minutes while provider is alive
  Future.delayed(const Duration(minutes: 30), () {
    if (ref.state.hasValue) ref.invalidateSelf();
  });

  return rates;
});

// ── State ─────────────────────────────────────────────────────────────────────
class ConverterState {
  final ConverterCategory category;
  final List<String> units;
  final String fromUnit;
  final String toUnit;
  final String inputText;
  final double? result;

  const ConverterState({
    required this.category,
    required this.units,
    required this.fromUnit,
    required this.toUnit,
    this.inputText = '',
    this.result,
  });

  ConverterState copyWith({
    List<String>? units,
    String? fromUnit,
    String? toUnit,
    String? inputText,
    double? result,
    bool clearResult = false,
  }) =>
      ConverterState(
        category: category,
        units: units ?? this.units,
        fromUnit: fromUnit ?? this.fromUnit,
        toUnit: toUnit ?? this.toUnit,
        inputText: inputText ?? this.inputText,
        result: clearResult ? null : (result ?? this.result),
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────
class ConverterNotifier extends StateNotifier<ConverterState> {
  final Ref _ref;

  ConverterNotifier(this._ref, ConverterCategory category)
      : super(_buildInitial(category, _ref));

  static ConverterState _buildInitial(ConverterCategory cat, Ref ref) {
    final units = cat == ConverterCategory.currency
        ? ref.read(currencyRepositoryProvider).cachedCurrencies
        : ConversionEngine.unitsFor(cat);

    final safeUnits = units.isEmpty ? ['—'] : units;
    return ConverterState(
      category: cat,
      units: safeUnits,
      fromUnit: safeUnits[0],
      toUnit: safeUnits.length > 1 ? safeUnits[1] : safeUnits[0],
    );
  }

  // ── Input handling ──────────────────────────────────────────────────────────
  void appendDigit(String digit) {
    // Prevent multiple leading zeros
    final current = state.inputText;
    if (digit == '0' && current == '0') return;
    if (digit != '0' && current == '0') {
      _setInput(digit);
      return;
    }
    _setInput(current + digit);
  }

  void appendDot() {
    if (state.inputText.contains('.')) return;
    final val = state.inputText.isEmpty ? '0.' : '${state.inputText}.';
    _setInput(val);
  }

  void deleteLast() {
    final t = state.inputText;
    if (t.isEmpty) return;
    _setInput(t.length == 1 ? '' : t.substring(0, t.length - 1));
  }

  void clear() {
    state = state.copyWith(inputText: '', clearResult: true);
  }

  void _setInput(String text) {
    final value = double.tryParse(text);
    if (value == null) {
      state = state.copyWith(inputText: text, clearResult: true);
      return;
    }
    final result = _calculate(value);
    state = state.copyWith(inputText: text, result: result);
  }

  void saveToHistory() {
    final value = double.tryParse(state.inputText);
    final result = state.result;
    if (value == null || result == null) return;
    _saveHistory(value, result);
  }

  // ── Unit selection ──────────────────────────────────────────────────────────
  void setFromUnit(String unit) {
    state = state.copyWith(fromUnit: unit);
    _recalculate();
  }

  void setToUnit(String unit) {
    state = state.copyWith(toUnit: unit);
    _recalculate();
  }

  void swap() {
    state = state.copyWith(fromUnit: state.toUnit, toUnit: state.fromUnit);
    _recalculate();
  }

  void refreshCurrencyUnits(List<String> units) {
    if (units.isEmpty) return;
    final from =
        units.contains(state.fromUnit) ? state.fromUnit : units.first;
    final to = units.contains(state.toUnit)
        ? state.toUnit
        : (units.length > 1 ? units[1] : units.first);
    state = state.copyWith(units: units, fromUnit: from, toUnit: to);
    _recalculate();
  }

  // ── Core calc ───────────────────────────────────────────────────────────────
  void _recalculate() {
    final value = double.tryParse(state.inputText);
    if (value == null) return;
    state = state.copyWith(result: _calculate(value));
  }

  double _calculate(double value) {
    Map<String, double>? rates;
    if (state.category == ConverterCategory.currency) {
      rates = _ref.read(currencyRatesProvider).valueOrNull;
    }
    return ConversionEngine.convert(
      category: state.category,
      fromUnit: state.fromUnit,
      toUnit: state.toUnit,
      value: value,
      currencyRates: rates,
    );
  }

  void _saveHistory(double input, double output) {
    _ref.read(historyRepositoryProvider).add(HistoryEntry(
          category: state.category.label,
          fromUnit: state.fromUnit,
          toUnit: state.toUnit,
          inputValue: input,
          outputValue: output,
          timestamp: DateTime.now(),
        ));
    // Notify history UI immediately
    _ref.read(historyProvider.notifier).refresh();
  }
}

final converterProvider = StateNotifierProvider.family<ConverterNotifier,
    ConverterState, ConverterCategory>(
  (ref, category) => ConverterNotifier(ref, category),
);
