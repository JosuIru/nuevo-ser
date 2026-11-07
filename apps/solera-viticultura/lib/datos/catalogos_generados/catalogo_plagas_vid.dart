// GENERADO AUTOMÁTICAMENTE — NO EDITAR A MANO.
//
// Fuente: content/viticultura/plagas_vid.csv
// Generado: 2026-11-07
// Filas: 21 (0 revisadas, 21 pendientes de revisión)
//
// ⚠ DATOS PROVISIONALES SIN VALIDAR AGRONÓMICA/ENOLÓGICAMENTE.
// La app muestra un banner mientras este flag siga activo.
// Para regenerar: cd apps/solera-viticultura && dart run tool/compilar_catalogos.dart

/// Tipo de incidencia. Coincide con el dropdown del formulario de
/// incidencia (`tipo` en la BD) salvo que ese también acepta `estres`
/// y `otro` para entradas libres.
enum TipoPlagaVid { enfermedad, plaga, fisiologico, abiotico }

class PlagaVid {
  final String id;
  final String nombreComun;
  final String nombreCientifico;
  final TipoPlagaVid tipo;
  final String sintomas;
  final String condicionesFavorables;
  final String manejoCultural;
  /// `true` para enfermedades reguladas que requieren notificación a Servicios
  /// Fitosanitarios CCAA. Hoy ningún registro lo tiene activo — pendiente de que
  /// el agrónomo asesor incluya Xylella, Flavescencia dorada y similares.
  final bool declaracionOficial;

  const PlagaVid({
    required this.id,
    required this.nombreComun,
    this.nombreCientifico = '',
    required this.tipo,
    this.sintomas = '',
    this.condicionesFavorables = '',
    this.manejoCultural = '',
    this.declaracionOficial = false,
  });
}

