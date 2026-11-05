import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/ganado.dart';
import '../modelos/ganado_ecologico.dart';
import '../modelos/zona_finca.dart';
import '../servicios/generador_libro_explotacion.dart';
import '../utiles/crotal.dart';
import '../utiles/numeros.dart';
import 'pantalla_escaner_crotal.dart';
import 'pantalla_ganado.dart' show etiquetaEspecie, nombresDeZonas;
import 'widgets/cuerpo_responsivo.dart';
import 'widgets/ganado_visual.dart';
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
  late bool _ecologico = widget.lote?.ecologico ?? false;
  late bool _cicloCorto = widget.lote?.cicloCorto ?? false;
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
      'ecologico': _ecologico ? 1 : 0,
      'ciclo_corto': _cicloCorto ? 1 : 0,
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
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(textos.ganEcologico),
              subtitle: Text(textos.ganEcologicoAyuda),
              value: _ecologico,
              onChanged: (valor) => setState(() => _ecologico = valor),
            ),
            if (_ecologico)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(textos.ganCicloCorto),
                subtitle: Text(textos.ganCicloCortoAyuda),
                value: _cicloCorto,
                onChanged: (valor) => setState(() => _cicloCorto = valor),
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

// ─── Piezas comunes de los formularios a pantalla completa ──────────────

/// Una fecha en una caja de campo, como un TextField: rótulo, valor (o el
/// rótulo como pista si no hay) y el calendario a la derecha.
class _CajaFecha extends StatelessWidget {
  const _CajaFecha({
    required this.etiqueta,
    required this.valor,
    required this.alPulsar,
  });

  final String etiqueta;
  final String? valor;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: alPulsar,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        isEmpty: valor == null,
        decoration: InputDecoration(
          labelText: etiqueta,
          suffixIcon: const Icon(Icons.calendar_month_outlined),
        ),
        child: Text(valor ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

/// Barra fija de abajo con los botones de guardar, sobre una raya.
Widget _barraInferior(BuildContext context, List<Widget> botones) {
  return DecoratedBox(
    decoration: BoxDecoration(
      color: context.esquemaZunbeltz.surfaceContainerLow,
      border: Border(
          top: BorderSide(color: context.esquemaZunbeltz.outlineVariant)),
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(children: [
          for (var indice = 0; indice < botones.length; indice++) ...[
            if (indice > 0) const SizedBox(width: 12),
            Expanded(child: botones[indice]),
          ],
        ]),
      ),
    ),
  );
}

/// Rótulo de sección dentro de un formulario («Sexo», «A qué pieza»).
Widget _rotuloSeccion(BuildContext context, String texto) => Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(texto,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600)),
    );

// ─── Animal ─────────────────────────────────────────────

