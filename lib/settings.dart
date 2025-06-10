import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'database/database_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:device_info_plus/device_info_plus.dart';


class Settings extends StatefulWidget {
  final void Function(Locale) onLocaleChange;

  const Settings({Key? key, required this.onLocaleChange}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<Settings> {
  bool _isLoading = false;

  /// Muestra el diálogo para que el usuario seleccione el idioma.
  void _showLanguageSelectionDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.changeLanguageDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(l10n.languageEnglish),
                onTap: () {
                  widget.onLocaleChange(const Locale('en'));
                  Navigator.of(dialogContext).pop();
                },
              ),
              ListTile(
                title: Text(l10n.languageSpanish),
                onTap: () {
                  widget.onLocaleChange(const Locale('es'));
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.close),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Inicia el proceso de exportación de la base de datos.
  Future<void> _exportDatabase() async {
    final l10n = AppLocalizations.of(context)!;
    if (!await _requestPermissions()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settings_permission_denied)));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbPath = p.join(dbFolder.path, 'gym_diary.db');
      final dbFile = File(dbPath);

      if (await dbFile.exists()) {
        // Genera un nombre de archivo único con fecha y hora.
        final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        final String newFileName = 'gym_diary_backup_$timestamp.db';

        // Permite al usuario elegir dónde guardar el archivo.
        String? resultPath = await FilePicker.platform.getDirectoryPath(
          dialogTitle: l10n.settings_export_dialog_title,
        );

        if (resultPath != null) {
          final newPath = p.join(resultPath, newFileName);
          await dbFile.copy(newPath);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(l10n.settings_export_success(newPath)),
            duration: const Duration(seconds: 5),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settings_no_folder_selected)));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settings_error(e.toString()))));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  /// Inicia el proceso de importación de la base de datos.
  Future<void> _importDatabase() async {
    final l10n = AppLocalizations.of(context)!;

    // Muestra una advertencia CRÍTICA antes de proceder.
    final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.settings_import_warning_title),
          content: Text(l10n.settings_import_warning_content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.settings_import_confirm),
            )
          ],
        ));

    if (confirm != true) return;

    if (!await _requestPermissions()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settings_permission_denied)));
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Permite al usuario seleccionar el archivo .db a importar.
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // O puedes ser más estricto con custom: ['db']
      );

      if (result != null && result.files.single.path != null) {
        final sourceFile = File(result.files.single.path!);

        // Obtén la ruta de la base de datos de la app.
        final dbFolder = await getApplicationDocumentsDirectory();
        final destinationPath = p.join(dbFolder.path, 'gym_diary.db');

        // ¡CRÍTICO! Cierra la conexión a la base de datos antes de sobreescribirla.
        await DatabaseHelper.instance.closeDB();

        // Copia el archivo seleccionado y reemplaza el existente.
        await sourceFile.copy(destinationPath);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settings_import_success)),
        );
        // Devuelve 'true' para indicar a HomeScreen que debe recargar.
        if (mounted) Navigator.of(context).pop(true);

      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settings_no_file_selected)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.settings_error(e.toString()))));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  /// Solicita los permisos de almacenamiento necesarios.
  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        status = await Permission.manageExternalStorage.request();
      }
      return status.isGranted;
    }
    // Para otras plataformas como iOS, la lógica puede ser diferente o no necesaria.
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings_title),
      ),
      body: _isLoading
          ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(l10n.settings_loading, style: Theme.of(context).textTheme.titleMedium),
            ],
          ))
          : ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          _buildSectionTitle(context, l10n.settings_section_general),
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.settings_language),
              subtitle: Text(l10n.settings_language_subtitle),
              onTap: () => _showLanguageSelectionDialog(context),
            ),
          ),
          const Divider(height: 24),
          _buildSectionTitle(context, l10n.settings_section_data),
          Card(
            child: ListTile(
              leading: const Icon(Icons.upload_file),
              title: Text(l10n.settings_export),
              subtitle: Text(l10n.settings_export_subtitle),
              onTap: _exportDatabase,
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.download_for_offline),
              title: Text(l10n.settings_import),
              subtitle: Text(l10n.settings_import_subtitle),
              onTap: _importDatabase,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2
        ),
      ),
    );
  }
}