import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Aquí podrías inicializar datos predeterminados si lo deseas.
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diario de Entrenamiento',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/startWorkout': (context) => Placeholder(), // Reemplazar con la pantalla de inicio de entrenamiento
        '/templateDetails': (context) => Placeholder(), // Reemplazar con la pantalla de detalle de plantilla
        '/createTemplate': (context) => Placeholder(), // Reemplazar con la pantalla para crear una nueva plantilla
        '/calendar': (context) => Placeholder(), // Reemplazar con la pantalla de calendario
        '/info': (context) => Placeholder(), // Reemplazar con la pantalla de información
      },
    );
  }
}
