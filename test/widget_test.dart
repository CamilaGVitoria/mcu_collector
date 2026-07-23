import 'package:flutter_test/flutter_test.dart';

import 'package:mcu_collector/main.dart';

void main() {
  testWidgets('App should render MCU Collector title', (WidgetTester tester) async {
    await tester.pumpWidget(const McuCollectorApp());
    await tester.pumpAndSettle();

    expect(find.text('MCU Collector'), findsOneWidget);
  });
}
