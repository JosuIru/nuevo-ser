import 'dart:math' as math;

import '../ejercicio.dart';
import '../utilidades.dart';

/// Fichas de los dominios MED (medida) y GEO (geometría). Solo las que se
/// pueden plantear con palabras y números: las que necesitan una figura
/// dibujada se saltan en v0.1.

/// Conversión por una escalera de unidades con [factorPeldano] entre
/// peldaños (10 en longitud, 100 en superficie, 1000 en volumen).
Ejercicio _conversionEscalera(
  math.Random azar,
  List<String> unidades, {
  required int factorPeldano,
  int maximoPeldanos = 3,
}) {
  final origen = azar.nextInt(unidades.length);
  late int destino;
  do {
    destino = azar.nextInt(unidades.length);
  } while (destino == origen || (destino - origen).abs() > maximoPeldanos);
  final peldanos = destino - origen;
  final factor = math.pow(factorPeldano, peldanos.abs()).toDouble();
  // Hacia unidades pequeñas: entero o con un decimal. Hacia grandes: un
  // múltiplo redondo para que el resultado no tenga una ristra de ceros.
  final valor = peldanos > 0
      ? (azar.nextBool() ? azar.entre(2, 30).toDouble() : azar.entre(11, 99) / 10)
      : azar.entre(1, 9) * factor * (azar.nextBool() ? 1 : 10) / 10;
  final resultado = peldanos > 0 ? valor * factor : valor / factor;
  return Ejercicio(
    enunciado: 'Completa:',
    destacado: '${formatearDecimal(valor, cifras: 6)} ${unidades[origen]} = ___ ${unidades[destino]}',
    solucion: formatearDecimal(resultado, cifras: 6),
    renglones: 2,
  );
}

const _longitud = ['km', 'hm', 'dam', 'm', 'dm', 'cm', 'mm'];
const _masa = ['kg', 'hg', 'dag', 'g', 'dg', 'cg', 'mg'];
const _capacidad = ['kL', 'hL', 'daL', 'L', 'dL', 'cL', 'mL'];
const _superficie = ['km²', 'hm²', 'dam²', 'm²', 'dm²', 'cm²', 'mm²'];
const _volumen = ['m³', 'dm³', 'cm³'];

const _poligonos = {
  3: 'triángulo', 4: 'cuadrilátero', 5: 'pentágono', 6: 'hexágono', //
  7: 'heptágono', 8: 'octógono', 9: 'eneágono', 10: 'decágono',
};

String _clasificarAngulo(int grados) => grados < 90
    ? 'agudo'
    : grados == 90
        ? 'recto'
        : grados < 180
            ? 'obtuso'
            : 'llano';

/// Ternas pitagóricas pequeñas (catetos, hipotenusa).
const _ternas = [(3, 4, 5), (6, 8, 10), (5, 12, 13), (9, 12, 15), (8, 15, 17), (12, 16, 20), (7, 24, 25)];

