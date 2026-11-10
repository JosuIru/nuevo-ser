import 'package:flutter/material.dart';

import '../datos/catalogo_habilidades.dart';
import '../datos/cliente_tutor_panel.dart';
import '../datos/config_api.dart';
import '../dominio/catalogo_distritos.dart';
import '../dominio/distrito.dart';
import '../dominio/estado_cuaderno.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';
import '../l10n/app_localizations.dart';
import '../l10n/traducciones_narrativa.dart';
import '../nucleo/paleta.dart';
import 'widgets/indicador_ventana.dart';

/// Panel del tutor: el adulto entra con su email/password, lista los
/// niños vinculados a su cuenta, elige uno y ve el progreso detallado.
///
/// A diferencia del cuaderno del niño (sin números, sin juicios), aquí
/// añadimos métricas crudas: nivel 0-5, precisión, días desde última
/// práctica. Read-only — esta pantalla nunca modifica datos.
///
/// Token en memoria, NO en disco. TTL 15 minutos servidor (configurado
/// en el plugin). Si la sesión caduca, vuelve a pedirla.
class PantallaPanelTutor extends StatefulWidget {
  const PantallaPanelTutor({super.key});

  @override
  State<PantallaPanelTutor> createState() => _PantallaPanelTutorState();
}

class _PantallaPanelTutorState extends State<PantallaPanelTutor> {
  final ClienteTutorPanel _cliente = ClienteTutorPanel(
    urlBase: ConfigApi.urlBase,
    hostOverride: ConfigApi.hostOverride,
  );

