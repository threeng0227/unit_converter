import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unit_converter_pro/data/models/favorite_conversion.dart';
import 'package:unit_converter_pro/data/repositories/favorites_repository.dart';

final favoritesRepositoryProvider = Provider((_) => FavoritesRepository());

class FavoritesNotifier extends StateNotifier<List<FavoriteConversion>> {
  final FavoritesRepository _repo;

  FavoritesNotifier(this._repo) : super(_repo.getAll());

  Future<void> toggle(FavoriteConversion fav) async {
    await _repo.toggle(fav);
    state = _repo.getAll();
  }

  bool isFavorite(String id) => _repo.isFavorite(id);
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<FavoriteConversion>>(
  (ref) => FavoritesNotifier(ref.read(favoritesRepositoryProvider)),
);
