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

String getLocalizedCategoryName(BuildContext context, String categoryKey) {
  final l10n = AppLocalizations.of(context)!;
  if (categoryKey.isEmpty) { // Para el caso de "Todas las Categorías"
    return l10n.category_all;
  }
  switch (categoryKey) {
    case 'Chest': return l10n.category_chest;
    case 'Back': return l10n.category_back;
    case 'Legs': return l10n.category_legs;
    case 'Arms': return l10n.category_arms;
    case 'Shoulders': return l10n.category_shoulders;
    case 'Abs': return l10n.category_abs;
    case 'Other': return l10n.category_other;
    default:
    // Fallback si la clave no se reconoce (no debería pasar con claves canónicas)
      debugPrint("Advertencia: Clave de categoría desconocida '$categoryKey' en getLocalizedCategoryName.");
      return categoryKey;
  }
}

String getLocalizedTemplateName(BuildContext context, Map<String, dynamic> templateData) {
  final l10n = AppLocalizations.of(context)!;
  final String? templateKey = templateData['template_key'] as String?;
  final String templateNameFromDb = templateData['name'] as String? ?? "Plantilla Desconocida";

  if (templateKey != null && templateKey.isNotEmpty) {
    switch (templateKey) {
      case 'chest_routine_full': return l10n.predefined_template_chest_routine_full_name;
      case 'back_strong': return l10n.predefined_template_back_strong_name;
      case 'leg_day_basic': return l10n.predefined_template_leg_day_basic_name;
      case 'shoulders_steel': return l10n.predefined_template_shoulders_steel_name;
      case 'arms_toned': return l10n.predefined_template_arms_toned_name;
      default:
      // Si hay una templateKey pero no coincide con ninguna clave ARB (debería ser raro)
        debugPrint("Advertencia: Clave de plantilla predefinida '$templateKey' no encontrada. Mostrando nombre de BD.");
        return templateNameFromDb; // Muestra el nombre de la BD como fallback
    }
  }
  // Para plantillas creadas por el usuario (templateKey es null)
  return templateNameFromDb;
}



