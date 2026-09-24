// Pantalla principal del juego: la mesa del descifrador.
//
// Vista cenital con tres zonas:
//   - Bandeja de entrada (esquina superior izquierda): los documentos
//     del día apilados con leves rotaciones (4-6° entre piezas).
//   - Bandeja de resuelto (esquina superior derecha): documentos
//     archivados con decisión, más pequeños y ordenados.
//   - Banner del maestro (parte superior): saludo según estado.
//
// Cuando el niño toca una pieza, se navega a PantallaDocumento. Al
// volver, la pieza ya está en bandeja resuelto.
//
// Composición según `el-descifrador-11-guia-visual.md` §5.1. Versión
// inicial — la estética definitiva la cierra el ilustrador asignado
// (B8 BLOQUEOS-PENDIENTES.md).

import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/cargador_corpus.dart';
import '../datos/repositorio_anotaciones.dart';
import '../datos/repositorio_familiaridad.dart';
import '../datos/repositorio_identificaciones.dart';
import '../datos/repositorio_interpretaciones.dart';
import '../datos/repositorio_memoria_sesiones.dart';
import '../datos/repositorio_notas_libres.dart';
import '../datos/repositorio_pistas.dart';
import '../datos/repositorio_sellos.dart';
import '../datos/repositorio_sesion.dart';
import '../datos/repositorio_vocabulario.dart';
import '../dominio/identificaciones_lengua.dart';
import '../dominio/memoria_sesiones.dart';
import '../dominio/sellos.dart' show SelloConcedido;
import '../dominio/servicio_cumpleanyos.dart';
import '../dominio/servicio_saludo.dart';
import '../dominio/estado_sesion.dart';
import '../dominio/pieza_corpus.dart';
import 'paleta_estafeta.dart';
import 'pantalla_cuaderno.dart';
import 'pantalla_documento.dart';

class PantallaMesa extends StatefulWidget {
  const PantallaMesa({
    super.key,
    this.idPerfil = 'principal',
    this.cargadorInyectado,
    this.repositorioFamiliaridadInyectado,
    this.repositorioSesionInyectado,
    this.repositorioVocabularioInyectado,
    this.repositorioInterpretacionesInyectado,
    this.repositorioPistasInyectado,
    this.repositorioIdentificacionesInyectado,
    this.repositorioNotasLibresInyectado,
    this.repositorioAnotacionesInyectado,
    this.repositorioMemoriaSesionesInyectado,
    this.repositorioSellosInyectado,
    this.servicioSaludoInyectado,
    this.servicioCumpleanyosInyectado,
    this.alAbrirMapa,
  });

  /// Callback opcional para abrir el mapa del puerto desde la oficina.
  /// Si null, no se renderiza el botón (caso tests que usan
  /// PantallaMesa directamente sin orquestador).
  final VoidCallback? alAbrirMapa;

  /// ID del perfil del niño activo. En v0.4.0 hardcodeado a 'principal'
  /// hasta que llegue el sistema de perfiles del Descifrador.
  final String idPerfil;

  /// CargadorCorpus inyectado (para tests con bundle in-memory). Si
  /// null, se construye uno con rootBundle.
  final CargadorCorpus? cargadorInyectado;

  /// RepositorioFamiliaridad inyectado (para tests). Si null, se
  /// construye con el idPerfil.
  final RepositorioFamiliaridad? repositorioFamiliaridadInyectado;

  /// RepositorioSesion inyectado (para tests). Si null, se construye
  /// con el idPerfil.
  final RepositorioSesion? repositorioSesionInyectado;

  /// RepositorioVocabulario inyectado (para tests). Si null, se
  /// construye con el idPerfil.
  final RepositorioVocabulario? repositorioVocabularioInyectado;

  /// RepositorioInterpretaciones inyectado (para tests). Si null, se
  /// construye con el idPerfil.
  final RepositorioInterpretaciones? repositorioInterpretacionesInyectado;

