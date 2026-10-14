import 'package:flutter_test/flutter_test.dart';
import 'package:blog_nosql/main.dart';

void main() {
  testWidgets('EcoBlogApp smoke test - verifies login screen rendering', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EcoBlogApp());

    // Verifica elementos clave de la vista de Login
    expect(find.text('TerraBlog'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
    expect(find.text('Regístrate aquí'), findsOneWidget);
    expect(find.text('Usuario'), findsOneWidget);
    expect(find.text('Clave'), findsOneWidget);
  });
}