/// Alta o edición de un animal identificado. Con un rebaño elegido, la
/// especie y de quién es se toman de él; «Guardar y otro» deja el
/// formulario listo para el siguiente del mismo rebaño.
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
  late final _identificacion = TextEditingController(
      text: widget.animal == null
          ? null
          : crotalLegible(widget.animal!.identificacion));
  late final _nombre = TextEditingController(text: widget.animal?.nombre);
  late final _raza = TextEditingController(text: widget.animal?.raza);
  late final _madre = TextEditingController(text: widget.animal?.madre);
  late final _notas = TextEditingController(text: widget.animal?.notas);
  final _focoIdentificacion = FocusNode();
  late String _especie = widget.animal?.especie ?? '';
  late String _sexo = widget.animal?.sexo ?? '';
  late String _titular = widget.animal?.titularUid ?? '';
  late int? _loteId = widget.animal?.loteId ?? widget.loteId;
  late DateTime? _nacimiento = widget.animal?.fechaNacimientoMs == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(widget.animal!.fechaNacimientoMs!);
  List<LoteGanado> _lotes = const [];

  /// «Guardar y otro»: guarda y deja el formulario para el siguiente.
  bool _seguirConOtro = false;

  /// Se ha guardado al menos uno (para avisar a quien abrió el formulario
  /// aunque se cierre con la X tras «Guardar y otro»).
  bool _guardadoAlguno = false;

  bool get _esAlta => widget.animal == null;

  LoteGanado? get _lote =>
      _lotes.where((lote) => lote.id == _loteId).firstOrNull;

  /// Con un rebaño de una sola especie, la especie es la suya; un rebaño
  /// de «varias» deja elegirla.
  bool get _especieDelRebano =>
      _lote != null &&
      buscarOpcion(especiesGanado, _lote!.especie) != null &&
      _lote!.especie != 'varias';

  @override
  void initState() {
    super.initState();
    _identificacion.addListener(_alEscribirCrotal);
    _bd.listarLotes(soloActivos: true).then((lotes) {
      if (!mounted) return;
      setState(() {
        _lotes = lotes;
        // Al entrar en un lote toma su especie, si no se ha dicho otra.
        if (_especie.isEmpty) _especie = _lote?.especie ?? '';
      });
    });
  }

  String _crotalEscrito = '';
  void _alEscribirCrotal() {
    if (_identificacion.text == _crotalEscrito) return;
    setState(() => _crotalEscrito = _identificacion.text);
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
    _focoIdentificacion.dispose();
    super.dispose();
  }

  void _cerrar() => Navigator.of(context).pop(_guardadoAlguno);

  /// Lo que se guarda como identificación: la forma oficial sin espacios
  /// si se reconoce («ES03 1101…» → «ES031101…»), si no lo escrito.
  String _identificacionAGuardar() {
    final escrito = _identificacion.text.trim();
    final lectura = interpretarCodigoCrotal(escrito);
    return lectura.reconocido ? lectura.identificacion : escrito;
  }

  @override
  Future<void> guardar() async {
    final textos = AppLocalizations.of(context);
    final seguir = _seguirConOtro;
    _seguirConOtro = false;
    if (_identificacion.text.trim().isEmpty && _nombre.text.trim().isEmpty) {
      avisar(textos.ganIdentificacionObligatoria);
      return;
    }
    final lote = _lote;
    final datos = {
      'identificacion': _identificacionAGuardar(),
      'nombre': _nombre.text.trim(),
      'especie': _especieDelRebano ? lote!.especie : _especie,
      'raza': _raza.text.trim(),
      'sexo': _sexo,
      'fecha_nacimiento_ms': _nacimiento?.millisecondsSinceEpoch,
      'madre': _madre.text.trim(),
      'lote_id': _loteId,
      'titular_uid': lote?.titularUid ?? _titular,
      'notas': _notas.text.trim(),
    };
    if (_esAlta) {
      await _bd.guardarAnimal(Animal.fromMap({...datos, 'autor_uid': _miUid}));
    } else {
      await _bd.actualizarAnimal(widget.animal!.id!, datos);
    }
    _guardadoAlguno = true;
    if (!mounted) return;
    avisar(textos.ganGuardado);
    if (seguir && _esAlta) {
      // Del mismo rebaño, raza, sexo y fecha suelen repetirse.
      setState(() {
        _identificacion.clear();
        _nombre.clear();
        _madre.clear();
        _notas.clear();
      });
      _focoIdentificacion.requestFocus();
      return;
    }
    Navigator.of(context).pop(true);
  }

  Future<void> _escanearEn(TextEditingController controlador) async {
    final textos = AppLocalizations.of(context);
    final leido = await escanearCrotal(context);
    if (leido == null || !mounted) return;
    setState(() => controlador.text = crotalLegible(leido));
    avisar(textos.ganCrotalLeido(leido));
  }

  Widget? _ayudaCrotal(AppLocalizations textos) {
    final colores = context.coloresZunbeltz;
    final escrito = _identificacion.text.trim();
    final estilo = Theme.of(context).textTheme.bodySmall;
    if (escrito.isEmpty) return null;
    final reconocido = interpretarCodigoCrotal(escrito).reconocido;
    final color = reconocido ? colores.hecha : colores.pendiente;
    return Row(children: [
      Icon(reconocido ? Icons.check_circle_outline : Icons.info_outline,
          size: 18, color: color),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
            reconocido ? textos.ganCrotalOficial : textos.ganCrotalNoOficial,
            style: estilo?.copyWith(color: color)),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final esquema = context.esquemaZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final loteConocido =
        _loteId == null || _lotes.any((lote) => lote.id == _loteId);
    final ayudaCrotal = _ayudaCrotal(textos);
    final botonEscanear = escanerCrotalDisponible
        ? Padding(
            padding: const EdgeInsets.only(right: 6),
            child: IconButton.filledTonal(
              tooltip: textos.ganEscanearCrotal,
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () => _escanearEn(_identificacion),
            ),
          )
        : null;
    final sexoElegido = buscarOpcion(sexosAnimal, _sexo) == null ? null : _sexo;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (salio, _) {
        if (!salio) _cerrar();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: CloseButton(onPressed: _cerrar),
          title: Text(_esAlta ? textos.ganNuevoAnimal : textos.ganEditarAnimal),
        ),
        bottomNavigationBar: _barraInferior(context, [
          if (_esAlta)
            OutlinedButton(
              onPressed: guardando
                  ? null
                  : () {
                      _seguirConOtro = true;
                      guardarUnaVez();
                    },
              child: Text(textos.ganGuardarYOtro,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          FilledButton.icon(
            onPressed: guardando ? null : guardarUnaVez,
            icon: const Icon(Icons.check),
            label: Text(textos.comunGuardar),
          ),
        ]),
        body: CuerpoResponsivo(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              TextField(
                controller: _identificacion,
                focusNode: _focoIdentificacion,
                autofocus: _esAlta,
                textCapitalization: TextCapitalization.characters,
                style: estilos.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.5),
                decoration: InputDecoration(
                  labelText: textos.ganIdentificacion,
                  helperText: ayudaCrotal == null
                      ? textos.ganIdentificacionAyuda
                      : null,
                  helperMaxLines: 2,
                  helper: ayudaCrotal,
                  suffixIcon: botonEscanear,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                  controller: _nombre,
                  textCapitalization: TextCapitalization.sentences,
                  decoration:
                      InputDecoration(labelText: textos.ganNombreAnimal)),
              const SizedBox(height: 16),
              // Mientras cargan los lotes, un lote que aún no está en la lista
              // haría fallar el desplegable.
              if (loteConocido)
                DropdownButtonFormField<int?>(
                  isExpanded: true,
                  initialValue: _loteId,
                  decoration: InputDecoration(
                    labelText: textos.ganLote,
                    helperText:
                        _loteId == null ? null : textos.ganDelRebanoAyuda,
                  ),
                  items: [
                    DropdownMenuItem(
                        value: null, child: Text(textos.ganSinLote)),
                    for (final lote in _lotes)
                      DropdownMenuItem(
                        value: lote.id,
                        child: Text(
                          [
                            lote.nombre,
                            if (buscarOpcion(especiesGanado, lote.especie) !=
                                    null &&
                                lote.especie != 'varias')
                              etiquetaEspecie(lote.especie, idioma),
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (valor) => setState(() {
                    _loteId = valor;
                    final lote = _lote;
                    if (lote != null &&
                        buscarOpcion(especiesGanado, lote.especie) != null) {
                      _especie = lote.especie;
                    }
                  }),
                ),
              if (!_especieDelRebano) ...[
                const SizedBox(height: 16),
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
              ],
              if (_loteId == null) ...[
                const SizedBox(height: 16),
                _campoTitular(
                    context, _titular, (uid) => setState(() => _titular = uid)),
              ],
              const SizedBox(height: 16),
              TextField(
                  controller: _raza,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(labelText: textos.ganRaza)),
              const SizedBox(height: 12),
              _rotuloSeccion(context, textos.ganSexo),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  emptySelectionAllowed: true,
                  segments: [
                    for (final sexo in sexosAnimal)
                      ButtonSegment(
                          value: sexo.codigo,
                          label: Text(sexo.etiqueta(idioma),
                              maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                  selected: {if (sexoElegido != null) sexoElegido},
                  onSelectionChanged: (elegidos) => setState(
                      () => _sexo = elegidos.isEmpty ? '' : elegidos.first),
                ),
              ),
              const SizedBox(height: 20),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: _CajaFecha(
                    etiqueta: textos.ganNacimiento,
                    valor: _nacimiento == null
                        ? null
                        : DateFormat('dd/MM/yyyy', idioma).format(_nacimiento!),
                    alPulsar: () async {
                      final elegida = await showDatePicker(
                        context: context,
                        initialDate: _nacimiento ?? DateTime.now(),
                        firstDate: DateTime(DateTime.now().year - 30),
                        lastDate: DateTime.now(),
                      );
                      if (elegida != null) {
                        setState(() => _nacimiento = elegida);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _madre,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: textos.ganMadre,
                      suffixIcon: escanerCrotalDisponible
                          ? IconButton(
                              tooltip: textos.ganEscanearCrotal,
                              icon: Icon(Icons.qr_code_scanner,
                                  color: esquema.onSurfaceVariant),
                              onPressed: () => _escanearEn(_madre),
                            )
                          : null,
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              TextField(
                  controller: _notas,
                  minLines: 3,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                      labelText: textos.ganNotas, alignLabelWithHint: true)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Movimiento ─────────────────────────────────────────

/// Mover un rebaño: a otra pieza, fuera del espacio o de vuelta. Arriba, el
/// plano con la pieza donde está y la elegida; las piezas se eligen en una
/// lista con su superficie y si ya hay otro rebaño en ellas. Al apuntarlo
/// puede sacar la hoja de movimiento en PDF.
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
  /// Se recuerda si se quiere la hoja en PDF al mover.
  static const _claveHoja = 'zunbeltz.hoja_al_mover';

  final _bd = BaseDatosSoleraZunbeltz();
  final _destinoExterno = TextEditingController();
  final _guia = TextEditingController();
  final _notas = TextEditingController();
  List<ZonaFinca> _zonas = const [];
  Map<int, String> _fincas = const {};

  /// Rebaños que hay en cada pieza (sin contar este).
  Map<int, List<String>> _ocupacion = const {};
  int _cabezas = 0;
  late int? _zonaDestino = widget.zonaDestinoId;
  int? _zonaActual;
  String _tipo = tipoMovimientoTraslado;
  DateTime _fecha = DateTime.now();
  bool _sacarHoja = true;
  bool _cargado = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final zonas = await _bd.listarZonas();
    final fincas = {
      for (final finca in await _bd.listarFincas())
        if (finca.id != null) finca.id!: finca.nombre
    };
    final resumenes = await _bd.listarResumenLotes();
    final ocupacion = <int, List<String>>{};
    var cabezas = 0;
    int? zonaActual;
    MovimientoGanado? ultimo;
    for (final resumen in resumenes) {
      if (resumen.lote.id == widget.lote.id) {
        cabezas = resumen.cabezas;
        zonaActual = resumen.zonaId;
        ultimo = resumen.ultimoMovimiento;
        continue;
      }
      final zona = resumen.zonaId;
      if (zona != null) {
        ocupacion.putIfAbsent(zona, () => []).add(resumen.lote.nombre);
      }
    }
    var sacarHoja = true;
    try {
      final preferencias = await SharedPreferences.getInstance();
      sacarHoja = preferencias.getBool(_claveHoja) ?? true;
    } catch (_) {}
    // Primero la finca donde está; dentro, las de pasto antes que el monte
    // y las grandes (parcela catastral, cierre); luego por nombre.
    final fincaActual =
        zonas.where((zona) => zona.id == zonaActual).firstOrNull?.fincaId;
    int rangoTipo(ZonaFinca zona) => switch (zona.tipo) {
          'parcela_pasto' || 'pastoreo' || 'siega' || 'cercado' => 0,
          'monte' => 1,
          _ => 2,
        };
    zonas.sort((a, b) {
      final porFincaActual = (a.fincaId == fincaActual ? 0 : 1)
          .compareTo(b.fincaId == fincaActual ? 0 : 1);
      if (porFincaActual != 0) return porFincaActual;
      final porFinca = (fincas[a.fincaId] ?? '')
          .toLowerCase()
          .compareTo((fincas[b.fincaId] ?? '').toLowerCase());
      if (porFinca != 0) return porFinca;
      final porTipo = rangoTipo(a).compareTo(rangoTipo(b));
      return porTipo != 0
          ? porTipo
          : a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase());
    });
    if (!mounted) return;
    setState(() {
      _zonas = zonas.where((zona) => zona.id != null).toList();
      _fincas = fincas;
      _ocupacion = ocupacion;
      _cabezas = cabezas;
      _zonaActual = zonaActual;
      _sacarHoja = sacarHoja;
      // Si está fuera (o nunca se ha movido), lo normal es que entre.
      final fuera = ultimo == null || ultimo.esSalida;
      _tipo = fuera ? tipoMovimientoEntrada : tipoMovimientoTraslado;
      _cargado = true;
    });
  }

  @override
  void dispose() {
    _destinoExterno.dispose();
    _guia.dispose();
    _notas.dispose();
    super.dispose();
  }

  ZonaFinca? _zona(int? id) =>
      id == null ? null : _zonas.where((zona) => zona.id == id).firstOrNull;

  Future<void> _cambiarHoja(bool valor) async {
    setState(() => _sacarHoja = valor);
    try {
      final preferencias = await SharedPreferences.getInstance();
      await preferencias.setBool(_claveHoja, valor);
    } catch (_) {}
  }

  @override
  Future<void> guardar() async {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final esSalida = _tipo == tipoMovimientoSalida;
    if (!esSalida && _zonaDestino == null) {
      avisar(textos.ganDestinoObligatorio);
      return;
    }
    if (!esSalida && _zonaDestino == _zonaActual) {
      avisar(textos.ganYaEstaAhi);
      return;
    }
    final movimientoId = await _bd.moverLote(
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
    if (_sacarHoja) {
      try {
        final movimiento = (await _bd.listarMovimientos(loteId: widget.lote.id))
            .where((movimiento) => movimiento.id == movimientoId)
            .first;
        final documento = await generarHojaMovimientoPdf(
          textos: textos,
          idioma: idioma,
          movimiento: movimiento,
          lote: widget.lote,
          animalesDelLote: await _bd.listarAnimales(
              loteId: widget.lote.id, soloActivos: true),
          zonas: await nombresDeZonas(_bd),
        );
        await Printing.sharePdf(
            bytes: documento.bytes, filename: documento.nombreFichero);
      } catch (_) {
        if (mounted) avisar(textos.ganHojaNoSalio);
      }
    }
    if (!mounted) return;
    avisar(textos.ganMovimientoGuardado);
    Navigator.of(context).pop(true);
  }

  String _textoFecha(AppLocalizations textos, String idioma) {
    final hoy = DateTime.now();
    final diaYMes = DateFormat('d MMM', idioma).format(_fecha);
    if (_fecha.year == hoy.year &&
        _fecha.month == hoy.month &&
        _fecha.day == hoy.day) {
      return textos.ganFechaHoy(diaYMes);
    }
    return DateFormat('d MMM yyyy', idioma).format(_fecha);
  }

  Widget _tarjetaRebano(AppLocalizations textos) {
    final esquema = context.esquemaZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final dondeEsta = _zona(_zonaActual)?.nombre;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: esquema.surfaceContainer,
        borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
      ),
      child: Row(children: [
        AvatarEspecie(especie: widget.lote.especie, tamano: 52),
        const SizedBox(width: 14),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.lote.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    estilos.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            Text(
              [
                textos.ganCabezas(_cabezas),
                if (dondeEsta != null && dondeEsta.isNotEmpty) dondeEsta,
              ].join(' · '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  estilos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _listaPiezas(AppLocalizations textos, String idioma) {
    final esquema = context.esquemaZunbeltz;
    final colores = context.coloresZunbeltz;
    final estilos = Theme.of(context).textTheme;
    final variasFincas = _fincas.length > 1;
    final piezas = _zonas.where((zona) => zona.id != _zonaActual).toList();
    final hectareas = NumberFormat('#,##0.00', idioma);
    return Container(
      decoration: BoxDecoration(
        color: esquema.surfaceContainer,
        borderRadius: BorderRadius.circular(radioTarjetaZunbeltz),
      ),
      clipBehavior: Clip.antiAlias,
      child: RadioGroup<int>(
        groupValue: _zonaDestino,
        onChanged: (valor) => setState(() => _zonaDestino = valor),
        child: Column(children: [
          for (var indice = 0; indice < piezas.length; indice++) ...[
            if (indice > 0)
              Divider(
                  height: 1,
                  indent: 64,
                  endIndent: 16,
                  color: esquema.outlineVariant),
            Builder(builder: (context) {
              final zona = piezas[indice];
              final otros = _ocupacion[zona.id] ?? const <String>[];
              final ocupada = otros.isNotEmpty;
              final detalle = [
                if (variasFincas && (_fincas[zona.fincaId] ?? '').isNotEmpty)
                  _fincas[zona.fincaId]!,
                if (zona.superficieHa > 0)
                  '${hectareas.format(zona.superficieHa)} ha',
                ocupada
                    ? textos.ganPiezaConRebanos(otros.join(', '))
                    : textos.ganPiezaLibre,
              ].join(' · ');
              return RadioListTile<int>(
                value: zona.id!,
                contentPadding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
                title: Text(zona.nombre.isEmpty ? '—' : zona.nombre,
                    style: estilos.titleMedium),
                subtitle: Text(detalle,
                    style: estilos.bodyMedium?.copyWith(
                        color: ocupada
                            ? colores.pendiente
                            : esquema.onSurfaceVariant)),
              );
            }),
          ],
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final esSalida = _tipo == tipoMovimientoSalida;
    final esEntrada = _tipo == tipoMovimientoEntrada;
    final origen = esEntrada ? null : _zona(_zonaActual);
    final destino = esSalida ? null : _zona(_zonaDestino);
    final hayPlano = (origen?.vertices.length ?? 0) >= 3 ||
        (destino?.vertices.length ?? 0) >= 3;
    final etiquetas = {
      tipoMovimientoTraslado: textos.ganMovEntrePiezas,
      tipoMovimientoEntrada: textos.ganMovEntrada,
      tipoMovimientoSalida: textos.ganMovSalida,
    };
    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: Text(textos.ganMoverUnRebano),
      ),
      bottomNavigationBar: _barraInferior(context, [
        FilledButton.icon(
          onPressed: guardando || !_cargado ? null : guardarUnaVez,
          icon: const Icon(Icons.trending_up),
          label: Text(textos.ganApuntarMovimiento),
        ),
      ]),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          if (hayPlano)
            PlanoMovimiento(
              origen: origen?.vertices ?? const [],
              destino: destino?.vertices ?? const [],
              rotuloOrigen: origen == null || origen.nombre.isEmpty
                  ? null
                  : textos.ganRotuloAhora(origen.nombre),
              rotuloDestino: destino == null || destino.nombre.isEmpty
                  ? null
                  : textos.ganRotuloDestino(destino.nombre),
            ),
          CuerpoResponsivo(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _rotuloSeccion(context, textos.ganTipoMovimiento),
                  SegmentedButton<String>(
                    // Con la marca, «Entre piezas» no cabe en un móvil.
                    showSelectedIcon: false,
                    segments: [
                      for (final tipo in tiposMovimientoGanado)
                        ButtonSegment(
                          value: tipo.codigo,
                          label: Text(
                              etiquetas[tipo.codigo] ?? tipo.etiqueta(idioma),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                    ],
                    selected: {_tipo},
                    onSelectionChanged: (elegidos) =>
                        setState(() => _tipo = elegidos.first),
                  ),
                  const SizedBox(height: 20),
                  _tarjetaRebano(textos),
                  if (!esSalida) ...[
                    const SizedBox(height: 16),
                    _rotuloSeccion(context, textos.ganAQuePieza),
                    _listaPiezas(textos, idioma),
                  ],
                  if (esSalida || esEntrada) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _destinoExterno,
                      decoration: InputDecoration(
                          labelText: esSalida
                              ? textos.ganAdondeSale
                              : textos.ganDeDondeViene,
                          helperText:
                              esSalida ? textos.ganAdondeSaleAyuda : null),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: _CajaFecha(
                        etiqueta: textos.comunFecha,
                        valor: _textoFecha(textos, idioma),
                        alPulsar: () async {
                          final elegida = await showDatePicker(
                            context: context,
                            initialDate: _fecha,
                            firstDate: DateTime(_fecha.year - 30),
                            lastDate: DateTime(DateTime.now().year + 1),
                          );
                          if (elegida != null) {
                            setState(() => _fecha = elegida);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _guia,
                        decoration:
                            InputDecoration(labelText: textos.ganGuiaOpcional),
                      ),
                    ),
                  ]),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: Text(textos.ganGuiaAyuda,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.esquemaZunbeltz.onSurfaceVariant)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                      controller: _notas,
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(labelText: textos.ganNotas)),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: const Icon(Icons.picture_as_pdf_outlined),
                    title: Text(textos.libroHoja),
                    subtitle: Text(textos.ganHojaAlApuntar),
                    value: _sacarHoja,
                    onChanged: _cambiarHoja,
                  ),
                ],
              ),
            ),
          ),
        ],
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
  String _clase = '';
  DateTime _fecha = DateTime.now();

  /// El rebaño (el del animal, o el propio) es ecológico.
  bool _ecologico = false;

  bool get _esDeLote => widget.animalId == null;

  @override
  void initState() {
    super.initState();
    _cargarSiEsEcologico();
  }

  Future<void> _cargarSiEsEcologico() async {
    var loteId = widget.loteId;
    final animalId = widget.animalId;
    if (animalId != null) loteId = (await _bd.obtenerAnimal(animalId))?.loteId;
    final lote = loteId == null ? null : await _bd.obtenerLote(loteId);
    if (mounted && lote != null) setState(() => _ecologico = lote.ecologico);
  }

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
      claseMedicamento: conMedicamento ? _clase : '',
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
              if (_ecologico) ...[
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(textos.ganAvisoEcologicoPlazo,
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                  controller: _sustancia,
                  decoration:
                      InputDecoration(labelText: textos.ganSustanciaActiva)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _clase,
                decoration:
                    InputDecoration(labelText: textos.ganClaseMedicamento),
                items: [
                  DropdownMenuItem(
                      value: '', child: Text(textos.ganClaseSinIndicar)),
                  for (final clase in clasesMedicamento)
                    DropdownMenuItem(
                        value: clase.codigo,
                        child: Text(clase.etiqueta(idioma))),
                ],
                onChanged: (valor) => setState(() => _clase = valor ?? ''),
              ),
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
