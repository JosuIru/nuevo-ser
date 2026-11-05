import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/convenio.dart';
import '../modelos/proyecto_test.dart';
import '../utiles/numeros.dart';
import 'widgets/barra_inferior_formulario.dart';
import 'widgets/cuerpo_responsivo.dart';
import 'widgets/proyecto_visual.dart';

/// Apuntar una actividad de acompañamiento de un proyecto (anexo IV):
/// tipo en baldosas, asistencia, fecha, horas, descripción y notas.
class PantallaRegistrarActividad extends StatefulWidget {
  const PantallaRegistrarActividad({super.key, required this.proyecto});

  final ProyectoTest proyecto;

  @override
  State<PantallaRegistrarActividad> createState() =>
      _PantallaRegistrarActividadState();
}

class _PantallaRegistrarActividadState
    extends State<PantallaRegistrarActividad> {
  final _descripcion = TextEditingController();
  final _horas = TextEditingController();
  final _notas = TextEditingController();
  String _tipo = tiposAcompanamiento.first.codigo;
  String _asistencia = 'asistida';
  DateTime _fecha = DateTime.now();
  bool _guardando = false;

  @override
  void dispose() {
    _descripcion.dispose();
    _horas.dispose();
    _notas.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_guardando || widget.proyecto.id == null) return;
    setState(() => _guardando = true);
    try {
      await BaseDatosSoleraZunbeltz().guardarAcompanamiento(Acompanamiento(
        proyectoId: widget.proyecto.id!,
        tipo: _tipo,
        asistencia: _asistencia,
        fechaMs: _fecha.millisecondsSinceEpoch,
        descripcion: _descripcion.text.trim(),
        horas: leerNumero(_horas.text),
        notas: _notas.text.trim(),
      ));
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  String _textoFecha(AppLocalizations textos, String idioma) {
    final hoy = DateTime.now();
    if (_fecha.year == hoy.year &&
        _fecha.month == hoy.month &&
        _fecha.day == hoy.day) {
      return textos.ganFechaHoy(DateFormat('d MMM', idioma).format(_fecha));
    }
    return DateFormat('d MMM yyyy', idioma).format(_fecha);
  }

  Widget _baldosa(String codigo, String etiqueta) {
    final esquema = context.esquemaZunbeltz;
    final elegida = codigo == _tipo;
    return Material(
      color: elegida ? esquema.secondaryContainer : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
        side: BorderSide(
            color: elegida ? esquema.primary : esquema.outlineVariant,
            width: elegida ? 2 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => setState(() => _tipo = codigo),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Row(children: [
            Icon(iconoAcompanamiento(codigo),
                color: elegida
                    ? esquema.onSecondaryContainer
                    : esquema.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Text(etiqueta,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: elegida ? FontWeight.w700 : null,
                      color: elegida ? esquema.onSecondaryContainer : null)),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final esquema = context.esquemaZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final tipos = tiposAcompanamiento;
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(textos.actTitulo),
          Text(
              [
                textos.convenioAcompanamiento,
                if (widget.proyecto.nombre.isNotEmpty) widget.proyecto.nombre,
              ].join(' · '),
              style: estilos.bodyMedium
                  ?.copyWith(color: esquema.onSurfaceVariant)),
        ]),
      ),
      bottomNavigationBar: BarraInferiorFormulario(botones: [
        FilledButton.icon(
          onPressed: _guardando ? null : _guardar,
          icon: const Icon(Icons.check),
          label: Text(textos.actTitulo),
        ),
      ]),
      body: CuerpoResponsivo(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(textos.actTipo,
                style:
                    estilos.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            for (var indice = 0; indice < tipos.length; indice += 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: IntrinsicHeight(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                            child: _baldosa(tipos[indice].codigo,
                                tipos[indice].etiqueta(idioma))),
                        const SizedBox(width: 10),
                        Expanded(
                          child: indice + 1 < tipos.length
                              ? _baldosa(tipos[indice + 1].codigo,
                                  tipos[indice + 1].etiqueta(idioma))
                              : const SizedBox.shrink(),
                        ),
                      ]),
                ),
              ),
            const SizedBox(height: 10),
            Text(textos.acompanamientoAsistencia,
                style:
                    estilos.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                for (final opcion in asistenciasAcompanamiento)
                  ButtonSegment(
                      value: opcion.codigo,
                      label: Text(opcion.etiqueta(idioma),
                          maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
              selected: {_asistencia},
              onSelectionChanged: (elegidos) =>
                  setState(() => _asistencia = elegidos.first),
            ),
            const SizedBox(height: 20),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    final elegida = await showDatePicker(
                      context: context,
                      initialDate: _fecha,
                      firstDate: DateTime(_fecha.year - 5),
                      lastDate: DateTime(DateTime.now().year + 1),
                    );
                    if (elegida != null) setState(() => _fecha = elegida);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: textos.comunFecha,
                      suffixIcon: const Icon(Icons.calendar_month_outlined),
                    ),
                    child: Text(_textoFecha(textos, idioma),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _horas,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      InputDecoration(labelText: textos.acompanamientoHoras),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            TextField(
              controller: _descripcion,
              textCapitalization: TextCapitalization.sentences,
              decoration:
                  InputDecoration(labelText: textos.convenioDescripcion),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notas,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                  labelText: textos.apuNotas, alignLabelWithHint: true),
            ),
          ],
        ),
      ),
    );
  }
}
