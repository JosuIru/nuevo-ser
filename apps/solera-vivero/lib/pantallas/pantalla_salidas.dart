import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, rellenoInferiorSeguro;

import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../dominio/pasaporte.dart';
import '../estado/cambios_datos.dart';
import '../modelos/partida_planta.dart';
import '../modelos/pasaporte_emitido.dart';
import '../modelos/salida.dart';
import '../modelos/vivero.dart';
import '../servicios/compartir_documento.dart';
import '../servicios/generador_pasaporte_pdf.dart';
import '../utiles/textos_vivero.dart';
import 'formularios.dart';
import 'hoja_formulario.dart';
import 'pantalla_documentos.dart';
import 'vista_carga.dart';

/// Necesidad de pasaporte de una salida de planta. Todos los vegetales
/// para plantación salvo las semillas lo necesitan (Reglamento de Ejecución
/// (UE) 2019/2072, anexo XIII, punto 1): una partida es planta, así que la
/// especie no cambia la respuesta; mandan las marcas de destino.
NecesidadPasaporte necesidadDeSalida(Salida salida) =>
    evaluarNecesidadPasaporte(salida, necesitaPasaporteEspecie: true);

class _DatosSalidas {
  _DatosSalidas(this.salidas, this.partidas, this.pasaportes);
  final List<Salida> salidas;
  final Map<int, PartidaPlanta> partidas;
  final List<PasaporteEmitido> pasaportes;

  bool tienePasaporte(int salidaId) => pasaportes
      .any((pasaporte) => pasaporte.salidaId == salidaId && !pasaporte.anulado);
}

/// Pestaña Salidas: ventas y entregas del año, con el estado del pasaporte,
/// y el registro de pasaportes.
class PantallaSalidas extends StatefulWidget {
  const PantallaSalidas({super.key});

  @override
  State<PantallaSalidas> createState() => _PantallaSalidasState();
}

class _PantallaSalidasState extends State<PantallaSalidas> {
  int _anyo = DateTime.now().year;

  Future<_DatosSalidas> _cargar() async {
    final bd = BaseDatosSoleraVivero.instancia;
    final (desde, hasta) = intervaloAnyo(_anyo);
    return _DatosSalidas(
      await bd.listarSalidas(desdeMs: desde, hastaMs: hasta),
      {for (final partida in await bd.listarPartidas()) partida.id!: partida},
      await bd.listarPasaportes(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final anyoActual = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('vive.salidas')),
        actions: [
          IconButton(
            tooltip: SoleraL10n.t('vive.documentos'),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaDocumentos())),
          ),
          DropdownButton<int>(
            value: _anyo,
            underline: const SizedBox.shrink(),
            items: [
              for (var anyo = anyoActual; anyo >= anyoActual - 3; anyo--)
                DropdownMenuItem(value: anyo, child: Text('$anyo')),
            ],
            onChanged: (valor) => setState(() {
              _anyo = valor ?? anyoActual;
            }),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: VistaCarga<_DatosSalidas>(
        key: ValueKey(_anyo),
        cargar: _cargar,
        construir: (context, datos) {
          if (datos.salidas.isEmpty) {
            return ListaVacia(SoleraL10n.t('vive.sin_salidas_ayuda'));
          }
          return ListView(
            children: [
              for (final salida in datos.salidas)
                _filaSalida(context, salida, datos),
            ],
          );
        },
      ),
    );
  }

  Widget _filaSalida(BuildContext context, Salida salida, _DatosSalidas datos) {
    final partida = datos.partidas[salida.partidaId];
    final necesidad = necesidadDeSalida(salida);
    final exige = necesidadExigePasaporte(necesidad);
    final tiene = datos.tienePasaporte(salida.id!);
    return ListTile(
      leading: Icon(
        !exige
            ? Icons.remove_circle_outline
            : tiene
                ? Icons.verified_outlined
                : Icons.pending_actions_outlined,
        color: exige && !tiene ? Theme.of(context).colorScheme.error : null,
      ),
      title: Text(
          '${partida == null ? '—' : etiquetaPartida(partida)} · ${salida.cantidad}'),
      subtitle: Text([
        formatearFecha(salida.fechaMs),
        if (salida.clienteNombre.isNotEmpty) salida.clienteNombre,
        exige
            ? (tiene
                ? SoleraL10n.t('vive.pasaporte_preparado')
                : SoleraL10n.t('vive.pasaporte_pendiente'))
            : textoNecesidadPasaporte(necesidad),
      ].join(' · ')),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => abrirFichaSalida(context, salida.id!),
    );
  }
}

