import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Asegúrate que la ruta sea correcta

String getLocalizedExerciseName(BuildContext context, Map<String, dynamic> exercise) {
  final l10n = AppLocalizations.of(context)!;
  // Verifica si es predefinido y tiene un original_id
  if (exercise['is_predefined'] == 1 && exercise['original_id'] != null) {
    int originalId = exercise['original_id'] as int;
    switch (originalId) {
      case 0: return l10n.exercise_0_name;

      //case 1: return l10n.exercise_1_name;
      //case 2: return l10n.exercise_2_name;
    // ... Continúa con todos tus IDs hasta 44 ...
      //case 44: return l10n.exercise_44_name;
      default:
      // Fallback al nombre almacenado en la BD si el ID no está en el switch
        debugPrint("Advertencia: ID de ejercicio predefinido '$originalId' no encontrado en getLocalizedExerciseName. Usando nombre de BD.");
        return exercise['name']?.toString() ?? "Unknown Exercise";
    }
  }
  // Para ejercicios manuales o si falta información para localizar
  return exercise['name']?.toString() ?? "Exercise";
}

String getLocalizedExerciseDescription(BuildContext context, Map<String, dynamic> exercise) {
  final l10n = AppLocalizations.of(context)!;
  if (exercise['is_predefined'] == 1 && exercise['original_id'] != null) {
    int originalId = exercise['original_id'] as int;
    switch (originalId) {
      case 0: return l10n.exercise_0_description;
      //case 1: return l10n.exercise_1_description;
      //case 2: return l10n.exercise_2_description;
    // ... Continúa con todos tus IDs hasta 44 ...
      //case 44: return l10n.exercise_44_description;
      default:
        debugPrint("Advertencia: ID de ejercicio predefinido '$originalId' no encontrado en getLocalizedExerciseDescription. Usando descripción de BD.");
        return exercise['description']?.toString() ?? "";
    }
  }
  return exercise['description']?.toString() ?? "";
}