  String? _token;
  String _nombreTutor = '';
  List<ResumenNino> _ninos = const [];
  ResumenNino? _ninoSeleccionado;
  ProgresoNino? _progresoNinoSeleccionado;
  CatalogoHabilidades? _catalogo;
  bool _cargando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    CatalogoHabilidades.cargar().then((c) {
      if (mounted) setState(() => _catalogo = c);
    });
  }

  @override
  void dispose() {
    _cliente.cerrar();
    super.dispose();
  }

  Future<void> _autenticar(String email, String password) async {
    final textos = AppLocalizations.of(context);
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final auth = await _cliente.iniciarSesionTutor(
        email: email,
        password: password,
      );
      final ninos = await _cliente.listarNinos(auth.token);
      if (!mounted) return;
      setState(() {
        _token = auth.token;
        _nombreTutor = auth.nombreTutor;
        _ninos = ninos;
        if (ninos.length == 1) {
          _ninoSeleccionado = ninos.first;
        }
        _cargando = false;
      });
      if (ninos.length == 1) {
        await _cargarProgreso(ninos.first);
      }
    } on ExcepcionTutorPanel catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = e.codigoHttp == 401
            ? textos.panelTutorErrorAuth
            : textos.panelTutorErrorServidor(e.codigoHttp);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = textos.panelTutorErrorRed;
      });
    }
  }

  Future<void> _cargarProgreso(ResumenNino nino) async {
    if (_token == null) return;
    final textos = AppLocalizations.of(context);
    setState(() => _cargando = true);
    try {
      final progreso = await _cliente.obtenerProgresoNino(
        token: _token!,
        ninoId: nino.ninoId,
      );
      if (!mounted) return;
      setState(() {
        _ninoSeleccionado = nino;
        _progresoNinoSeleccionado = progreso;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = textos.panelTutorErrorProgreso;
      });
    }
  }

  void _cerrarSesion() {
    setState(() {
      _token = null;
      _nombreTutor = '';
      _ninos = const [];
      _ninoSeleccionado = null;
      _progresoNinoSeleccionado = null;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: PaletaNeon.fondoProfundo,
      appBar: AppBar(
        backgroundColor: PaletaNeon.fondoMedio,
        iconTheme: const IconThemeData(color: PaletaNeon.textoTenue),
        title: Text(
          textos.panelTutorTitulo,
          style: const TextStyle(
            color: PaletaNeon.textoPrincipal,
            fontSize: 14,
            letterSpacing: 4,
            fontWeight: FontWeight.w300,
          ),
        ),
        actions: [
          if (_token != null)
            IconButton(
              tooltip: textos.panelTutorTooltipSalir,
              icon: const Icon(Icons.logout, size: 18),
              onPressed: _cerrarSesion,
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: PaletaNeon.fondoCiudad),
        child: _token == null
            ? _FormularioAuth(
                cargando: _cargando,
                error: _error,
                alEnviar: _autenticar,
              )
            : _Panel(
                nombreTutor: _nombreTutor,
                ninos: _ninos,
                ninoSeleccionado: _ninoSeleccionado,
                progreso: _progresoNinoSeleccionado,
                catalogo: _catalogo,
                cargando: _cargando,
                alSeleccionarNino: _cargarProgreso,
              ),
      ),
    );
  }
}

class _FormularioAuth extends StatefulWidget {
  final bool cargando;
  final String? error;
  final void Function(String email, String password) alEnviar;

  const _FormularioAuth({
    required this.cargando,
    required this.error,
    required this.alEnviar,
  });

  @override
  State<_FormularioAuth> createState() => _FormularioAuthState();
}

class _FormularioAuthState extends State<_FormularioAuth> {
  final _ctrlEmail = TextEditingController();
  final _ctrlPass = TextEditingController();
  bool _ocultarPass = true;

  @override
  void dispose() {
    _ctrlEmail.dispose();
    _ctrlPass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: rellenoInferiorSeguro(context, const EdgeInsets.fromLTRB(24, 32, 24, 32)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              textos.panelTutorTagline,
              style: TextStyle(
                fontFamily: 'CormorantGaramond',
                fontStyle: FontStyle.italic,
                fontSize: 22,
                color: PaletaNeon.textoPrincipal.withOpacity(0.95),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              textos.panelTutorIntro,
              style: TextStyle(
                color: PaletaNeon.textoTenue.withOpacity(0.85),
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _ctrlEmail,
              autofillHints: const [AutofillHints.email],
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: PaletaNeon.textoPrincipal),
              decoration: InputDecoration(
                labelText: textos.panelTutorCampoEmail,
                labelStyle: const TextStyle(color: PaletaNeon.textoTenue),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _ctrlPass,
              obscureText: _ocultarPass,
              autofillHints: const [AutofillHints.password],
              style: const TextStyle(color: PaletaNeon.textoPrincipal),
              decoration: InputDecoration(
                labelText: textos.panelTutorCampoPassword,
                labelStyle: const TextStyle(color: PaletaNeon.textoTenue),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _ocultarPass = !_ocultarPass),
                  icon: Icon(
                    _ocultarPass
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: 18,
                    color: PaletaNeon.textoTenue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: widget.cargando
                  ? null
                  : () => widget.alEnviar(
                        _ctrlEmail.text.trim(),
                        _ctrlPass.text,
                      ),
              child: widget.cargando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: PaletaNeon.textoPrincipal,
                      ),
                    )
                  : Text(textos.panelTutorBotonEntrar),
            ),
            if (widget.error != null) ...[
              const SizedBox(height: 18),
              Text(
                widget.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: PaletaNeon.rosaAcento,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String nombreTutor;
  final List<ResumenNino> ninos;
  final ResumenNino? ninoSeleccionado;
  final ProgresoNino? progreso;
  final CatalogoHabilidades? catalogo;
  final bool cargando;
  final void Function(ResumenNino) alSeleccionarNino;

  const _Panel({
    required this.nombreTutor,
    required this.ninos,
    required this.ninoSeleccionado,
    required this.progreso,
    required this.catalogo,
    required this.cargando,
    required this.alSeleccionarNino,
  });

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    if (ninos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            textos.panelTutorSinNinos,
            style: TextStyle(color: PaletaNeon.textoTenue.withOpacity(0.85)),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _Saludo(nombreTutor: nombreTutor),
        ),
        if (ninos.length > 1)
          SliverToBoxAdapter(
            child: _SelectorNino(
              ninos: ninos,
              seleccionado: ninoSeleccionado,
              alElegir: alSeleccionarNino,
            ),
          ),
        if (cargando)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: PaletaNeon.azulNeon),
              ),
            ),
          )
        else if (progreso != null && catalogo != null)
          ..._construirSeccionesDistrito(context, progreso!, catalogo!)
        else
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                textos.panelTutorElegirNino,
                style: const TextStyle(color: PaletaNeon.textoTenue),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        // CustomScrollView no deja solo el hueco de la barra de navegación
        // del sistema (edge-to-edge, Android 15+): lo último quedaba debajo.
        SliverToBoxAdapter(
          child: SizedBox(
            height: rellenoInferiorSeguro(
              context,
              const EdgeInsets.only(bottom: 16),
            ).bottom,
          ),
        ),
      ],
    );
  }

  List<Widget> _construirSeccionesDistrito(
    BuildContext context,
    ProgresoNino progreso,
    CatalogoHabilidades catalogo,
  ) {
    final estadosPorId = <String, EstadoHabilidad>{
      for (final e in progreso.habilidades) e.identificadorHabilidad: e,
    };

    final secciones = <Widget>[];
    for (final distrito in CatalogoDistritos.todos) {
      final habilidades = catalogo.delDistrito(distrito.identificador);
      if (habilidades.isEmpty) continue;
      // Ordenamos por urgencia: precisión baja y muchos días sin
      // practicar primero. Es la pista accionable para el tutor.
      habilidades.sort((a, b) {
        final ea = estadosPorId[a.identificador];
        final eb = estadosPorId[b.identificador];
        final urgenciaA = _urgencia(ea);
        final urgenciaB = _urgencia(eb);
        return urgenciaB.compareTo(urgenciaA);
      });
      secciones.add(
        SliverToBoxAdapter(
          child: _CabeceraDistrito(distrito: distrito),
        ),
      );
      secciones.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) {
              final hab = habilidades[i];
              return _LineaTutor(
                habilidad: hab,
                estado: estadosPorId[hab.identificador],
                colorAcento: distrito.colorAcento,
              );
            },
            childCount: habilidades.length,
          ),
        ),
      );
    }
    secciones.add(const SliverToBoxAdapter(child: SizedBox(height: 32)));
    return secciones;
  }

  /// Heurística simple para ordenar: cuanto más alta más urgente.
  /// Latentes (sin tocar) bajas; vistas con poca precisión altas;
  /// dominadas hace mucho tiempo, también suben.
  double _urgencia(EstadoHabilidad? estado) {
    if (estado == null) return 0; // latente — no urgente, a su ritmo
    final dias = DateTime.now().difference(estado.ultimaPractica).inDays;
    final precisionInversa = 1 - estado.precision;
    final factorTiempo = (dias.toDouble()).clamp(0, 60) / 60.0;
    return precisionInversa * 0.6 + factorTiempo * 0.4;
  }
}

