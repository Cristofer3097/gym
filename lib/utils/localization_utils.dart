import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Asegúrate que la ruta sea correcta

String getLocalizedExerciseName(BuildContext context, Map<String, dynamic> exercise) {
  final l10n = AppLocalizations.of(context)!;
  // Verifica si es predefinido y tiene un original_id
  if (exercise['is_predefined'] == 1 && exercise['original_id'] != null) {
    int originalId = exercise['original_id'] as int;
    switch (originalId) {
      case 0: return l10n.exercise_0_name;
      case 1: return l10n.exercise_1_name;
      case 2: return l10n.exercise_2_name;
      case 3: return l10n.exercise_3_name;
      case 4: return l10n.exercise_4_name;
      case 5: return l10n.exercise_5_name;
      case 6: return l10n.exercise_6_name;
      case 7: return l10n.exercise_7_name;
      case 8: return l10n.exercise_8_name;
      case 9: return l10n.exercise_9_name;
      case 10: return l10n.exercise_10_name;
      case 11: return l10n.exercise_11_name;
      case 12: return l10n.exercise_12_name;
      case 13: return l10n.exercise_13_name;
      case 14: return l10n.exercise_14_name;
      case 15: return l10n.exercise_15_name;
      case 16: return l10n.exercise_16_name;
      case 17: return l10n.exercise_17_name;
      case 18: return l10n.exercise_18_name;
      case 19: return l10n.exercise_19_name;
      case 20: return l10n.exercise_20_name;
      case 21: return l10n.exercise_21_name;
      case 22: return l10n.exercise_22_name;
      case 23: return l10n.exercise_23_name;
      case 24: return l10n.exercise_24_name;
      case 25: return l10n.exercise_25_name;
      case 26: return l10n.exercise_26_name;
      case 27: return l10n.exercise_27_name;
      case 28: return l10n.exercise_28_name;
      case 29: return l10n.exercise_29_name;
      case 30: return l10n.exercise_30_name;
      case 31: return l10n.exercise_31_name;
      case 32: return l10n.exercise_32_name;
      case 33: return l10n.exercise_33_name;
      case 34: return l10n.exercise_34_name;
      case 35: return l10n.exercise_35_name;
      case 36: return l10n.exercise_36_name;
      case 37: return l10n.exercise_37_name;
      case 38: return l10n.exercise_38_name;
      case 39: return l10n.exercise_39_name;
      case 40: return l10n.exercise_40_name;
      case 41: return l10n.exercise_41_name;
      case 42: return l10n.exercise_42_name;
      case 43: return l10n.exercise_21_name;
      case 44: return l10n.exercise_22_name;
      case 45: return l10n.exercise_23_name;
      case 46: return l10n.exercise_24_name;
      case 47: return l10n.exercise_25_name;
      case 48: return l10n.exercise_26_name;
      case 49: return l10n.exercise_27_name;
      case 50: return l10n.exercise_28_name;
      case 51: return l10n.exercise_29_name;
      case 52: return l10n.exercise_30_name;
      case 53: return l10n.exercise_31_name;
      case 54: return l10n.exercise_32_name;
      case 55: return l10n.exercise_33_name;
      case 56: return l10n.exercise_34_name;
      case 57: return l10n.exercise_35_name;
      case 58: return l10n.exercise_36_name;
      case 59: return l10n.exercise_37_name;
      case 60: return l10n.exercise_38_name;


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
      case 1: return l10n.exercise_1_description;
      case 2: return l10n.exercise_2_description;
      case 3: return l10n.exercise_3_description;
      case 4: return l10n.exercise_4_description;
      case 5: return l10n.exercise_5_description;
      case 6: return l10n.exercise_6_description;
      case 7: return l10n.exercise_7_description;
      case 8: return l10n.exercise_8_description;
      case 9: return l10n.exercise_9_description;
      case 10: return l10n.exercise_10_description;
      case 11: return l10n.exercise_11_description;
      case 12: return l10n.exercise_12_description;
      case 13: return l10n.exercise_13_description;
      case 14: return l10n.exercise_14_description;
      case 15: return l10n.exercise_15_description;
      case 16: return l10n.exercise_16_description;
      case 17: return l10n.exercise_17_description;
      case 18: return l10n.exercise_18_description;
      case 19: return l10n.exercise_19_description;
      case 20: return l10n.exercise_20_description;
      case 21: return l10n.exercise_21_description;
      case 22: return l10n.exercise_22_description;
      case 23: return l10n.exercise_23_description;
      case 24: return l10n.exercise_24_description;
      case 25: return l10n.exercise_25_description;
      case 26: return l10n.exercise_26_description;
      case 27: return l10n.exercise_27_description;
      case 28: return l10n.exercise_28_description;
      case 29: return l10n.exercise_29_description;
      case 30: return l10n.exercise_30_description;
      case 31: return l10n.exercise_31_description;
      case 32: return l10n.exercise_32_description;
      case 33: return l10n.exercise_33_description;
      case 34: return l10n.exercise_34_description;
      case 35: return l10n.exercise_35_description;
      case 36: return l10n.exercise_36_description;
      case 37: return l10n.exercise_37_description;
      case 38: return l10n.exercise_38_description;
      case 39: return l10n.exercise_39_description;
      case 40: return l10n.exercise_40_description;
      case 41: return l10n.exercise_41_description;
      case 42: return l10n.exercise_42_description;
      case 44: return l10n.exercise_43_description;
      case 45: return l10n.exercise_26_description;
      case 46: return l10n.exercise_27_description;
      case 47: return l10n.exercise_28_description;
      case 48: return l10n.exercise_29_description;
      case 49: return l10n.exercise_30_description;
      case 50: return l10n.exercise_31_description;
      case 51: return l10n.exercise_32_description;
      case 52: return l10n.exercise_33_description;
      case 53: return l10n.exercise_34_description;
      case 54: return l10n.exercise_35_description;
      case 55: return l10n.exercise_36_description;
      case 56: return l10n.exercise_37_description;
      case 57: return l10n.exercise_38_description;
      case 58: return l10n.exercise_39_description;
      case 59: return l10n.exercise_40_description;
      case 60: return l10n.exercise_41_description;

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
    case 'Biceps': return l10n.category_Biceps;
    case 'Triceps': return l10n.category_Triceps;
    case 'Shoulders': return l10n.category_shoulders;
    case 'Glutes': return l10n.category_glutes;
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



