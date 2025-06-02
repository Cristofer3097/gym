// database_exercise.dart

// No necesitas 'import 'package:sqflite/sqflite.dart';' aquí.
// Puedes eliminar esa línea si solo defines la lista.

const List<Map<String, dynamic>> predefinedExerciseList = [
  // Pecho
  {
    'id': 0, // <--- Nuevo ID
    'name': 'Barbell Bench Press',
    'muscle_group': 'Pecho',
    'image': 'assets/exercises/chest_bench_press.png',
    'description': 'Fundamental exercise for the pectoralis major, anterior deltoids, and triceps.', // <-- EN INGLÉS
  },
  {
    'id': 1, // <--- Nuevo ID
    'name': 'Press de Banca Inclinado con Barra',
    'muscle_group': 'Pecho',
    'image': 'assets/exercises/chest_incline_bench_press.png',
    'description': 'Enfatiza la parte superior (clavicular) del pectoral.',
  },
  {
    'id': 2, // <--- Nuevo ID
    'name': 'Press de Banca Declinado con Barra',
    'muscle_group': 'Pecho',
    'image': 'assets/exercises/chest_decline_bench_press.png',
    'description': 'Enfatiza la parte inferior del pectoral.',
  },
  {
    'id': 3, // <--- Nuevo ID
    'name': 'Press de Banca con Mancuernas',
    'muscle_group': 'Pecho',
    'image': 'assets/exercises/chest_dumbbell_press.png',
    'description': 'Permite mayor rango de movimiento y activación de estabilizadores.',
  },
  {
    'id': 4, // <--- Nuevo ID
    'name': 'Press Inclinado con Mancuernas',
    'muscle_group': 'Pecho',
    'image': 'assets/exercises/chest_incline_dumbbell_press.png',
    'description': 'Mayor activación de la parte superior del pectoral con mancuernas.',
  },
  {
    'id': 5, // <--- Nuevo ID
    'name': 'Aperturas con Mancuernas',
    'muscle_group': 'Pecho',
    'image': 'assets/exercises/chest_dumbbell_flyes.png',
    'description': 'Ejercicio de aislamiento para el pectoral.',
  },
  {
    'id': 6, // <--- Nuevo ID
    'name': 'Flexiones (Push-ups)',
    'muscle_group': 'Pecho',
    'image': 'assets/exercises/chest_push_ups.png',
    'description': 'Ejercicio de peso corporal efectivo para el pecho, hombros y tríceps.',
  },
  {
    'id': 7, // <--- Nuevo ID
    'name': 'Fondos en Paralelas (Dips)',
    'muscle_group': 'Pecho',
    'image': 'assets/exercises/chest_dips.png',
    'description': 'Excelente para la parte inferior del pecho y tríceps. Inclinarse hacia adelante enfoca más el pecho.',
  },
  {
    'id': 8, // <--- Nuevo ID
    'name': 'Cruce de Poleas (Cable Crossover)',
    'muscle_group': 'Pecho',
    'image': 'assets/exercises/chest_cable_crossover.png',
    'description': 'Permite tensión constante y trabajar diferentes ángulos del pectoral.',
  },

  // Espalda
  {
    'id': 9, // <--- Nuevo ID
    'name': 'Dominadas (Pull-ups)',
    'muscle_group': 'Espalda',
    'image': 'assets/exercises/back_pull_ups.png',
    'description': 'Ejercicio compuesto clave para el dorsal ancho y la parte superior de la espalda.',
  },
  {
    'id': 10, // <--- Nuevo ID
    'name': 'Jalón al Pecho (Lat Pulldown)',
    'muscle_group': 'Espalda',
    'image': 'assets/exercises/back_lat_pulldown.png',
    'description': 'Alternativa a las dominadas, trabaja el dorsal ancho.',
  },
  {
    'id': 11, // <--- Nuevo ID
    'name': 'Remo con Barra',
    'muscle_group': 'Espalda',
    'image': 'assets/exercises/back_barbell_row.png',
    'description': 'Desarrolla el grosor de la espalda, trabajando dorsales, romboides y trapecios.',
  },
  {
    'id': 12, // <--- Nuevo ID
    'name': 'Remo con Mancuerna (Dumbbell Row)',
    'muscle_group': 'Espalda',
    'image': 'assets/exercises/back_dumbbell_row.png',
    'description': 'Permite un trabajo unilateral y mayor rango de movimiento.',
  },
  {
    'id': 13, // <--- Nuevo ID
    'name': 'Peso Muerto (Deadlift)',
    'muscle_group': 'Espalda', // También trabaja piernas y glúteos intensamente
    'image': 'assets/exercises/back_deadlift.png',
    'description': 'Ejercicio compuesto que trabaja prácticamente todo el cuerpo, con gran énfasis en la cadena posterior.',
  },
  {
    'id': 14, // <--- Nuevo ID
    'name': 'Remo Sentado en Polea (Seated Cable Row)',
    'muscle_group': 'Espalda',
    'image': 'assets/exercises/back_seated_cable_row.png',
    'description': 'Trabaja la parte media de la espalda.',
  },
  {
    'id': 15, // <--- Nuevo ID
    'name': 'Hiperextensiones (Back Extensions)',
    'muscle_group': 'Espalda', // Principalmente lumbares
    'image': 'assets/exercises/back_hyperextensions.png',
    'description': 'Fortalece la zona lumbar, glúteos e isquiotibiales.',
  },

  // Piernas
  {
    'id': 16, // <--- Nuevo ID
    'name': 'Sentadilla con Barra (Squat)',
    'muscle_group': 'Pierna',
    'image': 'assets/exercises/legs_squat.png',
    'description': 'Ejercicio fundamental para cuádriceps, glúteos e isquiotibiales.',
  },
  {
    'id': 17, // <--- Nuevo ID
    'name': 'Prensa de Piernas (Leg Press)',
    'muscle_group': 'Pierna',
    'image': 'assets/exercises/legs_leg_press.png',
    'description': 'Permite mover grandes pesos y enfocar diferentes áreas de las piernas según la posición de los pies.',
  },
  {
    'id': 18, // <--- Nuevo ID
    'name': 'Extensiones de Cuádriceps (Leg Extensions)',
    'muscle_group': 'Pierna',
    'image': 'assets/exercises/legs_leg_extensions.png',
    'description': 'Ejercicio de aislamiento para los cuádriceps.',
  },
  {
    'id': 19, // <--- Nuevo ID
    'name': 'Curl Femoral Tumbado (Lying Leg Curl)',
    'muscle_group': 'Pierna',
    'image': 'assets/exercises/legs_lying_leg_curl.png',
    'description': 'Ejercicio de aislamiento para los isquiotibiales.',
  },
  {
    'id': 20, // <--- Nuevo ID
    'name': 'Curl Femoral Sentado (Seated Leg Curl)',
    'muscle_group': 'Pierna',
    'image': 'assets/exercises/legs_seated_leg_curl.png',
    'description': 'Alternativa para trabajar los isquiotibiales.',
  },
  {
    'id': 21, // <--- Nuevo ID
    'name': 'Zancadas (Lunges)',
    'muscle_group': 'Pierna',
    'image': 'assets/exercises/legs_lunges.png',
    'description': 'Trabaja cuádriceps, glúteos e isquiotibiales, además de mejorar el equilibrio.',
  },
  {
    'id': 22, // <--- Nuevo ID
    'name': 'Elevación de Talones (Calf Raises)',
    'muscle_group': 'Pierna', // Específicamente pantorrillas
    'image': 'assets/exercises/legs_calf_raises.png',
    'description': 'Desarrolla los músculos de la pantorrilla (gastrocnemio y sóleo).',
  },
  {
    'id': 23, // <--- Nuevo ID
    'name': 'Sentadilla Búlgara (Bulgarian Split Squat)',
    'muscle_group': 'Pierna',
    'image': 'assets/exercises/legs_bulgarian_split_squat.png',
    'description': 'Excelente ejercicio unilateral para cuádriceps y glúteos.',
  },

  // Hombros
  {
    'id': 24, // <--- Nuevo ID
    'name': 'Press Militar con Barra (Overhead Press)',
    'muscle_group': 'Hombros',
    'image': 'assets/exercises/shoulders_overhead_press.png',
    'description': 'Ejercicio compuesto principal para el desarrollo de los deltoides.',
  },
  {
    'id': 25, // <--- Nuevo ID
    'name': 'Press de Hombros con Mancuernas',
    'muscle_group': 'Hombros',
    'image': 'assets/exercises/shoulders_dumbbell_press.png',
    'description': 'Permite un movimiento más natural y mayor activación de estabilizadores.',
  },
  {
    'id': 26, // <--- Nuevo ID
    'name': 'Elevaciones Laterales con Mancuernas',
    'muscle_group': 'Hombros',
    'image': 'assets/exercises/shoulders_lateral_raises.png',
    'description': 'Aísla la cabeza media del deltoides, dando amplitud a los hombros.',
  },
  {
    'id': 27, // <--- Nuevo ID
    'name': 'Elevaciones Frontales con Mancuernas',
    'muscle_group': 'Hombros',
    'image': 'assets/exercises/shoulders_front_raises.png',
    'description': 'Trabaja la cabeza anterior (frontal) del deltoides.',
  },
  {
    'id': 28, // <--- Nuevo ID
    'name': 'Pájaro (Bent-over Dumbbell Raise)',
    'muscle_group': 'Hombros', // También trabaja espalda alta
    'image': 'assets/exercises/shoulders_bent_over_raises.png',
    'description': 'Enfatiza la cabeza posterior del deltoides y los músculos de la espalda alta.',
  },
  {
    'id': 29, // <--- Nuevo ID
    'name': 'Remo al Mentón (Upright Row)',
    'muscle_group': 'Hombros', // También trapecios
    'image': 'assets/exercises/shoulders_upright_row.png',
    'description': 'Trabaja los deltoides laterales y anteriores, así como los trapecios.',
  },

  // Brazos (Bíceps)
  {
    'id': 30, // <--- Nuevo ID
    'name': 'Curl de Bíceps con Barra',
    'muscle_group': 'Brazos',
    'image': 'assets/exercises/arms_barbell_curl.png',
    'description': 'Ejercicio básico para la masa de los bíceps.',
  },
  {
    'id': 31, // <--- Nuevo ID
    'name': 'Curl de Bíceps con Mancuernas',
    'muscle_group': 'Brazos',
    'image': 'assets/exercises/arms_dumbbell_curl.png',
    'description': 'Permite supinación para una mayor activación del bíceps.',
  },
  {
    'id': 32, // <--- Nuevo ID
    'name': 'Curl Martillo (Hammer Curl)',
    'muscle_group': 'Brazos',
    'image': 'assets/exercises/arms_hammer_curl.png',
    'description': 'Trabaja el bíceps braquial y el braquiorradial, dando grosor al brazo.',
  },
  {
    'id': 33, // <--- Nuevo ID
    'name': 'Curl Concentrado',
    'muscle_group': 'Brazos',
    'image': 'assets/exercises/arms_concentration_curl.png',
    'description': 'Ejercicio de aislamiento para el pico del bíceps.',
  },
  {
    'id': 34, // <--- Nuevo ID
    'name': 'Curl en Banco Scott (Preacher Curl)',
    'muscle_group': 'Brazos',
    'image': 'assets/exercises/arms_preacher_curl.png',
    'description': 'Aísla el bíceps al evitar el balanceo del cuerpo.',
  },

  // Brazos (Tríceps)
  {
    'id': 35, // <--- Nuevo ID
    'name': 'Press Francés (Skullcrusher)',
    'muscle_group': 'Brazos',
    'image': 'assets/exercises/arms_skullcrusher.png',
    'description': 'Excelente para la masa del tríceps, especialmente la cabeza larga.',
  },
  {
    'id': 36, // <--- Nuevo ID
    'name': 'Extensiones de Tríceps en Polea Alta',
    'muscle_group': 'Brazos',
    'image': 'assets/exercises/arms_tricep_pulldown.png',
    'description': 'Ejercicio popular para trabajar todas las cabezas del tríceps.',
  },
  {
    'id': 37, // <--- Nuevo ID
    'name': 'Fondos entre Bancos',
    'muscle_group': 'Brazos',
    'image': 'assets/exercises/arms_bench_dips.png',
    'description': 'Ejercicio de peso corporal para tríceps.',
  },
  {
    'id': 38, // <--- Nuevo ID
    'name': 'Press Cerrado (Close-grip Bench Press)',
    'muscle_group': 'Brazos', // También Pecho
    'image': 'assets/exercises/arms_close_grip_bench_press.png',
    'description': 'Variante del press de banca que enfatiza el trabajo de los tríceps.',
  },
  {
    'id': 39, // <--- Nuevo ID
    'name': 'Patada de Tríceps (Tricep Kickback)',
    'muscle_group': 'Brazos',
    'image': 'assets/exercises/arms_tricep_kickback.png',
    'description': 'Ejercicio de aislamiento para la cabeza lateral del tríceps.',
  },

  // Abdomen
  {
    'id': 40, // <--- Nuevo ID
    'name': 'Encogimientos (Crunches)',
    'muscle_group': 'Abdomen',
    'image': 'assets/exercises/abs_crunches.png',
    'description': 'Ejercicio básico para la parte superior del abdomen.',
  },
  {
    'id': 41, // <--- Nuevo ID
    'name': 'Elevaciones de Piernas (Leg Raises)',
    'muscle_group': 'Abdomen',
    'image': 'assets/exercises/abs_leg_raises.png',
    'description': 'Enfatiza la parte inferior del abdomen.',
  },
  {
    'id': 42, // <--- Nuevo ID
    'name': 'Plancha Abdominal (Plank)',
    'muscle_group': 'Abdomen',
    'image': 'assets/exercises/abs_plank.png',
    'description': 'Ejercicio isométrico para fortalecer todo el core.',
  },
  {
    'id': 43, // <--- Nuevo ID
    'name': 'Rueda Abdominal (Ab Wheel Rollout)',
    'muscle_group': 'Abdomen',
    'image': 'assets/exercises/abs_ab_wheel.png',
    'description': 'Ejercicio avanzado para un core fuerte y definido.',
  },
  {
    'id': 44, // <--- Nuevo ID
    'name': 'Encogimientos en Polea Alta (Cable Crunch)',
    'muscle_group': 'Abdomen',
    'image': 'assets/exercises/abs_cable_crunch.png',
    'description': 'Permite añadir resistencia progresiva a los encogimientos.',
  },

  // Continúa añadiendo IDs únicos a todos tus ejercicios...
];

