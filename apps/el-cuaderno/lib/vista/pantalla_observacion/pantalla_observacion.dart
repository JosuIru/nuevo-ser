import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../datos/almacenador_medios.dart';
import '../../datos/selector_imagen.dart';
import '../../dominio/geolocalizacion_privacy_first.dart';
import '../../dominio/misterio.dart';
import '../../dominio/nivel_confianza.dart';
import '../../dominio/observacion.dart';
import '../../dominio/repositorio_local.dart';
import '../../dominio/sit_spot.dart';
import '../../dominio/sugeridor_misterio.dart';
import '../../nucleo/i18n/generado/textos_app.dart';
import '../tema/colores.dart';
import '../tema/tipografia.dart';
import 'chip_sugerencia_misterio.dart';
import 'lienzo_dibujo.dart';
import 'pantalla_mapa_sonidos.dart';
import 'selector_confianza.dart';
import 'selector_misterio.dart';

/// Pantalla de Nueva Observación. Coherente con el mockup de la
/// biblia §5.2 y el detalle operativo del doc 13 §3.2.
class PantallaObservacion extends StatefulWidget {
  const PantallaObservacion({
    super.key,
    required this.repositorio,
    required this.misteriosAbiertos,
    required this.sitSpotActivo,
    this.misterioPreseleccionadoId,
    this.preguntaDelNinoPreseleccionadaId,
    this.alGuardarObservacion,
    this.selectorImagen,
    this.almacenadorMedios,
    this.servicioGeolocalizacion,
    this.constructorMiniatura,
    this.abrirLienzoDibujoOverride,
    this.confirmarPrePermisoGeoOverride,
    DateTime Function()? proveedorAhora,
    String Function()? proveedorIds,
  })  : _proveedorAhora = proveedorAhora ?? DateTime.now,
        _proveedorIds = proveedorIds ?? _generarUuid;

  final RepositorioLocal repositorio;
  final List<Misterio> misteriosAbiertos;
  final SitSpot? sitSpotActivo;
  final String? misterioPreseleccionadoId;

  /// Si el niño abre la observación desde la página de una pregunta
  /// suya, el id se preselecciona aquí — paralelo a
  /// [misterioPreseleccionadoId] pero apuntando a la pregunta del
  /// niño en lugar del catálogo del adulto. Tras guardar, la pantalla
  /// llama a `repositorio.anclarObservacionAPregunta` para mantener
  /// sincronizado [PreguntaDelNino.observacionesIds].
  final String? preguntaDelNinoPreseleccionadaId;

  /// Invocado tras persistir la observación en el repositorio. El
  /// orquestador lo cablea a la cola de sync para que la observación
  /// recién creada quede como pendiente de subir al backend (cuando
  /// haya token y el adulto pulse "Sincronizar"). Si es null, la
  /// observación se guarda sólo en local (modo S1, tests, demo).
  final Future<void> Function(Observacion observacion)? alGuardarObservacion;

  /// Picker de cámara/galería para anclar una foto a la observación.
  /// Si es null, los botones de foto no aparecen (modo S1, tests que
  /// no quieren simular el flujo de imagen).
  final SelectorImagen? selectorImagen;

  /// Almacenador que mueve la foto seleccionada al directorio privado
  /// de la app. Requerido si [selectorImagen] no es null.
  final AlmacenadorMedios? almacenadorMedios;

  /// Servicio de geolocalización para anclar coordenadas a la página
  /// (B5). Si llega no nulo, la UI muestra el botón opt-in "anclar mi
  /// posición a esta página"; las coords NUNCA cruzan red — se
  /// persisten sólo en `Observacion.dondeCoordenadas` (Isar local). Si
  /// es null (tests sin geo, modo S1), el botón no aparece.
  final ServicioGeolocalizacion? servicioGeolocalizacion;

  /// Constructor de la miniatura. Por defecto `Image.file`. Tests
  /// pueden inyectar un `Container()` para evitar el decode async
  /// que cuelga el flutter tester con `Future.then` pendientes.
  final Widget Function(File fichero)? constructorMiniatura;

  /// Para tests: closure que reemplaza la apertura real del lienzo
  /// (`PantallaLienzoDibujo` vía `Navigator.push`). Devuelve los bytes
  /// PNG simulados o null si el "niño" canceló. Producción siempre
  /// pasa null y se usa el flujo real.
  final Future<Uint8List?> Function(BuildContext)? abrirLienzoDibujoOverride;

