import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart';

import '../nucleo/actualizaciones_las_versiones.dart';
import '../nucleo/paleta_archivo.dart';
import 'pantalla_creditos.dart';
import 'pantalla_instrucciones.dart';

/// Menú principal del juego — la única superficie de meta-navegación
/// del esqueleto. Sustituye los tres botones sueltos previos
/// (CUADERNO / SESIÓN / AJUSTES) por un engranaje único que abre esta
/// pantalla con todas las acciones agrupadas por bloques.
///
/// Tres bloques visibles:
/// - **MI ARCHIVO** — Cuaderno, Avances, Resúmenes (Mosaicos
///   entregados). Lo que la Cronista ha producido.
/// - **MI CUENTA** — sesión del adulto acompañante e idioma. Lo que
///   define el contexto del dispositivo.
/// - **AYUDA Y AJUSTES** — Instrucciones, Créditos, Resetear y
///   Salir. Lo meta.
class PantallaMenu extends StatelessWidget {
  /// Abre el Cuaderno con las entradas registradas.
  final VoidCallback alAbrirCuaderno;

  /// Abre la pantalla de avances/progreso del juego.
  final VoidCallback alAbrirAvances;

  /// Abre la pantalla con los Mosaicos entregados.
  final VoidCallback alAbrirResumenes;

  /// Abre el ático de Andrés. `null` mientras no haya ninguna Brecha
  /// cerrada: la fila no aparece (no hay candado ni «próximamente»).
  final VoidCallback? alAbrirAtico;

  /// Abre la pantalla de cuenta / login del adulto acompañante.
  final VoidCallback alAbrirCuenta;

  /// Abre la pantalla de gestión de perfiles (multi-Cronista).
  final VoidCallback alAbrirPerfiles;

  /// Nombre visible del perfil activo, para mostrar en el subtítulo
  /// de la fila "Cambiar perfil". `null` si todavía no se cargó.
  final String? nombrePerfilActivo;

  /// `true` si ya hay sesión iniciada (token JWT presente). Se usa
  /// para etiquetar la fila de cuenta.
  final bool sesionIniciada;

  /// Cambia el idioma de la app a [codigo] (`'es'`, `'eu'` o `'ca'`).
  final ValueChanged<String> alCambiarIdioma;

  /// Código de idioma actualmente activo, para resaltar en el diálogo
  /// de idioma. Si es `null` no se resalta ninguno.
  final String? idiomaActivo;

  /// Abre la pantalla de ajustes de audio (modo silencio + volumen
  /// por capa).
  final VoidCallback alAbrirAjustesAudio;

  /// `true` si las cinemáticas se ven en versión corta (por defecto).
  final bool escenasCortas;

  /// Cambia entre escenas cortas y enteras. `null` oculta la fila.
  final ValueChanged<bool>? alCambiarEscenasCortas;

  /// Confirma y ejecuta el reset total del Archivo. La pantalla
  /// muestra el diálogo de confirmación; el callback hace el borrado
  /// real y cierra la pantalla a la configuración inicial.
  final Future<void> Function() alResetearArchivo;

