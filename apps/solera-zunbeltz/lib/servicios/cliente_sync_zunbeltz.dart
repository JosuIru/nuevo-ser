import 'dart:convert';

import 'package:http/http.dart' as http;

import '../datos/base_datos.dart';
import '../modelos/constantes.dart';
import '../modelos/persona_espacio.dart';
import '../modelos/tarea_mantenimiento.dart';

class ErrorSyncZunbeltz implements Exception {
  final String mensaje;
  ErrorSyncZunbeltz(this.mensaje);
  @override
  String toString() => 'ErrorSyncZunbeltz: $mensaje';
}

/// Quién es la persona dueña del token y quiénes forman el espacio, tal
/// como lo devuelven `GET /yo` y la sincronización.
class SesionRemota {
  SesionRemota({required this.sesion, required this.personas});

  final SesionEspacio sesion;
  final List<PersonaEspacio> personas;

  /// Lee `yo` y `personas` de una respuesta del servidor.
  static SesionRemota desdeJson(Map<Object?, Object?> json) {
    final yo = json['yo'];
    if (yo is! Map) {
      throw ErrorSyncZunbeltz('Respuesta inesperada del servidor (sin `yo`).');
    }
    return SesionRemota(
      sesion: SesionEspacio.fromJson(Map<String, Object?>.from(yo)),
      personas: [
        for (final item in (json['personas'] as List?) ?? const [])
          if (item is Map)
            PersonaEspacio.fromJson(Map<String, Object?>.from(item)),
      ],
    );
  }
}

/// Resultado de una sincronización: cuántas tareas se subieron, cuántas
/// llegaron nuevas o actualizadas del servidor, cuántas no se pudieron
/// bajar por no reconocer la finca (nombre sin equivalente local), cuántos
/// cambios locales rechazó el servidor por permisos, y la sesión refrescada.
class ResultadoSyncZunbeltz {
  ResultadoSyncZunbeltz({
    required this.subidas,
    required this.bajadas,
    required this.omitidasFincaDesconocida,
    required this.rechazadasPorPermisos,
    required this.sesionRemota,
  });

  final int subidas;
  final int bajadas;
  final int omitidasFincaDesconocida;
  final int rechazadasPorPermisos;
  final SesionRemota sesionRemota;
}

/// Sincroniza las tareas de mantenimiento con el plugin `solera-zunbeltz-sync`
/// instalado en el WordPress propio de Zunbeltz Elkartea.
///
/// **Alcance actual — solo tareas.** Fincas, puntos y zonas siguen siendo
/// locales a cada dispositivo (no hay catálogo compartido de puntos/zonas
/// todavía). Para que una tarea "aterrice" en la finca correcta en otro
/// dispositivo, se empareja por **nombre de finca** — un catálogo pequeño y
/// estable ("Zunbeltz", "La Planilla"), no por id autoincrement, que es
/// local a cada sqflite. Una tarea anclada a un punto o zona concreto pierde
/// ese anclaje al llegar a otro dispositivo (queda como tarea de finca);
/// título, descripción, responsable, prioridad, estado, fecha, coste y
/// recurrencia sí viajan enteros.
///
/// **Auth**: token personal (`X-Zunbeltz-Token`) que la coordinación crea
/// para cada persona en el admin de WordPress. El servidor aplica los
/// permisos del rol al sincronizar; los cambios que rechaza vuelven en
/// `forzar` y aquí se sobrescriben con la versión del servidor.
class ClienteSyncZunbeltz {
  ClienteSyncZunbeltz({required this.urlBase, required this.token});

  final String urlBase;
  final String token;

  Uri _ruta(String ruta) => Uri.parse(
      '${_sinBarraFinal(urlBase)}/wp-json/solera-zunbeltz/v1/$ruta');

  Map<String, String> get _cabeceras => {
        'content-type': 'application/json',
        'X-Zunbeltz-Token': token,
      };

  void _comprobarConfiguracion() {
    if (urlBase.trim().isEmpty || token.trim().isEmpty) {
      throw ErrorSyncZunbeltz(
          'Configura la URL del WordPress y el token en Ajustes.');
    }
  }

  /// Valida el token y devuelve quién es su dueña y las personas del
  /// espacio (`GET /yo`).
  Future<SesionRemota> obtenerSesion() async {
    _comprobarConfiguracion();
    final json = await _leerRespuesta(() => http.get(_ruta('yo'), headers: _cabeceras));
    return SesionRemota.desdeJson(json);
  }

  Future<Map<Object?, Object?>> _leerRespuesta(
      Future<http.Response> Function() peticion) async {
    http.Response respuesta;
    try {
      respuesta = await peticion().timeout(const Duration(seconds: 30));
    } catch (e) {
      throw ErrorSyncZunbeltz('No se pudo contactar con el servidor: $e');
    }
    if (respuesta.statusCode == 401 || respuesta.statusCode == 403) {
      throw ErrorSyncZunbeltz(
          'Token incorrecto o persona desactivada. Revisa Ajustes.');
    }
    if (respuesta.statusCode != 200) {
      throw ErrorSyncZunbeltz(
          'Error HTTP ${respuesta.statusCode}: ${respuesta.body}');
    }
    final json = jsonDecode(utf8.decode(respuesta.bodyBytes));
    if (json is! Map) {
      throw ErrorSyncZunbeltz('Respuesta inesperada del servidor.');
    }
    return json;
  }

