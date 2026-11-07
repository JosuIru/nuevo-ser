import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show DialogoConfirmacion, SoleraL10n, TituloBloqueSolera;

import '../datos/base_datos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/contrato_polinizacion.dart';
import '../modelos/fila_arboles.dart';
import '../modelos/observacion_plaga.dart';
import '../modelos/parcela.dart';
import '../modelos/tratamiento.dart';
import '../utiles/textos_frutal.dart';
import 'formularios_registros.dart';
import 'pantalla_parcelas.dart';

class _DatosFicha {
  _DatosFicha(this.parcela, this.filas, this.contratos, this.observaciones,
      this.tratamientos);

  final Parcela parcela;
  final List<FilaArboles> filas;
  final List<ContratoPolinizacion> contratos;
  final List<ObservacionPlaga> observaciones;
  final List<Tratamiento> tratamientos;
}

/// Ficha de una parcela: datos, filas y variedades, polinización,
/// seguimiento de plagas y últimos tratamientos.
class PantallaFichaParcela extends StatefulWidget {
  const PantallaFichaParcela({super.key, required this.parcelaId});

  final int parcelaId;

  @override
  State<PantallaFichaParcela> createState() => _PantallaFichaParcelaState();
}

class _PantallaFichaParcelaState extends State<PantallaFichaParcela> {
  late Future<_DatosFicha?> _datos;

  @override
  void initState() {
    super.initState();
    _datos = _cargar();
    cambiosDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    super.dispose();
  }

  void _recargar() {
    if (!mounted) return;
    setState(() {
      _datos = _cargar();
    });
  }

  Future<_DatosFicha?> _cargar() async {
    final baseDatos = BaseDatosSoleraFrutal.instancia;
    final parcela = await baseDatos.obtenerParcela(widget.parcelaId);
    if (parcela == null) return null;
    return _DatosFicha(
      parcela,
      await baseDatos.listarFilasArboles(parcelaId: widget.parcelaId),
      await baseDatos.listarContratosPolinizacion(parcelaId: widget.parcelaId),
      await baseDatos.listarObservacionesPlaga(parcelaId: widget.parcelaId),
      await baseDatos.listarTratamientos(parcelaId: widget.parcelaId),
    );
  }

