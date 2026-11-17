import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:moaqit/core/localization/app_localizations.dart';
import 'package:moaqit/core/widgets/rolling_odometer.dart';

void main() {
  test('AppLocalizations number formatter converts digits in Arabic', () {
    final locAr = AppLocalizations(const Locale('ar'));
    expect(locAr.formatNumber(12345), '١٢٣٤٥');

    final locEn = AppLocalizations(const Locale('en'));
    expect(locEn.formatNumber(12345), '12345');
  });

  testWidgets('RollingTimeOdometer displays formatted duration',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RollingTimeOdometer(
            duration: Duration(hours: 2, minutes: 15, seconds: 40),
          ),
        ),
      ),
    );

    expect(find.byType(RollingTimeOdometer), findsOneWidget);
  });
}
