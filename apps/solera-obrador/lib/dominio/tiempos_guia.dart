import 'planificador_hornada.dart';

/// Tiempos de las 10 recetas de la guía, para el planificador.
///
/// **De dónde sale cada número** (todo ORIENTATIVO, como la guía):
/// - Autólisis, primera fermentación, fermentación final y cocción: los
///   rangos escritos en `content/obrador/guia_recetas.csv` (columnas del
///   mismo nombre), a la `temperatura_masa_c` de la receta. Un test
///   comprueba que cada rango aparece en el texto de la guía.
/// - Autólisis: solo donde la guía la da por «recomendable» (si dice
///   «opcional» o «no se usa», no entra en el plan).
/// - Precalentar el horno: 30-45 min, de la ficha «Horno doméstico con
///   vapor» de la guía (45-60 min con olla o piedra, fichas «Olla de
///   hierro» y «Piedra o acero»).
/// - Amasado, formado y enfriado: la guía describe cómo, no cuánto. Son
///   **estimaciones de la app** para un obrador pequeño; el centeno reposa
///   12-24 h antes de cortar (lo dice la guía).
/// - Refresco de la masa madre: 4-8 h a 25 °C para un refresco 1:1:1 (la
///   guía, ficha «Refrescos y proporciones», dice «pocas horas»; el número
///   es una estimación). Si la persona apunta las horas hasta el pico de
///   sus refrescos, el plan usa las suyas.
const _precalentarHorno = TiempoFase(FaseHornada.precalentarHorno, 30, 45);
const _precalentarOllaOPiedra =
    TiempoFase(FaseHornada.precalentarHorno, 45, 60);
const _refrescoEstimado = TiempoFase(FaseHornada.refrescoMasaMadre, 240, 480);