  const PantallaMenu({
    super.key,
    required this.alAbrirCuaderno,
    required this.alAbrirAvances,
    required this.alAbrirResumenes,
    this.alAbrirAtico,
    required this.alAbrirCuenta,
    required this.alAbrirPerfiles,
    required this.nombrePerfilActivo,
    required this.sesionIniciada,
    required this.alCambiarIdioma,
    required this.idiomaActivo,
    required this.alAbrirAjustesAudio,
    required this.alResetearArchivo,
    this.escenasCortas = true,
    this.alCambiarEscenasCortas,
  });

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      backgroundColor: PaletaArchivo.fondoProfundo,
      appBar: AppBar(
        backgroundColor: PaletaArchivo.fondoProfundo,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: PaletaArchivo.textoPrincipal,
          onPressed: () => Navigator.of(contexto).maybePop(),
        ),
        title: Text(
          'MENÚ',
          style: TextStyle(
            fontSize: 13,
            letterSpacing: 5,
            color: PaletaArchivo.textoPrincipal,
            fontWeight: FontWeight.w400,
            shadows: [
              Shadow(
                color: PaletaArchivo.ambarLacre.withOpacity(0.35),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            // Aviso de versión nueva: sólo ocupa sitio si la hay.
            AvisoActualizaciones(
              config: configActualizacionesLasVersiones,
              nombreApp: nombreAppLasVersiones,
              margen: const EdgeInsets.only(bottom: 12),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Image.asset(
                'assets/marca/las_versiones_logo.png',
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
            const _Encabezado(texto: 'MI ARCHIVO'),
            _FilaMenu(
              icono: Icons.menu_book_outlined,
              titulo: 'Cuaderno',
              subtitulo:
                  'Entradas que la Cronista ha ido anotando entre Brechas.',
              alPulsar: alAbrirCuaderno,
            ),
            _FilaMenu(
              icono: Icons.timeline_outlined,
              titulo: 'Avances',
              subtitulo:
                  'Cómo va el oficio: arcos cerrados, Brechas trabajadas, '
                  'entradas del Cuaderno.',
              alPulsar: alAbrirAvances,
            ),
            _FilaMenu(
              icono: Icons.collections_bookmark_outlined,
              titulo: 'Resúmenes',
              subtitulo:
                  'Mosaicos de fin de arco que la Cronista ha entregado.',
              alPulsar: alAbrirResumenes,
            ),
            if (alAbrirAtico != null)
              _FilaMenu(
                icono: Icons.scale_outlined,
                titulo: 'El ático',
                subtitulo:
                    'Andrés guarda arriba lo ya investigado. Para repasar '
                    'el oficio con calma.',
                alPulsar: alAbrirAtico!,
              ),
            const SizedBox(height: 18),
            const _Encabezado(texto: 'MI CUENTA'),
            _FilaMenu(
              icono: Icons.people_alt_outlined,
              titulo: 'Cambiar perfil',
              subtitulo: nombrePerfilActivo == null
                  ? 'Cada Cronista del dispositivo tiene su propio Archivo.'
                  : 'Activo: $nombrePerfilActivo. Pulsa para cambiar.',
              alPulsar: alAbrirPerfiles,
            ),
            _FilaMenu(
              icono: sesionIniciada
                  ? Icons.lock_outlined
                  : Icons.lock_open_outlined,
              titulo: sesionIniciada ? 'Sesión iniciada' : 'Iniciar sesión',
              subtitulo:
                  'Cuenta del adulto acompañante. Sólo se usa para '
                  'enviar los Mosaicos al servidor familiar.',
              alPulsar: alAbrirCuenta,
            ),
            _FilaMenu(
              icono: Icons.language_outlined,
              titulo: 'Idioma',
              subtitulo: _subtituloIdioma(idiomaActivo),
              alPulsar: () => _abrirDialogoIdioma(contexto),
            ),
            const SizedBox(height: 18),
            const _Encabezado(texto: 'AYUDA Y AJUSTES'),
            _FilaMenu(
              icono: Icons.help_outline,
              titulo: 'Instrucciones',
              subtitulo:
                  'Cómo se juega — para Cronistas y para padres y '
                  'maestros.',
              alPulsar: () => Navigator.of(contexto).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PantallaInstrucciones(),
                ),
              ),
            ),
            if (alCambiarEscenasCortas != null)
              _FilaInterruptor(
                icono: Icons.short_text,
                titulo: 'Escenas cortas',
                subtitulo: 'La historia en pocas líneas para llegar antes a '
                    'jugar. Cada escena se puede ver entera con un toque.',
                valorInicial: escenasCortas,
                alCambiar: alCambiarEscenasCortas!,
              ),
            _FilaMenu(
              icono: Icons.volume_up_outlined,
              titulo: 'Audio',
              subtitulo:
                  'Modo silencio y volumen por capa (ambiente, música, '
                  'efectos, narrativos).',
              alPulsar: alAbrirAjustesAudio,
            ),
            _FilaMenu(
              icono: Icons.system_update,
              titulo: 'Actualizaciones',
              subtitulo:
                  'Versión instalada y, si la hay, la nueva para '
                  'descargar e instalar.',
              alPulsar: () => Navigator.of(contexto).push(
                MaterialPageRoute<void>(
                  builder: (_) => PantallaEstadoActualizaciones(
                    config: configActualizacionesLasVersiones,
                    nombreApp: nombreAppLasVersiones,
                  ),
                ),
              ),
            ),
            _FilaMenu(
              icono: Icons.image_outlined,
              titulo: 'Créditos',
              subtitulo:
                  'Atribución de las imágenes de fondo cedidas con '
                  'licencia libre.',
              alPulsar: () => Navigator.of(contexto).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PantallaCreditos(),
                ),
              ),
            ),
            _FilaMenu(
              icono: Icons.delete_sweep_outlined,
              titulo: 'Resetear Archivo',
              subtitulo:
                  'Borra todo el progreso y vuelve al primer arranque. '
                  'No hay vuelta atrás.',
              colorEnfasis: PaletaArchivo.ambarLacre,
              alPulsar: () => _confirmarReseteo(contexto),
            ),
            _FilaMenu(
              icono: Icons.exit_to_app_outlined,
              titulo: 'Salir',
              subtitulo:
                  'Cierra la app. El progreso queda guardado — al '
                  'volver, la Cronista sigue donde lo dejó.',
              alPulsar: _salirDeLaApp,
            ),
          ],
        ),
      ),
    );
  }

  static String _subtituloIdioma(String? codigo) {
    switch (codigo) {
      case 'es':
        return 'Castellano. Pulsa para cambiar.';
      case 'eu':
        return 'Euskara. Pulsa para cambiar.';
      case 'ca':
        return 'Català. Pulsa para cambiar.';
    }
    return 'Idioma de la app. Pulsa para cambiar.';
  }

  Future<void> _abrirDialogoIdioma(BuildContext contexto) async {
    final codigo = await showDialog<String>(
      context: contexto,
      barrierDismissible: true,
      builder: (ctxDialogo) {
        return AlertDialog(
          backgroundColor: PaletaArchivo.fondoProfundo,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          title: const Text(
            'Idioma de la app',
            style: TextStyle(
              fontSize: 16,
              color: PaletaArchivo.textoPrincipal,
              letterSpacing: 0.5,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'El contenido narrativo largo de hoy está en castellano. '
                'Cuando la traducción humana revisada de euskera y catalán '
                'esté lista, el cambio aquí afectará también a las '
                'cinemáticas y Brechas.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: PaletaArchivo.textoTenue,
                ),
              ),
              const SizedBox(height: 16),
              _BotonIdiomaDialogo(
                etiqueta: 'Castellano',
                codigo: 'es',
                activo: idiomaActivo == 'es',
              ),
              const SizedBox(height: 8),
              _BotonIdiomaDialogo(
                etiqueta: 'Euskara',
                codigo: 'eu',
                activo: idiomaActivo == 'eu',
              ),
              const SizedBox(height: 8),
              _BotonIdiomaDialogo(
                etiqueta: 'Català',
                codigo: 'ca',
                activo: idiomaActivo == 'ca',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctxDialogo).pop(null),
              child: const Text(
                'CANCELAR',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 3,
                  color: PaletaArchivo.textoTenue,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (codigo == null) return;
    alCambiarIdioma(codigo);
  }

  Future<void> _confirmarReseteo(BuildContext contexto) async {
    final confirmado = await showDialog<bool>(
      context: contexto,
      barrierDismissible: true,
      builder: (ctxDialogo) {
        return AlertDialog(
          backgroundColor: PaletaArchivo.fondoProfundo,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          title: const Text(
            '¿Resetear el Archivo?',
            style: TextStyle(
              fontSize: 16,
              color: PaletaArchivo.textoPrincipal,
              letterSpacing: 0.5,
            ),
          ),
          content: const Text(
            'Se borrará todo el progreso de esta Cronista. La acción '
            'no se puede deshacer.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: PaletaArchivo.textoPrincipal,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctxDialogo).pop(false),
              child: const Text(
                'CANCELAR',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 3,
                  color: PaletaArchivo.textoTenue,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctxDialogo).pop(true),
              child: const Text(
                'SÍ, RESETEAR',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 3,
                  color: PaletaArchivo.ambarLacre,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirmado != true) return;
    await alResetearArchivo();
    if (!contexto.mounted) return;
    Navigator.of(contexto).maybePop();
  }

  void _salirDeLaApp() {
    SystemNavigator.pop();
  }
}

class _Encabezado extends StatelessWidget {
  final String texto;
  const _Encabezado({required this.texto});

  @override
  Widget build(BuildContext contexto) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 4,
          color: PaletaArchivo.textoTenue.withOpacity(0.85),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Fila del menú con interruptor. Guarda el valor en local para que el
/// cambio se vea al momento sin reconstruir la pantalla entera.
class _FilaInterruptor extends StatefulWidget {
  const _FilaInterruptor({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.valorInicial,
    required this.alCambiar,
  });

  final IconData icono;
  final String titulo;
  final String subtitulo;
  final bool valorInicial;
  final ValueChanged<bool> alCambiar;

  @override
  State<_FilaInterruptor> createState() => _EstadoFilaInterruptor();
}

class _EstadoFilaInterruptor extends State<_FilaInterruptor> {
  late bool _valor = widget.valorInicial;

  void _cambiar(bool nuevo) {
    setState(() => _valor = nuevo);
    widget.alCambiar(nuevo);
  }

  @override
  Widget build(BuildContext contexto) {
    return Semantics(
      toggled: _valor,
      label: widget.titulo,
      child: InkWell(
        onTap: () => _cambiar(!_valor),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: PaletaArchivo.tintaTenue.withValues(alpha: 0.35),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(widget.icono, color: PaletaArchivo.ambarLacre, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.titulo,
                      style: const TextStyle(
                        fontSize: 15,
                        color: PaletaArchivo.textoPrincipal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitulo,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: PaletaArchivo.textoTenue.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _valor,
                activeThumbColor: PaletaArchivo.ambarLacre,
                onChanged: _cambiar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilaMenu extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback alPulsar;
  final Color? colorEnfasis;

  const _FilaMenu({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.alPulsar,
    this.colorEnfasis,
  });

  @override
  Widget build(BuildContext contexto) {
    final colorTitulo = colorEnfasis ?? PaletaArchivo.textoPrincipal;
    return InkWell(
      onTap: alPulsar,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: PaletaArchivo.tintaTenue.withOpacity(0.35),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icono, color: PaletaArchivo.ambarLacre, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontSize: 15,
                      color: colorTitulo,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitulo,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: PaletaArchivo.textoTenue.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: PaletaArchivo.textoTenue.withOpacity(0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonIdiomaDialogo extends StatelessWidget {
  final String etiqueta;
  final String codigo;
  final bool activo;

  const _BotonIdiomaDialogo({
    required this.etiqueta,
    required this.codigo,
    required this.activo,
  });

  @override
  Widget build(BuildContext contexto) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.of(contexto).pop(codigo),
        style: OutlinedButton.styleFrom(
          backgroundColor: activo
              ? PaletaArchivo.ambarLacre.withOpacity(0.18)
              : Colors.transparent,
          side: BorderSide(
            color: activo
                ? PaletaArchivo.ambarLacre
                : PaletaArchivo.tintaTenue.withOpacity(0.7),
            width: activo ? 1.4 : 1.0,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
        ),
        child: Text(
          etiqueta,
          style: TextStyle(
            fontSize: 14,
            letterSpacing: 1,
            color: PaletaArchivo.textoPrincipal,
            fontWeight: activo ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
