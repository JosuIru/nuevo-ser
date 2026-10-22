import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../datos/base_datos.dart';
import '../datos/catalogo_cultivos.dart';
import '../modelos/finca.dart';
import '../utiles/permisos_gps.dart';

/// Onboarding del primer arranque. Cuatro pasos:
/// 1) Bienvenida con qué hace Solera.
/// 2) Selección de cultivos prioritarios (chips multi-selección,
///    opcional — el catálogo está siempre disponible aunque no se
///    seleccione nada).
/// 3) Crear primera finca (opcional — modo "punto suelto" funciona).
/// 4) Pedir permiso GPS y notificaciones.
///
/// El usuario puede saltar cualquier paso. Al completar (o saltar) el
/// flujo queda marcado en SharedPreferences y no se vuelve a mostrar.
class PantallaOnboarding extends StatefulWidget {
  const PantallaOnboarding({super.key});

  static const claveCompletado = 'agro.onboarding.completado';

  static Future<bool> yaCompletado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(claveCompletado) ?? false;
  }

  static Future<void> marcarCompletado() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(claveCompletado, true);
  }

  @override
  State<PantallaOnboarding> createState() => _PantallaOnboardingState();
}

class _PantallaOnboardingState extends State<PantallaOnboarding> {
  final _controladorPagina = PageController();
  final _controladorNombreFinca = TextEditingController();
  int _pagina = 0;
  final Set<String> _cultivosSeleccionados = {};

  @override
  void dispose() {
    _controladorPagina.dispose();
    _controladorNombreFinca.dispose();
    super.dispose();
  }

  Future<void> _terminar() async {
    // Si el usuario tecleó nombre de finca, la creamos.
    final nombre = _controladorNombreFinca.text.trim();
    if (nombre.isNotEmpty) {
      await BaseDatosAgro.instancia.guardarFinca(Finca(
        nombre: nombre,
        colorEntero: 0xFF558B2F,
        fechaCreacionMs: DateTime.now().millisecondsSinceEpoch,
      ));
    }
    await PantallaOnboarding.marcarCompletado();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/');
  }

  Future<void> _saltar() async {
    await PantallaOnboarding.marcarCompletado();
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/');
  }

  void _avanzar() {
    if (_pagina < 3) {
      _controladorPagina.animateToPage(_pagina + 1,
          duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
    } else {
      _terminar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido a Solera'),
        actions: [
          TextButton(onPressed: _saltar, child: const Text('Saltar')),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controladorPagina,
              onPageChanged: (i) => setState(() => _pagina = i),
              children: [
                const _PaginaBienvenida(),
                _PaginaCultivos(seleccionados: _cultivosSeleccionados, alCambiar: () => setState(() {})),
                _PaginaFinca(controlador: _controladorNombreFinca),
                const _PaginaPermisos(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                for (var i = 0; i < 4; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: CircleAvatar(
                      radius: 5,
                      backgroundColor: i == _pagina ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
                    ),
                  ),
                const Spacer(),
                FilledButton.icon(
                  icon: Icon(_pagina == 3 ? Icons.check : Icons.arrow_forward),
                  onPressed: _avanzar,
                  label: Text(_pagina == 3 ? 'Empezar a usar Solera' : 'Siguiente'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginaBienvenida extends StatelessWidget {
  const _PaginaBienvenida();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.eco, size: 80, color: Color(0xFF558B2F)),
          const SizedBox(height: 16),
          Text('Tu cuaderno de campo digital', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          const Text(
            'Solera te ayuda a llevar el control de tus árboles, viñas, truferas, olivar o pistacho.\n\n'
            '· Marca cada planta en el mapa con un punto GPS.\n'
            '· Apunta cosechas, observaciones, plagas y tratamientos.\n'
            '· Consulta una guía con cultivos y plagas frecuentes.\n'
            '· Genera informes en PDF para tu asesor o cooperativa.\n\n'
            'Todo offline en tu móvil. Tus datos no salen sin tu permiso.',
            style: TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _PaginaCultivos extends StatelessWidget {
  final Set<String> seleccionados;
  final VoidCallback alCambiar;
  const _PaginaCultivos({required this.seleccionados, required this.alCambiar});

  @override
  Widget build(BuildContext context) {
    final cultivosVisibles = catalogoCultivos.where((c) => c.id != 'generico').toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('¿Qué cultivas?', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          const Text(
            'Selecciona los cultivos que ya tienes o que vas a plantar. Esto sirve para sugerir variedades y plagas en la pantalla "Hoy". Puedes cambiarlo después.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in cultivosVisibles)
                    FilterChip(
                      avatar: Icon(c.icono, color: c.color, size: 18),
                      label: Text(c.nombreVisible),
                      selected: seleccionados.contains(c.id),
                      onSelected: (sel) {
                        if (sel) {
                          seleccionados.add(c.id);
                        } else {
                          seleccionados.remove(c.id);
                        }
                        alCambiar();
                      },
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

class _PaginaFinca extends StatelessWidget {
  final TextEditingController controlador;
  const _PaginaFinca({required this.controlador});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.agriculture, size: 60, color: Color(0xFF558B2F)),
          const SizedBox(height: 16),
          Text('Tu primera finca', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          const Text(
            'Si quieres agrupar tus plantas en una finca con nombre, escríbelo aquí. Si tienes árboles dispersos sin agrupación clara, déjalo en blanco — funcionarán como puntos sueltos.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controlador,
            decoration: const InputDecoration(
              labelText: 'Nombre de la finca (opcional)',
              hintText: 'Ej: La Solana, Olivar de mi padre, Trufera de Soria',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginaPermisos extends StatefulWidget {
  const _PaginaPermisos();

  @override
  State<_PaginaPermisos> createState() => _PaginaPermisosState();
}

class _PaginaPermisosState extends State<_PaginaPermisos> {
  bool _gpsConcedido = false;
  bool _notificacionesConcedidas = false;

  Future<void> _pedirGps() async {
    final ok = await asegurarPermisoUbicacion();
    if (mounted) setState(() => _gpsConcedido = ok);
  }

  Future<void> _pedirNotificaciones() async {
    final ok = await asegurarPermisoNotificaciones();
    if (mounted) setState(() => _notificacionesConcedidas = ok);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.gps_fixed, size: 60, color: Color(0xFF558B2F)),
          const SizedBox(height: 16),
          Text('Permisos', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          const Text(
            'Solera necesita ubicación para situar tus plantas en el mapa y grabar recorridos GPS de inspección. Las notificaciones permiten mantener viva la grabación cuando bloqueas la pantalla.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.location_on, color: _gpsConcedido ? Colors.green : Colors.grey),
            title: const Text('Ubicación GPS'),
            subtitle: Text(_gpsConcedido ? 'Concedido' : 'Pendiente'),
            trailing: TextButton(
              onPressed: _gpsConcedido ? null : _pedirGps,
              child: const Text('Conceder'),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.notifications, color: _notificacionesConcedidas ? Colors.green : Colors.grey),
            title: const Text('Notificaciones'),
            subtitle: Text(_notificacionesConcedidas ? 'Concedidas' : 'Pendiente (opcional)'),
            trailing: TextButton(
              onPressed: _notificacionesConcedidas ? null : _pedirNotificaciones,
              child: const Text('Conceder'),
            ),
          ),
        ],
      ),
    );
  }
}
