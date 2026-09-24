import '../brecha.dart';
import 'partida_tres_fichas.dart';

/// Frases de Andrés en el ático. Humor seco, cercano (doc 04). No
/// evalúa: «yo sólo guardo las cosas; tú sabrás qué dicen».
///
/// Texto en castellano como el resto del contenido de las Brechas;
/// eu/ca cuando se mueva todo a claves narrativas.
class VozAndresAtico {
  VozAndresAtico._();

  static const bienvenida = 'Pasa, pasa. Cuidado con la tercera viga, '
      'que cruje. Aquí arriba guardo lo que ya habéis investigado.';

  static const entradaTresFichas = 'Tarjetas de investigaciones pasadas. '
      'Cada una a su bandeja. Yo no digo nada hasta el final.';

  static String instruccionRonda(RondaTresFichas ronda) {
    switch (ronda.tipo) {
      case TipoRondaTresFichas.unaBrecha:
        return 'Todas de la misma investigación: ${ronda.tarjetas.first.brecha.titulo}.';
      case TipoRondaTresFichas.dosCapas:
        return 'Ahora mezcladas, de épocas distintas. El criterio es el mismo.';
      case TipoRondaTresFichas.tarjetaSuelta:
        return 'A estas se les soltó el hilo. Las fuentes están en el cajón: '
            'búscalas antes de decidir. Esta ronda no la apunto.';
    }
  }

  static String nombreNivel(NivelConfianza nivel) {
    switch (nivel) {
      case NivelConfianza.solido:
        return 'Sólido';
      case NivelConfianza.probable:
        return 'Probable';
      case NivelConfianza.disputado:
        return 'Disputado';
    }
  }

  static String sobreLaBalanza(InclinacionBalanza inclinacion) {
    switch (inclinacion) {
      case InclinacionBalanza.equilibrio:
        return 'La balanza se queda quieta. Eso en este oficio es mucho decir.';
      case InclinacionBalanza.sobreconfianza:
        return 'La balanza se va hacia el lado de la seguridad. Te fías un '
            'poco más de lo que dicen las fuentes.';
      case InclinacionBalanza.timidez:
        return 'La balanza se va hacia el lado de la duda. A veces las '
            'fuentes dan para más de lo que te atreves a decir.';
    }
  }

  /// Comentario sobre UNA tarjeta desviada. Sólo usa datos del
  /// catálogo (nivel canónico y número de fuentes de anclaje): no
  /// añade afirmaciones históricas nuevas.
  static String sobreUnaTarjeta(DesviacionTarjeta desviacion) {
    final tarjeta = desviacion.tarjeta;
    final numeroFuentes = tarjeta.fuentesAnclaje.length;
    // «Anclada», no «sostenida»: las fuentes de anclaje pueden
    // sostener la afirmación o contradecirla (modelo AfirmacionCanonica).
    final fuentes = switch (numeroFuentes) {
      0 => 'No está anclada a ninguna fuente',
      1 => 'Está anclada a una sola fuente',
      _ => 'Está anclada a $numeroFuentes fuentes',
    };
    return '«${tarjeta.afirmacion.texto}» La pusiste en '
        '${nombreNivel(desviacion.declarado)}. $fuentes. En el Archivo la '
        'dejamos en ${nombreNivel(tarjeta.nivelCanonico)}. Pero tú verás.';
  }

  static const cierre = 'Hala. Vuelve cuando quieras, que esto no se mueve de aquí.';
}