final List<PlantillaFicha> plantillasMedidaGeometria = [
  PlantillaFicha(
    idHabilidad: 'MED.01',
    descripcion:
        'Las unidades de longitud van de 10 en 10: km, hm, dam, m, dm, cm, mm. Para pasar a una '
        'unidad más pequeña se multiplica por 10 en cada escalón; a una más grande, se divide.\n'
        'Ejemplo: 3 m = 30 dm = 300 cm, y 2500 m = 2,5 km.',
    preguntaExplicalo: '¿Por qué al pasar de metros a centímetros el número se hace más grande?',
    generar: (azar) => _conversionEscalera(azar, _longitud, factorPeldano: 10),
  ),
  PlantillaFicha(
    idHabilidad: 'MED.02',
    descripcion:
        'La masa (kg, g, mg…) y la capacidad (L, dL, mL…) también van de 10 en 10, como la '
        'longitud: cada escalón hacia abajo multiplica por 10.\n'
        'Ejemplo: 2 kg = 2000 g y 350 mL = 0,35 L.',
    preguntaExplicalo: '¿Qué tienen en común los nombres kilómetro, kilogramo y kilolitro? ¿Qué significa «kilo»?',
    generar: (azar) =>
        _conversionEscalera(azar, azar.nextBool() ? _masa : _capacidad, factorPeldano: 10),
  ),
  PlantillaFicha(
    idHabilidad: 'MED.03',
    descripcion:
        'El tiempo no va de 10 en 10, sino de 60 en 60: 1 hora son 60 minutos y 1 minuto son '
        '60 segundos.\n'
        'Ejemplo: 2 h 30 min son 2 × 60 + 30 = 150 minutos, no 230.',
    preguntaExplicalo: '¿Por qué 1,5 horas no son 1 hora y 50 minutos?',
    generar: (azar) {
      final tipo = azar.nextInt(3);
      if (tipo == 0) {
        final horas = azar.entre(1, 5);
        final minutos = azar.entre(1, 11) * 5;
        return Ejercicio(
          enunciado: 'Completa:',
          destacado: '$horas h $minutos min = ___ min',
          solucion: '${horas * 60 + minutos}',
          renglones: 2,
        );
      }
      if (tipo == 1) {
        final minutos = azar.entre(61, 300);
        return Ejercicio(
          enunciado: 'Escribe en horas y minutos:',
          destacado: '$minutos min = ___ h ___ min',
          solucion: '${minutos ~/ 60} h ${minutos % 60} min',
          renglones: 2,
        );
      }
      // Una película: dura de hora y cuarto a dos horas y media.
      final inicioHora = azar.entre(16, 20);
      final inicioMinuto = azar.entre(0, 11) * 5;
      final duracion = azar.entre(15, 30) * 5;
      final fin = inicioHora * 60 + inicioMinuto + duracion;
      String reloj(int hora, int minuto) => '$hora:${minuto.toString().padLeft(2, '0')}';
      return Ejercicio(
        enunciado: 'Una película empieza a las ${reloj(inicioHora, inicioMinuto)} y dura '
            '$duracion minutos. ¿A qué hora termina?',
        solucion: reloj(fin ~/ 60, fin % 60),
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'MED.04',
    descripcion:
        'Los ángulos se miden en grados (°). Un ángulo recto mide 90°; si mide menos es agudo, '
        'si mide más (y menos de 180°) es obtuso, y uno de 180° es llano.\n'
        'Ejemplo: un ángulo de 40° es agudo, uno de 120° es obtuso, y a uno de 70° le faltan 20° '
        'para ser recto.',
    preguntaExplicalo: 'Busca en el aula un ángulo recto, uno agudo y uno obtuso. ¿Dónde están?',
    generar: (azar) {
      if (azar.nextBool()) {
        final grados = azar.elegir([
          azar.entre(5, 85),
          90,
          azar.entre(95, 175),
          180,
          89,
          91,
        ]);
        return Ejercicio(
          enunciado: '¿Cómo es un ángulo de $grados°: agudo, recto, obtuso o llano? Dibújalo a ojo.',
          solucion: _clasificarAngulo(grados),
          renglones: 3,
        );
      }
      final grados = azar.entre(5, 85);
      final aRecto = azar.nextBool();
      return Ejercicio(
        enunciado: '¿Cuántos grados le faltan a un ángulo de $grados° para ser '
            '${aRecto ? 'recto' : 'llano'}?',
        solucion: '${(aRecto ? 90 : 180) - grados}°',
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'MED.05',
    descripcion:
        'Las unidades de superficie (m², cm²…) van de 100 en 100, no de 10 en 10: un cuadrado de '
        '1 m de lado tiene 100 × 100 = 10 000 cm².\n'
        'Ejemplo: 3 m² = 30 000 cm², y 500 cm² = 5 dm².',
    preguntaExplicalo: '¿Por qué 1 m² son 10 000 cm² y no 100? Haz un dibujo si te ayuda.',
    generar: (azar) =>
        _conversionEscalera(azar, _superficie, factorPeldano: 100, maximoPeldanos: 2),
  ),
  PlantillaFicha(
    idHabilidad: 'MED.06',
    descripcion:
        'Las unidades de volumen van de 1000 en 1000: 1 m³ = 1000 dm³. Y se relacionan con la '
        'capacidad: 1 dm³ es 1 litro y 1 cm³ es 1 mililitro.\n'
        'Ejemplo: 2,5 m³ = 2500 dm³, es decir, 2500 litros.',
    preguntaExplicalo: '¿Por qué una caja de 1 dm de lado tiene 1000 cm³? Explícalo con cubitos.',
    generar: (azar) {
      if (azar.nextBool()) {
        return _conversionEscalera(azar, _volumen, factorPeldano: 1000, maximoPeldanos: 1);
      }
      final cantidad = azar.entre(2, 40) * (azar.nextBool() ? 1 : 25);
      final aLitros = azar.nextBool();
      return aLitros
          ? Ejercicio(
              enunciado: 'Completa:',
              destacado: '$cantidad dm³ = ___ L',
              solucion: '$cantidad',
              renglones: 2,
            )
          : Ejercicio(
              enunciado: 'Un recipiente tiene una capacidad de $cantidad cL. ¿Cuántos cm³ de agua caben?',
              solucion: '${cantidad * 10}',
              renglones: 2,
            );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'GEO.01',
    descripcion:
        'Los polígonos se nombran por su número de lados: triángulo (3), cuadrilátero (4), '
        'pentágono (5), hexágono (6)… Los ángulos pueden ser agudos (menos de 90°), rectos (90°) '
        'u obtusos (más de 90°).\n'
        'Ejemplo: una señal de stop es un octógono (8 lados), y la esquina de una hoja, un ángulo recto.',
    preguntaExplicalo: '¿Un círculo es un polígono? Explica por qué sí o por qué no.',
    generar: (azar) {
      final lados = azar.entre(3, 10);
      final tipo = azar.nextInt(3);
      if (tipo == 2) {
        final grados = azar.elegir([azar.entre(10, 80), 90, azar.entre(100, 170)]);
        return Ejercicio(
          enunciado: 'Un ángulo mide $grados°. ¿Es agudo, recto u obtuso? Dibújalo a ojo.',
          solucion: _clasificarAngulo(grados),
          renglones: 3,
        );
      }
      if (tipo == 0) {
        return Ejercicio(
          enunciado: '¿Cómo se llama un polígono de $lados lados? Dibuja uno.',
          solucion: _poligonos[lados]!,
          renglones: 4,
        );
      }
      return Ejercicio(
        enunciado: '¿Cuántos lados y cuántos vértices tiene un ${_poligonos[lados]}? Dibuja uno.',
        solucion: '$lados lados y $lados vértices',
        renglones: 4,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'GEO.02',
    descripcion:
        'El perímetro es lo que mide el borde de una figura: la suma de todos sus lados. Se mide '
        'en unidades de longitud (cm, m…).\n'
        'Ejemplo: un rectángulo de 5 cm por 3 cm tiene 5 + 3 + 5 + 3 = 16 cm de perímetro.',
    preguntaExplicalo: 'Si quieres poner una valla alrededor de un huerto, ¿necesitas el perímetro o el área? ¿Por qué?',
    generar: (azar) {
      final tipo = azar.nextInt(3);
      if (tipo == 0) {
        final largo = azar.entre(4, 20);
        final ancho = azar.entre(2, largo - 1);
        return Ejercicio(
          enunciado: 'Un huerto rectangular mide $largo m de largo y $ancho m de ancho. '
              '¿Cuántos metros de valla hacen falta para rodearlo?',
          solucion: '${2 * (largo + ancho)} m',
          renglones: 3,
        );
      }
      if (tipo == 1) {
        final lados = azar.entre(3, 8);
        final lado = azar.entre(2, 15);
        return Ejercicio(
          enunciado: '¿Cuál es el perímetro de un ${_poligonos[lados]} regular de $lado cm de lado?',
          solucion: '${lados * lado} cm',
          renglones: 3,
        );
      }
      final (a, b, c) = azar.elegir(_ternas);
      return Ejercicio(
        enunciado: 'Los lados de un triángulo miden $a cm, $b cm y $c cm. ¿Cuál es su perímetro?',
        solucion: '${a + b + c} cm',
        renglones: 2,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'GEO.03',
    descripcion:
        'El área es lo que ocupa una figura por dentro. En un rectángulo se calcula multiplicando '
        'la base por la altura, y se mide en unidades cuadradas (cm², m²).\n'
        'Ejemplo: un rectángulo de 5 cm por 3 cm tiene 5 × 3 = 15 cm² de área.',
    preguntaExplicalo: '¿Por qué el área se mide en cm² y el perímetro en cm?',
    generar: (azar) {
      final esCuadrado = azar.nextInt(3) == 0;
      final base = azar.entre(3, 15);
      // Un rectángulo «de 7 m por 7 m» sería un cuadrado: el ancho, siempre menor.
      final altura = esCuadrado ? base : azar.entre(2, base - 1);
      return Ejercicio(
        enunciado: esCuadrado
            ? '¿Cuál es el área de un cuadrado de $base cm de lado?'
            : 'Un patio rectangular mide $base m de largo y $altura m de ancho. ¿Qué área tiene?',
        solucion: '${base * altura} ${esCuadrado ? 'cm²' : 'm²'}',
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'GEO.04',
    descripcion:
        'Un triángulo es la mitad de un rectángulo con su misma base y altura. Por eso su área es '
        'base por altura entre 2.\n'
        'Ejemplo: un triángulo de 6 cm de base y 4 cm de altura tiene 6 × 4 : 2 = 12 cm².',
    preguntaExplicalo: 'Dibuja un rectángulo y una diagonal. ¿Qué te dice eso del área del triángulo?',
    generar: (azar) {
      late int base, altura;
      do {
        base = azar.entre(3, 16);
        altura = azar.entre(2, 12);
      } while ((base * altura).isOdd);
      return Ejercicio(
        enunciado: 'Un triángulo tiene $base cm de base y $altura cm de altura. ¿Cuál es su área?',
        solucion: '${base * altura ~/ 2} cm²',
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'GEO.05',
    descripcion:
        'En un círculo de radio r, el borde (circunferencia) mide 2 × π × r y el área es π × r^{2}. '
        'π es un número que vale más o menos 3,14.\n'
        'Ejemplo: con r = 3 cm, la circunferencia mide 2 × 3,14 × 3 = 18,84 cm y el área, '
        '3,14 × 3 × 3 = 28,26 cm².',
    preguntaExplicalo: 'Si duplicas el radio de un círculo, ¿se duplica también su área? Explícalo.',
    generar: (azar) {
      final radio = azar.entre(1, 10);
      final esArea = azar.nextBool();
      final resultado = esArea ? 3.14 * radio * radio : 2 * 3.14 * radio;
      return Ejercicio(
        enunciado: esArea
            ? 'Calcula el área de un círculo de $radio cm de radio (usa π ≈ 3,14).'
            : 'Calcula la longitud de una circunferencia de $radio cm de radio (usa π ≈ 3,14).',
        solucion: '${formatearDecimal(resultado, cifras: 2)} ${esArea ? 'cm²' : 'cm'}',
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'GEO.06',
    descripcion:
        'El volumen es lo que ocupa un cuerpo. En un ortoedro (una caja) se multiplican el largo, '
        'el ancho y el alto, y se mide en unidades cúbicas (cm³, m³).\n'
        'Ejemplo: una caja de 5 cm de largo, 4 cm de ancho y 2 cm de alto tiene 5 × 4 × 2 = 40 cm³.',
    preguntaExplicalo: '¿Cuántos cubitos de 1 cm caben en una caja de 2 × 3 × 4 cm? ¿Cómo lo has contado?',
    generar: (azar) {
      final largo = azar.entre(2, 12);
      final ancho = azar.entre(2, 10);
      final alto = azar.entre(2, 10);
      return Ejercicio(
        enunciado: 'Una caja mide $largo cm de largo, $ancho cm de ancho y $alto cm de alto. '
            '¿Cuál es su volumen?',
        solucion: '${largo * ancho * alto} cm³',
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'GEO.08',
    descripcion:
        'En un triángulo rectángulo, los lados que forman el ángulo recto se llaman catetos (a y b) '
        'y el más largo, hipotenusa (c). Siempre se cumple a^{2} + b^{2} = c^{2}.\n'
        'Ejemplo: con catetos de 3 cm y 4 cm, c^{2} = 9 + 16 = 25, así que la hipotenusa mide 5 cm.',
    preguntaExplicalo: '¿Sirve el teorema de Pitágoras para cualquier triángulo? ¿Por qué?',
    generar: (azar) {
      final (a, b, c) = azar.elegir(_ternas);
      if (azar.nextBool()) {
        return Ejercicio(
          enunciado: 'Los catetos de un triángulo rectángulo miden $a cm y $b cm. ¿Cuánto mide la hipotenusa?',
          solucion: '$c cm',
          renglones: 3,
        );
      }
      return Ejercicio(
        enunciado: 'La hipotenusa de un triángulo rectángulo mide $c cm y un cateto, $a cm. '
            '¿Cuánto mide el otro cateto?',
        solucion: '$b cm',
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'GEO.09',
    descripcion:
        'Dos figuras son semejantes si tienen la misma forma y sus lados son proporcionales. Con '
        'el teorema de Tales se calculan alturas con sombras: a la misma hora, la razón altura/sombra es igual.\n'
        'Ejemplo: si un palo de 1 m da 2 m de sombra y un árbol da 10 m, el árbol mide 10 : 2 = 5 m.',
    preguntaExplicalo: '¿Por qué la sombra sirve para medir un árbol sin subirse a él?',
    generar: (azar) {
      if (azar.nextBool()) {
        final palo = azar.entre(1, 2);
        final sombraPalo = azar.entre(2, 4);
        final factor = azar.entre(3, 8);
        return Ejercicio(
          enunciado: 'A la misma hora, un palo de $palo m da una sombra de $sombraPalo m y un árbol da '
              'una sombra de ${sombraPalo * factor} m. ¿Cuánto mide el árbol?',
          solucion: '${palo * factor} m',
          renglones: 3,
        );
      }
      final razon = azar.entre(2, 4);
      // Solo triángulos que existen: el lado mayor, menor que la suma de los otros dos.
      late List<int> lados;
      do {
        lados = [azar.entre(2, 6), azar.entre(2, 6), azar.entre(3, 7)]..sort();
      } while (lados[0] + lados[1] <= lados[2]);
      return Ejercicio(
        enunciado: 'Un triángulo tiene lados de ${unirConY(lados.map((l) => '$l cm').toList())}. '
            'Otro triángulo semejante tiene cada lado multiplicado por $razon '
            '(razón de semejanza $razon). ¿Cuánto miden sus lados?',
        solucion: lados.map((l) => '${l * razon} cm').join(', '),
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'GEO.10',
    descripcion:
        'Cada polígono tiene su fórmula de área: romboide, base · altura; rombo, (D · d) : 2; '
        'trapecio, (B + b) · altura : 2. Y un polígono cualquiera se puede partir en triángulos.\n'
        'Ejemplo: un rombo de diagonales 6 cm y 4 cm tiene (6 · 4) : 2 = 12 cm².',
    preguntaExplicalo: '¿Por qué el área del rombo se parece a la del triángulo? Haz un dibujo.',
    generar: (azar) {
      final tipo = azar.nextInt(3);
      if (tipo == 0) {
        final diagonalMayor = azar.entre(6, 16);
        late int diagonalMenor;
        do {
          diagonalMenor = azar.entre(3, diagonalMayor - 1);
        } while ((diagonalMayor * diagonalMenor).isOdd);
        return Ejercicio(
          enunciado: 'Un rombo tiene diagonales de $diagonalMayor cm y $diagonalMenor cm. ¿Cuál es su área?',
          solucion: '${diagonalMayor * diagonalMenor ~/ 2} cm²',
          renglones: 3,
        );
      }
      if (tipo == 1) {
        final baseMayor = azar.entre(6, 14);
        final baseMenor = azar.entre(2, baseMayor - 1);
        late int altura;
        do {
          altura = azar.entre(2, 10);
        } while (((baseMayor + baseMenor) * altura).isOdd);
        return Ejercicio(
          enunciado: 'Un trapecio tiene bases de $baseMayor cm y $baseMenor cm, y $altura cm de altura. '
              '¿Cuál es su área?',
          solucion: '${(baseMayor + baseMenor) * altura ~/ 2} cm²',
          renglones: 3,
        );
      }
      final base = azar.entre(4, 15);
      final altura = azar.entre(2, 10);
      return Ejercicio(
        enunciado: 'Un romboide tiene $base cm de base y $altura cm de altura. ¿Cuál es su área?',
        solucion: '${base * altura} cm²',
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'GEO.11',
    descripcion:
        'El volumen de un prisma o de un cilindro es el área de la base por la altura. En un '
        'cilindro, la base es un círculo: V = π · r^{2} · h.\n'
        'Ejemplo: un cilindro de 2 cm de radio y 5 cm de altura tiene 3,14 · 2^{2} · 5 = 62,8 cm³.',
    preguntaExplicalo: '¿Por qué el volumen de un prisma es «área de la base por altura»? Piensa en hojas apiladas.',
    generar: (azar) {
      final altura = azar.entre(3, 12);
      if (azar.nextBool()) {
        final radio = azar.entre(1, 6);
        return Ejercicio(
          enunciado: 'Un bote cilíndrico tiene $radio cm de radio y $altura cm de altura. '
              '¿Cuál es su volumen? (π ≈ 3,14)',
          solucion: '${formatearDecimal(3.14 * radio * radio * altura, cifras: 2)} cm³',
          renglones: 3,
        );
      }
      final lado = azar.entre(2, 8);
      late int alturaTriangulo;
      do {
        alturaTriangulo = azar.entre(2, 8);
      } while ((lado * alturaTriangulo).isOdd);
      return Ejercicio(
        enunciado: 'Un prisma tiene de base un triángulo de $lado cm de base y $alturaTriangulo cm '
            'de altura. El prisma mide $altura cm de alto. ¿Cuál es su volumen?',
        solucion: '${lado * alturaTriangulo ~/ 2 * altura} cm³',
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'GEO.12',
    descripcion:
        'Una pirámide o un cono ocupan un tercio del prisma o cilindro con la misma base y altura: '
        'V = área de la base · h : 3. Una esfera de radio r: V = 4/3 · π · r^{3}.\n'
        'Ejemplo: un cono de 3 cm de radio y 4 cm de altura tiene 3,14 · 3^{2} · 4 : 3 = 37,68 cm³.',
    preguntaExplicalo: '¿Cuántos conos llenos de agua necesitas para llenar un cilindro de la misma base y altura?',
    generar: (azar) {
      final tipo = azar.nextInt(3);
      if (tipo == 0) {
        final lado = azar.entre(2, 9);
        final altura = azar.entre(1, 5) * 3;
        return Ejercicio(
          enunciado: 'Una pirámide de base cuadrada tiene $lado cm de lado de base y $altura cm de '
              'altura. ¿Cuál es su volumen?',
          solucion: '${lado * lado * altura ~/ 3} cm³',
          renglones: 3,
        );
      }
      if (tipo == 1) {
        final radio = azar.entre(1, 5);
        final altura = azar.entre(1, 4) * 3;
        return Ejercicio(
          enunciado: 'Un cono tiene $radio cm de radio y $altura cm de altura. ¿Cuál es su volumen? (π ≈ 3,14)',
          solucion: '${formatearDecimal(3.14 * radio * radio * altura / 3, cifras: 2)} cm³',
          renglones: 3,
        );
      }
      final radio = azar.entre(1, 2) * 3;
      return Ejercicio(
        enunciado: 'Una pelota tiene forma de esfera de $radio cm de radio. ¿Cuál es su volumen? (π ≈ 3,14)',
        solucion: '${formatearDecimal(4 * 3.14 * radio * radio * radio / 3, cifras: 2)} cm³',
        renglones: 3,
      );
    },
  ),
  PlantillaFicha(
    idHabilidad: 'GEO.13',
    descripcion:
        'Pitágoras sirve en muchos problemas: la diagonal de una pantalla, la altura a la que '
        'llega una escalera apoyada… Busca el triángulo rectángulo escondido.\n'
        'Ejemplo: una escalera de 5 m con el pie a 3 m de la pared llega a √(25 − 9) = √16 = 4 m de altura.',
    preguntaExplicalo: '¿Cómo encuentras el triángulo rectángulo escondido en un problema? Pon un ejemplo.',
    generar: (azar) {
      final (a, b, c) = azar.elegir(_ternas);
      final tipo = azar.nextInt(3);
      if (tipo == 0) {
        return Ejercicio(
          enunciado: 'Una escalera de $c m se apoya en una pared. Su pie está a $a m de la pared. '
              '¿A qué altura llega la escalera?',
          solucion: '$b m',
          renglones: 4,
        );
      }
      if (tipo == 1) {
        return Ejercicio(
          enunciado: 'Un campo rectangular mide $a m por $b m. ¿Cuántos metros te ahorras al cruzarlo '
              'por la diagonal en vez de ir de una esquina a la opuesta por dos de sus bordes?',
          solucion: '${a + b - c} m',
          renglones: 4,
        );
      }
      return Ejercicio(
        enunciado: 'Una cometa está atada a un hilo tenso de $c m. La cometa está justo encima de un '
            'punto que queda a $b m de quien la sujeta. ¿A qué altura vuela (sin contar la altura de la persona)?',
        solucion: '$a m',
        renglones: 4,
      );
    },
  ),
];

/// Habilidades de MED/GEO que necesitan una figura dibujada.
const motivosSinPlantillaGeometria = {
  'GEO.07': 'la simetría necesita figuras dibujadas (v0.1 no dibuja)',
};
