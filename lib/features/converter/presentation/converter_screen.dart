import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unit_converter_pro/core/constants/converter_categories.dart';
import 'package:unit_converter_pro/core/l10n/locale_provider.dart';
import 'package:unit_converter_pro/core/services/conversion_engine.dart';
import 'package:unit_converter_pro/core/theme/app_theme.dart';
import 'package:unit_converter_pro/core/utils/number_formatter.dart';
import 'package:unit_converter_pro/data/providers/repository_providers.dart';
import 'package:unit_converter_pro/features/converter/providers/converter_provider.dart';
import 'package:unit_converter_pro/shared/widgets/banner_ad_widget.dart';
import 'package:unit_converter_pro/shared/widgets/calculator_keypad.dart';

class ConverterScreen extends ConsumerStatefulWidget {
  final ConverterCategory category;
  const ConverterScreen({super.key, required this.category});

  @override
  ConsumerState<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends ConsumerState<ConverterScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.category == ConverterCategory.currency) {
      ref.listenManual(currencyRatesProvider, (_, next) {
        next.whenData((rates) {
          ref
              .read(converterProvider(widget.category).notifier)
              .refreshCurrencyUnits(rates.keys.toList());
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(converterProvider(widget.category));
    final notifier = ref.read(converterProvider(widget.category).notifier);
    final g = widget.category.gradient;

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) notifier.saveToHistory();
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ────────────────────────────────────────────────────
            _AppBar(category: widget.category, gradient: g),
            const SizedBox(height: 12),
            // ── Result display ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _ResultPanel(state: state, gradient: g),
            ),
            const SizedBox(height: 10),
            // ── Unit selectors ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _UnitRow(
                state: state,
                gradient: g,
                onFromChanged: notifier.setFromUnit,
                onToChanged: notifier.setToUnit,
                onSwap: notifier.swap,
              ),
            ),
            if (widget.category == ConverterCategory.currency) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _CurrencyBadge(),
              ),
            ],
            const SizedBox(height: 8),
            // ── Keypad ────────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: CalculatorKeypad(
                  onDigit: notifier.appendDigit,
                  onDot: notifier.appendDot,
                  onDelete: notifier.deleteLast,
                  onClear: notifier.clear,
                ),
              ),
            ),
            // ── Banner Ad ─────────────────────────────────────────────────
            const BannerAdWidget(),
          ],
        ),
      ),
    ),
    );
  }
}

