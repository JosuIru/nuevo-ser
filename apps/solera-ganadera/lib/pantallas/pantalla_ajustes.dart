import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SelectorIdioma, SoleraL10n;
import 'package:nuevo_ser_mapa/nuevo_ser_mapa.dart' show CampoPunto;

import '../branding.dart';

import '../datos/base_datos.dart';
import '../modelos/explotacion.dart';
import '../modelos/ganado.dart';
import '../modelos/titular.dart';
import '../utiles/textos_ganadera.dart';
import 'lectura_receta.dart';
import '../servicios/exportacion_datos.dart';
import 'pantalla_ayuda.dart';
import 'pantalla_documentos.dart';
import 'pantalla_economia.dart';

/// Ajustes: idioma, titular y explotación (los datos de cabecera del libro
/// de registro) y los accesos al resto.
class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  final _nombre = TextEditingController();
  final _nif = TextEditingController();
  final _telefono = TextEditingController();
  final _correo = TextEditingController();
  final _direccion = TextEditingController();
  final _rega = TextEditingController();
  final _nombreExplotacion = TextEditingController();
  final _direccionExplotacion = TextEditingController();
  final _municipio = TextEditingController();
  final _provincia = TextEditingController();
  final _clasificacion = TextEditingController();
  final _capacidad = TextEditingController();
  Set<String> _especies = {};
  Explotacion _explotacion = Explotacion();

  List<TextEditingController> get _controladores => [
        _nombre,
        _nif,
        _telefono,
        _correo,
        _direccion,
        _rega,
        _nombreExplotacion,
        _direccionExplotacion,
        _municipio,
        _provincia,
        _clasificacion,
        _capacidad,
      ];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final baseDatos = BaseDatosSoleraGanadera.instancia;
      final titular = await baseDatos.obtenerTitular();
      final explotacion = await baseDatos.obtenerExplotacion();
      if (!mounted) return;
      setState(() {
        _nombre.text = titular.nombre;
        _nif.text = titular.nif;
        _telefono.text = titular.telefono;
        _correo.text = titular.correo;
        _direccion.text = titular.direccion;
        _explotacion = explotacion;
        _rega.text = explotacion.codigoRega;
        _nombreExplotacion.text = explotacion.nombre;
        _direccionExplotacion.text = explotacion.direccion;
        _municipio.text = explotacion.municipio;
        _provincia.text = explotacion.provincia;
        _clasificacion.text = explotacion.clasificacion;
        _capacidad.text = explotacion.capacidadMaxima == 0
            ? ''
            : '${explotacion.capacidadMaxima}';
        _especies = {...explotacion.especies};
      });
    } catch (error) {
      debugPrint('No se pudieron leer los ajustes: $error');
    }
  }

  /// El punto de la explotación: con el GPS o marcado en el mapa.
  void _cambiarUbicacion(double? latitud, double? longitud) {
    setState(() {
      _explotacion = Explotacion.fromMap(_explotacion.toMap()
        ..['latitud'] = latitud
        ..['longitud'] = longitud);
    });
  }

  Future<void> _guardar() async {
    final baseDatos = BaseDatosSoleraGanadera.instancia;
    await baseDatos.guardarTitular(Titular(
      nombre: _nombre.text.trim(),
      nif: _nif.text.trim(),
      telefono: _telefono.text.trim(),
      correo: _correo.text.trim(),
      direccion: _direccion.text.trim(),
    ));
    final rega = _rega.text.replaceAll(' ', '').toUpperCase();
    await baseDatos.guardarExplotacion(Explotacion(
      codigoRega: rega,
      nombre: _nombreExplotacion.text.trim(),
      direccion: _direccionExplotacion.text.trim(),
      municipio: _municipio.text.trim(),
      provincia: _provincia.text.trim(),
      latitud: _explotacion.latitud,
      longitud: _explotacion.longitud,
      clasificacion: _clasificacion.text.trim(),
      capacidadMaxima: leerEntero(_capacidad.text) ?? 0,
      especies: _especies,
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(SoleraL10n.t(rega.isEmpty || pareceCodigoRega(rega)
            ? 'gana.guardado'
            : 'gana.guardado_rega_raro'))));
  }

  @override
  void dispose() {
    for (final controlador in _controladores) {
      controlador.dispose();
    }
    super.dispose();
  }

  Widget _campo(TextEditingController controlador, String clave,
          {TextInputType? teclado}) =>
      TextField(
        controller: controlador,
        keyboardType: teclado,
        decoration: InputDecoration(labelText: SoleraL10n.t(clave)),
      );

  @override
  Widget build(BuildContext context) {
    final estilos = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ajustes'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.picture_as_pdf_outlined),
            title: Text(SoleraL10n.t('gana.documentos')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaDocumentos())),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.auto_awesome_outlined),
            title: Text(SoleraL10n.t('gana.inteligencia_artificial')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => abrirClaveIaGanadera(context),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.euro_outlined),
            title: Text(SoleraL10n.t('gana.ingresos_y_gastos')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaEconomia())),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.download_outlined),
            title: Text(SoleraL10n.t('gana.exportar_datos')),
            subtitle: Text(SoleraL10n.t('gana.exportar_datos_explicacion')),
            onTap: () async {
              final mensajero = ScaffoldMessenger.of(context);
              try {
                await exportarTodosLosDatos();
              } catch (error) {
                debugPrint('Exportación fallida: $error');
                mensajero.showSnackBar(SnackBar(
                    content: Text(SoleraL10n.t('gana.error_documento'))));
              }
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.help_outline),
            title: Text(SoleraL10n.t('gana.ayuda')),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PantallaAyuda())),
          ),
          const SelectorIdioma(),
          const SizedBox(height: 24),
          Text(SoleraL10n.t('gana.titular'), style: estilos.titleMedium),
          _campo(_nombre, 'gana.nombre_titular'),
          _campo(_nif, 'gana.nif'),
          _campo(_telefono, 'gana.telefono', teclado: TextInputType.phone),
          _campo(_correo, 'gana.correo', teclado: TextInputType.emailAddress),
          _campo(_direccion, 'gana.direccion'),
          const SizedBox(height: 24),
          Text(SoleraL10n.t('gana.explotacion'), style: estilos.titleMedium),
          _campo(_rega, 'gana.codigo_rega'),
          _campo(_nombreExplotacion, 'gana.nombre_explotacion'),
          _campo(_direccionExplotacion, 'gana.direccion'),
          _campo(_municipio, 'gana.municipio'),
          _campo(_provincia, 'gana.provincia'),
          CampoPunto(
            titulo: SoleraL10n.t('gana.coordenadas_explotacion'),
            latitud: _explotacion.latitud,
            longitud: _explotacion.longitud,
            paqueteApp: paqueteAppGanadera,
            alCambiar: _cambiarUbicacion,
          ),
          _campo(_clasificacion, 'gana.clasificacion'),
          _campo(_capacidad, 'gana.capacidad_maxima',
              teclado: TextInputType.number),
          const SizedBox(height: 8),
          Text(SoleraL10n.t('gana.especies_autorizadas'),
              style: estilos.bodySmall),
          Wrap(
            spacing: 6,
            children: [
              for (final especie in especiesGanado)
                FilterChip(
                  label: Text(nombreEspecie(especie)),
                  selected: _especies.contains(especie),
                  onSelected: (elegida) => setState(() {
                    elegida
                        ? _especies.add(especie)
                        : _especies.remove(especie);
                  }),
                ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
              onPressed: _guardar, child: Text(SoleraL10n.t('guardar'))),
        ],
      ),
    );
  }
}