  /// RepositorioPistas inyectado (para tests). Si null, se construye
  /// con el idPerfil.
  final RepositorioPistas? repositorioPistasInyectado;

  /// RepositorioIdentificaciones inyectado (para tests). Si null, se
  /// construye con el idPerfil.
  final RepositorioIdentificaciones? repositorioIdentificacionesInyectado;

  /// RepositorioNotasLibres inyectado (para tests). Si null, se
  /// construye con el idPerfil.
  final RepositorioNotasLibres? repositorioNotasLibresInyectado;

  /// RepositorioAnotaciones inyectado (para tests). Si null, se
  /// construye con el idPerfil.
  final RepositorioAnotaciones? repositorioAnotacionesInyectado;

  /// RepositorioMemoriaSesiones inyectado (para tests). Si null, se
  /// construye con el idPerfil.
  final RepositorioMemoriaSesiones? repositorioMemoriaSesionesInyectado;

  /// RepositorioSellos inyectado (para tests). Si null, se construye
  /// con el idPerfil.
  final RepositorioSellos? repositorioSellosInyectado;

  /// Servicios inyectables para tests deterministas. Si null, se usa
  /// la implementación por defecto (sin parámetros).
  final ServicioSaludo? servicioSaludoInyectado;
  final ServicioCumpleanyos? servicioCumpleanyosInyectado;

  @override
  State<PantallaMesa> createState() => _EstadoPantallaMesa();
}

class _EstadoPantallaMesa extends State<PantallaMesa> {
  EstadoSesion? _estado;
  String? _errorCarga;
  late final RepositorioFamiliaridad _repositorioFamiliaridad;
  late final RepositorioSesion _repositorioSesion;
  late final RepositorioVocabulario _repositorioVocabulario;
  late final RepositorioInterpretaciones _repositorioInterpretaciones;
  late final RepositorioPistas _repositorioPistas;
  late final RepositorioIdentificaciones _repositorioIdentificaciones;
  late final RepositorioNotasLibres _repositorioNotasLibres;
  late final RepositorioAnotaciones _repositorioAnotaciones;
  late final RepositorioMemoriaSesiones _repositorioMemoriaSesiones;
  late final RepositorioSellos _repositorioSellos;
  late final ServicioSaludo _servicioSaludo;
  late final ServicioCumpleanyos _servicioCumpleanyos;
  late final CargadorCorpus _cargador;
  IdentificacionesPiezas _identificaciones = IdentificacionesPiezas.inicial();
  MemoriaSesiones? _memoriaPreviaAEstaVisita;
  MemoriaSesiones? _memoriaActual;
  HitoCumpleanyos? _hitoActivo;
  List<SelloConcedido> _sellosNuevosPendientes = const [];

  @override
  void initState() {
    super.initState();
    _repositorioFamiliaridad =
        widget.repositorioFamiliaridadInyectado ??
            RepositorioFamiliaridad(idPerfil: widget.idPerfil);
    _repositorioSesion = widget.repositorioSesionInyectado ??
        RepositorioSesion(idPerfil: widget.idPerfil);
    _repositorioVocabulario = widget.repositorioVocabularioInyectado ??
        RepositorioVocabulario(idPerfil: widget.idPerfil);
    _repositorioInterpretaciones =
        widget.repositorioInterpretacionesInyectado ??
            RepositorioInterpretaciones(idPerfil: widget.idPerfil);
    _repositorioPistas = widget.repositorioPistasInyectado ??
        RepositorioPistas(idPerfil: widget.idPerfil);
    _repositorioIdentificaciones =
        widget.repositorioIdentificacionesInyectado ??
            RepositorioIdentificaciones(idPerfil: widget.idPerfil);
    _repositorioNotasLibres = widget.repositorioNotasLibresInyectado ??
        RepositorioNotasLibres(idPerfil: widget.idPerfil);
    _repositorioAnotaciones = widget.repositorioAnotacionesInyectado ??
        RepositorioAnotaciones(idPerfil: widget.idPerfil);
    _repositorioMemoriaSesiones =
        widget.repositorioMemoriaSesionesInyectado ??
            RepositorioMemoriaSesiones(idPerfil: widget.idPerfil);
    _repositorioSellos = widget.repositorioSellosInyectado ??
        RepositorioSellos(idPerfil: widget.idPerfil);
    _servicioSaludo =
        widget.servicioSaludoInyectado ?? const ServicioSaludo();
    _servicioCumpleanyos = widget.servicioCumpleanyosInyectado ??
        const ServicioCumpleanyos();
    _cargador = widget.cargadorInyectado ?? CargadorCorpus();
    _registrarVisitaYCargar();
    _cargarIdentificaciones();
  }

