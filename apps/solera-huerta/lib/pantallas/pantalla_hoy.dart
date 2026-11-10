import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show AvisoCatalogosProvisionales;
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show CabeceraHoySolera, CifraCabecera, SoleraL10n;
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show AvisoActualizaciones, configActualizacionesMonorepo;

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/flag_revision.dart';
import '../estado/cambios_datos.dart';
import '../estado/datos_huerta.dart';
import '../estado/perfil_huerta.dart';
import '../modelos/tratamiento.dart';
import '../provisional_core/venta_directa/semanas.dart';
import '../utiles/textos_huerta.dart';
import 'formularios_huerta.dart';
import 'selector_perfil.dart';
import '../estado/semana_cestas.dart';

typedef _DatosHoy = ({
  DatosHuerta datos,
  SemanaCestas semana,
  List<Tratamiento> tratamientos,
});

/// Hoy: primeros pasos, siembras que tocan, cestas de la semana, plazos de
/// seguridad abiertos y lo que falta apuntar para el certificador.
class PantallaHoy extends StatefulWidget {
  const PantallaHoy({super.key});

  @override
  State<PantallaHoy> createState() => _PantallaHoyState();
}

class _PantallaHoyState extends State<PantallaHoy> {
  late Future<_DatosHoy> _datos;

  @override
  void initState() {
    super.initState();
    _datos = _cargar();
    cambiosDatos.addListener(_recargar);
    perfilHuerta.addListener(_alCambiarPerfil);
  }