// ── Custom AppBar ─────────────────────────────────────────────────────────────
class _AppBar extends ConsumerWidget {
  final ConverterCategory category;
  final List<Color> gradient;
  const _AppBar({required this.category, required this.gradient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // Back
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 15, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(category.icon, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  category.localizedLabel(lang),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Result panel ──────────────────────────────────────────────────────────────
class _ResultPanel extends StatelessWidget {
  final ConverterState state;
  final List<Color> gradient;
  const _ResultPanel({required this.state, required this.gradient});

  @override
  Widget build(BuildContext context) {
    final inputDisplay = state.inputText.isEmpty ? '0' : state.inputText;
    final resultText =
        state.result != null ? NumberFormatter.format(state.result!) : '—';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── From ───────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.fromUnit,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 44,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      inputDisplay,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 40,
                        fontWeight: FontWeight.w300,
                        letterSpacing: -1.5,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Divider with arrow indicator
          Stack(
            alignment: Alignment.center,
            children: [
              Container(height: 1, color: AppColors.cardBorder),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16, color: gradient[0]),
              ),
            ],
          ),
          // ── To ─────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 14, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.toUnit,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 44,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: ShaderMask(
                            shaderCallback: (b) => LinearGradient(colors: gradient)
                                .createShader(b),
                            child: Text(
                              resultText,
                              key: ValueKey(resultText),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1.5,
                                height: 1,
                              ),
                            )
                                .animate(key: ValueKey(resultText))
                                .fadeIn(duration: 150.ms)
                                .slideY(
                                    begin: 0.15,
                                    end: 0,
                                    duration: 200.ms,
                                    curve: Curves.easeOut),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (state.result != null) _CopyButton(text: resultText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Copy button ───────────────────────────────────────────────────────────────
class _CopyButton extends ConsumerStatefulWidget {
  final String text;
  const _CopyButton({required this.text});

  @override
  ConsumerState<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends ConsumerState<_CopyButton> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final s = stringsOf(ref);
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        await Clipboard.setData(ClipboardData(text: widget.text));
        setState(() => _copied = true);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) setState(() => _copied = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: _copied
              ? Colors.green.withValues(alpha: 0.12)
              : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _copied
                ? Colors.green.withValues(alpha: 0.5)
                : AppColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _copied ? Icons.check_rounded : Icons.copy_rounded,
              size: 13,
              color: _copied ? Colors.green : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              _copied ? s.copied : s.copy,
              style: TextStyle(
                color: _copied ? Colors.green : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Unit row ──────────────────────────────────────────────────────────────────
class _UnitRow extends ConsumerWidget {
  final ConverterState state;
  final List<Color> gradient;
  final ValueChanged<String> onFromChanged;
  final ValueChanged<String> onToChanged;
  final VoidCallback onSwap;

  const _UnitRow({
    required this.state,
    required this.gradient,
    required this.onFromChanged,
    required this.onToChanged,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider).languageCode;
    final fromLabel = locale == 'vi' ? 'TỪ' : 'FROM';
    final toLabel = locale == 'vi' ? 'SANG' : 'TO';
    return Row(
      children: [
        Expanded(
          child: _UnitPicker(
            label: fromLabel,
            selected: state.fromUnit,
            units: state.units,
            onChanged: onFromChanged,
          ),
        ),
        const SizedBox(width: 10),
        _SwapButton(gradient: gradient, onTap: onSwap),
        const SizedBox(width: 10),
        Expanded(
          child: _UnitPicker(
            label: toLabel,
            selected: state.toUnit,
            units: state.units,
            onChanged: onToChanged,
          ),
        ),
      ],
    );
  }
}

class _SwapButton extends StatefulWidget {
  final List<Color> gradient;
  final VoidCallback onTap;
  const _SwapButton({required this.gradient, required this.onTap});

  @override
  State<_SwapButton> createState() => _SwapButtonState();
}

class _SwapButtonState extends State<_SwapButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        _spin.forward(from: 0);
        widget.onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: widget.gradient[0].withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: RotationTransition(
          turns: _spin,
          child: const Icon(Icons.swap_horiz_rounded,
              color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

// ── Unit picker ───────────────────────────────────────────────────────────────
class _UnitPicker extends ConsumerWidget {
  final String label;
  final String selected;
  final List<String> units;
  final ValueChanged<String> onChanged;

  const _UnitPicker({
    required this.label,
    required this.selected,
    required this.units,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safe =
        units.contains(selected) ? selected : (units.firstOrNull ?? '—');
    final lang = ref.watch(localeProvider).languageCode;
    final displaySafe = ConversionEngine.localizedName(safe, lang);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _showSheet(context);
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.fromLTRB(14, 0, 10, 0),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    displaySafe,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.unfold_more_rounded,
                color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (ctx) => _PickerSheet(
        label: label,
        selected: selected,
        units: units,
        onChanged: (u) {
          Navigator.pop(ctx);
          onChanged(u);
        },
      ),
    );
  }
}

// ── Picker bottom sheet ───────────────────────────────────────────────────────
class _PickerSheet extends ConsumerStatefulWidget {
  final String label;
  final String selected;
  final List<String> units;
  final ValueChanged<String> onChanged;

  const _PickerSheet({
    required this.label,
    required this.selected,
    required this.units,
    required this.onChanged,
  });

  @override
  ConsumerState<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends ConsumerState<_PickerSheet> {
  late List<String> _filtered;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.units;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scroll) => Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.fromLTRB(0, 12, 0, 16),
            decoration: BoxDecoration(
              color: AppColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '${stringsOf(ref).selectUnit} ${widget.label}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _ctrl,
              autofocus: false,
              onChanged: (q) => setState(() {
                _filtered = widget.units
                    .where((u) => u.toLowerCase().contains(q.toLowerCase()))
                    .toList();
              }),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: stringsOf(ref).searchUnit,
                hintStyle: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 14),
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(Icons.search_rounded,
                      color: AppColors.textSecondary, size: 18),
                ),
                prefixIconConstraints:
                    const BoxConstraints(minWidth: 46, minHeight: 46),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () => setState(() {
                          _ctrl.clear();
                          _filtered = widget.units;
                        }),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Icon(Icons.close_rounded,
                              color: AppColors.textSecondary, size: 16),
                        ),
                      )
                    : null,
                suffixIconConstraints:
                    const BoxConstraints(minWidth: 44, minHeight: 44),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // List
          Expanded(
            child: ListView.builder(
              controller: scroll,
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final unit = _filtered[i];
                final sel = unit == widget.selected;
                final symbol = ConversionEngine.symbolFor(unit);
                final lang = ref.read(localeProvider).languageCode;
                final displayName = ConversionEngine.localizedName(unit, lang);
                return InkWell(
                  onTap: () => widget.onChanged(unit),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 13),
                    child: Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: displayName,
                                  style: TextStyle(
                                    color: sel
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: sel
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                  ),
                                ),
                                if (symbol.isNotEmpty)
                                  TextSpan(
                                    text: symbol,
                                    style: TextStyle(
                                      color: sel
                                          ? AppColors.primary.withValues(alpha: 0.7)
                                          : AppColors.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (sel)
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.primary, size: 18),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Currency status badge ─────────────────────────────────────────────────────
class _CurrencyBadge extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rates = ref.watch(currencyRatesProvider);
    return rates.when(
      loading: () => const SizedBox(
        height: 2,
        child: LinearProgressIndicator(
            backgroundColor: AppColors.card, color: AppColors.primary),
      ),
      data: (_) {
        final ts = ref.read(currencyRepositoryProvider).lastUpdated;
        return Row(children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
                color: Colors.green, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            ts != null
                ? '${stringsOf(ref).liveRates} · ${ts.day}/${ts.month} ${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}'
                : stringsOf(ref).liveRates,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 11),
          ),
        ]);
      },
      error: (e, s) => Row(children: [
        Container(
          width: 6,
          height: 6,
          decoration:
              const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(stringsOf(ref).offlineRates,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ]),
    );
  }
}
