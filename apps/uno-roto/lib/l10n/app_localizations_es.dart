// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get botonSaltar => 'saltar';

  @override
  String get tocaParaContinuar => 'toca para continuar';

  @override
  String get comunCancelar => 'cancelar';

  @override
  String tutorCabecera(String habilidad) {
    return 'pista — $habilidad';
  }

  @override
  String get tutorInputPista => 'pregunta';

  @override
  String get tutorBotonPreguntar => 'preguntar';

  @override
  String get tutorEstadoVacio =>
      'Cuéntame qué te ha trabado.\nCon tus palabras.';

  @override
  String get tutorOfertaTitulo => '¿Quieres una pista?';

  @override
  String tutorOfertaCuerpo(String habilidad) {
    return 'Sobre $habilidad. Una pista, no la solución.';
  }

  @override
  String get tutorOfertaSigoSolo => 'sigo solo';

  @override
  String get tutorOfertaSi => 'sí';

  @override
  String get habTitulo => 'habilidades';

  @override
  String get habTooltipPerfiles => 'Cambiar de perfil';

  @override
  String get habTooltipSonido => 'Ajustes de sonido';

  @override
  String get habTooltipRitmo => 'Cambiar ritmo del juego';

  @override
  String get habTooltipCuenta => 'Cuenta (vincular / sesión)';

  @override
  String get habTooltipSync => 'Sincronizar progreso';

  @override
  String get habTooltipDebugTutor => 'Probar tutor IA (debug)';

  @override
  String get habTooltipReiniciar => 'Reiniciar progreso (debug)';

  @override
  String get habTooltipIdioma => 'Cambiar idioma';

  @override
  String get habIdiomaTitulo => 'Idioma de la app';

  @override
  String get habIdiomaSnack => 'Idioma cambiado.';

  @override
  String get mapaBotonEntrenar => 'Entrenar';

  @override
  String get mapaBotonInstrucciones => 'Cómo se juega';

  @override
  String get tituloInstrucciones => 'CÓMO SE JUEGA';

  @override
  String get demoPuzzleTocaResultado =>
      'Cuando sepas la respuesta,\ntoca la opción correcta.';

  @override
  String get demoPuzzleTocaSiNo => 'Decide y toca SÍ o NO.';

  @override
  String get cazaBotonMapa => '‹ mapa';

  @override
  String get cazaBadgeEntrenando => 'ENTRENANDO · ';

  @override
  String get entrenamientoTitulo => 'ENTRENAMIENTO';

  @override
  String get entrenamientoPregunta => '¿En qué quieres centrarte hoy?';

  @override
  String get sonidoPaqueteTitulo => 'PAQUETE SONORO';

  @override
  String get sonidoPaqueteNoInstalado =>
      'No instalado. Solo suenan los efectos cortos.';

  @override
  String sonidoPaqueteVersion(int version, String tamano) {
    return 'Versión $version · $tamano';
  }

  @override
  String get sonidoPaqueteExplicacion =>
      'Ambient, música y narrativos se descargan del servidor para no inflar el tamaño de la app.';

  @override
  String get sonidoPaqueteBotonDescargar => 'Descargar paquete';

  @override
  String get sonidoPaqueteBotonComprobar => 'Comprobar actualizaciones';

  @override
  String get sonidoPaqueteBotonBorrar => 'Borrar paquete';

  @override
  String get sonidoPaqueteConfirmTitulo => 'Borrar paquete sonoro';

  @override
  String sonidoPaqueteConfirmTexto(String tamano) {
    return 'Se eliminarán $tamano del dispositivo. Podrás volver a descargarlo cuando quieras.';
  }

  @override
  String get sonidoPaqueteConfirmBotonBorrar => 'Borrar';

  @override
  String get sonidoBotonCancelar => 'Cancelar';

  @override
  String get sonidoMensajeInstalado => 'Paquete sonoro instalado.';

  @override
  String get sonidoMensajeBorrado => 'Paquete sonoro borrado.';

  @override
  String sonidoMensajeFallido(String mensaje) {
    return 'Descarga fallida: $mensaje';
  }

  @override
  String get cierreBotonSeguir => 'Seguir practicando';

  @override
  String get cierreBotonBuenasNoches => 'Buenas noches';

  @override
  String get combateBotonDeshacer => 'Deshacer';

  @override
  String get combateBotonDeNuevo => 'De nuevo';

  @override
  String get combateBotonCortar => 'Cortar';

  @override
  String get cinematicaAccionDividir => 'desliza para dividir';

  @override
  String get cinematicaAccionDesfragmentar => 'toca cada mitad';

  @override
  String get comparacionMismoTamano => 'mismo tamaño de trozo';

  @override
  String get comparacionMismoNumero => 'el mismo número de trozos';

  @override
  String get simetriaPreguntaVertical =>
      '¿es simétrica respecto al eje vertical?';

  @override
  String get simetriaPreguntaHorizontal =>
      '¿es simétrica respecto al eje horizontal?';

  @override
  String barrasPreguntaValor(String etiqueta) {
    return '¿cuántos en \"$etiqueta\"?';
  }

  @override
  String get barrasPreguntaTotal => '¿cuál es el total?';

  @override
  String aumentoVerbo(int porcentaje) {
    return 'aumenta un $porcentaje% sobre';
  }

  @override
  String descuentoVerbo(int porcentaje) {
    return 'descuenta un $porcentaje% sobre';
  }

  @override
  String get respuestaSi => 'sí';

  @override
  String get respuestaNo => 'no';

  @override
  String get habRitmoTitulo => 'Ritmo del juego';

  @override
  String habRitmoSnack(String ritmo) {
    return 'Ritmo \"$ritmo\". Se aplicará en la próxima escena.';
  }

  @override
  String get habSyncFaltaToken =>
      'Vincula primero una cuenta desde el icono de perfil.';

  @override
  String get habSyncEnProgreso => 'Sincronizando…';

  @override
  String habSyncResumen(int esquirlas, int flags, int habilidades) {
    return 'Sync OK. Esquirlas $esquirlas · $flags flags · $habilidades habilidades.';
  }

  @override
  String get habSyncSesionCaduco =>
      'La sesión caducó. Ábrela desde \"Cuenta\" e inicia sesión otra vez.';

  @override
  String habApiError(int codigo, String mensaje) {
    return 'API $codigo: $mensaje';
  }

  @override
  String habRedError(String error) {
    return 'Red: $error';
  }

  @override
  String get habReiniciarTitulo => 'Reiniciar progreso';

  @override
  String get habReiniciarCuerpo =>
      'Borra escenas vistas, habilidades, esquirlas y rango. La próxima vez que abras la app, empezarás desde la apertura.';

  @override
  String get habReiniciarBoton => 'reiniciar';

  @override
  String get habReiniciarHecho =>
      'Progreso reiniciado. Cierra la app y vuélvela a abrir.';

  @override
  String habEsquirlasResumen(int n) {
    return '$n esquirlas';
  }

  @override
  String get habNivelInexplorada => 'sin tocar';

  @override
  String get habNivelIntroducida => 'introducida';

  @override
  String get habNivelEnDesarrollo => 'en desarrollo';

  @override
  String get habNivelCompetente => 'competente';

  @override
  String get habNivelMaestria => 'maestría';

  @override
  String habChipNivel(int n, String etiqueta) {
    return '$n $etiqueta';
  }

  @override
  String habFilaResumen(String nivel, int precision, int intentos) {
    return '$nivel · precisión $precision% · $intentos intentos';
  }

  @override
  String get cuentaTitulo => 'cuenta';

  @override
  String get cuentaCrearTitulo => 'crear cuenta';

  @override
  String get cuentaIniciarTitulo => 'iniciar sesión';

  @override
  String get cuentaCerrarSesionTitulo => 'Cerrar sesión';

  @override
  String get cuentaCerrarSesionCuerpo =>
      'El progreso local sigue intacto, solo se desconecta del servidor.';

  @override
  String get cuentaBotonCerrar => 'cerrar';

  @override
  String get cuentaSinCuentaTitulo => 'Sin cuenta vinculada';

  @override
  String get cuentaSinCuentaCuerpo =>
      'Puedes seguir jugando offline. Si vinculas una cuenta, el progreso se guarda en el servidor y se desbloquea el tutor para cuando te atasques.';

  @override
  String get cuentaBotonCrear => 'crear cuenta';

  @override
  String get cuentaBotonIniciar => 'iniciar sesión';

  @override
  String get cuentaVinculadaTitulo => 'Cuenta vinculada';

  @override
  String get cuentaVinculadaCuerpo =>
      'El progreso se sincroniza con el servidor y el tutor está disponible cuando te atascas.';

  @override
  String get cuentaBotonCerrarSesion => 'cerrar sesión';

  @override
  String get cuentaCaducadaTitulo => 'Sesión caducada';

  @override
  String cuentaCaducadaCuerpo(String email) {
    return 'Vuelve a iniciar sesión para sincronizar y usar el tutor:\n$email';
  }

  @override
  String get cuentaCampoEmail => 'email del tutor';

  @override
  String get cuentaCampoPassword => 'contraseña';

  @override
  String get cuentaCampoPasswordMin => 'contraseña (mínimo 8)';

  @override
  String get cuentaCampoNombreTutor => 'nombre del tutor (opcional)';

  @override
  String get cuentaCampoNombreNino => 'nombre del niño';

  @override
  String get cuentaErrorCamposRegistro =>
      'Pon email, contraseña (mínimo 8 caracteres) y nombre del niño.';

  @override
  String get cuentaErrorCamposLogin => 'Pon el email y la contraseña.';

  @override
  String get cuentaErrorRed => 'No se pudo conectar.';

  @override
  String get cuentaBotonCreando => 'creando…';

  @override
  String get cuentaBotonEntrando => 'entrando…';

  @override
  String get cuentaResetTitulo => 'OLVIDÉ MI CONTRASEÑA';

  @override
  String get cuentaResetEmailInvalido => 'Escribe un email válido.';

  @override
  String get cuentaResetErrorRed => 'No se pudo conectar. Inténtalo más tarde.';

  @override
  String get cuentaResetTagline => 'No pasa nada.';

  @override
  String get cuentaResetIntro =>
      'Pon tu email y te mandamos un enlace para crear una contraseña nueva. Caduca en 30 minutos.';

  @override
  String get cuentaResetCampoEmail => 'Email';

  @override
  String get cuentaResetBoton => 'ENVIAR ENLACE';

  @override
  String get cuentaResetEnviadoCuerpo =>
      'Si esa dirección está registrada,\nte llegará un enlace en unos minutos.';

  @override
  String get cuentaResetEnviadoSpam => 'Revisa también la carpeta de spam.';

  @override
  String get cuentaResetBotonVolver => 'VOLVER';

  @override
  String get panelTutorTitulo => 'MODO TUTOR';

  @override
  String get panelTutorTooltipSalir => 'Cerrar sesión';

  @override
  String get panelTutorErrorAuth => 'Email o contraseña incorrectos.';

  @override
  String panelTutorErrorServidor(int codigo) {
    return 'Error del servidor ($codigo).';
  }

  @override
  String get panelTutorErrorRed => 'No se pudo conectar al servidor.';

  @override
  String get panelTutorErrorProgreso =>
      'No se pudo cargar el progreso (token caducado).';

  @override
  String get panelTutorTagline => 'Para ti, no para el peque.';

  @override
  String get panelTutorIntro =>
      'Entra con tu email y contraseña para ver el progreso real.';

  @override
  String get panelTutorCampoEmail => 'Email';

  @override
  String get panelTutorCampoPassword => 'Contraseña';

  @override
  String get panelTutorBotonEntrar => 'ENTRAR';

  @override
  String get panelTutorSinNinos => 'Esta cuenta aún no tiene ningún niño.';

  @override
  String get panelTutorElegirNino => 'Elige un niño para ver su progreso.';

  @override
  String panelTutorSaludoConNombre(String nombre) {
    return 'Hola, $nombre.';
  }

  @override
  String get panelTutorSubtituloSaludo =>
      'Aquí tienes el progreso real, sin adornos.';

  @override
  String get sonidoTitulo => 'sonido';

  @override
  String get sonidoSeccionVolumen => 'VOLUMEN POR CAPA';

  @override
  String get sonidoModoSilencioTitulo => 'Modo sin sonido';

  @override
  String get sonidoModoSilencioSubtitulo =>
      'el juego es completamente jugable en silencio';

  @override
  String get ajustesSeccionMaquinas => 'MÁQUINAS';

  @override
  String get sinPrisasTitulo => 'Sin prisas';

  @override
  String get sinPrisasSubtitulo =>
      'En las máquinas de acción nada corre solo: la pieza de Encaje espera, las sombras se paran si tú te paras, las barcas no llegan a la compuerta y Salto va más despacio.';

  @override
  String get sonidoCapaAmbient => 'viento, agua, ruido rosa del mundo';

  @override
  String get sonidoCapaMusica => 'loops de distrito y de combate';

  @override
  String get sonidoCapaEfectos => 'taps, aciertos, errores';

  @override
  String get sonidoCapaNarrativos => 'motivos y efectos únicos';

  @override
  String get sonidoNotaAccesibilidad =>
      'Los ajustes se guardan por perfil. Cada niño que juegue con su perfil tendrá su propia configuración de volúmenes.';

  @override
  String get perfHeaderQuienEres => '¿QUIÉN ERES?';

  @override
  String get perfHeaderSubtitulo => 'elige un perfil o crea uno nuevo';

  @override
  String get perfBadgeActual => 'perfil actual';

  @override
  String get perfTooltipBorrar => 'borrar perfil';

  @override
  String get perfBotonNuevo => 'nuevo perfil';

  @override
  String get perfDialogNuevoTitulo => 'Nuevo perfil';

  @override
  String get perfDialogNuevoHint => 'nombre del jugador';

  @override
  String get perfBotonCrear => 'crear';

  @override
  String get perfDialogBorrarTitulo => 'Borrar perfil';

  @override
  String perfDialogBorrarCuerpo(String nombre) {
    return 'Se borrará todo el progreso de $nombre. Esta acción no se puede deshacer.';
  }

  @override
  String get perfBotonBorrar => 'borrar';

  @override
  String get nombreTitulo => '¿Cómo te llamas?';

  @override
  String get nombreSubtitulo => 'sora te va a preguntar en un momento';

  @override
  String get nombreBotonContinuar => 'continuar';

  @override
  String get cuadernoTitulo => 'cuaderno';

  @override
  String get cuadernoVacio =>
      'Aún no has desbloqueado entradas.\nSigue jugando — cada persona o lugar que conozcas abre una página.';

  @override
  String cuadernoResumen(int leidas, int desbloqueadas, int total) {
    return '$leidas leídas · $desbloqueadas de $total desbloqueadas';
  }

  @override
  String mapaArcoResumen(String romano, int vistas, int total) {
    return 'Arco $romano · $vistas/$total';
  }

  @override
  String get mapaMontanaTitulo => 'LA MONTAÑA';

  @override
  String get mapaMontanaSubtitulo => 'el horizonte espera';

  @override
  String mapaDistritoBloqueado(int n) {
    return 'se abre a las $n esquirlas';
  }

  @override
  String get puzzleBotonHuir => 'huir';

  @override
  String get rangoAprendiz1 => 'Aprendiz I';

  @override
  String get rangoAprendiz2 => 'Aprendiz II';

  @override
  String get rangoAprendiz3 => 'Aprendiz III';

  @override
  String get rangoIniciado => 'Iniciado';

  @override
  String get ritmoTranquilo => 'Tranquilo';

  @override
  String get ritmoEstandar => 'Estándar';

  @override
  String get ritmoExigente => 'Exigente';

  @override
  String get ritmoTranquiloDesc =>
      'Las palabras aparecen más despacio. Los combates dan más tiempo.';

  @override
  String get ritmoEstandarDesc => 'La velocidad base del juego.';

  @override
  String get ritmoExigenteDesc =>
      'Todo va más rápido. Los combates piden más agilidad.';

  @override
  String get capaAmbient => 'Ambiente';

  @override
  String get capaMusica => 'Música';

  @override
  String get capaEfectos => 'Efectos';

  @override
  String get capaNarrativos => 'Narrativos';

  @override
  String get catCuadernoBitacora => 'Bitácora';

  @override
  String get catCuadernoPersonajes => 'Personajes';

  @override
  String get catCuadernoFragmentos => 'Fragmentos';

  @override
  String get catCuadernoLugares => 'Lugares';

  @override
  String get catCuadernoHistoria => 'Historia';

  @override
  String get catCuadernoNaturaleza => 'Naturaleza';

  @override
  String get catCuadernoMitos => 'Mitos';

  @override
  String get puzzleHeaderAmplificar => 'AMPLIFICAR';

  @override
  String get puzzleInstrAmplificar => 'completa: toca el número que falta';

  @override
  String get puzzleHeaderSumaBasica => 'SUMAR';

  @override
  String get puzzleInstrSumaBasica => '¿cuánto suman?';

  @override
  String get puzzleHeaderEcuacionLineal => 'DESPEJA X';

  @override
  String get puzzleInstrEcuacionLineal =>
      '¿qué valor de x hace cierta la ecuación?';

  @override
  String get puzzleHeaderAngulo => 'ÁNGULO';

  @override
  String get puzzleInstrAngulo => 'toca el nombre del ángulo dibujado';

  @override
  String get puzzleInstrAreaRectangulo =>
      'área = base × altura. Toca el resultado';

  @override
  String get puzzleHeaderTriangulo => 'TRIÁNGULO';

  @override
  String get puzzleInstrAreaTriangulo =>
      'área = base × altura ÷ 2. Toca el resultado';

  @override
  String get puzzleInstrCirculoPi =>
      'usa la fórmula (π ≈ 3,14) y toca el resultado';

  @override
  String get puzzleHeaderComparar => 'COMPARAR';

  @override
  String get puzzleInstrCualEsMayor => 'toca la fracción mayor';

  @override
  String get puzzleInstrLeerCifras =>
      'toca el decimal mayor (más cifras no es más)';

  @override
  String get puzzleInstrMiraValor =>
      'toca el decimal mayor (más cifras no es más)';

  @override
  String get puzzleHeaderContraMitad => 'CONTRA 1/2';

  @override
  String get puzzleInstrContraMitad => 'toca <, =, > comparándola con 1/2';

  @override
  String get puzzleHeaderContraUno => 'CONTRA 1';

  @override
  String get puzzleInstrContraUno => 'toca <, =, > comparándola con 1';

  @override
  String get puzzleHeaderDecimal => 'DECIMAL';

  @override
  String get puzzleInstrQueDecimal => 'toca el decimal que vale lo mismo';

  @override
  String get puzzleHeaderDivisores => 'DIVISORES';

  @override
  String get puzzleInstrCualNoDivisor => 'tres son divisores. Toca el que NO';

  @override
  String get puzzleHeaderDual => 'DUAL';

  @override
  String get puzzleInstrDual => 'calcula la operación y toca el resultado';

  @override
  String get puzzleHeaderEscala => 'ESCALA';

  @override
  String puzzleInstrEscalaMapa(int denominador) {
    return 'mapa 1:$denominador';
  }

  @override
  String get puzzleInstrEnPlano => 'en plano';

  @override
  String get puzzleHeaderEspejo => 'ESPEJO';

  @override
  String get puzzleInstrEspejo => 'toca la fracción equivalente';

  @override
  String get puzzleHeaderParte => 'PARTE';

  @override
  String get puzzleInstrCalcula => 'calcula y toca el resultado';

  @override
  String get puzzleHeaderGrafico => 'GRÁFICO';

  @override
  String get puzzleHeaderCircular => 'CIRCULAR';

  @override
  String get puzzleHeaderImpropio => 'IMPROPIO';

  @override
  String get puzzleInstrImpropio => 'toca el número mixto que vale igual';

  @override
  String get puzzleHeaderJerarquia => 'JERARQUÍA';

  @override
  String get puzzleInstrJerarquiaPrimero =>
      'primero × y ÷, después + y −. Toca el resultado';

  @override
  String get puzzleInstrJerarquiaRecuerda =>
      '× y ÷ antes que + y −. Toca el resultado';

  @override
  String get puzzleHeaderLeer => 'LEER';

  @override
  String get puzzleInstrQueNumero => 'lee el texto y toca el número correcto';

  @override
  String get puzzleInstrQueFraccion =>
      'lee el texto y toca la fracción correcta';

  @override
  String get puzzleHeaderLongitud => 'LONGITUD';

  @override
  String get puzzleInstrConvierteMedida => 'convierte y toca el resultado';

  @override
  String get puzzleHeaderMedia => 'MEDIA';

  @override
  String get puzzleInstrCalculaMedia => 'suma y divide. Toca la media';

  @override
  String get puzzleHeaderConvertir => 'CONVERTIR';

  @override
  String get puzzleInstrConvertirImpropia =>
      'toca la fracción impropia equivalente';

  @override
  String puzzleInstrCualEsModa(String modo) {
    return 'toca el valor de la $modo';
  }

  @override
  String get puzzleHeaderOpDecimal => 'OP. DECIMAL';

  @override
  String get puzzleInstrCuantoValeOp => 'calcula y toca el resultado';

  @override
  String get puzzleHeaderDecimalFraccion => 'DECIMAL Y FRACCIÓN';

  @override
  String get puzzleInstrFraccionDecimal =>
      'calcula la operación mixta y toca el resultado';

  @override
  String get puzzleHeaderOrdenar => 'ORDENAR';

  @override
  String get puzzleInstrOrdenar => 'toca la fila ordenada de menor a mayor';

  @override
  String get puzzleHeaderPerimetro => 'PERÍMETRO';

  @override
  String get puzzleInstrPerimetro => 'suma los lados y toca el perímetro';

  @override
  String get puzzleHeaderPoligono => 'POLÍGONO';

  @override
  String get puzzleInstrPoligono => 'toca el nombre del polígono dibujado';

  @override
  String get puzzleHeaderPorcentaje => 'PORCENTAJE';

  @override
  String get puzzleInstrPorcentajeFraccion =>
      'toca la fracción equivalente al porcentaje';

  @override
  String puzzleInstrPorcentajeDe(int porcentaje, int cantidad) {
    return 'el $porcentaje % de $cantidad';
  }

  @override
  String get puzzleHeaderQuePorcentaje => '¿QUÉ %?';

  @override
  String get puzzleInstrQuePorcentaje => 'toca el porcentaje correcto';

  @override
  String get puzzleHeaderPrimos => 'PRIMOS';

  @override
  String get puzzleInstrEsPrimo => 'toca SÍ si es primo, NO si no lo es';

  @override
  String get puzzleHeaderProbabilidad => 'PROBABILIDAD';

  @override
  String puzzleInstrProbabilidadSaco(int favorables, int otros) {
    return 'saco con $favorables rojas y $otros azules';
  }

  @override
  String get puzzleInstrProbabilidadFormula =>
      'toca la fracción que da la probabilidad';

  @override
  String get puzzleHeaderPProb => 'P → %';

  @override
  String puzzleInstrPEquals(int numerador, int denominador) {
    return 'P = $numerador/$denominador';
  }

  @override
  String get puzzleInstrComoPorcentaje =>
      'toca el porcentaje equivalente a la fracción';

  @override
  String get puzzleHeaderProporcion => 'PROPORCIÓN';

  @override
  String get puzzleInstrCompletaProporcion =>
      'completa: toca el número que falta';

  @override
  String get puzzleInstrSiEsto => 'si esto, entonces…';

  @override
  String get puzzleHeaderRazon => 'RAZÓN';

  @override
  String get puzzleInstrRazon => 'toca la razón ya reducida';

  @override
  String get puzzleHeaderRedondear => 'REDONDEAR';

  @override
  String get puzzleInstrRedondear => 'toca el redondeo a la décima';

  @override
  String get puzzleHeaderSimetria => 'SIMETRÍA';

  @override
  String get puzzleHeaderSimplificar => 'SIMPLIFICAR';

  @override
  String get puzzleInstrSimplificar => 'toca la fracción reducida al máximo';

  @override
  String get puzzleHeaderSuperficie => 'SUPERFICIE';

  @override
  String get puzzleInstrSuperficie =>
      'convierte la superficie. Toca el resultado';

  @override
  String get puzzleHeaderTiempo => 'TIEMPO';

  @override
  String get puzzleInstrTiempo => 'convierte y toca el resultado';

  @override
  String get puzzleHeaderVolumen => 'VOLUMEN';

  @override
  String get puzzleInstrVolumenFormula =>
      'V = largo × ancho × alto. Toca el volumen';

  @override
  String get estadisticoModa => 'moda';

  @override
  String get estadisticoMediana => 'mediana';

  @override
  String get sonidoDescargaConectando => 'Conectando con el servidor…';

  @override
  String sonidoDescargaBajandoConTotal(String mb, String total) {
    return 'Bajando $mb / $total MB';
  }

  @override
  String sonidoDescargaBajandoSinTotal(String mb) {
    return 'Bajando $mb MB';
  }

  @override
  String get sonidoDescargaVerificando => 'Verificando integridad…';

  @override
  String sonidoDescargaInstalando(int actual, int total) {
    return 'Instalando $actual / $total';
  }

  @override
  String get cuentaErrorCamposAnadirNino =>
      'Pon el email, la contraseña y el nombre del niño.';

  @override
  String get cuentaAnadirNinoTitulo => 'AÑADIR NIÑO';

  @override
  String get cuentaAnadirNinoTagline =>
      'Mete el email y la contraseña del tutor que ya tiene cuenta. Añadiremos a este niño bajo esa misma cuenta.';

  @override
  String get cuentaAnadirNinoBoton => 'AÑADIR NIÑO';

  @override
  String get cuentaAnadirNinoBotonEnviando => 'AÑADIENDO…';
}
