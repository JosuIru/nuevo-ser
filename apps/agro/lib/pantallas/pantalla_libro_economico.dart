import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, formatearEuros, rellenoInferiorSeguro;

import '../datos/base_datos.dart';
import '../datos/catalogo_cultivos.dart';
import '../modelos/apunte_gasto.dart';
import '../modelos/apunte_ingreso.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/tercero.dart';
import 'pantalla_extracto_economico.dart';
import 'pantalla_nuevo_gasto.dart';
import 'pantalla_nuevo_ingreso.dart';

/// Libro económico agro. TabBar con 3 pestañas: Ingresos / Gastos /
/// Resumen. Selector de año en el AppBar (toca para cambiar). El
/// resumen calcula sobre marcha los totales del año elegido — el
/// extracto anual con modelo 347 vive en `PantallaExtractoEconomico`.
///
/// **Provisional**: el formato del libro está pendiente de
/// validación por asesor fiscal. Banner amarillo persistente
/// hasta que firme.
class PantallaLibroEconomico extends StatefulWidget {
  const PantallaLibroEconomico({super.key});

  @override
  State<PantallaLibroEconomico> createState() => _PantallaLibroEconomicoState();
}

class _PantallaLibroEconomicoState extends State<PantallaLibroEconomico>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  int _ano = DateTime.now().year;
  ConfiguracionFiscal _configFiscal = ConfiguracionFiscal();
  List<ApunteIngreso> _ingresos = const [];
  List<ApunteGasto> _gastos = const [];
  Map<int, Tercero> _terceros = const {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
    _tabs.addListener(_onTabChanged);
    _cargar();
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabs.removeListener(_onTabChanged);
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final db = BaseDatosAgro.instancia;
    final cf = await db.obtenerConfiguracionFiscal();
    if (cf.anoFiscalActivo != 0 && cf.anoFiscalActivo != _ano) {
      _ano = cf.anoFiscalActivo;
    }
    final ingresos = await db.listarApuntesIngresoPorAno(_ano);
    final gastos = await db.listarApuntesGastoPorAno(_ano);
    final filasTerceros = await db.listarTerceros();
    if (!mounted) return;
    setState(() {
      _configFiscal = cf;
      _ingresos = ingresos;
      _gastos = gastos;
      _terceros = {for (final t in filasTerceros) t.id ?? -1: t};
      _cargando = false;
    });
  }

  Future<void> _cambiarAno() async {
    final actual = DateTime.now().year;
    final elegido = await showDialog<int>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text(SoleraL10n.t('agro.ano_fiscal')),
        children: List.generate(7, (i) => actual - 4 + i)
            .map(
              (a) => SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(a),
                child: Text(a.toString()),
              ),
            )
            .toList(),
      ),
    );
    if (elegido != null && elegido != _ano) {
      setState(() => _ano = elegido);
      await _cargar();
    }
  }

  Future<void> _abrirNuevoIngreso({ApunteIngreso? existente}) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PantallaNuevoIngreso(existente: existente),
      ),
    );
    if (ok == true) await _cargar();
  }

  Future<void> _abrirNuevoGasto({ApunteGasto? existente}) async {
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PantallaNuevoGasto(existente: existente),
      ),
    );
    if (ok == true) await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextButton.icon(
          onPressed: _cambiarAno,
          icon: const Icon(Icons.calendar_month, color: Colors.white),
          label: Text(
            '${SoleraL10n.t('libro_economico')} · $_ano',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: SoleraL10n.t('agro.extracto_anual'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PantallaExtractoEconomico(anoInicial: _ano),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          tabs: [
            Tab(text: SoleraL10n.t('agro.ingresos')),
            Tab(text: SoleraL10n.t('agro.gastos')),
            Tab(text: SoleraL10n.t('agro.trimestres')),
            Tab(text: SoleraL10n.t('agro.resumen')),
          ],
        ),
      ),
      floatingActionButton: _floatingActionButton(),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _bannerProvisional(),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _ListaIngresos(
                        ingresos: _ingresos,
                        terceros: _terceros,
                        alAbrir: (a) => _abrirNuevoIngreso(existente: a),
                      ),
                      _ListaGastos(
                        gastos: _gastos,
                        terceros: _terceros,
                        alAbrir: (a) => _abrirNuevoGasto(existente: a),
                      ),
                      _ResumenTrimestral(
                        ano: _ano,
                        ingresos: _ingresos,
                        gastos: _gastos,
                        terceros: _terceros,
                        configFiscal: _configFiscal,
                      ),
                      _ResumenAnual(
                        ano: _ano,
                        ingresos: _ingresos,
                        gastos: _gastos,
                        terceros: _terceros,
                        configFiscal: _configFiscal,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _bannerProvisional() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Colors.amber.withValues(alpha: 0.18),
      child: Text(
        SoleraL10n.t('agro.aviso_libro_economico_provisional'),
        style: const TextStyle(fontSize: 11),
      ),
    );
  }

  Widget? _floatingActionButton() {
    if (_tabs.index >= 2) return null;
    return FloatingActionButton.extended(
      onPressed: () {
        if (_tabs.index == 0) {
          _abrirNuevoIngreso();
        } else {
          _abrirNuevoGasto();
        }
      },
      icon: const Icon(Icons.add),
      label: Text(SoleraL10n.t(_tabs.index == 0 ? 'agro.nuevo_ingreso' : 'agro.nuevo_gasto')),
    );
  }
}

