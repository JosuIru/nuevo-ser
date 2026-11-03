/// Un aviso que llega por FCM (`includes/push-fcm.php` del plugin): mensaje
/// solo de datos, ya traducido por el servidor al idioma del móvil.
class AvisoAlMomento {
  const AvisoAlMomento({
    required this.clase,
    required this.clave,
    required this.titulo,
    required this.texto,
  });

  /// `alarma`, `peticion_urgente`, `peticion` o `tarea`.
  final String clase;

  /// `tipo|uid` de lo avisado: se apunta como ya notificado para que la
  /// sincronización no vuelva a avisar de lo mismo.
  final String clave;
  final String titulo;
  final String texto;

  static const clasesConocidas = {
    'alarma',
    'peticion_urgente',
    'peticion',
    'tarea',
  };

  /// Las alarmas y las peticiones urgentes van por el canal de alta
  /// importancia; el resto, por el de avisos.
  bool get urgente => clase == 'alarma' || clase == 'peticion_urgente';

  /// El aviso de los datos de un mensaje, o null si no es uno nuestro.
  static AvisoAlMomento? desdeDatos(Map<String, dynamic> datos) {
    final clase = datos['clase'];
    final titulo = datos['titulo'];
    if (clase is! String ||
        !clasesConocidas.contains(clase) ||
        titulo is! String ||
        titulo.trim().isEmpty) {
      return null;
    }
    final clave = datos['clave'];
    final texto = datos['texto'];
    return AvisoAlMomento(
      clase: clase,
      clave: clave is String ? clave : '',
      titulo: titulo,
      texto: texto is String ? texto : '',
    );
  }

  /// Id de la notificación: uno por cosa avisada, siempre el mismo (un
  /// aviso repetido sustituye al anterior en vez de amontonarse). Lejos de
  /// los ids fijos de `servicio_notificaciones.dart` (1-4). No se usa
  /// `String.hashCode`, que no está garantizado entre ejecuciones.
  int get idNotificacion {
    final base = clave.isEmpty ? '$clase|$titulo' : clave;
    var huella = 0x811c9dc5;
    for (final unidad in base.codeUnits) {
      huella = ((huella ^ unidad) * 0x01000193) & 0x7fffffff;
    }
    return 1000 + huella % 1000000000;
  }
}
