<?php
/**
 * GENERADO desde los ARB de la app con
 * `dart run tool/generar_textos_ayuda.dart` — NO editar a mano.
 *
 * Índice de la ayuda, apartados con versión para tester y textos de
 * serie en castellano y euskera. Coordinación los cambia en
 * Larrea Zunbeltz → Ayuda (includes/ayuda.php).
 *
 * @package SoleraZunbeltzSync
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/** Grupo → claves de sus apartados (cada uno con T título y B cuerpo). */
const SZS_AYUDA_INDICE = array(
	'ayudaGrupoEmpezar' => array( 'ayudaQueEs', 'ayudaPestanas', 'ayudaIdiomaDatos', 'ayudaHoyAvisos', 'ayudaWidget', 'ayudaActualizaciones' ),
	'ayudaGrupoFincas' => array( 'ayudaFincas', 'ayudaMapaSinCobertura', 'ayudaZonas', 'ayudaEditarMapa', 'ayudaImportar', 'ayudaCierres', 'ayudaTareas', 'ayudaRecurrentes', 'ayudaTablero' ),
	'ayudaGrupoGanado' => array( 'ayudaGanadoLotes', 'ayudaGanadoMover', 'ayudaGanadoManejo' ),
	'ayudaGrupoProyectos' => array( 'ayudaProyectos', 'ayudaApuntar', 'ayudaNumeros', 'ayudaConvenio', 'ayudaCalculadora', 'ayudaInformes' ),
	'ayudaGrupoEquipo' => array( 'ayudaSync', 'ayudaWeb', 'ayudaRoles', 'ayudaPeticiones', 'ayudaContactos', 'ayudaNotificaciones' ),
	'ayudaGrupoProblemas' => array( 'ayudaProblemas' ),
);

/** Apartados que tienen además versión para tester (TesterT / TesterB). */
const SZS_AYUDA_CON_TESTER = array( 'ayudaZonas', 'ayudaEditarMapa', 'ayudaTareas', 'ayudaRecurrentes', 'ayudaTablero' );

/** Claves sueltas (intro, rótulos, avisos del manual). */
const SZS_AYUDA_CLAVES_SUELTAS = array( 'ayudaIntro', 'ayudaConsejo', 'ayudaPie', 'ayudaPerfilTester', 'ayudaManualTester', 'ajustesProvisional', 'meteoOrientativo' );

