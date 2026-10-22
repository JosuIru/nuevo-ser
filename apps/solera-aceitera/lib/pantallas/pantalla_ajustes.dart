import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../estado/clave_anthropic_aceitera.dart';
import '../modelos/olivar.dart';
import '../modelos/titular.dart';
import 'pantalla_acerca.dart';
import 'pantalla_configuracion_fiscal.dart';
import 'pantalla_copia_seguridad.dart';
import 'pantalla_terceros.dart';

/// Ajustes por secciones: Explotación (titular, olivar, fiscal, terceros) ·
/// Inteligencia artificial · Preferencias (idioma) · Datos (copia de
/// seguridad) · Aplicación (actualizaciones, acerca de). Los libros y
/// registros (cuaderno PAC, libro económico, campañas, libro del aceite)
/// están en la pestaña Registros.
class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  Titular? _titular;
  Olivar? _olivar;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final bd = BaseDatosSoleraAceitera();
    final t = await bd.obtenerTitular();
    final o = await bd.obtenerOlivar();
    if (!mounted) return;
    setState(() {
      _titular = t;
      _olivar = o;
    });
  }

  static const _colorIconos = Color(0xFF5C6B3A);
  static const _margenTarjetas = EdgeInsets.symmetric(horizontal: 16, vertical: 4);

  Widget _entradaQueAbre({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required WidgetBuilder construirPantalla,
  }) {
    return Card(
      margin: _margenTarjetas,
      child: ListTile(
        leading: Icon(icono, color: _colorIconos),
        title: Text(titulo),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.of(context)
              .push(MaterialPageRoute(builder: construirPantalla));
          if (mounted) await _cargar();
        },
      ),
    );
  }

  List<Widget> _seccionExplotacion() => [
        CabeceraSeccionAjustes(SoleraL10n.t('seccion_explotacion')),
        if (_titular != null)
          Card(
            margin: _margenTarjetas,
            child: ListTile(
              leading: const Icon(Icons.person, color: _colorIconos),
              title: Text(_titular!.razonSocial.isEmpty
                  ? '(sin razón social)'
                  : _titular!.razonSocial),
              subtitle: Text('Titular · NIF: ${_titular!.nif}'),
            ),
          ),
        if (_olivar != null)
          Card(
            margin: _margenTarjetas,
            child: ListTile(
              leading: const Icon(Icons.eco, color: _colorIconos),
              title: Text(
                  _olivar!.nombre.isEmpty ? '(sin nombre)' : _olivar!.nombre),
              subtitle: Text(
                [
                  'Olivar',
                  _olivar!.municipio,
                  _olivar!.provincia,
                ].where((s) => s.isNotEmpty).join(' · '),
              ),
            ),
          ),
        _entradaQueAbre(
          icono: Icons.account_balance,
          titulo: 'Configuración fiscal',
          subtitulo: 'Régimen IRPF + IVA + año fiscal activo',
          construirPantalla: (_) => const PantallaConfiguracionFiscal(),
        ),
        _entradaQueAbre(
          icono: Icons.people_outline,
          titulo: 'Terceros (clientes / proveedores)',
          subtitulo: 'Datos fiscales para asociar a apuntes y al modelo 347',
          construirPantalla: (_) => const PantallaTerceros(),
        ),
      ];

  List<Widget> _seccionInteligenciaArtificial() => [
        CabeceraSeccionAjustes(SoleraL10n.t('seccion_integraciones')),
        _entradaQueAbre(
          icono: Icons.auto_awesome,
          titulo: SoleraL10n.t('identificacion_con_ia'),
          subtitulo: 'Plagas y variedades por foto con Claude · clave '
              'Anthropic propia, guardada sólo en el dispositivo',
          construirPantalla: (_) => construirPantallaClaveAnthropicAceitera(),
        ),
      ];

  List<Widget> _seccionPreferencias() => [
        CabeceraSeccionAjustes(SoleraL10n.t('seccion_preferencias')),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SelectorIdioma(onCambio: () => setState(() {})),
          ),
        ),
      ];

  List<Widget> _seccionDatos() => [
        CabeceraSeccionAjustes(SoleraL10n.t('seccion_datos')),
        _entradaQueAbre(
          icono: Icons.backup_outlined,
          titulo: SoleraL10n.t('copia_de_seguridad'),
          subtitulo: 'Guardar todos los datos en un ZIP o restaurar uno',
          construirPantalla: (_) => const PantallaCopiaSeguridad(),
        ),
      ];

  List<Widget> _seccionAplicacion() => [
        CabeceraSeccionAjustes(SoleraL10n.t('seccion_aplicacion')),
        _entradaQueAbre(
          icono: Icons.system_update,
          titulo: SoleraL10n.t('comprobar_actualizaciones'),
          subtitulo: 'Versión instalada y última publicada',
          construirPantalla: (_) => PantallaEstadoActualizaciones(
            config: configActualizacionesMonorepo('solera-aceitera'),
            nombreApp: 'Solera Aceitera',
          ),
        ),
        _entradaQueAbre(
          icono: Icons.info_outline,
          titulo: SoleraL10n.t('acerca_de'),
          subtitulo: 'Qué es Solera Aceitera, compromisos y catálogos',
          construirPantalla: (_) => const PantallaAcerca(),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ajustes'))),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ..._seccionExplotacion(),
          ..._seccionInteligenciaArtificial(),
          ..._seccionPreferencias(),
          ..._seccionDatos(),
          ..._seccionAplicacion(),
        ],
      ),
    );
  }
}
