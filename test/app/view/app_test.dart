import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/app/app.dart';

void main() {
  group('App', () {
    testWidgets('renders scaffold placeholder', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App()),
      );
      expect(find.text('Toddler Games — scaffold ready'), findsOneWidget);
    });
  });
}
