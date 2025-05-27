// lib/tips_extras_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'rm_calculator_dialog.dart';

class TipsExtrasScreen extends StatelessWidget {
  const TipsExtrasScreen({Key? key}) : super(key: key);

  // TODO: Reemplaza esta URL con la URL real de tu repositorio cuando esté lista
  final String _repositoryUrl = 'https://github.com/Cristofer3097/gym';
  final String _heavyDutyBookUrl = 'https://www.amazon.com.mx/Heavy-Duty-Verdad-Entrenamiento-Intensidad-ebook/dp/B0F74PTBXZ/ref=sr_1_6?crid=1K9NUXJFDFR2C&dib=eyJ2IjoiMSJ9.BXt_LZeGSWI7WWJcjDKapprBUdFNMT6mPWI5Ualm_pFay7IwmsMDdeebzA0hcdCYYbOQ1MWxJHPH4eD3xZwT7oY5B47TJDQRJXqTVhHmHNVbfytNGdXnn579-TX74sgxKP4lMu9N6CCZvRa8n2ij4Pby9NMI4MzUqVjpboqWo_O9h0D8O1CL1DFKOM7npeMtm9wywN8edXFYUmTKzF21zvteiCEPSzfuwTYD0GkXlQ_oeX-xCafQIgh64gn1YztC8OU_JEZXTua2R7uZuec_-spF3BmL4rJE0j3Rwwr87bs.zH6MPy44BSzxenauvMRQ-n-f5ZyiTcZNRq7feA5QruE&dib_tag=se&keywords=heavy+duty+mike+mentzer&qid=1748297635&sprefix=heavy+dut%2Caps%2C180&sr=8-6';