  Future<void> _editar(Parcela parcela) async {
    final guardado = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => PantallaEditarParcela(parcela: parcela)));
    if (guardado == true) avisarCambioDatos();
  }

  Future<void> _borrar(Parcela parcela) async {
    final mensajero = ScaffoldMessenger.of(context);
    final navegador = Navigator.of(context);
    final confirmado = await DialogoConfirmacion.mostrar(context,
        titulo: SoleraL10n.t('borrar'),
        mensaje: parcela.nombre,
        esPeligroso: true);
    if (!confirmado) return;
    try {
      await BaseDatosSoleraFrutal.instancia.borrarParcela(parcela.id!);
      avisarCambioDatos();
      navegador.pop();
    } catch (error) {
      mensajero.showSnackBar(
          SnackBar(content: Text(SoleraL10n.t('frut.parcela_con_registros'))));
    }
  }

  Widget _titulo(String texto, {VoidCallback? alAnadir}) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 0),
        child: Row(
          children: [
            Expanded(child: TituloBloqueSolera(texto)),
            if (alAnadir != null)
              IconButton(
                  tooltip: SoleraL10n.t('frut.anadir'),
                  onPressed: alAnadir,
                  icon: const Icon(Icons.add)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DatosFicha?>(
      future: _datos,
      builder: (context, instantanea) {
        final datos = instantanea.data;
        if (datos == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
                child: instantanea.connectionState == ConnectionState.done
                    ? Text(SoleraL10n.t('frut.error_cargar'))
                    : const CircularProgressIndicator()),
          );
        }
        final parcela = datos.parcela;
        final arbolesPorHa = parcela.arbolesPorHectarea;
        return Scaffold(
          appBar: AppBar(
            title: Text(parcela.nombre),
            actions: [
              IconButton(
                  tooltip: SoleraL10n.t('editar'),
                  onPressed: () => _editar(parcela),
                  icon: const Icon(Icons.edit_outlined)),
              IconButton(
                  tooltip: SoleraL10n.t('borrar'),
                  onPressed: () => _borrar(parcela),
                  icon: const Icon(Icons.delete_outline)),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              ListTile(
                title: Text(nombreEspecie(parcela.especieId)),
                subtitle: Text([
                  '${formatearNumero(parcela.superficieHa, decimales: 2)} ha',
                  if (parcela.variedadPrincipalId.isNotEmpty)
                    parcela.variedadPrincipalId,
                  if (parcela.marcoPlantacion.isNotEmpty)
                    parcela.marcoPlantacion,
                  if (arbolesPorHa != null)
                    SoleraL10n.tf('frut.arboles_por_ha',
                        {'n': formatearNumero(arbolesPorHa, decimales: 0)}),
                  parcela.regadio
                      ? '${SoleraL10n.t('frut.regadio')} (${nombreSistemaRiego(parcela.sistemaRiego)})'
                      : SoleraL10n.t('frut.secano'),
                  if (parcela.codigoSigpac.isNotEmpty)
                    'SIGPAC ${parcela.codigoSigpac}',
                ].join(' · ')),
              ),
              _titulo(SoleraL10n.t('frut.filas_variedades'),
                  alAnadir: () =>
                      mostrarAltaFila(context, parcelaId: parcela.id!)),
              if (datos.filas.isEmpty)
                ListTile(title: Text(SoleraL10n.t('frut.sin_filas')))
              else
                for (final fila in datos.filas)
                  ListTile(
                    leading: Icon(fila.esPolinizadora
                        ? Icons.local_florist_outlined
                        : Icons.forest_outlined),
                    title: Text('${fila.etiqueta} · ${fila.variedadId}'),
                    subtitle: Text([
                      if (fila.numeroArboles > 0)
                        SoleraL10n.tf(
                            'frut.n_arboles', {'n': fila.numeroArboles}),
                      if (fila.esPolinizadora)
                        SoleraL10n.t('frut.es_polinizadora'),
                    ].join(' · ')),
                    onLongPress: () async {
                      await BaseDatosSoleraFrutal.instancia
                          .borrarFilaArboles(fila.id!);
                      avisarCambioDatos();
                    },
                  ),
              _titulo(SoleraL10n.t('frut.polinizacion'),
                  alAnadir: () => mostrarAltaContratoPolinizacion(context,
                      parcelaId: parcela.id!)),
              for (final contrato in datos.contratos)
                ListTile(
                  leading: const Icon(Icons.hive_outlined),
                  title: Text(
                      '${contrato.campania} · ${contrato.apicultorNombre}'),
                  subtitle: Text([
                    SoleraL10n.tf(
                        'frut.n_colmenas', {'n': contrato.numeroColmenas}),
                    if (contrato.colmenasPorHectarea(parcela.superficieHa)
                        case final porHectarea?)
                      SoleraL10n.tf('frut.colmenas_por_ha',
                          {'n': formatearNumero(porHectarea)}),
                    if (contrato.fechaEntradaMs != null)
                      formatearFecha(contrato.fechaEntradaMs!),
                  ].join(' · ')),
                ),
              _titulo(SoleraL10n.t('frut.seguimiento_plagas'),
                  alAnadir: () =>
                      mostrarAltaObservacion(context, parcelaId: parcela.id!)),
              for (final observacion in datos.observaciones.take(10))
                ListTile(
                  leading: Icon(
                      observacion.superaUmbral
                          ? Icons.report_outlined
                          : Icons.visibility_outlined,
                      color: observacion.superaUmbral
                          ? Theme.of(context).colorScheme.error
                          : null),
                  title: Text(observacion.plagaId),
                  subtitle: Text([
                    formatearFecha(observacion.fechaMs),
                    if (observacion.recuento != null)
                      formatearNumero(observacion.recuento!),
                    if (observacion.notas.isNotEmpty) observacion.notas,
                  ].join(' · ')),
                ),
              _titulo(SoleraL10n.t('frut.ultimos_tratamientos'),
                  alAnadir: () =>
                      mostrarAltaTratamiento(context, parcelaId: parcela.id!)),
              for (final tratamiento in datos.tratamientos.take(10))
                ListTile(
                  leading: const Icon(Icons.science_outlined),
                  title: Text(tratamiento.sustanciaActivaId),
                  subtitle: Text([
                    formatearFecha(tratamiento.fechaMs),
                    if (tratamiento.problemaFitosanitario.isNotEmpty)
                      tratamiento.problemaFitosanitario,
                  ].join(' · ')),
                ),
            ],
          ),
        );
      },
    );
  }
}
