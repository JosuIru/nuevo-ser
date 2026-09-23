import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../datos/catalogo_habilidades.dart';
import '../dominio/catalogo_distritos.dart';
import '../dominio/progreso_arco.dart';
import '../l10n/traducciones_narrativa.dart';
import '../nucleo/paleta.dart';

/// Pantalla "Acerca de Uno Roto". Página estática (fuera de
/// gameplay) que explica qué es el juego, qué hay dentro y bajo qué
/// licencia se distribuye. Es accesible desde el menú overflow de
/// `pantalla_habilidades` y desde el botón "Más opciones".
///
/// Los números (habilidades, distritos, escenas) se calculan en
/// tiempo de ejecución contra los catálogos para que no se queden
/// desactualizados al añadir contenido.
class PantallaAcercaDe extends StatefulWidget {
  const PantallaAcercaDe({super.key});

  @override
  State<PantallaAcercaDe> createState() => _PantallaAcercaDeState();
}

class _PantallaAcercaDeState extends State<PantallaAcercaDe> {
  int? _totalHabilidades;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final catalogo = await CatalogoHabilidades.cargar();
    if (!mounted) return;
    setState(() => _totalHabilidades = catalogo.habilidades.length);
  }

  int get _totalEscenas => ProgresoArco.todos.fold<int>(
        0,
        (acumulado, arco) => acumulado + arco.totalEscenas,
      );

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Scaffold(
      backgroundColor: PaletaNeon.fondoProfundo,
      appBar: AppBar(
        backgroundColor: PaletaNeon.fondoMedio,
        iconTheme: const IconThemeData(color: PaletaNeon.textoTenue),
        title: Text(
          traducirNarrativa('ACERCA DE', locale),
          style: const TextStyle(
            color: PaletaNeon.textoPrincipal,
            fontSize: 14,
            letterSpacing: 4,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: PaletaNeon.fondoCiudad),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          children: [
            const _Hero(),
            const SizedBox(height: 28),
            const _Seccion(
              titulo: 'EL JUEGO',
              cuerpo:
                  'Uno Roto es un juego de matemáticas para niños y niñas '
                  '9–12. Las matemáticas son el mundo en el que se mueven '
                  '— no un peaje para llegar a la diversión. Cada combate '
                  'es un puzzle de fracciones, decimales o proporciones; '
                  'cada Fragmento atrapado restaura un trozo de ciudad.\n\n'
                  'Sin puntos, sin ranking, sin "ganar". El progreso se '
                  'mide en habilidades dominadas y en piezas de ciudad '
                  'recuperadas.',
            ),
            _Seccion(
              titulo: 'LAS MATEMÁTICAS',
              cuerpo:
                  '${_totalHabilidades ?? 66} habilidades repartidas en 8 '
                  'dominios: fracciones, decimales, proporciones, '
                  'divisibilidad, operaciones, medida, geometría y '
                  'estadística. Un motor adaptativo elige la siguiente '
                  'según el ritmo del niño — los aciertos consolidan, los '
                  'fallos no penalizan.',
            ),
            _Seccion(
              titulo: 'LA CIUDAD',
              cuerpo:
                  '${CatalogoDistritos.todos.length} distritos para '
                  'recorrer y La Montaña al horizonte. Cada distrito '
                  'tiene su atmósfera (Tejados, Canales, Mercado, '
                  'Industria, Puerto, Afueras) y se desbloquea al ir '
                  'recolectando esquirlas.',
            ),
            _Seccion(
              titulo: 'LA HISTORIA',
              cuerpo:
                  '${ProgresoArco.todos.length} arcos narrativos con '
                  '$_totalEscenas escenas cinemáticas en total. Sora '
                  'guía el camino, los Fragmentos nombrados (Kurz, '
                  'Zafrán, Vorax) ponen los obstáculos, y Eco aparece '
                  'cuando el niño se atasca y necesita una mano.',
            ),
            const _Seccion(
              titulo: 'LOS PERSONAJES',
              cuerpo:
                  '**Sora** — la guía. Voz seca, sin adornos.\n'
                  '**Kurz** — el primer Fragmento que habla. Murmura.\n'
                  '**Eco** — el tutor IA, voz poética, llega por '
                  'silencio.\n'
                  '**Kai** — va dos rangos por delante. Modelo a '
                  'seguir.\n'
                  '**Irune** — la guardiana de las tres reglas.\n'
                  '**Tana, Niko, Brina, Rexán, Ari** — vecinos.\n'
                  '**Zafrán, Vadic, Vorax** — los Fragmentos mayores.\n'
                  '**La Montaña** — el horizonte. Espera.',
            ),
            const _Seccion(
              titulo: 'IDIOMAS',
              cuerpo:
                  'Castellano, euskera y catalán desde el primer '
                  'arranque. La traducción inicial es automática — la '
                  'voz de cada personaje aún está en revisión humana.',
            ),
            const _Seccion(
              titulo: 'LICENCIA',
              cuerpo:
                  'Código AGPL-3.0. Contenido (textos, arte, sonido) '
                  'CC-BY-SA 4.0. Sin tracking, sin anuncios, sin '
                  'monetización. Privacidad por diseño.',
            ),
            const _Seccion(
              titulo: 'TUTOR IA',
              cuerpo:
                  'Cuando el niño falla tres veces seguidas y el '
                  'Fragmento se le escapa, aparece la opción de hablar '
                  'con Eco. Las preguntas se filtran (sin emails, sin '
                  'texto fuera del alcance del juego) y la respuesta '
                  'usa Claude Haiku 4.5 con voz cariñosa, metáforas y '
                  'sin dar la solución directa.',
            ),
            const SizedBox(height: 8),
            const _BotonCompartir(),
            const SizedBox(height: 16),
            Text(
              traducirNarrativa('hasta mañana', locale),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'CormorantGaramond',
                fontStyle: FontStyle.italic,
                fontSize: 16,
                color: PaletaNeon.textoTenue.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Uno Roto',
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontStyle: FontStyle.italic,
            fontSize: 36,
            color: PaletaNeon.textoPrincipal,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          traducirNarrativa(
            'Las matemáticas son el mundo, no un peaje.',
            locale,
          ),
          style: TextStyle(
            fontFamily: 'CormorantGaramond',
            fontStyle: FontStyle.italic,
            fontSize: 16,
            color: PaletaNeon.violetaNeon.withOpacity(0.85),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(
              color: PaletaNeon.violetaBase.withOpacity(0.6),
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'v0.5 · pre-MVP',
            style: TextStyle(
              color: PaletaNeon.textoTenue,
              fontSize: 11,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final String cuerpo;

  const _Seccion({required this.titulo, required this.cuerpo});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            traducirNarrativa(titulo, locale),
            style: TextStyle(
              color: PaletaNeon.azulNeon.withOpacity(0.85),
              fontSize: 11,
              letterSpacing: 3,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _CuerpoConNegrita(texto: cuerpo),
        ],
      ),
    );
  }
}

/// Renderiza un texto con `**negrita**` simple. Acepta múltiples
/// pares — útil para listas de personajes con su nombre destacado.
class _CuerpoConNegrita extends StatelessWidget {
  final String texto;

  const _CuerpoConNegrita({required this.texto});

  @override
  Widget build(BuildContext context) {
    final partes = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    var indice = 0;
    for (final match in regex.allMatches(texto)) {
      if (match.start > indice) {
        partes.add(TextSpan(text: texto.substring(indice, match.start)));
      }
      partes.add(
        TextSpan(
          text: match.group(1),
          style: const TextStyle(
            color: PaletaNeon.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
      indice = match.end;
    }
    if (indice < texto.length) {
      partes.add(TextSpan(text: texto.substring(indice)));
    }
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 14,
          color: PaletaNeon.textoTenue.withOpacity(0.85),
          height: 1.55,
        ),
        children: partes,
      ),
    );
  }
}

/// Botón "COMPARTIR" que abre el share sheet del sistema con el
/// enlace estable a la última versión publicada en GitHub Releases.
/// Pensado para que el adulto pase el APK a otra familia por
/// mensajería sin tener que buscar la URL a mano.
class _BotonCompartir extends StatelessWidget {
  const _BotonCompartir();

  /// Enlace estable que SIEMPRE apunta al último release publicado.
  /// El operador puede subir nuevas releases sin que esta URL cambie
  /// — la app no necesita actualizarse para seguir compartiendo la
  /// última.
  static const String _urlReleaseLatest =
      'https://github.com/JosuIru/nuevo-ser/releases/latest';

  static const String _textoCompartir =
      'Uno Roto — juego de matemáticas para 9-12 años. '
      'Sin tracking, sin anuncios, sin compras. '
      'Descarga el APK desde: $_urlReleaseLatest';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton.tonalIcon(
        onPressed: () => Share.share(
          _textoCompartir,
          subject: 'Uno Roto — juego de matemáticas para niños 9-12',
        ),
        icon: const Icon(Icons.share_outlined, size: 18),
        label: const Text(
          'COMPARTIR',
          style: TextStyle(letterSpacing: 2, fontSize: 12),
        ),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          backgroundColor: PaletaNeon.violetaNeon.withOpacity(0.4),
          foregroundColor: PaletaNeon.textoPrincipal,
        ),
      ),
    );
  }
}
