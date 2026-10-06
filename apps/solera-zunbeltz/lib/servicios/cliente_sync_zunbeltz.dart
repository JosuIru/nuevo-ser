import 'dart:convert';

import 'package:http/http.dart' as http;

import '../datos/base_datos.dart';
import '../datos/esquema_sincronizable.dart';
import '../modelos/entrada_actividad.dart';
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

/// Resultado de una sincronización: cuántas tareas y entidades (fincas,
/// puntos, proyectos…) se subieron, cuántas llegaron nuevas o cambiadas del
/// servidor, cuántas tareas no se pudieron bajar por no reconocer la finca,
/// cuántos cambios locales rechazó el servidor por permisos, cuántas cosas
/// se retiraron del móvil por haber dejado de ser visibles, y la sesión
/// refrescada.
class ResultadoSyncZunbeltz {
  ResultadoSyncZunbeltz({
    required this.subidas,
    required this.bajadas,
    required this.omitidasFincaDesconocida,
    required this.rechazadasPorPermisos,
    required this.sesionRemota,
    this.retiradas = 0,
    this.entidadesSubidas = 0,
    this.entidadesBajadas = 0,
    this.actividadNueva = const [],
    this.entidadesNuevasRecibidas = const [],
  });

  final int subidas;
  final int bajadas;
  final int omitidasFincaDesconocida;
  final int rechazadasPorPermisos;
  final SesionRemota sesionRemota;
  final int retiradas;
  final int entidadesSubidas;
  final int entidadesBajadas;

  /// Entradas de actividad recibidas en esta sincronización.
  final List<EntradaActividad> actividadNueva;

  /// Entidades (en formato del API) que llegaron y cambiaron algo en local:
  /// sirve para avisar de alarmas o peticiones nuevas.
  final List<Map<String, Object?>> entidadesNuevasRecibidas;
}

/// Sincroniza el espacio con el plugin `solera-zunbeltz-sync` instalado en
/// el WordPress propio de Zunbeltz Elkartea (`POST /sync`).
///
/// - **Entidades** (fincas, zonas, puntos, proyectos y su seguimiento,
///   peticiones, avisos — ver `datos/esquema_sincronizable.dart`): se suben
///   las cambiadas desde la última subida y las lápidas de lo borrado, y se
///   bajan las cambiadas desde la última revisión recibida. Con
///   `completa: true` se baja todo y se retira lo que el servidor ya no
///   manda (lo que esta persona ha dejado de ver).
/// - **Tareas**: se suben todas y se reciben todas las visibles; lo local
///   que no llega se retira. Se anclan a finca, punto y zona por `uid`; si
///   el servidor no manda `finca_uid` (tareas antiguas) se empareja por
///   nombre de finca.
/// - **Actividad** del espacio, si la persona tiene `ver_actividad`.
///
/// **Auth**: token personal (`X-Zunbeltz-Token`) que la coordinación crea
/// para cada persona en el admin de WordPress. El servidor aplica los
/// permisos y devuelve en `forzar` lo que hay que deshacer en el móvil.
class ClienteSyncZunbeltz {
  ClienteSyncZunbeltz({required this.urlBase, required this.token});

  final String urlBase;
  final String token;

