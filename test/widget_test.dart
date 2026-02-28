import 'package:flutter_test/flutter_test.dart';
import 'package:walletflow/main.dart';

void main() {
  testWidgets('App loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const WalletFlowApp());
    expect(find.text('WalletFlow'), findsOneWidget);
  });
}