  static String _sinBarraFinal(String url) =>
      url.endsWith('/') ? url.substring(0, url.length - 1) : url;

  /// Sube las tareas locales y fusiona (last-write-wins por `actualizado_ms`)
  /// las que llegan del servidor. Lanza [ErrorSyncZunbeltz] si la
  /// configuración o la respuesta del servidor no son válidas.
  Future<ResultadoSyncZunbeltz> sincronizar(
      BaseDatosSoleraZunbeltz bd) async {
    _comprobarConfiguracion();

    final fincas = await bd.listarFincas();
    final nombrePorFincaId = {
      for (final f in fincas)
        if (f.id != null) f.id!: f.nombre,
    };
    final tareas = await bd.tareasParaSincronizar();

    final cuerpo = jsonEncode({
      'tareas': [
        for (final t in tareas)
          tareaAJson(t, nombrePorFincaId[t.fincaId] ?? ''),
      ],
    });

    final json = await _leerRespuesta(() =>
        http.post(_ruta('tareas/sync'), headers: _cabeceras, body: cuerpo));
    if (json['tareas'] is! List) {
      throw ErrorSyncZunbeltz('Respuesta inesperada del servidor.');
    }
    final sesionRemota = SesionRemota.desdeJson(json);
    final uidsForzados = {
      for (final uid in (json['forzar'] as List?) ?? const [])
        if (uid is String) uid,
    };

    final fincaIdPorNombre = {
      for (final f in fincas)
        if (f.id != null) f.nombre: f.id!,
    };

    var bajadas = 0;
    var omitidas = 0;
    for (final item in (json['tareas'] as List)) {
      if (item is! Map) continue;
      final mapa = Map<String, Object?>.from(item);
      final nombreFinca = (mapa['finca_nombre'] as String?) ?? '';
      final fincaId = fincaIdPorNombre[nombreFinca];
      if (fincaId == null) {
        omitidas++;
        continue;
      }
      final remota = tareaDesdeJson(mapa, fincaId);
      final forzar = uidsForzados.contains(remota.uid);
      final antes = await bd.obtenerTareaPorUid(remota.uid);
      await bd.upsertTareaRemota(remota, forzar: forzar);
      if (forzar || antes == null || antes.actualizadoMs < remota.actualizadoMs) {
        bajadas++;
      }
    }

    // Una tarea nueva rechazada no existe en el servidor: no vuelve en
    // `tareas`, así que se borra aquí para no reenviarla en cada sync.
    final uidsRemotos = {
      for (final item in (json['tareas'] as List))
        if (item is Map && item['uid'] is String) item['uid'] as String,
    };
    for (final uid in uidsForzados.difference(uidsRemotos)) {
      final local = await bd.obtenerTareaPorUid(uid);
      if (local?.id != null) await bd.borrarTarea(local!.id!);
    }

    return ResultadoSyncZunbeltz(
      subidas: tareas.length,
      bajadas: bajadas,
      omitidasFincaDesconocida: omitidas,
      rechazadasPorPermisos: ((json['rechazos'] as List?) ?? const []).length,
      sesionRemota: sesionRemota,
    );
  }

  /// Serializa una tarea local al formato que espera el plugin WP. Pública
  /// y estática para poder testear el formato del payload sin red.
  static Map<String, Object?> tareaAJson(
          TareaMantenimiento tarea, String fincaNombre) =>
      {
        'uid': tarea.uid,
        'finca_nombre': fincaNombre,
        'titulo': tarea.titulo,
        'descripcion': tarea.descripcion,
        'responsable': tarea.responsable,
        'responsable_uid': tarea.responsableUid,
        'creado_por_uid': tarea.creadoPorUid,
        'prioridad': tarea.prioridad,
        'estado': tarea.estado,
        'fecha_objetivo_ms': tarea.fechaObjetivoMs,
        'coste_centimos': tarea.costeCentimos,
        'recurrencia_dias': tarea.recurrenciaDias,
        'fecha_creacion_ms': tarea.fechaCreacionMs,
        'actualizado_ms': tarea.actualizadoMs,
      };

  /// Reconstruye una tarea a partir de un ítem recibido del servidor, con
  /// `fincaId` ya resuelto localmente (ver `sincronizar`). Pública y
  /// estática por el mismo motivo que [tareaAJson].
  static TareaMantenimiento tareaDesdeJson(
          Map<String, Object?> json, int fincaId) =>
      TareaMantenimiento(
        uid: json['uid'] as String?,
        fincaId: fincaId,
        titulo: (json['titulo'] as String?) ?? '',
        descripcion: (json['descripcion'] as String?) ?? '',
        responsable: (json['responsable'] as String?) ?? '',
        responsableUid: (json['responsable_uid'] as String?) ?? '',
        creadoPorUid: (json['creado_por_uid'] as String?) ?? '',
        prioridad: (json['prioridad'] as String?) ?? prioridadTareaPorDefecto,
        estado: (json['estado'] as String?) ?? estadoTareaPorDefecto,
        fechaObjetivoMs: (json['fecha_objetivo_ms'] as num?)?.toInt(),
        costeCentimos: (json['coste_centimos'] as num?)?.toInt(),
        recurrenciaDias: (json['recurrencia_dias'] as num?)?.toInt(),
        fechaCreacionMs: (json['fecha_creacion_ms'] as num?)?.toInt() ?? 0,
        actualizadoMs: (json['actualizado_ms'] as num?)?.toInt() ?? 0,
      );
}
