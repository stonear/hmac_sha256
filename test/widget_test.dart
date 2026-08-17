import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmac_sha256/main.dart';

void main() {
  testWidgets('shows the generator and validator tabs', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    expect(find.text('HMAC SHA256 Generator'), findsOneWidget);
    expect(find.text('Generator'), findsAtLeastNWidgets(1));
    expect(find.text('Validator'), findsOneWidget);
  });
}
