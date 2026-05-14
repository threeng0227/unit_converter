abstract class AppConstants {
  static const String appName = 'Unit Converter Pro';
  static const String currencyApiBase = 'https://open.er-api.com/v6/latest';
  static const String currencyApiKey = 'YOUR_API_KEY'; // replace with real key
  static const String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // test id
  static const String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // test id
  static const String appOpenAdUnitId = 'ca-app-pub-3940256099942544/9257395921'; // test id
  static const int currencyCacheDurationMinutes = 30;
  static const int maxHistoryItems = 100;
  static const int maxFavoriteItems = 50;
}

abstract class HiveBoxes {
  static const String favorites = 'favorites';
  static const String history = 'history';
  static const String currencyRates = 'currency_rates';
  static const String settings = 'settings';
}

abstract class HiveTypeIds {
  static const int favoriteConversion = 0;
  static const int historyEntry = 1;
  static const int currencyCache = 2;
}