const Map<String, PlantillaTiempos> tiemposRecetasGuia = {
  'rustico': PlantillaTiempos(temperaturaReferenciaC: 24, fases: [
    TiempoFase(FaseHornada.amasado, 10, 20),
    TiempoFase(FaseHornada.primeraFermentacion, 90, 120),
    TiempoFase(FaseHornada.formado, 20, 30),
    TiempoFase(FaseHornada.fermentacionFinal, 45, 75),
    _precalentarHorno,
    TiempoFase(FaseHornada.coccion, 35, 45),
    TiempoFase(FaseHornada.enfriado, 60, 120),
  ]),
  'chapata': PlantillaTiempos(temperaturaReferenciaC: 24, fases: [
    TiempoFase(FaseHornada.autolisis, 20, 30),
    TiempoFase(FaseHornada.amasado, 10, 15),
    TiempoFase(FaseHornada.primeraFermentacion, 120, 180),
    TiempoFase(FaseHornada.formado, 5, 10),
    TiempoFase(FaseHornada.fermentacionFinal, 30, 45),
    _precalentarHorno,
    TiempoFase(FaseHornada.coccion, 20, 30),
    TiempoFase(FaseHornada.enfriado, 60, 90),
  ]),
  'baguette': PlantillaTiempos(temperaturaReferenciaC: 24, fases: [
    TiempoFase(FaseHornada.amasado, 10, 15),
    TiempoFase(FaseHornada.primeraFermentacion, 90, 120,
        alternativaNevera: TiempoFase(FaseHornada.primeraFermentacion, 720, 960,
            enNevera: true)),
    TiempoFase(FaseHornada.formado, 25, 35),
    TiempoFase(FaseHornada.fermentacionFinal, 45, 60),
    _precalentarHorno,
    TiempoFase(FaseHornada.coccion, 20, 25),
    TiempoFase(FaseHornada.enfriado, 45, 60),
  ]),
  'integral': PlantillaTiempos(temperaturaReferenciaC: 25, fases: [
    TiempoFase(FaseHornada.autolisis, 30, 60),
    TiempoFase(FaseHornada.amasado, 8, 12),
    TiempoFase(FaseHornada.primeraFermentacion, 90, 120),
    TiempoFase(FaseHornada.formado, 10, 15),
    TiempoFase(FaseHornada.fermentacionFinal, 45, 60),
    _precalentarHorno,
    TiempoFase(FaseHornada.coccion, 40, 50),
    TiempoFase(FaseHornada.enfriado, 60, 120),
  ]),
  'centeno': PlantillaTiempos(temperaturaReferenciaC: 28, fases: [
    _refrescoEstimado,
    TiempoFase(FaseHornada.amasado, 5, 10),
    TiempoFase(FaseHornada.primeraFermentacion, 30, 60),
    TiempoFase(FaseHornada.formado, 5, 10),
    TiempoFase(FaseHornada.fermentacionFinal, 40, 60),
    _precalentarHorno,
    TiempoFase(FaseHornada.coccion, 50, 70),
    TiempoFase(FaseHornada.enfriado, 720, 1440),
  ]),
  'molde': PlantillaTiempos(temperaturaReferenciaC: 26, fases: [
    TiempoFase(FaseHornada.amasado, 15, 20),
    TiempoFase(FaseHornada.primeraFermentacion, 60, 90),
    TiempoFase(FaseHornada.formado, 10, 15),
    TiempoFase(FaseHornada.fermentacionFinal, 45, 75),
    _precalentarHorno,
    TiempoFase(FaseHornada.coccion, 30, 40),
    TiempoFase(FaseHornada.enfriado, 60, 120),
  ]),
  'brioche': PlantillaTiempos(temperaturaReferenciaC: 24, fases: [
    TiempoFase(FaseHornada.amasado, 20, 30),
    TiempoFase(FaseHornada.primeraFermentacion, 60, 60),
    TiempoFase(FaseHornada.primeraFermentacion, 480, 960, enNevera: true),
    TiempoFase(FaseHornada.formado, 15, 25),
    TiempoFase(FaseHornada.fermentacionFinal, 90, 180),
    _precalentarHorno,
    TiempoFase(FaseHornada.coccion, 15, 40),
    TiempoFase(FaseHornada.enfriado, 30, 60),
  ]),
  'focaccia': PlantillaTiempos(temperaturaReferenciaC: 25, fases: [
    TiempoFase(FaseHornada.amasado, 8, 12),
    TiempoFase(FaseHornada.primeraFermentacion, 90, 120,
        alternativaNevera: TiempoFase(
            FaseHornada.primeraFermentacion, 720, 1440,
            enNevera: true)),
    TiempoFase(FaseHornada.formado, 10, 25),
    TiempoFase(FaseHornada.fermentacionFinal, 30, 60),
    _precalentarHorno,
    TiempoFase(FaseHornada.coccion, 20, 25),
    TiempoFase(FaseHornada.enfriado, 15, 30),
  ]),
  'empanada': PlantillaTiempos(temperaturaReferenciaC: 24, fases: [
    TiempoFase(FaseHornada.amasado, 8, 12),
    TiempoFase(FaseHornada.primeraFermentacion, 45, 60),
    TiempoFase(FaseHornada.formado, 20, 30),
    TiempoFase(FaseHornada.fermentacionFinal, 20, 30),
    _precalentarHorno,
    TiempoFase(FaseHornada.coccion, 35, 45),
    TiempoFase(FaseHornada.enfriado, 15, 30),
  ]),
  'masa_madre': PlantillaTiempos(temperaturaReferenciaC: 25, fases: [
    _refrescoEstimado,
    TiempoFase(FaseHornada.autolisis, 30, 60),
    TiempoFase(FaseHornada.amasado, 10, 15),
    TiempoFase(FaseHornada.primeraFermentacion, 180, 300),
    TiempoFase(FaseHornada.formado, 30, 40),
    TiempoFase(FaseHornada.fermentacionFinal, 60, 180,
        alternativaNevera: TiempoFase(FaseHornada.fermentacionFinal, 480, 960,
            enNevera: true)),
    _precalentarOllaOPiedra,
    TiempoFase(FaseHornada.coccion, 40, 45),
    TiempoFase(FaseHornada.enfriado, 60, 120),
  ]),
};

/// Plantilla en blanco para una receta propia: las fases de un pan con
/// levadura, para que la persona ponga sus tiempos.
const PlantillaTiempos plantillaRecetaPropiaPorDefecto =
    PlantillaTiempos(temperaturaReferenciaC: 24, fases: [
  TiempoFase(FaseHornada.amasado, 10, 20),
  TiempoFase(FaseHornada.primeraFermentacion, 90, 120),
  TiempoFase(FaseHornada.formado, 20, 30),
  TiempoFase(FaseHornada.fermentacionFinal, 45, 75),
  _precalentarHorno,
  TiempoFase(FaseHornada.coccion, 35, 45),
  TiempoFase(FaseHornada.enfriado, 60, 120),
]);