  /// Para tests: closure que reemplaza el AlertDialog de pre-permiso
  /// de geolocalización. Devuelve `true` si el "niño" pulsa "anclar"
  /// y `false` si cancela. Producción siempre pasa null y se muestra
  /// el diálogo real.
  final Future<bool> Function(BuildContext)? confirmarPrePermisoGeoOverride;

  final DateTime Function() _proveedorAhora;
  final String Function() _proveedorIds;

  static String _generarUuid() => const Uuid().v4();

  @override
  State<PantallaObservacion> createState() => _EstadoPantallaObservacion();
}

class _EstadoPantallaObservacion extends State<PantallaObservacion> {
  late final TextEditingController _controladorQueViste;
  late final TextEditingController _controladorCreesQueEs;
  late NivelConfianza _confianza;
  String? _misterioId;

  /// Ruta absoluta de la foto seleccionada por el niño (cámara o
  /// galería). Solo es válida durante la sesión de la pantalla; al
  /// pulsar "Guardar" se mueve al directorio de medios y la ruta
  /// **relativa** se persiste en `Observacion.fotoRutaLocal`.
  String? _rutaFotoTemporal;
  bool _seleccionandoFoto = false;

  /// Ruta absoluta del PNG renderizado por el lienzo de dibujo. Misma
  /// política que la foto: relativa al persistirla.
  String? _rutaDibujoTemporal;

  /// Id estable de esta observación. Se genera al montar la pantalla
  /// para que el almacenador de medios pueda nombrar el fichero con
  /// él incluso cuando todavía no se ha llamado a `_guardar`. Si el
  /// niño se vuelve atrás, la foto temporal queda huérfana en el
  /// directorio de medios — A5 (export v2) ya hace una verificación
  /// de "fichero apuntado existe".
  late final String _idObservacion;

  /// Coordenadas ancladas a esta observación (opt-in, nunca cruzan
  /// red — se persisten sólo en `Observacion.dondeCoordenadas`). Null
  /// hasta que el niño explícitamente las pida con el botón "anclar
  /// mi posición a esta página". Quitarlas vuelve a null.
  Coordenadas? _coordenadasAncladas;
  bool _solicitandoUbicacion = false;
  String? _avisoUbicacion;

  /// Ids de Misterios cuya sugerencia el niño ya rechazó en esta
  /// sesión. El sugeridor no los vuelve a proponer hasta que se
  /// monte la pantalla otra vez — sin "esto suena al Misterio X"
  /// repetido por el mismo borrado/escrito que ya rechazó.
  final Set<String> _sugerenciasRechazadas = <String>{};

  /// Calcula el Misterio sugerido en función del texto actual de
  /// `queVio`. Devuelve null si:
  /// - el niño ya seleccionó manualmente un Misterio;
  /// - no hay candidatos abiertos;
  /// - la heurística no encuentra match en lo que ha escrito;
  /// - el único candidato que matchea ya ha sido rechazado en esta
  ///   sesión.
  Misterio? get _sugerido {
    if (_misterioId != null) return null;
    if (widget.misteriosAbiertos.isEmpty) return null;
    final candidatos = widget.misteriosAbiertos
        .where((m) => !_sugerenciasRechazadas.contains(m.id))
        .toList(growable: false);
    if (candidatos.isEmpty) return null;
    return sugerirMisterio(
      queVio: _controladorQueViste.text,
      candidatos: candidatos,
    );
  }

  @override
  void initState() {
    super.initState();
    _controladorQueViste = TextEditingController();
    _controladorCreesQueEs = TextEditingController();
    _confianza = NivelConfianza.hipotesisActiva;
    _misterioId = widget.misterioPreseleccionadoId;
    _idObservacion = widget._proveedorIds();

    // Reconstruye el botón Guardar al cambiar la longitud del campo
    // obligatorio.
    _controladorQueViste.addListener(() => setState(() {}));
    _controladorCreesQueEs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controladorQueViste.dispose();
    _controladorCreesQueEs.dispose();
    super.dispose();
  }

  bool get _puedeGuardar => _controladorQueViste.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final textos = TextosApp.of(context);
    final esquema = Theme.of(context).colorScheme;
    final ahora = widget._proveedorAhora();

