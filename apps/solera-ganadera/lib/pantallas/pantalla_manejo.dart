import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, TituloBloqueSolera, separarCampoSolera;

import '../branding.dart';
import '../datos/base_datos.dart';
import '../dominio/calendario_sanitario.dart';
import '../estado/cambios_datos.dart';
import '../estado/datos_ganado.dart';
import '../modelos/ganado.dart';
import '../modelos/tarea_sanitaria.dart';
import '../modelos/visita.dart';
import '../utiles/textos_ganadera.dart';
import 'hoja_formulario.dart';

/// Calendario sanitario (lo que planifica el veterinario y el fin de las
/// supresiones) y registro de visitas.
class PantallaManejo extends StatefulWidget {
  const PantallaManejo({super.key});

  @override
  State<PantallaManejo> createState() => _PantallaManejoState();
}

class _DatosManejo {
  _DatosManejo(this.ganado, this.visitas);
  final DatosGanado ganado;
  final List<Visita> visitas;
}

class _PantallaManejoState extends State<PantallaManejo> {
  late Future<_DatosManejo> _datos = _cargar();

  @override
  void initState() {
    super.initState();
    cambiosDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    super.dispose();
  }

  static Future<_DatosManejo> _cargar() async => _DatosManejo(
      await DatosGanado.cargar(),
      await BaseDatosSoleraGanadera.instancia.listarVisitas());

  void _recargar() {
    setState(() {
      _datos = _cargar();
    });
  }

