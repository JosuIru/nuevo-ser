// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitulo => 'Solera Zunbeltz';

  @override
  String get navHoy => 'Hoy';

  @override
  String get navFincas => 'Fincas';

  @override
  String get navSeguimiento => 'Seguimiento';

  @override
  String get navAjustes => 'Ajustes';

  @override
  String get onboardingTitulo => 'Solera Zunbeltz';

  @override
  String get onboardingCuerpo =>
      'La herramienta del Espacio Test Agrario: gestiona las fincas, reparte las tareas de mantenimiento y lleva el seguimiento del testaje. Funciona sin cobertura en el monte.';

  @override
  String get onboardingBoton => 'Empezar';

  @override
  String get hoyTitulo => 'Hoy';

  @override
  String hoyResumenTareas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n tareas abiertas',
      one: '1 tarea abierta',
      zero: 'Sin tareas abiertas',
    );
    return '$_temp0';
  }

  @override
  String get hoyVacio =>
      'Aún no hay nada registrado. Empieza por marcar una infraestructura en el mapa de Fincas.';

  @override
  String get hoyVerTablero => 'Ver tareas';

  @override
  String get ajustesIdioma => 'Idioma';

  @override
  String get ajustesIdiomaCastellano => 'Castellano';

  @override
  String get ajustesIdiomaEuskera => 'Euskara';

  @override
  String get ajustesAcercaDe => 'Acerca de';

  @override
  String ajustesVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get ajustesProvisional =>
      'Versión preliminar. Los partes e informes que genera son orientativos y su formato está pendiente de validación. El papeleo oficial (libro de explotación, cuaderno PAC, trazabilidad…) llega en fases posteriores.';

  @override
  String get comunGuardar => 'Guardar';

  @override
  String get comunCancelar => 'Cancelar';

  @override
  String get comunBorrar => 'Borrar';

  @override
  String get comunFecha => 'Fecha';

  @override
  String get mapaNuevoPunto => 'Nuevo punto';

  @override
  String get mapaUsarGps => 'Usar GPS actual';

  @override
  String get mapaUsarCentro => 'Usar centro del mapa';

  @override
  String get mapaElegirFinca => '¿En qué finca?';

  @override
  String get mapaSinPuntos =>
      'Aún no hay puntos. Toca el mapa o pulsa «Nuevo punto» para marcar el primero.';

  @override
  String get mapaTocaParaAnadir => 'Toca el mapa para añadir un punto';

  @override
  String get mapaTocaNuevaUbicacion => 'Toca la nueva ubicación del punto';

  @override
  String get puntoRecolocado => 'Punto recolocado';

  @override
  String get fichaRecolocar => 'Recolocar en el mapa';

  @override
  String get mapaGpsNoDisponible =>
      'GPS no disponible — rellena la ubicación a mano.';

  @override
  String get mapaCapas => 'Capas';

  @override
  String get mapaMapa => 'Mapa';

  @override
  String get mapaGps => 'GPS';

  @override
  String get mapaTablero => 'Tareas';

  @override
  String get puntoNuevoTitulo => 'Nuevo punto de infraestructura';

  @override
  String get puntoFinca => 'Finca';

  @override
  String get puntoTipo => 'Tipo';

  @override
  String get puntoNombre => 'Nombre';

  @override
  String get puntoEstado => 'Estado';

  @override
  String get puntoNotas => 'Notas';

  @override
  String get puntoFotos => 'Fotos';

  @override
  String get puntoLatitud => 'Latitud';

  @override
  String get puntoLongitud => 'Longitud';

  @override
  String get puntoGuardado => 'Punto guardado';

  @override
  String get fichaPuntoTareas => 'Tareas del punto';

  @override
  String get fichaSinTareas => 'Sin tareas en este punto.';

  @override
  String get fichaNuevaTarea => 'Nueva tarea';

  @override
  String get fichaBorrarPunto => 'Borrar punto';

  @override
  String get fichaCoordenadas => 'Coordenadas';

  @override
  String get fichaSinCoordenadas => 'Sin coordenadas';

  @override
  String get tareaNuevaTitulo => 'Nueva tarea';

  @override
  String get tareaTitulo => 'Título';

  @override
  String get tareaDescripcion => 'Descripción';

  @override
  String get tareaResponsable => 'Responsable';

  @override
  String get tareaPrioridad => 'Prioridad';

  @override
  String get tareaEstado => 'Estado';

  @override
  String get tareaFechaObjetivo => 'Fecha objetivo';

  @override
  String get tareaSinFecha => 'Sin fecha';

  @override
  String get tareaFotosAntes => 'Fotos antes';

  @override
  String get tareaFotosDespues => 'Fotos después';

  @override
  String get tareaCoste => 'Coste (€)';

  @override
  String get tareaGuardada => 'Tarea guardada';

  @override
  String get tareaTituloObligatorio => 'Pon un título a la tarea.';

  @override
  String get tareaRecurrencia => 'Periodicidad';

  @override
  String get tareaMarcarHecha => 'Marcar hecha';

  @override
  String get tareaSiguienteGenerada => 'Hecha. Siguiente tarea generada.';

  @override
  String get tableroTitulo => 'Tareas de mantenimiento';

  @override
  String get tableroTodas => 'Todas';

  @override
  String get tableroFiltroFinca => 'Finca';

  @override
  String get tableroFiltroEstado => 'Estado';

  @override
  String get tableroSinTareas => 'No hay tareas con estos filtros.';

  @override
  String get tableroPartePdf => 'Parte PDF';

  @override
  String get tableroGenerandoPdf => 'Generando parte…';

  @override
  String get tareaDeFinca => 'Tarea de finca';

  @override
  String get parteTitulo => 'Parte de mantenimiento';

  @override
  String get parteSubtitulo =>
      'Espacio Test Agrario Zunbeltz · documento PROVISIONAL';

  @override
  String get parteProvisional =>
      'DOCUMENTO PROVISIONAL — formato pendiente de validación.';

  @override
  String parteResumenTareas(int n) {
    return 'Tareas incluidas: $n';
  }

  @override
  String get parteColPunto => 'Punto';

  @override
  String get parteColTarea => 'Tarea';

  @override
  String get parteColResponsable => 'Responsable';

  @override
  String get parteColPrioridad => 'Prioridad';

  @override
  String get parteColEstado => 'Estado';

  @override
  String get parteColFecha => 'Fecha objetivo';

  @override
  String get parteSinResponsable => 'Sin asignar';

  @override
  String get segTitulo => 'Seguimiento';

  @override
  String get segIndicadores => 'Indicadores del periodo';

  @override
  String get segTodasFincas => 'Todas las fincas';

  @override
  String get segAlimentacion => 'Alimentación (kg)';

  @override
  String get segPariciones => 'Pariciones';

  @override
  String get segProductos => 'Productos comercializados';

  @override
  String get segIngresos => 'Ingresos';

  @override
  String get segGastos => 'Gastos';

  @override
  String get segBalance => 'Balance';

  @override
  String get segPestanaActividad => 'Actividad';

  @override
  String get segPestanaEconomico => 'Económico';

  @override
  String get segNuevaActividad => 'Registrar actividad';

  @override
  String get segNuevoApunte => 'Apunte económico';

  @override
  String get segSinRegistros => 'Sin registros todavía.';

  @override
  String get segInformePdf => 'Informe de seguimiento (PDF)';

  @override
  String get segGenerandoInforme => 'Generando informe…';

  @override
  String get actNuevaTitulo => 'Registrar actividad';

  @override
  String get actTipo => 'Tipo de actividad';

  @override
  String get actCantidad => 'Cantidad';

  @override
  String get actLote => 'Lote / rebaño';

  @override
  String get actNotas => 'Notas';

  @override
  String get actGuardada => 'Actividad registrada';

  @override
  String get actCantidadObligatoria => 'Indica una cantidad mayor que cero.';

  @override
  String get apuNuevoTitulo => 'Nuevo apunte económico';

  @override
  String get apuTipo => 'Tipo';

  @override
  String get apuConcepto => 'Concepto';

  @override
  String get apuImporte => 'Importe (€)';

  @override
  String get apuNotas => 'Notas';

  @override
  String get apuGuardado => 'Apunte guardado';

  @override
  String get apuImporteObligatorio => 'Indica un importe mayor que cero.';

  @override
  String get informeSegTitulo => 'Informe de seguimiento';

  @override
  String informeSegResumenPeriodo(int actividades, int apuntes) {
    return 'Registros: $actividades · apuntes: $apuntes';
  }

  @override
  String get informeSegTablaActividad => 'Registros de actividad';

  @override
  String get informeSegTablaEconomico => 'Apuntes económicos';

  @override
  String get informeSegColTipo => 'Tipo';

  @override
  String get informeSegColCantidad => 'Cantidad';

  @override
  String get informeSegColConcepto => 'Concepto';

  @override
  String get informeSegColImporte => 'Importe (€)';

  @override
  String get meteoTitulo => 'Previsión';

  @override
  String get meteoHoy => 'Hoy';

  @override
  String get meteoSinConexion =>
      'No se pudo obtener la previsión. Revisa la conexión e inténtalo de nuevo.';

  @override
  String get meteoReintentar => 'Reintentar';

  @override
  String get meteoOrientativo =>
      'Previsión orientativa (Open-Meteo). No sustituye el criterio del ganadero ni del veterinario.';

  @override
  String get avisoHelada => 'Helada';

  @override
  String get avisoLluvia => 'Lluvia';

  @override
  String get avisoViento => 'Viento fuerte';

  @override
  String get avisoCalor => 'Calor';

  @override
  String get avisoBuenManejo => 'Buen día de manejo';

  @override
  String get acercaTitulo => 'Acerca del Espacio Test';

  @override
  String get acercaIntro =>
      'Zunbeltz es el primer Espacio Test Agroganadero de Navarra: una incubadora donde personas emprendedoras prueban un proyecto de ganadería ecológica extensiva durante un periodo acotado, con acompañamiento de ganaderas y ganaderos expertos, sobre las fincas de Zunbeltz (231 ha) y La Planilla (197 ha). Impulsado por el Gobierno de Navarra, la Mancomunidad de Andía y los municipios de la zona, con financiación de la UE, y gestionado por la Asociación Zunbeltz Elkartea.';

  @override
  String get acercaEnlaces => 'Enlaces';

  @override
  String get acercaFuentes => 'Información de fuentes públicas.';

  @override
  String get navProyectos => 'Proyectos';

  @override
  String get proyectosTitulo => 'Proyectos de test';

  @override
  String get proyectosVacio =>
      'Aún no hay proyectos. Pulsa + para añadir el primero.';

  @override
  String get proyectoNuevo => 'Nuevo proyecto';

  @override
  String get proyectoNombre => 'Nombre del proyecto';

  @override
  String get proyectoPersona => 'Persona tester';

  @override
  String get proyectoActividad => 'Actividad / vertical';

  @override
  String get proyectoFinca => 'Finca (apoyo)';

  @override
  String get proyectoSinFinca => 'Sin finca';

  @override
  String get proyectoFechaInicio => 'Inicio';

  @override
  String get proyectoFechaFin => 'Fin';

  @override
  String get proyectoGuardado => 'Proyecto guardado';

  @override
  String get proyectoNombreObligatorio => 'Pon un nombre al proyecto.';

  @override
  String get proyectoBorrar => 'Borrar proyecto';

  @override
  String get rentTitulo => 'Rentabilidad';

  @override
  String get rentVentas => 'Ventas';

  @override
  String get rentOtrosIngresos => 'Otros ingresos';

  @override
  String get rentGastos => 'Gastos';

  @override
  String get rentBalance => 'Balance';

  @override
  String get rentMargen => 'Margen';

  @override
  String get rentProyeccion => 'Proyección anual';

  @override
  String get detProduccion => 'Producción';

  @override
  String get detValidacion => 'Validación';

  @override
  String get detComercial => 'Comercialización';

  @override
  String get detEconomico => 'Económico';

  @override
  String get detSinDatos => 'Sin datos todavía.';

  @override
  String get detInformePdf => 'Informe del proyecto (PDF)';

  @override
  String get comNuevaTitulo => 'Nueva venta';

  @override
  String get comProducto => 'Producto';

  @override
  String get comCanal => 'Canal';

  @override
  String get comCantidad => 'Cantidad';

  @override
  String get comUnidad => 'Unidad';

  @override
  String get comPrecio => 'Precio unitario (€)';

  @override
  String get comIngreso => 'Ingreso (€)';

  @override
  String get comGuardada => 'Venta guardada';

  @override
  String get valNuevaTitulo => 'Nueva validación de producto';

  @override
  String get valDescripcion => '¿Qué se valida?';

  @override
  String get valResultado => 'Resultado';

  @override
  String get valValoracion => 'Valoración';

  @override
  String get valSinValorar => 'Sin valorar';

  @override
  String get valGuardada => 'Validación guardada';

  @override
  String get infProyTitulo => 'Informe del proyecto de test';

  @override
  String infProyResumen(String nombre, String persona) {
    return 'Proyecto: $nombre · tester: $persona';
  }

  @override
  String get comparativaPdf => 'Comparativa (PDF)';

  @override
  String get comparativaTitulo => 'Comparativa de proyectos de test';

  @override
  String get comparativaColProyecto => 'Proyecto';

  @override
  String get comparativaColTester => 'Tester';

  @override
  String get comparativaTotal => 'Total';

  @override
  String get periodoEtiqueta => 'Periodo';

  @override
  String get periodoTodo => 'Todo';

  @override
  String get periodoAnio => 'Este año';

  @override
  String get periodoTrimestre => 'Este trimestre';

  @override
  String get periodoTrimestreAnterior => 'Trimestre anterior';

  @override
  String get detDesgloseGastos => 'Desglose de gastos';

  @override
  String get detIvaSoportado => 'IVA soportado';

  @override
  String get detIvaRepercutido => 'IVA repercutido';

  @override
  String get apuCategoria => 'Categoría';

  @override
  String get apuIva => 'IVA';

  @override
  String get comIva => 'IVA';

  @override
  String get ivaNoFiscal =>
      'Cálculo orientativo. No es un módulo de declaración fiscal: el régimen (REAGP / general) lo define vuestro asesor.';

  @override
  String get detExportarCsv => 'Exportar CSV';

  @override
  String get enviarCoordinador => 'Enviar al coordinador';

  @override
  String get enviarCoordinadorTexto =>
      'Informe del proyecto de test para el coordinador del Espacio Test Zunbeltz.';

  @override
  String get enviarCoordinadorSinDestino =>
      'Configura el correo del coordinador en Ajustes.';

  @override
  String get enviarCoordinadorAdjuntar =>
      'Adjunta el informe (ya generado en):';

  @override
  String get ajustesCoordinador => 'Coordinador (envío de informes)';

  @override
  String get ajustesCoordinadorVacio => 'Sin configurar';

  @override
  String get coordinadorCorreo => 'Correo del coordinador';

  @override
  String get ayudaTitulo => 'Ayuda';

  @override
  String get ayudaIntro =>
      'Una guía paso a paso para usar la app. Toca un apartado para abrirlo, o escribe arriba lo que buscas. Si te pierdes, vuelve atrás con la flecha de arriba a la izquierda.';

  @override
  String get ayudaBuscar => 'Buscar en la ayuda';

  @override
  String get ayudaSinResultados =>
      'No hay ningún apartado con esa palabra. Prueba con otra: «tarea», «zona», «venta», «token»…';

  @override
  String get ayudaConsejo => 'Bueno saber';

  @override
  String get ayudaGrupoEmpezar => 'Primeros pasos';

  @override
  String get ayudaGrupoFincas => 'Fincas y tareas';

  @override
  String get ayudaGrupoProyectos => 'Tu proyecto de test';

  @override
  String get ayudaGrupoEquipo => 'Trabajar en equipo';

  @override
  String get ayudaGrupoProblemas => 'Si algo falla';

  @override
  String get ayudaQueEsT => '¿Qué es esta app?';

  @override
  String get ayudaQueEsB =>
      'Es la herramienta del Espacio Test Zunbeltz. Sirve para dos cosas: llevar el seguimiento de tu proyecto de test (lo que produces, lo que vendes, lo que gastas y lo que ganas) y cuidar las fincas (las infraestructuras del mapa y sus tareas de mantenimiento).\nTodo se guarda en tu móvil y funciona sin cobertura en el monte.';

  @override
  String get ayudaPestanasT => 'Moverse por la app';

  @override
  String get ayudaPestanasB =>
      'Abajo tienes cuatro pestañas. Tócalas para cambiar de pantalla:\n• Hoy: un resumen con las tareas abiertas.\n• Fincas: el mapa con los puntos, las zonas y las tareas.\n• Proyectos: tu proceso de test y tus números.\n• Ajustes: idioma, ayuda, envío de informes y sincronización.\nPara volver atrás, usa la flecha de arriba a la izquierda.';

  @override
  String get ayudaIdiomaDatosT => 'Idioma, fotos, tiempo e internet';

  @override
  String get ayudaIdiomaDatosB =>
      '• Cambia entre castellano y euskera en Ajustes → Idioma.\n• Las fotos se guardan en tu propio móvil.\n• En Fincas, el icono de la nube (arriba) abre el tiempo de la finca: cómo está ahora, las próximas 24 horas, el agua (lluvia caída, lluvia prevista y lo que pierden suelo y pasto) y los próximos 7 días. Toca un día para ver más detalle.\n• Avisos: helada, nieve, tormenta, lluvia, viento fuerte, calor, estrés por calor del ganado y días buenos para el manejo.\n» Todo funciona sin internet menos el tiempo y la sincronización de tareas. Sin cobertura, el tiempo muestra la última previsión que se descargó y avisa de cuándo es.';

  @override
  String get ayudaFincasT => 'Marcar un punto en el mapa';

  @override
  String get ayudaFincasB =>
      'Un punto es cada infraestructura: abrevadero, manga, cierre, refugio, balsa…\n1. Entra en Fincas.\n2. Toca el sitio exacto en el mapa. O pulsa «Nuevo punto» (abajo a la derecha) y elige «Usar GPS actual» si estás junto a la instalación, o «Usar centro del mapa».\n3. Elige el tipo y el estado, ponle nombre y, si quieres, añade fotos.\n4. Pulsa Guardar.\n» El color del punto dice su estado: verde, operativo; ocre, revisar; rojizo, averiado. El botón «GPS» centra el mapa en ti y «Capas» cambia entre mapa y satélite.';

  @override
  String get ayudaZonasT => 'Dibujar una zona (parcela, cercado…)';

  @override
  String get ayudaZonasB =>
      '1. En Fincas, pulsa «Dibujar zona».\n2. Toca en el mapa las esquinas de la zona, una detrás de otra. Si te equivocas, pulsa «Deshacer».\n3. Con tres esquinas o más, pulsa «Cerrar zona».\n4. Elige la finca, el tipo (parcela de pasto, cercado, zona de pastoreo…), el nombre y el estado, y guarda.\n» La superficie que sale del dibujo es orientativa. Si tienes la oficial del recinto SIGPAC, ponla en «Superficie oficial SIGPAC» y será la que se use.';

  @override
  String get ayudaEditarMapaT => 'Mover o borrar un punto o una zona';

  @override
  String get ayudaEditarMapaB =>
      '1. Toca el punto o la zona en el mapa para abrir su ficha.\n2. Para mover un punto: pulsa «Recolocar en el mapa» (arriba) y toca el sitio nuevo.\n3. Para corregir una zona: pulsa «Volver a dibujar» (arriba) y marca de nuevo sus esquinas.\n4. Para borrarlo: pulsa la papelera y confirma.';

  @override
  String get ayudaTareasT => 'Apuntar una tarea de mantenimiento';

  @override
  String get ayudaTareasB =>
      '1. Abre la ficha de un punto o de una zona y pulsa «Nueva tarea».\n2. Escribe qué hay que hacer. Si quieres, añade responsable, prioridad, fecha objetivo, fotos de antes y después y el coste.\n3. Pulsa Guardar.\n» La tarea queda unida a ese punto o zona: la verás en su ficha y en el tablero de tareas.';

  @override
  String get ayudaRecurrentesT => 'Tareas que se repiten';

  @override
  String get ayudaRecurrentesB =>
      'Lo que se hace siempre (rellenar comederos, revisar el vallado…) no hace falta apuntarlo cada vez.\n1. Al crear la tarea, elige una «Periodicidad»: diaria, semanal, quincenal, mensual o trimestral.\n2. Cuando la marques como hecha, la app crea sola la siguiente, con la fecha que toca.\n» En la lista, las tareas periódicas llevan el símbolo de repetir.';

  @override
  String get ayudaTableroT => 'Llevar las tareas al día';

  @override
  String get ayudaTableroB =>
      '1. En Fincas, pulsa «Tareas» (arriba) para ver el tablero con todas.\n2. Filtra por finca y por estado. Si sincronizas con el equipo, «Mis tareas» deja solo las que tienes asignadas.\n3. Para darla por hecha, pulsa el círculo con la marca, a la derecha de la tarea.\n4. Toca una tarea para cambiar su estado (pendiente, en curso, hecha, bloqueada), asignártela o soltarla.\n5. Con «Parte PDF» sacas el parte de mantenimiento de lo que tengas filtrado, para imprimirlo o enviarlo.';

  @override
  String get ayudaProyectosT => 'Crear tu proyecto';

  @override
  String get ayudaProyectosB =>
      '1. Entra en Proyectos y pulsa +.\n2. Pon el nombre del proyecto, la persona tester y la actividad. Si quieres, también la finca y las fechas de inicio y fin.\n3. Pulsa Guardar. Toca el proyecto en la lista para entrar en él.';

  @override
  String get ayudaApuntarT => 'Apuntar tu día a día';

  @override
  String get ayudaApuntarB =>
      'Dentro del proyecto hay cuatro pestañas: Producción, Comercialización, Validación y Económico.\n1. Ve a la pestaña de lo que quieras apuntar.\n2. Pulsa + y rellena lo que toque: lo producido; una venta (producto, canal, cantidad y precio); una prueba de producto y su resultado; o un gasto o ingreso con su categoría.\n3. Guarda. Los números de arriba se actualizan solos.';

  @override
  String get ayudaNumerosT => 'Entender tus números';

  @override
  String get ayudaNumerosB =>
      'Arriba del proyecto ves la rentabilidad: ventas, otros ingresos, gastos, balance, margen y la proyección a un año.\n• Con el filtro «Periodo» (arriba) lo miras para todo, este año, este trimestre o el trimestre anterior.\n• Si hay gastos, verás el desglose por categorías y el IVA soportado y repercutido.\n» El IVA es un cálculo orientativo, no una declaración fiscal: el régimen lo decide vuestro asesor.';

  @override
  String get ayudaInformesT => 'Sacar informes y enviarlos';

  @override
  String get ayudaInformesB =>
      '• En tu proyecto, el botón de compartir (arriba) saca el «Informe del proyecto (PDF)», lo exporta a CSV (se abre con Excel) o lo manda con «Enviar al coordinador».\n• Para enviarlo al coordinador, pon antes su correo en Ajustes → Coordinador.\n• En la lista de Proyectos, el botón del gráfico (arriba) saca la «Comparativa (PDF)» entre todos los proyectos.\n• En Ajustes, «Exportar espacio (CSV)» saca las fincas y los puntos del mapa, para pasarlos a coordinación.';

  @override
  String get ayudaSyncT => 'Compartir las tareas con el equipo';

  @override
  String get ayudaSyncB =>
      'Si en el Espacio Test usáis la sincronización, las tareas se comparten entre los móviles de todo el equipo.\n1. Pide a coordinación tu token personal. Es tu llave: cada persona tiene el suyo y no se comparte.\n2. En Ajustes → Sincronización de tareas, pon la dirección del WordPress de Zunbeltz y tu token.\n3. Pulsa «Sincronizar ahora» cuando tengas cobertura: suben tus cambios y bajan los del resto.\n» Solo se comparten las tareas. Los puntos, las zonas y los proyectos siguen solo en tu móvil.';

  @override
  String get ayudaRolesT => 'Quién puede hacer qué';

  @override
  String get ayudaRolesB =>
      'Cada persona tiene un rol, que le da coordinación.\n• Coordinación: ve, crea, cambia y reparte todas las tareas.\n• Tester: ve todas y crea las suyas. Puede cambiar las que ha creado o tiene asignadas, y coger las que están sin asignar.\n» En Ajustes ves con qué nombre y rol estás conectada. Sin sincronización estás en «Modo local» y puedes editarlo todo.';

  @override
  String get ayudaProblemasT => 'Problemas frecuentes';

  @override
  String get ayudaProblemasB =>
      '• «Tu rol no permite…»: esa tarea no es tuya. Cógela si está sin asignar, o pide a coordinación que te la asigne.\n• «Cambios revertidos» al sincronizar: tocaste algo que tu rol no permite y se ha dejado como estaba.\n• «Token incorrecto»: revisa que lo copiaste entero. Si lo has perdido, coordinación te genera uno nuevo y el viejo deja de valer.\n• «Sin finca reconocida»: esa tarea es de una finca que en tu móvil tiene otro nombre. Las fincas tienen que llamarse igual en todos los móviles.\n• No sale la previsión del tiempo: necesita internet. Lo demás funciona sin cobertura.\n» Tus datos viven en tu móvil. Si lo cambias o lo pierdes, habla antes con coordinación.';

  @override
  String get ayudaPie =>
      'Si algo no queda claro, pregunta a coordinación del Espacio Test.';

  @override
  String get ajustesExportarEspacio => 'Exportar espacio (CSV)';

  @override
  String get ajustesSyncTitulo => 'Sincronización de tareas';

  @override
  String get ajustesSyncUrl => 'WordPress de Zunbeltz';

  @override
  String get ajustesSyncToken => 'Token personal';

  @override
  String get ajustesSyncSinConfigurar => 'Sin configurar';

  @override
  String get ajustesSyncAhora => 'Sincronizar ahora';

  @override
  String ajustesSyncResultado(int subidas, int bajadas, int omitidas) {
    String _temp0 = intl.Intl.pluralLogic(
      omitidas,
      locale: localeName,
      other: ' · $omitidas sin finca reconocida',
      zero: '',
    );
    return '$subidas tareas subidas · $bajadas bajadas$_temp0';
  }

  @override
  String get ajustesDemo => 'Cargar datos de demostración';

  @override
  String get demoCargada => 'Datos de demostración cargados';

  @override
  String get demoYaHay =>
      'Ya hay proyectos; bórralos para recargar la demostración.';

  @override
  String get zonaDibujar => 'Dibujar zona';

  @override
  String get zonaNuevaTitulo => 'Nueva zona';

  @override
  String get zonaTitulo => 'Zonas';

  @override
  String get zonaFinca => 'Finca';

  @override
  String get zonaTipo => 'Tipo de zona';

  @override
  String get zonaNombre => 'Nombre';

  @override
  String get zonaEstado => 'Estado';

  @override
  String get zonaNotas => 'Notas';

  @override
  String get zonaFotos => 'Fotos';

  @override
  String get zonaRecintoSigpac => 'Recinto SIGPAC';

  @override
  String get zonaSuperficie => 'Superficie';

  @override
  String get zonaSuperficieOficial => 'Superficie oficial SIGPAC (ha)';

  @override
  String get zonaPerimetro => 'Perímetro';

  @override
  String get zonaOrientativa => 'orientativa';

  @override
  String get zonaAvisoSuperficie =>
      'La superficie del trazado es orientativa: la oficial es la del recinto SIGPAC. Si la tenéis, ponedla en «Superficie oficial» y será la que se use.';

  @override
  String get zonaGuardada => 'Zona guardada';

  @override
  String get zonaBorrar => 'Borrar zona';

  @override
  String get zonaTareas => 'Tareas de la zona';

  @override
  String get zonaSinTareas => 'Sin tareas en esta zona.';

  @override
  String get zonaNuevaTarea => 'Nueva tarea';

  @override
  String get zonaRedibujar => 'Volver a dibujar';

  @override
  String get zonaTrazadoActualizado => 'Trazado actualizado';

  @override
  String get zonaTrazadoCorto =>
      'Marca al menos tres esquinas para cerrar la zona.';

  @override
  String get dibujoTocaVertices =>
      'Toca las esquinas de la zona. Con tres o más, pulsa «Cerrar zona».';

  @override
  String get dibujoDeshacer => 'Deshacer';

  @override
  String get dibujoCerrar => 'Cerrar zona';

  @override
  String get dibujoCancelar => 'Cancelar';

  @override
  String dibujoEnCurso(String esquinas, String ha) {
    return '$esquinas · ≈ $ha ha';
  }

  @override
  String dibujoEsquinas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n esquinas',
      one: '1 esquina',
      zero: 'Sin esquinas',
    );
    return '$_temp0';
  }

  @override
  String get tareaDeZona => 'Tarea de zona';

  @override
  String get parteColZona => 'Zona';

  @override
  String ajustesSesionComo(String nombre) {
    return 'Sesión de $nombre';
  }

  @override
  String ajustesSesionConectada(String nombre) {
    return 'Sesión iniciada: $nombre';
  }

  @override
  String get ajustesSesionLocal => 'Modo local';

  @override
  String get ajustesSesionLocalDetalle =>
      'Sin sincronización: en este dispositivo se puede editar todo.';

  @override
  String ajustesSyncRechazadas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cambios revertidos: tu rol no los permite',
      one: '1 cambio revertido: tu rol no lo permite',
    );
    return '$_temp0';
  }

  @override
  String get tareaSinAsignar => 'Sin asignar';

  @override
  String get tareaAsignarme => 'Asignármela';

  @override
  String get tareaSoltar => 'Soltar la tarea';

  @override
  String get tareaCambiarEstado => 'Cambiar estado';

  @override
  String get tareaSinPermiso => 'Tu rol no permite cambiar esta tarea.';

  @override
  String get tareaNoPuedesCrear => 'Tu rol no permite crear tareas.';

  @override
  String get tableroMisTareas => 'Mis tareas';

  @override
  String get meteoAhora => 'Ahora';

  @override
  String get meteoSensacion => 'Sensación';

  @override
  String get meteoHumedad => 'Humedad';

  @override
  String get meteoViento => 'Viento';

  @override
  String get meteoRachas => 'rachas';

  @override
  String meteoLuz(int horas, int minutos) {
    return '$horas h $minutos min de luz';
  }

  @override
  String get meteoAmanecer => 'Amanece';

  @override
  String get meteoAnochecer => 'Anochece';

  @override
  String meteoAltitud(int metros) {
    return 'Datos del modelo a $metros m de altitud';
  }

  @override
  String get meteoProximasHoras => 'Próximas 24 horas';

  @override
  String get meteoAgua => 'Agua y pasto';

  @override
  String get meteoLluviaPasada => 'Lluvia últimos 7 días';

  @override
  String get meteoLluviaPrevista => 'Lluvia prevista (7 días)';

  @override
  String get meteoEvapotranspiracion =>
      'Agua que pierden suelo y pasto (7 días)';

  @override
  String get meteoBalanceSeco =>
      'Se prevé que suelo y pasto pierdan más agua de la que va a llover: ojo al pasto, las balsas y los abrevaderos.';

  @override
  String get meteoBalanceHumedo =>
      'Se prevé más lluvia de la que pierden suelo y pasto.';

  @override
  String get meteoDiasTitulo => 'Próximos 7 días';

  @override
  String get meteoSensacionMin => 'Sensación mínima';

  @override
  String get meteoHorasLluvia => 'Horas de lluvia';

  @override
  String get meteoNieve => 'Nieve';

  @override
  String get meteoUv => 'Índice UV máximo';

  @override
  String get meteoThi => 'Índice de estrés por calor (THI) máximo';

  @override
  String get meteoThiNota =>
      'El THI y su umbral de alerta (75, índice de seguridad del ganado LCI) son orientativos y están pendientes de validar con el veterinario para vacuno de carne y ovino en extensivo.';

  @override
  String meteoGuardada(String fecha) {
    return 'Sin conexión. Previsión guardada el $fecha.';
  }

  @override
  String meteoActualizado(String fecha) {
    return 'Actualizado $fecha';
  }

  @override
  String get avisoNieve => 'Nieve';

  @override
  String get avisoTormenta => 'Tormenta';

  @override
  String get avisoEstresCalor => 'Estrés por calor';

  @override
  String get meteoEvapotranspiracionDia => 'Agua que pierden suelo y pasto';

  @override
  String get actualizacionesTitulo => 'Actualizaciones';

  @override
  String get actualizacionesVersionInstalada => 'Versión instalada';

  @override
  String get actualizacionesUltimaPublicada => 'Última publicada';

  @override
  String get actualizacionesSinConexion => 'sin conexión';

  @override
  String get actualizacionesNingunaTodavia => 'ninguna todavía';

  @override
  String get actualizacionesPublicadaEl => 'Publicada el';

  @override
  String get actualizacionesComprobadoEl => 'Comprobado el';

  @override
  String get actualizacionesHayVersionNueva => 'Hay una versión nueva.';

  @override
  String get actualizacionesTienesLaUltima => 'Tienes la última versión.';

  @override
  String get actualizacionesQueTrae => 'Qué trae';

  @override
  String get actualizacionesDescargando => 'Descargando…';

  @override
  String get actualizacionesDescargarEInstalar => 'Descargar e instalar';

  @override
  String get actualizacionesBuscarAhora => 'Buscar ahora';

  @override
  String get actualizacionesVersionDisponible => 'Versión disponible';

  @override
  String get actualizacionesTienesInstalada => 'Tienes instalada la';

  @override
  String get actualizacionesTocaParaActualizar => 'Toca para actualizar.';

  @override
  String get actualizacionesActualizar => 'Actualizar';

  @override
  String get actualizacionesDescartar => 'Descartar por ahora';

  @override
  String get actualizacionesInstaladorAbierto =>
      'Se ha abierto el instalador. Confirma la actualización y vuelve a abrir la app.';

  @override
  String get actualizacionesDescargaEnNavegador =>
      'Se ha abierto la descarga en el navegador.';

  @override
  String get actualizacionesErrorDescarga =>
      'No se ha podido descargar. Comprueba la conexión y vuelve a probar.';

  @override
  String get actualizacionesErrorInstalador =>
      'Descargada, pero Android no ha dejado abrir el instalador. Permite «instalar apps desconocidas» para esta app en los ajustes del móvil.';

  @override
  String get ajustesActualizacionesSubtitulo =>
      'Versión instalada y última publicada';
}
