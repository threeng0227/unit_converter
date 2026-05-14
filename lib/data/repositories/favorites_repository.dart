import 'package:hive_flutter/hive_flutter.dart';
import 'package:unit_converter_pro/core/constants/app_constants.dart';
import 'package:unit_converter_pro/data/models/favorite_conversion.dart';

class FavoritesRepository {
  Box<FavoriteConversion> get _box => Hive.box<FavoriteConversion>(HiveBoxes.favorites);

  List<FavoriteConversion> getAll() => _box.values.toList();

  bool isFavorite(String id) => _box.containsKey(id);

  Future<void> add(FavoriteConversion fav) async {
    if (_box.length >= AppConstants.maxFavoriteItems) return;
    await _box.put(fav.id, fav);
  }

  Future<void> remove(String id) async => await _box.delete(id);

  Future<void> toggle(FavoriteConversion fav) async {
    if (isFavorite(fav.id)) {
      await remove(fav.id);
    } else {
      await add(fav);
    }
  }
}