class _ListaIngresos extends StatelessWidget {
  final List<ApunteIngreso> ingresos;
  final Map<int, Tercero> terceros;
  final ValueChanged<ApunteIngreso> alAbrir;
  const _ListaIngresos({
    required this.ingresos,
    required this.terceros,
    required this.alAbrir,
  });

  @override
  Widget build(BuildContext context) {
    if (ingresos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            SoleraL10n.t('agro.sin_ingresos_este_ano'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: rellenoInferiorSeguro(context, const EdgeInsets.only(top: 8, bottom: 80)),
      itemCount: ingresos.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final a = ingresos[i];
        final fecha = DateTime.fromMillisecondsSinceEpoch(a.fechaMs);
        final tercero = a.terceroId == null ? null : terceros[a.terceroId];
        return ListTile(
          onTap: () => alAbrir(a),
          leading: CircleAvatar(
            backgroundColor: a.esAyudaOSubvencion
                ? Colors.purple.shade100
                : Colors.green.shade100,
            child: Icon(
              _iconoIngreso(a.tipoIngreso),
              color: a.esAyudaOSubvencion
                  ? Colors.purple.shade800
                  : Colors.green.shade800,
            ),
          ),
          title: Text(
            a.concepto.isEmpty ? _textoTipo(a.tipoIngreso) : a.concepto,
          ),
          subtitle: Text(
            '${fecha.day}/${fecha.month} · '
            '${formatearEuros(a.importeTotalCentimos / 100)}'
            '${tercero != null ? ' · ${tercero.nombre}' : ''}',
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            formatearEuros(a.importeBaseCentimos / 100),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  static IconData _iconoIngreso(String tipo) {
    switch (tipo) {
      case 'alquiler_terreno':
        return Icons.terrain;
      case 'venta_lena_madera':
        return Icons.forest;
      case 'ayuda_pac':
      case 'subvencion_autonomica':
        return Icons.account_balance;
      default:
        return Icons.shopping_basket;
    }
  }

  static String _textoTipo(String tipo) {
    switch (tipo) {
      case 'venta_cosecha':
        return SoleraL10n.t('agro.venta_de_cosecha');
      case 'venta_lena_madera':
        return SoleraL10n.t('agro.venta_de_lena_madera');
      case 'alquiler_terreno':
        return SoleraL10n.t('agro.alquiler_de_terreno');
      case 'ayuda_pac':
        return SoleraL10n.t('agro.ayuda_pac');
      case 'subvencion_autonomica':
        return SoleraL10n.t('agro.subvencion');
      default:
        return SoleraL10n.t('agro.otro_ingreso');
    }
  }
}

class _ListaGastos extends StatelessWidget {
  final List<ApunteGasto> gastos;
  final Map<int, Tercero> terceros;
  final ValueChanged<ApunteGasto> alAbrir;
  const _ListaGastos({
    required this.gastos,
    required this.terceros,
    required this.alAbrir,
  });

  @override
  Widget build(BuildContext context) {
    if (gastos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            SoleraL10n.t('agro.sin_gastos_este_ano'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: rellenoInferiorSeguro(context, const EdgeInsets.only(top: 8, bottom: 80)),
      itemCount: gastos.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final a = gastos[i];
        final fecha = DateTime.fromMillisecondsSinceEpoch(a.fechaMs);
        final tercero = a.terceroId == null ? null : terceros[a.terceroId];
        return ListTile(
          onTap: () => alAbrir(a),
          leading: CircleAvatar(
            backgroundColor: Colors.red.shade100,
            child: Icon(_iconoGasto(a.tipoGasto), color: Colors.red.shade800),
          ),
          title: Text(
            a.concepto.isEmpty ? _textoTipo(a.tipoGasto) : a.concepto,
          ),
          subtitle: Text(
            '${fecha.day}/${fecha.month} · '
            '${formatearEuros(a.importeTotalCentimos / 100)}'
            '${tercero != null ? ' · ${tercero.nombre}' : ''}'
            '${a.esCultivoGeneral ? ' · ${_nombreCultivo(a.cultivoId)}' : ''}',
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            formatearEuros(a.importeBaseCentimos / 100),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  static String _nombreCultivo(String id) {
    final c = catalogoCultivos.where((x) => x.id == id).firstOrNull;
    return c?.nombreVisible ?? id;
  }

  static IconData _iconoGasto(String tipo) {
    switch (tipo) {
      case 'insumos':
        return Icons.grass;
      case 'tratamientos_fitosanitarios':
        return Icons.healing;
      case 'maquinaria':
        return Icons.agriculture;
      case 'mano_obra':
        return Icons.engineering;
      case 'combustible':
      case 'transporte':
        return Icons.local_shipping;
      case 'seguros':
        return Icons.shield;
      case 'riego_agua':
        return Icons.water_drop;
      case 'veterinario_animal':
        return Icons.pets;
      case 'certificacion':
        return Icons.verified;
      default:
        return Icons.receipt_long;
    }
  }

  static String _textoTipo(String tipo) {
    switch (tipo) {
      case 'insumos':
        return SoleraL10n.t('agro.insumos');
      case 'tratamientos_fitosanitarios':
        return SoleraL10n.t('agro.tratamiento');
      case 'maquinaria':
        return SoleraL10n.t('agro.maquinaria');
      case 'mano_obra':
        return SoleraL10n.t('agro.mano_de_obra');
      case 'combustible':
        return SoleraL10n.t('agro.combustible');
      case 'seguros':
        return SoleraL10n.t('agro.seguros');
      case 'riego_agua':
        return SoleraL10n.t('agro.riego_agua');
      case 'transporte':
        return SoleraL10n.t('agro.transporte');
      case 'veterinario_animal':
        return SoleraL10n.t('agro.veterinario');
      case 'certificacion':
        return SoleraL10n.t('agro.certificacion');
      default:
        return SoleraL10n.t('agro.otro_gasto');
    }
  }
}

class _ResumenTrimestral extends StatelessWidget {
  final int ano;
  final List<ApunteIngreso> ingresos;
  final List<ApunteGasto> gastos;
  final Map<int, Tercero> terceros;
  final ConfiguracionFiscal configFiscal;
  const _ResumenTrimestral({
    required this.ano,
    required this.ingresos,
    required this.gastos,
    required this.terceros,
    required this.configFiscal,
  });

  @override
  Widget build(BuildContext context) {
    final trimestres = List.generate(
      4,
      (i) => _ResumenTrimestreAgro._calcular(
        ano: ano,
        trimestre: i + 1,
        ingresos: ingresos,
        gastos: gastos,
        terceros: terceros,
      ),
    );

    return ListView(
      padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
      children: [
        Text(
          SoleraL10n.t('agro.resumen_fiscal_trimestral'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          SoleraL10n.t('agro.explicacion_resumen_trimestral'),
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        for (final trimestre in trimestres) ...[
          _ResumenTrimestreCardAgro(
            resumen: trimestre,
            configFiscal: configFiscal,
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        Text(
          SoleraL10n.t('agro.criterio_trimestres'),
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

class _ResumenTrimestreAgro {
  final int trimestre;
  final int ingresosOrdinarios;
  final int ayudas;
  final int gastosBase;
  final int ivaRepercutido;
  final int compensacionReagp;
  final int ivaSoportado;
  final int apuntesIngreso;
  final int apuntesGasto;

  const _ResumenTrimestreAgro({
    required this.trimestre,
    required this.ingresosOrdinarios,
    required this.ayudas,
    required this.gastosBase,
    required this.ivaRepercutido,
    required this.compensacionReagp,
    required this.ivaSoportado,
    required this.apuntesIngreso,
    required this.apuntesGasto,
  });

  factory _ResumenTrimestreAgro._calcular({
    required int ano,
    required int trimestre,
    required List<ApunteIngreso> ingresos,
    required List<ApunteGasto> gastos,
    required Map<int, Tercero> terceros,
  }) {
    final mesInicial = (trimestre - 1) * 3 + 1;
    final desde = DateTime(ano, mesInicial, 1).millisecondsSinceEpoch;
    final hasta = DateTime(ano, mesInicial + 3, 1).millisecondsSinceEpoch - 1;
    final ingresosTrim = ingresos
        .where((a) => a.fechaMs >= desde && a.fechaMs <= hasta)
        .toList();
    final gastosTrim = gastos
        .where((g) => g.fechaMs >= desde && g.fechaMs <= hasta)
        .toList();
    final ingresosOrdinarios = ingresosTrim
        .where((a) => !a.esAyudaOSubvencion)
        .map((a) => a.importeBaseCentimos)
        .fold<int>(0, (s, n) => s + n);
    final ayudas = ingresosTrim
        .where((a) => a.esAyudaOSubvencion)
        .map((a) => a.importeBaseCentimos)
        .fold<int>(0, (s, n) => s + n);
    final gastosBase = gastosTrim
        .map((g) => g.importeBaseCentimos)
        .fold<int>(0, (s, n) => s + n);
    final ivaRepercutido = ingresosTrim
        .map((a) => a.ivaRepercutidoCentimos)
        .fold<int>(0, (s, n) => s + n);
    final compensacionReagp = ingresosTrim
        .map((a) => a.compensacionReagpCentimos)
        .fold<int>(0, (s, n) => s + n);
    final ivaSoportado = gastosTrim
        .map((g) => g.ivaSoportadoCentimos)
        .fold<int>(0, (s, n) => s + n);
    final apuntesIngreso = ingresosTrim.where((a) {
      if (a.terceroId == null) return true;
      final t = terceros[a.terceroId!];
      return t == null || !t.tieneNif;
    }).length;
    return _ResumenTrimestreAgro(
      trimestre: trimestre,
      ingresosOrdinarios: ingresosOrdinarios,
      ayudas: ayudas,
      gastosBase: gastosBase,
      ivaRepercutido: ivaRepercutido,
      compensacionReagp: compensacionReagp,
      ivaSoportado: ivaSoportado,
      apuntesIngreso: apuntesIngreso,
      apuntesGasto: gastosTrim.length,
    );
  }

  int get diferenciaOrdinaria => ingresosOrdinarios - gastosBase;
}

class _ResumenTrimestreCardAgro extends StatelessWidget {
  final _ResumenTrimestreAgro resumen;
  final ConfiguracionFiscal configFiscal;
  const _ResumenTrimestreCardAgro({
    required this.resumen,
    required this.configFiscal,
  });

  @override
  Widget build(BuildContext context) {
    final titulo =
        '${SoleraL10n.tf('agro.trimestre_abreviado_n', {'n': resumen.trimestre})} · ${_nombreTrimestre(resumen.trimestre)}';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _ResumenLineaAgro(
              label: SoleraL10n.t('agro.ingresos_ordinarios'),
              value: resumen.ingresosOrdinarios,
              color: Colors.green.shade700,
            ),
            _ResumenLineaAgro(
              label: SoleraL10n.t('agro.ayudas_pac_y_subvenciones'),
              value: resumen.ayudas,
              color: Colors.purple.shade700,
            ),
            _ResumenLineaAgro(
              label: SoleraL10n.t('agro.gastos'),
              value: resumen.gastosBase,
              color: Colors.red.shade700,
            ),
            _ResumenLineaAgro(
              label: SoleraL10n.t('agro.diferencia_ordinaria'),
              value: resumen.diferenciaOrdinaria,
              color: resumen.diferenciaOrdinaria >= 0
                  ? Colors.green.shade900
                  : Colors.red.shade900,
            ),
            const SizedBox(height: 8),
            if (configFiscal.regimenIva == 'reagp') ...[
              _ResumenLineaAgro(
                label: SoleraL10n.t('agro.compensacion_reagp_cobrada'),
                value: resumen.compensacionReagp,
                color: Colors.teal.shade700,
              ),
              _ResumenLineaAgro(
                label: SoleraL10n.t('agro.iva_soportado'),
                value: resumen.ivaSoportado,
                color: Colors.blueGrey.shade700,
              ),
            ],
            if (configFiscal.regimenIva == 'general') ...[
              _ResumenLineaAgro(
                label: SoleraL10n.t('agro.iva_repercutido'),
                value: resumen.ivaRepercutido,
                color: Colors.teal.shade700,
              ),
              _ResumenLineaAgro(
                label: SoleraL10n.t('agro.iva_soportado_deducible'),
                value: resumen.ivaSoportado,
                color: Colors.blueGrey.shade700,
              ),
              _ResumenLineaAgro(
                label: SoleraL10n.t('agro.diferencia_iva'),
                value: resumen.ivaRepercutido - resumen.ivaSoportado,
                color: resumen.ivaRepercutido - resumen.ivaSoportado >= 0
                    ? Colors.indigo.shade700
                    : Colors.deepOrange.shade700,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              SoleraL10n.tf('agro.apuntes_ingresos_gastos_n', {
                'ingresos': resumen.apuntesIngreso,
                'gastos': resumen.apuntesGasto,
              }),
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  static String _nombreTrimestre(int trimestre) {
    switch (trimestre) {
      case 1:
        return SoleraL10n.t('agro.trimestre_ene_mar');
      case 2:
        return SoleraL10n.t('agro.trimestre_abr_jun');
      case 3:
        return SoleraL10n.t('agro.trimestre_jul_sep');
      default:
        return SoleraL10n.t('agro.trimestre_oct_dic');
    }
  }
}

class _ResumenLineaAgro extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _ResumenLineaAgro({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Text(
            formatearEuros(value / 100),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumenAnual extends StatelessWidget {
  final int ano;
  final List<ApunteIngreso> ingresos;
  final List<ApunteGasto> gastos;
  final Map<int, Tercero> terceros;
  final ConfiguracionFiscal configFiscal;
  const _ResumenAnual({
    required this.ano,
    required this.ingresos,
    required this.gastos,
    required this.terceros,
    required this.configFiscal,
  });

  @override
  Widget build(BuildContext context) {
    final ingresosOrdinarios = ingresos
        .where((a) => !a.esAyudaOSubvencion)
        .map((a) => a.importeBaseCentimos)
        .fold<int>(0, (s, n) => s + n);
    final ayudas = ingresos
        .where((a) => a.esAyudaOSubvencion)
        .map((a) => a.importeBaseCentimos)
        .fold<int>(0, (s, n) => s + n);
    final compensacionReagp = ingresos
        .map((a) => a.compensacionReagpCentimos)
        .fold<int>(0, (s, n) => s + n);
    final ivaRepercutido = ingresos
        .map((a) => a.ivaRepercutidoCentimos)
        .fold<int>(0, (s, n) => s + n);
    final gastosBase = gastos
        .map((g) => g.importeBaseCentimos)
        .fold<int>(0, (s, n) => s + n);
    final ivaSoportado = gastos
        .map((g) => g.ivaSoportadoCentimos)
        .fold<int>(0, (s, n) => s + n);
    final apuntesSinNif = ingresos.where((a) {
      if (a.terceroId == null) return true;
      final t = terceros[a.terceroId!];
      return t == null || !t.tieneNif;
    }).length;

    final diferenciaOrdinaria = ingresosOrdinarios - gastosBase;

    return ListView(
      padding: rellenoInferiorSeguro(context, const EdgeInsets.all(16)),
      children: [
        _Card(
          titulo: '${SoleraL10n.t('agro.ingresos_ordinarios')} $ano',
          importeCentimos: ingresosOrdinarios,
          color: Colors.green.shade700,
          subtitulo: SoleraL10n.t('agro.detalle_ingresos_ordinarios'),
        ),
        _Card(
          titulo: '${SoleraL10n.t('agro.ayudas_pac_y_subvenciones')} $ano',
          importeCentimos: ayudas,
          color: Colors.purple.shade700,
          subtitulo: SoleraL10n.t('agro.detalle_ayudas_pac'),
        ),
        _Card(
          titulo: '${SoleraL10n.t('agro.gastos')} $ano',
          importeCentimos: gastosBase,
          color: Colors.red.shade700,
          subtitulo: SoleraL10n.t('agro.base_imponible_sin_iva_soportado'),
        ),
        _Card(
          titulo: SoleraL10n.t('agro.diferencia_ordinaria'),
          importeCentimos: diferenciaOrdinaria,
          color: diferenciaOrdinaria >= 0
              ? Colors.green.shade900
              : Colors.red.shade900,
          subtitulo: SoleraL10n.t('agro.detalle_diferencia_ordinaria'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            SoleraL10n.t('agro.iva_y_compensaciones'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        if (configFiscal.regimenIva == 'reagp') ...[
          _Card(
            titulo: SoleraL10n.t('agro.compensacion_reagp_cobrada'),
            importeCentimos: compensacionReagp,
            color: Colors.teal.shade700,
            subtitulo: SoleraL10n.t('agro.detalle_compensacion_reagp'),
          ),
          _Card(
            titulo: SoleraL10n.t('agro.iva_soportado_en_compras'),
            importeCentimos: ivaSoportado,
            color: Colors.blueGrey.shade700,
            subtitulo: SoleraL10n.t('agro.detalle_iva_soportado_reagp'),
          ),
        ],
        if (configFiscal.regimenIva == 'general') ...[
          _Card(
            titulo: SoleraL10n.t('agro.iva_repercutido'),
            importeCentimos: ivaRepercutido,
            color: Colors.teal.shade700,
            subtitulo: SoleraL10n.t('agro.detalle_iva_repercutido'),
          ),
          _Card(
            titulo: SoleraL10n.t('agro.iva_soportado_deducible'),
            importeCentimos: ivaSoportado,
            color: Colors.blueGrey.shade700,
            subtitulo: SoleraL10n.t('agro.detalle_iva_soportado_deducible'),
          ),
          _Card(
            titulo: SoleraL10n.t('agro.diferencia_iva'),
            importeCentimos: ivaRepercutido - ivaSoportado,
            color: ivaRepercutido - ivaSoportado >= 0
                ? Colors.indigo.shade700
                : Colors.deepOrange.shade700,
            subtitulo: SoleraL10n.t('agro.detalle_diferencia_iva'),
          ),
        ],
        if (configFiscal.regimenIva == 'sin_elegir')
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              SoleraL10n.t('agro.configura_regimen_iva_resumen'),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        const SizedBox(height: 16),
        _Stats(
          icono: Icons.event_note,
          texto: SoleraL10n.tf('agro.apuntes_de_ingreso_n', {'n': ingresos.length}),
        ),
        _Stats(
          icono: Icons.event_note,
          texto: SoleraL10n.tf('agro.apuntes_de_gasto_n', {'n': gastos.length}),
        ),
        if (apuntesSinNif > 0)
          _Stats(
            icono: Icons.warning_amber,
            texto: SoleraL10n.tf('agro.ingresos_sin_nif_n', {'n': apuntesSinNif}),
            color: Colors.orange.shade800,
          ),
        const SizedBox(height: 24),
        Text(
          SoleraL10n.t('agro.extracto_desde_icono_pdf'),
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final String titulo;
  final int importeCentimos;
  final String subtitulo;
  final Color color;
  const _Card({
    required this.titulo,
    required this.importeCentimos,
    required this.subtitulo,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    subtitulo,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              formatearEuros(importeCentimos / 100),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color? color;
  const _Stats({required this.icono, required this.texto, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icono, size: 18, color: color ?? Colors.black87),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(color: color ?? Colors.black87, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
