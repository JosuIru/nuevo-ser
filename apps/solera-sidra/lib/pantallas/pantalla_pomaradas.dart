import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

import '../datos/base_datos.dart';
import '../dominio/catalogos.dart';
import '../estado/cambios_datos.dart';
import '../modelos/pomarada.dart';
import '../modelos/sagardotegi.dart';
import '../modelos/tratamiento.dart';
import '../utiles/textos_sidra.dart';
import 'hoja_formulario.dart';
import 'pantalla_tratamiento.dart';

/// Pomaradas (y viñas de txakoli) con sus datos de registro.
class PantallaPomaradas extends StatefulWidget {
  const PantallaPomaradas({super.key});

  @override
  State<PantallaPomaradas> createState() => _PantallaPomaradasState();
}

class _PantallaPomaradasState extends State<PantallaPomaradas> {
  late Future<List<Pomarada>> _pomaradas;

  @override
  void initState() {
    super.initState();
    _pomaradas = BaseDatosSoleraSidra.instancia.listarPomaradas();
    cambiosDatos.addListener(_recargar);
  }

  @override
  void dispose() {
    cambiosDatos.removeListener(_recargar);
    super.dispose();
  }

  void _recargar() {
    setState(() {
      _pomaradas = BaseDatosSoleraSidra.instancia.listarPomaradas();
    });
  }

