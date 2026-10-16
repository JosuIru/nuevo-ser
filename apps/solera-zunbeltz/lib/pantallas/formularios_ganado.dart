import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../datos/base_datos.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/ganado.dart';
import '../utiles/numeros.dart';
import 'widgets/cuerpo_responsivo.dart';
import 'widgets/relleno_seguro.dart';

String get _miUid => sesionEspacio.value?.persona.uid ?? '';

/// Las zonas de todas las fincas como opciones «Pasillo · Zunbeltz»,
/// ordenadas por finca y nombre.
Future<List<(int, String)>> _opcionesZona(BaseDatosSoleraZunbeltz bd) async {
  final fincas = {for (final finca in await bd.listarFincas()) finca.id: finca};
  final opciones = [
    for (final zona in await bd.listarZonas())
      if (zona.id != null)
        (
          zona.id!,
          [
            if (zona.nombre.isNotEmpty) zona.nombre,
            if (fincas[zona.fincaId] != null) fincas[zona.fincaId]!.nombre,
          ].join(' · ')
        ),
  ];
  opciones.sort((a, b) => a.$2.toLowerCase().compareTo(b.$2.toLowerCase()));
  return opciones;
}

/// Desplegable de quién es el ganado: del espacio o de una persona.
Widget _campoTitular(
    BuildContext context, String valor, ValueChanged<String> alCambiar) {
  final textos = AppLocalizations.of(context);
  final personas = personasEspacio.value;
  final conocida = valor.isEmpty || personas.any((p) => p.uid == valor);
  return DropdownButtonFormField<String>(
    isExpanded: true,
    initialValue: conocida ? valor : '',
    decoration: InputDecoration(labelText: textos.ganTitular),
    items: [
      DropdownMenuItem(value: '', child: Text(textos.ganTitularEspacio)),
      for (final persona in personas)
        DropdownMenuItem(value: persona.uid, child: Text(persona.nombre)),
    ],
    onChanged: (uid) => alCambiar(uid ?? ''),
  );
}

Widget _campoFecha(BuildContext context, DateTime fecha, String etiqueta,
    ValueChanged<DateTime> alCambiar) {
  final idioma = Localizations.localeOf(context).languageCode;
  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.event_outlined),
    title: Text(etiqueta),
    subtitle: Text(DateFormat('dd/MM/yyyy', idioma).format(fecha)),
    trailing: const Icon(Icons.edit_calendar_outlined),
    onTap: () async {
      final elegida = await showDatePicker(
        context: context,
        initialDate: fecha,
        firstDate: DateTime(fecha.year - 30),
        lastDate: DateTime(DateTime.now().year + 1),
      );
      if (elegida != null) alCambiar(elegida);
    },
  );
}

/// Un número entero escrito a mano; vacío = 0; null si no se entiende.
int? _leerEntero(String texto) {
  if (texto.trim().isEmpty) return 0;
  final numero = leerNumero(texto, nullSiAmbiguo: true);
  if (numero == null || numero < 0 || numero != numero.roundToDouble()) {
    return null;
  }
  return numero.round();
}

/// Base de los formularios: un solo guardado aunque se toque dos veces.
mixin _GuardarUnaVez<T extends StatefulWidget> on State<T> {
  bool guardando = false;

  Future<void> guardar();

  Future<void> guardarUnaVez() async {
    if (guardando) return;
    setState(() => guardando = true);
    try {
      await guardar();
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  void avisar(String texto) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(texto)));

  Widget botonGuardar(AppLocalizations textos) => FilledButton.icon(
        onPressed: guardando ? null : guardarUnaVez,
        icon: const Icon(Icons.save),
        label: Text(textos.comunGuardar),
      );
}

// ─── Lote ───────────────────────────────────────────────

/// Alta o edición de un lote. En el alta se puede decir en qué pieza está:
/// queda apuntado como su entrada.
class FormularioLote extends StatefulWidget {
  const FormularioLote({super.key, this.lote});

