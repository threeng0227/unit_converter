import 'package:hive_flutter/hive_flutter.dart';
import 'package:unit_converter_pro/core/constants/app_constants.dart';

part 'favorite_conversion.g.dart';

@HiveType(typeId: HiveTypeIds.favoriteConversion)
class FavoriteConversion extends HiveObject {
  @HiveField(0)
  final String category;

  @HiveField(1)
  final String fromUnit;

  @HiveField(2)
  final String toUnit;

  @HiveField(3)
  final String id;

  FavoriteConversion({
    required this.category,
    required this.fromUnit,
    required this.toUnit,
    required this.id,
  });

  factory FavoriteConversion.create({
    required String category,
    required String fromUnit,
    required String toUnit,
  }) =>
      FavoriteConversion(
        category: category,
        fromUnit: fromUnit,
        toUnit: toUnit,
        id: '${category}_${fromUnit}_$toUnit',
      );
}