  Future<void> _abrir(Widget pantalla) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('sidr.pomaradas'))),
      floatingActionButton: FloatingActionButton(
        tooltip: SoleraL10n.t('sidr.nueva_pomarada'),
        onPressed: () => _abrir(const PantallaEditarPomarada()),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Pomarada>>(
        future: _pomaradas,
        builder: (context, instantanea) {
          final pomaradas = instantanea.data;
          if (pomaradas == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (pomaradas.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(SoleraL10n.t('sidr.sin_pomaradas'),
                    textAlign: TextAlign.center),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              for (final pomarada in pomaradas)
                ListTile(
                  leading: Icon(pomarada.cultivo == 'vid'
                      ? Icons.wine_bar_outlined
                      : Icons.park_outlined),
                  title: Text(pomarada.nombre),
                  subtitle: Text([
                    if (pomarada.superficieHa > 0)
                      '${formatearNumero(pomarada.superficieHa, decimales: 2)} ha',
                    if (pomarada.numeroArboles > 0)
                      SoleraL10n.tf(
                          'sidr.n_arboles', {'n': pomarada.numeroArboles}),
                    if (pomarada.referenciaSigpac.isNotEmpty)
                      pomarada.referenciaSigpac,
                  ].join(' · ')),
                  trailing: pomarada.registradaDop
                      ? Chip(label: Text(SoleraL10n.t('sidr.dop')))
                      : null,
                  onTap: () =>
                      _abrir(PantallaFichaPomarada(pomarada: pomarada)),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Alta o edición de una pomarada.
class PantallaEditarPomarada extends StatefulWidget {
  const PantallaEditarPomarada({super.key, this.pomarada});

  final Pomarada? pomarada;

  @override
  State<PantallaEditarPomarada> createState() => _PantallaEditarPomaradaState();
}

class _PantallaEditarPomaradaState extends State<PantallaEditarPomarada> {
  late final Pomarada? _original = widget.pomarada;
  late final _nombre = TextEditingController(text: _original?.nombre);
  late final _municipio = TextEditingController(text: _original?.municipio);
  late final _poligono = TextEditingController(text: _original?.poligono);
  late final _parcela = TextEditingController(text: _original?.parcela);
  late final _recinto = TextEditingController(text: _original?.recinto);
  late final _superficie = TextEditingController(
      text: (_original?.superficieHa ?? 0) > 0
          ? formatearNumero(_original!.superficieHa, decimales: 2)
          : '');
  late final _arboles = TextEditingController(
      text: (_original?.numeroArboles ?? 0) > 0
          ? '${_original!.numeroArboles}'
          : '');
  late final _anio =
      TextEditingController(text: _original?.anioPlantacion?.toString());
  late final _notas = TextEditingController(text: _original?.notas);
  late String _cultivo = _original?.cultivo ?? 'manzano';
  late Set<String> _variedades = {...?_original?.variedades};
  late bool _registradaDop = _original?.registradaDop ?? false;
  double? _latitud;
  double? _longitud;
  Sagardotegi _sagardotegi = Sagardotegi();

  @override
  void initState() {
    super.initState();
    _latitud = _original?.latitud;
    _longitud = _original?.longitud;
    BaseDatosSoleraSidra.instancia.obtenerSagardotegi().then((sagardotegi) {
      if (mounted) setState(() => _sagardotegi = sagardotegi);
    });
  }

  @override
  void dispose() {
    for (final controlador in [
      _nombre,
      _municipio,
      _poligono,
      _parcela,
      _recinto,
      _superficie,
      _arboles,
      _anio,
      _notas,
    ]) {
      controlador.dispose();
    }
    super.dispose();
  }

  Future<void> _elegirVariedades() async {
    final elegidas = await elegirVarios(
      context,
      titulo: SoleraL10n.t('sidr.variedades'),
      opciones: variedadesParaCultivo(_cultivo, dop: _sagardotegi.dopId),
      elegidos: _variedades,
    );
    if (elegidas != null) setState(() => _variedades = elegidas);
  }

  Future<void> _guardar() async {
    final nombre = _nombre.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(SoleraL10n.t('sidr.falta_nombre'))));
      return;
    }
    await BaseDatosSoleraSidra.instancia.guardarPomarada(Pomarada(
      id: _original?.id,
      nombre: nombre,
      cultivo: _cultivo,
      municipio: _municipio.text.trim(),
      poligono: _poligono.text.trim(),
      parcela: _parcela.text.trim(),
      recinto: _recinto.text.trim(),
      superficieHa: leerNumero(_superficie.text) ?? 0,
      numeroArboles: leerEntero(_arboles.text) ?? 0,
      anioPlantacion: leerEntero(_anio.text),
      variedades: _variedades,
      registradaDop: _registradaDop,
      latitud: _latitud,
      longitud: _longitud,
      notas: _notas.text.trim(),
    ));
    avisarCambioDatos();
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final fueraDelPliego =
        variedadesFueraDelPliego(_variedades, _sagardotegi.dopId);
    return Scaffold(
      appBar: AppBar(
          title: Text(SoleraL10n.t(_original == null
              ? 'sidr.nueva_pomarada'
              : 'sidr.editar_pomarada'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          campoTexto(_nombre, SoleraL10n.t('sidr.nombre')),
          campoDesplegable<String>(
            etiqueta: SoleraL10n.t('sidr.cultivo'),
            valor: _cultivo,
            opciones: [
              for (final cultivo in cultivosParcela)
                (cultivo, nombreValor('cultivo', cultivo)),
            ],
            alCambiar: (valor) => setState(() => _cultivo = valor ?? _cultivo),
          ),
          campoTexto(_municipio, SoleraL10n.t('sidr.municipio')),
          Row(children: [
            Expanded(
                child: campoTexto(_poligono, SoleraL10n.t('sidr.poligono'))),
            const SizedBox(width: 8),
            Expanded(child: campoTexto(_parcela, SoleraL10n.t('sidr.parcela'))),
            const SizedBox(width: 8),
            Expanded(child: campoTexto(_recinto, SoleraL10n.t('sidr.recinto'))),
          ]),
          campoNumero(_superficie, SoleraL10n.t('sidr.superficie'),
              sufijo: 'ha'),
          campoNumero(_arboles, SoleraL10n.t('sidr.numero_arboles'),
              decimales: false),
          campoNumero(_anio, SoleraL10n.t('sidr.anio_plantacion'),
              decimales: false),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.eco_outlined),
            title: Text(SoleraL10n.t('sidr.variedades')),
            subtitle: Text(_variedades.isEmpty
                ? '—'
                : _variedades.map(nombreVariedad).join(', ')),
            trailing: const Icon(Icons.edit_outlined),
            onTap: _elegirVariedades,
          ),
          if (fueraDelPliego.isNotEmpty)
            TarjetaAviso(SoleraL10n.tf('sidr.variedades_fuera_pliego',
                {'variedades': fueraDelPliego.map(nombreVariedad).join(', ')})),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _registradaDop,
            title: Text(SoleraL10n.t('sidr.registrada_dop')),
            subtitle: Text(SoleraL10n.t('sidr.registrada_dop_ayuda')),
            onChanged: (valor) => setState(() => _registradaDop = valor),
          ),
          campoTexto(_notas, SoleraL10n.t('sidr.notas')),
          const SizedBox(height: 16),
          FilledButton(
              onPressed: _guardar, child: Text(SoleraL10n.t('guardar'))),
        ],
      ),
    );
  }
}

/// Ficha de la pomarada: datos, tratamientos y manzanos marcados.
class PantallaFichaPomarada extends StatefulWidget {
  const PantallaFichaPomarada({super.key, required this.pomarada});

  final Pomarada pomarada;

  @override
  State<PantallaFichaPomarada> createState() => _PantallaFichaPomaradaState();
}

class _PantallaFichaPomaradaState extends State<PantallaFichaPomarada> {
  late Pomarada _pomarada = widget.pomarada;
  late Future<(List<Tratamiento>, List<Manzano>)> _datos = _cargar();

  Future<(List<Tratamiento>, List<Manzano>)> _cargar() async {
    final baseDatos = BaseDatosSoleraSidra.instancia;
    final pomaradas = await baseDatos.listarPomaradas();
    _pomarada = pomaradas.firstWhere((pomarada) => pomarada.id == _pomarada.id,
        orElse: () => _pomarada);
    return (
      await baseDatos.listarTratamientos(pomaradaId: _pomarada.id),
      await baseDatos.listarManzanos(_pomarada.id!),
    );
  }

  void _recargar() {
    setState(() {
      _datos = _cargar();
    });
  }

  Future<void> _abrir(Widget pantalla) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => pantalla));
    _recargar();
  }

  Future<void> _nuevoManzano() async {
    final etiqueta = TextEditingController();
    final anio = TextEditingController();
    String? variedad;
    final guardado = await mostrarHojaFormulario(
      controladores: [etiqueta, anio],
      context,
      titulo: SoleraL10n.t('sidr.nuevo_manzano'),
      construir: (refrescar) => [
        campoTexto(etiqueta, SoleraL10n.t('sidr.etiqueta_manzano'),
            ayuda: SoleraL10n.t('sidr.etiqueta_manzano_ayuda')),
        campoDesplegable<String>(
          etiqueta: SoleraL10n.t('sidr.variedad'),
          valor: variedad,
          opciones: [
            for (final opcion in variedadesParaCultivo(_pomarada.cultivo))
              (opcion.id, opcion.nombre),
          ],
          alCambiar: (valor) => refrescar(() => variedad = valor),
        ),
        campoNumero(anio, SoleraL10n.t('sidr.anio_plantacion'),
            decimales: false),
      ],
      guardar: () async {
        if (etiqueta.text.trim().isEmpty) return false;
        await BaseDatosSoleraSidra.instancia.guardarManzano(Manzano(
          pomaradaId: _pomarada.id!,
          etiqueta: etiqueta.text.trim(),
          variedadId: variedad ?? '',
          anioPlantacion: leerEntero(anio.text),
        ));
        return true;
      },
    );
    if (guardado) _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pomarada.nombre),
        actions: [
          IconButton(
            tooltip: SoleraL10n.t('editar'),
            icon: const Icon(Icons.edit_outlined),
            onPressed: () =>
                _abrir(PantallaEditarPomarada(pomarada: _pomarada)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _abrir(PantallaEditarTratamiento(pomaradaId: _pomarada.id!)),
        icon: const Icon(Icons.sanitizer_outlined),
        label: Text(SoleraL10n.t('sidr.nuevo_tratamiento')),
      ),
      body: FutureBuilder<(List<Tratamiento>, List<Manzano>)>(
        future: _datos,
        builder: (context, instantanea) {
          final datos = instantanea.data;
          if (datos == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final (tratamientos, manzanos) = datos;
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              ListTile(
                title: Text(nombreValor('cultivo', _pomarada.cultivo)),
                subtitle: Text([
                  if (_pomarada.municipio.isNotEmpty) _pomarada.municipio,
                  if (_pomarada.referenciaSigpac.isNotEmpty)
                    '${SoleraL10n.t('sidr.sigpac')} ${_pomarada.referenciaSigpac}',
                  if (_pomarada.superficieHa > 0)
                    '${formatearNumero(_pomarada.superficieHa, decimales: 2)} ha',
                  if (_pomarada.densidadArbolesHa != null)
                    SoleraL10n.tf('sidr.arboles_por_ha', {
                      'n': formatearNumero(_pomarada.densidadArbolesHa!,
                          decimales: 0)
                    }),
                ].join(' · ')),
              ),
              if (_pomarada.variedades.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.eco_outlined),
                  title:
                      Text(_pomarada.variedades.map(nombreVariedad).join(', ')),
                ),
              ListTile(
                title: Text(SoleraL10n.t('sidr.tratamientos'),
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              if (tratamientos.isEmpty)
                ListTile(title: Text(SoleraL10n.t('sidr.sin_tratamientos'))),
              for (final tratamiento in tratamientos)
                ListTile(
                  leading: Icon(tratamiento.estaIncompleto
                      ? Icons.warning_amber_outlined
                      : Icons.sanitizer_outlined),
                  title: Text(tratamiento.sustanciaActivaId.isEmpty
                      ? SoleraL10n.t('sidr.sin_sustancia')
                      : nombreSustancia(tratamiento.sustanciaActivaId)),
                  subtitle: Text([
                    formatearFecha(tratamiento.fechaMs),
                    if (tratamiento.plagaObjetivoId.isNotEmpty)
                      nombrePlaga(tratamiento.plagaObjetivoId),
                    if (tratamiento.estaIncompleto)
                      SoleraL10n.t('sidr.tratamiento_incompleto'),
                  ].join(' · ')),
                  onTap: () => _abrir(PantallaEditarTratamiento(
                      pomaradaId: _pomarada.id!, tratamiento: tratamiento)),
                ),
              ListTile(
                title: Text(SoleraL10n.t('sidr.manzanos_marcados'),
                    style: Theme.of(context).textTheme.titleMedium),
                trailing: IconButton(
                  tooltip: SoleraL10n.t('sidr.nuevo_manzano'),
                  icon: const Icon(Icons.add),
                  onPressed: _nuevoManzano,
                ),
              ),
              for (final manzano in manzanos)
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.park_outlined),
                  title: Text(manzano.etiqueta),
                  subtitle: Text([
                    if (manzano.variedadId.isNotEmpty)
                      nombreVariedad(manzano.variedadId),
                    if (manzano.anioPlantacion != null)
                      '${manzano.anioPlantacion}',
                  ].join(' · ')),
                ),
            ],
          );
        },
      ),
    );
  }
}
