import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show AvisoCatalogosProvisionales;
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show CabeceraHoySolera, CifraCabecera, SoleraL10n, TituloBloqueSolera;

import '../branding.dart';
import '../datos/base_datos.dart';
import '../datos/catalogos_generados/flag_revision.dart';
import '../datos/estado_bodega.dart';
import '../dominio/campania.dart';
import '../estado/cambios_datos.dart';
import '../modelos/partida_manzana.dart';
import '../modelos/sagardotegi.dart';
import '../modelos/tratamiento.dart';
import '../utiles/textos_sidra.dart';
import 'hoja_formulario.dart';
import 'pantalla_bienvenida.dart';
import 'pantalla_kupela.dart';
import 'pantalla_partidas.dart';
import 'pantalla_prensados.dart';
import 'pantalla_txotx.dart';

/// Lo del día: lo que hay en bodega, el txotx de hoy y lo que queda por
/// apuntar.
class PantallaHoy extends StatefulWidget {
  const PantallaHoy({super.key});

  @override
  State<PantallaHoy> createState() => _PantallaHoyState();
}

class _DatosHoy {
  _DatosHoy(this.sagardotegi, this.estado, this.partidas, this.prensadas,
      this.tratamientos);

  final Sagardotegi sagardotegi;
  final EstadoBodega estado;
  final List<PartidaManzana> partidas;
  final Set<int> prensadas;
  final List<Tratamiento> tratamientos;
}

