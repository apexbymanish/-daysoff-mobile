import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daysoff_mobile/screens/destinations/destinations_screen.dart';

void main() {
  Widget makeApp() => const MaterialApp(home: DestinationsScreen());

  testWidgets('renders title, all 4 destinations, and Trip Collections section',
      (tester) async {
    await tester.pumpWidget(makeApp());
    await tester.pump();

    expect(find.text('Find Your Escape'), findsWidgets); // AppBar + header
    expect(find.text('Cinque Terre, Italy'), findsOneWidget);
    expect(find.text('Arashiyama, Kyoto'), findsOneWidget);
    // Scroll to reveal items further down the list
    await tester.scrollUntilVisible(
        find.text('Marrakech, Morocco'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Marrakech, Morocco'), findsOneWidget);
    await tester.scrollUntilVisible(
        find.text('Grindelwald, Swiss Alps'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Grindelwald, Swiss Alps'), findsOneWidget);
    await tester.scrollUntilVisible(
        find.text('Trip Collections'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Trip Collections'), findsOneWidget);
  });

  testWidgets('tapping Mountains chip filters to Swiss Alps only',
      (tester) async {
    await tester.pumpWidget(makeApp());
    await tester.pump();

    // Verify Arashiyama is visible before filtering
    expect(find.text('Arashiyama, Kyoto'), findsOneWidget);

    // Tap the Mountains chip
    await tester.tap(find.text('MOUNTAINS'));
    await tester.pump();

    expect(find.text('Grindelwald, Swiss Alps'), findsOneWidget);
    expect(find.text('Arashiyama, Kyoto'), findsNothing);
  });

  testWidgets('searching "kyoto" shows Arashiyama and hides Marrakech',
      (tester) async {
    await tester.pumpWidget(makeApp());
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'kyoto');
    await tester.pump();

    expect(find.text('Arashiyama, Kyoto'), findsOneWidget);
    expect(find.text('Marrakech, Morocco'), findsNothing);
  });
}
