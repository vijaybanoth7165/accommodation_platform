import 'package:flutter_test/flutter_test.dart';
import 'package:accommodation_platform/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AccommodationPlatformApp());
    expect(find.byType(AccommodationPlatformApp), findsOneWidget);
  });
}