/** Textos de serie, por idioma y clave. */
const SZS_AYUDA_TEXTOS_DE_SERIE = array(
	'es' => array(
		'ayudaIntro' => 'Una guía paso a paso para usar la app. Toca un apartado para abrirlo, o escribe arriba lo que buscas. Si te pierdes, vuelve atrás con la flecha de arriba a la izquierda.',
		'ayudaConsejo' => 'Bueno saber',
		'ayudaPie' => 'Si algo no queda claro, pregunta a coordinación del Espacio Test.',
		'ayudaPerfilTester' => 'Estás viendo la ayuda para personas tester: cuenta lo que puedes hacer con tu rol.',
		'ayudaManualTester' => 'Si eres persona tester',
		'ajustesProvisional' => 'Versión preliminar. Los partes e informes que genera son orientativos y su formato está pendiente de validación. El papeleo oficial (libro de explotación, cuaderno PAC, trazabilidad…) llega en fases posteriores.',
		'meteoOrientativo' => 'Previsión orientativa (Open-Meteo). No sustituye el criterio del ganadero ni del veterinario.',
		'ayudaGrupoEmpezar' => 'Primeros pasos',
		'ayudaQueEsT' => '¿Qué es esta app?',
		'ayudaQueEsB' => 'Es la herramienta del Espacio Test Zunbeltz. Sirve para dos cosas: llevar el seguimiento de tu proyecto de test (lo que produces, lo que vendes, lo que gastas y lo que ganas) y cuidar las fincas (las infraestructuras del mapa y sus tareas de mantenimiento).
Todo se guarda en tu móvil y funciona sin cobertura en el monte. Si sincronizas, además lo compartes con el resto del equipo a través del servidor de Zunbeltz.',
		'ayudaPestanasT' => 'Moverse por la app',
		'ayudaPestanasB' => 'Abajo tienes cinco pestañas. Tócalas para cambiar de pantalla:
• Hoy: la bandeja del espacio — alarmas, tareas vencidas y próximas, peticiones y avisos.
• Fincas: el mapa con los puntos, las zonas y las tareas.
• Ganado: los rebaños y sus animales, dónde está cada uno, movimientos y curas.
• Proyectos: el proceso de test, sus números y el convenio.
• Ajustes: idioma, sincronización, actualizaciones, envío de informes e información sobre el Espacio Test.
En Hoy, los iconos de arriba abren los contactos, el tiempo y esta ayuda.
Para volver atrás, usa la flecha de arriba a la izquierda.',
		'ayudaIdiomaDatosT' => 'Idioma, fotos, tiempo e internet',
		'ayudaIdiomaDatosB' => '• Cambia entre castellano y euskera en Ajustes → Idioma.
• Las fotos se guardan en tu móvil. Con la sincronización, además, viajan al resto del equipo: suben y bajan solo con wifi, reducidas para que pesen poco.
• En Hoy o en Fincas, el icono de la nube (arriba) abre el tiempo de la finca: cómo está ahora, las próximas 24 horas, el agua (lluvia caída, lluvia prevista y lo que pierden suelo y pasto) y los próximos 7 días. Toca un día para ver más detalle.
• Avisos: helada, nieve, tormenta, lluvia, viento fuerte, calor, estrés por calor del ganado y días buenos para el manejo.
» Todo funciona sin internet menos el tiempo, la sincronización y las actualizaciones. Sin cobertura, el tiempo muestra la última previsión que se descargó y avisa de cuándo es.',
		'ayudaHoyAvisosT' => 'Hoy y los avisos',
		'ayudaHoyAvisosB' => 'Hoy es la bandeja del espacio. Arriba salen las alarmas abiertas; luego tus tareas vencidas y las de los próximos 7 días; las peticiones; y los avisos, por categorías: Ganado, Instalaciones, Seguimiento individual y Noticias. Coordinación ve además las peticiones pendientes y «Lo último en el espacio»: quién ha hecho qué, desde la app o desde la oficina.
1. Para avisar de algo, pulsa «Dar un aviso».
2. Elige la categoría, escribe qué pasa y, si quieres, la finca.
3. Si es grave (un animal enfermo, una rotura importante, falta de alimento), marca «Es una alarma»: al resto le saltará una notificación.
4. Toca un aviso para verlo y, cuando esté arreglado, márcalo como resuelto.
» En Noticias, debajo de lo que publica coordinación, salen las «Noticias del sector»: titulares de fuera (administración, sindicatos agrarios, prensa del sector) de los canales que elige coordinación en el panel. Toca una para leerla entera en el navegador. No avisan con notificación.',
		'ayudaWidgetT' => 'El widget de la pantalla de inicio (Android)',
		'ayudaWidgetB' => 'En Android puedes poner en la pantalla de inicio del móvil un resumen de Hoy sin abrir la app: las alarmas abiertas, tus tareas vencidas y las de hoy, los rebaños en plazo de supresión (y cuándo queda libre el primero) y el tiempo de hoy en la finca.
1. Mantén pulsado un hueco de la pantalla de inicio y elige «Widgets».
2. Busca «Larrea Zunbeltz» y arrastra «Hoy en Zunbeltz» a la pantalla.
3. Si quieres, mantenlo pulsado para hacerlo más grande o más pequeño: con poco sitio se quitan primero el tiempo y luego la supresión.
» Sus botones abren la app directamente para dar un aviso, mover un rebaño o apuntar una cura (eligiendo el rebaño). Solo salen los que tu perfil puede usar.
» Se pone al día al cambiar algo en la app y, con la app cerrada, cada 15 minutos más o menos (Android decide cuándo). La hora de arriba dice cuándo fue la última vez.
» En la versión web y en el ordenador no hay widget.',
		'ayudaActualizacionesT' => 'Instalar una versión nueva',
		'ayudaActualizacionesB' => 'Cuando sale una versión nueva, la app te avisa al abrirla («Versión disponible»). Pulsa «Actualizar», o «Descartar por ahora» si te viene mal.
1. También puedes mirarlo en Ajustes → Actualizaciones: ves la versión instalada, la última publicada y qué trae. «Buscar ahora» lo vuelve a comprobar.
2. Pulsa «Descargar e instalar» y confirma en el instalador del móvil.
3. Vuelve a abrir la app.
» La primera vez, Android puede pedir que permitas «instalar apps desconocidas» para Larrea Zunbeltz. Tus datos se conservan al actualizar.',
		'ayudaGrupoFincas' => 'Fincas y tareas',
		'ayudaFincasT' => 'Marcar un punto en el mapa',
		'ayudaFincasB' => 'Un punto es cada infraestructura: abrevadero, manga, cierre, refugio, balsa…
1. Entra en Fincas.
2. Toca el sitio exacto en el mapa. O pulsa «Nuevo punto» (abajo a la derecha) y elige «Usar GPS actual» si estás junto a la instalación, o «Usar centro del mapa».
3. Elige el tipo y el estado, ponle nombre y, si quieres, añade fotos.
4. Pulsa Guardar.
» El color del punto dice su estado: verde, operativo; ocre, revisar; rojizo, averiado. El botón «GPS» centra el mapa en ti y «Capas» cambia entre mapa y satélite.',
		'ayudaMapaSinCoberturaT' => 'El mapa sin cobertura',
		'ayudaMapaSinCoberturaB' => 'En el monte muchas veces no hay cobertura. Los datos (puntos, zonas, tareas) están siempre en el móvil; la foto aérea, solo si se ha guardado antes.
1. Lo que miras en el mapa se guarda solo (hasta unos 200 MB; lo más antiguo se borra).
2. Para llevar las fincas enteras, con wifi: Fincas → icono de la nube con flecha (abajo, junto a «GPS») → «Descargar el mapa de las fincas». Te dice cuánto ocupa antes de empezar.
3. Mientras baja puedes usar la app; si la cancelas o se va la wifi, al volver a descargar sigue por donde iba.
4. En Ajustes → «Mapa sin cobertura» ves cuánto ocupa y puedes borrarlo.
» Solo se descarga la ortofoto del IGN. El callejero solo se guarda según lo vas viendo.',
		'ayudaZonasT' => 'Dibujar una zona (parcela, cercado…)',
		'ayudaZonasB' => '1. En Fincas, pulsa «Dibujar zona».
2. Toca en el mapa las esquinas de la zona, una detrás de otra. Si te equivocas, pulsa «Deshacer».
3. Con tres esquinas o más, pulsa «Cerrar zona».
4. Elige la finca, el tipo (parcela de pasto, cercado, zona de pastoreo…), el nombre y el estado, y guarda.
» La superficie que sale del dibujo es orientativa. Si tienes la oficial del recinto SIGPAC, ponla en «Superficie oficial SIGPAC» y será la que se use.',
		'ayudaZonasTesterT' => 'Consultar las zonas de una finca (parcelas, cercados…)',
		'ayudaZonasTesterB' => 'En Fincas puedes consultar las parcelas, cercados, zonas de pastoreo y otros espacios que forman parte de la finca.
1. Entra en Fincas para ver el mapa con las zonas y los puntos.
2. Toca una zona del mapa para ver su información: nombre, tipo, superficie y otros datos.
3. Si falta una zona, sus límites no son correctos o hay algún dato que actualizar, comunícalo a coordinación.
» Las personas tester pueden consultar las zonas, pero no dibujar nuevas ni modificar sus límites. Esos cambios los hace coordinación.',
		'ayudaEditarMapaT' => 'Mover o borrar un punto o una zona',
		'ayudaEditarMapaB' => '1. Toca el punto o la zona en el mapa para abrir su ficha.
2. Para mover un punto: pulsa «Recolocar en el mapa» (arriba) y toca el sitio nuevo.
3. Para corregir una zona: pulsa el lápiz (arriba). «Editar datos» cambia el nombre, el tipo, el estado, la referencia SIGPAC o las notas; «Ajustar contorno» deja mover sus esquinas (toca una esquina y después el sitio nuevo; los «+» añaden una esquina); «Volver a dibujar» la rehace entera.
4. Para borrarlo: pulsa la papelera y confirma.',
		'ayudaEditarMapaTesterT' => 'Comunicar cambios o incidencias en una finca',
		'ayudaEditarMapaTesterB' => 'Si encuentras un problema en una instalación o ves que la información del mapa no es correcta, puedes comunicárselo a coordinación.
1. Entra en Fincas y localiza en el mapa el punto o la zona.
2. Tócalo para ver su información.
3. Si hay un error, hay que cambiar algún dato o quieres comunicar una incidencia, da un aviso desde Hoy o contacta con coordinación.
» Los puntos móviles (un corral, un bidón) sí los puedes añadir y mover tú: pulsa «Recolocar en el mapa» en su ficha.
» No necesitas modificar el mapa. Coordinación actualiza los puntos, las zonas y sus datos con la información que recibe.',
		'ayudaImportarT' => 'Zonas desde el catastro o desde un fichero',
		'ayudaImportarB' => 'No hace falta dibujar a mano una parcela que ya está medida.
1. En Fincas, pulsa el icono de capas (arriba) y elige de dónde sale el contorno.
• «Parcela catastral en el centro del mapa»: mueve el mapa hasta que la cruz caiga dentro de la parcela.
• «Parcela catastral por referencia»: municipio, polígono y parcela, como en el recibo de la contribución.
• «Importar fichero»: KML o KMZ de Google Earth, GeoJSON, el recorrido de un GPS (GPX) o un Shapefile de QGIS en zip.
2. Los contornos encontrados salen en el mapa con borde a trazos. Toca uno y rellena la zona como siempre: finca, tipo, nombre y estado.
» El catastro es el de Navarra (IDENA) y sale con la parcela entera y sus subparcelas. Necesita internet.
» La lupa de arriba busca parajes, pueblos, calles y referencias catastrales de toda España y lleva el mapa allí.',
		'ayudaCierresT' => 'Un abrevadero o un cierre nuevo',
		'ayudaCierresB' => 'Un abrevadero, un bebedero o una manga son un punto: se marcan como en «Marcar un punto en el mapa», con su tipo.
Un cierre (alambrada, pastor eléctrico) no se dibuja como línea. Se apunta de una de estas dos maneras:
1. Si importa un tramo o una puerta concreta (para tensarlo, revisarlo o arreglarlo), marca un punto en ese sitio con el tipo «Cierre / alambrada», «Pastor eléctrico» o «Puerta / portillo», y di en el nombre o en las notas qué tramo es.
2. Si importa el recinto que cierra, dibújalo como zona («Dibujar zona»). Si es un cierre que se pone y se quita, elige el tipo «Cercado provisional».
» Las tareas del cierre se anclan a ese punto o a esa zona.
» Si necesitáis ver el trazado del cierre en el mapa, decídnoslo: sería una función nueva.',
		'ayudaTareasT' => 'Apuntar una tarea de mantenimiento',
		'ayudaTareasB' => '1. Abre la ficha de un punto o de una zona y pulsa «Nueva tarea».
2. Escribe qué hay que hacer o pulsa «Elegir una tarea tipo»: salen las habituales de Zunbeltz (alimentación, revisión del vallado, compras…) con su periodicidad sugerida, y arriba las que encajan con ese punto. Si quieres, añade responsable, prioridad, fecha objetivo, fotos de antes y después y el coste.
3. Pulsa Guardar. Si has elegido a dos o más responsables, la app pregunta: «Una tarea compartida» (una sola; la ven todas en «Mis tareas» y, cuando una la marca hecha, queda hecha para todas) o «Una para cada persona» (una tarea igual para cada una, con su propio estado).
» Si la tarea tiene coste, coordinación puede llevarlo a las cuentas de un proyecto desde la tarea: «Apuntar como gasto de un proyecto».
» La tarea queda unida a ese punto o zona: la verás en su ficha y en el tablero de tareas.',
		'ayudaTareasTesterT' => 'Pedir una tarea de mantenimiento',
		'ayudaTareasTesterB' => 'Si ves algo que hay que arreglar, revisar o mantener en la finca, puedes pedir que se haga una tarea.
1. Entra en Fincas y localiza el punto o la zona donde hace falta.
2. En su ficha, pulsa «Pedir una tarea» y explica qué pasa y qué hace falta hacer. Si puedes, añade una foto para que se entienda mejor.
3. Coordinación revisará la petición y organizará la tarea.
» Pedir una tarea no significa que tengas que hacerla tú. Coordinación valora la petición y decide cómo organizar el trabajo.
» Cuanto más clara sea la descripción del problema y su ubicación, más fácil será organizar la actuación.',
		'ayudaRecurrentesT' => 'Tareas que se repiten',
		'ayudaRecurrentesB' => 'Lo que se hace siempre (rellenar comederos, revisar el vallado…) no hace falta apuntarlo cada vez.
1. Al crear la tarea, elige una «Periodicidad»: diaria, semanal, quincenal, mensual o trimestral.
2. Cuando la marques como hecha, la app crea sola la siguiente, con la fecha que toca.
» En la lista, las tareas periódicas llevan el símbolo de repetir.',
		'ayudaRecurrentesTesterT' => 'Tareas que se repiten',
		'ayudaRecurrentesTesterB' => 'Algunas tareas se hacen cada cierto tiempo: rellenar comederos, revisar el vallado, comprobar las instalaciones…
1. En Fincas, pulsa «Tareas» para ver las actuaciones previstas.
2. Las que se repiten llevan el símbolo de repetir.
3. Si falta alguna tarea habitual o debería hacerse con otra frecuencia, comunícalo a coordinación.
» No hace falta pedir cada vez una tarea periódica que ya esté programada. Cuando se marca como hecha, la app prepara sola la siguiente.',
		'ayudaTableroT' => 'Llevar las tareas al día',
		'ayudaTableroB' => '1. En Fincas, pulsa «Tareas» (arriba) para ver el tablero con todas.
2. Filtra por finca y por estado. Si sincronizas con el equipo, «Mis tareas» deja solo las que tienes asignadas.
3. Para darla por hecha, pulsa el círculo con la marca, a la derecha de la tarea.
4. Toca una tarea para cambiar su estado (pendiente, en curso, hecha, bloqueada), asignártela o soltarla. Coordinación puede además «Cambiar responsables»: con varias, la tarea queda compartida. Si sueltas una compartida, sales tú y las demás siguen con ella.
5. Con «Parte PDF» sacas el parte de mantenimiento de lo que tengas filtrado, para imprimirlo o enviarlo.
» «Bloqueada» es para cuando no se puede seguir por algo ajeno a quien la hace: falta material, hay que esperar a alguien o el tiempo no deja. Coordinación la ve en el panel, en «Pide atención».',
		'ayudaTableroTesterT' => 'Consultar y llevar las tareas al día',
		'ayudaTableroTesterB' => 'En la app puedes ver las tareas de mantenimiento de las fincas y saber cuáles están pendientes, en curso, hechas o bloqueadas.
1. En Fincas, pulsa «Tareas» (arriba) para ver la lista.
2. Filtra por finca o por estado para encontrar las que te interesan.
3. «Mis tareas» deja solo las que tienes asignadas, también las que compartes con otras personas: en esas, cualquiera puede cambiar el estado y, cuando una la marca hecha, queda hecha para todas.
4. Toca una tarea para ver su información y cambiar su estado cuando empieces o termines el trabajo. Para darla por hecha, pulsa el círculo con la marca, a la derecha.
5. Si falta alguna actuación, pídela desde la ficha del punto o la zona para que coordinación la organice.
» «Bloqueada» es para cuando no se puede seguir por algo ajeno a quien la hace: falta material, hay que esperar a alguien o el tiempo no deja. Coordinación la ve en el panel, en «Pide atención».
» Las personas tester no pueden asignar tareas a otras personas. Eso lo hace coordinación, que organiza el mantenimiento de las fincas.',
		'ayudaGrupoGanado' => 'Ganado y movimientos',
		'ayudaGanadoLotesT' => 'Rebaños y animales',
		'ayudaGanadoLotesB' => 'El ganado se lleva por rebaños, como se maneja en extensivo: un rebaño de ovejas, un rebaño de vacas, los cerdos de cebo…
1. Entra en la pestaña Ganado y pulsa «Nuevo rebaño».
2. Ponle nombre, especie y de quién es (del espacio o de una persona tester). Si hay animales que no se llevan uno a uno (aves, cerdos de cebo), pon cuántos en «Cabezas sin crotal».
3. Elige en qué pieza está ahora y guarda.
4. Para los animales con crotal, abre el rebaño y pulsa «Añadir animal»: crotal, nombre si lo tiene, raza, sexo, nacimiento y madre.
» En la pestaña Animales se busca cualquier animal por su crotal.
» El icono de la cámara junto al crotal (en el alta y en la búsqueda) lee el código de barras del DIB y rellena el número solo. En el ordenador con Linux o Windows no está.
» El libro de explotación (icono del libro, arriba en Ganado) saca en PDF el censo, los animales, los movimientos y los tratamientos, con las UGM de cada rebaño. Cada movimiento tiene su hoja en PDF para acompañar el traslado. No sustituyen al libro oficial ni a la guía de SITRAN.',
		'ayudaGanadoMoverT' => 'Mover el ganado de pieza',
		'ayudaGanadoMoverB' => '1. Abre el rebaño y pulsa «Mover» (o, en la pestaña Movimientos, «Mover un rebaño»).
2. Elige la pieza a la que va y la fecha. Si sale del espacio (a la sierra, a otra explotación, al matadero), elige «Salida del espacio» y escribe adónde va; cuando vuelva, «Entrada en el espacio».
3. Si el movimiento lleva guía, apunta su número.
» También desde el mapa: toca una pieza y, en «Ganado en esta pieza», pulsa «Traer un rebaño».
» En la ficha de cada pieza se ve qué rebaños hay, cuántas cabezas y cuántas por hectárea. El historial del rebaño guarda todos sus movimientos.
» Un animal suelto se cambia de rebaño desde su ficha («Cambiar de rebaño»).',
		'ayudaGanadoManejoT' => 'Curas, tratamientos, pesajes y partos',
		'ayudaGanadoManejoB' => '1. Abre el rebaño (si es para todo el rebaño) o el animal y pulsa «Cura, pesaje, parto…».
2. Elige qué se ha hecho y la fecha.
3. En una cura o tratamiento, apunta lo que pone la receta: sustancia activa, dosis, días de supresión de carne y de leche, veterinario/a y número de receta. La app no recomienda medicamentos.
4. Guarda. Mientras dure el plazo, el rebaño o el animal sale marcado «En plazo de supresión» con el día desde el que queda libre.
» Para dar de baja un animal (venta, sacrificio, muerte), usa «Dar de baja» en su ficha: no se borra, se guarda su historia.
» En un rebaño marcado como ecológico, indica la clase de medicamento: los alopáticos doblan el plazo de espera (como mínimo 48 horas) y la ficha avisa cuando se acerca o se supera el límite de tratamientos al año. PROVISIONAL hasta que lo revise CPAEN/NNPEK.',
		'ayudaGrupoProyectos' => 'Tu proyecto de test',
		'ayudaProyectosT' => 'Crear tu proyecto',
		'ayudaProyectosB' => 'Los proyectos los crea coordinación, y cada uno es de una persona tester.
1. En Proyectos, pulsa + (solo coordinación).
2. Pon el nombre, la actividad y elige la persona tester. Si quieres, también la finca y las fechas.
3. Pulsa Guardar.
» Cada persona tester ve solo su proyecto. Coordinación ve todos y, al terminar el test, lo cierra desde el menú del proyecto (⋮ → Cerrar proyecto).',
		'ayudaApuntarT' => 'Apuntar tu día a día',
		'ayudaApuntarB' => 'Dentro del proyecto hay cuatro pestañas: Producción, Comercialización, Validación y Económico.
1. Ve a la pestaña de lo que quieras apuntar.
2. Pulsa + y rellena lo que toque: lo producido; una venta (producto, canal, cantidad y precio); una prueba de producto y su resultado; o un gasto o ingreso.
3. Los gastos van en uno de los seis bloques de la hoja de seguimiento (I. Costes directos … VI. Amortización) y en una partida: elige una de las sugeridas o escribe la tuya.
4. Guarda. Los números de arriba se actualizan solos.',
		'ayudaNumerosT' => 'Entender tus números',
		'ayudaNumerosB' => 'Arriba del proyecto ves la rentabilidad: ventas, otros ingresos, gastos, balance, margen y la proyección a un año.
• Con el filtro «Periodo» (arriba) lo miras para todo, este año, este trimestre o el trimestre anterior.
• Si hay gastos, verás el desglose por bloques y partidas, como en la hoja de seguimiento, y el IVA soportado y repercutido.
» El IVA es un cálculo orientativo, no una declaración fiscal: el régimen lo decide vuestro asesor.',
		'ayudaConvenioT' => 'El convenio: cuentas, fianza y acompañamiento',
		'ayudaConvenioB' => '» Esta información es orientativa y sirve como modelo general. Cada proyecto de test tiene sus propias condiciones, que se negocian y acuerdan entre la persona tester y Zunbeltz antes de empezar: los gastos, el reparto económico, la fianza y el resto del convenio.
En tu proyecto, el botón del apretón de manos (arriba) abre el Convenio:
• Balance: el del test (sin amortizaciones, el que se reparte) y el del proyecto (con ellas, el coste real), quién asume cada gasto y el reparto (por defecto 25 % Zunbeltz / 75 % tester si hay beneficio; 50 / 50 si hay pérdida).
• Presupuesto: lo previsto, comparado con lo gastado. Cada partida se puede poner a mano o calcular como en la hoja: cantidad × precio, o ración por animal y día × cabezas × días × precio.
• Amortizaciones: los bienes del inventario que usa el proyecto (aprisco, corral móvil, abrevaderos…). La cuota se calcula sola con los meses del test.
• Fianza: depósitos, devoluciones y retenciones.
• Acompañamiento: formaciones, visitas, asesoramientos, reuniones… y si se cumplen los indicadores del anexo IV.
• Incidencias: solo las ven coordinación y la persona tester del proyecto.
» Al apuntar un gasto, indica quién lo asume. Las amortizaciones van en el bloque VI. Coordinación lleva el resto.',
		'ayudaCalculadoraT' => 'Calculadora de transformación y Excel de alimentación',
		'ayudaCalculadoraB' => 'En tu proyecto, el botón de la calculadora (arriba):
1. Elige un rendimiento de referencia (los pone coordinación) o escribe los porcentajes.
2. Pon el peso vivo, el precio por kg y los costes: verás los kg de producto, el ingreso, el margen y a cuánto sale el kg vivo.
3. «Guardar este camino» para compararlo con otros (canal, despiece, elaborado…).
» En el botón de compartir del proyecto, «Alimentación por días (Excel)» saca los kg suministrados cada día y por rebaño.',
		'ayudaInformesT' => 'Sacar informes y enviarlos',
		'ayudaInformesB' => '• En tu proyecto, el botón de compartir (arriba) saca el «Informe del proyecto (PDF)», lo exporta a CSV (se abre con Excel) o lo manda con «Enviar al coordinador». El correo al que se manda se pone en Ajustes → «Coordinador (envío de informes)».
• El informe incluye las cuentas del convenio: balance del test y del proyecto, reparto, fianza, acompañamiento e incidencias.
• Los PDF salen con la marca «BORRADOR». La versión definitiva la saca coordinación con el proyecto cerrado.
• En la lista de Proyectos, el botón del gráfico saca la «Comparativa (PDF)» entre proyectos.
• En Ajustes, «Exportar espacio (CSV)» saca las fincas y los puntos del mapa.',
		'ayudaGrupoEquipo' => 'Trabajar en equipo',
		'ayudaSyncT' => 'Compartir el espacio con el equipo',
		'ayudaSyncB' => 'Con la sincronización, todo el equipo comparte el mismo espacio: fincas, puntos, zonas, tareas, proyectos, peticiones y avisos.
1. Pide a coordinación tu clave de usuario. Es personal: cada cual tiene la suya y no se comparte.
2. En Ajustes → Sincronización, pon la dirección del WordPress de Zunbeltz y tu clave de usuario.
3. La app sincroniza sola al abrirla, al volver a ella y cada 10 minutos si hay cobertura. También puedes pulsar el botón de sincronizar en Hoy.
» Sin cobertura puedes seguir trabajando: lo que hagas sube en cuanto vuelva la conexión. Las fotos (de puntos, zonas, fincas y tareas) suben y bajan solo con wifi, para no gastar datos; mientras tanto, una foto de otra persona sale como «Sin descargar» y se puede bajar tocándola.
» Estos pasos son para las personas tester de Zunbeltz que comparten la información con coordinación. Si usas la app por tu cuenta, no necesitas configurar la sincronización ni pedir una clave de usuario.',
		'ayudaWebT' => 'Usar la app en el ordenador',
		'ayudaWebB' => 'La app también funciona en el navegador, sin instalar nada. Es útil para trabajar desde la oficina o con una pantalla más grande.
1. Abre la dirección web de la aplicación en el navegador de tu ordenador.
2. Si usas la app por tu cuenta, puedes empezar a trabajar directamente, sin configurar un servidor ni poner una clave de usuario.
3. A partir de ahí funciona igual que en el móvil.
» Si eres persona tester de Zunbeltz, coordinación te da la dirección web (la del WordPress de Zunbeltz, terminada en /app/) y tu clave de usuario para compartir la información con el equipo. La dirección del servidor ya viene puesta: en Ajustes → Sincronización solo tienes que poner tu clave.
» En el navegador también se pueden hacer y añadir fotos. Se guardan en el navegador, ya reducidas, y suben al sincronizar con cualquier conexión (no solo con wifi).
» En el iPhone: abre la dirección en Safari, toca Compartir → «Añadir a pantalla de inicio» y ábrela siempre desde ese icono. Ábrela una vez con cobertura: a partir de ahí se abre también sin ella. Lo que apuntes sin cobertura se guarda y sube en la siguiente sincronización.
» Avisos al momento: en Ajustes → Sincronización, activa «Avisos al momento en este dispositivo» y acepta el permiso del navegador. Te llegan las alarmas, las peticiones (a coordinación) y las tareas que te asignan, aunque la app esté cerrada. En el iPhone solo funciona con la app añadida a la pantalla de inicio (iOS 16.4 o posterior) y abierta desde ese icono.
» Si arriba ves la franja «Versión de prueba», es la demostración: lo que apuntes ahí se queda en ese navegador y no lo ve nadie más.',
		'ayudaRolesT' => 'Quién puede hacer qué',
		'ayudaRolesB' => 'Cada persona tiene un rol, que le da coordinación.
• Coordinación: crea, reparte y cierra tareas; gestiona fincas, zonas, puntos y todos los proyectos; acepta o descarta peticiones; ve lo que pasa en el espacio.
• Tester: ve sus tareas y las generales (las que no son de nadie), cambia su estado, coge una general o suelta una suya. Pide tareas en vez de crearlas. Añade y mueve puntos (un corral móvil, un bidón), da avisos y apunta el día a día de su proyecto mientras esté abierto.
» En Ajustes ves con qué nombre y rol estás conectada. Sin sincronización estás en «Modo local» y puedes editarlo todo.',
		'ayudaPeticionesT' => 'Pedir una tarea',
		'ayudaPeticionesB' => 'Si ves que hace falta algo (comprar pienso, arreglar una cancela…), pídeselo a coordinación:
1. Desde Hoy, o desde la ficha del punto, pulsa «Pedir una tarea».
2. Escribe qué hace falta; marca «Es urgente» si corre prisa.
3. Guarda. Coordinación la verá al sincronizar y la convertirá en tarea o te contestará.
» Tus peticiones y su respuesta están en Fincas → Tareas → botón de peticiones (arriba).',
		'ayudaContactosT' => 'Contactos del espacio',
		'ayudaContactosB' => 'La agenda compartida: mataderos, veterinaria, personas expertas, compradores…
1. En Hoy, pulsa el icono de contactos (arriba).
2. Filtra por tipo y toca un contacto para llamar o escribir.
3. Para añadir uno, pulsa «Añadir contacto». Puedes corregir los que añadas tú; coordinación los gestiona todos, también desde la oficina.',
		'ayudaNotificacionesT' => 'Notificaciones',
		'ayudaNotificacionesB' => 'La app te avisa en el móvil:
• Cuando llega una alarma de otra persona.
• A coordinación: cuando hay peticiones nuevas y un resumen de lo que ha cambiado en el espacio.
• Cada mañana a las 9:00, si tienes tareas vencidas, hasta que las marques como hechas.
» Acepta el permiso de notificaciones la primera vez que lo pida la app. Con la app cerrada, el móvil Android comprueba si hay novedades cada 15 minutos más o menos cuando hay conexión; con el móvil en reposo puede tardar algo más. Si tu móvil corta las apps en segundo plano para ahorrar batería, quita a Larrea Zunbeltz de esa lista.',
		'ayudaGrupoProblemas' => 'Si algo falla',
		'ayudaProblemasT' => 'Problemas frecuentes',
		'ayudaProblemasB' => '• «Tu rol no permite…»: eso no te toca. Una tarea, cógela si está sin asignar o pide a coordinación que te la asigne.
• «… cambios revertidos: tu rol no los permite» al sincronizar: tocaste algo que tu rol no permite y se ha dejado como estaba.
• «Clave de usuario incorrecta»: revisa que lo copiaste entero. Si la has perdido, coordinación te genera una nueva y la vieja deja de valer.
• Falta algo o ves cosas que ya no son tuyas: en Ajustes, «Sincronizar todo desde cero».
• No sale la previsión del tiempo: necesita internet. Lo demás funciona sin cobertura.
• La actualización se descarga pero no se instala: en los ajustes del móvil, permite «instalar apps desconocidas» para Larrea Zunbeltz.
» Con sincronización, tus datos están también en el servidor de Zunbeltz: si cambias de móvil, configura el nuevo con tu clave de usuario y lo recuperas.',
	),
	'eu' => array(
		'ayudaIntro' => 'App-a erabiltzeko gida, urratsez urrats. Ukitu atal bat irekitzeko, edo idatzi goian bilatzen duzuna. Galtzen bazara, itzuli atzera goian ezkerrean dagoen geziarekin.',
		'ayudaConsejo' => 'Jakitea komeni da',
		'ayudaPie' => 'Zerbait argi ez badago, galdetu Saiakuntza Guneko koordinazioari.',
		'ayudaPerfilTester' => 'Pertsona testerrentzako laguntza ikusten ari zara: zure rolarekin egin dezakezuna azaltzen du.',
		'ayudaManualTester' => 'Pertsona testerra bazara',
		'ajustesProvisional' => 'Aurretiazko bertsioa. Sortzen dituen parte eta txostenak orientagarriak dira eta haien formatua baliozkotzeke dago. Paper-lan ofiziala (ustiategi-liburua, PAC koadernoa, trazabilitatea…) geroagoko faseetan iritsiko da.',
		'meteoOrientativo' => 'Iragarpen orientagarria (Open-Meteo). Ez du ordezkatzen abeltzainaren ezta albaitariaren irizpidea.',
		'ayudaGrupoEmpezar' => 'Lehen urratsak',
		'ayudaQueEsT' => 'Zer da app hau?',
		'ayudaQueEsB' => 'Zunbeltz Saiakuntza Gunearen tresna da. Bi gauzatarako balio du: zure test-proiektuaren jarraipena egiteko (zer ekoizten duzun, zer saltzen duzun, zer gastatzen duzun eta zer irabazten duzun) eta finkak zaintzeko (mapako azpiegiturak eta haien mantentze-zereginak).
Dena zure mugikorrean gordetzen da, eta mendian estaldurarik gabe ere badabil. Sinkronizatzen baduzu, gainera taldeko gainerakoekin partekatzen duzu Zunbeltzen zerbitzariaren bidez.',
		'ayudaPestanasT' => 'App-an mugitu',
		'ayudaPestanasB' => 'Behean bost fitxa dituzu. Ukitu pantailaz aldatzeko:
• Gaur: gunearen sarrera-ontzia — alarmak, zeregin iraungiak eta hurrengoak, eskaerak eta abisuak.
• Finkak: mapa, puntuekin, eremuekin eta zereginekin.
• Abereak: taldeak, bakoitza non dagoen, haien animaliak, mugimenduak eta sendaketak.
• Proiektuak: test-prozesua, haren zenbakiak eta hitzarmena.
• Ezarpenak: hizkuntza, sinkronizazioa, eguneraketak, txostenen bidalketa eta Saiakuntza Guneari buruzko informazioa.
Gaur pantailan, goiko ikonoek kontaktuak, eguraldia eta laguntza hau irekitzen dituzte.
Atzera itzultzeko, erabili goiko ezkerreko gezia.',
		'ayudaIdiomaDatosT' => 'Hizkuntza, argazkiak, eguraldia eta internet',
		'ayudaIdiomaDatosB' => '• Aldatu gaztelania eta euskara artean Ezarpenak → Hizkuntza atalean.
• Argazkiak zure mugikorrean gordetzen dira. Sinkronizazioarekin, gainera, taldeko besteengana iristen dira: wifiarekin bakarrik igotzen eta jaisten dira, txikituta, gutxi pisa dezaten.
• Gaur edo Finkak pantailan, hodeiaren ikonoak (goian) finkako eguraldia irekitzen du: orain nola dagoen, hurrengo 24 orduak, ura (egindako euria, aurreikusitako euria eta lurrak eta larreak galtzen dutena) eta hurrengo 7 egunak. Ukitu egun bat xehetasun gehiago ikusteko.
• Abisuak: izotza, elurra, ekaitza, euria, haize bortitza, beroa, abereen bero-estresa eta maneiurako egun onak.
» Dena internetik gabe dabil, eguraldia, sinkronizazioa eta eguneraketak izan ezik. Estaldurarik gabe, eguraldiak deskargatutako azken iragarpena erakusten du, eta noizkoa den adierazten du.',
		'ayudaHoyAvisosT' => 'Gaur eta abisuak',
		'ayudaHoyAvisosB' => 'Gaur gunearen sarrera-ontzia da. Goian alarma irekiak agertzen dira; gero zure zeregin iraungiak eta hurrengo 7 egunetakoak; eskaerak; eta abisuak, kategorien arabera: Abereak, Instalazioak, Banakako jarraipena eta Berriak. Koordinazioak, gainera, eskaera zain daudenak eta «Gunean azkena» ikusten ditu: nork zer egin duen, aplikaziotik edo bulegotik.
1. Zerbaiten berri emateko, sakatu «Abisua eman».
2. Aukeratu kategoria, idatzi zer gertatzen den eta, nahi baduzu, finka.
3. Larria bada (animalia gaixo bat, matxura handi bat, janari falta), markatu «Alarma da»: besteei jakinarazpen bat agertuko zaie.
4. Ukitu abisu bat ikusteko eta, konponduta dagoenean, markatu konpondutzat.
» Berriak atalean, koordinazioak argitaratzen duenaren azpian, «Sektoreko berriak» agertzen dira: kanpoko albisteak (administrazioa, nekazari-sindikatuak, sektoreko prentsa), koordinazioak panelean aukeratutako kanaletakoak. Ukitu bat osorik nabigatzailean irakurtzeko. Ez dute jakinarazpenik bidaltzen.',
		'ayudaWidgetT' => 'Hasierako pantailako widgeta (Android)',
		'ayudaWidgetB' => 'Android-en, mugikorraren hasierako pantailan Gaur-en laburpen bat jar dezakezu aplikazioa ireki gabe: alarma irekiak, zure zeregin iraungiak eta gaurkoak, kentze-epean dauden taldeak (eta lehena noiz geratzen den libre) eta finkako gaurko eguraldia.
1. Eutsi sakatuta hasierako pantailako hutsune bat eta aukeratu «Widgetak».
2. Bilatu «Larrea Zunbeltz» eta arrastatu «Gaur Zunbeltzen» pantailara.
3. Nahi baduzu, eutsi sakatuta handiago edo txikiago egiteko: leku gutxirekin, lehenik eguraldia kentzen da eta gero kentze-epea.
» Bere botoiek aplikazioa zuzenean irekitzen dute abisu bat emateko, talde bat mugitzeko edo sendaketa bat idazteko (taldea aukeratuta). Zure profilak erabil ditzakeenak bakarrik agertzen dira.
» Aplikazioan zerbait aldatzean eguneratzen da eta, aplikazioa itxita dagoela, 15 minutuz behin gutxi gorabehera (Android-ek erabakitzen du noiz). Goiko orduak azken aldia noiz izan zen dio.
» Web bertsioan eta ordenagailuan ez dago widgetik.',
		'ayudaActualizacionesT' => 'Bertsio berri bat instalatu',
		'ayudaActualizacionesB' => 'Bertsio berri bat ateratzen denean, aplikazioak abisatzen dizu irekitzean («Bertsio eskuragarria»). Sakatu «Eguneratu», edo «Baztertu oraingoz» une txarra bada.
1. Ezarpenak → Eguneraketak atalean ere begira dezakezu: instalatutako bertsioa, argitaratutako azkena eta zer dakarren ikusten dituzu. «Bilatu orain» sakatuta berriro egiaztatzen da.
2. Sakatu «Deskargatu eta instalatu» eta baieztatu mugikorraren instalatzailean.
3. Ireki berriro aplikazioa.
» Lehen aldian, Androidek «aplikazio ezezagunak instalatzea» baimentzeko eska dezake Larrea Zunbeltzentzat. Zure datuak gorde egiten dira eguneratzean.',
		'ayudaGrupoFincas' => 'Finkak eta zereginak',
		'ayudaFincasT' => 'Puntu bat markatu mapan',
		'ayudaFincasB' => 'Puntua azpiegitura bakoitza da: aska, manga, hesia, aterpea, urmaela…
1. Sartu Finketan.
2. Ukitu mapan leku zehatza. Edo sakatu «Puntu berria» (behean eskuinean) eta aukeratu «Erabili uneko GPSa» instalazioaren ondoan bazaude, edo «Erabili maparen erdigunea».
3. Aukeratu mota eta egoera, jarri izena eta, nahi baduzu, gehitu argazkiak.
4. Sakatu Gorde.
» Puntuaren koloreak egoera adierazten du: berdea, operatiboa; okrea, berrikusteke; gorrixka, matxuratuta. «GPS» botoiak mapa zugan zentratzen du, eta «Geruzak» botoiak mapa eta satelitea txandakatzen ditu.',
		'ayudaMapaSinCoberturaT' => 'Mapa estaldurarik gabe',
		'ayudaMapaSinCoberturaB' => 'Mendian askotan ez dago estaldurarik. Datuak (puntuak, eremuak, zereginak) beti daude mugikorrean; aireko argazkia, aurretik gorde bada bakarrik.
1. Mapan begiratzen duzuna berez gordetzen da (200 MB inguru arte; zaharrena ezabatzen da).
2. Finka osoak eramateko, wifiarekin: Finkak → gezidun hodeiaren ikonoa (behean, «GPS»aren ondoan) → «Finketako mapa deskargatu». Hasi aurretik zenbat hartzen duen esaten dizu.
3. Jaisten ari den bitartean aplikazioa erabil dezakezu; bertan behera uzten baduzu edo wifia joaten bada, berriz deskargatzean utzitako lekutik jarraituko du.
4. Ezarpenak → «Mapa estaldurarik gabe» atalean zenbat hartzen duen ikusi eta ezaba dezakezu.
» IGNren ortoargazkia bakarrik deskargatzen da. Kale-mapa ikusi ahala bakarrik gordetzen da.',
		'ayudaZonasT' => 'Eremu bat marraztu (saila, hesitua…)',
		'ayudaZonasB' => '1. Finketan, sakatu «Eremua marraztu».
2. Ukitu mapan eremuaren izkinak, bata bestearen atzetik. Oker bazabiltza, sakatu «Desegin».
3. Hiru izkina edo gehiago dituzunean, sakatu «Eremua itxi».
4. Aukeratu finka, mota (larre-saila, hesitua, alha-eremua…), izena eta egoera, eta gorde.
» Marrazkitik ateratzen den azalera gutxi gorabeherakoa da. SIGPAC barrutiaren azalera ofiziala baduzu, jarri «SIGPAC azalera ofiziala» eremuan eta hori erabiliko da.',
		'ayudaZonasTesterT' => 'Finka baten eremuak kontsultatu (sailak, hesituak…)',
		'ayudaZonasTesterB' => 'Finketan finkaren sailak, hesituak, alha-eremuak eta gainerako guneak kontsulta ditzakezu.
1. Sartu Finketan, eremuak eta puntuak dituen mapa ikusteko.
2. Ukitu mapan eremu bat haren informazioa ikusteko: izena, mota, azalera eta beste datu batzuk.
3. Eremu bat falta bada, mugak zuzenak ez badira edo daturen bat eguneratu behar bada, jakinarazi koordinazioari.
» Pertsona testerrek eremuak kontsulta ditzakete, baina ezin dute berririk marraztu, ezta mugak aldatu ere. Aldaketa horiek koordinazioak egiten ditu.',
		'ayudaEditarMapaT' => 'Puntu edo eremu bat mugitu edo ezabatu',
		'ayudaEditarMapaB' => '1. Ukitu mapan puntua edo eremua haren fitxa irekitzeko.
2. Puntu bat mugitzeko: sakatu «Kokatu berriro mapan» (goian) eta ukitu leku berria.
3. Eremu bat zuzentzeko: sakatu arkatza (goian). «Datuak editatu» aukerarekin izena, mota, egoera, SIGPAC erreferentzia edo oharrak aldatzen dira; «Ingurua doitu» aukerarekin izkinak mugitzen dira (ukitu izkina bat eta gero leku berria; «+» ikurrek izkina bat gehitzen dute); «Berriro marraztu» aukerak osorik egiten du berriro.
4. Ezabatzeko: sakatu zakarrontzia eta berretsi.',
		'ayudaEditarMapaTesterT' => 'Finka bateko aldaketak edo gorabeherak jakinarazi',
		'ayudaEditarMapaTesterB' => 'Instalazio batean arazoren bat aurkitzen baduzu edo maparen informazioa zuzena ez dela ikusten baduzu, koordinazioari jakinaraz diezaiokezu.
1. Sartu Finketan eta aurkitu mapan puntua edo eremua.
2. Ukitu haren informazioa ikusteko.
3. Akatsen bat badago, daturen bat aldatu behar bada edo gorabehera bat jakinarazi nahi baduzu, eman abisu bat Gaur pantailatik edo jarri harremanetan koordinazioarekin.
» Puntu mugikorrak (korta bat, bidoi bat) zuk zeuk gehitu eta mugi ditzakezu: sakatu «Kokatu berriro mapan» haren fitxan.
» Ez duzu mapa aldatu behar. Koordinazioak eguneratzen ditu puntuak, eremuak eta haien datuak, jasotzen duen informazioarekin.',
		'ayudaImportarT' => 'Eremuak katastrotik edo fitxategi batetik',
		'ayudaImportarB' => 'Ez da eskuz marraztu behar neurtuta dagoen partzela bat.
1. Finketan, sakatu geruzen ikonoa (goian) eta aukeratu ingurua nondik ateratzen den.
• «Maparen erdiko katastro-partzela»: mugitu mapa gurutzea partzelaren barruan erori arte.
• «Katastro-partzela erreferentziaz»: udalerria, poligonoa eta partzela, kontribuzioaren ordainagirian bezala.
• «Fitxategia inportatu»: Google Earth-eko KML edo KMZ, GeoJSON, GPS baten ibilbidea (GPX) edo QGISeko Shapefile bat zip-ean.
2. Aurkitutako inguruak mapan ateratzen dira ertz marratuarekin. Ukitu bat eta bete eremua beti bezala: finka, mota, izena eta egoera.
» Katastroa Nafarroakoa da (IDENA) eta partzela osoarekin eta bere azpipartzelekin ateratzen da. Internet behar du.
» Goiko luparekin Espainia osoko parajeak, herriak, kaleak eta katastro-erreferentziak bilatzen dira eta mapa hara eramaten da.',
		'ayudaCierresT' => 'Aska edo hesi berri bat',
		'ayudaCierresB' => 'Aska, edaska edo manga bat puntu bat da: «Puntu bat markatu mapan» atalean bezala markatzen da, bere motarekin.
Hesi bat (alanbrea, artzain elektrikoa) ezin da lerro gisa marraztu. Bi modu hauetako batean jasotzen da:
1. Zati edo ate jakin bat axola bada (tenkatzeko, berrikusteko edo konpontzeko), markatu puntu bat leku horretan «Hesia», «Artzain elektrikoa» edo «Atea / langa» motarekin, eta adierazi izenean edo oharretan zein zati den.
2. Hesiak ixten duen barrutia axola bada, marraztu eremu gisa («Eremua marraztu»). Jarri eta kentzen den hesia bada, aukeratu «Behin-behineko hesitua» mota.
» Hesiaren zereginak puntu edo eremu horri lotzen zaizkio.
» Hesiaren trazadura mapan ikusi behar baduzue, esan iezaguzue: funtzio berria litzateke.',
		'ayudaTareasT' => 'Mantentze-zeregin bat apuntatu',
		'ayudaTareasB' => '1. Ireki puntu edo eremu baten fitxa eta sakatu «Zeregin berria».
2. Idatzi zer egin behar den edo sakatu «Ohiko zeregin bat aukeratu»: Zunbeltzeko ohikoak agertzen dira (elikadura, hesiaren berrikuspena, erosketak…) iradokitako maiztasunarekin, eta goian puntu horri dagozkionak. Nahi baduzu, gehitu arduraduna, lehentasuna, helburu-data, aurreko eta ondorengo argazkiak eta kostua.
3. Sakatu Gorde. Bi arduradun edo gehiago aukeratu badituzu, app-ak galdetzen du: «Zeregin partekatu bat» (bakarra; denek ikusten dute «Nire zereginak» atalean eta, batek eginda markatzen duenean, denentzat geratzen da eginda) edo «Pertsona bakoitzeko bat» (zeregin berdin bat bakoitzarentzat, bere egoerarekin).
» Zereginak kostua badu, koordinazioak proiektu baten kontuetara eraman dezake zereginetik bertatik: «Proiektu baten gastu gisa apuntatu».
» Zeregina puntu edo eremu horri lotuta geratzen da: haren fitxan eta zereginen taulan ikusiko duzu.',
		'ayudaTareasTesterT' => 'Mantentze-zeregin bat eskatu',
		'ayudaTareasTesterB' => 'Finkan zerbait konpondu, berrikusi edo mantendu behar dela ikusten baduzu, zeregin bat egiteko eska dezakezu.
1. Sartu Finketan eta aurkitu beharra dagoen puntua edo eremua.
2. Haren fitxan, sakatu «Zeregin bat eskatu» eta azaldu zer gertatzen den eta zer egin behar den. Ahal baduzu, gehitu argazki bat hobeto ulertzeko.
3. Koordinazioak eskaera berrikusi eta zeregina antolatuko du.
» Zeregin bat eskatzeak ez du esan nahi zuk egin behar duzunik. Koordinazioak eskaera baloratu eta lana nola antolatu erabakitzen du.
» Arazoaren eta kokapenaren deskribapena zenbat eta argiagoa izan, orduan eta errazagoa izango da jarduera antolatzea.',
		'ayudaRecurrentesT' => 'Errepikatzen diren zereginak',
		'ayudaRecurrentesB' => 'Beti egiten dena (askak betetzea, hesia berrikustea…) ez da aldi bakoitzean apuntatu behar.
1. Zeregina sortzean, aukeratu «Periodikotasuna»: egunero, astero, 15 egunero, hilero edo hiruhilero.
2. Eginda gisa markatzen duzunean, app-ak berak sortzen du hurrengoa, dagokion datarekin.
» Zerrendan, zeregin periodikoek errepikatzeko ikurra dute.',
		'ayudaRecurrentesTesterT' => 'Errepikatzen diren zereginak',
		'ayudaRecurrentesTesterB' => 'Zeregin batzuk aldiro egiten dira: askak bete, hesia berrikusi, instalazioak egiaztatu…
1. Finketan, sakatu «Zereginak» aurreikusitako jarduerak ikusteko.
2. Errepikatzen direnek errepikatzeko ikurra dute.
3. Ohiko zereginen bat falta bada edo beste maiztasun batekin egin beharko balitz, jakinarazi koordinazioari.
» Ez dago jada programatuta dagoen zeregin periodiko bat aldi bakoitzean eskatu beharrik. Eginda gisa markatzean, app-ak berak prestatzen du hurrengoa.',
		'ayudaTableroT' => 'Zereginak egunean eraman',
		'ayudaTableroB' => '1. Finketan, sakatu «Zereginak» (goian) guztiak dituen taula ikusteko.
2. Iragazi finkaren eta egoeraren arabera. Taldearekin sinkronizatzen baduzu, «Nire zereginak» aukerak zuri esleitutakoak bakarrik uzten ditu.
3. Eginda emateko, sakatu zereginaren eskuinean dagoen marka duen zirkulua.
4. Ukitu zeregin bat haren egoera aldatzeko (egiteke, egiten, eginda, blokeatuta), zuri esleitzeko edo askatzeko. Koordinazioak, gainera, «Arduradunak aldatu» dezake: hainbatekin, zeregina partekatua geratzen da. Partekatu bat askatzen baduzu, zu ateratzen zara eta besteek jarraitzen dute.
5. «PDF txostena» botoiarekin iragazita duzunaren mantentze-partea ateratzen duzu, inprimatzeko edo bidaltzeko.
» «Blokeatuta»: egiten duenaren esku ez dagoen zerbaitengatik ezin denean jarraitu: materiala falta da, norbaiti itxaron behar zaio edo eguraldiak ez du uzten. Koordinazioak panelean ikusten du, «Arreta behar du» atalean.',
		'ayudaTableroTesterT' => 'Zereginak kontsultatu eta egunean eraman',
		'ayudaTableroTesterB' => 'App-an finken mantentze-zereginak ikus ditzakezu eta jakin zein dauden egiteke, egiten, eginda edo blokeatuta.
1. Finketan, sakatu «Zereginak» (goian) zerrenda ikusteko.
2. Iragazi finkaren edo egoeraren arabera, interesatzen zaizkizunak aurkitzeko.
3. «Nire zereginak» aukerak zuri esleitutakoak bakarrik uzten ditu, baita beste pertsona batzuekin partekatzen dituzunak ere: horietan, edozeinek alda dezake egoera eta, batek eginda markatzen duenean, denentzat geratzen da eginda.
4. Ukitu zeregin bat haren informazioa ikusteko eta egoera aldatzeko lana hasten edo amaitzen duzunean. Eginda emateko, sakatu eskuineko marka duen zirkulua.
5. Jarduera bat falta bada, eskatu puntuaren edo eremuaren fitxatik, koordinazioak antola dezan.
» «Blokeatuta»: egiten duenaren esku ez dagoen zerbaitengatik ezin denean jarraitu: materiala falta da, norbaiti itxaron behar zaio edo eguraldiak ez du uzten. Koordinazioak panelean ikusten du, «Arreta behar du» atalean.
» Pertsona testerrek ezin diete zereginak beste pertsona batzuei esleitu. Hori koordinazioak egiten du, finken mantentzea antolatzen baitu.',
		'ayudaGrupoGanado' => 'Abereak eta mugimenduak',
		'ayudaGanadoLotesT' => 'Taldeak eta animaliak',
		'ayudaGanadoLotesB' => 'Abereak taldeka eramaten dira, estentsiboan maneiatzen diren bezala: artalde bat, behi-talde bat, gizentzeko txerriak…
1. Sartu Abereak fitxan eta sakatu «Talde berria».
2. Jarri izena, espeziea eta norena den (espaziokoa edo tester batena). Banan-banan eramaten ez diren animaliak badaude (hegaztiak, gizentzeko txerriak), jarri zenbat diren «Krotalik gabeko buruak» atalean.
3. Aukeratu orain zein sailetan dagoen eta gorde.
4. Krotaldun animalientzat, ireki taldea eta sakatu «Animalia gehitu»: krotala, izena baldin badu, arraza, sexua, jaiotza eta ama.
» Animaliak fitxan edozein animalia bilatzen da bere krotalaren bidez.
» Krotalaren ondoko kamera-ikonoak (alta ematean eta bilaketan) DIBaren barra-kodea irakurri eta zenbakia berez betetzen du. Linux edo Windows duen ordenagailuan ez dago.
» Ustiategi-liburuak (liburuaren ikonoa, goian Abereak atalean) errolda, animaliak, mugimenduak eta tratamenduak ateratzen ditu PDFn, artalde bakoitzaren ALUekin. Mugimendu bakoitzak bere PDF orria du lekualdaketarekin batera eramateko. Ez dute ordezkatzen liburu ofiziala ezta SITRANeko gida ere.',
		'ayudaGanadoMoverT' => 'Abereak sailez mugitu',
		'ayudaGanadoMoverB' => '1. Ireki taldea eta sakatu «Mugitu» (edo, Mugimenduak fitxan, «Talde bat mugitu»).
2. Aukeratu zein sailetara doan eta data. Espaziotik ateratzen bada (mendira, beste ustiategi batera, hiltegira), aukeratu «Espaziotik irteera» eta idatzi nora doan; itzultzen denean, «Espaziora sarrera».
3. Mugimenduak gida badu, idatzi bere zenbakia.
» Mapatik ere bai: ukitu sail bat eta, «Sail honetako abereak» atalean, sakatu «Talde bat ekarri».
» Sail bakoitzaren fitxan ikusten da zein talde dauden, zenbat buru eta zenbat hektareako. Taldearen historiak bere mugimendu guztiak gordetzen ditu.
» Animalia solte bat bere fitxatik aldatzen da taldez («Taldez aldatu»).',
		'ayudaGanadoManejoT' => 'Sendaketak, tratamenduak, pisaketak eta erditzeak',
		'ayudaGanadoManejoB' => '1. Ireki taldea (talde osoarentzat bada) edo animalia eta sakatu «Sendaketa, pisaketa, erditzea…».
2. Aukeratu zer egin den eta data.
3. Sendaketa edo tratamendu batean, idatzi errezetan dagoena: substantzia aktiboa, dosia, haragiaren eta esnearen kentze-egunak, albaitaria eta errezeta-zenbakia. Aplikazioak ez du sendagairik gomendatzen.
4. Gorde. Epeak irauten duen bitartean, taldea edo animalia «Kentze-epean» markatuta agertzen da, libre geratzen den egunarekin.
» Animalia bati baja emateko (salmenta, hilketa, heriotza), erabili «Baja eman» bere fitxan: ez da ezabatzen, bere historia gordetzen da.
» Ekologiko gisa markatutako artalde batean, adierazi sendagai mota: alopatikoek itxaronaldia bikoizten dute (gutxienez 48 ordu) eta fitxak abisatzen du urteko tratamendu-mugara hurbiltzen denean edo gainditzen denean. BEHIN-BEHINEKOA CPAEN/NNPEKek berrikusi arte.',
		'ayudaGrupoProyectos' => 'Zure test-proiektua',
		'ayudaProyectosT' => 'Zure proiektua sortu',
		'ayudaProyectosB' => 'Proiektuak koordinazioak sortzen ditu, eta bakoitza pertsona tester batena da.
1. Proiektuetan, sakatu + (koordinazioak bakarrik).
2. Jarri izena, jarduera eta aukeratu pertsona testerra. Nahi baduzu, finka eta datak ere bai.
3. Sakatu Gorde.
» Pertsona tester bakoitzak bere proiektua bakarrik ikusten du. Koordinazioak denak ikusten ditu eta, testa amaitzean, proiektuaren menutik ixten du (⋮ → Proiektua itxi).',
		'ayudaApuntarT' => 'Zure egunerokoa apuntatu',
		'ayudaApuntarB' => 'Proiektuaren barruan lau fitxa daude: Ekoizpena, Merkaturatzea, Balidazioa eta Ekonomikoa.
1. Joan apuntatu nahi duzunaren fitxara.
2. Sakatu + eta bete dagokiona: ekoitzitakoa; salmenta bat (produktua, kanala, kantitatea eta prezioa); produktu-proba bat eta haren emaitza; edo gastu edo sarrera bat.
3. Gastuak jarraipen-orriko sei multzoetako batean doaz (I. Kostu zuzenak … VI. Amortizazioa) eta partida batean: aukeratu iradokitakoetako bat edo idatzi zurea.
4. Gorde. Goiko zenbakiak berez eguneratzen dira.',
		'ayudaNumerosT' => 'Zure zenbakiak ulertu',
		'ayudaNumerosB' => 'Proiektuaren goialdean errentagarritasuna ikusten duzu: salmentak, beste sarrera batzuk, gastuak, balantzea, marjina eta urtebeterako proiekzioa.
• «Aldia» iragazkiarekin (goian) denbora osorako, aurtengo, hiruhileko honetarako edo aurreko hiruhilekorako ikus dezakezu.
• Gastuak badaude, multzoen eta partiden araberako banaketa ikusiko duzu, jarraipen-orrian bezala, eta BEZ jasana eta jasanarazia.
» BEZa gutxi gorabeherako kalkulua da, ez zerga-aitorpena: araubidea zuen aholkulariak erabakitzen du.',
		'ayudaConvenioT' => 'Hitzarmena: kontuak, fidantza eta laguntza',
		'ayudaConvenioB' => '» Informazio hau orientagarria da eta eredu orokor gisa balio du. Test-proiektu bakoitzak bere baldintzak ditu, pertsona testerrak eta Zunbeltzek hasi aurretik negoziatu eta adosten dituztenak: gastuak, banaketa ekonomikoa, fidantza eta hitzarmenaren gainerakoa.
Zure proiektuan, esku-emate botoiak (goian) Hitzarmena irekitzen du:
• Balantzea: testarena (amortizaziorik gabe, banatzen dena) eta proiektuarena (haiekin, benetako kostua), gastu bakoitza nork hartzen duen eta banaketa (lehenetsita % 25 Zunbeltz / % 75 testerra irabazia badago; 50 / 50 galera badago).
• Aurrekontua: aurreikusia, gastatutakoarekin alderatuta. Partida bakoitza eskuz jar daiteke edo orrian bezala kalkulatu: kantitatea × prezioa, edo abereko eta eguneko errazioa × buruak × egunak × prezioa.
• Amortizazioak: proiektuak erabiltzen dituen inbentarioko ondasunak (artegia, korta mugikorra, askak…). Kuota berez kalkulatzen da testaren hilabeteekin.
• Fidantza: gordailuak, itzulketak eta atxikipenak.
• Laguntza: prestakuntzak, bisitak, aholkularitzak, bilerak… eta IV. eranskineko adierazleak betetzen diren.
• Gorabeherak: koordinazioak eta proiektuko pertsona testerrak bakarrik ikusten dituzte.
» Gastu bat idaztean, adierazi nork hartzen duen. Amortizazioak VI. multzoan doaz. Gainerakoa koordinazioak eramaten du.',
		'ayudaCalculadoraT' => 'Eraldaketa-kalkulagailua eta elikaduraren Excela',
		'ayudaCalculadoraB' => 'Zure proiektuan, kalkulagailuaren botoia (goian):
1. Aukeratu erreferentziazko errendimendu bat (koordinazioak jartzen ditu) edo idatzi ehunekoak.
2. Jarri pisu bizia, kg bakoitzeko prezioa eta kostuak: produktu-kg, sarrera, marjina eta kg biziaren prezioa ikusiko dituzu.
3. «Bide hau gorde» beste batzuekin alderatzeko (kanala, zatiketa, elaboratua…).
» Proiektuaren partekatzeko botoian, «Elikadura egunka (Excel)» aukerak egunero eta loteka emandako kg-ak ateratzen ditu.',
		'ayudaInformesT' => 'Txostenak atera eta bidali',
		'ayudaInformesB' => '• Zure proiektuan, partekatzeko botoiak (goian) «Proiektuaren txostena (PDF)» ateratzen du, CSVra esportatzen du (Excelekin irekitzen da) edo «Koordinatzaileari bidali» bidez bidaltzen du. Zein helbidetara bidali Ezarpenak → «Koordinatzailea (txostenak bidaltzea)» atalean jartzen da.
• Txostenak hitzarmenaren kontuak ditu: testaren eta proiektuaren balantzea, banaketa, fidantza, laguntza eta gorabeherak.
• PDFak «ZIRRIBORROA» markarekin ateratzen dira. Behin betiko bertsioa koordinazioak ateratzen du proiektua itxita dagoenean.
• Proiektuen zerrendan, grafikoaren botoiak proiektuen arteko «Konparaketa (PDF)» ateratzen du.
• Ezarpenetan, «Gunea esportatu (CSV)» aukerak maparen finkak eta puntuak ateratzen ditu.',
		'ayudaGrupoEquipo' => 'Taldean lan egin',
		'ayudaSyncT' => 'Gunea taldearekin partekatu',
		'ayudaSyncB' => 'Sinkronizazioarekin, talde osoak gune bera partekatzen du: finkak, puntuak, eremuak, zereginak, proiektuak, eskaerak eta abisuak.
1. Eskatu koordinazioari zure erabiltzaile-gako pertsonala. Zure giltza da: pertsona bakoitzak berea du eta ez da partekatzen.
2. Ezarpenak → Sinkronizazioa atalean, jarri Zunbeltzen WordPressaren helbidea eta zure erabiltzaile-gakoa.
3. Aplikazioak berak sinkronizatzen du irekitzean, itzultzean eta 10 minuturo estaldura badago. Gaur pantailako sinkronizazio-botoia ere saka dezakezu.
» Estaldurarik gabe lanean jarrai dezakezu: egiten duzuna konexioa itzultzean igotzen da. Argazkiak (puntuenak, eremuenak, finkenak eta zereginenak) wifiarekin bakarrik igotzen eta jaisten dira, daturik ez gastatzeko; bitartean, beste norbaiten argazkia «Deskargatu gabe» ageri da eta ukituta jaits daiteke.
» Urrats hauek koordinazioarekin informazioa partekatzen duten Zunbeltzeko pertsona testerrentzat dira. App-a zure kabuz erabiltzen baduzu, ez duzu sinkronizazioa konfiguratu behar, ezta erabiltzaile-gakorik eskatu ere.',
		'ayudaWebT' => 'Aplikazioa ordenagailuan erabili',
		'ayudaWebB' => 'Aplikazioak nabigatzailean ere funtzionatzen du, ezer instalatu gabe. Erabilgarria da bulegotik edo pantaila handiago batekin lan egiteko.
1. Ireki aplikazioaren web-helbidea zure ordenagailuko nabigatzailean.
2. App-a zure kabuz erabiltzen baduzu, zuzenean has zaitezke lanean, zerbitzaririk konfiguratu gabe eta erabiltzaile-gakorik jarri gabe.
3. Hortik aurrera mugikorrean bezala dabil.
» Zunbeltzeko pertsona testerra bazara, koordinazioak web-helbidea (Zunbeltzen WordPressarena, /app/ amaieran duena) eta zure erabiltzaile-gakoa emango dizkizu, informazioa taldearekin partekatzeko. Zerbitzariaren helbidea jarrita dator: Ezarpenak → Sinkronizazioa atalean zure gakoa baino ez duzu jarri behar.
» Nabigatzailean ere argazkiak atera eta gehi daitezke. Nabigatzailean gordetzen dira, txikituta, eta sinkronizatzean igotzen dira edozein konexiorekin (ez wifiarekin bakarrik).
» iPhonean: ireki helbidea Safarin, sakatu Partekatu → «Gehitu hasierako pantailan» eta ireki beti ikono horretatik. Ireki behin estaldurarekin: hortik aurrera estaldurarik gabe ere irekitzen da. Estaldurarik gabe idazten duzuna gorde egiten da eta hurrengo sinkronizazioan igotzen da.
» Berehalako abisuak: Ezarpenak → Sinkronizazioa atalean, aktibatu «Berehalako abisuak gailu honetan» eta onartu nabigatzailearen baimena. Alarmak, eskaerak (koordinazioari) eta esleitzen dizkizuten zereginak iristen zaizkizu, aplikazioa itxita egonda ere. iPhonean, aplikazioa hasierako pantailan gehituta (iOS 16.4 edo berriagoa) eta ikono horretatik irekita bakarrik dabil.
» Goian «Proba-bertsioa» zerrenda ikusten baduzu, erakustaldia da: bertan idazten duzuna nabigatzaile horretan geratzen da eta beste inork ez du ikusten.',
		'ayudaRolesT' => 'Nork zer egin dezakeen',
		'ayudaRolesB' => 'Pertsona bakoitzak rol bat du, koordinazioak ematen diona.
• Koordinazioa: zereginak sortu, banatu eta ixten ditu; finkak, eremuak, puntuak eta proiektu guztiak kudeatzen ditu; eskaerak onartu edo baztertzen ditu; gunean gertatzen dena ikusten du.
• Testerra: bere zereginak eta orokorrak (inorenak ez direnak) ikusten ditu, haien egoera aldatzen du, orokor bat hartu edo berea utzi. Zereginak eskatu egiten ditu, ez sortu. Puntuak gehitu eta mugitzen ditu (korta mugikor bat, bidoi bat), abisuak ematen ditu eta bere proiektuaren eguneroko lana idazten du irekita dagoen bitartean.
» Ezarpenetan ikusten duzu zein izen eta rolekin zauden konektatuta. Sinkronizaziorik gabe «Tokiko modua» zaude, eta dena edita dezakezu.',
		'ayudaPeticionesT' => 'Zeregin bat eskatu',
		'ayudaPeticionesB' => 'Zerbait behar dela ikusten baduzu (pentsua erosi, ate bat konpondu…), eskatu koordinazioari:
1. Gaur pantailatik edo puntuaren fitxatik, sakatu «Zeregin bat eskatu».
2. Idatzi zer behar den; markatu «Premiazkoa da» presa badu.
3. Gorde. Koordinazioak sinkronizatzean ikusiko du eta zeregin bihurtuko du edo erantzun egingo dizu.
» Zure eskaerak eta haien erantzuna Finkak → Zereginak → eskaeren botoian daude (goian).',
		'ayudaContactosT' => 'Guneko kontaktuak',
		'ayudaContactosB' => 'Agenda partekatua: hiltegiak, albaitaritza, pertsona adituak, erosleak…
1. Gaur pantailan, sakatu kontaktuen ikonoa (goian).
2. Iragazi motaren arabera eta ukitu kontaktu bat deitzeko edo idazteko.
3. Bat gehitzeko, sakatu «Kontaktua gehitu». Zuk gehitutakoak zuzen ditzakezu; koordinazioak denak kudeatzen ditu, bulegotik ere bai.',
		'ayudaNotificacionesT' => 'Jakinarazpenak',
		'ayudaNotificacionesB' => 'Aplikazioak mugikorrean abisatzen dizu:
• Beste pertsona baten alarma bat iristen denean.
• Koordinazioari: eskaera berriak daudenean eta gunean aldatu denaren laburpena.
• Goizero 9:00etan, zeregin iraungiak badituzu, egintzat markatu arte.
» Onartu jakinarazpenen baimena aplikazioak lehen aldiz eskatzen duenean. Aplikazioa itxita dagoenean, Android mugikorrak 15 minuturo gutxi gorabehera begiratzen du berririk dagoen, konexioa badago; mugikorra atsedenean badago, zertxobait gehiago atzera daiteke. Zure mugikorrak bateria aurrezteko bigarren planoko aplikazioak mozten baditu, kendu Larrea Zunbeltz zerrenda horretatik.',
		'ayudaGrupoProblemas' => 'Zerbaitek huts egiten badu',
		'ayudaProblemasT' => 'Ohiko arazoak',
		'ayudaProblemasB' => '• «Zure rolak ez du … baimenik»: hori ez dagokizu. Zeregin bat, hartu esleitu gabe badago edo eskatu koordinazioari zuri esleitzeko.
• Sinkronizatzean «… aldaketa desegin dira: zure rolak ez ditu baimentzen»: zure rolak uzten ez duen zerbait ukitu duzu eta zegoen bezala utzi da.
• «Erabiltzaile-gako okerra»: begiratu osorik kopiatu duzun. Galdu baduzu, koordinazioak berri bat sortzen dizu eta zaharrak ez du balioko.
• Zerbait falta da edo jada zureak ez diren gauzak ikusten dituzu: Ezarpenetan, «Dena hasieratik sinkronizatu».
• Eguraldi-iragarpena ez da agertzen: internet behar du. Gainerakoak estaldurarik gabe dabil.
• Eguneraketa deskargatzen da baina ez da instalatzen: mugikorraren ezarpenetan, baimendu «aplikazio ezezagunak instalatzea» Larrea Zunbeltzentzat.
» Sinkronizazioarekin, zure datuak Zunbeltzen zerbitzarian ere badaude: mugikorrez aldatzen baduzu, konfiguratu berria zure erabiltzaile-gakoarekin eta berreskuratuko dituzu.',
	),
);
