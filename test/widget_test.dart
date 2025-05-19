import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym/main.dart'; // Asegúrate de que esta ruta sea correcta

void main() {
  testWidgets('Prueba que HomeScreen muestra los elementos correctos', (WidgetTester tester) async {
    // 1. Construye el widget con MaterialApp (necesario para navegación)
    await tester.pumpWidget(
      MaterialApp(
        home: MyApp (),
      ),
    );

    // 2. Verifica que el título aparece
    expect(find.text('Diario de Entrenamiento'), findsOneWidget);

    // 3. Verifica que los botones principales existen
    expect(find.text('Iniciar Entrenamiento'), findsOneWidget);
    expect(find.text('Plantillas'), findsOneWidget);
    expect(find.text('+ Plantilla'), findsOneWidget);
    expect(find.text('Calendario'), findsOneWidget);
    expect(find.text('Información'), findsOneWidget);

    // 4. Opcional: Verifica que la imagen existe
    expect(find.byType(Image), findsOneWidget);
  });
}