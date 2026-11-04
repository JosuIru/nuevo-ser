import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/configuracion_fiscal.dart';

/// Configuración fiscal del titular. Single-row — la BD nunca debe
/// tener más de una en v0.1. La elección del régimen IRPF e IVA es
/// **global** del titular: cambia qué columnas pide el extracto y
/// si los apuntes de venta de miel llevan IVA repercutido (régimen
/// general) o compensación REAGP del 12%.
///
/// **v1 provisional**: módulos NO está soportado. El asesor fiscal
/// debe pedirlo explícitamente y validar el formato del extracto
/// antes de añadirlo. Documentado en BLOQUEOS-PENDIENTES.md.
class PantallaConfiguracionFiscal extends StatefulWidget {
  PantallaConfiguracionFiscal({super.key});

  @override
  State<PantallaConfiguracionFiscal> createState() =>
      _PantallaConfiguracionFiscalState();
}

class _PantallaConfiguracionFiscalState
    extends State<PantallaConfiguracionFiscal> {
  static const _opcionesIrpf = <_Opcion>[
    _Opcion('sin_elegir', 'Sin elegir'),
    _Opcion(
      'estimacion_directa_simplificada',
      'Estimación directa simplificada',
    ),
    _Opcion('estimacion_directa_normal', 'Estimación directa normal'),
  ];

  static const _opcionesIva = <_Opcion>[
    _Opcion('sin_elegir', 'Sin elegir'),
    _Opcion('reagp', 'REAGP — régimen especial agricultura/ganadería/pesca'),
    _Opcion('general', 'Régimen general'),
  ];

  String _regimenIrpf = 'sin_elegir';
  String _regimenIva = 'sin_elegir';
  int _anoFiscalActivo = DateTime.now().year;

  bool _cargando = true;
  bool _guardando = false;
  ConfiguracionFiscal? _existente;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final cf = await BaseDatosSoleraApicola.instancia.obtenerConfiguracionFiscal();
    if (!mounted) return;
    setState(() {
      _existente = cf;
      _regimenIrpf = cf.regimenIrpf;
      _regimenIva = cf.regimenIva;
      _anoFiscalActivo =
          cf.anoFiscalActivo == 0 ? DateTime.now().year : cf.anoFiscalActivo;
      _cargando = false;
    });
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final actualizada = ConfiguracionFiscal(
      id: _existente?.id,
      regimenIrpf: _regimenIrpf,
      regimenIva: _regimenIva,
      anoFiscalActivo: _anoFiscalActivo,
    );
    await BaseDatosSoleraApicola.instancia
        .guardarConfiguracionFiscal(actualizada);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final anoActual = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('configuracion_fiscal'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              border: Border.all(color: Colors.amber.shade700),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Provisional. El formato del libro y del extracto está pendiente de '
              'validación por asesor fiscal. Antes de presentar nada en una '
              'declaración, contrasta con tu asesor.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          _Cabecera('IRPF'),
          RadioGroup<String>(
            groupValue: _regimenIrpf,
            onChanged: (v) => setState(() => _regimenIrpf = v ?? 'sin_elegir'),
            child: Column(
              children: _opcionesIrpf
                  .map((o) => RadioListTile<String>(
                        value: o.codigo,
                        title: Text(o.titulo),
                      ))
                  .toList(),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'El régimen de módulos no está disponible en v1: pendiente de validación con '
              'asesor fiscal antes de añadirlo.',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ),
          SizedBox(height: 16),
          _Cabecera('IVA'),
          RadioGroup<String>(
            groupValue: _regimenIva,
            onChanged: (v) => setState(() => _regimenIva = v ?? 'sin_elegir'),
            child: Column(
              children: _opcionesIva
                  .map((o) => RadioListTile<String>(
                        value: o.codigo,
                        title: Text(o.titulo),
                      ))
                  .toList(),
            ),
          ),
          if (_regimenIva == 'reagp')
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'En REAGP no repercutes IVA en la venta de miel. El comprador '
                'te paga la compensación del 12 % sobre la base. El IVA soportado '
                'en compras no es recuperable: se imputa como mayor coste.',
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
          if (_regimenIva == 'general')
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'En régimen general repercutes el 4 % de IVA en la venta de miel '
                '(alimento de primera necesidad, art. 91.1.1.1.º LIVA) y el IVA '
                'soportado en compras es recuperable.',
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
          SizedBox(height: 16),
          _Cabecera('Año fiscal'),
          DropdownButtonFormField<int>(
            initialValue: _anoFiscalActivo,
            decoration: InputDecoration(
              labelText: 'Año fiscal por defecto al abrir el libro',
              border: OutlineInputBorder(),
            ),
            items: List.generate(5, (i) => anoActual - 2 + i)
                .map((a) => DropdownMenuItem(value: a, child: Text(a.toString())))
                .toList(),
            onChanged: (v) =>
                setState(() => _anoFiscalActivo = v ?? anoActual),
          ),
          SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _guardando ? null : _guardar,
            icon: _guardando
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Icon(Icons.check),
            label: Text(SoleraL10n.t('guardar')),
          ),
        ],
      ),
    );
  }
}

class _Opcion {
  final String codigo;
  final String titulo;
  const _Opcion(this.codigo, this.titulo);
}

class _Cabecera extends StatelessWidget {
  final String texto;
  _Cabecera(this.texto);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(texto,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}
