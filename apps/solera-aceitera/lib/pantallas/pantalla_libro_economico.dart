import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../datos/base_datos.dart';
import '../modelos/apunte_gasto.dart';
import '../modelos/apunte_ingreso.dart';
import '../modelos/configuracion_fiscal.dart';
import '../servicios/generador_extracto_economico.dart';
import 'pantalla_nuevo_gasto.dart';
import 'pantalla_nuevo_ingreso.dart';

/// Libro económico anual con TabBar (Ingresos / Gastos / Resumen).
/// El año fiscal por defecto se toma de `ConfiguracionFiscal.anyoFiscalActivo`;
/// el usuario puede cambiarlo en la cabecera. Botón "Generar extracto"
/// produce el PDF anual con la plantilla `informe_periodico` del core.
class PantallaLibroEconomico extends StatefulWidget {
  const PantallaLibroEconomico({super.key});

  @override
  State<PantallaLibroEconomico> createState() =>
      _PantallaLibroEconomicoState();
}

class _PantallaLibroEconomicoState extends State<PantallaLibroEconomico> {
  ConfiguracionFiscal _configuracion = ConfiguracionFiscal();
  List<ApunteIngreso> _ingresos = const [];
  List<ApunteGasto> _gastos = const [];
  int _anyo = DateTime.now().year;
  bool _cargando = true;
  bool _generando = false;

  final _formatoFecha = DateFormat('d/M/yyyy', 'es_ES');
  final _formatoEuros =
      NumberFormat.currency(locale: 'es_ES', symbol: '€', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    _cargarInicial();
  }

  Future<void> _cargarInicial() async {
    final cfg = await BaseDatosSoleraAceitera().obtenerConfiguracionFiscal();
    if (!mounted) return;
    setState(() {
      _configuracion = cfg;
      if (cfg.anyoFiscalActivo > 0) _anyo = cfg.anyoFiscalActivo;
    });
    await _cargarApuntes();
  }

  Future<void> _cargarApuntes() async {
    final desdeMs = DateTime(_anyo, 1, 1).millisecondsSinceEpoch;
    final hastaMs = DateTime(_anyo + 1, 1, 1).millisecondsSinceEpoch - 1;
    final ingresos = await BaseDatosSoleraAceitera().listarApuntesIngreso(
      desdeMs: desdeMs,
      hastaMs: hastaMs,
    );
    final gastos = await BaseDatosSoleraAceitera().listarApuntesGasto(
      desdeMs: desdeMs,
      hastaMs: hastaMs,
    );
    if (!mounted) return;
    setState(() {
      _ingresos = ingresos;
      _gastos = gastos;
      _cargando = false;
    });
  }