    return Scaffold(
      appBar: AppBar(title: Text(textos.observacionTitulo)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  _Cabecera(
                    cabecera: textos.observacionCabecera(_formatearHora(ahora)),
                    sitSpot: widget.sitSpotActivo,
                  ),
                  const SizedBox(height: 16),
                  _CajaFotoDibujo(
                    textos: textos,
                    selectorImagen: widget.selectorImagen,
                    rutaFoto: _rutaFotoTemporal,
                    rutaDibujo: _rutaDibujoTemporal,
                    cargando: _seleccionandoFoto,
                    alTomarFoto: widget.selectorImagen == null
                        ? null
                        : () => _capturarFoto(_OrigenFoto.camara),
                    alElegirFoto: widget.selectorImagen == null
                        ? null
                        : () => _capturarFoto(_OrigenFoto.galeria),
                    alQuitarFoto: _rutaFotoTemporal == null
                        ? null
                        : _quitarFoto,
                    alHacerDibujo: widget.almacenadorMedios == null
                        ? null
                        : _capturarDibujo,
                    alHacerMapaSonidos: widget.almacenadorMedios == null
                        ? null
                        : _capturarMapaSonidos,
                    alQuitarDibujo: _rutaDibujoTemporal == null
                        ? null
                        : _quitarDibujo,
                    constructorMiniatura: widget.constructorMiniatura,
                  ),
                  const SizedBox(height: 24),
                  _Etiqueta(textos.observacionEtiquetaQueViste),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _controladorQueViste,
                    minLines: 4,
                    maxLines: 8,
                    maxLength: 2000,
                    style: TipografiaCuaderno.serif(
                      color: esquema.onSurface,
                      tamano: TipografiaCuaderno.tamano14,
                      altoLinea: 1.5,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: textos.observacionPlaceholderQueViste,
                      hintStyle: TipografiaCuaderno.serif(
                        color: PaletaCuaderno.tintaTenue,
                        tamano: TipografiaCuaderno.tamano14,
                      ).copyWith(fontStyle: FontStyle.italic),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: esquema.outline),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Etiqueta(textos.observacionEtiquetaCreesQueEs),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _controladorCreesQueEs,
                    style: TipografiaCuaderno.serif(
                      color: esquema.onSurface,
                      tamano: TipografiaCuaderno.tamano14,
                    ),
                    decoration: InputDecoration(
                      hintText: textos.observacionPlaceholderCreesQueEs,
                      hintStyle: TipografiaCuaderno.serif(
                        color: PaletaCuaderno.tintaTenue,
                        tamano: TipografiaCuaderno.tamano14,
                      ).copyWith(fontStyle: FontStyle.italic),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: esquema.outline),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Los chips solo aparecen cuando el niño ha escrito algo
                  // en `crees que es` — coherente con doc 13 §3.2.4.
                  if (_controladorCreesQueEs.text.trim().isNotEmpty)
                    SelectorConfianza(
                      confianza: _confianza,
                      alCambiar: (nuevoNivel) =>
                          setState(() => _confianza = nuevoNivel),
                    ),
                  if (widget.servicioGeolocalizacion != null) ...[
                    const SizedBox(height: 24),
                    _BloqueAnclarPosicion(
                      coordenadasAncladas: _coordenadasAncladas,
                      solicitando: _solicitandoUbicacion,
                      aviso: _avisoUbicacion,
                      alAnclar: _anclarPosicion,
                      alQuitar: _quitarPosicion,
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (widget.misteriosAbiertos.isNotEmpty) ...[
                    const _Etiqueta('va con un Misterio'),
                    const SizedBox(height: 4),
                    if (_sugerido != null) ...[
                      ChipSugerenciaMisterio(
                        misterioSugerido: _sugerido!,
                        alAnclar: () => setState(
                          () => _misterioId = _sugerido!.id,
                        ),
                        alRechazar: () => setState(
                          () => _sugerenciasRechazadas.add(_sugerido!.id),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    SelectorMisterio(
                      misteriosAbiertos: widget.misteriosAbiertos,
                      misterioSeleccionadoId: _misterioId,
                      alCambiar: (id) => setState(() => _misterioId = id),
                    ),
                  ],
                ],
              ),
            ),
            _BotonGuardar(
              habilitado: _puedeGuardar,
              alPulsar: _guardar,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _capturarFoto(_OrigenFoto origen) async {
    final selector = widget.selectorImagen;
    final almacenador = widget.almacenadorMedios;
    if (selector == null || almacenador == null) return;

    setState(() => _seleccionandoFoto = true);
    try {
      final rutaOrigen = origen == _OrigenFoto.camara
          ? await selector.desdeCamara()
          : await selector.desdeGaleria();
      if (rutaOrigen == null) return;

      // Copiamos al directorio privado de la app aunque el niño
      // todavía no haya pulsado "Guardar". Si se vuelve atrás, la
      // foto queda huérfana — A5 (export v2) y la limpieza programada
      // se encargan de los huérfanos. La ventaja de copiar ya: la
      // miniatura sale del fichero estable, no del path del picker
      // que puede caducar.
      final rutaRelativa = await almacenador.guardar(
        rutaOrigen: rutaOrigen,
        observacionId: _idObservacion,
        tipo: TipoMedio.foto,
      );
      final rutaAbsoluta = await almacenador.resolverAbsoluta(rutaRelativa);
      if (!mounted) return;
      setState(() => _rutaFotoTemporal = rutaAbsoluta);
    } finally {
      if (mounted) {
        setState(() => _seleccionandoFoto = false);
      }
    }
  }

  Future<void> _capturarDibujo() async {
    final bytes = await (widget.abrirLienzoDibujoOverride?.call(context) ??
        Navigator.of(context).push<Uint8List?>(
          MaterialPageRoute(
            builder: (_) => const PantallaLienzoDibujo(),
          ),
        ));
    await _guardarComoDibujo(bytes);
  }

  /// El mapa de sonidos se guarda en el hueco del dibujo: es un dibujo
  /// con guía, no un medio nuevo (sin esquema nuevo, misma privacidad).
  Future<void> _capturarMapaSonidos() async {
    final bytes = await Navigator.of(context).push<Uint8List?>(
      MaterialPageRoute(builder: (_) => const PantallaMapaSonidos()),
    );
    await _guardarComoDibujo(bytes);
  }

  Future<void> _guardarComoDibujo(Uint8List? bytes) async {
    final almacenador = widget.almacenadorMedios;
    if (almacenador == null || bytes == null || !mounted) return;

    final rutaRelativa = await almacenador.guardarBytes(
      bytes: bytes,
      observacionId: _idObservacion,
      tipo: TipoMedio.dibujo,
    );
    final rutaAbsoluta = await almacenador.resolverAbsoluta(rutaRelativa);
    if (!mounted) return;
    setState(() => _rutaDibujoTemporal = rutaAbsoluta);
  }

  Future<void> _quitarDibujo() async {
    final almacenador = widget.almacenadorMedios;
    if (almacenador == null || _rutaDibujoTemporal == null) return;
    setState(() => _rutaDibujoTemporal = null);
    final rutaRelativa = '${AlmacenadorMedios.subdirectorioMedios}/'
        '${_idObservacion}_${TipoMedio.dibujo.sufijo}'
        '${TipoMedio.dibujo.extensionPredeterminada}';
    await almacenador.borrar(rutaRelativa);
  }

  Future<void> _quitarFoto() async {
    final almacenador = widget.almacenadorMedios;
    final rutaActual = _rutaFotoTemporal;
    if (almacenador == null || rutaActual == null) return;
    setState(() => _rutaFotoTemporal = null);
    // Borramos el fichero copiado del directorio privado. Si el niño
    // vuelve a tomar una foto, se generará otra con el mismo nombre.
    final rutaRelativa = '${AlmacenadorMedios.subdirectorioMedios}/'
        '${_idObservacion}_${TipoMedio.foto.sufijo}'
        '${_extraerExtensionDe(rutaActual)}';
    await almacenador.borrar(rutaRelativa);
  }

  /// Convierte una ruta absoluta (devuelta por
  /// `AlmacenadorMedios.resolverAbsoluta`) en la ruta relativa que se
  /// persiste en `Observacion.fotoRutaLocal` /
  /// `Observacion.dibujoRutaLocal`. Si el almacenador es null o la
  /// ruta absoluta no encaja con su directorio raíz, devuelve null —
  /// equivalente a "no hay foto/dibujo".
  Future<String?> _aRelativa(
    String? rutaAbsoluta,
    AlmacenadorMedios? almacenador,
  ) async {
    if (rutaAbsoluta == null || almacenador == null) return null;
    final dirRaiz = await almacenador.resolverAbsoluta('');
    final prefijo = dirRaiz.endsWith('/') ? dirRaiz : '$dirRaiz/';
    if (rutaAbsoluta.startsWith(prefijo)) {
      return rutaAbsoluta.substring(prefijo.length);
    }
    return null;
  }

  Future<void> _anclarPosicion() async {
    final servicio = widget.servicioGeolocalizacion;
    if (servicio == null) return;

    // Pre-permiso con la voz adulta amable (biblia §2.5 + doc 04 §1.2)
    // antes del diálogo del sistema. VOZ-ADULTA-PROVISIONAL —
    // pendiente de asesoría psicológica B8 (memoria
    // `project_el_cuaderno_decisiones_humanas_pendientes`). Texto
    // estable a propósito para que la asesoría tenga superficie
    // concreta sobre la que opinar.
    final override = widget.confirmarPrePermisoGeoOverride;
    final continua = override != null
        // El override sólo se usa en tests; el context se pasa al
        // callback antes de cualquier await dentro del propio override.
        // ignore: use_build_context_synchronously
        ? await override(context)
        : await _mostrarPrePermisoUbicacion();
    if (continua != true) return;
    if (!mounted) return;

    setState(() {
      _solicitandoUbicacion = true;
      _avisoUbicacion = null;
    });
    try {
      var permiso = await servicio.permiso();
      if (permiso == PermisoGeo.noSolicitado || permiso == PermisoGeo.denegado) {
        permiso = await servicio.pedirPermiso();
      }
      if (!mounted) return;
      if (permiso != PermisoGeo.concedido) {
        setState(() {
          _solicitandoUbicacion = false;
          _avisoUbicacion = permiso == PermisoGeo.denegadoPermanente
              ? 'No se ha podido pedir permiso. Si quieres anclar la posición, '
                  'cámbialo en los ajustes del teléfono.'
              : 'Sin permiso de ubicación. Puedes seguir sin él.';
        });
        return;
      }
      final coords = await servicio.coordenadasActuales();
      if (!mounted) return;
      setState(() {
        _solicitandoUbicacion = false;
        if (coords == null) {
          _avisoUbicacion = 'No se ha podido localizar la posición. '
              'Puedes seguir sin ella.';
        } else {
          _coordenadasAncladas = coords;
          _avisoUbicacion = null;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _solicitandoUbicacion = false;
        _avisoUbicacion = 'No se ha podido localizar la posición. '
            'Puedes seguir sin ella.';
      });
    }
  }

  Future<bool> _mostrarPrePermisoUbicacion() async {
    final textos = TextosApp.of(context);
    final continuar = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: Text(textos.observacionPrePermisoTitulo),
        content: Text(textos.observacionPrePermisoMensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogo).pop(false),
            child: Text(textos.observacionPrePermisoCancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogo).pop(true),
            child: Text(textos.observacionPrePermisoAnclar),
          ),
        ],
      ),
    );
    return continuar ?? false;
  }

  void _quitarPosicion() {
    setState(() {
      _coordenadasAncladas = null;
      _avisoUbicacion = null;
    });
  }

  String _extraerExtensionDe(String ruta) {
    final ultimoPunto = ruta.lastIndexOf('.');
    final ultimaBarra = ruta.lastIndexOf('/');
    if (ultimoPunto > ultimaBarra && ultimoPunto < ruta.length - 1) {
      return ruta.substring(ultimoPunto).toLowerCase();
    }
    return TipoMedio.foto.extensionPredeterminada;
  }

  Future<void> _guardar() async {
    final queViste = _controladorQueViste.text.trim();
    final creesQueEs = _controladorCreesQueEs.text.trim();
    final ahora = widget._proveedorAhora();
    final almacenador = widget.almacenadorMedios;

    // Las rutas persistidas son **relativas** al directorio de
    // documentos — sobreviven a cambios del sandbox UUID en Android y
    // a un export/import del cuaderno (A5).
    final rutaFotoRelativa = await _aRelativa(_rutaFotoTemporal, almacenador);
    final rutaDibujoRelativa =
        await _aRelativa(_rutaDibujoTemporal, almacenador);

    final observacion = Observacion(
      id: _idObservacion,
      cuandoCreada: ahora,
      cuandoOcurrio: ahora,
      dondeNombre: widget.sitSpotActivo?.nombre ?? '',
      sitSpotId: widget.sitSpotActivo?.id,
      dondeCoordenadas: _coordenadasAncladas,
      queVio: queViste,
      creesQueEs: creesQueEs.isEmpty ? null : creesQueEs,
      // Si el niño no escribió identificación, el nivel registrado
      // baja a hipótesis activa por defecto — incluso si el chip
      // mostrado decía otra cosa antes de borrar el texto.
      confianza: creesQueEs.isEmpty
          ? NivelConfianza.hipotesisActiva
          : _confianza,
      misterioId: _misterioId,
      preguntaDelNinoId: widget.preguntaDelNinoPreseleccionadaId,
      fotoRutaLocal: rutaFotoRelativa,
      dibujoRutaLocal: rutaDibujoRelativa,
    );

    await widget.repositorio.guardarObservacion(observacion);
    if (_misterioId != null) {
      await widget.repositorio.anclarObservacionAMisterio(
        observacion.id,
        _misterioId!,
      );
    }
    if (widget.preguntaDelNinoPreseleccionadaId != null) {
      await widget.repositorio.anclarObservacionAPregunta(
        observacion.id,
        widget.preguntaDelNinoPreseleccionadaId!,
      );
    }
    // Si la observación va contra el sit spot activo, registramos la
    // visita: doc 13 §2.1 muestra "hace 4 días" como pista del ritmo
    // de regreso. Sin esto, el campo se quedaba con el valor del seed
    // y la tarjeta del home decía siempre lo mismo.
    final sitSpotActivo = widget.sitSpotActivo;
    if (sitSpotActivo != null && sitSpotActivo.id == observacion.sitSpotId) {
      await widget.repositorio.establecerSitSpot(
        sitSpotActivo.copyWith(ultimaVisita: ahora),
      );
    }
    await widget.alGuardarObservacion?.call(observacion);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _formatearHora(DateTime cuando) {
    final hh = cuando.hour.toString().padLeft(2, '0');
    final mm = cuando.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.cabecera, required this.sitSpot});

  final String cabecera;
  final SitSpot? sitSpot;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textoLugar =
        sitSpot == null ? '' : ' · ${sitSpot!.nombre.toLowerCase()}';
    return Text(
      '$cabecera$textoLugar',
      style: TipografiaCuaderno.sans(
        color: esquema.tertiary,
        tamano: TipografiaCuaderno.tamano12,
      ),
    );
  }
}

/// Caja de foto/dibujo de la pantalla de Nueva Observación.
///
/// Estados visibles:
/// 1. **Sin selector ni almacenador cableado**: placeholder
///    informativo (modo S1, tests que no inyectan dependencias).
/// 2. **Cargando foto**: spinner mientras `_capturarFoto` se ejecuta.
/// 3. **Foto y/o dibujo presentes**: miniatura(s) con botón discreto
///    "quitar" sobre cada una.
/// 4. **Sin medios todavía**: dos filas de botones — la de fotografía
///    (cámara + galería) si hay `selectorImagen`, y la de dibujo
///    ("hacer dibujo") si hay `almacenadorMedios`.
class _CajaFotoDibujo extends StatelessWidget {
  const _CajaFotoDibujo({
    required this.textos,
    required this.selectorImagen,
    required this.rutaFoto,
    required this.rutaDibujo,
    required this.cargando,
    required this.alTomarFoto,
    required this.alElegirFoto,
    required this.alQuitarFoto,
    required this.alHacerDibujo,
    this.alHacerMapaSonidos,
    required this.alQuitarDibujo,
    required this.constructorMiniatura,
  });

