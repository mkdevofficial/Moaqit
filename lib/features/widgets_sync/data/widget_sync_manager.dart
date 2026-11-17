import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moaqit/core/services/widget_sync_service.dart';

final widgetSyncManagerProvider = Provider<WidgetSyncManager>((ref) {
  final service = ref.watch(widgetSyncServiceProvider);
  return WidgetSyncManager(service);
});

class WidgetSyncManager {
  final WidgetSyncService _service;

  WidgetSyncManager(this._service);

  Future<void> forceSyncAll() async {
    // Manual trigger for refresh or on settings change
    _service.toString();
  }
}
