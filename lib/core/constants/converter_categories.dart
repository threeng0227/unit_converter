import 'package:flutter/material.dart';
import 'package:unit_converter_pro/core/theme/app_theme.dart';

enum ConverterCategory {
  length,
  weight,
  temperature,
  area,
  speed,
  currency,
  dataStorage,
}

extension ConverterCategoryX on ConverterCategory {
  String get label => switch (this) {
        ConverterCategory.length => 'Length',
        ConverterCategory.weight => 'Weight',
        ConverterCategory.temperature => 'Temperature',
        ConverterCategory.area => 'Area',
        ConverterCategory.speed => 'Speed',
        ConverterCategory.currency => 'Currency',
        ConverterCategory.dataStorage => 'Data Storage',
      };

  String localizedLabel(String langCode) => langCode == 'vi'
      ? switch (this) {
          ConverterCategory.length => 'Chiều dài',
          ConverterCategory.weight => 'Khối lượng',
          ConverterCategory.temperature => 'Nhiệt độ',
          ConverterCategory.area => 'Diện tích',
          ConverterCategory.speed => 'Tốc độ',
          ConverterCategory.currency => 'Tiền tệ',
          ConverterCategory.dataStorage => 'Lưu trữ',
        }
      : label;

  IconData get icon => switch (this) {
        ConverterCategory.length => Icons.straighten_rounded,
        ConverterCategory.weight => Icons.monitor_weight_outlined,
        ConverterCategory.temperature => Icons.thermostat_rounded,
        ConverterCategory.area => Icons.grid_4x4_rounded,
        ConverterCategory.speed => Icons.speed_rounded,
        ConverterCategory.currency => Icons.currency_exchange_rounded,
        ConverterCategory.dataStorage => Icons.storage_rounded,
      };

  List<Color> get gradient => AppColors.categoryGradients[index];

  Color get iconBg => AppColors.categoryIconBg[index];

  String get routeName => switch (this) {
        ConverterCategory.length => 'length',
        ConverterCategory.weight => 'weight',
        ConverterCategory.temperature => 'temperature',
        ConverterCategory.area => 'area',
        ConverterCategory.speed => 'speed',
        ConverterCategory.currency => 'currency',
        ConverterCategory.dataStorage => 'data-storage',
      };
}