  Uri _ruta(String ruta) =>
      Uri.parse('${_sinBarraFinal(urlBase)}/wp-json/solera-zunbeltz/v1/$ruta');

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
    final json =
        await _leerRespuesta(() => http.get(_ruta('yo'), headers: _cabeceras));
    return SesionRemota.desdeJson(json);
  }

  Future<Map<Object?, Object?>> _leerRespuesta(
      Future<http.Response> Function() peticion) async {
    http.Response respuesta;
    try {
      respuesta = await peticion().timeout(const Duration(seconds: 60));
    } catch (e) {
      throw ErrorSyncZunbeltz('No se pudo contactar con el servidor: $e');
    }
    if (respuesta.statusCode == 401 || respuesta.statusCode == 403) {
      throw ErrorSyncZunbeltz(
          'Token incorrecto o persona desactivada. Revisa Ajustes.');
    }
    if (respuesta.statusCode == 404) {
      throw ErrorSyncZunbeltz(
          'El WordPress no tiene el plugin solera-zunbeltz-sync 0.3 o posterior.');
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

  /// Sube lo cambiado en este móvil y aplica lo que llega del servidor. Lanza
  /// [ErrorSyncZunbeltz] si la configuración o la respuesta no son válidas.
  /// Con [completa] baja todo desde cero y retira lo que ya no se ve: se usa
  /// la primera vez, al cambiar de persona y a mano desde Ajustes.
  Future<ResultadoSyncZunbeltz> sincronizar(BaseDatosSoleraZunbeltz bd,
      {bool completa = false}) async {
    _comprobarConfiguracion();
    final inicioMs = DateTime.now().millisecondsSinceEpoch;
    final esPrimera = await bd.leerEstadoSync(claveRevision) == 0;
    final sincronizacionCompleta = completa || esPrimera;

    // ── Lo que sube ──
    final entidades = await bd
        .entidadesPendientesDeSubir(await bd.leerEstadoSync(claveSubida));
    final lapidas = await bd.listarBorradosPendientes();
    final tareas = await bd.tareasParaSincronizar();
    final cuerpo = jsonEncode({
      'entidades': [
        ...entidades,
        for (final lapida in lapidas)
          if (lapida.tipo != 'tarea')
            {
              'tipo': lapida.tipo,
              'uid': lapida.uid,
              'actualizado_ms': lapida.borradoMs,
              'borrado': true,
              'datos': const <String, Object?>{},
            },
      ],
      'tareas': [
        for (final tarea in tareas) await _tareaConAnclajes(bd, tarea),
      ],
      'tareas_borradas': [
        for (final lapida in lapidas)
          if (lapida.tipo == 'tarea') lapida.uid,
      ],
      'desde_revision':
          sincronizacionCompleta ? 0 : await bd.leerEstadoSync(claveRevision),
      'desde_actividad': await bd.leerEstadoSync(claveActividad),
    });

    final json = await _leerRespuesta(
        () => http.post(_ruta('sync'), headers: _cabeceras, body: cuerpo));
    if (json['tareas'] is! List || json['entidades'] is! List) {
      throw ErrorSyncZunbeltz('Respuesta inesperada del servidor.');
    }
    final sesionRemota = SesionRemota.desdeJson(json);

    // ── Entidades que bajan ──
    final forzadas = {
      for (final clave in (json['forzar_entidades'] as List?) ?? const [])
        if (clave is Map) '${clave['tipo']}|${clave['uid']}',
    };
    final recibidas = [
      for (final item in json['entidades'] as List)
        if (item is Map) Map<String, Object?>.from(item),
    ];
    final ordenTipos = {
      for (var indice = 0; indice < tablasSincronizables.length; indice++)
        tablasSincronizables[indice].tipo: indice,
    };
    // Altas y cambios en orden de dependencias; lápidas al revés.
    recibidas.sort((a, b) {
      final borradaA = a['borrado'] == true, borradaB = b['borrado'] == true;
      if (borradaA != borradaB) return borradaA ? 1 : -1;
      final orden = (ordenTipos[a['tipo']] ?? 999)
          .compareTo(ordenTipos[b['tipo']] ?? 999);
      return borradaA ? -orden : orden;
    });
    var entidadesBajadas = 0;
    final entidadesNuevas = <Map<String, Object?>>[];
    final uidsRecibidosPorTipo = <String, Set<String>>{};
    for (final entidad in recibidas) {
      final clave = '${entidad['tipo']}|${entidad['uid']}';
      if (entidad['borrado'] != true) {
        uidsRecibidosPorTipo
            .putIfAbsent(entidad['tipo'] as String? ?? '', () => {})
            .add(entidad['uid'] as String? ?? '');
      }
      final cambio = await bd.aplicarEntidadRemota(entidad,
          forzar: forzadas.contains(clave));
      if (cambio) {
        entidadesBajadas++;
        entidadesNuevas.add(entidad);
      }
    }
    // Lo rechazado que el servidor no tiene (altas no permitidas) se borra.
    final clavesRecibidas = {
      for (final entidad in recibidas) '${entidad['tipo']}|${entidad['uid']}',
    };
    for (final clave in forzadas.difference(clavesRecibidas)) {
      final partes = clave.split('|');
      await bd.borrarEntidadSinLapida(partes[0], partes[1]);
    }
    var retiradas = 0;
    if (sincronizacionCompleta) {
      retiradas += await bd.retirarEntidadesNoRecibidas(uidsRecibidosPorTipo);
    }
    await bd.olvidarBorrados(lapidas);

    // ── Tareas que bajan ──
    final (bajadas, omitidas, tareasRetiradas) =
        await _aplicarTareasRemotas(bd, json);
    retiradas += tareasRetiradas;

    // ── Actividad ──
    final actividad = [
      for (final item in (json['actividad'] as List?) ?? const [])
        if (item is Map)
          EntradaActividad.fromMap(Map<String, Object?>.from(item)),
    ];
    if (actividad.isNotEmpty) {
      await bd.guardarActividadEspacio(actividad);
      await bd.guardarEstadoSync(
          claveActividad,
          actividad
              .map((entrada) => entrada.id)
              .reduce((a, b) => a > b ? a : b));
    }

    await bd.guardarEstadoSync(
        claveRevision, (json['revision'] as num?)?.toInt() ?? 0);
    await bd.guardarEstadoSync(claveSubida, inicioMs);

    return ResultadoSyncZunbeltz(
      subidas: tareas.length,
      bajadas: bajadas,
      omitidasFincaDesconocida: omitidas,
      rechazadasPorPermisos: ((json['rechazos'] as List?) ?? const []).length +
          ((json['rechazos_entidades'] as List?) ?? const []).length,
      sesionRemota: sesionRemota,
      retiradas: retiradas,
      entidadesSubidas: entidades.length,
      entidadesBajadas: entidadesBajadas,
      actividadNueva: actividad,
      entidadesNuevasRecibidas: entidadesNuevas,
    );
  }

  /// Cursores guardados en la BD (`estado_sync`).
  static const claveRevision = 'revision';
  static const claveActividad = 'actividad';
  static const claveSubida = 'subida_ms';

  Future<Map<String, Object?>> _tareaConAnclajes(
      BaseDatosSoleraZunbeltz bd, TareaMantenimiento tarea) async {
    final finca = await bd.obtenerFinca(tarea.fincaId);
    return tareaAJson(
      tarea,
      finca?.nombre ?? '',
      fincaUid: await bd.uidDeFila('fincas', tarea.fincaId) ?? '',
      puntoUid: tarea.puntoId == null
          ? ''
          : await bd.uidDeFila('puntos_infraestructura', tarea.puntoId!) ?? '',
      zonaUid: tarea.zonaId == null
          ? ''
          : await bd.uidDeFila('zonas_finca', tarea.zonaId!) ?? '',
    );
  }

  /// Fusiona las tareas recibidas y retira las que ya no llegan. Devuelve
  /// (bajadas, omitidas por finca desconocida, retiradas).
  Future<(int, int, int)> _aplicarTareasRemotas(
      BaseDatosSoleraZunbeltz bd, Map<Object?, Object?> json) async {
    final uidsForzados = {
      for (final uid in (json['forzar'] as List?) ?? const [])
        if (uid is String) uid,
    };
    final fincaIdPorNombre = {
      for (final finca in await bd.listarFincas())
        if (finca.id != null) finca.nombre: finca.id!,
    };

    var bajadas = 0;
    var omitidas = 0;
    final uidsRemotos = <String>{};
    for (final item in (json['tareas'] as List)) {
      if (item is! Map) continue;
      final mapa = Map<String, Object?>.from(item);
      if (mapa['uid'] is String) uidsRemotos.add(mapa['uid'] as String);
      final fincaId =
          await bd.idDeUid('fincas', (mapa['finca_uid'] as String?) ?? '') ??
              fincaIdPorNombre[(mapa['finca_nombre'] as String?) ?? ''];
      if (fincaId == null) {
        omitidas++;
        continue;
      }
      final traeAnclaje = mapa.containsKey('punto_uid');
      final remota = tareaDesdeJson(
        mapa,
        fincaId,
        puntoId: await bd.idDeUid(
            'puntos_infraestructura', (mapa['punto_uid'] as String?) ?? ''),
        zonaId: await bd.idDeUid(
            'zonas_finca', (mapa['zona_uid'] as String?) ?? ''),
      );
      final forzar = uidsForzados.contains(remota.uid);
      final antes = await bd.obtenerTareaPorUid(remota.uid);
      await bd.upsertTareaRemota(remota,
          forzar: forzar, anclajeDelServidor: traeAnclaje);
      if (forzar ||
          antes == null ||
          antes.actualizadoMs < remota.actualizadoMs) {
        bajadas++;
      }
    }

    // Una tarea nueva rechazada no existe en el servidor: no vuelve en
    // `tareas`, así que se borra aquí para no reenviarla en cada sync.
    for (final uid in uidsForzados.difference(uidsRemotos)) {
      final local = await bd.obtenerTareaPorUid(uid);
      if (local?.id != null) await bd.borrarTareaSinLapida(local!.id!);
    }

    // `tareas` es la lista entera de lo que esta persona ve: lo que haya
    // en local y no venga ya no le corresponde (reasignada a otra persona).
    var retiradas = 0;
    if (json['completo'] == true) {
      for (final local in await bd.listarTareas()) {
        if (local.id != null && !uidsRemotos.contains(local.uid)) {
          await bd.borrarTareaSinLapida(local.id!);
          retiradas++;
        }
      }
    }
    return (bajadas, omitidas, retiradas);
  }

  /// Serializa una tarea local al formato que espera el plugin WP. Pública
  /// y estática para poder testear el formato del payload sin red.
  static Map<String, Object?> tareaAJson(
    TareaMantenimiento tarea,
    String fincaNombre, {
    String fincaUid = '',
    String puntoUid = '',
    String zonaUid = '',
  }) =>
      {
        'uid': tarea.uid,
        'finca_nombre': fincaNombre,
        'finca_uid': fincaUid,
        'punto_uid': puntoUid,
        'zona_uid': zonaUid,
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
          Map<String, Object?> json, int fincaId,
          {int? puntoId, int? zonaId}) =>
      TareaMantenimiento(
        uid: json['uid'] as String?,
        fincaId: fincaId,
        puntoId: puntoId,
        zonaId: zonaId,
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
