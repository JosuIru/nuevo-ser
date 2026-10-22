import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import 'package:share_plus/share_plus.dart';

import '../servicios/backup_servicio.dart';

/// Pantalla de backup/restore. Operaciones lentas (segundos) y
/// destructivas — UI explícita con confirmaciones.
class PantallaBackup extends StatefulWidget {
  PantallaBackup({super.key});

  @override
  State<PantallaBackup> createState() => _PantallaBackupState();
}

class _PantallaBackupState extends State<PantallaBackup> {
  bool _trabajando = false;
  DateTime? _ultimoBackup;

  @override
  void initState() {
    super.initState();
    _cargarUltimoBackup();
  }

  Future<void> _cargarUltimoBackup() async {
    final u = await servicioCopiaSeguridad.ultimaCopia();
    if (mounted) setState(() => _ultimoBackup = u);
  }

  Future<void> _crearYCompartir() async {
    setState(() => _trabajando = true);
    try {
      final fichero = await servicioCopiaSeguridad.crearCopia();
      await _cargarUltimoBackup();
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(fichero.path)],
        subject: 'Backup Solera Arbolado Urbano',
      );
    } on ErrorCopiaSeguridad catch (error) {
      _avisar('No se pudo crear el backup. ${textoErrorCopiaSeguridad(error)}');
    } catch (error) {
      _avisar('No se pudo crear el backup: $error');
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  void _avisar(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(duration: const Duration(seconds: 8), content: Text(texto)),
    );
  }

  Future<void> _restaurar() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
    if (resultado == null || resultado.files.isEmpty) return;
    final ruta = resultado.files.first.path;
    if (ruta == null) return;
    final copia = File(ruta);

    // Primero se comprueba la copia sin tocar nada, para enseñar de
    // cuándo es y pedir confirmación.
    setState(() => _trabajando = true);
    InformeCopiaSeguridad informe;
    try {
      informe = await servicioCopiaSeguridad.validarCopia(copia);
    } on ErrorCopiaSeguridad catch (error) {
      _avisar('No se puede restaurar esta copia. ${textoErrorCopiaSeguridad(error)}');
      return;
    } catch (error) {
      _avisar('No se puede leer esta copia: $error');
      return;
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
    if (!mounted) return;

    final fecha = informe.fechaCreacion;
    final textoFecha = fecha == null
        ? 'de fecha desconocida (formato antiguo)'
        : 'del ${DateFormat("d/MM/yyyy 'a las' HH:mm").format(fecha)}';
    final confirmado = await DialogoConfirmacion.mostrar(
      context,
      titulo: 'Restaurar desde un backup',
      mensaje: 'La copia elegida es $textoFecha.\n\n'
          'Sustituye la base de datos actual por la de la copia y añade sus fotos.\n\n'
          'Antes se guarda automáticamente una copia del estado actual por si quieres deshacerlo.',
      textoConfirmar: 'Restaurar',
      textoCancelar: 'Cancelar',
      icono: Icons.restore,
    );
    if (confirmado != true) return;

    setState(() => _trabajando = true);
    try {
      final restauracion = await servicioCopiaSeguridad.restaurarCopia(copia);
      final respaldo = restauracion.respaldoPrevio;
      _avisar(respaldo == null
          ? 'Restaurado.'
          : 'Restaurado. Tu estado anterior se guardó en ${respaldo.path.split('/').last}');
    } on ErrorCopiaSeguridad catch (error) {
      _avisar('No se pudo restaurar. ${textoErrorCopiaSeguridad(error)}');
    } catch (error) {
      _avisar('No se pudo restaurar: $error');
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ultimo = _ultimoBackup;
    final hace = ultimo == null ? null : DateTime.now().difference(ultimo);
    return Scaffold(
      appBar: AppBar(title: Text('Backup y restauración')),
      body: AbsorbPointer(
        absorbing: _trabajando,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      ultimo == null
                          ? Icons.warning_amber
                          : (hace != null && hace.inDays > 7 ? Icons.error_outline : Icons.check_circle),
                      color: ultimo == null
                          ? Colors.orange
                          : (hace != null && hace.inDays > 7 ? Colors.red : Colors.green),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Último backup', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            ultimo == null
                                ? 'Nunca — recomendado hacer uno antes del cierre de campaña.'
                                : DateFormat("d/MM/yyyy 'a las' HH:mm").format(ultimo),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            Text('Crear backup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(
              'Empaqueta la base de datos y todas las fotos en un zip que puedes compartir por correo, '
              'Drive o copiar al servidor del ayuntamiento. Útil para migraciones de equipo o fin de campaña.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            SizedBox(height: 12),
            FilledButton.icon(
              icon: Icon(Icons.archive),
              onPressed: _trabajando ? null : _crearYCompartir,
              label: Text(_trabajando ? 'Empaquetando…' : 'Crear backup y compartir'),
            ),
            Divider(height: 32),
            Text('Restaurar desde backup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text(
              'Sustituye la base de datos actual por la del zip y añade sus fotos. Antes se comprueba '
              'la copia y se guarda una del estado actual por si quieres deshacer.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            SizedBox(height: 12),
            OutlinedButton.icon(
              icon: Icon(Icons.restore),
              onPressed: _trabajando ? null : _restaurar,
              label: Text('Restaurar zip'),
            ),
          ],
        ),
      ),
    );
  }
}