  Future<void> _elegirAlta(List<LoteGanado> lotes) async {
    final eleccion = await showModalBottomSheet<String>(
      context: context,
      builder: (contexto) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.event_note_outlined),
            title: Text(SoleraL10n.t('gana.nueva_tarea_sanitaria')),
            onTap: () => Navigator.pop(contexto, 'tarea'),
          ),
          ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: Text(SoleraL10n.t('gana.nueva_visita')),
            onTap: () => Navigator.pop(contexto, 'visita'),
          ),
        ]),
      ),
    );
    if (!mounted || eleccion == null) return;
    if (eleccion == 'tarea') {
      await mostrarAltaTareaSanitaria(context, lotes);
    } else {
      await mostrarAltaVisita(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('gana.manejo'))),
      body: FutureBuilder<_DatosManejo>(
        future: _datos,
        builder: (context, instantanea) {
          final datos = instantanea.data;
          if (datos == null) {
            return instantanea.hasError
                ? Center(child: Text(SoleraL10n.t('gana.error_cargar')))
                : const Center(child: CircularProgressIndicator());
          }
          final ahora = DateTime.now();
          final ganado = datos.ganado;
          final avisos = avisosSanitarios(
              tareas: ganado.tareas,
              eventos: ganado.eventos,
              lotes: ganado.lotes,
              animales: ganado.animales,
              ahora: ahora);
          final hechas = ganado.tareas.where((tarea) => !tarea.pendiente);
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(SoleraL10n.t('gana.explicacion_calendario'),
                    style: Theme.of(context).textTheme.bodySmall),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TituloBloqueSolera(
                    SoleraL10n.t('gana.calendario_sanitario')),
              ),
              if (avisos.isEmpty)
                ListTile(title: Text(SoleraL10n.t('gana.sin_avisos')))
              else
                for (final aviso in avisos)
                  TarjetaAvisoSanitario(
                      aviso: aviso, lotes: ganado.lotesPorId, ahora: ahora),
              if (hechas.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TituloBloqueSolera(SoleraL10n.t('gana.tareas_hechas')),
                ),
                for (final tarea in hechas.toList().reversed.take(10))
                  ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(tarea.titulo),
                    subtitle: Text(
                        '${nombreTipoTarea(tarea.tipo)} · ${formatearFecha(tarea.hechaMs)}'),
                  ),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TituloBloqueSolera(SoleraL10n.t('gana.visitas')),
              ),
              if (datos.visitas.isEmpty)
                ListTile(title: Text(SoleraL10n.t('gana.sin_visitas')))
              else
                for (final visita in datos.visitas)
                  ListTile(
                    leading: Icon(visita.esVeterinaria
                        ? Icons.medical_services_outlined
                        : Icons.badge_outlined),
                    title: Text(visita.persona),
                    subtitle: Text([
                      formatearFecha(visita.fechaMs),
                      if (visita.motivo.isNotEmpty) visita.motivo,
                      if (visita.vehiculo.isNotEmpty) visita.vehiculo,
                    ].join(' · ')),
                  ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: SoleraL10n.t('gana.anadir'),
        onPressed: () async {
          final lotes = await BaseDatosSoleraGanadera.instancia
              .listarLotes(soloActivos: true);
          await _elegirAlta(lotes);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Un aviso del calendario; si es una tarea, se puede marcar como hecha.
class TarjetaAvisoSanitario extends StatelessWidget {
  const TarjetaAvisoSanitario({
    super.key,
    required this.aviso,
    required this.lotes,
    required this.ahora,
  });

  final AvisoSanitario aviso;
  final Map<int, LoteGanado> lotes;
  final DateTime ahora;

  @override
  Widget build(BuildContext context) {
    final rebano = lotes[aviso.loteId]?.nombre;
    final tarea = aviso.tarea;
    final (icono, titulo) = switch (aviso.tipo) {
      TipoAvisoSanitario.tarea => (Icons.event_note_outlined, tarea!.titulo),
      TipoAvisoSanitario.finSupresionCarne => (
          Icons.no_food_outlined,
          '${SoleraL10n.t('gana.fin_supresion_carne')}: ${aviso.evento?.sustanciaActiva ?? ''}'
        ),
      TipoAvisoSanitario.finSupresionLeche => (
          Icons.water_drop_outlined,
          '${SoleraL10n.t('gana.fin_supresion_leche')}: ${aviso.evento?.sustanciaActiva ?? ''}'
        ),
    };
    final vencido = aviso.vencido(ahora);
    return ListTile(
      leading: Icon(icono, color: vencido ? colorAcentoGanadera : null),
      title: Text(titulo),
      subtitle: Text([
        formatearDia(aviso.dia),
        if (vencido) SoleraL10n.t('gana.atrasada'),
        if (rebano != null) rebano,
      ].join(' · ')),
      trailing: tarea == null
          ? null
          : IconButton(
              tooltip: SoleraL10n.t('gana.marcar_hecha'),
              icon: const Icon(Icons.check),
              onPressed: () async {
                await BaseDatosSoleraGanadera.instancia.guardarTareaSanitaria(
                    tarea.marcarHecha(DateTime.now().millisecondsSinceEpoch));
                avisarCambioDatos();
              },
            ),
    );
  }
}

/// Selector de fecha que muestra la elegida.
Widget selectorFecha(BuildContext context, String etiqueta, DateTime fecha,
        void Function(DateTime) alElegir) =>
    ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today_outlined),
      title: Text(etiqueta),
      subtitle: Text(formatearDia(fecha)),
      onTap: () async {
        final elegida = await showDatePicker(
          context: context,
          initialDate: fecha,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (elegida != null) alElegir(elegida);
      },
    );

/// Desplegable de rebaño, con «toda la explotación» como opción vacía.
Widget selectorLote(
        List<LoteGanado> lotes, int? loteId, void Function(int?) alCambiar,
        {String? textoVacio}) =>
    separarCampoSolera(DropdownButtonFormField<int?>(
      initialValue: loteId,
      decoration: InputDecoration(labelText: SoleraL10n.t('gana.rebano')),
      items: [
        DropdownMenuItem<int?>(
            value: null,
            child:
                Text(textoVacio ?? SoleraL10n.t('gana.toda_la_explotacion'))),
        for (final lote in lotes)
          DropdownMenuItem<int?>(value: lote.id, child: Text(lote.nombre)),
      ],
      onChanged: alCambiar,
    ));

Future<void> mostrarAltaTareaSanitaria(
    BuildContext context, List<LoteGanado> lotes) async {
  final titulo = TextEditingController();
  final notas = TextEditingController();
  var tipo = tiposTareaSanitaria.first;
  int? loteId;
  var fecha = DateTime.now();
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('gana.nueva_tarea_sanitaria'),
    construir: (refrescar) => [
      Text(SoleraL10n.t('gana.tarea_la_planifica_veterinario'),
          style: Theme.of(context).textTheme.bodySmall),
      campoTexto(titulo, SoleraL10n.t('gana.que_hay_que_hacer')),
      separarCampoSolera(DropdownButtonFormField<String>(
        initialValue: tipo,
        decoration: InputDecoration(labelText: SoleraL10n.t('gana.tipo')),
        items: [
          for (final opcion in tiposTareaSanitaria)
            DropdownMenuItem(
                value: opcion, child: Text(nombreTipoTarea(opcion)))
        ],
        onChanged: (valor) => refrescar(() => tipo = valor ?? tipo),
      )),
      selectorLote(lotes, loteId, (valor) => refrescar(() => loteId = valor)),
      selectorFecha(context, SoleraL10n.t('gana.fecha_prevista'), fecha,
          (elegida) => refrescar(() => fecha = elegida)),
      campoTexto(notas, SoleraL10n.t('gana.notas')),
    ],
    guardar: () async {
      if (titulo.text.trim().isEmpty) return false;
      await BaseDatosSoleraGanadera.instancia.guardarTareaSanitaria(
          TareaSanitaria(
              titulo: titulo.text.trim(),
              tipo: tipo,
              loteId: loteId,
              fechaPrevistaMs: fecha.millisecondsSinceEpoch,
              notas: notas.text.trim()));
      return true;
    },
  );
  if (guardado) avisarCambioDatos();
}

Future<void> mostrarAltaVisita(BuildContext context) async {
  final persona = TextEditingController();
  final motivo = TextEditingController();
  final vehiculo = TextEditingController();
  var esVeterinaria = false;
  var fecha = DateTime.now();
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('gana.nueva_visita'),
    construir: (refrescar) => [
      campoTexto(persona, SoleraL10n.t('gana.quien')),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(SoleraL10n.t('gana.es_visita_veterinaria')),
        value: esVeterinaria,
        onChanged: (valor) => refrescar(() => esVeterinaria = valor),
      ),
      campoTexto(motivo, SoleraL10n.t('gana.motivo')),
      campoTexto(vehiculo, SoleraL10n.t('gana.matricula_vehiculo')),
      selectorFecha(context, SoleraL10n.t('gana.fecha'), fecha,
          (elegida) => refrescar(() => fecha = elegida)),
    ],
    guardar: () async {
      if (persona.text.trim().isEmpty) return false;
      await BaseDatosSoleraGanadera.instancia.guardarVisita(Visita(
          fechaMs: fecha.millisecondsSinceEpoch,
          persona: persona.text.trim(),
          motivo: motivo.text.trim(),
          esVeterinaria: esVeterinaria,
          vehiculo: vehiculo.text.trim()));
      return true;
    },
  );
  if (guardado) avisarCambioDatos();
}
