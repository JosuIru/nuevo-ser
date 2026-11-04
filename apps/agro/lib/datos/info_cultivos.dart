/// Información agronómica ampliada por cultivo, complementaria al
/// `catalogoCultivos` (que vive en datos/catalogo_cultivos.dart y guarda
/// id, nombre, color, variedades sugeridas).
///
/// **Conservador a propósito**: hechos genéricos de cultivo (origen,
/// requisitos típicos, calendario aproximado) para Iberia. Sin
/// recomendaciones de tratamientos ni nombres comerciales — eso entra
/// en F2 con catálogo curado y validación de un agrónomo. La sección
/// "plagasNotables" es texto descriptivo libre, NO recetario.
///
/// Si un id no tiene entrada aquí, la guía muestra sólo lo del catálogo
/// base (es no-breaking añadir cultivos nuevos al `catalogoCultivos`
/// sin entrada en este fichero).
class InfoCultivo {
  final String descripcion;
  final String exigencias;
  final String calendario;
  final String plagasNotables;

  const InfoCultivo({
    required this.descripcion,
    required this.exigencias,
    this.calendario = '',
    this.plagasNotables = '',
  });
}

/// Mapa por id de cultivo (los mismos ids que en `catalogoCultivos`).
const Map<String, InfoCultivo> infoCultivos = {
  // ─── Truficultura ──────────────────────────────────────
  'tuber-melanosporum': InfoCultivo(
    descripcion:
        'Trufa negra o trufa de Périgord. Hongo micorrícico que vive en simbiosis con las raíces de árboles hospedantes (encina, roble, avellano). Su ciclo entero ocurre bajo tierra; la cosecha (de noviembre a marzo) requiere can entrenado o cerdo. Es el producto agrícola con mayor valor por kilo de Iberia tras el azafrán.',
    exigencias:
        'Suelo calizo (pH 7,5–8,5), bien drenado, pedregoso. Altitud 600–1.500 m. Precipitación 400–900 mm/año, con verano seco e invierno suave. España (Soria, Teruel, Huesca) y Aragón concentran la mayor superficie europea.',
    calendario:
        'Plantación: nov–marzo (planta micorrizada certificada).\nMantenimiento: poda de formación del 2.º al 4.º año, riego de apoyo en verano (~25-40 L/árbol/semana sequía).\nCosecha: nov–marzo (Tuber melanosporum).',
    plagasNotables:
        'Trufa brumale (Tuber brumale) que coloniza el quemado y desplaza a la melanosporum si el suelo se acidifica o se humedece en exceso. Insectos: Leiodes cinnamomeus (escarabajo de la trufa). Vertebrados: jabalí, corzo. Disponible recetario detallado en v2.',
  ),
  'tuber-aestivum': InfoCultivo(
    descripcion:
        'Trufa de verano o "scorzone". Más rústica que la melanosporum, soporta más humedad y menor pH. Cosecha de mayo a septiembre. Aroma menos intenso pero mercado en expansión por su menor precio.',
    exigencias:
        'pH 6,5–8,5 (más tolerante que melanosporum). Acepta más altitud (hasta 1.700 m) y mayor pluviometría. Hospederos similares.',
    calendario:
        'Plantación: nov–abril.\nCosecha: mayo–septiembre.',
    plagasNotables: 'Disponible en v2 con catálogo curado.',
  ),
  'tuber-brumale': InfoCultivo(
    descripcion:
        'Trufa de invierno. Coloniza el mismo nicho que la melanosporum y muchas veces aparece en plantaciones donde se intentaba producir melanosporum (es invasora del quemado). Su valor de mercado es menor.',
    exigencias:
        'Tolera mayor humedad y menor temperatura que melanosporum. En convivencia con melanosporum tiende a ganarle terreno si el suelo no se gestiona adecuadamente.',
    calendario: 'Cosecha: nov–marzo.',
    plagasNotables: 'Disponible en v2 con catálogo curado.',
  ),

  // ─── Forestal / dehesa ─────────────────────────────────
  'encina': InfoCultivo(
    descripcion:
        'Quercus de hoja perenne, emblemático de la dehesa ibérica. Soporta fríos rigurosos y veranos secos. Su bellota alimenta cerdo ibérico (montanera). Es el hospedero más usado en truficultura por su buena tolerancia a la micorrización con Tuber melanosporum y por su rusticidad. La subespecie ballota (carrasca) es la habitual en plantaciones truferas de interior.',
    exigencias:
        'pH 6,0–8,5 (muy tolerante a caliza). Pluviometría 350–1.000 mm. Resiste heladas hasta -15 °C. Suelo profundo o pedregoso bien drenado.',
    calendario:
        'Floración: mayo (vientos dispersan polen).\nBellota: octubre–diciembre (montanera).\nPoda: invierno (cada 6-10 años en dehesa).',
    plagasNotables:
        'Seca de la encina (Phytophthora cinnamomi) — afección crítica que está mermando dehesas en SO peninsular. Lagarta peluda, oruga procesionaria, perforadores. v2.',
  ),
  'roble-carrasqueno': InfoCultivo(
    descripcion:
        'Quercus marcescente de hoja semi-perenne (la hoja seca persiste hasta primavera). Crece más rápido que la encina y produce trufas con menos demora desde la plantación (4–7 años frente a 6–10 años en encina). Hospedero muy valorado en truficultura por su precocidad.',
    exigencias:
        'pH 6,5–8,0. Pluviometría 500–900 mm. Soporta heladas hasta -20 °C. Suelos calizos, frescos, profundos.',
    calendario: 'Floración: abril–mayo. Bellota: octubre–noviembre.',
  ),
  'coscoja': InfoCultivo(
    descripcion:
        'Quercus arbustivo de hoja perenne con borde espinoso. Más pequeña que la encina pero también micorriza con melanosporum. Se usa en zonas con suelos muy pedregosos donde la encina cuesta arraigar.',
    exigencias: 'pH 7,0–8,5. Sequía extrema. Suelos calizos pobres.',
  ),
  'alcornoque': InfoCultivo(
    descripcion:
        'Quercus de corteza gruesa que produce corcho (descorche cada 9–12 años). Cultivo emblemático del SO peninsular. Su bellota también alimenta cerdo ibérico, aunque menos dulce que la de encina.',
    exigencias:
        'pH 5,0–7,0 (silicícola — suelos ácidos). NO tolera caliza. Pluviometría 500–1.000 mm. Climas suaves.',
    calendario: 'Descorche: junio–agosto, cada 9–12 años una vez el árbol alcanza ~65 cm de circunferencia.',
    plagasNotables: 'Seca del alcornoque (Phytophthora cinnamomi), culebrilla del corcho (Coraebus undatus). v2.',
  ),
  'tilo': InfoCultivo(
    descripcion:
        'Árbol caducifolio ornamental y forestal. En truficultura puede actuar como hospedero de Tuber aestivum en climas más frescos. Sus flores son muy apreciadas en apicultura.',
    exigencias: 'pH 6,0–7,5. Suelos profundos y frescos. Climas templados.',
  ),
  'pino-pinonero': InfoCultivo(
    descripcion:
        'Pino mediterráneo cultivado por sus piñones. Producción concentrada en Castilla y León, Andalucía y Cataluña. Largo periodo improductivo (15–20 años hasta primer fruto comercial).',
    exigencias: 'pH 5,5–7,5. Suelos arenosos preferiblemente. Sequía estival tolerada.',
    calendario: 'Recolección de piña: octubre–marzo (la piña madura tras 3 años desde la floración).',
    plagasNotables: 'Procesionaria del pino (Thaumetopoea pityocampa), Leptoglossus occidentalis (chinche del piñón, plaga reciente que vacía piñones). v2.',
  ),
  'chopo': InfoCultivo(
    descripcion:
        'Frondosa de crecimiento muy rápido (turno 12–18 años). Cultivo intensivo en regadío para madera de chapa, palets y biomasa. Plantación en marco regular 5×5 o 6×3 m según destino.',
    exigencias:
        'pH 5,5–8,0. Suelo profundo, fértil, con freático cercano. Necesita mucha agua (1.000+ mm o riego).',
    calendario: 'Plantación: enero–marzo (estaca o planta a raíz desnuda). Corta: invierno del año 12–18.',
    plagasNotables: 'Royas (Melampsora), Marssonina, defoliadores. v2.',
  ),
  'sauce': InfoCultivo(
    descripcion: 'Frondosa ribereña de crecimiento rápido. Usado en silvicultura, restauración fluvial y como cortavientos en plantaciones intensivas.',
    exigencias: 'Suelo fresco a encharcado. Pluviometría >700 mm o freático cercano.',
  ),

  // ─── Frutales pepita ───────────────────────────────────
  'manzano': InfoCultivo(
    descripcion:
        'Frutal de pepita más extendido en climas templados. La cv. y patrón determinan vigor, precocidad y tamaño final del árbol. En Iberia se cultiva desde el norte atlántico (Asturias, Cantabria) hasta zonas frías de interior.',
    exigencias:
        'Suelo profundo, bien drenado, ligeramente ácido a neutro (pH 6,0–7,0). Necesita horas-frío (>800 h <7 °C) variables por variedad. Temperaturas óptimas 18–24 °C en cuajado.',
    calendario:
        'Floración: abril.\nCuajado: mayo.\nCosecha: agosto–octubre según variedad.\nPoda: invierno (descanso vegetativo).',
    plagasNotables:
        'Carpocapsa (Cydia pomonella), pulgones, oídio, moteado (Venturia inaequalis), monilia. Recetario detallado en v2.',
  ),
  'peral': InfoCultivo(
    descripcion:
        'Frutal de pepita similar al manzano pero más sensible a frío tardío y a caliza activa del suelo. Su patrón habitual en injerto es membrillero (control de vigor) o franco peral (mayor longevidad).',
    exigencias:
        'pH 6,0–7,5. Sensible a clorosis férrica si la caliza activa supera el 8 %. Necesita horas-frío 700–1000 h.',
    calendario:
        'Floración: marzo–abril (sensible a heladas tardías).\nCosecha: julio–octubre según variedad.',
    plagasNotables:
        'Psila del peral (Cacopsylla pyri), fuego bacteriano (Erwinia amylovora), moteado, stemphylium. Disponible en v2.',
  ),
  'membrillero': InfoCultivo(
    descripcion:
        'Frutal pequeño y rústico, muy productivo. Su fruto se consume cocinado (dulce de membrillo). Patrón habitual de peral por enanización y precocidad.',
    exigencias: 'Tolera suelos pesados; pH 6,0–7,5. Riego moderado.',
    calendario: 'Cosecha: octubre–noviembre.',
  ),

  // ─── Frutales hueso ────────────────────────────────────
  'cerezo': InfoCultivo(
    descripcion:
        'Frutal de hueso de alto valor en Iberia (Jerte, Caderechas, Aragón). Variedades autocompatibles e incompatibles obligan a planificar polinizadores. Patrones modernos (Gisela 5/6) permiten plantaciones intensivas.',
    exigencias:
        'pH 6,5–7,5. Necesita 800–1.200 horas-frío. Sensible al rajado de fruto por lluvia en cosecha.',
    calendario:
        'Floración: marzo–abril.\nCosecha: mayo–julio según variedad.\nPoda: post-cosecha en verde (evita Pseudomonas).',
    plagasNotables:
        'Mosca de la cereza (Rhagoletis cerasi), Drosophila suzukii, monilia, gomosis (Pseudomonas). Disponible en v2.',
  ),
  'ciruelo': InfoCultivo(
    descripcion:
        'Grupo amplio (japonesas, europeas). Las japonesas (P. salicina) son más precoces; las europeas (P. domestica) más rústicas y aptas para deshidratado.',
    exigencias: 'pH 6,0–7,5. Resistente a heladas medias.',
    calendario: 'Cosecha: junio–septiembre según variedad.',
    plagasNotables: 'Pulgón harinoso, monilia, moniliosis. v2.',
  ),
  'melocotonero': InfoCultivo(
    descripcion:
        'Frutal de hueso de ciclo corto y árbol de vida relativamente breve (15-20 años). Variedades de muy distinta época permiten escalonar cosecha de mayo a octubre.',
    exigencias:
        'pH 6,0–7,0. Sensible a clorosis si caliza activa alta. Riego abundante en cuajado y engorde.',
    calendario:
        'Floración: febrero–marzo (heladas tardías son riesgo).\nCosecha: mayo–octubre.',
    plagasNotables:
        'Mosca de la fruta (Ceratitis capitata), oídio, abolladura (Taphrina deformans), pulgón verde. v2.',
  ),
  'albaricoquero': InfoCultivo(
    descripcion:
        'Frutal mediterráneo de floración muy temprana. Sus hectáreas en España (Murcia) son referencia mundial.',
    exigencias: 'pH 6,5–7,5. Pocos requerimientos hídricos. Sensible a heladas tardías.',
    calendario: 'Floración: febrero. Cosecha: mayo–julio.',
  ),
  'nectarino': InfoCultivo(
    descripcion: 'Variedad de melocotonero con fruto de piel lisa. Mismo manejo y exigencias.',
    exigencias: 'Idénticas al melocotonero.',
  ),

  // ─── Frutos secos ──────────────────────────────────────
  'almendro': InfoCultivo(
    descripcion:
        'Frutal de hueso seco, rústico y resistente a sequía. España es el 2.º productor mundial. Variedades autocompatibles modernas (Guara, Soleta, Lauranne, Vairo, Penta) han revolucionado el cultivo.',
    exigencias:
        'pH 6,5–8,5 (tolera caliza). Pluviometría 300–600 mm. Sensible a heladas tardías en floración temprana.',
    calendario:
        'Floración: febrero–marzo.\nCosecha: agosto–septiembre.',
    plagasNotables:
        'Avispilla del almendro (Eurytoma amygdali), monilia, mancha ocre (Polystigma), abolladura. v2.',
  ),
  'pistacho': InfoCultivo(
    descripcion:
        'Cultivo en fuerte expansión en Iberia (Castilla-La Mancha, Aragón, Andalucía). Especie dioica: necesita polinizador macho (~1 cada 8-10 hembras). Vecería intensa: año cargado se alterna con año descargado.',
    exigencias:
        'pH 7,0–8,5 (tolera caliza alta). Sequía extrema (300-600 mm). Necesita 1.000+ horas-frío. Suelo muy bien drenado — sensible a Verticillium en suelos pesados.',
    calendario:
        'Floración: abril–mayo.\nCosecha: septiembre–octubre.\nPoda: invierno.',
    plagasNotables:
        'Verticillium (riesgo crítico al plantar — análisis previo de suelo obligatorio), barrenador (Chaetoptelius vestitus), Botryosphaeria. v2.',
  ),
  'nogal': InfoCultivo(
    descripcion:
        'Para fruto y madera. Especie longeva (>50 años) y de gran porte. Plantación moderna intensiva en patrón Paradox sobre marco 7×7 m.',
    exigencias:
        'pH 6,5–7,5. Suelo profundo, fértil, bien drenado. Sensible a heladas tardías y a Phytophthora si hay encharcamiento.',
    calendario: 'Cosecha: septiembre–octubre. Floración: abril–mayo.',
    plagasNotables: 'Carpocapsa, antracnosis, bacteriosis. v2.',
  ),
  'avellano': InfoCultivo(
    descripcion:
        'Cultivo tradicional en Tarragona, Asturias y Cantabria. Especie monoica de polinización anemófila — floración invernal.',
    exigencias: 'pH 6,0–7,5. Suelo fresco. Tolera heladas.',
    calendario: 'Floración: enero. Cosecha: agosto–septiembre.',
  ),
  'castano': InfoCultivo(
    descripcion:
        'Frutal y forestal de zonas atlánticas (Galicia, Asturias, El Bierzo) y de montaña (Sierra de Aracena). Híbridos eurojaponeses (Marigoule, Bouche de Bétizac) resisten Phytophthora cinnamomi.',
    exigencias: 'pH 5,0–6,5 (acidófilo). Suelo profundo y fresco. Pluviometría >800 mm.',
    calendario: 'Cosecha: octubre–noviembre.',
    plagasNotables: 'Avispilla del castaño (Dryocosmus kuriphilus), tinta (Phytophthora), chancro (Cryphonectria). v2.',
  ),

  // ─── Olivo ─────────────────────────────────────────────
  'olivo': InfoCultivo(
    descripcion:
        'Cultivo emblemático de Iberia. España produce ~50 % del aceite mundial. Marco tradicional 10×10 m, intensivo 6×3, superintensivo 1,5×4 con variedades de bajo vigor (Arbequina, Arbosana, Koroneiki). Vecería marcada.',
    exigencias:
        'pH 6,0–8,5 (muy tolerante). Pluviometría 300–700 mm. Resiste sequía extrema. Sensible a heladas <-10 °C prolongadas.',
    calendario:
        'Floración: mayo.\nCuajado y crecimiento del fruto: jun–sep.\nCosecha: octubre–enero según destino (verde para mesa, maduro para aceite).\nPoda: febrero–marzo (post-helada).',
    plagasNotables:
        'Mosca del olivo (Bactrocera oleae) — la más importante. Repilo (Spilocaea oleagina), tuberculosis (Pseudomonas savastanoi), prays, cochinilla. Verticillium en suelos contaminados. v2.',
  ),

  // ─── Vid ───────────────────────────────────────────────
  'vid': InfoCultivo(
    descripcion:
        'Cultivo más extenso de España (~950.000 ha). Las DO dictan variedades, marcos y prácticas. Patrones americanos resistentes a filoxera son obligatorios.',
    exigencias:
        'pH 6,0–8,0. Suelos pobres, drenados. Mesoclima por DO.',
    calendario:
        'Brotación: marzo–abril.\nFloración: mayo–junio.\nEnvero: julio–agosto.\nVendimia: agosto–octubre.\nPoda: dic–febrero.',
    plagasNotables:
        'Oídio, mildiu, botritis, polilla del racimo (Lobesia botrana), filoxera (controlada por patrón). v2.',
  ),

  // ─── Otros ─────────────────────────────────────────────
  'higuera': InfoCultivo(
    descripcion:
        'Frutal mediterráneo muy rústico. Algunas variedades dan dos cosechas (brevas en junio, higos en agosto–septiembre). Otras solo higos.',
    exigencias: 'pH 6,0–8,0. Tolerancia extrema a sequía.',
    calendario: 'Brevas: junio. Higos: agosto–septiembre.',
  ),
  'granado': InfoCultivo(
    descripcion: 'Frutal mediterráneo de floración prolongada. Mollar de Elche es la variedad española de referencia.',
    exigencias: 'pH 6,0–8,0. Tolerante a salinidad. Resiste sequía.',
    calendario: 'Cosecha: octubre–noviembre.',
  ),
  'kiwi': InfoCultivo(
    descripcion: 'Liana dioica (necesita planta macho polinizadora ~1:8). Cultivo intensivo en estructura.',
    exigencias: 'pH 5,5–6,5. Pluviometría >1.000 mm o riego abundante. Sensible a heladas tardías.',
    calendario: 'Cosecha: octubre–noviembre.',
  ),
  'caqui': InfoCultivo(
    descripcion: 'Cultivo en fuerte expansión en Valencia (DO Kaki Ribera del Xúquer). Variedad Rojo Brillante con desastringencia en cámara.',
    exigencias: 'pH 6,0–7,0. Sensible a heladas tardías.',
    calendario: 'Cosecha: octubre–diciembre.',
  ),
  'aguacate': InfoCultivo(
    descripcion: 'Cultivo subtropical (Costa Tropical Granada-Málaga). Variedades tipo A y B con horarios de floración complementarios para polinización cruzada.',
    exigencias: 'pH 5,5–7,0. Sensible al frío (<0 °C daños). Suelo muy bien drenado (Phytophthora cinnamomi).',
    calendario: 'Cosecha: variable según variedad (Hass: oct–jun).',
  ),
  'citrico-naranjo': InfoCultivo(
    descripcion: 'Cítrico de fruto dulce. Levante español es referencia mundial. Patrones modernos (Citrange Carrizo) sustituyeron al naranjo amargo por resistencia a virus tristeza.',
    exigencias: 'pH 6,0–7,5. Sin heladas <-3 °C. Riego regular.',
    calendario: 'Floración: marzo–abril. Cosecha: variable según variedad (Navelina nov, Valencia Late mar–jun).',
    plagasNotables: 'Cotonet (Delottococcus aberiae), pulgones, minador de hojas, mosca de la fruta (Ceratitis), HLB (cuarentena). v2.',
  ),
  'citrico-mandarino': InfoCultivo(
    descripcion: 'Grupo de cítricos pequeños (clementinas, satsumas, híbridos como Tango, Nadorcott). Variedades sin semilla son las más demandadas.',
    exigencias: 'Idénticas al naranjo.',
    calendario: 'Cosecha: octubre–marzo según variedad.',
  ),
  'citrico-limonero': InfoCultivo(
    descripcion: 'Cítrico ácido, refloreciente. Da fruto casi todo el año en zonas cálidas (Murcia).',
    exigencias: 'pH 6,0–7,5. Sensible al frío.',
    calendario: 'Cosecha: variable. Verna primavera-verano, Fino otoño-invierno.',
  ),
};