  Future<void> _registrarVisitaYCargar() async {
    final memoriaPrevia = await _repositorioMemoriaSesiones.cargar();
    final memoriaActual =
        await _repositorioMemoriaSesiones.registrarVisita();
    if (!mounted) return;
    setState(() {
      _memoriaPreviaAEstaVisita = memoriaPrevia;
      _memoriaActual = memoriaActual;
      _hitoActivo = _servicioCumpleanyos.hitoActivo(
        memoria: memoriaActual,
        ahora: memoriaActual.fechaUltimaVisita,
      );
    });
    await _cargarCorpus();
  }

  void _descartarSellosPendientes() {
    setState(() => _sellosNuevosPendientes = const []);
  }

  Future<void> _descartarHitoCumpleanyos() async {
    final actual = _memoriaActual;
    final hito = _hitoActivo;
    if (actual == null || hito == null) return;
    final siguiente = await _repositorioMemoriaSesiones.marcarHitoMostrado(
      memoriaActual: actual,
      hito: hito.dias,
    );
    if (!mounted) return;
    setState(() {
      _memoriaActual = siguiente;
      _hitoActivo = null;
    });
  }

  Future<void> _cargarIdentificaciones() async {
    final identificaciones = await _repositorioIdentificaciones.cargar();
    if (!mounted) return;
    setState(() => _identificaciones = identificaciones);
  }

  Future<void> _cargarCorpus() async {
    try {
      final resultado = await _cargador.cargarTodo();
      final sesion = await _repositorioSesion.cargar();
      if (!mounted) return;
      setState(() {
        _estado = EstadoSesion.reconciliar(
          piezasDelCorpus: resultado.piezasCargadas,
          idsResueltas: sesion.decisionesPorPieza.keys.toSet(),
        );
        _errorCarga = null;
      });
    } catch (excepcion) {
      if (!mounted) return;
      setState(() {
        _errorCarga = excepcion.toString();
      });
    }
  }

  Future<void> _abrirPieza(PiezaCorpus pieza) async {
    final piezasResueltas = _estado?.piezasResueltas() ?? const <PiezaCorpus>[];
    final resultado =
        await Navigator.of(context).push<ResultadoSesionDocumento>(
      MaterialPageRoute(
        builder: (contexto) => PantallaDocumento(
          pieza: pieza,
          repositorioFamiliaridad: _repositorioFamiliaridad,
          repositorioVocabularioInyectado: _repositorioVocabulario,
          repositorioInterpretacionesInyectado: _repositorioInterpretaciones,
          repositorioPistasInyectado: _repositorioPistas,
          repositorioIdentificacionesInyectado: _repositorioIdentificaciones,
          repositorioAnotacionesInyectado: _repositorioAnotaciones,
          repositorioSellosInyectado: _repositorioSellos,
          piezasResueltas: piezasResueltas,
          idPerfil: widget.idPerfil,
        ),
      ),
    );
    if (!mounted) return;
    // Refrescar identificaciones — el niño pudo haber identificado la
    // lengua sin llegar a decidir, y queremos que la tarjeta lo refleje.
    await _cargarIdentificaciones();
    if (!mounted) return;
    if (resultado != null) {
      // Persistir antes de actualizar UI para que un cierre forzoso
      // entre setState y guardar no pierda la decisión.
      await _repositorioSesion.registrarPiezaResuelta(
        pieza.id,
        resultado.decision,
      );
      if (!mounted) return;
      setState(() {
        _estado = _estado?.conPiezaResuelta(pieza.id);
        if (resultado.sellosNuevos.isNotEmpty) {
          _sellosNuevosPendientes = [
            ..._sellosNuevosPendientes,
            ...resultado.sellosNuevos,
          ];
        }
      });
    }
  }

