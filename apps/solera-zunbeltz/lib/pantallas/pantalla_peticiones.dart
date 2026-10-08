import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../branding.dart';
import '../datos/base_datos.dart';
import '../estado/datos_notificador.dart';
import '../estado/sesion_espacio.dart';
import '../l10n/app_localizations.dart';
import '../modelos/finca.dart';
import '../modelos/peticion_tarea.dart';
import 'nueva_peticion.dart';
import 'nueva_tarea.dart';
import 'widgets/relleno_seguro.dart';

/// Peticiones de tarea. Coordinación ve todas y las convierte en tarea o
/// las descarta; cada persona tester ve las suyas y su respuesta.
class PantallaPeticiones extends StatefulWidget {
  const PantallaPeticiones({super.key});

  @override
  State<PantallaPeticiones> createState() => _PantallaPeticionesState();
}

class _PantallaPeticionesState extends State<PantallaPeticiones> {
  final _bd = BaseDatosSoleraZunbeltz();
  List<PeticionTarea> _peticiones = const [];
  Map<int, Finca> _fincasPorId = const {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
    notificadorDatos.addListener(_cargar);
  }

  @override
  void dispose() {
    notificadorDatos.removeListener(_cargar);
    super.dispose();
  }

  Future<void> _cargar() async {
    try {
      final peticiones = await _bd.listarPeticiones();
      final fincas = await _bd.listarFincas();
      if (!mounted) return;
      setState(() {
        _peticiones = peticiones;
        _fincasPorId = {
          for (final finca in fincas)
            if (finca.id != null) finca.id!: finca,
        };
        _cargando = false;
      });
    } catch (_) {
      // Sin esto, si la BD falla el indicador de carga gira para siempre.
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _nueva() async {
    final creada = await Navigator.of(context)
        .push<bool>(MaterialPageRoute(builder: (_) => const NuevaPeticion()));
    if (creada == true) {
      avisarCambioDatos();
      await _cargar();
    }
  }

  Future<void> _crearTarea(PeticionTarea peticion) async {
    final textos = AppLocalizations.of(context);
    final fincaId = peticion.fincaId ?? _fincasPorId.keys.firstOrNull;
    if (fincaId == null || peticion.id == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(textos.peticionNecesitaFinca)));
      return;
    }
    final creada = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => NuevaTarea(
        fincaId: fincaId,
        puntoId: peticion.puntoId,
        tituloInicial: peticion.titulo,
        descripcionInicial: peticion.descripcion,
        guardar: (tarea) => _bd.aceptarPeticion(peticion.id!, tarea),
      ),
    ));
    if (creada == true) {
      avisarCambioDatos();
      await _cargar();
    }
  }

  Future<void> _descartar(PeticionTarea peticion) async {
    final textos = AppLocalizations.of(context);
    final controlador = TextEditingController();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) => AlertDialog(
        title: Text(textos.peticionDescartar),
        content: TextField(
          controller: controlador,
          autofocus: true,
          maxLines: 2,
          decoration: InputDecoration(labelText: textos.peticionMotivo),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(contexto, false),
              child: Text(textos.comunCancelar)),
          FilledButton(
              onPressed: () => Navigator.pop(contexto, true),
              child: Text(textos.peticionDescartar)),
        ],
      ),
    );
    if (confirmado != true || peticion.id == null) return;
    await _bd.actualizarPeticion(peticion.id!, {
      'estado': estadoPeticionDescartada,
      'respuesta': controlador.text.trim(),
    });
    avisarCambioDatos();
    await _cargar();
  }

  Future<void> _retirar(PeticionTarea peticion) async {
    if (peticion.id == null) return;
    await _bd.borrarPeticion(peticion.id!);
    avisarCambioDatos();
    await _cargar();
  }

  String _estado(PeticionTarea peticion, AppLocalizations textos) =>
      switch (peticion.estado) {
        estadoPeticionAceptada => textos.peticionEstadoAceptada,
        estadoPeticionDescartada => textos.peticionEstadoDescartada,
        _ => textos.peticionEstadoPendiente,
      };

  @override
  Widget build(BuildContext context) {
    final textos = AppLocalizations.of(context);
    final idioma = Localizations.localeOf(context).languageCode;
    final politica = politicaEspacioActual;
    final miUid = politica.miUid;
    return Scaffold(
      appBar: AppBar(title: Text(textos.peticionesTitulo)),
      floatingActionButton: politica.puedeEnviarPeticiones
          ? FloatingActionButton.extended(
              onPressed: _nueva,
              icon: const Icon(Icons.add_comment_outlined),
              label: Text(textos.peticionNueva),
            )
          : null,
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _peticiones.isEmpty
              ? Center(child: Text(textos.peticionesVacio))
              : ListView(
                  padding: rellenoSobreBarraSistema(
                      context, const EdgeInsets.only(bottom: 88)),
                  children: [
                    for (final peticion in _peticiones)
                      Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                if (peticion.urgente)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Icon(Icons.priority_high,
                                        size: 18, color: colorSenalZunbeltz),
                                  ),
                                Expanded(
                                  child: Text(peticion.titulo,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium),
                                ),
                              ]),
                              const SizedBox(height: 4),
                              Text([
                                textos.peticionDe(
                                    nombrePersonaEspacio(peticion.autorUid) ??
                                        textos.personaDesconocida),
                                if (peticion.fincaId != null &&
                                    _fincasPorId[peticion.fincaId] != null)
                                  _fincasPorId[peticion.fincaId]!.nombre,
                                if (peticion.fechaCreacionMs > 0)
                                  DateFormat('dd/MM/yyyy', idioma).format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          peticion.fechaCreacionMs)),
                                _estado(peticion, textos),
                              ].join(' · ')),
                              if (peticion.descripcion.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(peticion.descripcion),
                              ],
                              if (peticion.respuesta.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                    textos
                                        .peticionRespuesta(peticion.respuesta),
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ],
                              if (peticion.pendiente)
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    if (politica.puedeGestionarPeticiones) ...[
                                      FilledButton.tonal(
                                        onPressed: () => _crearTarea(peticion),
                                        child: Text(textos.peticionCrearTarea),
                                      ),
                                      TextButton(
                                        onPressed: () => _descartar(peticion),
                                        child: Text(textos.peticionDescartar),
                                      ),
                                    ] else if (peticion.autorUid == miUid ||
                                        politica.modoLocal)
                                      TextButton(
                                        onPressed: () => _retirar(peticion),
                                        child: Text(textos.peticionRetirar),
                                      ),
                                  ],
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
