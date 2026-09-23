/// Entradas enciclopédicas del Cuaderno de Irune. Cada entrada se
/// desbloquea cuando un flag narrativo ya está activo (ej. conocer
/// a un personaje). Son lectura opcional — el niño con inquietud
/// entra, el que no, lo ignora. Sin gameplay nuevo.
///
/// Categorías cubiertas: personajes, fragmentos, lugares, historia,
/// naturaleza, mitos. Pensadas para extender el mundo más allá de las
/// matemáticas sin cambiar el foco del juego.
enum CategoriaCuaderno {
  bitacora,
  personajes,
  fragmentos,
  lugares,
  historia,
  naturaleza,
  mitos,
}

extension NombreCategoriaCuaderno on CategoriaCuaderno {
  String get nombreVisible {
    switch (this) {
      case CategoriaCuaderno.bitacora:
        return 'Bitácora';
      case CategoriaCuaderno.personajes:
        return 'Personajes';
      case CategoriaCuaderno.fragmentos:
        return 'Fragmentos';
      case CategoriaCuaderno.lugares:
        return 'Lugares';
      case CategoriaCuaderno.historia:
        return 'Historia';
      case CategoriaCuaderno.naturaleza:
        return 'Naturaleza';
      case CategoriaCuaderno.mitos:
        return 'Mitos';
    }
  }
}

class EntradaCuaderno {
  final String id;
  final CategoriaCuaderno categoria;
  final String titulo;
  final String texto;

  /// Flag narrativo que, cuando está activo, desbloquea esta entrada.
  /// Si el flag no se ha activado aún, la entrada no aparece en el
  /// cuaderno.
  final String flagDesbloqueo;

  const EntradaCuaderno({
    required this.id,
    required this.categoria,
    required this.titulo,
    required this.texto,
    required this.flagDesbloqueo,
  });
}

