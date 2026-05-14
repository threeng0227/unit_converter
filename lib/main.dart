import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:unit_converter_pro/core/constants/app_constants.dart';
import 'package:unit_converter_pro/core/router/app_router.dart';
import 'package:unit_converter_pro/core/theme/app_theme.dart';
import 'package:unit_converter_pro/data/models/currency_cache.dart';
import 'package:unit_converter_pro/data/models/favorite_conversion.dart';
import 'package:unit_converter_pro/data/models/history_entry.dart';
import 'package:unit_converter_pro/core/l10n/locale_provider.dart';
import 'package:unit_converter_pro/shared/ads/ad_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi');
  await initializeDateFormatting('en');

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0E0F1A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Hive.initFlutter();
  Hive.registerAdapter(FavoriteConversionAdapter());
  Hive.registerAdapter(HistoryEntryAdapter());
  Hive.registerAdapter(CurrencyCacheAdapter());
  await Future.wait([
    Hive.openBox<FavoriteConversion>(HiveBoxes.favorites),
    Hive.openBox<HistoryEntry>(HiveBoxes.history),
    Hive.openBox<CurrencyCache>(HiveBoxes.currencyRates),
  ]);

  await AdService.initialize();
  AppOpenAdManager.load(showOnLoad: true); // show on cold start

  final container = ProviderContainer();
  await container.read(localeProvider.notifier).load();

  runApp(UncontrolledProviderScope(container: container, child: const App()));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AppOpenAdManager.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: appRouter,
    );
  }
}
