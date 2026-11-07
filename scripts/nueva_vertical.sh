#!/usr/bin/env bash
# Crea una vertical Larrea nueva en apps/solera-<id>/ con la estructura de la
# suite, ya compilando y con tests verdes. Bloque 1 del plan
# (docs/plan-verticales-larrea.md §4).
#
# Uso (desde cualquier sitio):
#   scripts/nueva_vertical.sh <id> "<Nombre visible>" <primario> <crema> <prefijo> <Clase>
# Ejemplo:
#   scripts/nueva_vertical.sh obrador "Larrea Obrador" 8A5A2B F5EFE2 obra Obrador
#
#   <id>       minúsculas y guiones: carpeta apps/solera-<id>, content/<id>
#   <primario> <crema>  colores en hexadecimal sin «#»
#   <prefijo>  prefijo de las claves de traducción (content/solera/traducciones/<id>.csv)
#   <Clase>    sufijo de las clases Dart (BaseDatosSolera<Clase>, colorPrimario<Clase>…)
#
# Lo que genera: pubspec con el stack de la suite y el core, android/ y linux/
# (flutter create), branding, main con Hoy y Ajustes, BD sobre BaseDatosSolera
# con la tabla del titular, permisos de GPS, compilador de catálogos sobre la
# librería común del core, traducciones es/eu/ca/gl (las eu/ca/gl, borrador),
# tests de BD y del sello PROVISIONAL, CLAUDE.md y BLOQUEOS-PENDIENTES.md.
#
# Toca fuera de la app: content/<id>/, content/solera/traducciones/<id>.csv y
# el fichero generado packages/nuevo_ser_core/lib/src/i18n/solera_l10n.dart.
# Si ese generado choca al integrar, se regenera; nunca se fusiona a mano.
set -euo pipefail

