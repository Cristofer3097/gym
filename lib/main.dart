import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'training_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
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
    } catch (_) {
      // Ignora el error si no existe el archivo aún
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
        title: const Text('Diario de Entrenamiento'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset('assets/logo.png', height: 100),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TrainingScreen()),
              ),
              child: const Text('Iniciar Entrenamiento'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 10),
            const Text('Plantillas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 2.5,
                ),
                itemCount: templates.length,
                itemBuilder: (context, index) => ElevatedButton(
                  onPressed: () {}, // Para detalles de plantilla en el futuro
                  child: Text(templates[index]['name']),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _addTemplate('Nueva Plantilla'),
              child: const Text('+ Plantilla'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {}, // Para funcionalidad de calendario en el futuro
              child: const Text('Calendario'),
            ),
          ],
        ),
      ),
    );
  }
}