  void _alCambiarPerfil() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    perfilHuerta.removeListener(_alCambiarPerfil);
    super.dispose();
  }

  Future<_DatosHoy> _cargar() async {
    final ahora = DateTime.now();
    final semana = await SemanaCestas.cargar(lunesDeSemana(ahora));
    return (
      datos: semana.datos,
      semana: semana,
      tratamientos: await BaseDatosSoleraHuerta.instancia.listarTratamientos(
        desdeMs: ahora
            .subtract(const Duration(days: 120))
            .millisecondsSinceEpoch,
      ),
    );
  }

  void _recargar() {
    if (!mounted) return;
    setState(() {
      _datos = _cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<_DatosHoy>(
        future: _datos,
        builder: (context, instantanea) {
          final cargado = instantanea.data;
          final datos = cargado?.datos;
          // Cabecera común de la suite (como el resto de verticales).
          final cabecera = CabeceraHoySolera(
            titulo: 'Larrea Huerta',
            fecha: DateFormat.MMMMEEEEd(
              SoleraL10n.idioma,
            ).format(DateTime.now()),
            rutaLogo: 'assets/icono-logo-huerta.png',
            cifras: [
              CifraCabecera(
                valor: '${datos?.parcelas.length ?? 0}',
                etiqueta: SoleraL10n.t('huer.parcelas'),
              ),
              CifraCabecera(
                valor: '${datos?.bancales.length ?? 0}',
                etiqueta: SoleraL10n.t('huer.bancales'),
              ),
              CifraCabecera(
                valor: '${datos?.cultivos.length ?? 0}',
                etiqueta: SoleraL10n.t('huer.cultivos'),
              ),
            ],
          );
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              cabecera,
              // Aviso de versión nueva: si no la hay, no ocupa sitio.
              AvisoActualizaciones(
                config: configActualizacionesMonorepo('solera-huerta'),
                nombreApp: 'Larrea Huerta',
              ),
              if (!catalogosCompletamenteRevisados)
                AvisoCatalogosProvisionales(
                  texto: SoleraL10n.t('huer.catalogos_provisionales'),
                ),
              if (cargado != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _tarjetas(context, cargado),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _tarjetas(BuildContext context, _DatosHoy cargado) {
    final datos = cargado.datos;
    final ahora = DateTime.now();
    final estilo = Theme.of(context).textTheme.titleMedium;
    if (datos.parcelas.isEmpty || datos.cultivos.isEmpty) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(SoleraL10n.t('huer.primeros_pasos'), style: estilo),
                const SizedBox(height: 8),
                Text(SoleraL10n.t(esHuertoDeCasa
                    ? 'huer.primeros_pasos_texto_casa'
                    : 'huer.primeros_pasos_texto')),
                const SizedBox(height: 12),
                const SelectorPerfilHuerta(),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (datos.parcelas.isEmpty)
                      FilledButton.tonal(
                        onPressed: () => mostrarFormularioParcela(context),
                        child: Text(SoleraL10n.t('huer.nueva_parcela')),
                      ),
                    if (datos.cultivos.isEmpty)
                      FilledButton.tonal(
                        onPressed: () => mostrarFormularioCultivo(context),
                        child: Text(SoleraL10n.t('huer.nuevo_cultivo')),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ];
    }
    final limite = ahora.add(const Duration(days: 14)).millisecondsSinceEpoch;
    final porSembrar = [
      for (final siembra in datos.siembras)
        if (!siembra.realizada && siembra.fechaPrevistaMs <= limite) siembra,
    ]..sort((a, b) => a.fechaPrevistaMs.compareTo(b.fechaPrevistaMs));
    final plazosAbiertos = [
      for (final tratamiento in cargado.tratamientos)
        if (tratamiento.finPlazoSeguridad?.isAfter(ahora) ?? false) tratamiento,
    ];
    final semana = cargado.semana;
    final queTocan = semana.queTocan;
    final compuestas = queTocan
        .where((s) => semana.cestaDe(s.id!) != null)
        .length;
    final entregadas = queTocan.where((s) {
      final cesta = semana.cestaDe(s.id!);
      return cesta != null && semana.entregaDe(cesta.id!) != null;
    }).length;
    final pendientesCertificador = [
      for (final lote in datos.lotes)
        if (lote.faltaAutorizacion)
          SoleraL10n.tf('huer.lote_sin_autorizacion', {'lote': lote.codigo}),
      for (final insumo in datos.insumos)
        if (insumo.faltaJustificante)
          SoleraL10n.tf('huer.insumo_sin_justificante', {
            'insumo': insumo.nombre,
          }),
    ];
    return [
      Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: Text(
                SoleraL10n.t('huer.siembras_proximas'),
                style: estilo,
              ),
              subtitle: porSembrar.isEmpty
                  ? Text(SoleraL10n.t('huer.nada_por_sembrar'))
                  : null,
            ),
            for (final siembra in porSembrar.take(8))
              ListTile(
                dense: true,
                leading: Icon(
                  siembra.fechaPrevistaMs < ahora.millisecondsSinceEpoch
                      ? Icons.warning_amber_outlined
                      : Icons.schedule_outlined,
                ),
                title: Text(datos.nombreDeCultivo(siembra.cultivoId)),
                subtitle: Text(
                  [
                    datos.nombreDeBancal(siembra.bancalId),
                    formatearFecha(siembra.fechaPrevistaMs),
                    if (datos.avisoRotacion(
                          bancalId: siembra.bancalId,
                          cultivoId: siembra.cultivoId,
                          fecha: DateTime.fromMillisecondsSinceEpoch(
                            siembra.fechaPrevistaMs,
                          ),
                          excluirSiembraId: siembra.id,
                        ) !=
                        null)
                      SoleraL10n.t('huer.rotacion_corta'),
                  ].join(' · '),
                ),
                onTap: () => mostrarFormularioSiembra(
                  context,
                  datos: datos,
                  siembra: siembra,
                ),
              ),
          ],
        ),
      ),
      if (!esHuertoDeCasa)
      Card(
        child: ListTile(
          leading: const Icon(Icons.shopping_basket_outlined),
          title: Text(SoleraL10n.t('huer.cestas_esta_semana'), style: estilo),
          subtitle: Text(
            SoleraL10n.tf('huer.resumen_cestas', {
              'total': queTocan.length,
              'compuestas': compuestas,
              'entregadas': entregadas,
            }),
          ),
        ),
      ),
      if (plazosAbiertos.isNotEmpty)
        Card(
          child: Column(
            children: [
              ListTile(
                title: Text(
                  SoleraL10n.t('huer.plazos_abiertos'),
                  style: estilo,
                ),
              ),
              for (final tratamiento in plazosAbiertos)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.timer_outlined),
                  title: Text(
                    datos.insumo(tratamiento.insumoId)?.nombre ?? '?',
                  ),
                  subtitle: Text(
                    [
                      tratamiento.bancalId == null
                          ? (datos.parcela(tratamiento.parcelaId)?.nombre ??
                                '?')
                          : datos.nombreDeBancal(tratamiento.bancalId!),
                      SoleraL10n.tf('huer.cosechar_desde', {
                        'fecha': formatearFechaDia(
                          tratamiento.finPlazoSeguridad!,
                        ),
                      }),
                    ].join(' · '),
                  ),
                ),
            ],
          ),
        ),
      if (pendientesCertificador.isNotEmpty && !esHuertoDeCasa)
        Card(
          child: Column(
            children: [
              ListTile(
                title: Text(
                  SoleraL10n.t('huer.pendiente_certificador'),
                  style: estilo,
                ),
              ),
              for (final texto in pendientesCertificador)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.assignment_late_outlined),
                  title: Text(texto),
                ),
            ],
          ),
        ),
    ];
  }
}
