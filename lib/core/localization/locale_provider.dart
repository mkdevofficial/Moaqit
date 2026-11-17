import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moaqit/core/services/storage_service.dart';

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(() {
  return LocaleNotifier();
});

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final storage = ref.watch(storageServiceProvider);
    final langCode = storage.getString('language_code') ?? 'ar';
    return Locale(langCode);
  }

  Future<void> setLocale(Locale newLocale) async {
    state = newLocale;
    final storage = ref.read(storageServiceProvider);
    await storage.setString('language_code', newLocale.languageCode);
  }

  void toggleLocale() {
    if (state.languageCode == 'ar') {
      setLocale(const Locale('en'));
    } else {
      setLocale(const Locale('ar'));
    }
  }
}
