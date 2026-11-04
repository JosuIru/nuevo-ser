import 'package:flutter/material.dart';

/// Tipo de problema sanitario o agronómico:
/// - plaga: organismo animal (insecto, ácaro, nematodo, vertebrado).
/// - enfermedad: patógeno biótico (hongo, bacteria, virus, fitoplasma).
/// - fisiologico: trastorno por desbalance nutricional, hídrico, etc.
/// - abiotico: daño por factores ambientales (helada, granizo, sol).
enum TipoPlaga { plaga, enfermedad, fisiologico, abiotico }

extension TipoPlagaTextos on TipoPlaga {
  String get nombreVisible {
    switch (this) {
      case TipoPlaga.plaga:
        return 'Plaga';
      case TipoPlaga.enfermedad:
        return 'Enfermedad';
      case TipoPlaga.fisiologico:
        return 'Trastorno fisiológico';
      case TipoPlaga.abiotico:
        return 'Daño abiótico';
    }
  }

  Color get color {
    switch (this) {
      case TipoPlaga.plaga:
        return const Color(0xFFE65100);
      case TipoPlaga.enfermedad:
        return const Color(0xFFAD1457);
      case TipoPlaga.fisiologico:
        return const Color(0xFFFFA000);
      case TipoPlaga.abiotico:
        return const Color(0xFF607D8B);
    }
  }

  IconData get icono {
    switch (this) {
      case TipoPlaga.plaga:
        return Icons.bug_report;
      case TipoPlaga.enfermedad:
        return Icons.coronavirus;
      case TipoPlaga.fisiologico:
        return Icons.healing;
      case TipoPlaga.abiotico:
        return Icons.cloud;
    }
  }
}

/// Entrada del catálogo de problemas sanitarios.
///
/// **Nota importante para v1**: la sección `manejoCultural` describe
/// solo prácticas culturales no-químicas verificables en bibliografía
/// agronómica pública (poda sanitaria, riego, manejo del suelo,
/// trampeo). NO incluye nombres comerciales de productos
/// fitosanitarios — esa información requiere validación de un
/// agrónomo y consulta de la BBDD del MAPA, que entran en F2.
class Plaga {
  final String id;
  final String nombreComun;
  final String nombreCientifico;
  final TipoPlaga tipo;
  final List<String> cultivoIds;
  final String descripcion;
  final String sintomas;
  final String condicionesFavorables;
  final String manejoCultural;

  const Plaga({
    required this.id,
    required this.nombreComun,
    required this.nombreCientifico,
    required this.tipo,
    required this.cultivoIds,
    required this.descripcion,
    required this.sintomas,
    this.condicionesFavorables = '',
    this.manejoCultural = '',
  });
}

