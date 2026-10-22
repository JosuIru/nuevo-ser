import 'package:flutter/material.dart';

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_variedades.dart';
import '../modelos/apunte_gasto.dart';
import '../modelos/apunte_ingreso.dart';
import '../modelos/configuracion_fiscal.dart';
import '../modelos/tercero.dart';
import 'pantalla_extracto_economico.dart';
import 'pantalla_nuevo_gasto.dart';
import 'pantalla_nuevo_ingreso.dart';

/// Libro económico viticultura. TabBar con 3 pestañas: Ingresos /
/// Gastos / Resumen. Selector de año en cabecera + acceso al
/// extracto anual PDF.
///
/// **Provisional** — formato pendiente de validación por asesor
/// fiscal.
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
    final db = BaseDatosSoleraViticultura.instancia;
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
        title: const Text('Año fiscal'),
        children: List.generate(7, (i) => actual - 4 + i)
            .map((a) => SimpleDialogOption(
                  onPressed: () => Navigator.of(context).pop(a),
                  child: Text(a.toString()),
                ))
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
          label: Text('Libro económico · $_ano',
              style: const TextStyle(color: Colors.white, fontSize: 18)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Extracto anual',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => PantallaExtractoEconomico(anoInicial: _ano),
              ));
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: 'Ingresos'),
            Tab(text: 'Gastos'),
            Tab(text: 'Trimestres'),
            Tab(text: 'Resumen'),
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
        'Libro económico provisional. Pendiente de validación por asesor fiscal '
        'antes de presentar nada en una declaración. Mientras tanto, contrasta '
        'cada apunte con tu asesor.',
        style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
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
      label: Text(_tabs.index == 0 ? 'Nuevo ingreso' : 'Nuevo gasto'),
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Aún no hay ingresos en este año. Pulsa "Nuevo ingreso" para '
            'registrar venta de uva, vino en botella o granel, alquiler de '
            'terreno o ayuda PAC.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
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
            child: Icon(_iconoIngreso(a.tipoIngreso),
                color: a.esAyudaOSubvencion
                    ? Colors.purple.shade800
                    : Colors.green.shade800),
          ),
          title:
              Text(a.concepto.isEmpty ? _textoTipo(a.tipoIngreso) : a.concepto),
          subtitle: Text(
            '${fecha.day}/${fecha.month} · '
            '${(a.importeTotalCentimos / 100).toStringAsFixed(2)} €'
            '${tercero != null ? ' · ${tercero.nombre}' : ''}'
            '${a.loteVino.isNotEmpty ? ' · L${a.loteVino}' : ''}',
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            '${(a.importeBaseCentimos / 100).toStringAsFixed(2)} €',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  static IconData _iconoIngreso(String tipo) {
    switch (tipo) {
      case 'venta_uva':
        return Icons.eco;
      case 'venta_vino_botella':
      case 'venta_vino_granel':
        return Icons.wine_bar;
      case 'alquiler_terreno':
        return Icons.terrain;
      case 'ayuda_pac':
      case 'subvencion_autonomica':
        return Icons.account_balance;
      default:
        return Icons.shopping_basket;
    }
  }

  static String _textoTipo(String tipo) {
    switch (tipo) {
      case 'venta_uva':
        return 'Venta de uva';
      case 'venta_vino_botella':
        return 'Venta vino (botella)';
      case 'venta_vino_granel':
        return 'Venta vino (granel)';
      case 'alquiler_terreno':
        return 'Alquiler de terreno';
      case 'ayuda_pac':
        return 'Ayuda PAC';
      case 'subvencion_autonomica':
        return 'Subvención';
      default:
        return 'Otro ingreso';
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Aún no hay gastos en este año. Pulsa "Nuevo gasto" para registrar '
            'insumos, tratamientos, vendimia, embotellado, barricas o cualquier '
            'otro gasto de la explotación.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
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
          title:
              Text(a.concepto.isEmpty ? _textoTipo(a.tipoGasto) : a.concepto),
          subtitle: Text(
            '${fecha.day}/${fecha.month} · '
            '${(a.importeTotalCentimos / 100).toStringAsFixed(2)} €'
            '${tercero != null ? ' · ${tercero.nombre}' : ''}'
            '${a.esVariedadGeneral ? ' · ${_nombreVariedad(a.variedadId)}' : ''}',
            style: const TextStyle(fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            '${(a.importeBaseCentimos / 100).toStringAsFixed(2)} €',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  static String _nombreVariedad(String id) {
    for (final v in catalogoVariedades) {
      if (v.id == id) return v.nombreCanonico;
    }
    return id;
  }

  static IconData _iconoGasto(String tipo) {
    switch (tipo) {
      case 'insumos_vid':
        return Icons.grass;
      case 'tratamientos_fitosanitarios':
        return Icons.healing;
      case 'vendimia':
        return Icons.agriculture;
      case 'embotellado':
      case 'etiquetado':
        return Icons.wine_bar;
      case 'barricas':
        return Icons.water_drop;
      case 'maquinaria':
        return Icons.precision_manufacturing;
      case 'mano_obra':
        return Icons.engineering;
      case 'combustible':
      case 'transporte':
        return Icons.local_shipping;
      case 'seguros':
        return Icons.shield;
      case 'certificacion':
        return Icons.verified;
      default:
        return Icons.receipt_long;
    }
  }

  static String _textoTipo(String tipo) {
    switch (tipo) {
      case 'insumos_vid':
        return 'Insumos vid';
      case 'tratamientos_fitosanitarios':
        return 'Tratamiento';
      case 'vendimia':
        return 'Vendimia';
      case 'embotellado':
        return 'Embotellado';
      case 'etiquetado':
        return 'Etiquetado';
      case 'barricas':
        return 'Barricas';
      case 'maquinaria':
        return 'Maquinaria';
      case 'mano_obra':
        return 'Mano de obra';
      case 'combustible':
        return 'Combustible';
      case 'seguros':
        return 'Seguros';
      case 'transporte':
        return 'Transporte';
      case 'certificacion':
        return 'Certificación';
      default:
        return 'Otro gasto';
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
      (i) => _ResumenTrimestreViticola._calcular(
        ano: ano,
        trimestre: i + 1,
        ingresos: ingresos,
        gastos: gastos,
        terceros: terceros,
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Resumen fiscal trimestral',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Totales por trimestre para revisar caja, IVA y diferencia antes del '
          'cierre fiscal. El extracto anual sigue disponible en el PDF.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        for (final trimestre in trimestres) ...[
          _ResumenTrimestreCardViticola(
            resumen: trimestre,
            configFiscal: configFiscal,
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        const Text(
          'Los trimestres usan el mismo criterio que el resumen anual: '
          'uva separada de vino, ayudas aparte y modelo 347 por NIF.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

class _ResumenTrimestreViticola {
  final int trimestre;
  final int ingresosUva;
  final int ingresosVino;
  final int ayudas;
  final int gastosBase;
  final int ivaRepercutido;
  final int compensacionReagp;
  final int ivaSoportado;
  final int apuntesIngreso;
  final int apuntesGasto;

  const _ResumenTrimestreViticola({
    required this.trimestre,
    required this.ingresosUva,
    required this.ingresosVino,
    required this.ayudas,
    required this.gastosBase,
    required this.ivaRepercutido,
    required this.compensacionReagp,
    required this.ivaSoportado,
    required this.apuntesIngreso,
    required this.apuntesGasto,
  });

  factory _ResumenTrimestreViticola._calcular({
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
    final gastosTrim =
        gastos.where((g) => g.fechaMs >= desde && g.fechaMs <= hasta).toList();
    final ingresosUva = ingresosTrim
        .where((a) => a.esVentaUva)
        .map((a) => a.importeBaseCentimos)
        .fold<int>(0, (s, n) => s + n);
    final ingresosVino = ingresosTrim
        .where((a) => a.esVentaVino)
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
    return _ResumenTrimestreViticola(
      trimestre: trimestre,
      ingresosUva: ingresosUva,
      ingresosVino: ingresosVino,
      ayudas: ayudas,
      gastosBase: gastosBase,
      ivaRepercutido: ivaRepercutido,
      compensacionReagp: compensacionReagp,
      ivaSoportado: ivaSoportado,
      apuntesIngreso: apuntesIngreso,
      apuntesGasto: gastosTrim.length,
    );
  }

  int get ingresosOrdinarios => ingresosUva + ingresosVino;
  int get diferenciaOrdinaria => ingresosOrdinarios - gastosBase;
}

class _ResumenTrimestreCardViticola extends StatelessWidget {
  final _ResumenTrimestreViticola resumen;
  final ConfiguracionFiscal configFiscal;
  const _ResumenTrimestreCardViticola({
    required this.resumen,
    required this.configFiscal,
  });

  @override
  Widget build(BuildContext context) {
    final titulo =
        'T${resumen.trimestre} · ${_nombreTrimestre(resumen.trimestre)}';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _ResumenLineaViticola(
              label: 'Ingresos uva',
              value: resumen.ingresosUva,
              color: Colors.green.shade700,
            ),
            _ResumenLineaViticola(
              label: 'Ingresos vino',
              value: resumen.ingresosVino,
              color: Colors.deepPurple.shade700,
            ),
            _ResumenLineaViticola(
              label: 'Ayudas PAC y subvenciones',
              value: resumen.ayudas,
              color: Colors.purple.shade700,
            ),
            _ResumenLineaViticola(
              label: 'Gastos',
              value: resumen.gastosBase,
              color: Colors.red.shade700,
            ),
            _ResumenLineaViticola(
              label: 'Diferencia ordinaria',
              value: resumen.diferenciaOrdinaria,
              color: resumen.diferenciaOrdinaria >= 0
                  ? Colors.green.shade900
                  : Colors.red.shade900,
            ),
            const SizedBox(height: 8),
            if (configFiscal.regimenIva == 'reagp') ...[
              _ResumenLineaViticola(
                label: 'Compensación REAGP cobrada',
                value: resumen.compensacionReagp,
                color: Colors.teal.shade700,
              ),
              _ResumenLineaViticola(
                label: 'IVA repercutido en vino',
                value: resumen.ivaRepercutido,
                color: Colors.indigo.shade700,
              ),
              _ResumenLineaViticola(
                label: 'IVA soportado',
                value: resumen.ivaSoportado,
                color: Colors.blueGrey.shade700,
              ),
            ],
            if (configFiscal.regimenIva == 'general') ...[
              _ResumenLineaViticola(
                label: 'IVA repercutido',
                value: resumen.ivaRepercutido,
                color: Colors.teal.shade700,
              ),
              _ResumenLineaViticola(
                label: 'IVA soportado deducible',
                value: resumen.ivaSoportado,
                color: Colors.blueGrey.shade700,
              ),
              _ResumenLineaViticola(
                label: 'Diferencia IVA',
                value: resumen.ivaRepercutido - resumen.ivaSoportado,
                color: resumen.ivaRepercutido - resumen.ivaSoportado >= 0
                    ? Colors.indigo.shade700
                    : Colors.deepOrange.shade700,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Apuntes: ${resumen.apuntesIngreso} ingresos · ${resumen.apuntesGasto} gastos',
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
        return 'ene-mar';
      case 2:
        return 'abr-jun';
      case 3:
        return 'jul-sep';
      default:
        return 'oct-dic';
    }
  }
}

class _ResumenLineaViticola extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _ResumenLineaViticola({
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
            '${(value / 100).toStringAsFixed(2)} €',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: color),
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
    final ingresosUva = ingresos
        .where((a) => a.esVentaUva)
        .map((a) => a.importeBaseCentimos)
        .fold<int>(0, (s, n) => s + n);
    final ingresosVino = ingresos
        .where((a) => a.esVentaVino)
        .map((a) => a.importeBaseCentimos)
        .fold<int>(0, (s, n) => s + n);
    final compensacionReagp = ingresos
        .map((a) => a.compensacionReagpCentimos)
        .fold<int>(0, (s, n) => s + n);
    final ivaRepercutido = ingresos
        .map((a) => a.ivaRepercutidoCentimos)
        .fold<int>(0, (s, n) => s + n);
    final gastosBase =
        gastos.map((g) => g.importeBaseCentimos).fold<int>(0, (s, n) => s + n);
    final ivaSoportado =
        gastos.map((g) => g.ivaSoportadoCentimos).fold<int>(0, (s, n) => s + n);
    final apuntesSinNif = ingresos.where((a) {
      if (a.terceroId == null) return true;
      final t = terceros[a.terceroId!];
      return t == null || !t.tieneNif;
    }).length;

    final diferenciaOrdinaria = ingresosOrdinarios - gastosBase;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Card(
          titulo: 'Ingresos uva $ano',
          importeCentimos: ingresosUva,
          color: Colors.green.shade700,
          subtitulo: 'Venta de uva (4% IVA / 12% compensación REAGP)',
        ),
        _Card(
          titulo: 'Ingresos vino $ano',
          importeCentimos: ingresosVino,
          color: Colors.deepPurple.shade700,
          subtitulo: 'Botella + granel (21% IVA general siempre)',
        ),
        _Card(
          titulo: 'Ayudas PAC y subvenciones $ano',
          importeCentimos: ayudas,
          color: Colors.purple.shade700,
          subtitulo: 'Fiscalmente NO son ingreso ordinario',
        ),
        _Card(
          titulo: 'Gastos $ano',
          importeCentimos: gastosBase,
          color: Colors.red.shade700,
          subtitulo: 'Base imponible (sin IVA soportado)',
        ),
        _Card(
          titulo: 'Diferencia ordinaria',
          importeCentimos: diferenciaOrdinaria,
          color: diferenciaOrdinaria >= 0
              ? Colors.green.shade900
              : Colors.red.shade900,
          subtitulo: 'Ingresos ordinarios − gastos. PAC y subvenciones aparte.',
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text('IVA y compensaciones',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        if (configFiscal.regimenIva == 'reagp') ...[
          _Card(
            titulo: 'Compensación REAGP cobrada',
            importeCentimos: compensacionReagp,
            color: Colors.teal.shade700,
            subtitulo: '12% sobre la base de uva — sólo aplica a venta de uva',
          ),
          _Card(
            titulo: 'IVA repercutido en venta de vino',
            importeCentimos: ivaRepercutido,
            color: Colors.indigo.shade700,
            subtitulo: 'A ingresar en Hacienda (modelo 303 trimestral)',
          ),
          _Card(
            titulo: 'IVA soportado en compras',
            importeCentimos: ivaSoportado,
            color: Colors.blueGrey.shade700,
            subtitulo: 'En REAGP NO es recuperable. Computa como mayor coste.',
          ),
        ],
        if (configFiscal.regimenIva == 'general') ...[
          _Card(
            titulo: 'IVA repercutido',
            importeCentimos: ivaRepercutido,
            color: Colors.teal.shade700,
            subtitulo: 'A ingresar en Hacienda (modelo 303 trimestral)',
          ),
          _Card(
            titulo: 'IVA soportado deducible',
            importeCentimos: ivaSoportado,
            color: Colors.blueGrey.shade700,
            subtitulo: 'Recuperable contra el repercutido',
          ),
          _Card(
            titulo: 'Diferencia IVA',
            importeCentimos: ivaRepercutido - ivaSoportado,
            color: ivaRepercutido - ivaSoportado >= 0
                ? Colors.indigo.shade700
                : Colors.deepOrange.shade700,
            subtitulo: 'Repercutido − soportado',
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
              'Configura el régimen de IVA en Ajustes → Configuración fiscal '
              'para que el resumen distinga REAGP de régimen general.',
              style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
            ),
          ),
        const SizedBox(height: 16),
        _Stats(
          icono: Icons.event_note,
          texto: 'Apuntes de ingreso: ${ingresos.length}',
        ),
        _Stats(
          icono: Icons.event_note,
          texto: 'Apuntes de gasto: ${gastos.length}',
        ),
        if (apuntesSinNif > 0)
          _Stats(
            icono: Icons.warning_amber,
            texto:
                '$apuntesSinNif ingreso(s) sin NIF — no entran al modelo 347',
            color: Colors.orange.shade800,
          ),
        const SizedBox(height: 24),
        const Text(
          'El extracto anual con detalle por mes y modelo 347 está disponible '
          'desde el icono PDF de la cabecera.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
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
                  Text(titulo,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitulo,
                      style:
                          const TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${(importeCentimos / 100).toStringAsFixed(2)} €',
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
