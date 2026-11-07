// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/apicola/plagas_apicolas.csv
// Generado: 2026-11-07
// Filas: 17 (0 revisadas, 17 pendientes de revisión)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR POR VETERINARIO APÍCOLA NI APICULTOR ASESOR.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-apicola && dart run tool/compilar_catalogos.dart

/// Categoría de la incidencia apícola.
enum TipoPlagaApicola { parasito, infeccion, plagaFisica, depredador, abiotico }

class PlagaApicola {
  final String id;
  final String nombreComun;
  final String nombreCientifico;
  final TipoPlagaApicola tipo;
  final String sintomas;
  final String condicionesFavorables;
  final String manejoCultural;
  /// `true` para enfermedades de declaración obligatoria al servicio veterinario oficial.
  final bool declaracionOficial;
  final String notas;

  const PlagaApicola({
    required this.id,
    required this.nombreComun,
    this.nombreCientifico = '',
    required this.tipo,
    this.sintomas = '',
    this.condicionesFavorables = '',
    this.manejoCultural = '',
    this.declaracionOficial = false,
    this.notas = '',
  });
}

const List<PlagaApicola> catalogoPlagasApicolas = [
  PlagaApicola(
    id: 'varroosis',
    nombreComun: 'Varroosis',
    nombreCientifico: 'Varroa destructor',
    tipo: TipoPlagaApicola.parasito,
    sintomas: 'Ácaros visibles sobre abejas adultas y cría|cría salteada|alas deformes|caída de población',
    condicionesFavorables: 'Cría operculada presente|colmenas debilitadas|sin tratamiento previo',
    manejoCultural: 'Recuento sticky board para nivel de infestación|fondos sanitarios|enjambres artificiales en sin_postura',
    notas: 'Ubicua en España. Tratamiento obligatorio en cualquier explotación',
  ),
  PlagaApicola(
    id: 'nosemosis_apis',
    nombreComun: 'Nosemosis (Nosema apis)',
    nombreCientifico: 'Vairimorpha apis',
    tipo: TipoPlagaApicola.infeccion,
    sintomas: 'Diarrea oscura sobre la piquera|panales manchados|abejas tambaleantes',
    condicionesFavorables: 'Primavera fría y húmeda|estrés alimentario|colmenas sucias',
    manejoCultural: 'Recambio de cera vieja|alimentación con jarabe limpio|aireación en invernada',
    notas: 'Antes llamada Nosema apis — reclasificada al género Vairimorpha',
  ),
  PlagaApicola(
    id: 'nosemosis_ceranae',
    nombreComun: 'Nosemosis (Nosema ceranae)',
    nombreCientifico: 'Vairimorpha ceranae',
    tipo: TipoPlagaApicola.infeccion,
    sintomas: 'Despoblamiento sin diarrea visible|caída en producción|reinas que pierden postura',
    condicionesFavorables: 'Estrés por trashumancia|colmenas envejecidas|nutrición pobre',
    manejoCultural: 'Recambio frecuente de cera|alimentación proteica suplementaria|reposición regular de reinas',
    notas: 'Más frecuente en España que la N. apis clásica. Diagnóstico solo por microscopio o PCR',
  ),
  PlagaApicola(
    id: 'loque_americana',
    nombreComun: 'Loque americana',
    nombreCientifico: 'Paenibacillus larvae',
    tipo: TipoPlagaApicola.infeccion,
    sintomas: 'Cría operculada de aspecto graso|opérculos hundidos y perforados|olor pútrido a cola de carpintero|prueba de la cerilla positiva',
    condicionesFavorables: 'Esporas persistentes muchos años|colmenas viejas|robo entre colmenas',
    manejoCultural: 'DESTRUCCIÓN OBLIGATORIA por incineración. NO es tratable con antibióticos en la UE',
    declaracionOficial: true,
    notas: 'ENFERMEDAD DE DECLARACIÓN OBLIGATORIA. Llamar a Servicios Veterinarios oficiales',
  ),
  PlagaApicola(
    id: 'loque_europea',
    nombreComun: 'Loque europea',
    nombreCientifico: 'Melissococcus plutonius',
    tipo: TipoPlagaApicola.infeccion,
    sintomas: 'Cría desoperculada con larvas retorcidas|color amarillento a marrón|olor agrio (no pútrido)',
    condicionesFavorables: 'Estrés nutricional|colmenas débiles',
    manejoCultural: 'Renovación de panal|trasiego a colmena limpia|reposición de reina',
    notas: 'Menos virulenta que la americana. Notificación variable por CCAA — verificar RD autonómico',
  ),
  PlagaApicola(
    id: 'ascosferiosis',
    nombreComun: 'Ascosferiosis (cría escayolada)',
    nombreCientifico: 'Ascosphaera apis',
    tipo: TipoPlagaApicola.infeccion,
    sintomas: 'Larvas momificadas blancas y duras|aspecto de tiza|momias en el fondo y la piquera',
    condicionesFavorables: 'Humedad elevada|ventilación pobre|primavera fría tras inversión',
    manejoCultural: 'Aireación|reducción de población a nivel saneable|reposición de reina',
    notas: 'Conocida también como cría escayolada. Manejo cultural suele bastar',
  ),
  PlagaApicola(
    id: 'virus_alas_deformes',
    nombreComun: 'Virus de las alas deformes',
    nombreCientifico: 'DWV (Deformed Wing Virus)',
    tipo: TipoPlagaApicola.infeccion,
    sintomas: 'Abejas jóvenes con alas atrofiadas o arrugadas|abdomen acortado|incapacidad de vuelo',
    condicionesFavorables: 'Alta carga de varroa|colmenas inmunodeprimidas',
    manejoCultural: 'Tratar contra varroa — la varroa es vector principal del DWV',
    notas: 'Indicador de infestación de varroa — el síntoma del DWV ya es señal de fracaso del control de varroa',
  ),
  PlagaApicola(
    id: 'virus_paralisis_cronica',
    nombreComun: 'Virus de la parálisis crónica',
    nombreCientifico: 'CBPV (Chronic Bee Paralysis Virus)',
    tipo: TipoPlagaApicola.infeccion,
    sintomas: 'Abejas negras y brillantes (sin pelo)|temblores|piquera con cadáveres',
    condicionesFavorables: 'Hacinamiento|verano caluroso|estrés ambiental',
    manejoCultural: 'Aireación|distancia entre colmenas|reposición de reina',
    notas: 'Presentación brusca puede colapsar colmenas en pocos días',
  ),
  PlagaApicola(
    id: 'acariosis',
    nombreComun: 'Acariosis traqueal',
    nombreCientifico: 'Acarapis woodi',
    tipo: TipoPlagaApicola.parasito,
    sintomas: 'Abejas que no vuelan|alas en posición K|piquera con cadáveres|alas asimétricas',
    condicionesFavorables: 'Invernada|colmenas viejas no renovadas',
    manejoCultural: 'Reposición de reinas|recambio de cera|tratamientos para varroa también limitan acariosis',
    notas: 'Diagnóstico solo por microscopio. Menos extendida que la varroa',
  ),
  PlagaApicola(
    id: 'polilla_cera',
    nombreComun: 'Polilla de la cera',
    nombreCientifico: 'Galleria mellonella',
    tipo: TipoPlagaApicola.plagaFisica,
    sintomas: 'Galerías de seda en panales abandonados|larvas blancas|destrucción rápida de panales',
    condicionesFavorables: 'Panales fuera de la colmena|colmenas debilitadas sin abejas',
    manejoCultural: 'Almacenar panales con frío o azufre|no dejar alzas vacías al sol',
    notas: 'Daña sobre todo cera almacenada — no la colmena fuerte y poblada',
  ),
  PlagaApicola(
    id: 'escarabajo_colmenas',
    nombreComun: 'Escarabajo de las colmenas',
    nombreCientifico: 'Aethina tumida',
    tipo: TipoPlagaApicola.plagaFisica,
    sintomas: 'Larvas en panales|miel fermentada y maloliente|colmenas saqueadas',
    condicionesFavorables: 'Climas cálidos y húmedos|colmenas debilitadas',
    manejoCultural: 'Trampas de fondo|fortalecer colmenas|destruir colonias afectadas',
    declaracionOficial: true,
    notas: 'ENFERMEDAD DE DECLARACIÓN OBLIGATORIA en la UE. Especie exótica invasora — vigilar y notificar inmediatamente',
  ),
  PlagaApicola(
    id: 'tropilaelaps',
    nombreComun: 'Tropilaelaps',
    nombreCientifico: 'Tropilaelaps spp.',
    tipo: TipoPlagaApicola.parasito,
    sintomas: 'Cría operculada perforada con orificios irregulares|abejas con alas deformes|caída brusca de población|larvas con manchas marrones',
    condicionesFavorables: 'Ausente en España. Riesgo de introducción por importación de material apícola.',
    manejoCultural: 'Vigilancia activa por inspector veterinario|inspección de colmenares importados|destrucción de colmenas si confirmación',
    declaracionOficial: true,
    notas: 'ENFERMEDAD DE DECLARACIÓN OBLIGATORIA UE. Ácaro asiático parasitario — agrava varroa.',
  ),
  PlagaApicola(
    id: 'vespa_velutina',
    nombreComun: 'Avispón asiático',
    nombreCientifico: 'Vespa velutina',
    tipo: TipoPlagaApicola.depredador,
    sintomas: 'Avispones vigilando piquera|abejas defensivas se concentran en piquera (efecto bola defensiva)|caída de actividad pecoreadora',
    condicionesFavorables: 'Verano y otoño en zonas afectadas (norte ibérico — atlántica)',
    manejoCultural: 'Trampeo selectivo de reinas en primavera|destrucción de nidos por especialista|reductores de piquera',
    declaracionOficial: true,
    notas: 'Especie exótica invasora. Dispone de protocolo nacional de gestión. Notificar nidos a 112 o ayuntamiento',
  ),
  PlagaApicola(
    id: 'abejaruco',
    nombreComun: 'Abejaruco europeo',
    nombreCientifico: 'Merops apiaster',
    tipo: TipoPlagaApicola.depredador,
    sintomas: 'Bandadas de aves coloridas posadas en cables|presas en piquera durante las migraciones',
    condicionesFavorables: 'Migraciones primavera y otoño',
    manejoCultural: 'Mover el colmenar si la presión es alta — protegido por ley',
    notas: 'Especie protegida — NO se persigue. Convivencia y manejo de ubicación es la única opción legal',
  ),
  PlagaApicola(
    id: 'robo',
    nombreComun: 'Robo entre colmenas',
    tipo: TipoPlagaApicola.abiotico,
    sintomas: 'Pelea en piquera|cera mordida|abejas brillantes (negras lustradas)',
    condicionesFavorables: 'Mielada parada|colmenas debilitadas|piquera abierta de más',
    manejoCultural: 'Reducción de piquera|cierre temporal de colmena debilitada|alimentación suplementaria',
    notas: 'Síntoma de manejo — no patología. Frecuente al final del verano',
  ),
  PlagaApicola(
    id: 'intoxicacion_fitosanitarios',
    nombreComun: 'Intoxicación por fitosanitarios',
    tipo: TipoPlagaApicola.abiotico,
    sintomas: 'Mortandad masiva en piquera|abejas con probóscide extendida|caída brusca',
    condicionesFavorables: 'Aplicaciones agrícolas próximas|cultivos en floración cercanos',
    manejoCultural: 'Notificar al SEPRONA + tomar muestras antes de mover|coordinar con agricultores vecinos|cambiar ubicación',
    notas: 'Pruebas y muestras críticas si va a haber denuncia',
  ),
  PlagaApicola(
    id: 'hambre_invernal',
    nombreComun: 'Hambre invernal',
    tipo: TipoPlagaApicola.abiotico,
    sintomas: 'Colmena muerta en invernada con abejas dentro de celdillas|reservas agotadas',
    condicionesFavorables: 'Invernada larga|cosecha excesiva otoñal',
    manejoCultural: 'Pesar colmenas pre-invernada (mínimo 12-15 kg de reservas según zona)|alimentación suplementaria preventiva',
    notas: 'Causa frecuente de mortandad invernal en explotaciones poco visitadas en otoño',
  ),
];

