import 'package:flutter_test/flutter_test.dart';
import 'package:tripline_admin_dashboard/main.dart';

void main() {
  testWidgets('Dashboard smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AdminDashboardApp());
  });
}
