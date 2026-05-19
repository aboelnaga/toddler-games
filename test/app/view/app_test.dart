import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/app/app.dart';

void main() {
  group('App', () {
    testWidgets('boots into HomeScreen', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Home (scaffold)'), findsOneWidget);
    });
  });
}