  Future<void> _abrirCuaderno() async {
    final estado = _estado;
    if (estado == null) return;
    final familiaridad = await _repositorioFamiliaridad.cargar();
    final vocabulario = await _repositorioVocabulario.cargar();
    final interpretaciones = await _repositorioInterpretaciones.cargar();
    final notasLibres = await _repositorioNotasLibres.cargar();
    final sellos = await _repositorioSellos.cargar();
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (contexto) => PantallaCuaderno(
          estadoSesion: estado,
          familiaridad: familiaridad,
          vocabulario: vocabulario,
          interpretaciones: interpretaciones,
          notasLibres: notasLibres,
          sellos: sellos,
          repositorioNotasLibresInyectado: _repositorioNotasLibres,
          idPerfil: widget.idPerfil,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext contexto) {
    final estado = _estado;
    final error = _errorCarga;

    return Scaffold(
      backgroundColor: PaletaEstafeta.madera,
      body: SafeArea(
        child: error != null
            ? _ErrorCarga(error: error)
            : estado == null
                ? const _Cargando()
                : _Mesa(
                    estado: estado,
                    identificaciones: _identificaciones,
                    memoriaPreviaAEstaVisita: _memoriaPreviaAEstaVisita,
                    hitoCumpleanyos: _hitoActivo,
                    sellosNuevosPendientes: _sellosNuevosPendientes,
                    servicioSaludo: _servicioSaludo,
                    alTocarPieza: _abrirPieza,
                    alAbrirCuaderno: _abrirCuaderno,
                    alDescartarHito: _descartarHitoCumpleanyos,
                    alDescartarSellos: _descartarSellosPendientes,
                    alAbrirMapa: widget.alAbrirMapa,
                  ),
      ),
    );
  }
}

/// Releases de El Descifrador en GitHub: tag `el-descifrador-<versión>`
/// con el APK `el-descifrador-<versión>.apk`.
final ConfigActualizaciones _configActualizacionesDescifrador =
    configActualizacionesMonorepo('el-descifrador');

const String _nombreAppDescifrador = 'El Descifrador';

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext contexto) {
    return const Center(
      child: CircularProgressIndicator(color: PaletaEstafeta.papel),
    );
  }
}

class _ErrorCarga extends StatelessWidget {
  const _ErrorCarga({required this.error});

  final String error;

