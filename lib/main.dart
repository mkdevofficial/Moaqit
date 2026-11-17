import 'package:material_ui/material_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moaqit/core/theme/app_theme.dart';
import 'package:moaqit/core/services/storage_service.dart';
import 'package:moaqit/core/services/notification_service.dart';
import 'package:moaqit/core/localization/app_localizations.dart';
import 'package:moaqit/core/localization/locale_provider.dart';
import 'package:moaqit/features/splash/presentation/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage
  final storageService = await StorageService.init();

  // Initialize notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const MawaqitApp(),
    ),
  );
}

class MawaqitApp extends ConsumerWidget {
  const MawaqitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Mawaqit مواقيت',
      debugShowCheckedModeBanner: false,
      locale: currentLocale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        ...GlobalMaterialLocalizations.delegates,
        ...GlobalCupertinoLocalizations.delegates,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: AppTheme.getTheme(AppThemeMode.emeraldNight),
      home: const SplashScreen(),
    );
  }
}