const List<PlagaVid> catalogoPlagasVid = [
  PlagaVid(
    id: 'mildiu',
    nombreComun: 'Mildiu',
    nombreCientifico: 'Plasmopara viticola',
    tipo: TipoPlagaVid.enfermedad,
    sintomas: 'Manchas amarillas aceitosas en haz; pelusa blanca en envés. En racimos: bayas marrones momificadas.',
    condicionesFavorables: 'Humedad alta + temperatura 18-25°C. Lluvia tras brotación.',
    manejoCultural: 'Eliminar restos de poda. Mejorar aireación con deshojado y poda en verde. Evitar riego foliar.',
  ),
  PlagaVid(
    id: 'oidio',
    nombreComun: 'Oídio',
    nombreCientifico: 'Erysiphe necator',
    tipo: TipoPlagaVid.enfermedad,
    sintomas: 'Polvillo blanco grisáceo en hojas y racimos. Bayas agrietadas.',
    condicionesFavorables: 'Calor seco 20-28°C. Sombras y vegetación densa.',
    manejoCultural: 'Deshojado en zona de racimos para airear. Evitar abonado nitrogenado excesivo. Poda en verde.',
  ),
  PlagaVid(
    id: 'botritis',
    nombreComun: 'Botritis o podredumbre gris',
    nombreCientifico: 'Botrytis cinerea',
    tipo: TipoPlagaVid.enfermedad,
    sintomas: 'Pelusa gris sobre racimos maduros. Bayas reventadas y podridas.',
    condicionesFavorables: 'Humedad alta cerca de vendimia. Heridas previas (granizo polilla).',
    manejoCultural: 'Vendimiar a tiempo. Eliminar racimos heridos. Aireación con deshojado.',
  ),
  PlagaVid(
    id: 'black_rot',
    nombreComun: 'Black-rot',
    nombreCientifico: 'Guignardia bidwellii',
    tipo: TipoPlagaVid.enfermedad,
    sintomas: 'Manchas pardas circulares en hojas. Bayas momificadas con puntos negros.',
    condicionesFavorables: 'Humedad y temperatura cálida 20-25°C.',
    manejoCultural: 'Eliminar momias y restos. Buena aireación.',
  ),
  PlagaVid(
    id: 'excoriosis',
    nombreComun: 'Excoriosis',
    nombreCientifico: 'Phomopsis viticola',
    tipo: TipoPlagaVid.enfermedad,
    sintomas: 'Lesiones negras en sarmientos jóvenes. Hojas con puntos pequeños.',
    condicionesFavorables: 'Lluvia en brotación temprana.',
    manejoCultural: 'Poda eliminando madera afectada. Quemar restos.',
  ),
  PlagaVid(
    id: 'eutipiosis',
    nombreComun: 'Eutipiosis',
    nombreCientifico: 'Eutypa lata',
    tipo: TipoPlagaVid.enfermedad,
    sintomas: 'Brotes raquíticos con entrenudos cortos. Hojas pequeñas y deformes. Tejido necrótico bajo corteza.',
    condicionesFavorables: 'Heridas de poda en humedad.',
    manejoCultural: 'Podar en seco al final del invierno. Cortar bien por debajo de la madera afectada. Proteger heridas grandes.',
  ),
  PlagaVid(
    id: 'yesca',
    nombreComun: 'Yesca',
    tipo: TipoPlagaVid.enfermedad,
    sintomas: 'Hojas con bandas amarillas/rojizas entre nervios. Apoplejía: muerte súbita de la cepa en verano.',
    condicionesFavorables: 'Heridas de injerto y poda. Suelo y agua estresada.',
    manejoCultural: 'Podar en seco. Eliminar cepas afectadas con apoplejía.',
  ),
  PlagaVid(
    id: 'brazo_muerto',
    nombreComun: 'Brazo muerto',
    nombreCientifico: 'Lasiodiplodia theobromae',
    tipo: TipoPlagaVid.enfermedad,
    sintomas: 'Brazos secos sin brotación. Tejido oscuro bajo corteza.',
    condicionesFavorables: 'Estrés hídrico y heridas.',
    manejoCultural: 'Cortar el brazo afectado bien por debajo del límite necrótico.',
  ),
  PlagaVid(
    id: 'polilla_racimo',
    nombreComun: 'Polilla del racimo',
    nombreCientifico: 'Lobesia botrana',
    tipo: TipoPlagaVid.plaga,
    sintomas: 'Larvas en racimos: en flor (1ª gen) y en grano (2ª y 3ª gen). Galerías y bayas perforadas. Vía de entrada para botritis.',
    condicionesFavorables: 'Calor 20-25°C. Tres generaciones por campaña en clima mediterráneo.',
    manejoCultural: 'Confusión sexual con feromonas. Trampeo masivo. Eliminar bayas afectadas. Vendimiar a tiempo.',
  ),
  PlagaVid(
    id: 'mosquito_verde',
    nombreComun: 'Mosquito verde',
    nombreCientifico: 'Empoasca vitis',
    tipo: TipoPlagaVid.plaga,
    sintomas: 'Hojas con bordes amarillentos/rojizos enrollados. Punteado clorótico.',
    condicionesFavorables: 'Mayo-septiembre. Vegetación tierna.',
    manejoCultural: 'Cubierta vegetal espontánea para fauna útil. Evitar abonado nitrogenado excesivo.',
  ),
  PlagaVid(
    id: 'acaros_eriofidos',
    nombreComun: 'Ácaros eriófidos (acariosis y erinosis)',
    nombreCientifico: 'Calepitrimerus vitis',
    tipo: TipoPlagaVid.plaga,
    sintomas: 'Acariosis: brotes detenidos primavera. Erinosis: agallas afelpadas en envés.',
    condicionesFavorables: 'Brotación. Acariosis en primavera fría.',
    manejoCultural: 'Tolerar daño bajo. Conservar fauna útil (ácaros depredadores).',
  ),
  PlagaVid(
    id: 'filoxera',
    nombreComun: 'Filoxera',
    nombreCientifico: 'Daktulosphaira vitifoliae',
    tipo: TipoPlagaVid.plaga,
    sintomas: 'En vid franca: agallas en raíces, decaimiento, muerte. En patrón resistente: agallas foliares (variantes).',
    condicionesFavorables: 'Suelos no arenosos.',
    manejoCultural: 'Plantar siempre sobre patrón americano resistente. La vid franca peninsular es inviable salvo en arenales.',
  ),
  PlagaVid(
    id: 'corrimiento',
    nombreComun: 'Corrimiento',
    tipo: TipoPlagaVid.fisiologico,
    sintomas: 'Cuajado deficiente: muchas flores caen sin cuajar. Racimos ralos.',
    condicionesFavorables: 'Frío o lluvia durante floración. Desequilibrio nutricional.',
    manejoCultural: 'Equilibrar nitrógeno. Despunte en floración para reducir competencia.',
  ),
  PlagaVid(
    id: 'golpe_de_calor',
    nombreComun: 'Golpe de calor',
    tipo: TipoPlagaVid.abiotico,
    sintomas: 'Bayas asoleadas con quemaduras. Pasificación rápida.',
    condicionesFavorables: 'Temperaturas >38°C con exposición directa.',
    manejoCultural: 'Evitar deshojado excesivo en lado de poniente. Mantener cobertura vegetal.',
  ),
  PlagaVid(
    id: 'granizo',
    nombreComun: 'Granizo',
    tipo: TipoPlagaVid.abiotico,
    sintomas: 'Heridas en hojas brotes y racimos. Vía de entrada para enfermedades.',
    condicionesFavorables: 'Tormentas de verano.',
    manejoCultural: 'Si grave: poda de saneamiento. Vigilar entrada de botritis.',
  ),
  PlagaVid(
    id: 'deficit_hidrico',
    nombreComun: 'Déficit hídrico',
    tipo: TipoPlagaVid.abiotico,
    sintomas: 'Hojas amarillentas y luego marrones. Maduración bloqueada. Bayas pequeñas y deshidratadas.',
    condicionesFavorables: 'Sequía en suelo poco profundo.',
    manejoCultural: 'Si hay riego: aplicar. Si no: aceptar la cosecha reducida y planificar reservas para próximo año.',
  ),
  PlagaVid(
    id: 'deficiencia_potasio',
    nombreComun: 'Deficiencia de potasio',
    tipo: TipoPlagaVid.fisiologico,
    sintomas: 'Hojas con bordes secos y necrosados. Maduración irregular.',
    condicionesFavorables: 'Suelos arenosos o muy lavados.',
    manejoCultural: 'Abonado de potasio en otoño/invierno.',
  ),
  PlagaVid(
    id: 'deficiencia_magnesio',
    nombreComun: 'Deficiencia de magnesio',
    tipo: TipoPlagaVid.fisiologico,
    sintomas: 'Manchas amarillas/rojizas internervales en hojas viejas.',
    condicionesFavorables: 'Suelos ácidos o exceso de potasio.',
    manejoCultural: 'Aporte de magnesio (sulfato magnésico foliar o al suelo).',
  ),
  PlagaVid(
    id: 'fitotoxicidad_herbicida',
    nombreComun: 'Fitotoxicidad por herbicida',
    tipo: TipoPlagaVid.abiotico,
    sintomas: 'Hojas deformes en cuchara o abullonadas. Brotes raquíticos.',
    condicionesFavorables: 'Deriva de herbicida vecino o aplicación incorrecta.',
    manejoCultural: 'Identificar fuente. Lavado con riego. Si grave puede afectar varias campañas.',
  ),
  PlagaVid(
    id: 'xylella_pierce',
    nombreComun: 'Xylella - síndrome de Pierce de la vid',
    nombreCientifico: 'Xylella fastidiosa subsp. multiplex',
    tipo: TipoPlagaVid.enfermedad,
    sintomas: 'Hojas con quemaduras marginales (escaldadura) avanzando hacia el centro. Sarmientos secos. Cepa decae y muere en 1-3 campañas.',
    condicionesFavorables: 'Vector chinche escupidor (Philaenus spumarius). Presente en Mallorca con brotes detectados en Extremadura 2025.',
    manejoCultural: 'Erradicación de cepas sintomáticas y zona tampón 100m. Control vector con cubierta vegetal manejada. NO existe tratamiento curativo.',
    declaracionOficial: true,
  ),
  PlagaVid(
    id: 'flavescencia_dorada',
    nombreComun: 'Flavescencia dorada',
    nombreCientifico: 'Candidatus Phytoplasma vitis',
    tipo: TipoPlagaVid.enfermedad,
    sintomas: 'Hojas enrolladas hacia el envés con coloración amarilla (variedades blancas) o rojiza (tintas) y aspecto cuero. Sarmientos no agostan. Racimos secos.',
    condicionesFavorables: 'Vector cicadélido Scaphoideus titanus. Plaga cuarentenaria UE A2 — presente en Francia y Italia amenaza península.',
    manejoCultural: 'Arranque obligatorio de cepas sintomáticas. Tratamiento insecticida del vector según protocolo. Material vegetal certificado.',
    declaracionOficial: true,
  ),
];