  final LoteGanado? lote;

  @override
  State<FormularioLote> createState() => _FormularioLoteState();
}

class _FormularioLoteState extends State<FormularioLote>
    with _GuardarUnaVez<FormularioLote> {
  final _bd = BaseDatosSoleraZunbeltz();
  late final _nombre = TextEditingController(text: widget.lote?.nombre);
  late final _sinIdentificar = TextEditingController(
      text: (widget.lote?.cabezasSinIdentificar ?? 0) == 0
          ? ''
          : '${widget.lote!.cabezasSinIdentificar}');
  late final _notas = TextEditingController(text: widget.lote?.notas);
  late String _especie = widget.lote?.especie ?? 'ovino';
  late String _titular = widget.lote?.titularUid ?? '';
  late bool _activo = widget.lote?.activo ?? true;
  List<(int, String)> _zonas = const [];
  int? _zonaInicial;
  DateTime _fechaEntrada = DateTime.now();

  bool get _esAlta => widget.lote == null;

  @override
  void initState() {
    super.initState();
    if (_esAlta) {
      _opcionesZona(_bd).then((zonas) {
        if (mounted) setState(() => _zonas = zonas);
      });
    }
  }

  @override
  void dispose() {
    _nombre.dispose();
    _sinIdentificar.dispose();
    _notas.dispose();
    super.dispose();
  }

  @override
  Future<void> guardar() async {
    final textos = AppLocalizations.of(context);
    if (_nombre.text.trim().isEmpty) {
      avisar(textos.ganNombreObligatorio);
      return;
    }
    final sinIdentificar = _leerEntero(_sinIdentificar.text);
    if (sinIdentificar == null) {
      avisar(textos.numeroNoValido);
      return;
    }
    final datos = {
      'nombre': _nombre.text.trim(),
      'especie': _especie,
      'titular_uid': _titular,
      'cabezas_sin_identificar': sinIdentificar,
      'estado': _activo ? estadoLoteActivo : estadoLoteCerrado,
      'notas': _notas.text.trim(),
    };
    if (_esAlta) {
      final loteId = await _bd
          .guardarLote(LoteGanado.fromMap({...datos, 'autor_uid': _miUid}));
      if (_zonaInicial != null) {
        await _bd.moverLote(
          loteId: loteId,
          fechaMs: _fechaEntrada.millisecondsSinceEpoch,
          tipo: tipoMovimientoEntrada,
          zonaDestinoId: _zonaInicial,
          autorUid: _miUid,
        );
      }
    } else {
      await _bd.actualizarLote(widget.lote!.id!, datos);
    }
    if (!mounted) return;
    avisar(textos.ganGuardado);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(
          title: Text(_esAlta ? textos.ganNuevoLote : textos.ganEditarLote)),
      body: CuerpoResponsivo(
        child: ListView(
          padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(16)),
          children: [
            TextField(
              controller: _nombre,
              autofocus: _esAlta,
              decoration: InputDecoration(
                  labelText: textos.ganNombreLote,
                  helperText: textos.ganNombreLoteAyuda),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: buscarOpcion(especiesGanado, _especie) == null
                  ? 'varias'
                  : _especie,
              decoration: InputDecoration(labelText: textos.ganEspecie),
              items: [
                for (final especie in especiesGanado)
                  DropdownMenuItem(
                      value: especie.codigo,
                      child: Text(especie.etiqueta(idioma))),
              ],
              onChanged: (valor) =>
                  setState(() => _especie = valor ?? _especie),
            ),
            const SizedBox(height: 12),
            _campoTitular(
                context, _titular, (uid) => setState(() => _titular = uid)),
            const SizedBox(height: 12),
            TextField(
              controller: _sinIdentificar,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: textos.ganCabezasSinIdentificar,
                  helperText: textos.ganCabezasSinIdentificarAyuda,
                  helperMaxLines: 3),
            ),
            if (_esAlta) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                isExpanded: true,
                initialValue: _zonaInicial,
                decoration: InputDecoration(labelText: textos.ganDondeEsta),
                items: [
                  DropdownMenuItem(
                      value: null, child: Text(textos.ganSinUbicar)),
                  for (final (id, nombre) in _zonas)
                    DropdownMenuItem(value: id, child: Text(nombre)),
                ],
                onChanged: (valor) => setState(() => _zonaInicial = valor),
              ),
              if (_zonaInicial != null)
                _campoFecha(context, _fechaEntrada, textos.ganFechaEntrada,
                    (fecha) => setState(() => _fechaEntrada = fecha)),
            ] else
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(textos.ganLoteActivo),
                subtitle: Text(textos.ganLoteActivoAyuda),
                value: _activo,
                onChanged: (valor) => setState(() => _activo = valor),
              ),
            const SizedBox(height: 12),
            TextField(
                controller: _notas,
                maxLines: 3,
                decoration: InputDecoration(labelText: textos.ganNotas)),
            const SizedBox(height: 24),
            botonGuardar(textos),
          ],
        ),
      ),
    );
  }
}

