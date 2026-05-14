import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unit_converter_pro/core/constants/converter_categories.dart';
import 'package:unit_converter_pro/features/converter/presentation/converter_screen.dart';
import 'package:unit_converter_pro/features/history/history_screen.dart';
import 'package:unit_converter_pro/features/home/home_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (ctx, s) => const HomeScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (ctx, s) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/converter/:category',
      pageBuilder: (context, state) {
        final categoryName = state.pathParameters['category']!;
        final category = ConverterCategory.values.firstWhere(
          (c) => c.routeName == categoryName,
          orElse: () => ConverterCategory.length,
        );
        return CustomTransitionPage(
          child: ConverterScreen(category: category),
          transitionsBuilder: (context, animation, _, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
              child: child,
            );
          },
        );
      },
    ),
  ],
);
