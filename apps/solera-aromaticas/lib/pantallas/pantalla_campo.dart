import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../dominio/recoleccion.dart';
import '../estado/cambios_datos.dart';
import '../modelos/cosecha.dart';
import '../modelos/parcela.dart';
import '../modelos/tratamiento.dart';
import '../modelos/zona_recoleccion.dart';
import '../utiles/textos_aromaticas.dart';
import 'formularios.dart';
import 'identificar_con_ia.dart';
import 'pantalla_editar_origen.dart';

class _DatosCampo {
  _DatosCampo(this.parcelas, this.zonas, this.cosechas, this.tratamientos);

  final List<Parcela> parcelas;
  final List<ZonaRecoleccion> zonas;

  /// Cosechas del año en curso.
  final List<Cosecha> cosechas;
  final List<Tratamiento> tratamientos;
}

/// El campo: parcelas de cultivo, zonas de recolección con su permiso, el
/// cuaderno de cosechas y recolección del año y los tratamientos.
class PantallaCampo extends StatefulWidget {
  const PantallaCampo({super.key});

  @override
  State<PantallaCampo> createState() => _PantallaCampoState();
}

class _PantallaCampoState extends State<PantallaCampo>
    with SingleTickerProviderStateMixin {
  late final TabController _pestanas = TabController(length: 4, vsync: this)
    ..addListener(() => setState(() {}));
  late Future<_DatosCampo> _datos = _cargar();

  @override
  void initState() {
    super.initState();
    cambiosDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    _pestanas.dispose();
    super.dispose();
  }

  void _recargar() {
    if (!mounted) return;
    setState(() {
      _datos = _cargar();
    });
  }

  Future<_DatosCampo> _cargar() async {
    final bd = BaseDatosSoleraAromaticas.instancia;
    final (desde, hasta) = intervaloAnyo(DateTime.now().year);
    return _DatosCampo(
      await bd.listarParcelas(),
      await bd.listarZonasRecoleccion(),
      await bd.listarCosechas(desdeMs: desde, hastaMs: hasta),
      await bd.listarTratamientos(desdeMs: desde, hastaMs: hasta),
    );
  }

  Future<void> _nuevo() async {
    switch (_pestanas.index) {
      case 0:
        await abrirEdicionParcela(context);
      case 1:
        await abrirEdicionZona(context);
      case 2:
        await mostrarAltaCosecha(context);
      default:
        await mostrarAltaTratamiento(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final etiquetasBoton = [
      'arom.nueva_parcela',
      'arom.nueva_zona',
      'arom.nueva_cosecha',
      'arom.nuevo_tratamiento',
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(SoleraL10n.t('arom.campo')),
        actions: [
          PopupMenuButton<String>(
            tooltip: SoleraL10n.t('arom.ia_identificar'),
            icon: const Icon(Icons.document_scanner_outlined),
            onSelected: (opcion) => opcion == 'especie'
                ? identificarEspecieConFoto(context)
                : identificarPlagaConFoto(context),
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'especie',
                  child: Text(SoleraL10n.t('arom.ia_identificar_especie'))),
              PopupMenuItem(
                  value: 'plaga',
                  child: Text(SoleraL10n.t('arom.ia_identificar_plaga'))),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _pestanas,
          isScrollable: true,
          tabs: [
            Tab(text: SoleraL10n.t('arom.parcelas')),
            Tab(text: SoleraL10n.t('arom.zonas')),
            Tab(text: SoleraL10n.t('arom.cosechas')),
            Tab(text: SoleraL10n.t('arom.tratamientos')),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _nuevo,
        icon: const Icon(Icons.add),
        label: Text(SoleraL10n.t(etiquetasBoton[_pestanas.index])),
      ),
      body: FutureBuilder<_DatosCampo>(
        future: _datos,
        builder: (context, instantanea) {
          final datos = instantanea.data;
          if (instantanea.hasError) {
            return Center(child: Text(SoleraL10n.t('arom.error_cargar')));
          }
          if (datos == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _pestanas,
            children: [
              _ListaParcelas(datos: datos),
              _ListaZonas(datos: datos),
              _ListaCosechas(datos: datos),
              _ListaTratamientos(datos: datos),
            ],
          );
        },
      ),
    );
  }
}

Widget _vacio(String clave) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(SoleraL10n.t(clave), textAlign: TextAlign.center),
      ),
    );

class _ListaParcelas extends StatelessWidget {
  const _ListaParcelas({required this.datos});

  final _DatosCampo datos;

  @override
  Widget build(BuildContext context) {
    if (datos.parcelas.isEmpty) return _vacio('arom.sin_parcelas');
    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        for (final parcela in datos.parcelas)
          ListTile(
            leading: const Icon(Icons.grass_outlined),
            title: Text(parcela.nombre),
            subtitle: Text([
              nombreEspecie(parcela.especieId),
              if (parcela.ecologico) SoleraL10n.t('arom.ecologico'),
              if (parcela.codigoSigpac.isNotEmpty) parcela.codigoSigpac,
            ].join(' · ')),
            trailing: Text(
                '${formatearNumero(parcela.superficieHa, decimales: 2)} ha'),
            onTap: () => abrirEdicionParcela(context, parcela: parcela),
            onLongPress: () => confirmarYBorrar(
                context,
                () => BaseDatosSoleraAromaticas.instancia
                    .borrarParcela(parcela.id!)),
          ),
      ],
    );
  }
}