PlagaApicola? plagaApicolaPorId(String id) {
  for (final p in catalogoPlagasApicolas) {
    if (p.id == id) return p;
  }
  return null;
}

/// Mapea una entrada del catálogo al string `tipo` que persiste el modelo
/// `IncidenciaApicola`. Combina id concreto + categoría taxonómica:
///  - id `polilla_cera` → polilla_cera
///  - id `vespa_velutina` → vespa_velutina
///  - id `robo` → robo
///  - parasito o infeccion → sanitario
///  - resto (plagaFisica salvo polilla, depredador salvo vespa, abiotico) → otro
String tipoIncidenciaParaBd(PlagaApicola plaga) {
  switch (plaga.id) {
    case 'polilla_cera':
      return 'polilla_cera';
    case 'vespa_velutina':
      return 'vespa_velutina';
    case 'robo':
      return 'robo';
  }
  switch (plaga.tipo) {
    case TipoPlagaApicola.parasito:
    case TipoPlagaApicola.infeccion:
      return 'sanitario';
    case TipoPlagaApicola.plagaFisica:
    case TipoPlagaApicola.depredador:
    case TipoPlagaApicola.abiotico:
      return 'otro';
  }
}

/// Búsqueda fuzzy para validar diagnósticos del modal IA.
/// Prueba primero los campos correspondientes (común↔común, científico↔científico)
/// y si nada matchea hace fallback cruzado, porque la IA y los apicultores
/// tienden a usar el nombre científico en cualquier campo.
PlagaApicola? plagaApicolaPorBusquedaFuzzy(String nombreComun, String nombreCientifico) {
  final consultaComun = _normalizar(nombreComun);
  final consultaCient = _normalizar(nombreCientifico);
  if (consultaComun.isEmpty && consultaCient.isEmpty) return null;
  // Pasada estricta: campo a campo.
  for (final p in catalogoPlagasApicolas) {
    if (consultaCient.isNotEmpty && p.nombreCientifico.isNotEmpty &&
        _normalizar(p.nombreCientifico).contains(consultaCient)) {
      return p;
    }
    if (consultaComun.isNotEmpty && _normalizar(p.nombreComun).contains(consultaComun)) {
      return p;
    }
  }
  // Pasada cruzada: el nombre común podría llevar el binomio latino y viceversa.
  for (final p in catalogoPlagasApicolas) {
    if (consultaComun.isNotEmpty && p.nombreCientifico.isNotEmpty &&
        _normalizar(p.nombreCientifico).contains(consultaComun)) {
      return p;
    }
    if (consultaCient.isNotEmpty &&
        _normalizar(p.nombreComun).contains(consultaCient)) {
      return p;
    }
  }
  return null;
}

List<PlagaApicola> buscarPlagasApicolas(String texto) {
  final consultaNormalizada = _normalizar(texto);
  if (consultaNormalizada.isEmpty) return const [];
  return catalogoPlagasApicolas.where((p) {
    return _normalizar(p.nombreComun).contains(consultaNormalizada) ||
        _normalizar(p.nombreCientifico).contains(consultaNormalizada) ||
        _normalizar(p.id).contains(consultaNormalizada);
  }).toList();
}

/// Patologías de declaración obligatoria — la app las destaca visualmente.
List<PlagaApicola> patologiasDeclaracionObligatoria() {
  return catalogoPlagasApicolas.where((p) => p.declaracionOficial).toList();
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