if [ $# -ne 6 ]; then
  sed -n '2,20p' "$0"; exit 1
fi
id="$1"; nombre="$2"; primario="$3"; crema="$4"; prefijo="$5"; clase="$6"
[[ "$id" =~ ^[a-z][a-z0-9-]*$ ]] || { echo "id no válido: $id"; exit 1; }
[[ "$primario$crema" =~ ^[0-9A-Fa-f]{12}$ ]] || { echo "colores no válidos"; exit 1; }
[[ "$prefijo" =~ ^[a-z]+$ ]] || { echo "prefijo no válido: $prefijo"; exit 1; }
[[ "$clase" =~ ^[A-Z][A-Za-z]*$ ]] || { echo "clase no válida: $clase"; exit 1; }

raiz="$(cd "$(dirname "$0")/.." && pwd)"
app="solera-$id"
paquete="solera_${id//-/_}"
destino="$raiz/apps/$app"
fecha="$(date +%F)"
export PATH="$HOME/flutter/bin:$PATH"

[ -e "$destino" ] && { echo "Ya existe $destino"; exit 1; }
[ -e "$raiz/content/solera/traducciones/$id.csv" ] && { echo "Ya existen traducciones de $id"; exit 1; }

echo "→ flutter create $paquete"
flutter create --platforms=android,linux --org com.coleccionnuevoser \
  --project-name "$paquete" --description "$nombre" "$destino" >/dev/null
rm -rf "$destino/test" "$destino/lib/main.dart"
mkdir -p "$destino"/lib/{datos/catalogos_generados,modelos,pantallas,servicios,estado,utiles} \
  "$destino"/test/datos "$destino"/tool "$raiz/content/$id"

# ─── pubspec ─────────────────────────────────────────────────────────
cat > "$destino/pubspec.yaml" <<EOF
name: $paquete
description: "$nombre — vertical de la suite Larrea (Colección Nuevo Ser)."
publish_to: 'none'
version: 0.1.0+1

environment:
  sdk: ^3.5.0

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_map: ^7.0.2
  latlong2: ^0.9.1
  geolocator: 12.0.0
  permission_handler: ^11.3.1
  image_picker: ^1.1.2
  path_provider: ^2.1.4
  path: ^1.9.0
  sqflite: ^2.3.3
  shared_preferences: ^2.3.2
  http: ^1.2.2
  share_plus: ^10.0.2
  intl: ^0.19.0
  pdf: ^3.11.1
  printing: ^5.13.4
  nuevo_ser_core:
    path: ../../packages/nuevo_ser_core

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  sqflite_common_ffi: ^2.3.3

flutter:
  uses-material-design: true

  # Letra del tema común Larrea (temaSolera del core). SIL OFL.
  fonts:
    - family: Poppins
      fonts:
        - asset: packages/nuevo_ser_core/fuentes/Poppins-SemiBold.ttf
          weight: 600
    - family: Inter
      fonts:
        - asset: packages/nuevo_ser_core/fuentes/Inter-Regular.ttf
          weight: 400
        - asset: packages/nuevo_ser_core/fuentes/Inter-Medium.ttf
          weight: 500
        - asset: packages/nuevo_ser_core/fuentes/Inter-SemiBold.ttf
          weight: 600
        - asset: packages/nuevo_ser_core/fuentes/Inter-Bold.ttf
          weight: 700
EOF
cp "$raiz/apps/solera-aceitera/analysis_options.yaml" "$destino/"
cp "$raiz/apps/solera-aceitera/lib/utiles/permisos_gps.dart" "$destino/lib/utiles/"
cp "$raiz/apps/solera-aceitera/test/datos/soporte_contrato_base_datos.dart" "$destino/test/datos/"

# ─── branding y main ─────────────────────────────────────────────────
cat > "$destino/lib/branding.dart" <<EOF
import 'package:flutter/material.dart';

/// Paleta de $nombre (patrón de la suite: color principal + crema).
/// PLACEHOLDER hasta el branding definitivo.
const Color colorPrimario$clase = Color(0xFF${primario^^});
const Color colorCrema$clase = Color(0xFF${crema^^});
EOF

cat > "$destino/lib/main.dart" <<EOF
// $nombre — esqueleto generado por scripts/nueva_vertical.sh ($fecha).
//
//   main() → App$clase → PantallaPrincipal (NavigationBar + IndexedStack)
//     ├── Hoy
//     └── Ajustes

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SoleraL10n, cargarIdiomaSolera, PaletaSolera, temaSolera;

import 'branding.dart';
import 'pantallas/pantalla_ajustes.dart';
import 'pantallas/pantalla_hoy.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await cargarIdiomaSolera();
  await initializeDateFormatting();
  runApp(const App$clase());
}

class App$clase extends StatelessWidget {
  const App$clase({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: SoleraL10n.notificador,
      builder: (context, _, __) => MaterialApp(
        title: '$nombre',
        debugShowCheckedModeBanner: false,
        theme: temaSolera(const PaletaSolera(
          primario: colorPrimario$clase,
          crema: colorCrema$clase,
        )),
        home: const PantallaPrincipal(),
      ),
    );
  }
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  int _pestanaActual = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _pestanaActual,
        children: const [PantallaHoy(), PantallaAjustes()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pestanaActual,
        onDestinationSelected: (indice) =>
            setState(() => _pestanaActual = indice),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            label: SoleraL10n.t('$prefijo.hoy'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            label: SoleraL10n.t('ajustes'),
          ),
        ],
      ),
    );
  }
}
EOF

cat > "$destino/lib/pantallas/pantalla_hoy.dart" <<EOF
import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart' show SoleraL10n;

class PantallaHoy extends StatelessWidget {
  const PantallaHoy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('$nombre')),
      body: Center(child: Text(SoleraL10n.t('$prefijo.bienvenida'))),
    );
  }
}
EOF

cat > "$destino/lib/pantallas/pantalla_ajustes.dart" <<EOF
import 'package:flutter/material.dart';
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show SelectorIdioma, SoleraL10n;

import '../datos/base_datos.dart';
import '../modelos/titular.dart';

class PantallaAjustes extends StatefulWidget {
  const PantallaAjustes({super.key});

  @override
  State<PantallaAjustes> createState() => _PantallaAjustesState();
}