  final TextosApp textos;
  final SelectorImagen? selectorImagen;
  final String? rutaFoto;
  final String? rutaDibujo;
  final bool cargando;
  final VoidCallback? alTomarFoto;
  final VoidCallback? alElegirFoto;
  final VoidCallback? alQuitarFoto;
  final VoidCallback? alHacerDibujo;
  final VoidCallback? alHacerMapaSonidos;
  final VoidCallback? alQuitarDibujo;
  final Widget Function(File fichero)? constructorMiniatura;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;

    if (selectorImagen == null && alHacerDibujo == null) {
      return _CajaInformativa(textos: textos);
    }
    if (cargando) {
      return Container(
        height: 110,
        decoration: BoxDecoration(
          color: esquema.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final tieneFoto = rutaFoto != null;
    final tieneDibujo = rutaDibujo != null;
    if (tieneFoto || tieneDibujo) {
      return Column(
        children: [
          if (tieneFoto)
            _CajaConFoto(
              rutaAbsoluta: rutaFoto!,
              alQuitarFoto: alQuitarFoto,
              textos: textos,
              constructorMiniatura: constructorMiniatura,
            ),
          if (tieneFoto && tieneDibujo) const SizedBox(height: 8),
          if (tieneDibujo)
            _CajaConDibujo(
              rutaAbsoluta: rutaDibujo!,
              alQuitarDibujo: alQuitarDibujo,
              textos: textos,
              constructorMiniatura: constructorMiniatura,
            ),
          if (selectorImagen != null && !tieneFoto) ...[
            const SizedBox(height: 8),
            _BotonesFoto(
              textos: textos,
              alTomarFoto: alTomarFoto,
              alElegirFoto: alElegirFoto,
            ),
          ],
          if (alHacerDibujo != null && !tieneDibujo) ...[
            const SizedBox(height: 8),
            _BotonDibujo(
              textos: textos,
              alHacerDibujo: alHacerDibujo,
              alHacerMapaSonidos: alHacerMapaSonidos,
            ),
          ],
        ],
      );
    }

    return _CajaBotones(
      textos: textos,
      alTomarFoto: alTomarFoto,
      alElegirFoto: alElegirFoto,
      alHacerDibujo: alHacerDibujo,
      alHacerMapaSonidos: alHacerMapaSonidos,
      mostrarFoto: selectorImagen != null,
    );
  }
}

class _CajaInformativa extends StatelessWidget {
  const _CajaInformativa({required this.textos});

  final TextosApp textos;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: esquema.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            textos.observacionCajaPlaceholder,
            textAlign: TextAlign.center,
            style: TipografiaCuaderno.sans(
              color: esquema.tertiary,
              tamano: TipografiaCuaderno.tamano12,
            ),
          ),
        ),
      ),
    );
  }
}

