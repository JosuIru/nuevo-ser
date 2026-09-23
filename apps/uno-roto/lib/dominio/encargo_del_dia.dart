/// El encargo del día — la meta corta y diegética de cada sesión
/// (doc 16, eje D). Sora propone una caza pequeña y concreta: "tres
/// Fragmentos en los Canales" o "cuatro donde tú quieras". Al
/// cumplirlo, un cierre sobrio; si el niño no viene, mañana hay otro
/// y no se pierde nada.
///
/// Reglas de diseño (doc 16 §3.D y salvaguardas §6):
///
/// - **Determinista** por fecha: la pareja `(fecha, distritos
///   desbloqueados)` produce siempre el mismo encargo, igual que
///   [ClimaDistrito] hace con el cielo. Sin reloj global, sin azar
///   trucable — se le pasa [ahora] desde fuera y los tests lo
///   congelan.
/// - **Sin racha, sin pérdida**: no hay contador de días seguidos ni
///   encargos acumulados. El de ayer se evapora sin rastro.
/// - **Siempre opcional**: nada del juego se bloquea por ignorarlo.
///   El cazadero libre sigue abierto igual.
/// - Solo propone distritos que el niño ya tiene desbloqueados.
///
/// El módulo es puro (sin Flutter, sin persistencia). El progreso del
/// encargo vive en `RepositorioEncargo`.
class EncargoDelDia {
  /// Fecha a la que pertenece el encargo, como `AAAA-MM-DD`. Es la
  /// clave con la que el repositorio detecta que cambió el día y el
  /// progreso de ayer ya no aplica.
  final String claveFecha;

  /// Distrito donde cuentan las capturas, o `null` si el encargo es
  /// libre ("donde tú quieras").
  final String? idDistrito;

  /// Número de capturas que pide el encargo.
  final int objetivo;

  const EncargoDelDia({
    required this.claveFecha,
    required this.idDistrito,
    required this.objetivo,
  });

  /// `true` cuando las capturas cuentan en cualquier distrito.
  bool get esLibre => idDistrito == null;

  /// `true` si una captura hecha en [idDistritoCaptura] avanza este
  /// encargo. Las cazas del modo entrenamiento pasan
  /// [esEntrenamiento] = true: cuentan solo para encargos libres —
  /// un encargo de distrito pide pisar ese distrito de verdad.
  bool cuentaCaptura({
    required String idDistritoCaptura,
    required bool esEntrenamiento,
  }) {
    if (esLibre) return true;
    if (esEntrenamiento) return false;
    return idDistrito == idDistritoCaptura;
  }
}

/// Genera el encargo que toca hoy. Determinista: mismo día y mismos
/// distritos desbloqueados → mismo encargo, aunque el niño cierre y
/// abra la app veinte veces.
class GeneradorEncargoDelDia {
  GeneradorEncargoDelDia._();

  /// Capturas que pide un encargo de distrito concreto.
  static const int objetivoEnDistrito = 3;

  /// Capturas que pide un encargo libre (algo más, porque puede
  /// repartirlas donde quiera).
  static const int objetivoLibre = 4;

  /// Devuelve el encargo del día de [ahora] para un niño con
  /// [idsDistritosDesbloqueados] abiertos. La lista vacía (imposible
  /// en flujo normal — Tejados se desbloquea con 0 esquirlas) produce
  /// un encargo libre.
  ///
  /// La elección es una opción entre `n + 1` candidatas: cada
  /// distrito desbloqueado y la variante libre. Así, con un solo
  /// distrito abierto (días 1-2) el encargo alterna entre "3 en
  /// Tejados" y "4 donde quieras", y a medida que la ciudad se abre
  /// el abanico crece solo.
  static EncargoDelDia deHoy({
    required DateTime ahora,
    required List<String> idsDistritosDesbloqueados,
  }) {
    final claveFecha = claveFechaDe(ahora);
    if (idsDistritosDesbloqueados.isEmpty) {
      return EncargoDelDia(
        claveFecha: claveFecha,
        idDistrito: null,
        objetivo: objetivoLibre,
      );
    }
    final semilla = _semillaDelDia(ahora);
    final totalOpciones = idsDistritosDesbloqueados.length + 1;
    final indice = semilla % totalOpciones;
    if (indice == idsDistritosDesbloqueados.length) {
      return EncargoDelDia(
        claveFecha: claveFecha,
        idDistrito: null,
        objetivo: objetivoLibre,
      );
    }
    return EncargoDelDia(
      claveFecha: claveFecha,
      idDistrito: idsDistritosDesbloqueados[indice],
      objetivo: objetivoEnDistrito,
    );
  }

  /// Formatea la fecha como `AAAA-MM-DD` (la hora se ignora a
  /// propósito: el encargo dura el día natural entero).
  static String claveFechaDe(DateTime ahora) {
    final mes = ahora.month.toString().padLeft(2, '0');
    final dia = ahora.day.toString().padLeft(2, '0');
    return '${ahora.year}-$mes-$dia';
  }

  /// Combina año y día del año con una sal propia, para que el
  /// encargo no quede correlacionado con el clima del día (que usa
  /// el mismo esquema de semilla en [ClimaDistrito]).
  static int _semillaDelDia(DateTime ahora) {
    final clave = 'encargo-${ahora.year}-${_diaDelAnio(ahora)}';
    return clave.hashCode & 0x7FFFFFFF;
  }

  static int _diaDelAnio(DateTime fecha) {
    final inicioAnio = DateTime(fecha.year);
    return fecha.difference(inicioAnio).inDays + 1;
  }
}