// ─── Animal ─────────────────────────────────────────────

/// Alta o edición de un animal identificado.
class FormularioAnimal extends StatefulWidget {
  const FormularioAnimal({super.key, this.animal, this.loteId});

  final Animal? animal;

  /// Lote en el que entra (al darlo de alta desde la ficha de un lote).
  final int? loteId;

  @override
  State<FormularioAnimal> createState() => _FormularioAnimalState();
}

class _FormularioAnimalState extends State<FormularioAnimal>
    with _GuardarUnaVez<FormularioAnimal> {
  final _bd = BaseDatosSoleraZunbeltz();
  late final _identificacion =
      TextEditingController(text: widget.animal?.identificacion);
  late final _nombre = TextEditingController(text: widget.animal?.nombre);
  late final _raza = TextEditingController(text: widget.animal?.raza);
  late final _madre = TextEditingController(text: widget.animal?.madre);
  late final _notas = TextEditingController(text: widget.animal?.notas);
  late String _especie = widget.animal?.especie ?? '';
  late String _sexo = widget.animal?.sexo ?? '';
  late String _titular = widget.animal?.titularUid ?? '';
  late int? _loteId = widget.animal?.loteId ?? widget.loteId;
  late DateTime? _nacimiento = widget.animal?.fechaNacimientoMs == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(widget.animal!.fechaNacimientoMs!);
  List<LoteGanado> _lotes = const [];

  bool get _esAlta => widget.animal == null;

  @override
  void initState() {
    super.initState();
    _bd.listarLotes(soloActivos: true).then((lotes) {
      if (!mounted) return;
      setState(() {
        _lotes = lotes;
        // Al entrar en un lote toma su especie, si no se ha dicho otra.
        if (_especie.isEmpty) {
          _especie =
              lotes.where((lote) => lote.id == _loteId).firstOrNull?.especie ??
                  '';
        }
      });
    });
  }

  @override
  void dispose() {
    for (final controlador in [
      _identificacion,
      _nombre,
      _raza,
      _madre,
      _notas
    ]) {
      controlador.dispose();
    }
    super.dispose();
  }

  @override
  Future<void> guardar() async {
    final textos = AppLocalizations.of(context);
    if (_identificacion.text.trim().isEmpty && _nombre.text.trim().isEmpty) {
      avisar(textos.ganIdentificacionObligatoria);
      return;
    }
    final datos = {
      'identificacion': _identificacion.text.trim(),
      'nombre': _nombre.text.trim(),
      'especie': _especie,
      'raza': _raza.text.trim(),
      'sexo': _sexo,
      'fecha_nacimiento_ms': _nacimiento?.millisecondsSinceEpoch,
      'madre': _madre.text.trim(),
      'lote_id': _loteId,
      'titular_uid': _titular,
      'notas': _notas.text.trim(),
    };
    if (_esAlta) {
      await _bd.guardarAnimal(Animal.fromMap({...datos, 'autor_uid': _miUid}));
    } else {
      await _bd.actualizarAnimal(widget.animal!.id!, datos);
    }
    if (!mounted) return;
    avisar(textos.ganGuardado);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final loteConocido =
        _loteId == null || _lotes.any((lote) => lote.id == _loteId);
    return Scaffold(
      appBar: AppBar(
          title:
              Text(_esAlta ? textos.ganNuevoAnimal : textos.ganEditarAnimal)),
      body: CuerpoResponsivo(
        child: ListView(
          padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(16)),
          children: [
            TextField(
              controller: _identificacion,
              autofocus: _esAlta,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                  labelText: textos.ganIdentificacion,
                  helperText: textos.ganIdentificacionAyuda),
            ),
            const SizedBox(height: 12),
            TextField(
                controller: _nombre,
                decoration: InputDecoration(labelText: textos.ganNombreAnimal)),
            const SizedBox(height: 12),
            // Mientras cargan los lotes, un lote que aún no está en la lista
            // haría fallar el desplegable.
            if (loteConocido)
              DropdownButtonFormField<int?>(
                isExpanded: true,
                initialValue: _loteId,
                decoration: InputDecoration(labelText: textos.ganLote),
                items: [
                  DropdownMenuItem(value: null, child: Text(textos.ganSinLote)),
                  for (final lote in _lotes)
                    DropdownMenuItem(value: lote.id, child: Text(lote.nombre)),
                ],
                onChanged: (valor) => setState(() => _loteId = valor),
              ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: buscarOpcion(especiesGanado, _especie) == null
                  ? ''
                  : _especie,
              decoration: InputDecoration(labelText: textos.ganEspecie),
              items: [
                const DropdownMenuItem(value: '', child: Text('—')),
                for (final especie in especiesGanado)
                  DropdownMenuItem(
                      value: especie.codigo,
                      child: Text(especie.etiqueta(idioma))),
              ],
              onChanged: (valor) => setState(() => _especie = valor ?? ''),
            ),
            const SizedBox(height: 12),
            TextField(
                controller: _raza,
                decoration: InputDecoration(labelText: textos.ganRaza)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue:
                  buscarOpcion(sexosAnimal, _sexo) == null ? '' : _sexo,
              decoration: InputDecoration(labelText: textos.ganSexo),
              items: [
                const DropdownMenuItem(value: '', child: Text('—')),
                for (final sexo in sexosAnimal)
                  DropdownMenuItem(
                      value: sexo.codigo, child: Text(sexo.etiqueta(idioma))),
              ],
              onChanged: (valor) => setState(() => _sexo = valor ?? ''),
            ),
            const SizedBox(height: 4),
            _nacimiento == null
                ? ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.cake_outlined),
                    title: Text(textos.ganNacimiento),
                    subtitle: Text(textos.ganSinFecha),
                    trailing: const Icon(Icons.edit_calendar_outlined),
                    onTap: () async {
                      final elegida = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(DateTime.now().year - 30),
                        lastDate: DateTime.now(),
                      );
                      if (elegida != null) {
                        setState(() => _nacimiento = elegida);
                      }
                    },
                  )
                : _campoFecha(context, _nacimiento!, textos.ganNacimiento,
                    (fecha) => setState(() => _nacimiento = fecha)),
            TextField(
                controller: _madre,
                decoration: InputDecoration(labelText: textos.ganMadre)),
            const SizedBox(height: 12),
            _campoTitular(
                context, _titular, (uid) => setState(() => _titular = uid)),
            const SizedBox(height: 12),
            TextField(
                controller: _notas,
                maxLines: 3,
                decoration: InputDecoration(labelText: textos.ganNotas)),
            const SizedBox(height: 24),
            botonGuardar(textos),
          ],
        ),
      ),
    );
  }
}