  Future<void> _abrirNuevoIngreso() async {
    final guardado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PantallaNuevoIngreso()),
    );
    if (guardado == true) await _cargarApuntes();
  }

  Future<void> _abrirNuevoGasto() async {
    final guardado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PantallaNuevoGasto()),
    );
    if (guardado == true) await _cargarApuntes();
  }

  Future<void> _generarExtracto() async {
    setState(() => _generando = true);
    try {
      final fichero = await generarExtractoEconomicoAnual(anyo: _anyo);
      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(fichero.path)],
        text: 'Extracto económico $_anyo · Larrea Aceitera',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generando el extracto: $e')),
      );
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  Future<void> _imprimirExtracto() async {
    setState(() => _generando = true);
    try {
      final fichero = await generarExtractoEconomicoAnual(anyo: _anyo);
      if (!mounted) return;
      await Printing.layoutPdf(
        onLayout: (_) => File(fichero.path).readAsBytes(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error abriendo el extracto: $e')),
      );
    } finally {
      if (mounted) setState(() => _generando = false);
    }
  }

  int get _totalBaseIngresos =>
      _ingresos.fold<int>(0, (acc, a) => acc + a.importeBaseCentimos);
  int get _totalBaseGastos =>
      _gastos.fold<int>(0, (acc, a) => acc + a.importeBaseCentimos);
  int get _totalIvaRepercutido =>
      _ingresos.fold<int>(0, (acc, a) => acc + a.ivaRepercutidoCentimos);
  int get _totalIvaSoportado =>
      _gastos.fold<int>(0, (acc, a) => acc + a.ivaSoportadoCentimos);
  int get _totalCompensacionReagp =>
      _ingresos.fold<int>(0, (acc, a) => acc + a.compensacionReagpCentimos);

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final anyoActual = DateTime.now().year;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Libro económico'),
          actions: [
            DropdownButton<int>(
              value: _anyo,
              underline: const SizedBox(),
              items: [
                for (var a = anyoActual + 1; a >= anyoActual - 9; a--)
                  DropdownMenuItem(value: a, child: Text(a.toString())),
              ],
              onChanged: (v) async {
                if (v != null) {
                  setState(() => _anyo = v);
                  await _cargarApuntes();
                }
              },
            ),
            const SizedBox(width: 8),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.trending_up), text: 'Ingresos'),
              Tab(icon: Icon(Icons.trending_down), text: 'Gastos'),
              Tab(icon: Icon(Icons.summarize), text: 'Resumen'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final indice = DefaultTabController.of(context).index;
            if (indice == 0) {
              await _abrirNuevoIngreso();
            } else if (indice == 1) {
              await _abrirNuevoGasto();
            } else {
              await _generarExtracto();
            }
          },
          child: const Icon(Icons.add),
        ),
        body: TabBarView(
          children: [
            _construirListaIngresos(),
            _construirListaGastos(),
            _construirResumen(),
          ],
        ),
      ),
    );
  }

  Widget _construirListaIngresos() {
    if (_ingresos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Sin ingresos registrados este año.\n'
            'Pulsa + para añadir el primero.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: _ingresos.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final a = _ingresos[i];
        return ListTile(
          leading: const Icon(Icons.trending_up,
              color: Color(0xFF5C6B3A)),
          title: Text(
            '${_formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(a.fechaMs))}'
            ' · ${a.concepto}',
          ),
          subtitle: Text(
            '${a.tipoIngreso} · '
            'base ${_formatoEuros.format(a.importeBaseCentimos / 100)}'
            '${a.compensacionReagpCentimos > 0 ? " · comp. REAGP ${_formatoEuros.format(a.compensacionReagpCentimos / 100)}" : ""}',
          ),
          trailing: Text(
            _formatoEuros.format(a.importeTotalCentimos / 100),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }

  Widget _construirListaGastos() {
    if (_gastos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Sin gastos registrados este año.\n'
            'Pulsa + para añadir el primero.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: _gastos.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final a = _gastos[i];
        return ListTile(
          leading: const Icon(Icons.trending_down,
              color: Color(0xFF5C6B3A)),
          title: Text(
            '${_formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(a.fechaMs))}'
            ' · ${a.concepto}',
          ),
          subtitle: Text(
            '${a.tipoGasto} · '
            'base ${_formatoEuros.format(a.importeBaseCentimos / 100)}'
            '${a.esParcelaConcreta ? " · parcela #${a.parcelaId}" : ""}',
          ),
          trailing: Text(
            _formatoEuros.format(a.importeTotalCentimos / 100),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        );
      },
    );
  }

  Widget _construirResumen() {
    final resultadoBruto = _totalBaseIngresos - _totalBaseGastos;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.shade300),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.gavel, color: Colors.amber.shade800),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Resumen PROVISIONAL hasta validación de asesor fiscal. '
                  'Las reglas IVA/REAGP olivar están sujetas a confirmación.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber.shade900,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _BloqueResumen(
          icono: Icons.account_balance,
          etiqueta: 'Régimen',
          valor: '${_etiquetaRegimenIrpf(_configuracion.regimenIrpf)}\n'
              '${_etiquetaRegimenIva(_configuracion.regimenIva)}',
        ),
        const SizedBox(height: 12),
        _BloqueResumen(
          icono: Icons.trending_up,
          etiqueta: 'Total ingresos (base)',
          valor: _formatoEuros.format(_totalBaseIngresos / 100),
        ),
        _BloqueResumen(
          icono: Icons.add_box,
          etiqueta: 'Total IVA repercutido',
          valor: _formatoEuros.format(_totalIvaRepercutido / 100),
        ),
        if (_totalCompensacionReagp > 0)
          _BloqueResumen(
            icono: Icons.savings,
            etiqueta: 'Total compensación REAGP',
            valor: _formatoEuros.format(_totalCompensacionReagp / 100),
          ),
        _BloqueResumen(
          icono: Icons.trending_down,
          etiqueta: 'Total gastos (base)',
          valor: _formatoEuros.format(_totalBaseGastos / 100),
        ),
        _BloqueResumen(
          icono: Icons.remove_circle_outline,
          etiqueta: 'Total IVA soportado',
          valor: _formatoEuros.format(_totalIvaSoportado / 100),
        ),
        const SizedBox(height: 12),
        Card(
          color: resultadoBruto >= 0
              ? Colors.green.shade50
              : Colors.red.shade50,
          child: ListTile(
            leading: Icon(
              resultadoBruto >= 0
                  ? Icons.check_circle_outline
                  : Icons.error_outline,
              color: resultadoBruto >= 0 ? Colors.green : Colors.red,
            ),
            title: Text(
              'Resultado bruto del año',
              style: TextStyle(
                color: resultadoBruto >= 0
                    ? Colors.green.shade900
                    : Colors.red.shade900,
              ),
            ),
            subtitle: Text(
              '(ingresos base − gastos base)',
              style: TextStyle(
                color: resultadoBruto >= 0
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
            trailing: Text(
              _formatoEuros.format(resultadoBruto / 100),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: resultadoBruto >= 0
                    ? Colors.green.shade900
                    : Colors.red.shade900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _generando ? null : _generarExtracto,
          icon: _generando
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.share),
          label: const Text('Generar extracto PDF y compartir'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _generando ? null : _imprimirExtracto,
          icon: const Icon(Icons.print),
          label: const Text('Generar y abrir'),
        ),
      ],
    );
  }
}

class _BloqueResumen extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const _BloqueResumen({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icono, color: const Color(0xFF5C6B3A)),
        title: Text(etiqueta),
        trailing: Text(
          valor,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

String _etiquetaRegimenIrpf(String regimen) {
  switch (regimen) {
    case 'estimacion_directa_simplificada':
      return 'IRPF: estimación directa simplificada';
    case 'estimacion_directa_normal':
      return 'IRPF: estimación directa normal';
    default:
      return 'IRPF: sin elegir';
  }
}

String _etiquetaRegimenIva(String regimen) {
  switch (regimen) {
    case 'reagp':
      return 'IVA: REAGP (compensación 12 % aceituna)';
    case 'general':
      return 'IVA: régimen general';
    default:
      return 'IVA: sin elegir';
  }
}