class _CajaBotones extends StatelessWidget {
  const _CajaBotones({
    required this.textos,
    required this.alTomarFoto,
    required this.alElegirFoto,
    required this.alHacerDibujo,
    this.alHacerMapaSonidos,
    required this.mostrarFoto,
  });

  final TextosApp textos;
  final VoidCallback? alTomarFoto;
  final VoidCallback? alElegirFoto;
  final VoidCallback? alHacerDibujo;
  final VoidCallback? alHacerMapaSonidos;
  final bool mostrarFoto;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: esquema.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          if (mostrarFoto) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: alTomarFoto,
                    icon: const Icon(Icons.photo_camera_outlined, size: 18),
                    label: Text(textos.observacionFotoTomar),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: alElegirFoto,
                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                    label: Text(textos.observacionFotoElegir),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (alHacerDibujo != null) ...[
            _BotonDibujo(
              textos: textos,
              alHacerDibujo: alHacerDibujo,
              alHacerMapaSonidos: alHacerMapaSonidos,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            textos.observacionCajaPlaceholder,
            textAlign: TextAlign.center,
            style: TipografiaCuaderno.sans(
              color: esquema.tertiary,
              tamano: TipografiaCuaderno.tamano12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonesFoto extends StatelessWidget {
  const _BotonesFoto({
    required this.textos,
    required this.alTomarFoto,
    required this.alElegirFoto,
  });

  final TextosApp textos;
  final VoidCallback? alTomarFoto;
  final VoidCallback? alElegirFoto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: alTomarFoto,
            icon: const Icon(Icons.photo_camera_outlined, size: 18),
            label: Text(textos.observacionFotoTomar),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: alElegirFoto,
            icon: const Icon(Icons.photo_library_outlined, size: 18),
            label: Text(textos.observacionFotoElegir),
          ),
        ),
      ],
    );
  }
}

