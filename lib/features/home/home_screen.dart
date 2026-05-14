import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unit_converter_pro/core/constants/converter_categories.dart';
import 'package:unit_converter_pro/core/l10n/locale_provider.dart';
import 'package:unit_converter_pro/core/theme/app_theme.dart';
import 'package:unit_converter_pro/features/history/history_provider.dart';
import 'package:unit_converter_pro/shared/widgets/banner_ad_widget.dart';

final _searchProvider = StateProvider<String>((_) => '');

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = stringsOf(ref);
    final query = ref.watch(_searchProvider);
    final lang = ref.watch(localeProvider).languageCode;
    final categories = ConverterCategory.values
        .where((c) => c.localizedLabel(lang).toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _Header(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SearchBar(
                hint: s.searchConverter,
                onChanged: (q) =>
                    ref.read(_searchProvider.notifier).state = q,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: categories.isEmpty
                  ? Center(
                      child: Text(s.noResults,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 14)),
                    )
                  : _CategoryGrid(categories: categories, lang: lang),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = stringsOf(ref);
    final count = ref.watch(historyProvider).length;
    final locale = ref.watch(localeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  s.appTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ConverterCategory.values.length} ${s.homeSubtitle}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // ── Language toggle ────────────────────────────────────────────
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(localeProvider.notifier).toggle();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              alignment: Alignment.center,
              child: Text(
                locale.languageCode == 'en' ? '🇬🇧' : '🇻🇳',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _HistoryButton(count: count),
        ],
      ),
    );
  }
}

class _HistoryButton extends StatelessWidget {
  final int count;
  const _HistoryButton({required this.count});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/history');
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          if (count > 0)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                height: 18,
                constraints: const BoxConstraints(minWidth: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────
class _SearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String hint;
  const _SearchBar({required this.onChanged, required this.hint});

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      onChanged: (v) {
        widget.onChanged(v);
        setState(() {});
      },
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w400),
        prefixIcon: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Icon(Icons.search_rounded,
              color: AppColors.textSecondary, size: 20),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 48, minHeight: 48),
        suffixIcon: _ctrl.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  _ctrl.clear();
                  widget.onChanged('');
                  setState(() {});
                },
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
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

// ── Grid ──────────────────────────────────────────────────────────────────────
class _CategoryGrid extends ConsumerWidget {
  final List<ConverterCategory> categories;
  final String lang;
  const _CategoryGrid({required this.categories, required this.lang});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = stringsOf(ref);
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemCount: categories.length,
      itemBuilder: (ctx, i) => _CategoryCard(
        category: categories[i],
        index: i,
        openLabel: s.open,
        lang: lang,
      ),
    );
  }
}

// ── Category card ─────────────────────────────────────────────────────────────
class _CategoryCard extends StatefulWidget {
  final ConverterCategory category;
  final int index;
  final String openLabel;
  final String lang;
  const _CategoryCard(
      {required this.category, required this.index, required this.openLabel, required this.lang});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
    lowerBound: 0.95,
    upperBound: 1.0,
    value: 1.0,
  );

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails d) => _press.reverse();
  void _onTapUp(TapUpDetails d) => _press.forward();
  void _onTapCancel() => _press.forward();

  @override
  Widget build(BuildContext context) {
    final g = widget.category.gradient;

    return ScaleTransition(
      scale: _press,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/converter/${widget.category.routeName}');
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.cardBorder),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      g[0].withValues(alpha: 0.28),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: g,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: g[0].withValues(alpha: 0.30),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(widget.category.icon,
                          color: Colors.white, size: 21),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.category.localizedLabel(widget.lang),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              ShaderMask(
                                shaderCallback: (b) =>
                                    LinearGradient(colors: g).createShader(b),
                                child: Text(
                                  widget.openLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(Icons.arrow_forward_rounded,
                                  size: 10, color: g[0]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: (widget.index * 45).ms, duration: 280.ms)
            .slideY(
                begin: 0.05,
                end: 0,
                delay: (widget.index * 45).ms,
                duration: 280.ms,
                curve: Curves.easeOutCubic),
      ),
    );
  }
}