const List<Map<String, dynamic>> predefinedTemplatesData = [
  {
    'templateName': 'Rutina de Pecho Completa',
    'exerciseSourceIds': [0, 1, 4, 5, 8], // IDs de predefinedExerciseList
    // (Press de Banca, Press Inclinado Barra, Press Inclinado Manc, Aperturas, Cruce Poleas)
  },
  {
    'templateName': 'Espalda Fuerte',
    'exerciseSourceIds': [9, 11, 12, 14], // (Dominadas, Remo Barra, Remo Mancuerna, Remo Sentado)
  },
  {
    'templateName': 'Día de Pierna Básico',
    'exerciseSourceIds': [16, 17, 19, 22], // (Sentadilla, Prensa, Curl Femoral Tumbado, Elev. Talones)
  },
  // Puedes añadir más plantillas aquí si lo deseas
  {
    'templateName': 'Hombros de Acero',
    'exerciseSourceIds': [24, 25, 26, 28], // Ejemplo: Press Militar, Press Mancuerna, Elev. Laterales, Pájaro
  },
  {
    'templateName': 'Brazos Tonificados',
    'exerciseSourceIds': [30, 31, 35, 36], // Ejemplo: Curl Barra, Curl Mancuerna, Press Francés, Ext. Polea
  },
];