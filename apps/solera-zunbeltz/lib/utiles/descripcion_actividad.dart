import '../l10n/app_localizations.dart';
import '../modelos/constantes.dart';
import '../modelos/entrada_actividad.dart';

/// «Ane ha movido el punto «Corral móvil» en Zunbeltz».
String describirActividad(
    EntradaActividad entrada, AppLocalizations textos, String idioma) {
  final persona = entrada.personaNombre.isEmpty
      ? textos.personaDesconocida
      : entrada.personaNombre;
  final tipo = _tipoEntidad(entrada.tipo, textos);
  final cosa = entrada.etiqueta.isEmpty ? tipo : '$tipo «${entrada.etiqueta}»';
  final frase = switch (entrada.accion) {
    'crear' => textos.actividadCrear(persona, cosa),
    'borrar' => textos.actividadBorrar(persona, cosa),
    'mover' => textos.actividadMover(persona, cosa),
    'estado' => textos.actividadEstado(persona, cosa,
        buscarOpcion(estadosTarea, entrada.detalle)?.etiqueta(idioma) ?? entrada.detalle),
    'asignar' => entrada.detalle.isEmpty
        ? textos.actividadDesasignar(persona, cosa)
        : textos.actividadAsignar(persona, cosa, entrada.detalle),
    _ => textos.actividadEditar(persona, cosa),
  };
  return [
    frase,
    if (entrada.contexto.isNotEmpty) textos.actividadEn(entrada.contexto),
    if (entrada.origen == 'panel') textos.actividadDesdePanel,
  ].join(' ');
}

String _tipoEntidad(String tipo, AppLocalizations textos) => switch (tipo) {
      'tarea' => textos.tipoEntidadTarea,
      'punto' => textos.tipoEntidadPunto,
      'finca' => textos.tipoEntidadFinca,
      'zona' => textos.tipoEntidadZona,
      'proyecto' => textos.tipoEntidadProyecto,
      'apunte' => textos.tipoEntidadApunte,
      'venta' => textos.tipoEntidadVenta,
      'registro_actividad' => textos.tipoEntidadRegistro,
      'validacion' => textos.tipoEntidadValidacion,
      'peticion' => textos.tipoEntidadPeticion,
      'aviso' => textos.tipoEntidadAviso,
      _ => textos.tipoEntidadOtra,
    };
