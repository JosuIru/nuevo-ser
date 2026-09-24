import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../datos/base_datos.dart';
import '../modelos/campania.dart';
import '../modelos/olivar.dart';
import '../modelos/titular.dart';
import 'pantalla_clave_anthropic.dart';
import 'pantalla_configuracion_fiscal.dart';
import 'pantalla_cuaderno_pac.dart';
import 'pantalla_libro_economico.dart';
import 'pantalla_terceros.dart';

/// Ajustes: datos del titular, del olivar y gestión de campañas.
/// Pantalla mínima en F1-A3 — F1-A8 añadirá secciones de IA, backup y
/// branding.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_titular != null) ...[
            const Text('Titular',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            Card(
              child: ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF5C6B3A)),
                title: Text(_titular!.razonSocial.isEmpty
                    ? '(sin razón social)'
                    : _titular!.razonSocial),
                subtitle: Text('NIF: ${_titular!.nif}'),
              ),
            ),
          ],
          if (_olivar != null) ...[
            const SizedBox(height: 16),
            const Text('Olivar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            Card(
              child: ListTile(
                leading: const Icon(Icons.eco, color: Color(0xFF5C6B3A)),
                title: Text(_olivar!.nombre.isEmpty
                    ? '(sin nombre)'
                    : _olivar!.nombre),
                subtitle: Text(
                  [_olivar!.municipio, _olivar!.provincia]
                      .where((s) => s.isNotEmpty)
                      .join(' · '),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Campañas',
                  style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.add),
                label: const Text('Nueva campaña'),
                onPressed: _abrirNuevaCampania,
              ),
            ],
          ),
          if (_campanias.isEmpty)
            const Card(
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
                  child: ListTile(
                    leading: Icon(
                      c.estaAbierta
                          ? Icons.local_fire_department
                          : Icons.history,
                      color: c.estaAbierta
                          ? const Color(0xFF5C6B3A)
                          : Colors.grey,
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
          const SizedBox(height: 24),
          const Text('Informes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Card(
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf,
                  color: Color(0xFF5C6B3A)),
              title: const Text('Cuaderno PAC olivar'),
              subtitle: const Text(
                'Genera el PDF del Cuaderno de Explotación PAC '
                '(RD 1311/2012) · sello PROVISIONAL',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PantallaCuadernoPac(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Libro económico',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Card(
            child: ListTile(
              leading: const Icon(Icons.book,
                  color: Color(0xFF5C6B3A)),
              title: const Text('Libro económico anual'),
              subtitle: const Text(
                'Ingresos / gastos / resumen + extracto PDF · PROVISIONAL',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PantallaLibroEconomico(),
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance,
                  color: Color(0xFF5C6B3A)),
              title: const Text('Configuración fiscal'),
              subtitle: const Text('Régimen IRPF + IVA + año fiscal activo'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PantallaConfiguracionFiscal(),
                ),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.people_outline,
                  color: Color(0xFF5C6B3A)),
              title: const Text('Terceros (clientes / proveedores)'),
              subtitle: const Text(
                'Datos fiscales para asociar a apuntes y al modelo 347',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PantallaTerceros(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Inteligencia artificial',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Card(
            child: ListTile(
              leading: const Icon(Icons.auto_awesome,
                  color: Color(0xFF5C6B3A)),
              title: const Text('Clave Anthropic (BYO key)'),
              subtitle: const Text(
                'Identificación visual de plagas y variedades con Claude '
                '(local — la clave no sale del dispositivo)',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PantallaClaveAnthropic(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Aplicación',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          Card(
            child: ListTile(
              leading: const Icon(Icons.system_update,
                  color: Color(0xFF5C6B3A)),
              title: const Text('Actualizaciones'),
              subtitle: const Text('Versión instalada y última publicada'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PantallaEstadoActualizaciones(
                    config: configActualizacionesMonorepo('solera-aceitera'),
                    nombreApp: 'Solera Aceitera',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
