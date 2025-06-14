const List<Map<String, dynamic>> predefinedExerciseList = [
  // Pecho
  {
    'id': 0, // <--- Nuevo ID
    'name': 'Bench Press',
    'muscle_group': 'Chest',
    'image': 'assets/exercises/bench_press.gif',
    'description': 'The Bench Press is a classic strength training exercise that primarily targets the chest, shoulders, and triceps, contributing to upper body muscle development. It is suitable for anyone, from beginners to professional athletes, looking to improve their upper body strength and muscular endurance. Individuals may want to incorporate bench press into their routine for its effectiveness in enhancing physical performance, promoting bone health, and improving body composition.', // <-- EN INGLÉS
  },
  {
    'id': 1, // <--- Nuevo ID
    'name': 'Dumbbell bench press',
    'muscle_group': 'Chest',
    'image': 'assets/exercises/Dumbbell_bench_press.gif',
    'description': 'The Dumbbell Bench Press is a versatile strength-training exercise that primarily targets the chest, while also engaging the shoulders and triceps. It is suitable for both beginners and advanced fitness enthusiasts as it can be easily modified to match individual strength levels and goals. People might opt for this exercise as it promotes muscle growth, improves upper body strength, and offers better range of motion compared to a barbell bench press.',
  },
  {
    'id': 2, // <--- Nuevo ID
    'name': 'Smith Bench Press',
    'muscle_group': 'Chest',
    'image': 'assets/exercises/Smith_bench_press.png',
    'description': 'The Smith Bench Press is a strength-training exercise that primarily targets the chest muscles, while also engaging the shoulders and triceps. The Smith machine provides stability, allowing for controlled movements and focus on form. One would want to perform this exercise to build upper body strength, enhance muscle definition, and improve overall athletic performance.',
  },
  {
    'id': 3, // <--- Nuevo ID
    'name': 'Dumbbell Fly',
    'muscle_group': 'Chest',
    'image': 'assets/exercises/Dumbbell_Flyes.gif',
    'description': 'The Dumbbell Fly is a strength training exercise targeting the chest muscles, specifically the pectoralis major, and secondary muscles like the shoulders and biceps. This exercise is beneficial for those looking to enhance their upper body strength, improve muscle definition, and promote better posture.',
  },
  {
    'id': 4, // <--- Nuevo ID
    'name': 'Lever Seated Fly',
    'muscle_group': 'Chest',
    'image': 'assets/exercises/Lever_Seated_Fly.gif',
    'description': 'The Lever Seated Fly is a strength training exercise primarily targeting the chest muscles, while also engaging the shoulders and arms. The exercise is beneficial for enhancing muscle definition, improving posture, and boosting upper body strength, making it an ideal choice for those looking to increase their functional fitness or sculpt their physique.',
  },
  {
    'id': 5, // <--- Nuevo ID
    'name': 'Incline Bench Press',
    'muscle_group': 'Chest',
    'image': 'assets/exercises/Press_Incline_Bench_Press.gif',
    'description': 'The Incline Bench Press is a strength-training exercise that primarily targets the upper portion of the chest muscles, while also engaging the shoulders and triceps. Suitable for anyone looking to enhance upper body strength and improve muscle definition, particularly in the chest area. ',
  },
  {
    'id': 6, // <--- Nuevo ID
    'name': 'Dumbbel Incline Bench Press',
    'muscle_group': 'Chest',
    'image': 'assets/exercises/Dumbbel_Incline_Bench_Press.png',
    'description': 'The Dumbbell Incline Bench Press is a highly effective exercise primarily targeting the upper chest muscles, but also working the shoulders and triceps. Individuals may want to incorporate this exercise into their routine as it allows for a greater range of motion compared to the barbell version, promoting better muscle activation and growth.',
  },
  {
    'id': 7, // <--- Nuevo ID
    'name': 'Lever Chest Press',
    'muscle_group': 'Chest',
    'image': 'assets/exercises/Lever_Chest_Press.gif',
    'description': 'The Lever Chest Press is a strength-building exercise that primarily targets the pectoral muscles, but also works the triceps and anterior deltoids. It is an excellent workout for both beginners and advanced fitness enthusiasts due to its adjustable resistance and controlled movement. People may choose this exercise for its ability to enhance upper body strength, improve muscle tone, and assist in the development of a more defined chest.',
  },
  {
    'id': 8, // <--- Nuevo ID
    'name': 'Chest Dip',
    'muscle_group': 'Chest',
    'image': 'assets/exercises/chest_dips.gif',
    'description': 'The Chest Dip is a powerful exercise that primarily targets the pectoralis muscles, triceps, and the front shoulders, helping to build strength and definition in these areas. It is suitable for individuals at an intermediate or advanced fitness level who are aiming to enhance their upper body strength and muscular endurance.',
  },
  {
    'id': 9, // <--- Nuevo ID
    'name': 'Smith Incline Bench Press',
    'muscle_group': "Chest",
    'image': 'assets/exercises/Smith_Incline_Bench_Press.png',
    'description': 'The Smith Incline Bench Press is a strength-building exercise that primarily targets your upper chest, shoulders, and triceps, while also engaging other supporting muscles. Suitable for both beginners and advanced athletes due to the controlled movement of the Smith machine, which can help prevent injury and ensure correct form.',
  },
  // Espalda
  {
    'id': 10, // <--- Nuevo ID
    'name': 'Pulldown',
    'muscle_group': 'Back',
    'image': 'assets/exercises/Pulldown.gif',
    'description': 'The Cable Pulldown is a popular strength training exercise that primarily targets the muscles in your back, specifically the latissimus dorsi, but also works your shoulders and arms. This exercise is ideal for both beginners and advanced fitness enthusiasts, as the weight can be easily adjusted to match individual strength levels. Incorporating Cable Pulldowns into your workout routine can help improve upper body strength, promote better posture, and enhance muscle definition.',
  },
  {
    'id': 11, // <--- Nuevo ID
    'name': 'Pulldown with V-bar',
    'muscle_group': "Back",
    'image': 'assets/exercises/Pulldown_with_V-bar.gif',
    'description': 'Pulldown with V-bar is a highly effective exercise that targets and strengthens the muscles in your back, shoulders, and arms, particularly the latissimus dorsi.',
  },
  {
    'id': 12, // <--- Nuevo ID
    'name': 'Remo con Mancuerna (Dumbbell Row)',
    'muscle_group': "Back",
    'image': 'assets/exercises/back_dumbbell_row.png',
    'description': 'Permite un trabajo unilateral y mayor rango de movimiento.',
  },
  {
    'id': 13, // <--- Nuevo ID
    'name': 'Peso Muerto (Deadlift)',
    'muscle_group': "Back", // También trabaja piernas y glúteos intensamente
    'image': 'assets/exercises/back_deadlift.png',
    'description': 'Ejercicio compuesto que trabaja prácticamente todo el cuerpo, con gran énfasis en la cadena posterior.',
  },
  {
    'id': 14, // <--- Nuevo ID
    'name': 'Remo Sentado en Polea (Seated Cable Row)',
    'muscle_group': "Back",
    'image': 'assets/exercises/back_seated_cable_row.png',
    'description': 'Trabaja la parte media de la espalda.',
  },
  {
    'id': 15, // <--- Nuevo ID
    'name': 'Hiperextensiones (Back Extensions)',
    'muscle_group': "Back", // Principalmente lumbares
    'image': 'assets/exercises/back_hyperextensions.png',
    'description': 'Fortalece la zona lumbar, glúteos e isquiotibiales.',
  },

  // Piernas
  {
    'id': 16, // <--- Nuevo ID
    'name': 'Sentadilla con Barra (Squat)',
    'muscle_group': "Legs",
    'image': 'assets/exercises/legs_squat.png',
    'description': 'Ejercicio fundamental para cuádriceps, glúteos e isquiotibiales.',
  },
  {
    'id': 17, // <--- Nuevo ID
    'name': 'Prensa de Piernas (Leg Press)',
    'muscle_group': "Legs",
    'image': 'assets/exercises/legs_leg_press.png',
    'description': 'Permite mover grandes pesos y enfocar diferentes áreas de las piernas según la posición de los pies.',
  },
  {
    'id': 18, // <--- Nuevo ID
    'name': 'Extensiones de Cuádriceps (Leg Extensions)',
    'muscle_group': "Legs",
    'image': 'assets/exercises/legs_leg_extensions.png',
    'description': 'Ejercicio de aislamiento para los cuádriceps.',
  },
  {
    'id': 19, // <--- Nuevo ID
    'name': 'Curl Femoral Tumbado (Lying Leg Curl)',
    'muscle_group': "Legs",
    'image': 'assets/exercises/legs_lying_leg_curl.png',
    'description': 'Ejercicio de aislamiento para los isquiotibiales.',
  },
  {
    'id': 20, // <--- Nuevo ID
    'name': 'Curl Femoral Sentado (Seated Leg Curl)',
    'muscle_group': "Legs",
    'image': 'assets/exercises/legs_seated_leg_curl.png',
    'description': 'Alternativa para trabajar los isquiotibiales.',
  },
  {
    'id': 21, // <--- Nuevo ID
    'name': 'Zancadas (Lunges)',
    'muscle_group': "Legs",
    'image': 'assets/exercises/legs_lunges.png',
    'description': 'Trabaja cuádriceps, glúteos e isquiotibiales, además de mejorar el equilibrio.',
  },
  {
    'id': 22, // <--- Nuevo ID
    'name': 'Elevación de Talones (Calf Raises)',
    'muscle_group': "Legs", // Específicamente pantorrillas
    'image': 'assets/exercises/legs_calf_raises.png',
    'description': 'Desarrolla los músculos de la pantorrilla (gastrocnemio y sóleo).',
  },
  {
    'id': 23, // <--- Nuevo ID
    'name': 'Sentadilla Búlgara (Bulgarian Split Squat)',
    'muscle_group': "Legs",
    'image': 'assets/exercises/legs_bulgarian_split_squat.png',
    'description': 'Excelente ejercicio unilateral para cuádriceps y glúteos.',
  },

  // Hombros
  {
    'id': 24, // <--- Nuevo ID
    'name': 'Press Militar con Barra (Overhead Press)',
    'muscle_group': "Shoulders",
    'image': 'assets/exercises/shoulders_overhead_press.png',
    'description': 'Ejercicio compuesto principal para el desarrollo de los deltoides.',
  },
  {
    'id': 25, // <--- Nuevo ID
    'name': 'Press de Hombros con Mancuernas',
    'muscle_group': "Shoulders",
    'image': 'assets/exercises/shoulders_dumbbell_press.png',
    'description': 'Permite un movimiento más natural y mayor activación de estabilizadores.',
  },
  {
    'id': 26, // <--- Nuevo ID
    'name': 'Elevaciones Laterales con Mancuernas',
    'muscle_group': "Shoulders",
    'image': 'assets/exercises/shoulders_lateral_raises.png',
    'description': 'Aísla la cabeza media del deltoides, dando amplitud a los hombros.',
  },
  {
    'id': 27, // <--- Nuevo ID
    'name': 'Elevaciones Frontales con Mancuernas',
    'muscle_group': "Shoulders",
    'image': 'assets/exercises/shoulders_front_raises.png',
    'description': 'Trabaja la cabeza anterior (frontal) del deltoides.',
  },
  {
    'id': 28, // <--- Nuevo ID
    'name': 'Pájaro (Bent-over Dumbbell Raise)',
    'muscle_group': "Shoulders", // También trabaja espalda alta
    'image': 'assets/exercises/shoulders_bent_over_raises.png',
    'description': 'Enfatiza la cabeza posterior del deltoides y los músculos de la espalda alta.',
  },
  {
    'id': 29, // <--- Nuevo ID
    'name': 'Remo al Mentón (Upright Row)',
    'muscle_group': "Shoulders", // También trapecios
    'image': 'assets/exercises/shoulders_upright_row.png',
    'description': 'Trabaja los deltoides laterales y anteriores, así como los trapecios.',
  },

  // Brazos (Bíceps)
  {
    'id': 30, // <--- Nuevo ID
    'name': 'Curl de Bíceps con Barra',
    'muscle_group': "Arms",
    'image': 'assets/exercises/arms_barbell_curl.png',
    'description': 'Ejercicio básico para la masa de los bíceps.',
  },
  {
    'id': 31, // <--- Nuevo ID
    'name': 'Curl de Bíceps con Mancuernas',
    'muscle_group': "Arms",
    'image': 'assets/exercises/arms_dumbbell_curl.png',
    'description': 'Permite supinación para una mayor activación del bíceps.',
  },
  {
    'id': 32, // <--- Nuevo ID
    'name': 'Curl Martillo (Hammer Curl)',
    'muscle_group': "Arms",
    'image': 'assets/exercises/arms_hammer_curl.png',
    'description': 'Trabaja el bíceps braquial y el braquiorradial, dando grosor al brazo.',
  },
  {
    'id': 33, // <--- Nuevo ID
    'name': 'Curl Concentrado',
    'muscle_group': "Arms",
    'image': 'assets/exercises/arms_concentration_curl.png',
    'description': 'Ejercicio de aislamiento para el pico del bíceps.',
  },
  {
    'id': 34, // <--- Nuevo ID
    'name': 'Curl en Banco Scott (Preacher Curl)',
    'muscle_group': "Arms",
    'image': 'assets/exercises/arms_preacher_curl.png',
    'description': 'Aísla el bíceps al evitar el balanceo del cuerpo.',
  },

  // Brazos (Tríceps)
  {
    'id': 35, // <--- Nuevo ID
    'name': 'Press Francés (Skullcrusher)',
    'muscle_group': "Arms",
    'image': 'assets/exercises/arms_skullcrusher.png',
    'description': 'Excelente para la masa del tríceps, especialmente la cabeza larga.',
  },
  {
    'id': 36, // <--- Nuevo ID
    'name': 'Extensiones de Tríceps en Polea Alta',
    'muscle_group': "Arms",
    'image': 'assets/exercises/arms_tricep_pulldown.png',
    'description': 'Ejercicio popular para trabajar todas las cabezas del tríceps.',
  },
  {
    'id': 37, // <--- Nuevo ID
    'name': 'Fondos entre Bancos',
    'muscle_group': "Arms",
    'image': 'assets/exercises/arms_bench_dips.png',
    'description': 'Ejercicio de peso corporal para tríceps.',
  },
  {
    'id': 38, // <--- Nuevo ID
    'name': 'Press Cerrado (Close-grip Bench Press)',
    'muscle_group': "Arms", // También Pecho
    'image': 'assets/exercises/arms_close_grip_bench_press.png',
    'description': 'Variante del press de banca que enfatiza el trabajo de los tríceps.',
  },
  {
    'id': 39, // <--- Nuevo ID
    'name': 'Patada de Tríceps (Tricep Kickback)',
    'muscle_group': "Arms",
    'image': 'assets/exercises/arms_tricep_kickback.png',
    'description': 'Ejercicio de aislamiento para la cabeza lateral del tríceps.',
  },

  // Abdomen
  {
    'id': 40, // <--- Nuevo ID
    'name': 'Encogimientos (Crunches)',
    'muscle_group': "Abs",
    'image': 'assets/exercises/abs_crunches.png',
    'description': 'Ejercicio básico para la parte superior del abdomen.',
  },
  {
    'id': 41, // <--- Nuevo ID
    'name': 'Elevaciones de Piernas (Leg Raises)',
    'muscle_group': "Abs",
    'image': 'assets/exercises/abs_leg_raises.png',
    'description': 'Enfatiza la parte inferior del abdomen.',
  },
  {
    'id': 42, // <--- Nuevo ID
    'name': 'Plancha Abdominal (Plank)',
    'muscle_group': "Abs",
    'image': 'assets/exercises/abs_plank.png',
    'description': 'Ejercicio isométrico para fortalecer todo el core.',
  },
  {
    'id': 43, // <--- Nuevo ID
    'name': 'Rueda Abdominal (Ab Wheel Rollout)',
    'muscle_group': "Abs",
    'image': 'assets/exercises/abs_ab_wheel.png',
    'description': 'Ejercicio avanzado para un core fuerte y definido.',
  },
  {
    'id': 44, // <--- Nuevo ID
    'name': 'Encogimientos en Polea Alta (Cable Crunch)',
    'muscle_group': "Abs",
    'image': 'assets/exercises/abs_cable_crunch.png',
    'description': 'Permite añadir resistencia progresiva a los encogimientos.',
  },

  // Continúa añadiendo IDs únicos a todos tus ejercicios...
];

const List<Map<String, dynamic>> predefinedTemplatesData = [
  {
    'templateKey': 'chest_routine_full', // <-- NUEVA CLAVE ÚNICA
    'templateName': 'Complete Chest Routine', // <-- NOMBRE CANÓNICO EN INGLÉS
    'exerciseSourceIds': [0, 1, 4, 5, 8],
  },
  {
    'templateKey': 'back_strong',
    'templateName': 'Strong Back', // <-- NOMBRE CANÓNICO EN INGLÉS
    'exerciseSourceIds': [9, 11, 12, 14],
  },
  {
    'templateKey': 'leg_day_basic',
    'templateName': 'Basic Leg Day', // <-- NOMBRE CANÓNICO EN INGLÉS
    'exerciseSourceIds': [16, 17, 19, 22],
  },
  {
    'templateKey': 'shoulders_steel',
    'templateName': 'Steel Shoulders', // <-- NOMBRE CANÓNICO EN INGLÉS
    'exerciseSourceIds': [24, 25, 26, 28],
  },
  {
    'templateKey': 'arms_toned',
    'templateName': 'Toned Arms', // <-- NOMBRE CANÓNICO EN INGLÉS
    'exerciseSourceIds': [30, 31, 35, 36],
  },
];