Future<void> abrirFichaSalida(
        BuildContext context, int salidaId) =>
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PantallaFichaSalida(salidaId: salidaId)));

class _DatosFichaSalida {
  _DatosFichaSalida(this.salida, this.partida, this.vivero, this.pasaportes);
  final Salida? salida;
  final PartidaPlanta? partida;
  final Vivero vivero;
  final List<PasaporteEmitido> pasaportes;
}

/// Ficha de la salida: si necesita pasaporte, los datos A-D y el registro
/// de los pasaportes preparados para ella.
class PantallaFichaSalida extends StatelessWidget {
  const PantallaFichaSalida({super.key, required this.salidaId});
  final int salidaId;

  Future<_DatosFichaSalida> _cargar() async {
    final bd = BaseDatosSoleraVivero.instancia;
    final salida = await bd.obtenerSalida(salidaId);
    return _DatosFichaSalida(
      salida,
      salida == null ? null : await bd.obtenerPartida(salida.partidaId),
      await bd.obtenerVivero(),
      await bd.listarPasaportes(salidaId: salidaId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return VistaCarga<_DatosFichaSalida>(
      cargar: _cargar,
      construir: (context, datos) {
        final salida = datos.salida;
        final partida = datos.partida;
        if (salida == null || partida == null) return const Scaffold();
        final necesidad = necesidadDeSalida(salida);
        final preparados = prepararDatosPasaporte(
            vivero: datos.vivero, partida: partida, salida: salida);
        return Scaffold(
          appBar: AppBar(
            title: Text(SoleraL10n.tf('vive.salida_del', {
              'fecha': formatearFecha(salida.fechaMs),
            })),
            actions: [
              if (datos.pasaportes.isEmpty)
                IconButton(
                  tooltip: SoleraL10n.t('borrar'),
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    if (!await confirmar(
                        context, SoleraL10n.t('vive.borrar_salida'))) {
                      return;
                    }
                    await BaseDatosSoleraVivero.instancia
                        .borrarSalida(salida.id!);
                    avisarCambioDatos();
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
            ],
          ),
          body: ListView(
            padding: rellenoInferiorSeguro(context, const EdgeInsets.only(bottom: 24)),
            children: [
              ListTile(
                title: Text(etiquetaPartida(partida)),
                subtitle: Text([
                  SoleraL10n.tf('vive.plantas_n', {'n': salida.cantidad}),
                  if (salida.clienteNombre.isNotEmpty) salida.clienteNombre,
                  if (salida.clienteCodigoRopveg.isNotEmpty)
                    salida.clienteCodigoRopveg,
                  if (salida.importeCentimos > 0)
                    formatearEuros(salida.importeCentimos),
                ].join(' · ')),
              ),
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(textoNecesidadPasaporte(necesidad),
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Text(SoleraL10n.t('vive.decision_del_operador'),
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ),
              TituloSeccion(SoleraL10n.t('vive.datos_pasaporte')),
              ListTile(
                  dense: true,
                  title: const Text('A'),
                  subtitle: Text(
                      preparados.letraA.isEmpty ? '—' : preparados.letraA)),
              ListTile(
                  dense: true,
                  title: const Text('B'),
                  subtitle: Text(preparados.codigoOperador.isEmpty
                      ? '—'
                      : preparados.codigoOperador)),
              ListTile(
                  dense: true,
                  title: const Text('C'),
                  subtitle: Text(preparados.codigoTrazabilidad)),
              ListTile(
                  dense: true,
                  title: const Text('D'),
                  subtitle: Text(preparados.paisOrigen.isEmpty
                      ? '—'
                      : preparados.paisOrigen)),
              for (final falta in preparados.faltan)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.error_outline),
                  title: Text(textoDatoFaltante(falta)),
                ),
              if (especiePorId(partida.especieId)?.anexoXivZonaProtegida ==
                  true)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.shield_outlined),
                  title: Text(SoleraL10n.t('vive.especie_anexo_xiv')),
                ),
              if (!datos.vivero.autorizadoPasaporte)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.info_outline),
                  title: Text(SoleraL10n.t('vive.sin_autorizacion_borrador')),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.icon(
                  icon: const Icon(Icons.assignment_outlined),
                  label: Text(SoleraL10n.t('vive.preparar_pasaporte')),
                  onPressed: () => mostrarFormularioPasaporte(
                      context, datos.vivero, partida, salida),
                ),
              ),
              TituloSeccion(SoleraL10n.t('vive.pasaportes_registrados')),
              if (datos.pasaportes.isEmpty)
                ListaVacia(SoleraL10n.t('vive.sin_pasaportes')),
              for (final pasaporte in datos.pasaportes)
                ListTile(
                  leading: Icon(pasaporte.anulado
                      ? Icons.block
                      : pasaporte.esBorrador
                          ? Icons.edit_note
                          : Icons.verified_outlined),
                  title: Text(
                      '${pasaporte.esZonaProtegida ? 'ZP · ' : ''}${pasaporte.codigoTrazabilidad} · ${pasaporte.cantidad}'),
                  subtitle: Text([
                    formatearFecha(pasaporte.fechaMs),
                    if (pasaporte.anulado) SoleraL10n.t('vive.anulado'),
                    if (pasaporte.esBorrador) SoleraL10n.t('vive.borrador'),
                  ].join(' · ')),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                      tooltip: SoleraL10n.t('vive.etiqueta_pdf'),
                      icon: const Icon(Icons.print_outlined),
                      onPressed: () => compartirDocumentoPdf(
                        context,
                        nombreFichero:
                            'pasaporte_${pasaporte.codigoTrazabilidad}.pdf',
                        generar: (tema) => generarEtiquetaPasaportePdf(
                            datosDesdeRegistro(pasaporte,
                                operadorAutorizado:
                                    datos.vivero.autorizadoPasaporte),
                            tema: tema),
                      ),
                    ),
                    if (!pasaporte.anulado)
                      IconButton(
                        tooltip: SoleraL10n.t('vive.anular'),
                        icon: const Icon(Icons.block),
                        onPressed: () async {
                          if (!await confirmar(
                              context, SoleraL10n.t('vive.anular_pasaporte'))) {
                            return;
                          }
                          await BaseDatosSoleraVivero.instancia
                              .anularPasaporte(pasaporte);
                          avisarCambioDatos();
                        },
                      ),
                  ]),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Registra los datos del pasaporte de la salida (foto de las letras A-D).
/// Sin autorización del vivero, o con datos que faltan, queda como borrador.
Future<bool> mostrarFormularioPasaporte(BuildContext context, Vivero vivero,
    PartidaPlanta partida, Salida salida) async {
  final plagasZp = TextEditingController();
  final preparadoPor = TextEditingController(
      text: vivero.personaContactoFitosanitaria.isEmpty
          ? vivero.nombre
          : vivero.personaContactoFitosanitaria);
  final guardado = await mostrarHojaFormulario(
    context,
    titulo: SoleraL10n.t('vive.preparar_pasaporte'),
    construir: (refrescar) => [
      Text(SoleraL10n.t('vive.preparar_pasaporte_ayuda')),
      if (salida.destinoZonaProtegida)
        campoTexto(plagasZp, SoleraL10n.t('vive.plagas_zona_protegida'),
            ayuda: SoleraL10n.t('vive.plagas_zona_protegida_ayuda')),
      campoTexto(preparadoPor, SoleraL10n.t('vive.preparado_por')),
    ],
    guardar: () async {
      final datos = prepararDatosPasaporte(
          vivero: vivero,
          partida: partida,
          salida: salida,
          plagasZonaProtegida: plagasZp.text);
      await BaseDatosSoleraVivero.instancia.guardarPasaporte(PasaporteEmitido(
        salidaId: salida.id!,
        fechaMs: DateTime.now().millisecondsSinceEpoch,
        esZonaProtegida: datos.esZonaProtegida,
        nombreBotanico: datos.nombreBotanico,
        variedad: datos.variedad,
        codigoOperador: datos.codigoOperador,
        codigoTrazabilidad: datos.codigoTrazabilidad,
        paisOrigen: datos.paisOrigen,
        plagasZonaProtegida: datos.plagasZonaProtegida,
        cantidad: datos.cantidad,
        preparadoPor: preparadoPor.text.trim(),
        esBorrador: datos.esBorrador,
      ));
      avisarCambioDatos();
      return true;
    },
  );
  liberarControladores([plagasZp, preparadoPor]);
  return guardado;
}
