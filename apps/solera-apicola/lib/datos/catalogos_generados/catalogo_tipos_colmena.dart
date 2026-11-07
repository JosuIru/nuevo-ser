// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/apicola/tipos_colmena.csv
// Generado: 2026-11-07
// Filas: 7 (0 revisadas, 7 pendientes de revisión)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR POR VETERINARIO APÍCOLA NI APICULTOR ASESOR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-apicola && dart run tool/compilar_catalogos.dart

/// Forma constructiva de la colmena.
enum FormatoColmena { fijaHorizontal, verticalAlza, topBar, tronco }

class TipoColmena {
  final String id;
  final String nombreCanonico;
  final FormatoColmena formato;
  /// Cuadros en la cámara de cría — 0 si tronco o top-bar.
  final int numeroCuadrosCamara;
  final bool apilableAlzas;
  final String usoTradicional;
  final List<String> ventajas;
  final List<String> desventajas;
  final String notas;

  const TipoColmena({
    required this.id,
    required this.nombreCanonico,
    required this.formato,
    required this.numeroCuadrosCamara,
    required this.apilableAlzas,
    this.usoTradicional = '',
    this.ventajas = const [],
    this.desventajas = const [],
    this.notas = '',
  });
}

const List<TipoColmena> catalogoTiposColmena = [
  TipoColmena(
    id: 'layens',
    nombreCanonico: 'Layens',
    formato: FormatoColmena.fijaHorizontal,
    numeroCuadrosCamara: 12,
    apilableAlzas: false,
    usoTradicional: 'Mediterránea — España y Francia mediterránea',
    ventajas: ['Cámara de cría amplia', 'sin alzas (manejo simple)', 'cuadros largos pesados con miel'],
    desventajas: ['Sin alzas dificulta cosechas escalonadas', 'cuadros pesados al cosechar', 'menos modular'],
    notas: 'Colmena más extendida en España. Cuadros 30x35 cm aproximados',
  ),
  TipoColmena(
    id: 'layens_industrial',
    nombreCanonico: 'Layens industrial (12 cuadros)',
    formato: FormatoColmena.fijaHorizontal,
    numeroCuadrosCamara: 12,
    apilableAlzas: false,
    usoTradicional: 'Mediterránea ibérica',
    ventajas: ['Idem Layens', 'estandarizada'],
    desventajas: ['Idem Layens'],
    notas: 'Variante con dimensiones estandarizadas para mecanización',
  ),
  TipoColmena(
    id: 'dadant',
    nombreCanonico: 'Dadant',
    formato: FormatoColmena.verticalAlza,
    numeroCuadrosCamara: 10,
    apilableAlzas: true,
    usoTradicional: 'Francia y centro-sur de Europa',
    ventajas: ['Alzas apilables', 'cámara de cría amplia', 'cuadros más manejables que en Layens'],
    desventajas: ['Asimetría cámara-alza', 'menos extendida en España que Layens'],
    notas: 'Cuadros de cámara mayores que los de alza — cuadro Dadant clásico',
  ),
  TipoColmena(
    id: 'langstroth',
    nombreCanonico: 'Langstroth',
    formato: FormatoColmena.verticalAlza,
    numeroCuadrosCamara: 10,
    apilableAlzas: true,
    usoTradicional: 'EE. UU. y mundial — más extendida globalmente',
    ventajas: ['Estándar internacional', 'alzas y cámara mismo cuadro', 'máxima modularidad'],
    desventajas: ['Cámara de cría a veces pequeña en climas largos'],
    notas: 'Inventada por L.L. Langstroth en 1851 — base de la apicultura moderna',
  ),
  TipoColmena(
    id: 'warre',
    nombreCanonico: 'Warré',
    formato: FormatoColmena.verticalAlza,
    numeroCuadrosCamara: 8,
    apilableAlzas: true,
    usoTradicional: 'Movimiento de apicultura natural en Europa',
    ventajas: ['Manejo mínimo', 'nesting natural sin cuadros precableados', 'alzas pequeñas ligeras'],
    desventajas: ['Difícil para cosecha escalonada', 'menos productiva', 'incompatible con mecanización'],
    notas: 'Diseñada por Émile Warré (años 1920) — popular en apicultura natural',
  ),
  TipoColmena(
    id: 'top_bar',
    nombreCanonico: 'Top-bar',
    formato: FormatoColmena.topBar,
    numeroCuadrosCamara: 0,
    apilableAlzas: false,
    usoTradicional: 'África y apicultura naturalista en Europa/EE. UU.',
    ventajas: ['Sin cuadros — solo barras superiores', 'construcción sencilla', 'abeja diseña su panal'],
    desventajas: ['No apilable', 'cosecha destructiva del panal', 'incompatible con extractor centrífugo'],
    notas: 'Apicultura tradicional africana adaptada a hobbistas',
  ),
  TipoColmena(
    id: 'tronco_artesanal',
    nombreCanonico: 'Tronco artesanal (corcho/castaño)',
    formato: FormatoColmena.tronco,
    numeroCuadrosCamara: 0,
    apilableAlzas: false,
    usoTradicional: 'Cantábrico y zonas tradicionales europeas',
    ventajas: ['Bajo coste', 'integración paisajística'],
    desventajas: ['No permite manejo moderno', 'no permite registro fitosanitario fiable'],
    notas: 'Patrimonio etnográfico — uso decorativo o demostrativo más que productivo',
  ),
];

TipoColmena? tipoColmenaPorId(String id) {
  for (final t in catalogoTiposColmena) {
    if (t.id == id) return t;
  }
  return null;
}

List<TipoColmena> buscarTiposColmena(String texto) {
  final consultaNormalizada = _normalizar(texto);
  if (consultaNormalizada.isEmpty) return const [];
  return catalogoTiposColmena.where((t) {
    return _normalizar(t.id).contains(consultaNormalizada) ||
        _normalizar(t.nombreCanonico).contains(consultaNormalizada);
  }).toList();
}

String _normalizar(String texto) {
  return texto
      .toLowerCase()
      .replaceAll(RegExp(r'[áàä]'), 'a')
      .replaceAll(RegExp(r'[éèë]'), 'e')
      .replaceAll(RegExp(r'[íìï]'), 'i')
      .replaceAll(RegExp(r'[óòö]'), 'o')
      .replaceAll(RegExp(r'[úùü]'), 'u')
      .replaceAll('ñ', 'n')
      .trim();
}