// ─── Movimiento ─────────────────────────────────────────

/// Mover un lote: a otra pieza, fuera del espacio o de vuelta.
class FormularioMovimiento extends StatefulWidget {
  const FormularioMovimiento(
      {super.key, required this.lote, this.zonaDestinoId});

  final LoteGanado lote;

  /// Pieza ya elegida (al traer un lote desde la ficha de una zona).
  final int? zonaDestinoId;

  @override
  State<FormularioMovimiento> createState() => _FormularioMovimientoState();
}

class _FormularioMovimientoState extends State<FormularioMovimiento>
    with _GuardarUnaVez<FormularioMovimiento> {
  final _bd = BaseDatosSoleraZunbeltz();
  final _destinoExterno = TextEditingController();
  final _guia = TextEditingController();
  final _notas = TextEditingController();
  List<(int, String)> _zonas = const [];
  late int? _zonaDestino = widget.zonaDestinoId;
  int? _zonaActual;
  bool _fueraDelEspacio = false;
  String _tipo = tipoMovimientoTraslado;
  DateTime _fecha = DateTime.now();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final zonas = await _opcionesZona(_bd);
    final ultimo =
        ultimoMovimiento(await _bd.listarMovimientos(loteId: widget.lote.id));
    if (!mounted) return;
    setState(() {
      _zonas = zonas;
      _fueraDelEspacio = ultimo == null || ultimo.esSalida;
      _zonaActual =
          ultimo == null || ultimo.esSalida ? null : ultimo.zonaDestinoId;
      // Si está fuera (o nunca se ha movido), lo normal es que entre.
      _tipo = _fueraDelEspacio ? tipoMovimientoEntrada : tipoMovimientoTraslado;
    });
  }

  @override
  void dispose() {
    _destinoExterno.dispose();
    _guia.dispose();
    _notas.dispose();
    super.dispose();
  }

  @override
  Future<void> guardar() async {
    final textos = AppLocalizations.of(context);
    final esSalida = _tipo == tipoMovimientoSalida;
    if (!esSalida && _zonaDestino == null) {
      avisar(textos.ganDestinoObligatorio);
      return;
    }
    if (!esSalida && _zonaDestino == _zonaActual) {
      avisar(textos.ganYaEstaAhi);
      return;
    }
    await _bd.moverLote(
      loteId: widget.lote.id!,
      fechaMs: _fecha.millisecondsSinceEpoch,
      tipo: _tipo,
      zonaDestinoId: esSalida ? null : _zonaDestino,
      destinoExterno: esSalida || _tipo == tipoMovimientoEntrada
          ? _destinoExterno.text.trim()
          : '',
      guia: _guia.text.trim(),
      notas: _notas.text.trim(),
      autorUid: _miUid,
    );
    if (!mounted) return;
    avisar(textos.ganMovimientoGuardado);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final esSalida = _tipo == tipoMovimientoSalida;
    final nombreActual = _zonas
        .where((zona) => zona.$1 == _zonaActual)
        .map((zona) => zona.$2)
        .firstOrNull;
    final destinoConocido =
        _zonaDestino == null || _zonas.any((zona) => zona.$1 == _zonaDestino);
    return Scaffold(
      appBar: AppBar(title: Text(textos.ganMoverTitulo(widget.lote.nombre))),
      body: CuerpoResponsivo(
        child: ListView(
          padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(16)),
          children: [
            Text(
              nombreActual == null
                  ? textos.ganAhoraFuera
                  : textos.ganAhoraEn(nombreActual),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _tipo,
              decoration: InputDecoration(labelText: textos.ganTipoMovimiento),
              items: [
                for (final tipo in tiposMovimientoGanado)
                  DropdownMenuItem(
                      value: tipo.codigo, child: Text(tipo.etiqueta(idioma))),
              ],
              onChanged: (valor) => setState(() => _tipo = valor ?? _tipo),
            ),
            const SizedBox(height: 12),
            if (!esSalida && destinoConocido)
              DropdownButtonFormField<int?>(
                isExpanded: true,
                initialValue: _zonaDestino,
                decoration: InputDecoration(labelText: textos.ganAQuePieza),
                items: [
                  for (final (id, nombre) in _zonas)
                    DropdownMenuItem(value: id, child: Text(nombre)),
                ],
                onChanged: (valor) => setState(() => _zonaDestino = valor),
              ),
            if (esSalida || _tipo == tipoMovimientoEntrada) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _destinoExterno,
                decoration: InputDecoration(
                    labelText: esSalida
                        ? textos.ganAdondeSale
                        : textos.ganDeDondeViene,
                    helperText: esSalida ? textos.ganAdondeSaleAyuda : null),
              ),
            ],
            const SizedBox(height: 4),
            _campoFecha(context, _fecha, textos.comunFecha,
                (fecha) => setState(() => _fecha = fecha)),
            TextField(
                controller: _guia,
                decoration: InputDecoration(
                    labelText: textos.ganGuia,
                    helperText: textos.ganGuiaAyuda)),
            const SizedBox(height: 12),
            TextField(
                controller: _notas,
                maxLines: 2,
                decoration: InputDecoration(labelText: textos.ganNotas)),
            const SizedBox(height: 24),
            botonGuardar(textos),
          ],
        ),
      ),
    );
  }
}