/// Catálogo inicial v1. Foco en problemas mainstream de los cultivos
/// prioritarios (olivo, almendro, frutales, pistacho, trufa, vid).
/// Contenido conservador y verificable. La validación final por un
/// agrónomo y la ampliación con el material que aporte tu hermano
/// (truficultor) entran en F2.
const List<Plaga> catalogoPlagas = [
  // ─── Olivo ─────────────────────────────────────────────
  Plaga(
    id: 'mosca-olivo',
    nombreComun: 'Mosca del olivo',
    nombreCientifico: 'Bactrocera oleae',
    tipo: TipoPlaga.plaga,
    cultivoIds: ['olivo'],
    descripcion:
        'Díptero tefrítido específico del olivo. Es la plaga más importante del olivar a escala mundial. La hembra pone un huevo dentro de la aceituna en envero; la larva se alimenta de la pulpa, abriendo galerías que arruinan la calidad del aceite y propician la entrada de hongos.',
    sintomas:
        'Picadura visible en la aceituna (punto pardo). Galería interna marrón. Caída prematura del fruto. Aumento de acidez del aceite. Aceitunas blandas en pulgar al apretar.',
    condicionesFavorables:
        'Veranos suaves y húmedos. Olivar costero o de regadío con frutos grandes y tempranos. Más virulenta en variedades de mesa que de almazara.',
    manejoCultural:
        'Trampeo masivo con mosqueros (botellas con atrayente alimenticio + atrayente sexual feromona Cera Trap, ECO-trap o equivalentes), 1 trampa cada 1-2 árboles. Recolección anticipada para reducir daño. Eliminar aceitunas caídas al suelo (rompe ciclo).',
  ),
  Plaga(
    id: 'repilo',
    nombreComun: 'Repilo',
    nombreCientifico: 'Spilocaea oleagina (Venturia oleaginea)',
    tipo: TipoPlaga.enfermedad,
    cultivoIds: ['olivo'],
    descripcion:
        'Hongo defoliador. La enfermedad más común del olivar tras la mosca. Provoca caída masiva de hoja y debilita el árbol, reduciendo cosecha del año siguiente.',
    sintomas:
        'Manchas redondas oscuras en el haz de la hoja con halo amarillento (forma de "ojo de gallo" o "moneda"). Defoliación severa al año siguiente.',
    condicionesFavorables:
        'Otoño-primavera con humedad relativa >80 % y temperatura 12-22 °C. Olivos con copa densa, mal aireada, en zonas húmedas o cerca de cursos de agua.',
    manejoCultural:
        'Poda aireadora para reducir humedad interna de copa. Tratamiento cúprico preventivo en otoño y primavera (caldo bordelés, oxicloruro de cobre).',
  ),
  Plaga(
    id: 'tuberculosis-olivo',
    nombreComun: 'Tuberculosis (verrugas)',
    nombreCientifico: 'Pseudomonas savastanoi pv. savastanoi',
    tipo: TipoPlaga.enfermedad,
    cultivoIds: ['olivo'],
    descripcion:
        'Bacteria que coloniza heridas de poda y daños de granizo o helada produciendo tumores característicos en ramas y troncos. Reduce vigor.',
    sintomas:
        'Verrugas o tumores leñosos en ramas, brotes y troncos, de 1-3 cm. Caída de hoja en zonas afectadas.',
    condicionesFavorables:
        'Heridas por poda, granizo o frío. Lluvias post-poda diseminan la bacteria.',
    manejoCultural:
        'Podar en seco, evitando días lluviosos y posteriores. Desinfectar tijeras entre árboles (lejía 10 % o etanol 70 %). Tratar heridas grandes con caldo bordelés.',
  ),
  Plaga(
    id: 'prays-olivo',
    nombreComun: 'Polilla del olivo (prays)',
    nombreCientifico: 'Prays oleae',
    tipo: TipoPlaga.plaga,
    cultivoIds: ['olivo'],
    descripcion:
        'Lepidóptero con tres generaciones que afectan a hojas, flores y frutos sucesivamente. La generación carpófaga (sobre fruto) es la que más cosecha pierde.',
    sintomas:
        'Hojas con minas (gen. filófaga). Inflorescencias secas (gen. antófaga). Aceitunas con orificio de salida y caída en septiembre (gen. carpófaga).',
    condicionesFavorables: 'Climas suaves. Olivos jóvenes con muchas yemas tiernas.',
    manejoCultural: 'Seguimiento con trampas de feromona en floración para decidir umbral de tratamiento.',
  ),

  // ─── Almendro ──────────────────────────────────────────
  Plaga(
    id: 'avispilla-almendro',
    nombreComun: 'Avispilla del almendro',
    nombreCientifico: 'Eurytoma amygdali',
    tipo: TipoPlaga.plaga,
    cultivoIds: ['almendro'],
    descripcion:
        'Himenóptero que pone el huevo dentro de la almendra recién formada. La larva consume el grano. Puede llegar a destruir el 80 % de la cosecha en focos no controlados.',
    sintomas:
        'Almendras pequeñas y deformes que no se desprenden del árbol en cosecha; al abrirlas se ve el grano completamente consumido por la larva.',
    condicionesFavorables: 'Variedades de cáscara fina. Plantaciones en zonas tradicionales sin recogida sistemática de los frutos pegados.',
    manejoCultural:
        'Recogida y destrucción de "momias" (almendras pegadas al árbol y al suelo) en febrero-marzo: rompe el ciclo. Es la práctica clave; tratamiento químico solo si la presión es alta y la recogida no es viable.',
  ),
  Plaga(
    id: 'mancha-ocre',
    nombreComun: 'Mancha ocre',
    nombreCientifico: 'Polystigma amygdalinum',
    tipo: TipoPlaga.enfermedad,
    cultivoIds: ['almendro'],
    descripcion:
        'Hongo que provoca defoliación severa en almendro. Cada vez más extendido en Iberia.',
    sintomas:
        'Manchas amarillentas que viran a anaranjado intenso con tacto rugoso (acérvulos del hongo). Defoliación temprana en verano.',
    condicionesFavorables:
        'Primaveras lluviosas. Variedades sensibles (Marcona muy susceptible).',
    manejoCultural: 'Recoger y destruir hojas caídas en otoño (reduce inóculo). Tratamientos cúpricos al inicio de brotación.',
  ),
  Plaga(
    id: 'monilia',
    nombreComun: 'Monilia (podredumbre marrón)',
    nombreCientifico: 'Monilinia spp.',
    tipo: TipoPlaga.enfermedad,
    cultivoIds: ['almendro', 'cerezo', 'ciruelo', 'melocotonero', 'albaricoquero', 'nectarino', 'manzano', 'peral'],
    descripcion:
        'Hongo que afecta a frutales de hueso y pepita. Tres especies principales (M. fructicola, M. laxa, M. fructigena). Pudre flores, brotes y frutos.',
    sintomas:
        'Flores secas y pegadas a la rama (chancro). Brotes con punta seca en gancho. Frutos con podredumbre marrón concéntrica y micelio gris en superficie. Frutos momificados que persisten en el árbol.',
    condicionesFavorables: 'Primaveras lluviosas y suaves durante floración. Heridas en fruto (granizo, picaduras).',
    manejoCultural: 'Eliminar frutos momificados y ramillas afectadas en poda invernal. Aclareo para airear copa.',
  ),

  // ─── Frutales pepita ────────────────────────────────────
  Plaga(
    id: 'carpocapsa',
    nombreComun: 'Carpocapsa (gusano de la manzana)',
    nombreCientifico: 'Cydia pomonella',
    tipo: TipoPlaga.plaga,
    cultivoIds: ['manzano', 'peral', 'nogal'],
    descripcion:
        'Lepidóptero clave del manzano y peral. La larva entra al fruto y se alimenta de la pulpa y semillas. Hasta 3 generaciones por año.',
    sintomas:
        'Galería desde el exterior con expulsión de excrementos. Fruto con orificio de entrada. Caída prematura.',
    condicionesFavorables: 'Veranos cálidos. Frutales bajo poda inadecuada que facilitan refugios de la larva en cortezas.',
    manejoCultural:
        'Confusión sexual por feromonas (eficaz, ampliamente adoptada). Seguimiento con trampas. Recoger y destruir fruta caída.',
  ),
  Plaga(
    id: 'fuego-bacteriano',
    nombreComun: 'Fuego bacteriano',
    nombreCientifico: 'Erwinia amylovora',
    tipo: TipoPlaga.enfermedad,
    cultivoIds: ['manzano', 'peral', 'membrillero'],
    descripcion:
        'Bacteria de cuarentena (notificación obligatoria a las autoridades fitosanitarias). Puede causar la muerte del árbol en pocas semanas.',
    sintomas:
        'Brotes "quemados" con punta en gancho color marrón-negro. Exudado lechoso en tiempo húmedo. Avance rápido por la rama hacia el tronco.',
    condicionesFavorables: 'Floración con clima cálido (>15 °C) y húmedo. Tormentas y granizo dispersan la bacteria.',
    manejoCultural:
        'Cuarentena obligatoria — informar a las autoridades fitosanitarias. Cortar y quemar (no compostar) ramas afectadas con 30-50 cm de margen sano. Desinfectar tijeras entre cortes.',
  ),
  Plaga(
    id: 'moteado-manzano',
    nombreComun: 'Moteado',
    nombreCientifico: 'Venturia inaequalis',
    tipo: TipoPlaga.enfermedad,
    cultivoIds: ['manzano', 'peral'],
    descripcion: 'Hongo más importante del manzano en zonas húmedas. Provoca manchas foliares y desfigura el fruto.',
    sintomas: 'Manchas oliváceas en hoja y fruto, con bordes difusos. Fruto deformado y agrietado en casos graves.',
    condicionesFavorables: 'Primavera y verano húmedos. Variedades sensibles (Reineta, Golden).',
    manejoCultural: 'Recoger hojas caídas en otoño (reduce inóculo). Variedades resistentes en plantaciones nuevas.',
  ),
  Plaga(
    id: 'psila-peral',
    nombreComun: 'Psila del peral',
    nombreCientifico: 'Cacopsylla pyri',
    tipo: TipoPlaga.plaga,
    cultivoIds: ['peral'],
    descripcion: 'Hemíptero que produce melaza abundante donde se desarrolla negrilla. Plaga clave del peral.',
    sintomas: 'Brotes pegajosos por melaza, hojas y frutos cubiertos de negrilla. Defoliación en focos severos.',
    condicionesFavorables: 'Plantaciones intensivas con exceso de nitrógeno y vigor.',
    manejoCultural: 'Equilibrio nutricional (no abusar de N). Conservar enemigos naturales (Anthocoris).',
  ),

  // ─── Frutales hueso ─────────────────────────────────────
  Plaga(
    id: 'mosca-cereza',
    nombreComun: 'Mosca de la cereza',
    nombreCientifico: 'Rhagoletis cerasi',
    tipo: TipoPlaga.plaga,
    cultivoIds: ['cerezo'],
    descripcion: 'Tefrítido específico del cerezo. La hembra pone un huevo en la cereza y la larva consume la pulpa.',
    sintomas: 'Cereza con punto blando y oscuro. Larva blanca en el interior cerca del hueso.',
    condicionesFavorables: 'Veranos cálidos. Variedades tardías son las más afectadas.',
    manejoCultural: 'Trampas amarillas con atrayente desde inicio de envero. Recolección anticipada. Variedades tempranas escapan a la plaga.',
  ),
  Plaga(
    id: 'drosophila-suzukii',
    nombreComun: 'Drosophila suzukii (mosca de alas manchadas)',
    nombreCientifico: 'Drosophila suzukii',
    tipo: TipoPlaga.plaga,
    cultivoIds: ['cerezo', 'ciruelo'],
    descripcion: 'Drosofílido invasor (Asia). A diferencia de otras drosófilas, ataca fruto sano en envero. Daños severos en cerezo y frutos rojos.',
    sintomas: 'Picaduras en fruto en envero. Fruto blando y con larvas blanquecinas en pulpa.',
    condicionesFavorables: 'Cualquier zona de cultivo. Más severa en climas frescos (norte peninsular).',
    manejoCultural: 'Trampeo masivo con vinagre + vino + jabón. Mallas anti-insecto en plantaciones intensivas. Recolección frecuente.',
  ),
  Plaga(
    id: 'abolladura',
    nombreComun: 'Abolladura',
    nombreCientifico: 'Taphrina deformans',
    tipo: TipoPlaga.enfermedad,
    cultivoIds: ['melocotonero', 'nectarino', 'almendro'],
    descripcion: 'Hongo característico del melocotonero que deforma severamente las hojas en primavera.',
    sintomas: 'Hojas deformadas, abolladas, color rojizo o amarillo. Caen en pocas semanas. Brotes deformados.',
    condicionesFavorables: 'Primaveras frescas y lluviosas durante brotación.',
    manejoCultural: 'Tratamiento cúprico en yema hinchada (antes de brotación) — mejor momento. Una vez visible la abolladura, ya no hay tratamiento eficaz para esa estación.',
  ),
  Plaga(
    id: 'mosca-mediterranea',
    nombreComun: 'Mosca de la fruta',
    nombreCientifico: 'Ceratitis capitata',
    tipo: TipoPlaga.plaga,
    cultivoIds: ['melocotonero', 'nectarino', 'albaricoquero', 'caqui', 'higuera', 'citrico-naranjo', 'citrico-mandarino'],
    descripcion: 'Tefrítido polífago. Plaga muy importante en cítricos y frutales de hueso.',
    sintomas: 'Picadura en fruto. Pulpa con galerías y larvas. Fruto que cae prematuramente.',
    condicionesFavorables: 'Veranos cálidos. Frutales con cosecha en agosto-octubre.',
    manejoCultural: 'Trampeo masivo con atrayente alimenticio. Recolección anticipada de frutos picados.',
  ),

  // ─── Pistacho ──────────────────────────────────────────
  Plaga(
    id: 'verticillium-pistacho',
    nombreComun: 'Verticilosis',
    nombreCientifico: 'Verticillium dahliae',
    tipo: TipoPlaga.enfermedad,
    cultivoIds: ['pistacho', 'olivo', 'almendro'],
    descripcion:
        'Hongo de suelo extremadamente persistente. Es la principal amenaza al instalar un pistacho — los microesclerocios sobreviven 10+ años en el suelo.',
    sintomas: 'Marchitez de ramas individuales en plena vegetación, con hoja seca pegada (no cae). Sección del leño con anillo oscuro al cortar.',
    condicionesFavorables:
        'Suelos donde antes hubo cultivos hospederos (algodón, alfalfa, tomate, patata, fresa, olivo enfermo). Riego abundante. pH neutro-alcalino.',
    manejoCultural:
        'CRÍTICO: análisis de suelo (recuento de microesclerocios) ANTES de plantar. Patrones tolerantes (UCB-1 en pistacho). Evitar cultivos previos hospedantes en la rotación.',
  ),
  Plaga(
    id: 'botryosphaeria-pistacho',
    nombreComun: 'Botryosphaeria del pistacho',
    nombreCientifico: 'Botryosphaeria dothidea',
    tipo: TipoPlaga.enfermedad,
    cultivoIds: ['pistacho'],
    descripcion: 'Hongo de yemas y panículas. Emergente en plantaciones jóvenes en Castilla-La Mancha.',
    sintomas: 'Punta seca en panículas. Yemas necrosadas. Pistachos vacíos en cosecha.',
    manejoCultural: 'Poda de partes afectadas y destrucción. Tratamientos cúpricos en otoño.',
  ),

  // ─── Vid ───────────────────────────────────────────────
  Plaga(
    id: 'oidio-vid',
    nombreComun: 'Oídio',
    nombreCientifico: 'Erysiphe necator (Uncinula necator)',
    tipo: TipoPlaga.enfermedad,
    cultivoIds: ['vid'],
    descripcion: 'Hongo polvo blanco. Enfermedad fúngica más extendida en viñedo.',
    sintomas: 'Polvillo blanco-gris en hojas, brotes y racimos. Bayas agrietadas y secas. Pérdida de cosecha.',
    condicionesFavorables: 'Tiempo seco y temperaturas 20-27 °C. NO requiere agua libre (a diferencia del mildiu).',
    manejoCultural: 'Azufre espolvoreado o mojable es el clásico. Plantaciones aireadas. Variedades menos sensibles.',
  ),
  Plaga(
    id: 'mildiu',
    nombreComun: 'Mildiu',
    nombreCientifico: 'Plasmopara viticola',
    tipo: TipoPlaga.enfermedad,
    cultivoIds: ['vid'],
    descripcion: 'Oomiceto. Junto al oídio, la enfermedad clave del viñedo.',
    sintomas: 'Manchas de aceite en hoja (envés con eflorescencia blanca). Racimos secos en pasa marrón.',
    condicionesFavorables: 'Lluvia + 10 °C + hojas mojadas (regla de los "3 dieces"). Primavera y verano lluvioso.',
    manejoCultural: 'Tratamiento cúprico preventivo. Manejo de la cubierta vegetal para reducir humedad bajo cepa.',
  ),
  Plaga(
    id: 'lobesia',
    nombreComun: 'Polilla del racimo',
    nombreCientifico: 'Lobesia botrana',
    tipo: TipoPlaga.plaga,
    cultivoIds: ['vid'],
    descripcion: 'Lepidóptero con 3 generaciones. La 3.ª (sobre uva en envero) es la que produce daño económico.',
    sintomas: 'Bayas con orificio de entrada y galerías. Botritis secundaria sobre el daño.',
    manejoCultural: 'Confusión sexual con feromonas (muy extendida en las DO). Trampas para seguir el vuelo.',
  ),

  // ─── Trufa ─────────────────────────────────────────────
  Plaga(
    id: 'tuber-brumale-invasiva',
    nombreComun: 'Trufa brumale (invasión del quemado)',
    nombreCientifico: 'Tuber brumale',
    tipo: TipoPlaga.plaga,
    cultivoIds: ['tuber-melanosporum'],
    descripcion:
        'No es estrictamente una plaga sino una especie competidora del mismo nicho. Cuando coloniza un quemado de Tuber melanosporum desplaza progresivamente a la deseada, reduciendo drásticamente el valor comercial de la cosecha.',
    sintomas:
        'En la cosecha aparecen trufas de carne más oscura, con vetas blancas más anchas y aroma alcanforado en lugar del afrutado característico de melanosporum.',
    condicionesFavorables:
        'Suelos que se humedecen en exceso o se acidifican (riego mal gestionado, acolchado excesivo). Altitudes bajas. Variedades de hospedero más vigorosas.',
    manejoCultural:
        'Riego controlado (no encharcar). Muestreo regular de trufas en cosecha — las brumale no se dejan para el final de campaña: se retiran en cuanto se identifican. Encalado para mantener pH 7,8-8,2 si tiende a bajar.',
  ),
  Plaga(
    id: 'leiodes',
    nombreComun: 'Escarabajo de la trufa',
    nombreCientifico: 'Leiodes cinnamomeus',
    tipo: TipoPlaga.plaga,
    cultivoIds: ['tuber-melanosporum', 'tuber-aestivum', 'tuber-brumale'],
    descripcion: 'Coleóptero diminuto que pone huevos en trufas maduras. Las larvas consumen la gleba.',
    sintomas: 'Trufa con galerías internas blanquecinas y larvas pequeñas. Aroma rancio.',
    manejoCultural: 'Cosecha temprana y completa (no dejar trufas pasadas en el quemado). Conservación en frío inmediato.',
  ),

  // ─── Multi-cultivo ─────────────────────────────────────
  Plaga(
    id: 'pulgon',
    nombreComun: 'Pulgones',
    nombreCientifico: 'Aphididae spp.',
    tipo: TipoPlaga.plaga,
    cultivoIds: ['manzano', 'peral', 'cerezo', 'ciruelo', 'melocotonero', 'albaricoquero', 'almendro', 'citrico-naranjo', 'citrico-mandarino', 'citrico-limonero', 'higuera', 'granado'],
    descripcion: 'Grupo amplio de hemípteros chupadores. Producen melaza que da lugar a negrilla. Algunas especies vectores de virus.',
    sintomas: 'Brotes deformados, enrollados. Melaza pegajosa con negrilla negra. Hormigas en el árbol (transportan pulgones).',
    manejoCultural: 'Conservar fauna auxiliar (mariquitas, sírfidos, crisopas). Equilibrio en abonado nitrogenado (exceso de N favorece pulgón). Bandas de plantas atractivas para auxiliares.',
  ),
  Plaga(
    id: 'cochinilla',
    nombreComun: 'Cochinillas',
    nombreCientifico: 'Coccoidea spp.',
    tipo: TipoPlaga.plaga,
    cultivoIds: ['olivo', 'citrico-naranjo', 'citrico-mandarino', 'citrico-limonero', 'aguacate', 'higuera', 'granado'],
    descripcion: 'Familia amplia de hemípteros. Algunas con escudo cerúleo (cochinilla algodonosa, californiana, tizón); otras desnudas (cotonet).',
    sintomas: 'Costras circulares u ovaladas adheridas a hojas, ramas y frutos. Melaza y negrilla en algunas especies.',
    manejoCultural: 'Aceite de invierno para reducir fase invernante. Conservar parasitoides (Aphytis, Comperiella).',
  ),
  Plaga(
    id: 'helada-tardia',
    nombreComun: 'Helada tardía',
    nombreCientifico: '',
    tipo: TipoPlaga.abiotico,
    cultivoIds: ['almendro', 'albaricoquero', 'cerezo', 'ciruelo', 'melocotonero', 'nectarino', 'manzano', 'peral', 'pistacho', 'kiwi', 'caqui'],
    descripcion: 'Daño por temperaturas bajas en floración o cuajado, sobre todo en frutales de floración temprana.',
    sintomas: 'Flor o fruto recién cuajado con coloración marrón-acuosa. Caída en pocos días. Anillo necrótico en hueso de frutos jóvenes (señal típica).',
    condicionesFavorables: 'Marzo-abril con descenso brusco nocturno. Vaguadas y zonas bajas con acumulación de aire frío.',
    manejoCultural: 'Variedades de floración tardía. No plantar en zonas bajas. Riego antiheladas por aspersión durante la noche fría (mantiene 0 °C por liberación de calor latente). Calefacción con velas/quemadores en plantaciones de alto valor.',
  ),
];

/// Devuelve las plagas que afectan a un cultivo concreto.
List<Plaga> plagasDeCultivo(String cultivoId) {
  return [for (final p in catalogoPlagas) if (p.cultivoIds.contains(cultivoId)) p];
}

/// Devuelve la plaga por id, o null si no existe.
Plaga? plagaPorId(String id) {
  for (final p in catalogoPlagas) {
    if (p.id == id) return p;
  }
  return null;
}
