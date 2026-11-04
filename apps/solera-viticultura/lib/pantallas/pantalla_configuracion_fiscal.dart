import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/configuracion_fiscal.dart';

/// Configuración fiscal del titular. Single-row. Cambia el cálculo
/// de IVA/compensación en los apuntes de venta de uva (REAGP 12% o
/// general 4%) y la columna repercutida en venta de vino (siempre
/// 21% — el vino es producto transformado y NO entra en REAGP).
///
/// **v1 provisional**: módulos NO está soportado. En agricultura
/// módulos sigue siendo común — el asesor fiscal puede pedirlo.
/// Documentado en BLOQUEOS-PENDIENTES.md (F1-12).
class PantallaConfiguracionFiscal extends StatefulWidget {
  PantallaConfiguracionFiscal({super.key});

  @override
  State<PantallaConfiguracionFiscal> createState() =>
      _PantallaConfiguracionFiscalState();
}

class _PantallaConfiguracionFiscalState
    extends State<PantallaConfiguracionFiscal> {
  // El segundo campo es la clave de traducción del texto visible.
  static const _opcionesIrpf = <_Opcion>[
    _Opcion('sin_elegir', 'viti.sin_elegir'),
    _Opcion('estimacion_directa_simplificada',
        'viti.estimacion_directa_simplificada'),
    _Opcion('estimacion_directa_normal', 'viti.estimacion_directa_normal'),
  ];

  static const _opcionesIva = <_Opcion>[
    _Opcion('sin_elegir', 'viti.sin_elegir'),
    _Opcion('reagp', 'viti.regimen_reagp'),
    _Opcion('general', 'viti.regimen_general'),
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
    final cf =
        await BaseDatosSoleraViticultura.instancia.obtenerConfiguracionFiscal();
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
    await BaseDatosSoleraViticultura.instancia
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
              SoleraL10n.t('viti.aviso_fiscal_provisional'),
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
              SoleraL10n.t('viti.modulos_no_disponible'),
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
                SoleraL10n.t('viti.explicacion_reagp'),
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
          if (_regimenIva == 'general')
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                SoleraL10n.t('viti.explicacion_regimen_general'),
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
            ),
          SizedBox(height: 16),
          _Cabecera(SoleraL10n.t('viti.ano_fiscal')),
          DropdownButtonFormField<int>(
            initialValue: _anoFiscalActivo,
            decoration: InputDecoration(
              labelText: SoleraL10n.t('viti.ano_fiscal_por_defecto'),
              border: OutlineInputBorder(),
            ),
            items: List.generate(5, (i) => anoActual - 2 + i)
                .map((a) =>
                    DropdownMenuItem(value: a, child: Text(a.toString())))
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
  final String claveTitulo;
  const _Opcion(this.codigo, this.claveTitulo);

  String get titulo => SoleraL10n.t(claveTitulo);
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