// ─── Eventos de manejo ──────────────────────────────────

/// Apuntar una cura o tratamiento, un pesaje, un parto… a un animal o a
/// un lote entero.
class FormularioEventoGanado extends StatefulWidget {
  const FormularioEventoGanado(
      {super.key, this.animalId, this.loteId, this.titulo = ''})
      : assert(animalId != null || loteId != null);

  final int? animalId;
  final int? loteId;

  /// A quién se le apunta (el crotal o el nombre del lote).
  final String titulo;

  @override
  State<FormularioEventoGanado> createState() => _FormularioEventoGanadoState();
}

class _FormularioEventoGanadoState extends State<FormularioEventoGanado>
    with _GuardarUnaVez<FormularioEventoGanado> {
  final _bd = BaseDatosSoleraZunbeltz();
  final _descripcion = TextEditingController();
  final _sustancia = TextEditingController();
  final _dosis = TextEditingController();
  final _supresionCarne = TextEditingController();
  final _supresionLeche = TextEditingController();
  final _veterinario = TextEditingController();
  final _receta = TextEditingController();
  final _peso = TextEditingController();
  final _crias = TextEditingController();
  final _cabezas = TextEditingController();
  String _tipo = tipoEventoTratamiento;
  DateTime _fecha = DateTime.now();

  bool get _esDeLote => widget.animalId == null;

  @override
  void dispose() {
    for (final controlador in [
      _descripcion,
      _sustancia,
      _dosis,
      _supresionCarne,
      _supresionLeche,
      _veterinario,
      _receta,
      _peso,
      _crias,
      _cabezas,
    ]) {
      controlador.dispose();
    }
    super.dispose();
  }

  @override
  Future<void> guardar() async {
    final textos = AppLocalizations.of(context);
    final conMedicamento = tiposEventoConMedicamento.contains(_tipo);
    if (conMedicamento && _sustancia.text.trim().isEmpty) {
      avisar(textos.ganSustanciaObligatoria);
      return;
    }
    double? peso;
    if (_tipo == tipoEventoPesaje) {
      peso = leerNumero(_peso.text, nullSiAmbiguo: true);
      if (peso == null || peso <= 0) {
        avisar(textos.ganPesoObligatorio);
        return;
      }
    }
    final carne = _leerEntero(_supresionCarne.text);
    final leche = _leerEntero(_supresionLeche.text);
    final crias = _leerEntero(_crias.text);
    final cabezas = _leerEntero(_cabezas.text);
    if (carne == null || leche == null || crias == null || cabezas == null) {
      avisar(textos.numeroNoValido);
      return;
    }
    await _bd.guardarEventoGanado(EventoGanado(
      animalId: widget.animalId,
      loteId: _esDeLote ? widget.loteId : null,
      fechaMs: _fecha.millisecondsSinceEpoch,
      tipo: _tipo,
      descripcion: _descripcion.text.trim(),
      sustanciaActiva: conMedicamento ? _sustancia.text.trim() : '',
      dosis: conMedicamento ? _dosis.text.trim() : '',
      plazoSupresionCarneDias: conMedicamento ? carne : 0,
      plazoSupresionLecheDias: conMedicamento ? leche : 0,
      veterinario: conMedicamento ? _veterinario.text.trim() : '',
      receta: conMedicamento ? _receta.text.trim() : '',
      pesoKg: peso,
      crias: _tipo == tipoEventoParto ? crias : 0,
      cabezas: _esDeLote ? cabezas : 0,
      autorUid: _miUid,
    ));
    if (!mounted) return;
    avisar(textos.ganGuardado);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final conMedicamento = tiposEventoConMedicamento.contains(_tipo);
    final numero = TextInputType.number;
    return Scaffold(
      appBar: AppBar(title: Text(textos.ganManejoTitulo(widget.titulo))),
      body: CuerpoResponsivo(
        child: ListView(
          padding: rellenoSobreBarraSistema(context, const EdgeInsets.all(16)),
          children: [
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _tipo,
              decoration: InputDecoration(labelText: textos.ganTipoManejo),
              items: [
                for (final tipo in tiposEventoGanado)
                  DropdownMenuItem(
                      value: tipo.codigo, child: Text(tipo.etiqueta(idioma))),
              ],
              onChanged: (valor) => setState(() => _tipo = valor ?? _tipo),
            ),
            const SizedBox(height: 4),
            _campoFecha(context, _fecha, textos.comunFecha,
                (fecha) => setState(() => _fecha = fecha)),
            if (conMedicamento) ...[
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(textos.ganAvisoVeterinario,
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                  controller: _sustancia,
                  decoration:
                      InputDecoration(labelText: textos.ganSustanciaActiva)),
              const SizedBox(height: 12),
              TextField(
                  controller: _dosis,
                  decoration: InputDecoration(labelText: textos.ganDosis)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                      controller: _supresionCarne,
                      keyboardType: numero,
                      decoration: InputDecoration(
                          labelText: textos.ganSupresionCarneDias,
                          suffixText: textos.ganDias)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                      controller: _supresionLeche,
                      keyboardType: numero,
                      decoration: InputDecoration(
                          labelText: textos.ganSupresionLecheDias,
                          suffixText: textos.ganDias)),
                ),
              ]),
              const SizedBox(height: 12),
              TextField(
                  controller: _veterinario,
                  decoration:
                      InputDecoration(labelText: textos.ganVeterinario)),
              const SizedBox(height: 12),
              TextField(
                  controller: _receta,
                  decoration: InputDecoration(labelText: textos.ganReceta)),
            ],
            if (_tipo == tipoEventoPesaje) ...[
              const SizedBox(height: 12),
              TextField(
                  controller: _peso,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: textos.ganPeso, suffixText: 'kg')),
            ],
            if (_tipo == tipoEventoParto) ...[
              const SizedBox(height: 12),
              TextField(
                  controller: _crias,
                  keyboardType: numero,
                  decoration: InputDecoration(labelText: textos.ganCrias)),
            ],
            if (_esDeLote) ...[
              const SizedBox(height: 12),
              TextField(
                  controller: _cabezas,
                  keyboardType: numero,
                  decoration: InputDecoration(
                      labelText: textos.ganCabezasTratadas,
                      helperText: textos.ganCabezasTratadasAyuda)),
            ],
            const SizedBox(height: 12),
            TextField(
                controller: _descripcion,
                maxLines: 3,
                decoration: InputDecoration(labelText: textos.ganDescripcion)),
            const SizedBox(height: 24),
            botonGuardar(textos),
          ],
        ),
      ),
    );
  }
}