/// Botón de dibujo y, al lado, el de mapa de sonidos (que se guarda
/// en el mismo hueco).
class _BotonDibujo extends StatelessWidget {
  const _BotonDibujo({
    required this.textos,
    required this.alHacerDibujo,
    this.alHacerMapaSonidos,
  });

  final TextosApp textos;
  final VoidCallback? alHacerDibujo;
  final VoidCallback? alHacerMapaSonidos;

  @override
  Widget build(BuildContext context) {
    final dibujo = OutlinedButton.icon(
      onPressed: alHacerDibujo,
      icon: const Icon(Icons.brush_outlined, size: 18),
      label: Text(textos.observacionDibujoComenzar),
    );
    if (alHacerMapaSonidos == null) {
      return SizedBox(width: double.infinity, child: dibujo);
    }
    return Row(
      children: [
        Expanded(child: dibujo),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: alHacerMapaSonidos,
            icon: const Icon(Icons.hearing_outlined, size: 18),
            label: Text(textos.observacionMapaSonidosComenzar),
          ),
        ),
      ],
    );
  }
}

class _CajaConDibujo extends StatelessWidget {
  const _CajaConDibujo({
    required this.rutaAbsoluta,
    required this.alQuitarDibujo,
    required this.textos,
    required this.constructorMiniatura,
  });

