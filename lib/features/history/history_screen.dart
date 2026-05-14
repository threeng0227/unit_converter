import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:unit_converter_pro/core/constants/converter_categories.dart';
import 'package:unit_converter_pro/core/l10n/app_strings.dart';
import 'package:unit_converter_pro/core/l10n/locale_provider.dart';
import 'package:unit_converter_pro/core/theme/app_theme.dart';
import 'package:unit_converter_pro/core/utils/number_formatter.dart';
import 'package:unit_converter_pro/features/history/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = stringsOf(ref);
    final history = ref.watch(historyProvider);
    final notifier = ref.read(historyProvider.notifier);
    final lang = ref.watch(localeProvider).languageCode;
    final dateFmt = DateFormat('d MMM · HH:mm', lang);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.only(left: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: AppColors.textSecondary),
          ),
        ),
        leadingWidth: 52,
        title: Text(s.history,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        actions: [
          if (history.isNotEmpty)
            GestureDetector(
              onTap: () => _confirmClear(context, notifier, s),
              child: Container(
                margin: const EdgeInsets.only(right: 14),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
                ),
                child: Text(s.clear,
                    style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
      body: history.isEmpty
          ? _empty(s)
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: history.length,
              separatorBuilder: (_, i) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final e = history[i];
                final cat = ConverterCategory.values.firstWhere(
                  (c) => c.label == e.category,
                  orElse: () => ConverterCategory.length,
                );
                return Dismissible(
                  key: ValueKey(e.timestamp),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => notifier.removeAt(i),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: Colors.redAccent, size: 24),
                  ),
                  child: _HistoryCard(
                    category: cat,
                    fromValue: NumberFormatter.format(e.inputValue),
                    toValue: NumberFormatter.format(e.outputValue),
                    fromUnit: e.fromUnit,
                    toUnit: e.toUnit,
                    time: dateFmt.format(e.timestamp),
                  ),
                );
              },
            ),
    );
  }

  Widget _empty(S s) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(Icons.history_rounded,
                size: 32, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Text(s.noHistoryYet,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(s.noHistorySubtitle,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, HistoryNotifier notifier, S s) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(s.clearHistoryTitle,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 17)),
        content: Text(s.clearHistoryContent,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              notifier.clear();
            },
            child: Text(s.clear),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ConverterCategory category;
  final String fromValue;
  final String toValue;
  final String fromUnit;
  final String toUnit;
  final String time;

  const _HistoryCard({
    required this.category,
    required this.fromValue,
    required this.toValue,
    required this.fromUnit,
    required this.toUnit,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final g = category.gradient;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: g),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(category.icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$fromValue $fromUnit',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$toValue $toUnit',
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(time,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
