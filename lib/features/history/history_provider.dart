import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unit_converter_pro/data/models/history_entry.dart';
import 'package:unit_converter_pro/data/repositories/history_repository.dart';
import 'package:unit_converter_pro/data/providers/repository_providers.dart';

class HistoryNotifier extends StateNotifier<List<HistoryEntry>> {
  final HistoryRepository _repo;

  HistoryNotifier(this._repo) : super(_repo.getAll());

  void refresh() => state = List.from(_repo.getAll());

  Future<void> removeAt(int index) async {
    await _repo.removeAt(index);
    state = List.from(_repo.getAll());
  }

  Future<void> clear() async {
    await _repo.clear();
    state = [];
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<HistoryEntry>>(
  (ref) => HistoryNotifier(ref.read(historyRepositoryProvider)),
);