class _ListaZonas extends StatelessWidget {
  const _ListaZonas({required this.datos});

  final _DatosCampo datos;

  @override
  Widget build(BuildContext context) {
    if (datos.zonas.isEmpty) return _vacio('arom.sin_zonas');
    final hoy = DateTime.now();
    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(SoleraL10n.t('arom.zonas_explicacion'),
              style: Theme.of(context).textTheme.bodySmall),
        ),
        for (final zona in datos.zonas)
          ListTile(
            leading: Icon(
              zona.vigenteEn(hoy)
                  ? Icons.verified_outlined
                  : Icons.report_gmailerrorred_outlined,
              color: zona.vigenteEn(hoy)
                  ? null
                  : Theme.of(context).colorScheme.error,
            ),
            title: Text(zona.nombre),
            subtitle: Text(_resumenPermiso(zona, datos.cosechas, hoy)),
            onTap: () => abrirEdicionZona(context, zona: zona),
            onLongPress: () => confirmarYBorrar(
                context,
                () => BaseDatosSoleraAromaticas.instancia
                    .borrarZonaRecoleccion(zona.id!)),
          ),
      ],
    );
  }
}

/// «Permiso X · hasta dd/mm/aaaa · 120 de 500 kg» o «Sin permiso apuntado».
String _resumenPermiso(
    ZonaRecoleccion zona, List<Cosecha> cosechas, DateTime hoy) {
  if (!zona.tienePermiso) return SoleraL10n.t('arom.sin_permiso_apuntado');
  final partes = <String>[
    SoleraL10n.tf('arom.permiso_n', {'numero': zona.numeroPermiso}),
    if (zona.finVigenciaMs != null)
      SoleraL10n.tf(zona.vigenteEn(hoy) ? 'arom.hasta' : 'arom.caducado',
          {'fecha': formatearFecha(zona.finVigenciaMs!)}),
  ];
  final usados = kgRecolectadosEnVigencia(zona, cosechas);
  partes.add(zona.limiteKg == null
      ? SoleraL10n.tf('arom.kg_recolectados', {'kg': formatearNumero(usados)})
      : SoleraL10n.tf('arom.kg_de_limite', {
          'kg': formatearNumero(usados),
          'limite': formatearNumero(zona.limiteKg!),
        }));
  return partes.join(' · ');
}

class _ListaCosechas extends StatelessWidget {
  const _ListaCosechas({required this.datos});

  final _DatosCampo datos;

  @override
  Widget build(BuildContext context) {
    if (datos.cosechas.isEmpty) return _vacio('arom.sin_cosechas');
    final parcelas = {for (final p in datos.parcelas) p.id: p.nombre};
    final zonas = {for (final z in datos.zonas) z.id: z.nombre};
    final total = datos.cosechas
        .fold<double>(0, (suma, cosecha) => suma + cosecha.kgFrescos);
    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        ListTile(
          title: Text(SoleraL10n.tf('arom.cosechas_del_anyo', {
            'n': datos.cosechas.length,
            'kg': formatearNumero(total),
          })),
        ),
        for (final cosecha in datos.cosechas)
          ListTile(
            leading: Icon(cosecha.esSilvestre
                ? Icons.forest_outlined
                : Icons.grass_outlined),
            title: Text(
                '${nombreEspecie(cosecha.especieId)} · ${formatearNumero(cosecha.kgFrescos)} kg'),
            subtitle: Text([
              formatearFecha(cosecha.fechaMs),
              cosecha.esSilvestre
                  ? zonas[cosecha.zonaRecoleccionId] ?? ''
                  : parcelas[cosecha.parcelaId] ?? '',
              if (cosecha.estadoFenologico.isNotEmpty)
                nombreEstadoFenologico(cosecha.estadoFenologico),
            ].join(' · ')),
            onTap: () => mostrarAltaCosecha(context, cosecha: cosecha),
            onLongPress: () => confirmarYBorrar(
                context,
                () => BaseDatosSoleraAromaticas.instancia
                    .borrarCosecha(cosecha.id!)),
          ),
      ],
    );
  }
}

class _ListaTratamientos extends StatelessWidget {
  const _ListaTratamientos({required this.datos});

  final _DatosCampo datos;

  @override
  Widget build(BuildContext context) {
    if (datos.tratamientos.isEmpty) return _vacio('arom.sin_tratamientos');
    final parcelas = {for (final p in datos.parcelas) p.id: p.nombre};
    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        for (final tratamiento in datos.tratamientos)
          ListTile(
            leading: const Icon(Icons.science_outlined),
            title: Text(tratamiento.sustanciaActivaId),
            subtitle: Text([
              formatearFecha(tratamiento.fechaMs),
              parcelas[tratamiento.parcelaId] ?? '',
              if (tratamiento.problemaFitosanitario.isNotEmpty)
                nombrePlaga(tratamiento.problemaFitosanitario),
            ].join(' · ')),
            onLongPress: () => confirmarYBorrar(
                context,
                () => BaseDatosSoleraAromaticas.instancia
                    .borrarTratamiento(tratamiento.id!)),
          ),
      ],
    );
  }
}
