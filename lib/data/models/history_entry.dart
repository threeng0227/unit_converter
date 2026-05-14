import 'package:hive_flutter/hive_flutter.dart';
import 'package:unit_converter_pro/core/constants/app_constants.dart';

part 'history_entry.g.dart';

@HiveType(typeId: HiveTypeIds.historyEntry)
class HistoryEntry extends HiveObject {
  @HiveField(0)
  final String category;

  @HiveField(1)
  final String fromUnit;

  @HiveField(2)
  final String toUnit;

  @HiveField(3)
  final double inputValue;

  @HiveField(4)
  final double outputValue;

  @HiveField(5)
  final DateTime timestamp;

  HistoryEntry({
    required this.category,
    required this.fromUnit,
    required this.toUnit,
    required this.inputValue,
    required this.outputValue,
    required this.timestamp,
  });
}