  final String rutaAbsoluta;
  final VoidCallback? alQuitarDibujo;
  final TextosApp textos;
  final Widget Function(File fichero)? constructorMiniatura;

  @override
  Widget build(BuildContext context) {
    final fichero = File(rutaAbsoluta);
    final miniatura = constructorMiniatura?.call(fichero) ??
        Image.file(
          fichero,
          height: 200,
          width: double.infinity,
          fit: BoxFit.contain,
        );
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: PaletaCuaderno.papelClaro,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: PaletaCuaderno.papelOscuro),
          ),
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: miniatura,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: textos.observacionDibujoQuitar,
              onPressed: alQuitarDibujo,
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class _CajaConFoto extends StatelessWidget {
  const _CajaConFoto({
    required this.rutaAbsoluta,
    required this.alQuitarFoto,
    required this.textos,
    required this.constructorMiniatura,
  });

  final String rutaAbsoluta;
  final VoidCallback? alQuitarFoto;
  final TextosApp textos;
  final Widget Function(File fichero)? constructorMiniatura;

  @override
  Widget build(BuildContext context) {
    final fichero = File(rutaAbsoluta);
    final miniatura = constructorMiniatura?.call(fichero) ??
        Image.file(
          fichero,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        );
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: miniatura,
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: textos.observacionFotoQuitar,
              onPressed: alQuitarFoto,
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    return Text(
      texto,
      style: TipografiaCuaderno.sans(
        color: esquema.tertiary,
        tamano: TipografiaCuaderno.tamano12,
        peso: TipografiaCuaderno.pesoMedio,
      ),
    );
  }
}