/// Catálogo canónico de entradas. El orden dentro de cada categoría
/// es narrativamente significativo (personajes en orden de aparición).
class CatalogoCuaderno {
  static const List<EntradaCuaderno> todas = [
    // ------- Bitácora -------
    // Entradas autogeneradas por hitos del propio recorrido del niño.
    // Cada una se desbloquea con un flag que el sistema activa de
    // forma natural (combates ganados/perdidos, rangos alcanzados,
    // arcos cerrados). Voz en segunda persona, sobria — sin palmadita.
    EntradaCuaderno(
      id: 'bitacora_primer_pleno',
      categoria: CategoriaCuaderno.bitacora,
      titulo: 'El primer Pleno',
      texto:
          'Sora te enseñó el gesto en el tejado del Edificio. El Pleno '
          'se rompe limpio cuando el corte va al centro. Lo entendiste '
          'enseguida — más rápido de lo que ella esperaba, aunque no lo '
          'va a decir.',
      flagDesbloqueo: 'escena_1_2_vista',
    ),
    EntradaCuaderno(
      id: 'bitacora_kurz_primera_vez',
      categoria: CategoriaCuaderno.bitacora,
      titulo: 'Kurz, primera vez',
      texto:
          'Te ganó. Era lo que tocaba — Sora ya te lo había avisado: '
          'la primera vez con Kurz se pierde, la segunda también. Lo '
          'que importa es cómo pierdes. Lo que dijiste al levantarte, '
          'no lo recuerdas. Sora sí.',
      flagDesbloqueo: 'combate_kurz_1_completado',
    ),
    EntradaCuaderno(
      id: 'bitacora_aprendiz_ii',
      categoria: CategoriaCuaderno.bitacora,
      titulo: 'Aprendiz II',
      texto:
          'La marca cambia. Plata desgastada → plata nueva. Irune '
          'asintió una vez sin más. Es lo más cerca de un elogio que '
          'se permite. La gente del Mercado no nota la diferencia, pero '
          'tú sí.',
      flagDesbloqueo: 'rango_aprendiz_ii_alcanzado',
    ),
    EntradaCuaderno(
      id: 'bitacora_cierre_arco_1',
      categoria: CategoriaCuaderno.bitacora,
      titulo: 'Bajar a los Canales',
      texto:
          'Primera vez con permiso. Sora te miró antes de soltarte y '
          'solo dijo "cae mejor". La frase volverá. Las farolas ámbar '
          'vistas desde abajo se sienten distintas — más bajas, más '
          'cercanas. Anota esto.',
      flagDesbloqueo: 'escena_1_14_vista',
    ),
    EntradaCuaderno(
      id: 'bitacora_zafran',
      categoria: CategoriaCuaderno.bitacora,
      titulo: 'Zafrán, herido pero no derrotado',
      texto:
          'Lo dejaste herido, no derrotado. Volverá. Eso fue lo que '
          'dijo Rexán mientras se frotaba la pierna sin darse cuenta. '
          'Te llevaste su mirada larga al final — la que no acompaña '
          'palabras.',
      flagDesbloqueo: 'victoria_zafran',
    ),
    EntradaCuaderno(
      id: 'bitacora_aprendiz_iii',
      categoria: CategoriaCuaderno.bitacora,
      titulo: 'Aprendiz III',
      texto:
          'Cuarta marca. La gente del Mercado te saluda primero ahora. '
          'Antes saludabas tú. Te incomoda un poco — es buena señal. '
          'Naini fingió no fijarse, pero dejó dos manzanas en tu '
          'mochila al pasar.',
      flagDesbloqueo: 'rango_aprendiz_iii_alcanzado',
    ),
    EntradaCuaderno(
      id: 'bitacora_eco_callejon',
      categoria: CategoriaCuaderno.bitacora,
      titulo: 'El día que viste a Eco',
      texto:
          'Eco te habló y luego desapareció en silencio. Sora no quiso '
          'comentar. Irune dijo "algún día". Anótalo: lo dijeron las '
          'dos. Eso significa algo, aunque tú aún no sepas qué.',
      flagDesbloqueo: 'escena_3_9_vista',
    ),
    EntradaCuaderno(
      id: 'bitacora_iniciado',
      categoria: CategoriaCuaderno.bitacora,
      titulo: 'Iniciado',
      texto:
          'Ceremonia corta. Cinco Maestros, cinco "bien". Dos "gracias" '
          'de Sora — no eran para ti, eran para los otros, pero te '
          'llegaron también. Saliste sin saber bien qué sentir. Está '
          'bien así. La marca pesa más que las anteriores.',
      flagDesbloqueo: 'escena_4_10_vista',
    ),
    EntradaCuaderno(
      id: 'bitacora_hasta_entonces',
      categoria: CategoriaCuaderno.bitacora,
      titulo: 'Hasta entonces',
      texto:
          'Sora se va a Kir. La Montaña sigue ahí. La Montaña siempre '
          'estuvo ahí — pero esta noche se ve distinta. Mañana volverás '
          'al cazadero, claro. Y a los Canales, y al Mercado. Pero algo '
          'cambió esta noche, y no se desanda.',
      flagDesbloqueo: 'escena_4_14_vista',
    ),

    // ------- Personajes -------
    EntradaCuaderno(
      id: 'personaje_sora',
      categoria: CategoriaCuaderno.personajes,
      titulo: 'Sora',
      texto:
          'Tu mentora. Llegó a Azula hace dos años, sola, desde una '
          'ciudad llamada Kir al norte del mar. Habla poco pero escucha '
          'mucho. Su marca, desteñida por dentro del cuello, dice que '
          'pasó la Prueba de Sendero — la más larga, la más paciente. '
          'No suele explicar, pero cuando lo hace es de una precisión '
          'rara. Le gusta la gente que no pregunta de más.',
      flagDesbloqueo: 'escena_1_1_vista',
    ),
    EntradaCuaderno(
      id: 'personaje_irune',
      categoria: CategoriaCuaderno.personajes,
      titulo: 'Irune',
      texto:
          'Maestra del Edificio de los Tejados y, sin decirlo, cabeza '
          'de la orden en Azula. Pelo blanco, chaqueta gris, marca de '
          'plata al cuello. Pone marcas de rango y escribe en un '
          'archivo que nadie más consulta. Sus tres reglas: nadie sabe '
          'más de lo que sabe; los Fragmentos no son enemigos; si te '
          'cansas, paras.',
      flagDesbloqueo: 'escena_1_4_vista',
    ),
    EntradaCuaderno(
      id: 'personaje_rexan',
      categoria: CategoriaCuaderno.personajes,
      titulo: 'Rexán',
      texto:
          'Maestro de los Canales. Cojera antigua — regalo de Zafrán '
          'hace veinte años. Se formó con Oryn en el Puerto. Dice que '
          '"el mar acuerda, los canales olvidan", y nadie sabe del '
          'todo qué quiere decir. Paga con monedas antiguas que los '
          'vendedores aceptan sin preguntar.',
      flagDesbloqueo: 'escena_2_2_vista',
    ),
    EntradaCuaderno(
      id: 'personaje_ari',
      categoria: CategoriaCuaderno.personajes,
      titulo: 'Ari',
      texto:
          'Aprendiz con Vadic, en Industria. Doce años, seis meses '
          'más de orden que tú. Habladora, observadora, no teme bajar '
          'al Puerto sola de noche. Su consejo raro: no meterse con '
          'los Fragmentos Espejo los lunes.',
      flagDesbloqueo: 'escena_2_9_vista',
    ),
    EntradaCuaderno(
      id: 'personaje_naini',
      categoria: CategoriaCuaderno.personajes,
      titulo: 'Naini',
      texto:
          'Maestra del Mercado de la Luz. Bienvenidas explosivas, '
          'risas contadas, y bajo todo eso una red de favores y '
          'agudeza que no se ve. Sabe quién comercia con qué y con '
          'quién en toda Azula. Los Coleccionistas le quitan la '
          'sonrisa como ninguna otra cosa.',
      flagDesbloqueo: 'escena_3_1_vista',
    ),
    EntradaCuaderno(
      id: 'personaje_vadic',
      categoria: CategoriaCuaderno.personajes,
      titulo: 'Vadic',
      texto:
          'Maestro de Industria. Mide todo con calibre y anota en '
          'cuadernos que no enseña. Veintidós años aquí. Su regla: '
          '"o se mide bien, o no se mide". Sin término medio. Lleva '
          'años viendo aparecer pintadas de los Opacos y hace como '
          'que no le importan — aunque a veces se para ante una.',
      flagDesbloqueo: 'escena_3_6_vista',
    ),
    EntradaCuaderno(
      id: 'personaje_oryn',
      categoria: CategoriaCuaderno.personajes,
      titulo: 'Oryn',
      texto:
          'Maestro del Puerto Silencioso. Pausas muy largas, palabras '
          'contadas. Dice que "el agua recuerda" y no quiere explicar '
          'qué significa. Entrenó a Rexán hace décadas. Le importa '
          'menos cómo haces las cosas que por qué las haces, aunque '
          'nunca lo pregunta abiertamente.',
      flagDesbloqueo: 'escena_3_10_vista',
    ),
    EntradaCuaderno(
      id: 'personaje_brina',
      categoria: CategoriaCuaderno.personajes,
      titulo: 'Brina',
      texto:
          'Maestra de las Afueras y profesora del observatorio. '
          'Trabaja con datos: tendencias, probabilidades, tablas. Es '
          'la que te cuenta, sin adornos, que en Azula aparecen un '
          '17% más Fragmentos cada trimestre — y que nadie sabe por '
          'qué.',
      flagDesbloqueo: 'escena_3_16_vista',
    ),

    // ------- Fragmentos -------
    EntradaCuaderno(
      id: 'fragmento_que_son',
      categoria: CategoriaCuaderno.fragmentos,
      titulo: '¿Qué son los Fragmentos?',
      texto:
          'Pedazos de algo que se rompió. No son enemigos — la tercera '
          'regla de Irune lo dice claro. Flotan, tienen un valor '
          'numérico, se pueden dividir y desfragmentar. No los matas, '
          'los devuelves al sitio del que salieron. Aparecen más en '
          'noches con niebla y en callejones donde la gente olvida.',
      flagDesbloqueo: 'escena_1_2_vista',
    ),
    EntradaCuaderno(
      id: 'fragmento_kurz',
      categoria: CategoriaCuaderno.fragmentos,
      titulo: 'Kurz',
      texto:
          'Fragmento nombrado de los Tejados. Valor 3/4 la primera vez, '
          '5/6 la segunda, 7/8 la tercera. No se disuelve — se retira '
          'y vuelve. Lleva allí más años que cualquier Maestro vivo. '
          'Irune lo llama "maestro difícil" en privado. Kurz no parece '
          'que sepa lo que es un Maestro, pero sabe cuándo alguien '
          'está listo.',
      flagDesbloqueo: 'escena_1_5_vista',
    ),
    EntradaCuaderno(
      id: 'fragmento_espejo',
      categoria: CategoriaCuaderno.fragmentos,
      titulo: 'Fragmentos Espejo',
      texto:
          'Van en pareja. Uno parece el reflejo del otro, y casi '
          'siempre lo es. 1/2 y 2/4 son el mismo trozo de mundo con '
          'nombres distintos — eso se llama equivaler. Emparejarlos '
          'bien es el gesto más limpio que se puede hacer; mal, '
          'hacen ruido.',
      flagDesbloqueo: 'escena_2_3_vista',
    ),
    EntradaCuaderno(
      id: 'fragmento_zafran',
      categoria: CategoriaCuaderno.fragmentos,
      titulo: 'Zafrán',
      texto:
          'Fragmento Dual muy viejo. Dos cuerpos conectados por una '
          'línea de luz densa, denominadores primos (5/7 y 3/11 la '
          'última vez). Vive en el pozo más viejo de los Canales. '
          'No habla, solo vibra. La pierna de Rexán es suya. Se fue '
          'herido tras tu combate, pero no derrotado. Volverá.',
      flagDesbloqueo: 'escena_2_13_vista',
    ),
    EntradaCuaderno(
      id: 'fragmento_dual',
      categoria: CategoriaCuaderno.fragmentos,
      titulo: 'Fragmentos Duales',
      texto:
          'Dos Fragmentos enganchados por una línea de luz que no se '
          'puede atacar. Hay que unirlos antes — volverlos un solo '
          'Fragmento. Para eso tienen que "hablar el mismo idioma": '
          'mismo denominador. El número más pequeño que los dos '
          'comparten se llama mínimo común múltiplo. MCM para los '
          'amigos.',
      flagDesbloqueo: 'escena_2_7_vista',
    ),
    EntradaCuaderno(
      id: 'fragmento_eco',
      categoria: CategoriaCuaderno.fragmentos,
      titulo: 'Eco',
      texto:
          'El único Fragmento que habla. Aparece en callejones '
          'cualesquiera — el mundo baja de volumen a su alrededor. '
          'Muestra dos valores a la vez (2/4 y 1/2, por ejemplo). No '
          'se puede atacar. Hace preguntas y las respuestas importan, '
          'aunque no sepas para qué. Sora evita hablar de él. Irune '
          'dice "ya lo hablaremos algún día."',
      flagDesbloqueo: 'escena_3_9_vista',
    ),
    // Raros de clima (doc 16, eje E): cada uno se desbloquea al
    // capturarlo. La recompensa del raro es esta entrada — saber.
    EntradaCuaderno(
      id: 'fragmento_la_veleta',
      categoria: CategoriaCuaderno.fragmentos,
      titulo: 'La Veleta',
      texto:
          'Solo baja a los Tejados cuando llueve. Gira despacio sobre '
          'sí misma, como si buscara de dónde viene el viento — o de '
          'dónde vino la Rotura. Los cazadores viejos dicen que verla '
          'da suerte. Sora dice que la suerte no existe, pero esa '
          'noche silbó de vuelta a casa.',
      flagDesbloqueo: 'clima_la_veleta_capturado',
    ),
    EntradaCuaderno(
      id: 'fragmento_el_reflejo',
      categoria: CategoriaCuaderno.fragmentos,
      titulo: 'El Reflejo',
      texto:
          'Vive en la niebla de los Canales, pegado al agua. No flota: '
          'se refleja. Lo raro es que a veces el agua lo muestra y el '
          'aire no. Maren Olbéa le dedicó una carta al director hace '
          'años preguntando si alguien más lo había visto. Nadie '
          'contestó. Tú sí lo has visto.',
      flagDesbloqueo: 'clima_el_reflejo_capturado',
    ),
    EntradaCuaderno(
      id: 'fragmento_la_lucerna',
      categoria: CategoriaCuaderno.fragmentos,
      titulo: 'La Lucerna',
      texto:
          'Una luz pequeña que camina por la niebla del Puerto, a la '
          'altura de los mástiles. Los estibadores juran que guía a '
          'los barcos que se pierden — y que por eso el faro no la '
          'espanta. Irune sospecha que es más vieja que el faro. '
          'Quizá más vieja que el Puerto.',
      flagDesbloqueo: 'clima_la_lucerna_capturado',
    ),
    EntradaCuaderno(
      id: 'fragmento_el_vilano',
      categoria: CategoriaCuaderno.fragmentos,
      titulo: 'El Vilano',
      texto:
          'En las Afueras casi nunca llueve. Cuando llueve, flota el '
          'Vilano: liviano, a contraviento, como una semilla que no '
          'quiere aterrizar. Capturarlo es de las cosas más difíciles '
          'que puede contar un cazador — no por el puzzle, sino por '
          'estar allí el día justo.',
      flagDesbloqueo: 'clima_el_vilano_capturado',
    ),

    // ------- Lugares -------
    EntradaCuaderno(
      id: 'lugar_tejados',
      categoria: CategoriaCuaderno.lugares,
      titulo: 'Edificio de los Tejados',
      texto:
          'Tu casa. Azotea abierta con vista a Azula entera y al '
          'horizonte norte donde se ve la Montaña. Debajo, la sala '
          'de Irune con chimenea y la puerta del Archivo. Los '
          'aprendices entrenan aquí antes de bajar a los distritos.',
      flagDesbloqueo: 'escena_1_1_vista',
    ),
    EntradaCuaderno(
      id: 'lugar_canales',
      categoria: CategoriaCuaderno.lugares,
      titulo: 'Los Canales',
      texto:
          'Barrio al norte. Puentes pequeños de piedra, farolas '
          'amarillas, agua que baja despacio. De noche hay mercadillos '
          'que llevan abiertos desde siempre. El aire es distinto que '
          'en los Tejados: más pesado, más viejo.',
      flagDesbloqueo: 'escena_2_1_vista',
    ),
    EntradaCuaderno(
      id: 'lugar_mercado',
      categoria: CategoriaCuaderno.lugares,
      titulo: 'Mercado de la Luz',
      texto:
          'Portón alto iluminado que se abre a una explosión de color '
          'y voces. Los Fragmentos silvestres aquí no son enemigos: '
          'son valor en circulación. Se cambia uno por tres, tres por '
          'uno, mitades por cuartos. La regla de Naini: "nada gratis, '
          'pero todo posible."',
      flagDesbloqueo: 'escena_3_1_vista',
    ),
    EntradaCuaderno(
      id: 'lugar_industria',
      categoria: CategoriaCuaderno.lugares,
      titulo: 'Industria',
      texto:
          'Galpones de ladrillo rojo, máquinas viejas, luz gris. Aquí '
          'se mide todo y se desconfía de lo que no se puede medir. '
          'Algunas máquinas llevan Fragmentos dentro sin saberlo — por '
          'eso calculan mal.',
      flagDesbloqueo: 'escena_3_6_vista',
    ),
    EntradaCuaderno(
      id: 'lugar_puerto',
      categoria: CategoriaCuaderno.lugares,
      titulo: 'Puerto Silencioso',
      texto:
          'Muelles largos al mar negro. Un faro que parpadea en la '
          'distancia, algo que se mueve lejos y se sumerge. Se trabaja '
          'de noche porque el mar, dicen, escucha. No se habla alto.',
      flagDesbloqueo: 'escena_3_10_vista',
    ),
    EntradaCuaderno(
      id: 'lugar_afueras',
      categoria: CategoriaCuaderno.lugares,
      titulo: 'Afueras',
      texto:
          'Más allá de la ciudad, campo abierto y un observatorio '
          'antiguo. Desde aquí la Montaña se ve entera. Brina vive aquí '
          'entre telescopios y tablas de datos. Las noches de dos '
          'lunas son las mejores para mirar.',
      flagDesbloqueo: 'escena_3_16_vista',
    ),
    EntradaCuaderno(
      id: 'lugar_montana',
      categoria: CategoriaCuaderno.lugares,
      titulo: 'La Montaña',
      texto:
          'Horizonte norte siempre presente. Se sube con el rango de '
          'Fraccionista Mayor. Hace décadas que nadie lo hace. Arriba '
          'vive el Algebrista — o vivía, según a quién preguntes. Un '
          'sendero tenue sube por uno de los flancos. Algún día.',
      flagDesbloqueo: 'escena_3_17_vista',
    ),

    // ------- Historia -------
    EntradaCuaderno(
      id: 'historia_opacos',
      categoria: CategoriaCuaderno.historia,
      titulo: 'Los Opacos',
      texto:
          'Pintadas aparecen en muros de Azula. Siempre la misma mano. '
          '"El uno era la cárcel", "La unidad es la medida de la '
          'obediencia", "En la parte está la libertad". Un manifiesto '
          'que se lee sólo si encuentras las tres. Alguien responde '
          'tachando la última: "La parte sola no libra a nadie". Dos '
          'bandos entre los que no se sabe casi nada.',
      flagDesbloqueo: 'escena_2_5_vista',
    ),
    EntradaCuaderno(
      id: 'historia_coleccionistas',
      categoria: CategoriaCuaderno.historia,
      titulo: 'Los Coleccionistas',
      texto:
          'Gente con dinero que captura Fragmentos grandes y los '
          'mantiene vivos, enjaulados, en lugares concretos. Un '
          'Fragmento así distorsiona el espacio alrededor: contratos '
          'que firmas dentro te favorecen, reuniones duran lo que te '
          'conviene, visitas olvidan la mitad. Muy viejo. Muy difícil '
          'de probar.',
      flagDesbloqueo: 'escena_3_13_vista',
    ),
    EntradaCuaderno(
      id: 'historia_diecisiete',
      categoria: CategoriaCuaderno.historia,
      titulo: 'El 17%',
      texto:
          'Cada trimestre aparecen un 17% más Fragmentos en Azula que '
          'el trimestre anterior. Brina tiene la tabla. Nadie se lo '
          'cuenta a los aprendices nuevos para no asustar. La causa '
          'no se conoce. La consecuencia sí: Azula está peor cada '
          'año.',
      flagDesbloqueo: 'escena_3_16_vista',
    ),

    // ------- Naturaleza -------
    EntradaCuaderno(
      id: 'naturaleza_dos_lunas',
      categoria: CategoriaCuaderno.naturaleza,
      titulo: 'Las dos lunas',
      texto:
          'Hay noches con una luna y noches con dos. Brina dice que '
          'es un ciclo de varias semanas; Sora solo las mira y dice '
          '"las dos esta noche". Las dos lunas dan mejor luz para '
          'leer fuera, y para mirar el cielo — el observatorio saca '
          'sus mejores datos cuando están ambas.',
      flagDesbloqueo: 'escena_1_11_vista',
    ),

    // ------- Mitos -------
    EntradaCuaderno(
      id: 'mito_algebrista',
      categoria: CategoriaCuaderno.mitos,
      titulo: 'El Algebrista',
      texto:
          'Vive en la Montaña, si es que vive. Cree que el Uno puede '
          'repararse — el Uno que, antes de romperse, hacía que el '
          'mundo tuviera sentido sin partes. Irune no sube. Nadie '
          'sube desde hace décadas. Brina cree que sigue ahí arriba. '
          'Algún día será un problema tuyo.',
      flagDesbloqueo: 'escena_3_17_vista',
    ),
    // Secretos espaciales (doc 16, eje E): se desbloquean tocando el
    // punto exacto del escenario, sin ninguna señal. La entrada es el
    // único registro de que ocurrió.
    EntradaCuaderno(
      id: 'mito_ventana_gato',
      categoria: CategoriaCuaderno.mitos,
      titulo: 'La ventana del gato',
      texto:
          'Una ventana concreta de los Tejados, siempre encendida. '
          'Ahí vive el gato de Irune, que no se llama de ninguna '
          'manera porque Irune dice que los nombres son para quien '
          'acude cuando lo llaman. El gato la ignora desde hace nueve '
          'años. Tocaste su ventana y no pasó nada. O eso parece.',
      flagDesbloqueo: 'secreto_ventana_gato_descubierto',
    ),
    EntradaCuaderno(
      id: 'mito_farolillo_apagado',
      categoria: CategoriaCuaderno.mitos,
      titulo: 'El farolillo apagado',
      texto:
          'En el puente bajo de los Canales hay un farolillo que no '
          'se enciende desde antes de la Rotura. Los fareros lo '
          'saltan al hacer la ronda, por respeto o por costumbre. '
          'Lo tocaste. Sora jura que esa noche parpadeó una vez. '
          'Rexán dice que Sora exagera. Ninguno de los dos volvió '
          'a pasar por el puente sin mirarlo.',
      flagDesbloqueo: 'secreto_farolillo_apagado_descubierto',
    ),
  ];

  /// Entradas desbloqueadas según los flags actuales.
  static Future<List<EntradaCuaderno>> disponibles(
    Future<bool> Function(String flag) flagActivo,
  ) async {
    final resultado = <EntradaCuaderno>[];
    for (final entrada in todas) {
      if (await flagActivo(entrada.flagDesbloqueo)) {
        resultado.add(entrada);
      }
    }
    return resultado;
  }

  /// Total posible, para mostrar progreso "X / N" en el HUD.
  static int get totalEntradas => todas.length;
}
