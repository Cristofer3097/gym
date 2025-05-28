// lib/rm_calculator_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para input formatters

class RMCalculatorDialog extends StatefulWidget {
  const RMCalculatorDialog({Key? key}) : super(key: key);

  @override
  _RMCalculatorDialogState createState() => _RMCalculatorDialogState();
}

class _RMCalculatorDialogState extends State<RMCalculatorDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();

  String _selectedUnit = 'kg'; // 'kg' o 'lb'
  double? _calculated1RM;
  List<Map<String, String>> _rmTableData = [];

  // Fórmula de Epley (según lo proporcionado)
  // 1RM = peso / [1.0278 – (0.0278 * reps)]
  static const double _epleyConst1 = 1.0278;
  static const double _epleyConst2 = 0.0278;

  @override
  void initState() {
    super.initState();
    _weightController.addListener(_calculateRM);
    _repsController.addListener(_calculateRM);
  }

  @override
  void dispose() {
    _weightController.removeListener(_calculateRM);
    _repsController.removeListener(_calculateRM);
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _calculateRM() {
    if (mounted && _formKey.currentState != null && !_formKey.currentState!.validate()) {
      setState(() {
        _calculated1RM = null;
        _rmTableData = [];
      });
      return;
    }

    final double? weight = double.tryParse(_weightController.text.trim().replaceAll(',', '.'));
    final int? reps = int.tryParse(_repsController.text.trim());

    if (weight == null || weight <= 0 || reps == null || reps <= 0) {
      if (mounted) { // Añadido mounted check
        setState(() {
          _calculated1RM = null;
          _rmTableData = [];
        });
      }
      return;
    }
    double oneRM;
    if (reps == 1) {
      oneRM = weight;
    } else {
      double denominator = _epleyConst1 - (_epleyConst2 * reps);
      if (denominator <= 0) {
        if (mounted) { // Añadido mounted check
          setState(() {
            _calculated1RM = null;
            _rmTableData = [];
          });
        }
        return;
      }
      oneRM = weight / denominator;
    }

    List<Map<String, String>> tableData = [];
    // RMs a mostrar, basados en la imagen de ejemplo
    List<int> rMsToDisplayInGrid  = [
      1, 2, 3, 4,    // Fila 1
      5, 6, 7, 8,    // Fila 2 (5RM añadido)
      9, 10, 11, 12 // Fila 3 (placeholder para 9RM en la primera columna)
    ];

    for (int x_val in rMsToDisplayInGrid) { // x_val ahora es int, no int?
      // Ya no necesitamos la condición 'if (x_val == null)'
      double xRMValue;
      if (x_val == 1) {
        xRMValue = oneRM;
      } else {
        double factor = _epleyConst1 - (_epleyConst2 * x_val);
        if (factor <= 0) factor = 0.01;
        xRMValue = oneRM * factor;
      }
      tableData.add({
        'rm': '${x_val}RM',
        'value': xRMValue.toStringAsFixed(0),
      });
    }

    if (mounted) { // Añadido mounted check
      setState(() {
        _calculated1RM = oneRM;
        _rmTableData = tableData;
      });
    }
  }

  Widget _buildRMCell(String rmLabel, String value, Color primaryColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          rmLabel,
          style: TextStyle(
            color: primaryColor, // Amarillo
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _calculated1RM != null ? value : '-',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22, // Tamaño grande para el valor
            color: Colors.white,
          ),
        ),
        Text(
          _selectedUnit,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color amarilloPrincipal = theme.primaryColor; // Usar el color primario del tema

    return AlertDialog(
      title: const Text('Calculadora de RM', textAlign: TextAlign.center),
      contentPadding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0.0),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0, top: 0), // Ajusta el padding si es necesario
                child: Text(
                  "Esto no es preciso y puede generarte ciertos errores.",
                  style: TextStyle(
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[500], // Un color sutil para la advertencia
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        labelText: 'Peso',
                        hintText: 'Ej: 100',
                        suffixText: _selectedUnit,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*([.,])?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Requerido';
                        }
                        if (double.tryParse(value.trim().replaceAll(',', '.')) == null ||
                            double.parse(value.trim().replaceAll(',', '.')) <= 0) {
                          return 'Inválido (>0)';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),

                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _repsController,
                decoration: const InputDecoration(
                  labelText: 'Repeticiones',
                  hintText: 'Ej: 5',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Requerido';
                  }
                  final int? reps = int.tryParse(value.trim());
                  if (reps == null || reps <= 0) {
                    return 'Inválido (>0)';
                  }
                  if (reps > 24) { // Límite práctico para la fórmula
                    return 'Máx 24';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_calculated1RM != null && _rmTableData.length == 12)
                Column(
                  children: [
                    // Fila 1 (1RM, 2RM, 3RM, 4RM)
                    Row(
                      children: _rmTableData.sublist(0, 4).map((data) {
                        return Expanded(
                          child: data['rm'] == 'placeholder'
                              ? Container() // Celda vacía
                              : _buildRMCell(data['rm']!, data['value']!, amarilloPrincipal),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16), // Espacio entre filas

                    // Fila 2 (Placeholder, 6RM, 7RM, 8RM)
                    Row(
                      children: _rmTableData.sublist(4, 8).map((data) {
                        return Expanded(
                          child: data['rm'] == 'placeholder'
                              ? Container() // Celda vacía
                              : _buildRMCell(data['rm']!, data['value']!, amarilloPrincipal),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16), // Espacio entre filas

                    // Fila 3 (Placeholder, 10RM, 11RM, 12RM)
                    Row(
                      children: _rmTableData.sublist(8, 12).map((data) {
                        return Expanded(
                          child: data['rm'] == 'placeholder'
                              ? Container() // Celda vacía
                              : _buildRMCell(data['rm']!, data['value']!, amarilloPrincipal),
                        );
                      }).toList(),
                    ),
                  ],
                )
              else if (_weightController.text.isNotEmpty && _repsController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Text(
                    _formKey.currentState?.validate() == false ? "Por favor, corrige los errores." : "Ingresa valores válidos para calcular.",
                    style: TextStyle(fontStyle: FontStyle.italic, color: _formKey.currentState?.validate() == false ? theme.colorScheme.error : Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cerrar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}