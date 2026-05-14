abstract class S {
  // ── Home ──────────────────────────────────────────────────────────────────
  final String appTitle;
  final String homeSubtitle;
  final String searchConverter;
  final String noResults;
  final String open;

  // ── History ───────────────────────────────────────────────────────────────
  final String history;
  final String clear;
  final String noHistoryYet;
  final String noHistorySubtitle;
  final String clearHistoryTitle;
  final String clearHistoryContent;
  final String cancel;

  // ── Converter ─────────────────────────────────────────────────────────────
  final String searchUnit;
  final String selectUnit;
  final String copy;
  final String copied;
  final String liveRates;
  final String offlineRates;

  const S({
    required this.appTitle,
    required this.homeSubtitle,
    required this.searchConverter,
    required this.noResults,
    required this.open,
    required this.history,
    required this.clear,
    required this.noHistoryYet,
    required this.noHistorySubtitle,
    required this.clearHistoryTitle,
    required this.clearHistoryContent,
    required this.cancel,
    required this.searchUnit,
    required this.selectUnit,
    required this.copy,
    required this.copied,
    required this.liveRates,
    required this.offlineRates,
  });
}

class SEN extends S {
  const SEN()
      : super(
          appTitle: 'Unit Converter',
          homeSubtitle: 'converters • Works offline',
          searchConverter: 'Search converter...',
          noResults: 'No results',
          open: 'Open',
          history: 'History',
          clear: 'Clear',
          noHistoryYet: 'No history yet',
          noHistorySubtitle: 'Your conversions will appear here',
          clearHistoryTitle: 'Clear history?',
          clearHistoryContent: 'All conversion history will be deleted.',
          cancel: 'Cancel',
          searchUnit: 'Search unit...',
          selectUnit: 'Select unit',
          copy: 'Copy',
          copied: 'Copied',
          liveRates: 'Live rates',
          offlineRates: 'Offline · cached rates',
        );
}

class SVI extends S {
  const SVI()
      : super(
          appTitle: 'Đổi Đơn Vị',
          homeSubtitle: 'bộ chuyển đổi • Dùng offline',
          searchConverter: 'Tìm bộ chuyển đổi...',
          noResults: 'Không có kết quả',
          open: 'Mở',
          history: 'Lịch sử',
          clear: 'Xóa',
          noHistoryYet: 'Chưa có lịch sử',
          noHistorySubtitle: 'Các lần chuyển đổi sẽ hiện ở đây',
          clearHistoryTitle: 'Xóa lịch sử?',
          clearHistoryContent: 'Toàn bộ lịch sử chuyển đổi sẽ bị xóa.',
          cancel: 'Hủy',
          searchUnit: 'Tìm đơn vị...',
          selectUnit: 'Chọn đơn vị',
          copy: 'Sao chép',
          copied: 'Đã sao chép',
          liveRates: 'Tỷ giá thực',
          offlineRates: 'Offline · tỷ giá cache',
        );
}
