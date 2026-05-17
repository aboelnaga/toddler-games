import 'package:toddler_games/app/app.dart';
import 'package:toddler_games/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() => const App());
}