class _PantallaAjustesState extends State<PantallaAjustes> {
  final _controladorNombre = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final titular = await BaseDatosSolera$clase.instancia.obtenerTitular();
      if (mounted) _controladorNombre.text = titular.nombre;
    } catch (error) {
      debugPrint('No se pudo leer el titular: \$error');
    }
  }

  Future<void> _guardar() async {
    await BaseDatosSolera$clase.instancia
        .guardarTitular(Titular(nombre: _controladorNombre.text.trim()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(SoleraL10n.t('$prefijo.guardado'))));
  }

  @override
  void dispose() {
    _controladorNombre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(SoleraL10n.t('ajustes'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SelectorIdioma(),
          const SizedBox(height: 24),
          Text(SoleraL10n.t('$prefijo.titular'),
              style: Theme.of(context).textTheme.titleMedium),
          TextField(
            controller: _controladorNombre,
            decoration: InputDecoration(
                labelText: SoleraL10n.t('$prefijo.nombre_titular')),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _guardar, child: Text(SoleraL10n.t('guardar'))),
        ],
      ),
    );
  }
}
EOF

# ─── modelo y base de datos ──────────────────────────────────────────
cat > "$destino/lib/modelos/titular.dart" <<EOF
/// Titular de la explotación (tabla de una sola fila).
class Titular {
  Titular({this.id, this.nombre = '', this.nif = ''});

  final int? id;
  final String nombre;
  final String nif;

  Map<String, Object?> toMap() => {'id': id, 'nombre': nombre, 'nif': nif};

  factory Titular.fromMap(Map<String, Object?> mapa) => Titular(
        id: mapa['id'] as int?,
        nombre: (mapa['nombre'] as String?) ?? '',
        nif: (mapa['nif'] as String?) ?? '',
      );
}
EOF

cat > "$destino/lib/datos/base_datos.dart" <<EOF
import 'package:nuevo_ser_core/nuevo_ser_core.dart'
    show BaseDatosSolera, PasoMigracionSolera;
import 'package:sqflite/sqflite.dart';

import '../modelos/titular.dart';

/// Nombre del fichero en la carpeta de documentos. También es el nombre de
/// la entrada en las copias de seguridad: no cambiarlo nunca.
const String nombreFicheroBaseDatos$clase = 'solera_${id//-/_}.db';

/// Versión del esquema: el número del último paso de [pasosMigracion].
const int versionEsquema$clase = 1;

/// Base de datos local de $nombre. La apertura, el cerrojo, las FK y las
/// migraciones las pone BaseDatosSolera (core). **Migraciones aditivas**:
/// un cambio de esquema es un paso nuevo; nunca se edita lo publicado.
class BaseDatosSolera$clase extends BaseDatosSolera {
  static final BaseDatosSolera$clase instancia = BaseDatosSolera$clase._interno();
  factory BaseDatosSolera$clase() => instancia;
  BaseDatosSolera$clase._interno();

  @override
  String get nombreFichero => nombreFicheroBaseDatos$clase;

  @override
  int get versionEsquema => versionEsquema$clase;

  @override
  DatabaseFactory get fabricaBaseDatos => databaseFactory;