class _Saludo extends StatelessWidget {
  final String nombreTutor;
  const _Saludo({required this.nombreTutor});

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final nombre = nombreTutor.trim();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (nombre.isNotEmpty)
            Text(
              textos.panelTutorSaludoConNombre(nombre),
              style: TextStyle(
                fontFamily: 'CormorantGaramond',
                fontStyle: FontStyle.italic,
                fontSize: 22,
                color: PaletaNeon.textoPrincipal.withOpacity(0.92),
              ),
            ),
          Text(
            textos.panelTutorSubtituloSaludo,
            style: TextStyle(
              fontSize: 12,
              color: PaletaNeon.textoTenue.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectorNino extends StatelessWidget {
  final List<ResumenNino> ninos;
  final ResumenNino? seleccionado;
  final void Function(ResumenNino) alElegir;

  const _SelectorNino({
    required this.ninos,
    required this.seleccionado,
    required this.alElegir,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: ninos.map((n) {
          final activo = seleccionado?.ninoId == n.ninoId;
          return ChoiceChip(
            label: Text(n.nombreMostrar),
            selected: activo,
            onSelected: (_) => alElegir(n),
            selectedColor: PaletaNeon.violetaNeon.withOpacity(0.4),
            backgroundColor: PaletaNeon.fondoMedio,
            labelStyle: TextStyle(
              color: activo
                  ? PaletaNeon.textoPrincipal
                  : PaletaNeon.textoTenue,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CabeceraDistrito extends StatelessWidget {
  final Distrito distrito;
  const _CabeceraDistrito({required this.distrito});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: distrito.colorAcento,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            traducirNarrativa(
              distrito.nombre,
              Localizations.localeOf(context),
            ).toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 3,
              color: distrito.colorAcento.withOpacity(0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _LineaTutor extends StatelessWidget {
  final Habilidad habilidad;
  final EstadoHabilidad? estado;
  final Color colorAcento;

  const _LineaTutor({
    required this.habilidad,
    required this.estado,
    required this.colorAcento,
  });

  String _diasDesde() {
    if (estado == null ||
        estado!.ultimaPractica.millisecondsSinceEpoch == 0) {
      return 'nunca';
    }
    final dias = DateTime.now().difference(estado!.ultimaPractica).inDays;
    if (dias <= 0) return 'hoy';
    if (dias == 1) return 'ayer';
    return 'hace $dias días';
  }

  @override
  Widget build(BuildContext context) {
    final clas = estado == null
        ? EstadoCuaderno.latente
        : estadoCuadernoDe(estado!);
    final precisionPct = ((estado?.precision ?? 0) * 100).round();
    final exposiciones = estado?.totalExposiciones ?? 0;
    final nivel = estado?.nivel.valor ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: PaletaNeon.fondoMedio.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorAcento.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          IndicadorVentana(
            estado: clas,
            colorAcento: colorAcento,
            tamano: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${habilidad.identificador}  ·  ${traducirNarrativa(habilidad.nombre, Localizations.localeOf(context))}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: PaletaNeon.textoPrincipal,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'nivel $nivel  ·  precisión $precisionPct%  ·  $exposiciones intentos  ·  ${_diasDesde()}',
                  style: TextStyle(
                    fontSize: 11,
                    color: PaletaNeon.textoTenue.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