enum _OrigenFoto { camara, galeria }

class _BotonGuardar extends StatelessWidget {
  const _BotonGuardar({required this.habilitado, required this.alPulsar});

  final bool habilitado;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final textos = TextosApp.of(context);
    final esquema = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!habilitado)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                textos.observacionAvisoFalta,
                textAlign: TextAlign.center,
                style: TipografiaCuaderno.sans(
                  color: esquema.tertiary,
                  tamano: TipografiaCuaderno.tamano12,
                ),
              ),
            ),
          FilledButton(
            onPressed: habilitado ? alPulsar : null,
            style: FilledButton.styleFrom(
              backgroundColor: esquema.primary,
              foregroundColor: esquema.onPrimary,
              disabledBackgroundColor:
                  // Flutter 3.24: usar withOpacity (CLAUDE.md uno-roto).
                  // ignore: deprecated_member_use
                  esquema.surfaceContainerHighest.withOpacity(0.5),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: TipografiaCuaderno.sans(
                color: esquema.onPrimary,
                tamano: TipografiaCuaderno.tamano14,
                peso: TipografiaCuaderno.pesoMedio,
              ),
            ),
            child: Text(textos.observacionBotonGuardar),
          ),
        ],
      ),
    );
  }
}

/// Bloque opt-in "anclar mi posición a esta página" (B5 — fallback de
/// experto pendiente de asesoría psicológica B8 sobre el copy del
/// pre-permiso). Las coordenadas se persisten sólo en
/// `Observacion.dondeCoordenadas` (Isar local) y NUNCA cruzan red —
/// la frontera está en `cliente_el_cuaderno.dart`.
class _BloqueAnclarPosicion extends StatelessWidget {
  const _BloqueAnclarPosicion({
    required this.coordenadasAncladas,
    required this.solicitando,
    required this.aviso,
    required this.alAnclar,
    required this.alQuitar,
  });

  final Coordenadas? coordenadasAncladas;
  final bool solicitando;
  final String? aviso;
  final VoidCallback alAnclar;
  final VoidCallback alQuitar;

  @override
  Widget build(BuildContext context) {
    final esquema = Theme.of(context).colorScheme;
    final textos = TextosApp.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: esquema.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: esquema.outline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            coordenadasAncladas == null
                ? 'Posición no anclada'
                : 'Posición anclada a esta página',
            style: TipografiaCuaderno.sans(
              color: esquema.onSurface,
              tamano: TipografiaCuaderno.tamano13,
              peso: TipografiaCuaderno.pesoMedio,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'La posición se queda en este cuaderno y no sale a internet.',
            style: TipografiaCuaderno.serif(
              color: PaletaCuaderno.tintaTenue,
              tamano: TipografiaCuaderno.tamano12,
              altoLinea: 1.45,
            ),
          ),
          if (aviso != null) ...[
            const SizedBox(height: 8),
            Text(
              aviso!,
              style: TipografiaCuaderno.serif(
                color: PaletaCuaderno.sienaTenue,
                tamano: TipografiaCuaderno.tamano12,
                altoLinea: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              if (coordenadasAncladas == null)
                TextButton(
                  onPressed: solicitando ? null : alAnclar,
                  child: Text(solicitando ? 'localizando…' : 'anclar mi posición'),
                )
              else ...[
                TextButton(
                  onPressed: alQuitar,
                  child: Text(textos.observacionQuitarPosicion),
                ),
                const SizedBox(width: 8),
                Text(
                  '${coordenadasAncladas!.lat.toStringAsFixed(5)}, '
                  '${coordenadasAncladas!.lng.toStringAsFixed(5)}',
                  style: TipografiaCuaderno.sans(
                    color: PaletaCuaderno.tintaTenue,
                    tamano: TipografiaCuaderno.tamano12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
