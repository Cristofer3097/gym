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
  {
    'id': 10, // <--- Nuevo ID
    'name': 'Cable Fly',
    'muscle_group': "Chest",
    'image': 'assets/exercises/cable_fly.gif',
    'description': 'Cable Fly is a targeted exercise that primarily strengthens the chest muscles, while also engaging the shoulders and arms. Suitable for both beginners and experienced gym-goers, offering adjustable resistance to match individual fitness levels. ',
  },
  // Espalda
  {
    'id': 11, // <--- Nuevo ID
    'name': 'Pulldown',
    'muscle_group': 'Back',
    'image': 'assets/exercises/Pulldown.gif',
    'description': 'The Cable Pulldown is a popular strength training exercise that primarily targets the muscles in your back, specifically the latissimus dorsi, but also works your shoulders and arms. This exercise is ideal for both beginners and advanced fitness enthusiasts, as the weight can be easily adjusted to match individual strength levels. Incorporating Cable Pulldowns into your workout routine can help improve upper body strength, promote better posture, and enhance muscle definition.',
  },
  {
    'id': 12, // <--- Nuevo ID
    'name': 'Pulldown with V-bar',
    'muscle_group': "Back",
    'image': 'assets/exercises/Pulldown_with_V-bar.gif',
    'description': 'Pulldown with V-bar is a highly effective exercise that targets and strengthens the muscles in your back, shoulders, and arms, particularly the latissimus dorsi.',
  },
  {
    'id': 13, // <--- Nuevo ID
    'name': 'Pull-up',
    'muscle_group': "Back", // También trabaja piernas y glúteos intensamente
    'image': 'assets/exercises/Pull-up.gif',
    'description': 'The Pull-up exercise is a highly beneficial upper body workout that targets multiple muscle groups, including the back, arms, shoulders, and chest, improving strength and endurance. It is an ideal exercise for anyone, from beginners to fitness enthusiasts, who are interested in building upper body strength and enhancing muscle definition. ',
  },
  {
    'id': 14, // <--- Nuevo ID
    'name': 'Supination Pulldown on High Pulley',
    'muscle_group': "Back",
    'image': 'assets/exercises/Supination-Pulldown-on-High-Pulley.gif',
    'description': 'Supination Pulldown on High Pulley is a strength-building exercise targeting your back muscles, particularly the lats, rhomboids, and traps. It is suitable for individuals at all fitness levels who want to improve their upper body strength and posture. ',
  },
  {
    'id': 15, // <--- Nuevo ID
    'name': 'Horizontal Row',
    'muscle_group': "Back",
    'image': 'assets/exercises/Horizontal_Rowing.gif',
    'description': 'Horizontal Row is a strength-building exercise that targets the muscles in your back, shoulders, and arms, making it ideal for those looking to improve upper body strength and posture. ',
  },
  {
    'id': 16, // <--- Nuevo ID
    'name': 'Open Horizontal Row',
    'muscle_group': "Back",
    'image': 'assets/exercises/Open_Horizontal_Rowing.gif',
    'description': 'Open Horizontal Row is a strength-building exercise that targets the muscles in your back, shoulders, and arms, contributing to improved posture and overall upper body strength.',
  },
  {
    'id': 17, // <--- Nuevo ID
    'name': 'Horizontal Machine Row',
    'muscle_group': "Back",
    'image': 'assets/exercises/Horizontal_Machine_Row.gif',
    'description': 'Horizontal Machine Row is a strength training exercise that primarily targets the muscles in the back, improving muscular endurance and promoting better posture. ',
  },
  {
    'id': 18, // <--- Nuevo ID
    'name': 'T-Bar Row',
    'muscle_group': "Back",
    'image': 'assets/exercises/T-Bar_Row.gif',
    'description': 'T-Bar Row is a strength training exercise that primarily targets the muscles in your back, shoulders, and arms, offering a comprehensive upper body workout. ',
  },
  {
    'id': 19, // <--- Nuevo ID
    'name': 'Rear Delt Row',
    'muscle_group': "Back",
    'image': 'assets/exercises/Rear_Delt_Row.gif',
    'description': 'Rear Delt Row is a strength training exercise that specifically targets the rear deltoids, helping to enhance shoulder stability and upper body strength.',
  },
  {
    'id': 20,
    'name': 'Reverse Barbell Row',
    'muscle_group': "Back",
    'image': 'assets/exercises/Reverse_Barbell_Row.gif',
    'description': 'Reverse Barbell Row is a strength-building exercise that primarily targets the muscles in your back, biceps, and forearms.',
  },
  {
    'id': 21, // <--- Nuevo ID
    'name': 'One Arm Row',
    'muscle_group': "Back",
    'image': 'assets/exercises/One_Arm_Row.gif',
    'description': 'The One Arm Row is a strength training exercise that primarily targets the muscles in the back, but also works the biceps and shoulders, contributing to improved posture and upper body strength. ',
  },
  // Piernas
  {
    'id': 22, // <--- Nuevo ID
    'name': 'Hack Squat',
    'muscle_group': "Legs",
    'image': 'assets/exercises/Hack_Squat.gif',
    'description': 'The Hack Squat is a lower body exercise that primarily targets the quadriceps, while also engaging the glutes and hamstrings, contributing to improved strength, balance, and muscle definition. Individuals might opt for the Sled Hack Squat because it offers a safer alternative to traditional squats, as it reduces strain on the back while still providing an effective workout for the lower body.',
  },
  {
    'id': 23, // <--- Nuevo ID
    'name': 'Extension',
    'muscle_group': "Legs",
    'image': 'assets/exercises/Extension.gif',
    'description': 'The Extension is a strength-building exercise that primarily targets the quadriceps, enhancing muscle tone, power, and endurance in the lower body.',
  },
  {
    'id': 24, // <--- Nuevo ID
    'name': 'Incline Press',
    'muscle_group': "Legs",
    'image': 'assets/exercises/Incline_Press.gif',
    'description': 'The Incline Press is a comprehensive lower body exercise that primarily targets the quadriceps, while also engaging the glutes, hamstrings, and calves. This exercise is suitable for both beginners and advanced fitness enthusiasts as it can be easily adjusted to match individual strength levels.',
  },
  {
    'id': 25, // <--- Nuevo ID
    'name': 'Barbell Squat',
    'muscle_group': "Legs",
    'image': 'assets/exercises/Barbell_Squat.gif',
    'description': 'The Barbell Squat is a comprehensive lower body exercise that primarily targets the quadriceps, hamstrings, and glutes, while also engaging the core and improving balance. It is suitable for individuals at all fitness levels, from beginners to advanced athletes, due to its modifiable intensity and form. People would want to perform this exercise not only for its ability to build strength and muscle, but also for its benefits in enhancing flexibility, mobility, and overall functional fitness.',
  },
  {
    'id': 26, // <--- Nuevo ID
    'name': 'Smith Squat',
    'muscle_group': "Legs",
    'image': 'assets/exercises/Smith_Squat.png',
    'description': 'The Smith Squat is a strength training exercise that primarily targets the glutes, quadriceps, and hamstrings, while also engaging the core and lower back. ',
  },
  {
    'id': 27, // <--- Nuevo ID
    'name': 'Adductor in Machine',
    'muscle_group': "Legs",
    'image': 'assets/exercises/Adductor_in_Machine.gif',
    'description': 'The Adductor in Machine is a targeted strength exercise that focuses on the inner thigh muscles, primarily the adductor group. This exercise is beneficial not only for improving overall leg aesthetics, but also for enhancing performance in movements and sports that require strong, stable hips and thighs.',
  },
  // Hombros
  {
    'id': 28,
    'name': 'Machine Lateral Raises',
    'muscle_group': "Shoulders",
    'image': 'assets/exercises/Machine_Lateral_Raises.gif',
    'description': 'The Machine Lateral Raises is a strength training exercise that primarily targets the shoulders, specifically the lateral deltoids, aiding in the development of broader, stronger shoulders.',
  },
  {
    'id': 29, // <--- Nuevo ID
    'name': 'Dumbbell Lateral Raises',
    'muscle_group': "Shoulders", // También trapecios
    'image': 'assets/exercises/Dumbbell_Lateral_Raises.gif',
    'description': 'The Lateral Raise is a strength training exercise that primarily targets the deltoids, helping to build shoulder width and definition. It is suitable for individuals at any fitness level, from beginners to advanced athletes, looking to improve upper body strength and posture. People may want to incorporate Lateral Raises into their routine to enhance shoulder stability, promote balanced muscle development, and improve daily functional movements.',
  },
  {
    'id': 30, // <--- Nuevo ID
    'name': 'Lateral Raises on Cables',
    'muscle_group': "Shoulders",
    'image': 'assets/exercises/Lateral_Raises_on_cables.gif',
    'description': 'The Lateral Raises on Cables is a strength-building exercise that primarily targets the deltoids, enhancing shoulder definition and improving overall upper body strength.',
  },
  {
    'id': 31, // <--- Nuevo ID
    'name': 'Dumbbell Shoulder Press',
    'muscle_group': "Shoulders",
    'image': 'assets/exercises/Dumbbell_Military_Press.gif',
    'description': 'The Dumbbell Shoulder Press is a highly effective upper body exercise that targets the deltoids, triceps, and upper pectoral muscles, promoting improved strength and muscle tone.',
  },
  {
    'id': 32, // <--- Nuevo ID
    'name': 'Shoulder Press on Machine',
    'muscle_group': "Shoulders",
    'image': 'assets/exercises/Military_Press_on_Machine.gif',
    'description': 'The Shoulder Press on Machine is a strength-building exercise targeting the deltoids, triceps, and upper body muscles, making it highly beneficial for those aiming to enhance their upper body strength.',
  },
  {
    'id': 33, // <--- Nuevo ID
    'name': 'Shoulder Press Smith',
    'muscle_group': "Shoulders",
    'image': 'assets/exercises/Military_Press_Smith.png',
    'description': 'The Shoulder Press Smith is a strength-building exercise that primarily targets the deltoids, triceps, and upper body muscles, offering a comprehensive workout for your upper body. It is suitable for both beginners and advanced fitness enthusiasts as it allows for controlled movements and adjustable weights. ',
  },
  {
    'id': 34, // <--- Nuevo ID
    'name': 'Dumbbell Front Raise',
    'muscle_group': "Shoulders",
    'image': 'assets/exercises/Dumbbell_Front_Raises.gif',
    'description': 'The Dumbbell Front Raise is a strength-building exercise that primarily targets the shoulders, specifically the anterior deltoids, and also works the upper chest muscles. ',
  },
  {
    'id': 35, // <--- Nuevo ID
    'name': 'Lever Reverse Fly',
    'muscle_group': "Shoulders",
    'image': 'assets/exercises/Machine_Rear_Flyes.gif',
    'description': 'The Lever Reverse Fly is a strength training exercise that primarily targets and enhances the muscles in your upper back, shoulders, and arms. It is ideal for individuals at an intermediate fitness level who are looking to improve their upper body strength and posture.',
  },
  {
    'id': 36, // <--- Nuevo ID
    'name': 'Rear Fly',
    'muscle_group': "Shoulders",
    'image': 'assets/exercises/Rear_Fly.gif',
    'description': 'The Rear Fly is a strength training exercise that primarily targets the muscles in the upper back, shoulders, and arms, contributing to improved posture and enhanced muscle definition.  People may choose this exercise for its ability to be easily modified, its effectiveness in building upper body strength, and its role in creating a balanced, well-rounded fitness routine.',
  },
  // Biceps

  {
    'id': 37, // <--- Nuevo ID
    'name': 'Barbell Curl',
    'muscle_group': "Biceps",
    'image': 'assets/exercises/Barbell_Curl.gif',
    'description': 'The Barbell Curl is a strength training exercise designed to target the biceps and improve upper body strength. It is suitable for anyone, from beginners to advanced athletes, who are looking to build muscle mass and enhance arm definition. ',
  },
  {
    'id': 38, // <--- Nuevo ID
    'name': 'Biceps Curl',
    'muscle_group': "Biceps", // También Pecho
    'image': 'assets/exercises/Biceps_Curl.gif',
    'description': 'The Biceps Curl is a strength training exercise that primarily targets the biceps muscles, promoting muscle growth and endurance in the upper arms. This exercise is suitable for individuals at all fitness levels, from beginners to advanced athletes, due to its adjustable intensity. People may want to perform Biceps Curls not only to enhance their arm strength and tone, but also to improve their overall lifting capability, making daily tasks easier.',
  },
  {
    'id': 39, // <--- Nuevo ID
    'name': 'Concentration Curl',
    'muscle_group': "Biceps",
    'image': 'assets/exercises/Concentration_Curl.gif',
    'description': 'The Concentration Curl is a highly effective exercise that primarily targets the biceps, promoting muscle growth and strength. People might opt for this exercise as it focuses on the isolation of the bicep muscle, leading to improved muscle definition and size.',
  },

  // Abdomen
  {
    'id': 40, // <--- Nuevo ID
    'name': 'Overhead Curl',
    'muscle_group': "Biceps",
    'image': 'assets/exercises/Overhead_Curl.gif',
    'description': 'The Overhead Curl is a strength training exercise that primarily targets the biceps and shoulders, helping to enhance upper body strength and improve muscle definition. This exercise is ideal for both beginners and advanced fitness enthusiasts as it can be easily adjusted to match individual fitness levels. Incorporating Overhead Curls into your workout routine can aid in improving arm strength and stability, making it a beneficial exercise for those who are looking to improve their performance in sports or daily activities that require upper body strength.',
  },
  {
    'id': 41, // <--- Nuevo ID
    'name': 'Lever Preacher Curl',
    'muscle_group': "Biceps",
    'image': 'assets/exercises/Lever_Preacher_Curl.gif',
    'description': 'Enfatiza la parte inferior del abdomen.',
  },
  {
    'id': 42, // <--- Nuevo ID
    'name': 'Barbell Preacher Curl',
    'muscle_group': "Biceps",
    'image': 'assets/exercises/Barbell_Preacher_Curl.gif',
    'description': 'The Barbell Preacher Curl is a highly effective exercise for targeting and isolating the biceps, particularly the brachialis muscle, leading to enhanced arm strength and size. ',
  },
  {
    'id': 43, // <--- Nuevo ID
    'name': 'Barbell Spider Curl',
    'muscle_group': "Biceps",
    'image': 'assets/exercises/Barbell_Spider_Curl.gif',
    'description': 'The Barbell Spider Curl is a targeted exercise designed to isolate and enhance the biceps by reducing help from other muscle groups. This exercise is ideal for individuals looking to improve their upper body strength, particularly those wanting to define and sculpt their arm muscles.',
  },
  {
    'id': 44, // <--- Nuevo ID
    'name': 'Isolated Biceps Curl',
    'muscle_group': "Biceps",
    'image': 'assets/exercises/Isolated_Biceps_Curl.gif',
    'description': 'The Cable One Arm Biceps Curl is a strength-building exercise targeting the biceps and providing an intense isolation workout. This exercise is especially beneficial for those who want to focus on muscle symmetry and balance, as it allows for the independent workout of each arm, helping to prevent or correct any strength imbalances.',
  },
  {
    'id': 45,
    'name': 'Inclined Curl',
    'muscle_group': "Biceps",
    'image': 'assets/exercises/Inclined_Curl.gif',
    'description': 'The Inclined Curl is a strength training exercise that specifically targets the biceps, promoting muscle growth and enhancing arm strength.',
  },
  {
    'id': 45,
    'name': 'Triceps Pushdown',
    'muscle_group': "Triceps",
    'image': 'assets/exercises/Triceps_Pushdown.gif',
    'description': 'The Triceps Pushdown is a strength training exercise that primarily targets the triceps muscles, helping to improve upper body strength and muscle definition. It is suitable for individuals at all fitness levels, from beginners to advanced, as it can be easily adjusted based on strength and skill.',
  },
  {
    'id': 46,
    'name': 'Cross Triceps Extension',
    'muscle_group': "Tricpes",
    'image': 'assets/exercises/Cross_Triceps_Extension.png',
    'description': 'The Cross Triceps Extension is a strength-building exercise that primarily targets the triceps, while also engaging the shoulders and core muscles.',
  },
  {
    'id': 47,
    'name': 'One Arm Triceps Extension',
    'muscle_group': "Triceps",
    'image': 'assets/exercises/One_Arm_Triceps_Extension.gif',
    'description': 'The One Arm Triceps Extension is a strength-building exercise designed to isolate and develop the triceps muscle, contributing to improved upper body strength and toned arms.  ',
  },
  {
    'id': 48,
    'name': 'Triceps Extension',
    'muscle_group': "Triceps",
    'image': 'assets/exercises/Machine_Rear_Flyes.gif',
    'description': 'The Triceps Extension is a strength training exercise that specifically targets and isolates the triceps muscles, promoting muscle growth and endurance. ',
  },
  {
    'id': 49,
    'name': 'Rear Fly',
    'muscle_group': "Shoulders",
    'image': 'assets/exercises/Rear_Fly.gif',
    'description': 'The Rear Fly is a strength training exercise that primarily targets the muscles in the upper back, shoulders, and arms, contributing to improved posture and enhanced muscle definition.  People may choose this exercise for its ability to be easily modified, its effectiveness in building upper body strength, and its role in creating a balanced, well-rounded fitness routine.',
  },
  // Biceps

  {
    'id': 50,
    'name': 'Barbell Curl',
    'muscle_group': "Biceps",
    'image': 'assets/exercises/Barbell_Curl.gif',
    'description': 'The Barbell Curl is a strength training exercise designed to target the biceps and improve upper body strength. It is suitable for anyone, from beginners to advanced athletes, who are looking to build muscle mass and enhance arm definition. ',
  },
  {
    'id': 51,
    'name': 'Biceps Curl',
    'muscle_group': "Biceps", // También Pecho
    'image': 'assets/exercises/Biceps_Curl.gif',
    'description': 'The Biceps Curl is a strength training exercise that primarily targets the biceps muscles, promoting muscle growth and endurance in the upper arms. This exercise is suitable for individuals at all fitness levels, from beginners to advanced athletes, due to its adjustable intensity. People may want to perform Biceps Curls not only to enhance their arm strength and tone, but also to improve their overall lifting capability, making daily tasks easier.',
  },
  {
    'id': 52,
    'name': 'Concentration Curl',
    'muscle_group': "Biceps",
    'image': 'assets/exercises/Concentration_Curl.gif',
    'description': 'The Concentration Curl is a highly effective exercise that primarily targets the biceps, promoting muscle growth and strength. People might opt for this exercise as it focuses on the isolation of the bicep muscle, leading to improved muscle definition and size.',
  },

  // Abdomen
  {
    'id': 53,
    'name': 'Overhead Curl',
    'muscle_group': "Biceps",
    'image': 'assets/exercises/Overhead_Curl.gif',
    'description': 'The Overhead Curl is a strength training exercise that primarily targets the biceps and shoulders, helping to enhance upper body strength and improve muscle definition. This exercise is ideal for both beginners and advanced fitness enthusiasts as it can be easily adjusted to match individual fitness levels. Incorporating Overhead Curls into your workout routine can aid in improving arm strength and stability, making it a beneficial exercise for those who are looking to improve their performance in sports or daily activities that require upper body strength.',
  },
  {
    'id': 54,
    'name': 'Lever Preacher Curl',
    'muscle_group': "Biceps",
    'image': 'assets/exercises/Lever_Preacher_Curl.gif',
    'description': 'Enfatiza la parte inferior del abdomen.',
  },
  {
    'id': 55,
    'name': 'Barbell Preacher Curl',
    'muscle_group': "Biceps",
    'image': 'assets/exercises/Barbell_Preacher_Curl.gif',
    'description': 'The Barbell Preacher Curl is a highly effective exercise for targeting and isolating the biceps, particularly the brachialis muscle, leading to enhanced arm strength and size. ',
  },
  {
    'id': 56,
    'name': 'Rueda Abdominal (Ab Wheel Rollout)',
    'muscle_group': "Abs",
    'image': 'assets/exercises/abs_ab_wheel.png',
    'description': 'Ejercicio avanzado para un core fuerte y definido.',
  },
  {
    'id': 57,
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