  @override
  Future<void> crearEsquemaInicial(Database db) async {
    await db.execute('''
      CREATE TABLE titulares (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL DEFAULT '',
        nif TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  @override
  Map<int, PasoMigracionSolera> get pasosMigracion => const {};

  Future<Titular> obtenerTitular() async {
    final db = await basedatos;
    final filas = await db.query('titulares', limit: 1);
    return filas.isEmpty ? Titular() : Titular.fromMap(filas.first);
  }

  Future<void> guardarTitular(Titular titular) async {
    await guardarFilaUnica('titulares', titular.toMap());
  }
}
EOF

# ─── tests ───────────────────────────────────────────────────────────
cat > "$destino/test/datos/base_datos_test.dart" <<EOF
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:$paquete/datos/base_datos.dart';
import 'package:$paquete/modelos/titular.dart';

import 'soporte_contrato_base_datos.dart';

void main() {
  final entorno = EntornoBaseDatosTemporal();
  final baseDatos = BaseDatosSolera$clase.instancia;

  setUp(entorno.preparar);
  tearDown(() async {
    await baseDatos.cerrar();
    await entorno.limpiar();
  });

  test('crea \$nombreFicheroBaseDatos$clase en la versión declarada', () async {
    final db = await baseDatos.basedatos;
    expect(await db.getVersion(), versionEsquema$clase);
    expect(File(entorno.ruta(nombreFicheroBaseDatos$clase)).existsSync(), isTrue);
  });

  test('el titular se guarda en una sola fila', () async {
    await baseDatos.guardarTitular(Titular(nombre: 'Primera'));
    await baseDatos.guardarTitular(Titular(nombre: 'Segunda'));
    final filas = await (await baseDatos.basedatos).query('titulares');
    expect(filas, hasLength(1));
    expect((await baseDatos.obtenerTitular()).nombre, 'Segunda');
  });
}
EOF

cat > "$destino/test/sello_provisional_test.dart" <<'EOF'
// Guardarraíl del riesgo R1 (auditoría 2026-05-12): todo generador de PDF
// oficial (`lib/servicios/generador_*_pdf.dart`) lleva la palabra
// PROVISIONAL hasta que un asesor humano valide el formato. Quitarla exige
// apuntar el commit y el nombre del asesor en BLOQUEOS-PENDIENTES.md.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final carpeta = Directory('lib/servicios');
  // git no guarda carpetas vacías: sin generadores todavía, no hay nada que vigilar.
  final generadores = (carpeta.existsSync() ? carpeta.listSync() : <FileSystemEntity>[])
      .whereType<File>()
      .where((fichero) => RegExp(r'generador_\w+_pdf\.dart$').hasMatch(fichero.path));

  for (final generador in generadores) {
    test('${generador.path} conserva el sello PROVISIONAL', () {
      expect(generador.readAsStringSync(), contains('PROVISIONAL'),
          reason: 'Retirar el sello exige validación humana: ver '
              'BLOQUEOS-PENDIENTES.md y la auditoría 2026-05-12 (R1).');
    });
  }

  test('el guardarraíl se carga', () => expect(generadores, isA<Iterable<File>>()));
}
EOF

# ─── catálogos ───────────────────────────────────────────────────────
cat > "$destino/tool/compilar_catalogos.dart" <<EOF
// ignore_for_file: avoid_print
// Compilador de catálogos de $nombre: content/$id/*.csv →
// lib/datos/catalogos_generados/. Lo común está en el core.
//
//   cd apps/$app && dart run tool/compilar_catalogos.dart
//
// Para cada CSV, añade una función _compilarX que lea con
// \`compilador.leer('x.csv')\`, escriba la cabecera con
// \`compilador.cabeceraDart(...)\` y la clase del catálogo, y termine con
// \`compilador.escribir('catalogo_x.dart', ...)\`. Ver
// apps/solera-aceitera/tool/compilar_catalogos.dart como ejemplo completo.

import '../../../packages/nuevo_ser_core/tool/catalogos/compilador_catalogos.dart';

final compilador = CompiladorCatalogos(carpetaContent: '$id', carpetaApp: '$app');

/// Funciones de compilación, una por CSV.
final catalogos = <Future<void> Function()>[];

Future<void> main() async {
  for (final compilarCatalogo in catalogos) {
    await compilarCatalogo();
  }
  // Sin catálogos todavía no hay nada revisado: el banner sigue activo.
  if (catalogos.isEmpty) compilador.todasRevisadas = false;
  await compilador.escribirFlagRevision(
    descripcionCatalogos: 'los catálogos de $nombre',
    textoBanner: 'datos provisionales sin validar',
  );
  print('Hecho: catalogosCompletamenteRevisados = \${compilador.todasRevisadas}');
}
EOF

cat > "$raiz/content/$id/LEEME.md" <<EOF
# Catálogos de $nombre

CSV curados que \`apps/$app/tool/compilar_catalogos.dart\` compila a Dart.
Convenciones de la suite: líneas \`#\` de comentario arriba con la fuente;
columna \`revisado_por\` (solo cuenta como firma humana si empieza por
\`asesor:\` o \`persona:\`; \`fuente_publica\` es revisión documental).
EOF

# ─── traducciones ────────────────────────────────────────────────────
cat > "$raiz/content/solera/traducciones/$id.csv" <<EOF
clave,es,eu,ca,gl
$prefijo.bienvenida,Primera versión en construcción.,Lehen bertsioa eraikitzen ari da.,Primera versió en construcció.,Primeira versión en construción.
$prefijo.guardado,Guardado,Gordeta,Desat,Gardado
$prefijo.hoy,Hoy,Gaur,Avui,Hoxe
$prefijo.nombre_titular,Nombre del titular,Titularraren izena,Nom del titular,Nome do titular
$prefijo.titular,Titular,Titularra,Titular,Titular
EOF

# ─── documentación ───────────────────────────────────────────────────
cat > "$destino/CLAUDE.md" <<EOF
# $nombre — CLAUDE.md

Cerebro persistente de la vertical. Se actualiza **al cerrar cada bloque**:
cualquier agente nuevo debe poder seguir leyendo solo este fichero, su ficha
(\`docs/plan-verticales/$id.md\`) y \`docs/plan-verticales-larrea.md\`.

## Estado

| Bloque | Estado | Notas |
|---|---|---|
| 1 Esqueleto | ✅ $fecha | Generado con \`scripts/nueva_vertical.sh\` |
| 2 Modelos + BD | pendiente | |
| 3 Pantallas | pendiente | |
| 4-5 Documentos oficiales PDF | pendiente | sello PROVISIONAL |
| 6 Catálogos | pendiente | |
| 7 IA visual | pendiente | |
| 8 Branding + GPS | pendiente | |
| 9 Economía | pendiente | PROVISIONAL |
| 10 Revisión con fuente pública | pendiente | |
| 11 APK + ayuda | pendiente | |

**Siguiente acción**: bloque 2.

## Encuadre

(Para quién, diferencial, normativa con fuente enlazada y hard limits: copiar
de la ficha de encargo y mantener al día.)

## Decisiones tomadas sin consultar

(Cada una con fecha y porqué.)

## Datos técnicos

- Paquete \`$paquete\`, BD \`solera_${id//-/_}.db\` sobre \`BaseDatosSolera\` del core.
- Traducciones: \`content/solera/traducciones/$id.csv\` (claves \`$prefijo.*\`), y
  regenerar con \`cd packages/nuevo_ser_core && dart run tool/compilar_traducciones_solera.dart\`.
  eu/ca/gl son **borrador** hasta la revisión nativa (\`scripts/traducciones/\`).
- Catálogos: \`content/$id/\` → \`dart run tool/compilar_catalogos.dart\`.
EOF

cat > "$destino/BLOQUEOS-PENDIENTES.md" <<EOF
# $nombre — bloqueos pendientes

Lo que espera a una persona. Un agente nunca se para por esto: lo apunta aquí
y sigue. Lo recoge \`scripts/pendientes/\`.

## Asesores humanos (para retirar sellos PROVISIONAL)

## Revisión nativa eu/ca/gl

- Textos de \`content/solera/traducciones/$id.csv\` (borrador, $fecha).

## Bloqueos técnicos
EOF

# ─── generar, comprobar ──────────────────────────────────────────────
echo "→ traducciones"
# El test de traducciones del core vigila las claves sueltas por prefijo.
prueba_l10n="$raiz/packages/nuevo_ser_core/test/i18n/solera_l10n_test.dart"
grep -q "|$prefijo)" "$prueba_l10n" || sed -i "s/|nat\(|[a-z|]*\)\?)\\\\./|nat\1|$prefijo)\\\\./" "$prueba_l10n"
( cd "$raiz/packages/nuevo_ser_core" && dart run tool/compilar_traducciones_solera.dart >/dev/null )
cd "$destino"
echo "→ pub get + catálogos"
flutter pub get >/dev/null
dart run tool/compilar_catalogos.dart >/dev/null
echo "→ analyze"
flutter analyze
echo "→ test"
flutter test
echo "✅ $app creada en $destino"