  Future<void>  _launchGenericUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
       if (!await launchUrl(url)) {
         if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('No se pudo abrir el enlace: $urlString')),
           );
         }
        print('Could not launch $urlString');
       }
     }
  void _showRMCalculatorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return const RMCalculatorDialog();
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Para usar colores y estilos del tema

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consejos y Extras'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            _buildSectionTitle(context, '💡 Consejos Rápidos', theme.primaryColor),
            Card( // Usamos una Card directamente para tener más control sobre el título
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell( // Para hacer el área del título clickeable
                      onTap: () => _showRMCalculatorDialog(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // Para que el Row no ocupe todo el ancho innecesariamente
                        children: [
                          Text(
                            "Conoce tu RM ", // Título
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Icon(Icons.info_outline_rounded, color: Colors.yellow, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text( // Descripción del tip
                      "PR (Personal Record) y RM (Repetición Máxima) son conceptos clave para medir el progreso y la fuerza. PR es el máximo peso que has levantado en un ejercicio en particular, mientras que RM es el peso máximo que puedes levantar en una sola repetición, independientemente de tu récord personal.",
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.85),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            _buildTip(
              context,
              'Libro Recomendado', // Título del consejo
              'Un libro que me ayudó a entender la importancia del entrenamiento efectivo y de alta intensidad es "Heavy Duty" del fisicoculturista Mike Mentzer.', // Contenido del consejo
              actionButton: ElevatedButton.icon( // El botón que quieres integrar
                icon: const Icon(Icons.menu_book_rounded, size: 20), // Icono más apropiado para un libro
                label: const Text('Link del libro'), // Texto del botón
                style: ElevatedButton.styleFrom(

                ),
                onPressed: () {
                  _launchGenericUrl(context, _heavyDutyBookUrl); // Descomenta cuando tengas la URL y url_launcher


                },
              ),
            ),
            _buildTip(context, 'Constancia:', 'La clave del progreso es ser constante con tus entrenamientos y nutrición.'),
            _buildTip(context, 'Calentamiento:', 'No olvides calentar antes de cada sesión para prevenir lesiones y preparar tus músculos.'),
            _buildTip(context, 'Aproximidad:', 'Antes de llegar al fallo moscular, entrenar 2 series con un peso del 50% - 80% de tu peso máximo y de 2-4 repeticiones por debajo del fallo antes de llegar a tu serie efectiva.'),
            _buildTip(context, 'Técnica > Peso:', 'Prioriza una buena técnica sobre levantar más peso, especialmente al iniciar. Esto maximiza la efectividad y previene lesiones.'),
            _buildTip(context, 'Evita la sobrecarga de entrenamiento:', 'Realizar entre 6 y 7 ejercicios en una sesión de gimnasio. es importante elegir ejercicios que sean efectivos para los objetivos de entrenamiento y evitar la sobrecarga para evitar el escancamiento y lesiones.'),
            _buildTip(context, 'Progresión Gradual:', 'Aumenta la intensidad, el volumen o la frecuencia de tus entrenamientos pero se paciente, con agregar 5 Lb más es suficiente para una mejorar tu serie efectiva. Si haces mas de 10 repeticiones es hora de subir de peso'),
            _buildTip(context, 'Descanso:', 'El descanso es tan importante como el ejercicio. Duerme bien (7-9 horas) y permite que tus músculos se recuperen entre sesiones. Te recomiendo un descanso de 48 a 72 horas entre sesiones para el mismo grupo muscular. '),
            _buildTip(context, 'Descanso entre series :', 'De 3-5 minutos:Son ideales para entrenamientos que buscan aumentar la fuerza máxima y la potencia. Permiten una recuperación más completa del sistema neuromuscular y energético, lo que facilita una mayor intensidad y volumen en las series subsecuentes.'),
            _buildTip(context, 'Conoce tu cuerpo:', 'No ignores el dolor (diferente a la fatiga muscular). Si algo no se siente bien, detente y evalúa.'),
            _buildTip(context, 'Nutrición:', 'Una alimentación balanceada es fundamental.\n -Es importante llegar a tus calorias de mantenimiento o con un poco de superávit calórico (100 - 200) es suficiente para ganancias mosculares. (Hay muchas paginas web para calcular tus calorias necesarias)  \n -Asegúrate de consumir suficientes proteínas (1.8 gr de proteina multiplicado por tu peso) para la reparación muscular. \n -Los Carbohidratos son tambien fundamentales, antes del entrenamiento es crucial para optimizar el rendimiento, especialmente en ejercicios de larga duración o alta intensidad. \n -Unos Carbohidratos de absorción lenta, como pan integral o frutas, puede ayudar a mantener los niveles de energía estables a lo largo del entrenamiento.'),



            const SizedBox(height: 24),
            _buildSectionTitle(context, '🔗 Repositorio del Proyecto', theme.primaryColor),
            Text(
              "El código fuente de esta aplicación está disponible en GitHub. Este proyecto es de código abierto, lo que significa que puedes explorar cómo está construido, proponer mejoras, o incluso utilizar partes del código para tus propios proyectos.\n\nTu contribución o feedback es siempre bienvenido.",
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.code_rounded), // Icono para repositorio
                label: const Text('Visitar Repositorio'),
                onPressed: () {
                   _launchGenericUrl(context, _repositoryUrl); // Descomenta cuando tengas la URL y url_launcher
                },
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle(context, '🚀 El Porqué del Proyecto', theme.primaryColor),
            Text(
              "Esta aplicación, 'Gym Diary', nació de mi necesidad personal de contar con una herramienta simple, directa y efectiva para llevar un registro detallado de mis entrenamientos en el gimnasio. Buscaba algo que me permitiera personalizar mis rutinas, seguir mi progreso en series, repeticiones y pesos, y tener un historial accesible pero siempre me encontraba aplicaciones de servicio o con un costo muy escesivo para simplemente guardar datos numericos, funciones innecesarias y/o complejas.\n\n"
                  "El objetivo principal es ofrecer una experiencia de usuario clara, enfocada en la funcionalidad esencial para el seguimiento del entrenamiento de fuerza, permitiendo al usuario concentrarse en lo importante: su progreso y constancia.\n\n"
                  "Espero sinceramente que encuentres esta aplicación útil para alcanzar tus metas de fitness. ¡Cualquier comentario o sugerencia para mejorarla será muy apreciado!",
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                "Creador Cristofer3097",
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTip(BuildContext context, String title, String content, {Widget? actionButton}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Card( // Usar Card para mejor separación visual
        // elevation y color se heredan del CardTheme
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white, // O theme.colorScheme.onSurface
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.85), // O theme.colorScheme.onSurface.withOpacity(0.85)
                  height: 1.4,
                ),
              ),
              if (actionButton != null) ...[ // Si se proporciona un actionButton
                const SizedBox(height: 12), // Añade un espacio antes del botón
                Center(child: actionButton), // Muestra el botón, centrado
              ],
            ],
          ),
        ),
      ),
    );
  }
}



