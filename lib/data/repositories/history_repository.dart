import 'package:hive_flutter/hive_flutter.dart';
import 'package:unit_converter_pro/core/constants/app_constants.dart';
import 'package:unit_converter_pro/data/models/history_entry.dart';

class HistoryRepository {
  Box<HistoryEntry> get _box => Hive.box<HistoryEntry>(HiveBoxes.history);

  List<HistoryEntry> getAll() {
    final list = _box.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  Future<void> add(HistoryEntry entry) async {
    await _box.add(entry);
    if (_box.length > AppConstants.maxHistoryItems) {
      await _box.deleteAt(0);
    }
  }

  Future<void> removeAt(int sortedIndex) async {
    final list = _box.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final key = _box.keyAt(_box.values.toList().indexOf(list[sortedIndex]));
    await _box.delete(key);
  }

  Future<void> clear() async => await _box.clear();
}
