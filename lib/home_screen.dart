import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  // Lista de plantillas de ejemplo. En una app real podrías obtenerlas de la base de datos.
  final List<String> templates = ['Pierna', 'Pecho', 'Espalda', 'Brazos', 'Cardio'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Diario de Entrenamiento'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo de la aplicación (asegúrate de tener la imagen en assets y declarada en pubspec.yaml)
            Image.asset('assets/logo.png', height: 100),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/startWorkout');
              },
              child: Text('Iniciar Entrenamiento'),
            ),
            SizedBox(height: 10),
            Text('Plantillas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            // Mostrar las plantillas en un GridView (2 columnas)
            Expanded(
              child: GridView.builder(
                itemCount: templates.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.5,
                ),
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/templateDetails', arguments: templates[index]);
                    },
                    child: Text(templates[index]),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/createTemplate');
              },
              child: Text('+ Plantilla'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/calendar');
              },
              child: Text('Calendario'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/info');
              },
              child: Text('Información'),
            ),
          ],
        ),
      ),
    );
  }
}