PlagaVid? plagaPorId(String id) {
  for (final p in catalogoPlagasVid) {
    if (p.id == id) return p;
  }
  return null;
}

/// Plagas de declaración obligatoria — la app las destaca con banner rojo.
/// Hoy la lista puede estar vacía (depende de la columna `declaracion_oficial`)
/// — el agrónomo asesor decide qué activar (Xylella, Flavescencia dorada…).
List<PlagaVid> patologiasDeclaracionObligatoria() {
  return catalogoPlagasVid.where((p) => p.declaracionOficial).toList();
}

/// Mapea el `tipo` enumerado del catálogo al string que espera la BD
/// del modelo `Incidencia` (`plaga`, `enfermedad`, `fisiologico`, `otro`).
/// Los abióticos se mapean a `otro` porque el formulario no los distingue.
String tipoIncidenciaParaBd(TipoPlagaVid tipo) {
  switch (tipo) {
    case TipoPlagaVid.enfermedad:
      return 'enfermedad';
    case TipoPlagaVid.plaga:
      return 'plaga';
    case TipoPlagaVid.fisiologico:
      return 'fisiologico';
    case TipoPlagaVid.abiotico:
      return 'otro';
  }
}

/// Busca por id exacto > nombre común > nombre científico. Usado por
/// el modal IA para marcar diagnósticos como "validados por catálogo".
PlagaVid? plagaPorBusquedaFuzzy(String nombreComun, String nombreCientifico) {
  final qComun = _normalizar(nombreComun);
  final qCient = _normalizar(nombreCientifico);
  if (qComun.isEmpty && qCient.isEmpty) return null;
  for (final p in catalogoPlagasVid) {
    if (qCient.isNotEmpty && p.nombreCientifico.isNotEmpty &&
        _normalizar(p.nombreCientifico).contains(qCient)) {
      return p;
    }
    if (qComun.isNotEmpty && _normalizar(p.nombreComun).contains(qComun)) {
      return p;
    }
  }
  return null;
}

List<PlagaVid> buscarPlagasVid(String texto) {
  final q = _normalizar(texto);
  if (q.isEmpty) return const [];
  return catalogoPlagasVid.where((p) {
    return _normalizar(p.nombreComun).contains(q) ||
        _normalizar(p.nombreCientifico).contains(q) ||
        _normalizar(p.id).contains(q);
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

