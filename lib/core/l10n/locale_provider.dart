import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter_pro/core/l10n/app_strings.dart';

const _kLangKey = 'app_language';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() => const Locale('en');

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kLangKey);
    if (saved != null) state = Locale(saved);
  }

  Future<void> toggle() async {
    final next = state.languageCode == 'en' ? 'vi' : 'en';
    state = Locale(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLangKey, next);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

S stringsOf(WidgetRef ref) {
  final lang = ref.watch(localeProvider).languageCode;
  return lang == 'vi' ? const SVI() : const SEN();
}
