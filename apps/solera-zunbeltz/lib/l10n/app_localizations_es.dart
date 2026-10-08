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
      'Adjunta el informe PDF que acabas de guardar.';

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
      'Es la herramienta del Espacio Test Zunbeltz. Sirve para dos cosas: llevar el seguimiento de tu proyecto de test (lo que produces, lo que vendes, lo que gastas y lo que ganas) y cuidar las fincas (las infraestructuras del mapa y sus tareas de mantenimiento).\nTodo se guarda en tu móvil y funciona sin cobertura en el monte. Si sincronizas, además lo compartes con el resto del equipo a través del servidor de Zunbeltz.';

  @override
  String get ayudaPestanasT => 'Moverse por la app';

  @override
  String get ayudaPestanasB =>
      'Abajo tienes cuatro pestañas. Tócalas para cambiar de pantalla:\n• Hoy: la bandeja del espacio — alarmas, tareas vencidas y próximas, peticiones y avisos.\n• Fincas: el mapa con los puntos, las zonas y las tareas.\n• Proyectos: el proceso de test, sus números y el convenio.\n• Ajustes: idioma, sincronización, actualizaciones, envío de informes e información sobre el Espacio Test.\nEn Hoy, los iconos de arriba abren los contactos, el tiempo y esta ayuda.\nPara volver atrás, usa la flecha de arriba a la izquierda.';

  @override
  String get ayudaIdiomaDatosT => 'Idioma, fotos, tiempo e internet';

  @override
  String get ayudaIdiomaDatosB =>
      '• Cambia entre castellano y euskera en Ajustes → Idioma.\n• Las fotos se guardan en tu propio móvil.\n• En Hoy o en Fincas, el icono de la nube (arriba) abre el tiempo de la finca: cómo está ahora, las próximas 24 horas, el agua (lluvia caída, lluvia prevista y lo que pierden suelo y pasto) y los próximos 7 días. Toca un día para ver más detalle.\n• Avisos: helada, nieve, tormenta, lluvia, viento fuerte, calor, estrés por calor del ganado y días buenos para el manejo.\n» Todo funciona sin internet menos el tiempo, la sincronización y las actualizaciones. Sin cobertura, el tiempo muestra la última previsión que se descargó y avisa de cuándo es.';

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
      'Los proyectos los crea coordinación, y cada uno es de una persona tester.\n1. En Proyectos, pulsa + (solo coordinación).\n2. Pon el nombre, la actividad y elige la persona tester. Si quieres, también la finca y las fechas.\n3. Pulsa Guardar.\n» Cada persona tester ve solo su proyecto. Coordinación ve todos y, al terminar el test, lo cierra desde el menú del proyecto (⋮ → Cerrar proyecto).';

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
      '• En tu proyecto, el botón de compartir (arriba) saca el «Informe del proyecto (PDF)», lo exporta a CSV (se abre con Excel) o lo manda con «Enviar al coordinador». El correo al que se manda se pone en Ajustes → «Coordinador (envío de informes)».\n• El informe incluye las cuentas del convenio: balance del test y del proyecto, reparto, fianza, acompañamiento e incidencias.\n• Los PDF salen con la marca «BORRADOR». La versión definitiva la saca coordinación con el proyecto cerrado.\n• En la lista de Proyectos, el botón del gráfico saca la «Comparativa (PDF)» entre proyectos.\n• En Ajustes, «Exportar espacio (CSV)» saca las fincas y los puntos del mapa.';

  @override
  String get ayudaSyncT => 'Compartir el espacio con el equipo';

  @override
  String get ayudaSyncB =>
      'Con la sincronización, todo el equipo comparte el mismo espacio: fincas, puntos, zonas, tareas, proyectos, peticiones y avisos.\n1. Pide a coordinación tu token personal. Es tu llave: cada persona tiene el suyo y no se comparte.\n2. En Ajustes → Sincronización, pon la dirección del WordPress de Zunbeltz y tu token.\n3. La app sincroniza sola al abrirla, al volver a ella y cada 10 minutos si hay cobertura. También puedes pulsar el botón de sincronizar en Hoy.\n» Sin cobertura puedes seguir trabajando: lo que hagas sube en cuanto vuelva la conexión. Las fotos se quedan en tu móvil.';

  @override
  String get ayudaRolesT => 'Quién puede hacer qué';

  @override
  String get ayudaRolesB =>
      'Cada persona tiene un rol, que le da coordinación.\n• Coordinación: crea, reparte y cierra tareas; gestiona fincas, zonas, puntos y todos los proyectos; acepta o descarta peticiones; ve lo que pasa en el espacio.\n• Tester: ve sus tareas y las generales (las que no son de nadie), cambia su estado, coge una general o suelta una suya. Pide tareas en vez de crearlas. Añade y mueve puntos (un corral móvil, un bidón), da avisos y apunta el día a día de su proyecto mientras esté abierto.\n» En Ajustes ves con qué nombre y rol estás conectada. Sin sincronización estás en «Modo local» y puedes editarlo todo.';

  @override
  String get ayudaProblemasT => 'Problemas frecuentes';

  @override
  String get ayudaProblemasB =>
      '• «Tu rol no permite…»: eso no te toca. Una tarea, cógela si está sin asignar o pide a coordinación que te la asigne.\n• «… cambios revertidos: tu rol no los permite» al sincronizar: tocaste algo que tu rol no permite y se ha dejado como estaba.\n• «Token incorrecto»: revisa que lo copiaste entero. Si lo has perdido, coordinación te genera uno nuevo y el viejo deja de valer.\n• Falta algo o ves cosas que ya no son tuyas: en Ajustes, «Sincronizar todo desde cero».\n• No sale la previsión del tiempo: necesita internet. Lo demás funciona sin cobertura.\n• La actualización se descarga pero no se instala: en los ajustes del móvil, permite «instalar apps desconocidas» para Solera Zunbeltz.\n» Con sincronización, tus datos están también en el servidor de Zunbeltz: si cambias de móvil, configura el nuevo con tu token y lo recuperas.';

  @override
  String get ayudaPie =>
      'Si algo no queda claro, pregunta a coordinación del Espacio Test.';

  @override
  String get ajustesExportarEspacio => 'Exportar espacio (CSV)';

  @override
  String get ajustesSyncTitulo => 'Sincronización';

  @override
  String get ajustesSyncUrl => 'WordPress de Zunbeltz';

  @override
  String get ajustesSyncToken => 'Token personal';

  @override
  String get ajustesSyncSinConfigurar => 'Sin configurar';

  @override
  String get ajustesSyncAhora => 'Sincronizar ahora';

  @override
  String ajustesSyncResultado(int enviados, int recibidos, int retirados) {
    String _temp0 = intl.Intl.pluralLogic(
      retirados,
      locale: localeName,
      other: ' · $retirados retirados de este móvil',
      zero: '',
    );
    return '$enviados cambios enviados · $recibidos recibidos$_temp0';
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

  @override
  String get fotosSoloEnMovil => 'Las fotos se añaden desde la app del móvil.';

  @override
  String get demoFranja =>
      'Versión de prueba: los datos se guardan solo en este navegador y no se comparten con nadie.';

  @override
  String get ajustesSyncCompleta => 'Sincronizar todo desde cero';

  @override
  String get ajustesSyncCompletaDetalle =>
      'Vuelve a bajar todo el espacio y quita de este móvil lo que ya no te corresponde.';

  @override
  String get ajustesDemoSoloLocal =>
      'Los datos de ejemplo solo se cargan en modo local, para que no lleguen al WordPress de Zunbeltz.';

  @override
  String get fincaNueva => 'Nueva finca';

  @override
  String get fincaNuevaNombre => 'Nombre';

  @override
  String get fincaNuevaSuperficie => 'Superficie (ha)';

  @override
  String get fincaNuevaCentro =>
      'Se coloca en el centro del mapa. Muévelo antes si hace falta.';

  @override
  String fincaNuevaCreada(String nombre) {
    return 'Finca «$nombre» creada';
  }

  @override
  String get proyectoEditar => 'Editar proyecto';

  @override
  String get proyectoPersonaTester => 'Persona tester';

  @override
  String get proyectoSinPersona => 'Sin asignar';

  @override
  String get proyectoCerrar => 'Cerrar proyecto';

  @override
  String get proyectoReabrir => 'Reabrir proyecto';

  @override
  String get proyectoCerrarPregunta =>
      'Al cerrarlo, la persona tester ya no podrá apuntar en él y los informes saldrán como versión definitiva. ¿Cerrar el proyecto?';

  @override
  String proyectoCerradoAviso(String fecha) {
    return 'Proyecto cerrado el $fecha. Solo coordinación puede cambiarlo.';
  }

  @override
  String get proyectoCerradoEtiqueta => 'Cerrado';

  @override
  String get proyectoMas => 'Más opciones';

  @override
  String get peticionesTitulo => 'Peticiones de tarea';

  @override
  String get peticionNueva => 'Pedir una tarea';

  @override
  String get peticionQue => 'Qué hace falta';

  @override
  String get peticionDetalles => 'Detalles';

  @override
  String get peticionFinca => 'Finca';

  @override
  String get peticionSinFinca => 'Sin finca concreta';

  @override
  String get peticionUrgente => 'Es urgente';

  @override
  String get peticionUrgenteEtiqueta => 'Urgente';

  @override
  String get peticionEnviada =>
      'Petición guardada. Coordinación la verá al sincronizar.';

  @override
  String get peticionesVacio => 'No hay peticiones.';

  @override
  String get peticionCrearTarea => 'Crear la tarea';

  @override
  String get peticionDescartar => 'Descartar';

  @override
  String get peticionMotivo => 'Motivo (lo verá quien la pidió)';

  @override
  String get peticionRetirar => 'Retirar la petición';

  @override
  String get peticionEstadoPendiente => 'Pendiente';

  @override
  String get peticionEstadoAceptada => 'Aceptada: tarea creada';

  @override
  String get peticionEstadoDescartada => 'Descartada';

  @override
  String peticionDe(String nombre) {
    return 'Pide $nombre';
  }

  @override
  String peticionRespuesta(String texto) {
    return 'Respuesta: $texto';
  }

  @override
  String get peticionNecesitaFinca =>
      'Para crear la tarea, elige antes una finca.';

  @override
  String get personaDesconocida => 'alguien del espacio';

  @override
  String get avisoCategoriaGanado => 'Ganado';

  @override
  String get avisoCategoriaInstalaciones => 'Instalaciones';

  @override
  String get avisoCategoriaSeguimiento => 'Seguimiento individual';

  @override
  String get avisoCategoriaNoticias => 'Noticias';

  @override
  String get avisoNuevo => 'Dar un aviso';

  @override
  String get avisoTitulo => 'Qué pasa';

  @override
  String get avisoDescripcion => 'Detalles';

  @override
  String get avisoCategoria => 'Categoría';

  @override
  String get avisoEsAlarma =>
      'Es una alarma (animal enfermo, rotura importante, falta de alimento…)';

  @override
  String get avisoAlarma => 'Alarma';

  @override
  String get avisoGuardado =>
      'Aviso guardado. Llegará al resto al sincronizar.';

  @override
  String get avisoResolver => 'Marcar como resuelto';

  @override
  String get avisoReabrir => 'Reabrir';

  @override
  String get avisoResuelto => 'Resuelto';

  @override
  String get avisoBorrar => 'Borrar aviso';

  @override
  String get avisosVacio => 'Sin avisos en esta categoría.';

  @override
  String avisoDe(String nombre) {
    return 'Avisa $nombre';
  }

  @override
  String hoyAlarmasAbiertas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n alarmas abiertas',
      one: '1 alarma abierta',
    );
    return '$_temp0';
  }

  @override
  String hoyTareasVencidas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n tareas vencidas',
      one: '1 tarea vencida',
      zero: 'Ninguna tarea vencida',
    );
    return '$_temp0';
  }

  @override
  String hoyTareasProximas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n tareas en los próximos 7 días',
      one: '1 tarea en los próximos 7 días',
      zero: 'Nada para los próximos 7 días',
    );
    return '$_temp0';
  }

  @override
  String hoyPeticionesPendientes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n peticiones pendientes',
      one: '1 petición pendiente',
    );
    return '$_temp0';
  }

  @override
  String get hoyActividad => 'Lo último en el espacio';

  @override
  String get hoyActividadVacia =>
      'Todavía no ha llegado actividad. Sincroniza para verla.';

  @override
  String get hoyAvisos => 'Avisos';

  @override
  String get hoyTareas => 'Tareas';

  @override
  String get hoyTiempo => 'El tiempo';

  @override
  String actividadCrear(String persona, String cosa) {
    return '$persona ha añadido $cosa';
  }

  @override
  String actividadEditar(String persona, String cosa) {
    return '$persona ha cambiado $cosa';
  }

  @override
  String actividadBorrar(String persona, String cosa) {
    return '$persona ha borrado $cosa';
  }

  @override
  String actividadMover(String persona, String cosa) {
    return '$persona ha movido $cosa';
  }

  @override
  String actividadEstado(String persona, String cosa, String estado) {
    return '$persona ha marcado $cosa como «$estado»';
  }

  @override
  String actividadAsignar(String persona, String cosa, String responsable) {
    return '$persona ha asignado $cosa a $responsable';
  }

  @override
  String actividadDesasignar(String persona, String cosa) {
    return '$persona ha dejado sin asignar $cosa';
  }

  @override
  String actividadEn(String lugar) {
    return 'en $lugar';
  }

  @override
  String get actividadDesdePanel => 'desde la oficina';

  @override
  String get tipoEntidadTarea => 'la tarea';

  @override
  String get tipoEntidadPunto => 'el punto';

  @override
  String get tipoEntidadFinca => 'la finca';

  @override
  String get tipoEntidadZona => 'la zona';

  @override
  String get tipoEntidadProyecto => 'el proyecto';

  @override
  String get tipoEntidadApunte => 'el apunte';

  @override
  String get tipoEntidadVenta => 'la venta';

  @override
  String get tipoEntidadRegistro => 'el registro';

  @override
  String get tipoEntidadValidacion => 'la prueba de producto';

  @override
  String get tipoEntidadPeticion => 'la petición';

  @override
  String get tipoEntidadAviso => 'el aviso';

  @override
  String get tipoEntidadOtra => 'un dato';

  @override
  String get notificacionCanalAlarmas => 'Alarmas del espacio';

  @override
  String get notificacionCanalAvisos => 'Avisos y recordatorios';

  @override
  String notificacionAlarma(String titulo) {
    return 'Alarma: $titulo';
  }

  @override
  String notificacionAlarmas(int n) {
    return '$n alarmas nuevas en el espacio';
  }

  @override
  String notificacionPeticiones(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n peticiones de tarea nuevas',
      one: 'Nueva petición de tarea',
    );
    return '$_temp0';
  }

  @override
  String notificacionCambios(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n cambios en el espacio',
      one: '1 cambio en el espacio',
    );
    return '$_temp0';
  }

  @override
  String notificacionVencidas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Tienes $n tareas vencidas',
      one: 'Tienes 1 tarea vencida',
    );
    return '$_temp0';
  }

  @override
  String get notificacionVencidasCuerpo =>
      'Siguen pendientes hasta que se marquen como hechas.';

  @override
  String get apuAsumidoPor => 'Lo asume';

  @override
  String get apuAmortizacion => 'Es amortización (infraestructura o material)';

  @override
  String get apuAmortizacionDetalle =>
      'Cuenta en el balance del proyecto, no en el del test.';

  @override
  String get convenioTitulo => 'Convenio';

  @override
  String get convenioBalance => 'Balance';

  @override
  String get convenioPresupuesto => 'Presupuesto';

  @override
  String get convenioFianza => 'Fianza';

  @override
  String get convenioAcompanamiento => 'Acompañamiento';

  @override
  String get convenioIncidencias => 'Incidencias';

  @override
  String get convenioProvisional =>
      'Orientativo, según el convenio tester. No es contabilidad ni declaración fiscal.';

  @override
  String get balanceIngresos => 'Ingresos';

  @override
  String get balanceGastosTest => 'Gastos del test (sin amortizaciones)';

  @override
  String get balanceAmortizaciones => 'Amortizaciones';

  @override
  String get balanceTest => 'Balance del test';

  @override
  String get balanceProyecto => 'Balance del proyecto (coste real)';

  @override
  String get balanceAsumeTester => 'Gastos que asume la persona tester';

  @override
  String get balanceAsumeZunbeltz => 'Gastos que asume Zunbeltz';

  @override
  String get balanceReparto => 'Reparto del resultado';

  @override
  String balanceRepartoDetalle(String tipo, int zunbeltz, int tester) {
    return '$tipo: $zunbeltz % Zunbeltz · $tester % tester';
  }

  @override
  String get balanceBeneficio => 'Beneficio';

  @override
  String get balancePerdida => 'Pérdida';

  @override
  String get balanceParteZunbeltz => 'Parte de Zunbeltz';

  @override
  String get balanceParteTester => 'Parte de la persona tester';

  @override
  String get balancePrevistoReal => 'Previsto frente a real';

  @override
  String get balancePrevisto => 'Previsto';

  @override
  String get balanceReal => 'Real';

  @override
  String get balancePorcentajes => 'Cambiar porcentajes del reparto';

  @override
  String get balancePorcentajeBeneficio => '% para Zunbeltz si hay beneficio';

  @override
  String get balancePorcentajePerdida => '% para Zunbeltz si hay pérdida';

  @override
  String get presupuestoVacio =>
      'Sin presupuesto. Coordinación añade las partidas del anexo II.';

  @override
  String get presupuestoNuevaPartida => 'Añadir partida';

  @override
  String get presupuestoTotal => 'Total previsto';

  @override
  String get fianzaReferencia =>
      'Fianza de referencia (10 % de lo que asume Zunbeltz)';

  @override
  String get fianzaDepositado => 'Depositado';

  @override
  String get fianzaDevuelto => 'Devuelto';

  @override
  String get fianzaRetenido => 'Retenido (incluidas incidencias)';

  @override
  String get fianzaPendiente => 'En depósito ahora';

  @override
  String get fianzaNuevoMovimiento => 'Añadir movimiento';

  @override
  String get acompanamientoNuevo => 'Añadir actividad';

  @override
  String get acompanamientoVacio =>
      'Sin actividades de acompañamiento todavía.';

  @override
  String acompanamientoIndicadores(int meses) {
    return 'Indicadores del anexo IV ($meses meses)';
  }

  @override
  String get acompanamientoSoporte =>
      'Soporte integral: formación, visita de referencia y asesoramiento';

  @override
  String get acompanamientoDifusion =>
      'Difusión: visita recibida, mercado y medio';

  @override
  String get acompanamientoSeguimiento =>
      'Seguimiento: reunión y visita a la finca cada mes';

  @override
  String get acompanamientoVenta => 'Venta: búsqueda de canales o mercado';

  @override
  String acompanamientoAsistidas(int asistidas, int propuestas) {
    return '$asistidas de $propuestas';
  }

  @override
  String get acompanamientoValoraciones =>
      'Valoración de la implicación (0-10)';

  @override
  String get acompanamientoValoracionZunbeltz => 'Según Zunbeltz';

  @override
  String get acompanamientoValoracionTester => 'Según la persona tester';

  @override
  String get acompanamientoHoras => 'Horas';

  @override
  String get acompanamientoAsistencia => 'Asistencia';

  @override
  String get incidenciasVacio => 'Sin incidencias.';

  @override
  String get incidenciaNueva => 'Registrar incidencia';

  @override
  String get incidenciaNivel => 'Nivel';

  @override
  String get incidenciaRetencion => 'Retención de fianza (€)';

  @override
  String get incidenciasPrivado =>
      'Solo lo ven coordinación y la persona tester de este proyecto.';

  @override
  String get convenioTipo => 'Tipo';

  @override
  String get convenioConcepto => 'Concepto';

  @override
  String get convenioImporte => 'Importe (€)';

  @override
  String get convenioFecha => 'Fecha';

  @override
  String get convenioDescripcion => 'Descripción';

  @override
  String get convenioCumple => 'Cumple';

  @override
  String get convenioNoCumple => 'Todavía no';

  @override
  String get marcaBorrador => 'BORRADOR';

  @override
  String get informeBorradorAviso =>
      'Borrador: la versión definitiva la genera coordinación con el proyecto cerrado.';

  @override
  String get ayudaHoyAvisosT => 'Hoy y los avisos';

  @override
  String get ayudaHoyAvisosB =>
      'Hoy es la bandeja del espacio. Arriba salen las alarmas abiertas; luego tus tareas vencidas y las de los próximos 7 días; las peticiones; y los avisos, por categorías: Ganado, Instalaciones, Seguimiento individual y Noticias. Coordinación ve además las peticiones pendientes y «Lo último en el espacio»: quién ha hecho qué, desde la app o desde la oficina.\n1. Para avisar de algo, pulsa «Dar un aviso».\n2. Elige la categoría, escribe qué pasa y, si quieres, la finca.\n3. Si es grave (un animal enfermo, una rotura importante, falta de alimento), marca «Es una alarma»: al resto le saltará una notificación.\n4. Toca un aviso para verlo y, cuando esté arreglado, márcalo como resuelto.\n» En Noticias, debajo de lo que publica coordinación, salen las «Noticias del sector»: titulares de fuera (administración, sindicatos agrarios, prensa del sector) de los canales que elige coordinación en el panel. Toca una para leerla entera en el navegador. No avisan con notificación.';

  @override
  String get ayudaPeticionesT => 'Pedir una tarea';

  @override
  String get ayudaPeticionesB =>
      'Si ves que hace falta algo (comprar pienso, arreglar una cancela…), pídeselo a coordinación:\n1. Desde Hoy, o desde la ficha del punto, pulsa «Pedir una tarea».\n2. Escribe qué hace falta; marca «Es urgente» si corre prisa.\n3. Guarda. Coordinación la verá al sincronizar y la convertirá en tarea o te contestará.\n» Tus peticiones y su respuesta están en Fincas → Tareas → botón de peticiones (arriba).';

  @override
  String get ayudaConvenioT => 'El convenio: cuentas, fianza y acompañamiento';

  @override
  String get ayudaConvenioB =>
      'En tu proyecto, el botón del apretón de manos (arriba) abre el Convenio:\n• Balance: el del test (sin amortizaciones, el que se reparte) y el del proyecto (con ellas, el coste real), quién asume cada gasto y el reparto (por defecto 25 % Zunbeltz / 75 % tester si hay beneficio; 50 / 50 si hay pérdida).\n• Presupuesto: lo previsto, comparado con lo gastado.\n• Fianza: depósitos, devoluciones y retenciones.\n• Acompañamiento: formaciones, visitas, asesoramientos, reuniones… y si se cumplen los indicadores del anexo IV.\n• Incidencias: solo las ven coordinación y la persona tester del proyecto.\n» Al apuntar un gasto, indica quién lo asume y si es una amortización. Coordinación lleva el resto.';

  @override
  String get ayudaNotificacionesT => 'Notificaciones';

  @override
  String get ayudaNotificacionesB =>
      'La app te avisa en el móvil:\n• Cuando llega una alarma de otra persona.\n• A coordinación: cuando hay peticiones nuevas y un resumen de lo que ha cambiado en el espacio.\n• Cada mañana a las 9:00, si tienes tareas vencidas, hasta que las marques como hechas.\n» Acepta el permiso de notificaciones la primera vez que lo pida la app. Con la app cerrada, el móvil Android comprueba si hay novedades cada 15 minutos más o menos cuando hay conexión; con el móvil en reposo puede tardar algo más. Si tu móvil corta las apps en segundo plano para ahorrar batería, quita a Solera Zunbeltz de esa lista.';

  @override
  String get contactosTitulo => 'Contactos';

  @override
  String get contactosVacio => 'Todavía no hay contactos.';

  @override
  String get contactosTodos => 'Todos';

  @override
  String get contactoNuevo => 'Añadir contacto';

  @override
  String get contactoEditar => 'Editar contacto';

  @override
  String get contactoNombre => 'Nombre';

  @override
  String get contactoTipo => 'Tipo';

  @override
  String get contactoTelefono => 'Teléfono';

  @override
  String get contactoCorreo => 'Correo';

  @override
  String get contactoLocalidad => 'Localidad';

  @override
  String get contactoNotas => 'Notas';

  @override
  String get contactoLlamar => 'Llamar';

  @override
  String get contactoEscribir => 'Escribir';

  @override
  String get contactoBorrar => 'Borrar contacto';

  @override
  String get contactoGuardado => 'Contacto guardado.';

  @override
  String get tipoContactoMatadero => 'Matadero';

  @override
  String get tipoContactoVeterinaria => 'Veterinaria';

  @override
  String get tipoContactoExperto => 'Persona experta';

  @override
  String get tipoContactoComprador => 'Comprador / tienda';

  @override
  String get tipoContactoProveedor => 'Proveedor';

  @override
  String get tipoContactoAdministracion => 'Administración';

  @override
  String get tipoContactoOtro => 'Otro';

  @override
  String get calculadoraTitulo => 'Calculadora de transformación';

  @override
  String get calculadoraIntro =>
      'De un animal de X kg a kg de producto, precio y margen. Prueba caminos (canal, despiece, elaborado) y guárdalos para compararlos.';

  @override
  String get calculadoraReferencia => 'Rendimiento de referencia';

  @override
  String get calculadoraSinReferencias =>
      'Coordinación puede guardar rendimientos de referencia en la oficina. Mientras, pon los porcentajes a mano.';

  @override
  String get calculadoraNinguna => 'Ninguno (a mano)';

  @override
  String get calculadoraPesoVivo => 'Peso vivo por animal (kg)';

  @override
  String get calculadoraAnimales => 'Animales';

  @override
  String get calculadoraRendimientoCanal => 'Rendimiento a canal (%)';

  @override
  String get calculadoraRendimientoProducto =>
      'Producto vendible sobre canal (%)';

  @override
  String get calculadoraPrecioKg => 'Precio de venta (€/kg)';

  @override
  String get calculadoraCosteSacrificio => 'Matadero por animal (€)';

  @override
  String get calculadoraCosteTransformacion =>
      'Transformación y envasado (€/kg)';

  @override
  String get calculadoraOtrosCostes => 'Otros costes (€)';

  @override
  String get calculadoraKgCanal => 'Kg de canal';

  @override
  String get calculadoraKgProducto => 'Kg de producto';

  @override
  String get calculadoraIngreso => 'Ingreso';

  @override
  String get calculadoraCostes => 'Costes';

  @override
  String get calculadoraMargen => 'Margen';

  @override
  String get calculadoraMargenKgVivo => 'Margen por kg vivo';

  @override
  String get calculadoraGuardar => 'Guardar este camino';

  @override
  String get calculadoraNombreEscenario =>
      'Nombre (p. ej. «Despiece y venta directa»)';

  @override
  String get calculadoraEscenarios => 'Caminos guardados';

  @override
  String get calculadoraOrientativo =>
      'Cálculo orientativo: los rendimientos reales dependen del animal, del matadero y del despiece.';

  @override
  String get alimentacionExcel => 'Alimentación por días (Excel)';

  @override
  String get ayudaContactosT => 'Contactos del espacio';

  @override
  String get ayudaContactosB =>
      'La agenda compartida: mataderos, veterinaria, personas expertas, compradores…\n1. En Hoy, pulsa el icono de contactos (arriba).\n2. Filtra por tipo y toca un contacto para llamar o escribir.\n3. Para añadir uno, pulsa «Añadir contacto». Puedes corregir los que añadas tú; coordinación los gestiona todos, también desde la oficina.';

  @override
  String get ayudaCalculadoraT =>
      'Calculadora de transformación y Excel de alimentación';

  @override
  String get ayudaCalculadoraB =>
      'En tu proyecto, el botón de la calculadora (arriba):\n1. Elige un rendimiento de referencia (los pone coordinación) o escribe los porcentajes.\n2. Pon el peso vivo, el precio por kg y los costes: verás los kg de producto, el ingreso, el margen y a cuánto sale el kg vivo.\n3. «Guardar este camino» para compararlo con otros (canal, despiece, elaborado…).\n» En el botón de compartir del proyecto, «Alimentación por días (Excel)» saca los kg suministrados cada día y por lote.';

  @override
  String get ayudaActualizacionesT => 'Instalar una versión nueva';

  @override
  String get ayudaActualizacionesB =>
      'Cuando sale una versión nueva, la app te avisa al abrirla («Versión disponible»). Pulsa «Actualizar», o «Descartar por ahora» si te viene mal.\n1. También puedes mirarlo en Ajustes → Actualizaciones: ves la versión instalada, la última publicada y qué trae. «Buscar ahora» lo vuelve a comprobar.\n2. Pulsa «Descargar e instalar» y confirma en el instalador del móvil.\n3. Vuelve a abrir la app.\n» La primera vez, Android puede pedir que permitas «instalar apps desconocidas» para Solera Zunbeltz. Tus datos se conservan al actualizar.';

  @override
  String get ayudaWebT => 'Usar la app en el ordenador';

  @override
  String get ayudaWebB =>
      'La app también funciona en el navegador, útil en la oficina o con pantalla grande.\n1. Abre la dirección que te dé coordinación (la del WordPress de Zunbeltz, terminada en /app/).\n2. La dirección del servidor ya viene puesta: en Ajustes → Sincronización solo tienes que poner tu token.\n3. A partir de ahí funciona igual que en el móvil.\n» En el navegador no se pueden añadir fotos: se añaden desde el móvil. Si arriba ves la franja «Versión de prueba», es la demostración: lo que apuntes ahí se queda en ese navegador y no lo ve nadie más.';

  @override
  String get noticiasSectorTitulo => 'Noticias del sector';

  @override
  String noticiasSectorVerTodas(int n) {
    return 'Ver todas ($n)';
  }

  @override
  String get noticiasSectorVacio =>
      'Todavía no hay noticias del sector. Los canales los añade coordinación en el panel de WordPress.';

  @override
  String noticiasSectorActualizadas(String fecha) {
    return 'Actualizado: $fecha';
  }

  @override
  String get noticiasSectorDestacada => 'Destacada';

  @override
  String get noticiasSectorSinAbrir => 'No se ha podido abrir la noticia.';

  @override
  String get noticiasSectorSinServidor =>
      'Las noticias del sector llegan del servidor del espacio: configúralo en Ajustes → Sincronización.';

  @override
  String get numeroNoValido =>
      'Hay un número que no se entiende. Escríbelo, por ejemplo, así: 1200 o 1.200,50.';

  @override
  String get comProductoObligatorio => 'Indica qué producto has vendido.';

  @override
  String get puntoCoordenadasNoValidas =>
      'Revisa las coordenadas: latitud entre -90 y 90 y longitud entre -180 y 180, por ejemplo 42,795 y -1,912.';

  @override
  String get comunBorrarConfirmar =>
      '¿Borrarlo? No se puede deshacer y desaparece también de los demás móviles.';

  @override
  String get errorSyncConfiguracion =>
      'Pon la dirección del WordPress y tu token en Ajustes → Sincronización.';

  @override
  String get errorSyncSinConexion =>
      'No se ha podido contactar con el servidor. Comprueba la cobertura y la dirección.';

  @override
  String get errorSyncToken =>
      'Token incorrecto o persona desactivada. Pide uno nuevo a coordinación.';

  @override
  String get errorSyncPluginAntiguo =>
      'Ese WordPress no tiene el plugin de Solera Zunbeltz (0.3 o posterior).';

  @override
  String errorSyncServidor(int codigo) {
    return 'El servidor ha respondido con un error ($codigo). Prueba más tarde.';
  }

  @override
  String get errorSyncRespuesta =>
      'El servidor ha respondido algo inesperado. Revisa que la dirección sea la del WordPress de Zunbeltz.';

  @override
  String get informePeriodo => 'Periodo de las cifras';

  @override
  String get informeTodoElProyecto => 'todo el proyecto';

  @override
  String get informeConvenioAcumulado =>
      'Cuentas del convenio (todo el proyecto, sea cual sea el periodo):';
}
