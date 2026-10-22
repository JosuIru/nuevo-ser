import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/campania.dart';
import '../modelos/olivar.dart';
import '../modelos/titular.dart';
import 'pantalla_acerca.dart';
import 'pantalla_clave_anthropic.dart';
import 'pantalla_configuracion_fiscal.dart';
import 'pantalla_cuaderno_pac.dart';
import 'pantalla_libro_economico.dart';
import 'pantalla_terceros.dart';

/// Ajustes por secciones: Explotación (titular, olivar, fiscal, terceros) ·
/// Registros y documentos (cuaderno PAC, libro económico, campañas) ·
/// Inteligencia artificial · Preferencias (idioma) · Aplicación
/// (actualizaciones, acerca de). Sin copia de seguridad: la app aún no
/// tiene servicio de backup (pendiente, ver CLAUDE.md).
class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  final _formatoFecha = DateFormat('d/M/yyyy', 'es_ES');
  Titular? _titular;
  Olivar? _olivar;
  List<Campania> _campanias = const [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final bd = BaseDatosSoleraAceitera();
    final t = await bd.obtenerTitular();
    final o = await bd.obtenerOlivar();
    final cs = await bd.listarCampanias();
    if (!mounted) return;
    setState(() {
      _titular = t;
      _olivar = o;
      _campanias = cs;
    });
  }

  Future<void> _abrirNuevaCampania() async {
    final olivar = _olivar;
    if (olivar?.id == null) return;
    final anyo = DateTime.now().year;
    await BaseDatosSoleraAceitera().insertarCampania(Campania(
      olivarId: olivar!.id!,
      anyoComercial: anyo,
      fechaInicioMs: DateTime.now().millisecondsSinceEpoch,
    ));
    await _cargar();
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

  List<Widget> _seccionRegistros() => [
        CabeceraSeccionAjustes(SoleraL10n.t('seccion_registros')),
        _entradaQueAbre(
          icono: Icons.picture_as_pdf,
          titulo: 'Cuaderno PAC olivar',
          subtitulo: 'Genera el PDF del Cuaderno de Explotación PAC '
              '(RD 1311/2012) · sello PROVISIONAL',
          construirPantalla: (_) => const PantallaCuadernoPac(),
        ),
        _entradaQueAbre(
          icono: Icons.book,
          titulo: 'Libro económico anual',
          subtitulo:
              'Ingresos / gastos / resumen + extracto PDF · PROVISIONAL',
          construirPantalla: (_) => const PantallaLibroEconomico(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Campañas de recolección',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.add),
                label: const Text('Nueva campaña'),
                onPressed: _abrirNuevaCampania,
              ),
            ],
          ),
        ),
        if (_campanias.isEmpty)
          const Card(
            margin: _margenTarjetas,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Todavía no has abierto ninguna campaña.\n'
                'Crea una para empezar a registrar recolecciones, '
                'partidas y molturaciones.',
              ),
            ),
          )
        else
          ..._campanias.map((c) => Card(
                margin: _margenTarjetas,
                child: ListTile(
                  leading: Icon(
                    c.estaAbierta
                        ? Icons.local_fire_department
                        : Icons.history,
                    color: c.estaAbierta ? _colorIconos : Colors.grey,
                  ),
                  title: Text('${c.anyoComercial}/${c.anyoComercial + 1}'),
                  subtitle: Text(
                    'Inicio: ${_formatoFecha.format(DateTime.fromMillisecondsSinceEpoch(c.fechaInicioMs))}',
                  ),
                  trailing: c.estaAbierta
                      ? const Chip(label: Text('Abierta'))
                      : null,
                ),
              )),
      ];

  List<Widget> _seccionInteligenciaArtificial() => [
        CabeceraSeccionAjustes(SoleraL10n.t('seccion_integraciones')),
        _entradaQueAbre(
          icono: Icons.auto_awesome,
          titulo: SoleraL10n.t('identificacion_con_ia'),
          subtitulo: 'Plagas y variedades por foto con Claude · clave '
              'Anthropic propia, guardada sólo en el dispositivo',
          construirPantalla: (_) => const PantallaClaveAnthropic(),
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
          ..._seccionRegistros(),
          ..._seccionInteligenciaArtificial(),
          ..._seccionPreferencias(),
          ..._seccionAplicacion(),
        ],
      ),
    );
  }
}
