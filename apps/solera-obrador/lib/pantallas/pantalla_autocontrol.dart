import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n, margenHojaSegura, separarCampoSolera;

import '../datos/base_datos.dart';
import '../datos/catalogos_generados/catalogo_controles_tipo.dart';
import '../estado/cambios_datos.dart';
import '../modelos/registro_autocontrol.dart';
import '../utiles/textos_obrador.dart';

/// Cuaderno de autocontrol del mes en curso.
class PantallaAutocontrol extends StatefulWidget {
  const PantallaAutocontrol({super.key});

  @override
  State<PantallaAutocontrol> createState() => _PantallaAutocontrolState();
}

class _PantallaAutocontrolState extends State<PantallaAutocontrol> {
  late Future<List<RegistroAutocontrol>> _registros;

  @override
  void initState() {
    super.initState();
    _registros = _cargar();
    cambiosDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    super.dispose();
  }

  void _recargar() => setState(() {
        _registros = _cargar();
      });

  Future<List<RegistroAutocontrol>> _cargar() {
    final ahora = DateTime.now();
    final inicioMes = DateTime(ahora.year, ahora.month);
    final inicioSiguiente = DateTime(ahora.year, ahora.month + 1);
    return BaseDatosSoleraObrador.instancia.listarRegistrosAutocontrol(
        desdeMs: inicioMes.millisecondsSinceEpoch,
        hastaMs: inicioSiguiente.millisecondsSinceEpoch - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('obra.autocontrol'))),
      floatingActionButton: FloatingActionButton(
        tooltip: SoleraL10n.t('obra.nuevo_control'),
        onPressed: () => mostrarAltaAutocontrol(context),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<RegistroAutocontrol>>(
        future: _registros,
        builder: (context, instantanea) {
          final registros = instantanea.data ?? const [];
          if (instantanea.connectionState == ConnectionState.done &&
              registros.isEmpty) {
            return Center(child: Text(SoleraL10n.t('obra.sin_controles_mes')));
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              for (final registro in registros.reversed)
                TarjetaRegistroAutocontrol(registro: registro),
            ],
          );
        },
      ),
    );
  }
}

/// Fila de un registro de autocontrol; en rojo si fue incorrecto.
class TarjetaRegistroAutocontrol extends StatelessWidget {
  const TarjetaRegistroAutocontrol({super.key, required this.registro});

  final RegistroAutocontrol registro;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final fecha = DateFormat.MMMd(SoleraL10n.idioma)
        .add_Hm()
        .format(DateTime.fromMillisecondsSinceEpoch(registro.fechaMs));
    final valor =
        registro.valor == null ? '' : ' · ${formatearNumero(registro.valor!)}';
    return ListTile(
      leading: Icon(
          registro.correcto ? Icons.check_circle_outline : Icons.error_outline,
          color: registro.correcto ? esquema.primary : esquema.error),
      title: Text(
          '${nombreTipoAutocontrol(registro.tipo)} · ${registro.elemento}$valor'),
      subtitle: Text([
        fecha,
        if (registro.responsable.isNotEmpty) registro.responsable,
        if (registro.accionCorrectora.isNotEmpty) registro.accionCorrectora,
        if (registro.faltaAccionCorrectora) SoleraL10n.t('obra.falta_accion'),
      ].join(' · ')),
    );
  }
}

/// Hoja inferior para apuntar un control en pocos toques.
Future<void> mostrarAltaAutocontrol(BuildContext context) async {
  final guardado = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _HojaAltaAutocontrol(),
  );
  if (guardado == true) avisarCambioDatos();
}

class _HojaAltaAutocontrol extends StatefulWidget {
  const _HojaAltaAutocontrol();

  @override
  State<_HojaAltaAutocontrol> createState() => _HojaAltaAutocontrolState();
}

class _HojaAltaAutocontrolState extends State<_HojaAltaAutocontrol> {
  String _tipo = tiposRegistroAutocontrol.first;
  bool _correcto = true;
  bool _guardando = false;
  final _elemento = TextEditingController();
  final _valor = TextEditingController();
  final _accion = TextEditingController();
  final _responsable = TextEditingController();

  @override
  void dispose() {
    for (final controlador in [_elemento, _valor, _accion, _responsable]) {
      controlador.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_guardando || _elemento.text.trim().isEmpty) return;
    setState(() {
      _guardando = true;
    });
    await BaseDatosSoleraObrador.instancia
        .guardarRegistroAutocontrol(RegistroAutocontrol(
      tipo: _tipo,
      fechaMs: DateTime.now().millisecondsSinceEpoch,
      elemento: _elemento.text.trim(),
      valor: leerNumero(_valor.text),
      correcto: _correcto,
      accionCorrectora: _accion.text.trim(),
      responsable: _responsable.text.trim(),
    ));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margenHojaSegura(context, const EdgeInsets.all(16)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(SoleraL10n.t('obra.nuevo_control'),
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tipo in tiposRegistroAutocontrol)
                  ChoiceChip(
                    label: Text(nombreTipoAutocontrol(tipo)),
                    selected: _tipo == tipo,
                    onSelected: (_) => setState(() => _tipo = tipo),
                  ),
              ],
            ),
            Wrap(
              spacing: 6,
              children: [
                for (final control in catalogoControlesTipo
                    .where((control) => control.tipo == _tipo))
                  ActionChip(
                    label: Text(control.elemento),
                    onPressed: () =>
                        setState(() => _elemento.text = control.elemento),
                  ),
              ],
            ),
            separarCampoSolera(TextField(
              controller: _elemento,
              decoration:
                  InputDecoration(labelText: SoleraL10n.t('obra.elemento')),
            )),
            if (_tipo == 'temperatura' || _tipo == 'proveedor')
              separarCampoSolera(TextField(
                controller: _valor,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                decoration: InputDecoration(
                    labelText: SoleraL10n.t('obra.temperatura_c')),
              )),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(SoleraL10n.t('obra.correcto')),
              value: _correcto,
              onChanged: (valor) => setState(() => _correcto = valor),
            ),
            if (!_correcto)
              separarCampoSolera(TextField(
                controller: _accion,
                decoration: InputDecoration(
                    labelText: SoleraL10n.t('obra.accion_correctora')),
              )),
            TextField(
              controller: _responsable,
              decoration:
                  InputDecoration(labelText: SoleraL10n.t('obra.responsable')),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _guardando ? null : _guardar,
              child: Text(SoleraL10n.t('guardar')),
            ),
          ],
        ),
      ),
    );
  }
}
