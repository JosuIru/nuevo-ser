import '../brecha.dart';
import 'partida_documento_roto.dart';
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

  // ─── El documento roto ───────────────────────────────────────────

  static String instruccionDocumentoRoto(int indiceRonda) {
    switch (indiceRonda) {
      case 0:
        return 'Se les despegó el sello. ¿Cuál es primaria y cuál '
            'secundaria?';
      case 1:
        return 'Ahora quién lo hizo y cuándo. Ojo: la fecha es la del '
            'documento, no la de lo que cuenta.';
      default:
        return '¿Para quién se hizo cada uno? Y una de estas tiras no es '
            'de nada que haya en la mesa. Esa, a la caja.';
    }
  }

  /// Pista cuando una tira no encaja. No dice cuál es la buena: da el
  /// criterio del oficio para volver a mirar.
  static String pistaNoEncaja(TipoTira tipo) {
    switch (tipo) {
      case TipoTira.tipoFuente:
        return 'No encaja. Primaria: hecha en su momento, por quien '
            'estaba. Secundaria: hecha después, mirando otras fuentes.';
      case TipoTira.autor:
        return 'No encaja. ¿Quién lo hizo, o de quién habla? No es lo mismo.';
      case TipoTira.fecha:
        return 'No encaja. Mira si esa fecha es de cuando se hizo el '
            'documento o de lo que cuenta.';
      case TipoTira.publico:
        return 'No encaja. ¿A quién iba dirigido? A veces a nadie.';
    }
  }

  static String cierreDocumentoRoto(TipoTira? tipoConMasVueltas) {
    switch (tipoConMasVueltas) {
      case null:
        return 'Todo pegado a la primera. Ni la humedad puede contigo.';
      case TipoTira.tipoFuente:
        return 'Lo de primaria y secundaria es lo que más vueltas ha dado. '
            'Normal: es lo primero que se aprende y lo último que se domina.';
      case TipoTira.autor:
        return 'Los autores son lo que más vueltas ha dado. Quien escribe '
            'y de quien se escribe se confunden mucho.';
      case TipoTira.fecha:
        return 'Las fechas son lo que más vueltas ha dado. Un documento '
            'tiene dos: la suya y la de lo que cuenta.';
      case TipoTira.publico:
        return 'El público es lo que más vueltas ha dado. Pregúntate '
            'siempre para quién se hizo.';
    }
  }

  static const cierre = 'Hala. Vuelve cuando quieras, que esto no se mueve de aquí.';
}
