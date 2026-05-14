import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unit_converter_pro/core/constants/converter_categories.dart';
import 'package:unit_converter_pro/core/theme/app_theme.dart';
import 'package:unit_converter_pro/features/favorites/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final notifier = ref.read(favoritesProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Favorites')),
      body: favorites.isEmpty
          ? Center(
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
                    child: const Icon(Icons.star_outline_rounded, size: 36, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  const Text('No favorites yet',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Star a conversion to save it here',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: favorites.length,
              separatorBuilder: (context, idx) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final fav = favorites[i];
                final category = ConverterCategory.values.firstWhere(
                  (c) => c.label == fav.category,
                  orElse: () => ConverterCategory.length,
                );
                final gradient = category.gradient;

                return GestureDetector(
                  onTap: () => context.push('/converter/${category.routeName}'),
                  child: Container(
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
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gradient),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(category.icon, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fav.category,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 3),
                                Text(
                                  '${fav.fromUnit}  →  ${fav.toUnit}',
                                  style: const TextStyle(
                                      color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.star_rounded, color: AppColors.primary, size: 20),
                            onPressed: () => notifier.toggle(fav),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