  @override
  Widget build(BuildContext contexto) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'La oficina está cerrada por hoy.',
              style: TextStyle(color: PaletaEstafeta.papel, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: const TextStyle(color: PaletaEstafeta.papel, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Mesa extends StatelessWidget {
  const _Mesa({
    required this.estado,
    required this.identificaciones,
    required this.memoriaPreviaAEstaVisita,
    required this.hitoCumpleanyos,
    required this.sellosNuevosPendientes,
    required this.servicioSaludo,
    required this.alTocarPieza,
    required this.alAbrirCuaderno,
    required this.alDescartarHito,
    required this.alDescartarSellos,
    this.alAbrirMapa,
  });

  final EstadoSesion estado;
  final IdentificacionesPiezas identificaciones;

  /// Estado de memoria previa a registrar la visita actual. Permite que
  /// el saludo mida "días desde la última visita" considerando hoy
  /// como visita nueva.
  final MemoriaSesiones? memoriaPreviaAEstaVisita;
  final HitoCumpleanyos? hitoCumpleanyos;

  /// Sellos del cuaderno recién concedidos en la última sesión de
  /// documento. Se muestran como banda discreta hasta que el niño la
  /// descarta.
  final List<SelloConcedido> sellosNuevosPendientes;
  final ServicioSaludo servicioSaludo;
  final ValueChanged<PiezaCorpus> alTocarPieza;
  final VoidCallback alAbrirCuaderno;
  final VoidCallback alDescartarHito;
  final VoidCallback alDescartarSellos;
  final VoidCallback? alAbrirMapa;

  @override
  Widget build(BuildContext contexto) {
    return Stack(
      children: [
        // Escenario renderizado en flavor3d v0.13: vista picada de la
        // oficina de La Estafeta con la mesa, lámpara, tintero, pluma
        // y ventana al mar atlántico. Se rellena recortando para cubrir
        // toda la pantalla (BoxFit.cover).
        Positioned.fill(
          child: Image.asset(
            'assets/escenarios/oficina.png',
            fit: BoxFit.cover,
          ),
        ),
        // Velo oscuro sutil para que los papeles y los textos
        // destaquen sobre el render iluminado.
        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.32)),
        ),
        // Frase del maestro en la parte superior + hito de cumpleaños
        // del cuaderno si toca (doc 06 §4).
        Positioned(
          top: 24,
          left: 32,
          right: 32,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SaludoMaestro(
                estado: estado,
                memoria: memoriaPreviaAEstaVisita,
                servicio: servicioSaludo,
              ),
              if (hitoCumpleanyos != null) ...[
                const SizedBox(height: 8),
                _BandaCumpleanyos(
                  hito: hitoCumpleanyos!,
                  alDescartar: alDescartarHito,
                ),
              ],
              if (sellosNuevosPendientes.isNotEmpty) ...[
                const SizedBox(height: 8),
                _BandaSellosNuevos(
                  sellos: sellosNuevosPendientes,
                  alDescartar: alDescartarSellos,
                ),
              ],
              // Aviso de versión nueva, como una banda más. Si no hay
              // versión nueva no ocupa sitio.
              AvisoActualizaciones(
                config: _configActualizacionesDescifrador,
                nombreApp: _nombreAppDescifrador,
                margen: const EdgeInsets.only(top: 8),
              ),
            ],
          ),
        ),
        // Bandeja de entrada (esquina superior izquierda).
        Positioned(
          left: 32,
          top: 96,
          child: _BandejaEntrada(
            piezas: estado.piezasEnBandejaDeEntrada(),
            identificaciones: identificaciones,
            alTocarPieza: alTocarPieza,
          ),
        ),
        // Bandeja resuelto (esquina superior derecha) — indicador
        // discreto del trabajo del día.
        Positioned(
          right: 32,
          top: 96,
          child: _BandejaResuelto(cantidad: estado.cantidadResueltas),
        ),
        // Botón del cuaderno (lateral derecho). Doc 11 §5.1 sitúa el
        // cuaderno parcialmente visible en lateral derecho de la mesa.
        Positioned(
          right: 32,
          bottom: 32,
          child: _BotonCuaderno(alPulsar: alAbrirCuaderno),
        ),
        // Entrada a la pantalla de actualizaciones, abajo en el centro
        // entre el mapa y el cuaderno (la mesa no tiene AppBar ni menú).
        Positioned(
          left: 0,
          right: 0,
          bottom: 28,
          child: Center(
            child: IconButton(
              tooltip: 'Actualizaciones',
              icon: Icon(
                Icons.system_update,
                color: PaletaEstafeta.papel.withValues(alpha: 0.8),
              ),
              onPressed: () => Navigator.of(contexto).push(
                MaterialPageRoute<void>(
                  builder: (_) => PantallaEstadoActualizaciones(
                    config: _configActualizacionesDescifrador,
                    nombreApp: _nombreAppDescifrador,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Botón mapa, esquina inferior izquierda — para salir al puerto
        // (calle mayor → resto de localizaciones). Solo aparece si el
        // orquestador inyectó el callback (no en tests aislados).
        if (alAbrirMapa != null)
          Positioned(
            left: 32,
            bottom: 32,
            child: _BotonMapa(alPulsar: alAbrirMapa!),
          ),
      ],
    );
  }
}

class _BotonMapa extends StatelessWidget {
  const _BotonMapa({required this.alPulsar});

  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext contexto) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(2),
      child: InkWell(
        onTap: alPulsar,
        borderRadius: BorderRadius.circular(2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map_outlined,
                color: PaletaEstafeta.papel,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'Salir al puerto',
                style: TextStyle(
                  color: PaletaEstafeta.papel,
                  fontSize: 13,
                  fontFamily: 'serif',
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BandaCumpleanyos extends StatelessWidget {
  const _BandaCumpleanyos({required this.hito, required this.alDescartar});

  final HitoCumpleanyos hito;
  final VoidCallback alDescartar;

  @override
  Widget build(BuildContext contexto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: PaletaEstafeta.papel.withValues(alpha: 0.08),
        border: Border(
          left: BorderSide(
            color: PaletaEstafeta.papel.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hito.texto,
              style: const TextStyle(
                color: PaletaEstafeta.papel,
                fontSize: 14,
                fontFamily: 'serif',
                height: 1.4,
              ),
            ),
          ),
          IconButton(
            onPressed: alDescartar,
            icon: Icon(
              Icons.close,
              size: 16,
              color: PaletaEstafeta.papel.withValues(alpha: 0.7),
            ),
            tooltip: 'Cerrar',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }
}

class _BandaSellosNuevos extends StatelessWidget {
  const _BandaSellosNuevos({
    required this.sellos,
    required this.alDescartar,
  });

  final List<SelloConcedido> sellos;
  final VoidCallback alDescartar;

  @override
  Widget build(BuildContext contexto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: PaletaEstafeta.papel.withValues(alpha: 0.08),
        border: Border(
          left: BorderSide(
            color: PaletaEstafeta.papel.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final sello in sellos) ...[
                  Text(
                    sello.texto,
                    style: const TextStyle(
                      color: PaletaEstafeta.papel,
                      fontSize: 14,
                      fontFamily: 'serif',
                      height: 1.4,
                    ),
                  ),
                  if (sello != sellos.last) const SizedBox(height: 4),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: alDescartar,
            icon: Icon(
              Icons.close,
              size: 16,
              color: PaletaEstafeta.papel.withValues(alpha: 0.7),
            ),
            tooltip: 'Cerrar',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }
}

class _SaludoMaestro extends StatelessWidget {
  const _SaludoMaestro({
    required this.estado,
    required this.memoria,
    required this.servicio,
  });

  final EstadoSesion estado;
  final MemoriaSesiones? memoria;
  final ServicioSaludo servicio;

  @override
  Widget build(BuildContext contexto) {
    final saludo = servicio.saludoParaSesion(
      memoria: memoria,
      estado: estado,
      ahora: DateTime.now(),
    );
    return Text(
      saludo,
      style: const TextStyle(
        color: PaletaEstafeta.papel,
        fontSize: 18,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class _BandejaEntrada extends StatelessWidget {
  const _BandejaEntrada({
    required this.piezas,
    required this.identificaciones,
    required this.alTocarPieza,
  });

  final List<PiezaCorpus> piezas;
  final IdentificacionesPiezas identificaciones;
  final ValueChanged<PiezaCorpus> alTocarPieza;

  @override
  Widget build(BuildContext contexto) {
    if (piezas.isEmpty) {
      return const SizedBox.shrink();
    }
    // Layout vertical sin solapamiento en v0.4.0. El "papeles apilados
    // con leves rotaciones" del doc 11 §5.1 lo afinará el ilustrador
    // asignado cuando llegue (B8). Esta versión es funcional y
    // permite hit-testing claro en tests.
    return SizedBox(
      width: 260,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var indice = 0; indice < piezas.length; indice++) ...[
            if (indice > 0) const SizedBox(height: 12),
            _PapelEnBandeja(
              key: ValueKey('pieza-${piezas[indice].id}'),
              pieza: piezas[indice],
              lenguaIdentificada:
                  identificaciones.yaIdentificada(piezas[indice].id),
              alTocar: () => alTocarPieza(piezas[indice]),
            ),
          ],
        ],
      ),
    );
  }
}

class _PapelEnBandeja extends StatelessWidget {
  const _PapelEnBandeja({
    super.key,
    required this.pieza,
    required this.lenguaIdentificada,
    required this.alTocar,
  });

  final PiezaCorpus pieza;

  /// True si el niño ya identificó la lengua de esta pieza. Si no,
  /// la tarjeta muestra "?" en el espacio de lengua — mecánica
  /// nuclear §3.1.
  final bool lenguaIdentificada;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext contexto) {
    // Nota v0.4.0: rotación visual diferida hasta que llegue ilustrador
    // (doc 11 §5.1 pide leves rotaciones de 4-6° entre piezas). Transform.rotate
    // interfiere con hit-testing en tests; el efecto se aplicará en CSS/widget
    // de presentación cuando se cierre la guía visual definitiva.
    return Material(
      color: PaletaEstafeta.papel,
      elevation: 4,
      borderRadius: BorderRadius.circular(2),
      child: InkWell(
        onTap: alTocar,
        borderRadius: BorderRadius.circular(2),
        child: Container(
            width: 220,
            height: 280,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pieza.tipo.identificadorTecnico,
                  style: TextStyle(
                    color: PaletaEstafeta.sepia.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  pieza.remitenteTextoLibre.replaceAll('_', ' '),
                  style: const TextStyle(
                    color: PaletaEstafeta.tinta,
                    fontSize: 13,
                    fontFamily: 'serif',
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  lenguaIdentificada
                      ? pieza.lenguaPrincipal.nombreCanonico
                      : 'lengua sin identificar',
                  style: const TextStyle(
                    color: PaletaEstafeta.sepia,
                    fontSize: 11,
                    fontFamily: 'serif',
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Spacer(),
                Text(
                  // Asomo del texto sin abrir — solo las primeras
                  // palabras, atenuadas. El cuerpo se ve al abrir.
                  pieza.textoDocumento.split('\n').first,
                  style: TextStyle(
                    color: PaletaEstafeta.tinta.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontFamily: 'serif',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class _BotonCuaderno extends StatelessWidget {
  const _BotonCuaderno({required this.alPulsar});

  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext contexto) {
    return Material(
      color: PaletaEstafeta.papel,
      elevation: 4,
      borderRadius: BorderRadius.circular(2),
      child: InkWell(
        key: const ValueKey('boton-cuaderno'),
        onTap: alPulsar,
        borderRadius: BorderRadius.circular(2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.book_outlined,
                color: PaletaEstafeta.tinta,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Tu cuaderno',
                style: const TextStyle(
                  color: PaletaEstafeta.tinta,
                  fontSize: 14,
                  fontFamily: 'serif',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BandejaResuelto extends StatelessWidget {
  const _BandejaResuelto({required this.cantidad});

  final int cantidad;

  @override
  Widget build(BuildContext contexto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: PaletaEstafeta.sepia.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: PaletaEstafeta.sepia.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        cantidad == 0
            ? 'Archivo: nada hoy'
            : cantidad == 1
                ? 'Archivo: 1 pieza'
                : 'Archivo: $cantidad piezas',
        style: const TextStyle(
          color: PaletaEstafeta.papel,
          fontSize: 12,
          fontFamily: 'serif',
        ),
      ),
    );
  }
}