class _PantallaHoyState extends State<PantallaHoy> {
  late Future<_DatosHoy> _datos;

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
    setState(() {
      _datos = _cargar();
    });
  }

  Future<_DatosHoy> _cargar() async {
    final baseDatos = BaseDatosSoleraSidra.instancia;
    final rango = rangoCampania(campaniaDe(DateTime.now()));
    return _DatosHoy(
      await baseDatos.obtenerSagardotegi(),
      await EstadoBodega.cargar(),
      await baseDatos.listarPartidas(
          desdeMs: rango.desdeMs, hastaMs: rango.hastaMs),
      await baseDatos.partidasPrensadas(),
      await baseDatos.listarTratamientos(
          desdeMs: rango.desdeMs, hastaMs: rango.hastaMs),
    );
  }

  Future<void> _abrir(Widget pantalla) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<_DatosHoy>(
        future: _datos,
        builder: (context, instantanea) {
          final datos = instantanea.data;
          final fecha =
              DateFormat.MMMMEEEEd(SoleraL10n.idioma).format(DateTime.now());
          final kilosCampania = datos?.partidas
                  .fold<double>(0, (suma, partida) => suma + partida.kilos) ??
              0;
          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              CabeceraHoySolera(
                titulo: datos == null || datos.sagardotegi.estaSinConfigurar
                    ? 'Larrea Sagardoa'
                    : datos.sagardotegi.nombre,
                rutaLogo: rutaLogoSidra,
                fecha: fecha,
                acciones: [
                  IconButton(
                    tooltip: SoleraL10n.t('sidr.entradas_fruta'),
                    icon: const Icon(Icons.local_shipping_outlined),
                    onPressed: () => _abrir(const PantallaPartidas()),
                  ),
                  IconButton(
                    tooltip: SoleraL10n.t('sidr.prensados'),
                    icon: const Icon(Icons.compress_outlined),
                    onPressed: () => _abrir(const PantallaPrensados()),
                  ),
                  if (datos != null && datos.sagardotegi.abreTxotx)
                    IconButton(
                      tooltip: SoleraL10n.t('sidr.abrir_kupela'),
                      icon: const Icon(Icons.local_bar_outlined),
                      onPressed: () =>
                          mostrarAltaSesionTxotx(context, datos.estado),
                    ),
                ],
                cifras: [
                  CifraCabecera(
                      valor: formatearLitros(datos?.estado.saldo
                              .litrosTotales(datos.estado.kupelas) ??
                          0),
                      etiqueta: SoleraL10n.t('sidr.en_bodega')),
                  CifraCabecera(
                      valor:
                          '${formatearNumero(kilosCampania, decimales: 0)} kg',
                      etiqueta: SoleraL10n.t('sidr.fruta_campania')),
                ],
              ),
              if (datos != null && datos.sagardotegi.estaSinConfigurar)
                Card(
                  margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: ListTile(
                    leading: const Icon(Icons.waving_hand_outlined),
                    title: Text(SoleraL10n.t('sidr.bienvenida_titulo')),
                    subtitle: Text(SoleraL10n.t('sidr.bienvenida_texto')),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _abrir(const PantallaBienvenida()),
                  ),
                ),
              if (!catalogosCompletamenteRevisados)
                AvisoCatalogosProvisionales(texto: SoleraL10n.t('sidr.catalogos_provisionales')),
              if (instantanea.hasError)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(SoleraL10n.t('sidr.error_cargar')),
                ),
              if (datos != null) ..._bloques(context, datos),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _bloques(BuildContext context, _DatosHoy datos) {
    final estado = datos.estado;
    final ahora = DateTime.now();
    final inicioDia =
        DateTime(ahora.year, ahora.month, ahora.day).millisecondsSinceEpoch;
    final sesionesHoy = estado.sesionesTxotx
        .where((sesion) =>
            sesion.fechaMs >= inicioDia &&
            sesion.fechaMs < inicioDia + const Duration(days: 1).inMilliseconds)
        .toList();
    final sinPrensar = datos.partidas
        .where((partida) => !datos.prensadas.contains(partida.id))
        .length;
    final incompletos = datos.tratamientos
        .where((tratamiento) => tratamiento.estaIncompleto)
        .length;
    final descuadradas = estado.kupelas
        .where((kupela) =>
            estado.saldo.quedaEnNegativo(kupela.id!) ||
            estado.saldo.superaCapacidad(kupela))
        .toList();
    final etiquetasDescuadradas = estado.embotellados
        .where((embotellado) => embotellado.etiquetasDescuadradas)
        .length;
    return [
      if (datos.sagardotegi.abreTxotx) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TituloBloqueSolera(SoleraL10n.t('sidr.txotx_de_hoy')),
        ),
        if (sesionesHoy.isEmpty)
          ListTile(title: Text(SoleraL10n.t('sidr.sin_txotx_hoy')))
        else
          for (final sesion in sesionesHoy)
            ListTile(
              leading: const Icon(Icons.local_bar_outlined),
              title: Text(estado.etiquetaKupela(sesion.kupelaId)),
              trailing: Text(formatearLitros(sesion.litrosServidos)),
            ),
      ],
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TituloBloqueSolera(SoleraL10n.t('sidr.kupelas')),
      ),
      if (estado.kupelasConContenido.isEmpty)
        ListTile(title: Text(SoleraL10n.t('sidr.sin_kupelas_llenas')))
      else
        for (final kupela in estado.kupelasConContenido)
          ListTile(
            dense: true,
            leading: const Icon(Icons.propane_tank_outlined),
            title: Text(kupela.etiqueta),
            trailing: Text(formatearLitros(estado.saldo.litrosEn(kupela.id!))),
            onTap: () => _abrir(PantallaKupela(kupelaId: kupela.id!)),
          ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: TituloBloqueSolera(SoleraL10n.t('sidr.por_revisar')),
      ),
      if (sinPrensar == 0 &&
          incompletos == 0 &&
          descuadradas.isEmpty &&
          etiquetasDescuadradas == 0)
        ListTile(title: Text(SoleraL10n.t('sidr.nada_por_revisar'))),
      if (sinPrensar > 0)
        ListTile(
          leading: const Icon(Icons.local_shipping_outlined),
          title: Text(
              SoleraL10n.tf('sidr.partidas_sin_prensar', {'n': sinPrensar})),
          onTap: () => _abrir(const PantallaPrensados()),
        ),
      if (incompletos > 0)
        ListTile(
          leading: const Icon(Icons.sanitizer_outlined),
          title: Text(SoleraL10n.tf(
              'sidr.tratamientos_incompletos', {'n': incompletos})),
        ),
      for (final kupela in descuadradas)
        ListTile(
          leading: const Icon(Icons.warning_amber_outlined),
          title: Text(SoleraL10n.tf(
              'sidr.kupela_descuadrada', {'kupela': kupela.etiqueta})),
          onTap: () => _abrir(PantallaKupela(kupelaId: kupela.id!)),
        ),
      if (etiquetasDescuadradas > 0)
        ListTile(
          leading: const Icon(Icons.label_off_outlined),
          title: Text(SoleraL10n.tf('sidr.lotes_etiquetas_descuadradas',
              {'n': etiquetasDescuadradas})),
        ),
    ];
  }
}
