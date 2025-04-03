import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> templates = [];

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/templates.json');
  }

  Future<void> _loadTemplates() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        setState(() {
          templates = List<Map<String, dynamic>>.from(json.decode(contents));
        });
      }
    } catch (e) {
      print("Error al cargar plantillas: $e");
    }
  }

  Future<void> _saveTemplates() async {
    final file = await _localFile;
    await file.writeAsString(json.encode(templates));
  }

  void _addTemplate(String name) {
    setState(() {
      templates.add({'name': name, 'exercises': []});
      _saveTemplates();
    });
  }

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
          children: [
            Image.asset('assets/logo.png', height: 100),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {}, // Navegar a entrenamientos
              child: Text('Iniciar Entrenamiento'),
            ),
            SizedBox(height: 10),
            Text('Plantillas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.5,
                ),
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    onPressed: () {}, // Navegar a detalles
                    child: Text(templates[index]['name']),
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _addTemplate('Nueva Plantilla');
              },
              child: Text('+ Plantilla'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: Text('Calendario'),
            ),
          ],
        ),
      ),
    );
  }
}
