# Política de privacidad — El Cuaderno

> **BORRADOR — pendiente de revisión legal LOPDGDD.**
> Este documento NO es la política definitiva. Es la formulación honesta
> que el equipo de desarrollo deriva de los principios de la biblia
> (§2.1 privacidad estructural, §2.9 sin extracción), redactada para que
> una asesoría legal especializada en LOPDGDD para menores la convierta
> en texto vinculante antes del piloto público.
>
> Versión: 0.1 — 2026-04-30.

---

## 1. Quién publica El Cuaderno

El Cuaderno es un juego digital pedagógico publicado por **Colección
Nuevo Ser Kids**, la línea infantil/escolar de la **Colección Nuevo
Ser** ([coleccion-nuevo-ser.gailu.net](https://coleccion-nuevo-ser.gailu.net/)). El
código fuente está bajo licencia **AGPL-3.0** y los contenidos
pedagógicos bajo **CC-BY-SA 4.0**. Cualquiera puede auditar tanto el
código como el contenido.

## 2. Qué datos NO recoge El Cuaderno

Este apartado es estructural, no negociable. La biblia §2.1 lo
describe como "privacidad por diseño": el código fuente está escrito de
forma que muchas categorías de datos **no pueden salir** del
dispositivo, no porque se prometa no usarlas, sino porque no existen
los caminos técnicos para sacarlas. Cualquiera puede verificarlo
leyendo el código.

El Cuaderno **no recoge ni envía a ningún servidor**:

- El **texto libre** que el niño escribe en sus observaciones, en sus
  preguntas al Tutor, en sus respuestas a Misterios, ni en ningún otro
  campo de texto.
- Las **fotos y dibujos** que el niño guarda asociados a una observación.
- Las **coordenadas geográficas precisas** del sit spot ni de las
  observaciones. Solo se deriva localmente un código de región
  administrativa (NUTS-3, p. ej. `ES-NA`) que el adulto puede vetar.
- El **nombre real, apellidos, fecha de nacimiento, edad**, dirección
  postal, número de teléfono, ni ningún otro identificador civil.
- **Identificadores publicitarios** (Google Advertising ID, IDFA,
  cualquier equivalente). El Cuaderno no los lee.
- **Ubicación en tiempo real**, **agenda de contactos**, **cámara o
  micrófono** salvo cuando el niño explícitamente añade una foto o un
  dibujo a una observación.
- Datos para **publicidad, perfilado comportamental, retargeting o
  venta a terceros**. El Cuaderno no integra ningún SDK de tracking,
  analytics comerciales o redes publicitarias.

## 3. Qué datos SÍ se procesan localmente

En el dispositivo del niño se guardan, **cifrados en reposo** mediante
Isar Community con clave generada al primer arranque y custodiada por
el sistema operativo:

- Las **observaciones** del cuaderno (qué viste, crees que es, foto y
  dibujo si los hay, fecha, sit spot al que están ancladas).
- Los **Misterios** que el niño ha abierto y a los que ha anclado
  observaciones.
- El **sit spot** elegido (nombre del niño, descripción del lugar). La
  posición geográfica precisa NO se guarda; lo que se guarda es la
  descripción textual que el niño dio.
- El **nombre que el niño eligió** al primer arranque (no es nombre
  real obligatorio — puede ser un apodo o el primer nombre).
- El **idioma del juego** que se eligió.
- Las **preferencias** del juego (sonido, accesibilidad).

Todo lo anterior **vive solo en el dispositivo**. Si el niño desinstala
la app o borra el cuaderno desde Ajustes, todo se elimina. Si cambia de
dispositivo sin sincronización opt-in (ver §5), los datos no viajan.

## 4. Qué datos se procesan en el servidor

El servidor solo recibe datos cuando **el adulto** explícitamente activa
la sincronización (ver §5). Los datos enviados son:

- **Metadatos agregados de actividad semanal**: cuántas observaciones
  hizo el niño esa semana, repartidas por nivel de confianza (consenso
  / hipótesis activa / no segura) y por Misterio. **NUNCA** el texto de
  las observaciones, NUNCA fotos ni dibujos.
- **Hashes** de tokens de identificación de Misterios para emparejar
  con el catálogo en el servidor. Los hashes son irreversibles — el
  servidor no puede recuperar el texto que el niño escribió.
- **Código de región administrativa** (NUTS-3, p. ej. `ES-NA`,
  `ES-MD`). Una región alberga normalmente decenas de miles de
  habitantes; identifica la región del usuario, no a la persona.
- **Token de autenticación** (JWT) que vincula la app al servidor
  mientras la sesión está activa. El JWT contiene el identificador
  interno del niño en el servidor, no su nombre civil.

El servidor procesa esos agregados con un modelo de IA (Claude Haiku
de Anthropic) para generar el resumen semanal cualitativo de la vista
del cuidador (un párrafo corto + una pregunta para la cena). Los
agregados nunca se utilizan para crear un perfil persistente del niño
ni para entrenar el modelo de IA: el contrato con Anthropic excluye
explícitamente el uso de datos para entrenamiento (zero data
retention).

## 5. Sincronización opt-in

La sincronización con el servidor está **desactivada por defecto**.
Para activarla hace falta:

1. Que un **adulto** abra Ajustes → "Cuenta del adulto" e introduzca
   email + contraseña de una cuenta previamente creada en el portal web
   de Colección Nuevo Ser Kids. La app **no permite crear cuentas
   nuevas desde el cliente** — esto evita que el niño abra una cuenta
   por su cuenta sin que un adulto lo sepa.
2. Que el adulto pulse explícitamente "Subir ahora" en cada uno de los
   tres bloques opt-in: "Sincronizar mis observaciones", "Compartir
   resumen con el adulto", "Tutor IA real".
3. La app **nunca sincroniza en background**, **nunca envía
   notificaciones push**, **nunca solicita permiso para ejecutarse
   cuando el niño no la está usando**.

Si el adulto cierra sesión desde Ajustes, el token se borra del
dispositivo y la app vuelve al modo offline-first sin afectar a las
observaciones del niño.

## 6. El Tutor IA

El Tutor IA usa Claude Haiku de Anthropic. Cuando está activado:

- Cada conversación es **independiente** — el Tutor **no tiene memoria
  entre conversaciones**. Lo que el niño le contó ayer no influye en lo
  que el Tutor responde hoy.
- Las preguntas del niño se envían al servidor **filtradas por una
  lista negra** que detecta y bloquea contenido de daño, suicidio,
  autolesión, violencia y otros tópicos sensibles antes de que la
  pregunta llegue al modelo de IA.
- Las respuestas del Tutor también pasan por el mismo filtro antes de
  llegar al niño.
- El Tutor tiene una **cuota diaria** (30 turnos/día) que evita uso
  obsesivo y limita el coste si el niño deja la app abierta sin querer.
- El contrato con Anthropic incluye **zero data retention**: las
  preguntas del niño no se guardan en sus servidores y no se usan para
  entrenar futuros modelos.

## 7. Aulas y vista del cuidador

Cuando el niño se une a un aula con un código que le da su profesor,
el **aula nunca ve las observaciones individuales** del niño. Lo único
que se comparte con el aula es la **agregación con k≥5**: una métrica
solo aparece en el dashboard del profesor si al menos 5 niños la
contribuyen, lo que impide identificar a un niño concreto.

La vista del cuidador (madre, padre, tutor legal del niño) es una
página discreta que muestra **solo un párrafo cualitativo** generado
por la IA + **una pregunta para la cena**. Nunca acceso al cuaderno.
Nunca lectura de las observaciones del niño.

## 8. Edad mínima y consentimiento

El Cuaderno está diseñado para niños de **9 a 13 años**. Conforme a la
LOPDGDD para menores, la edad mínima de consentimiento autónomo en
España es **14 años**. Por debajo de esa edad, el consentimiento para
el tratamiento de datos personales **lo da el titular de la patria
potestad o tutela**.

En la práctica, esto significa que:

- El **niño** puede usar el cuaderno offline sin más, ya que en modo
  offline no hay tratamiento de datos en el sentido del RGPD —
  todo vive en su dispositivo.
- La **sincronización opt-in con el servidor** requiere que un adulto
  haya creado previamente una cuenta y haya introducido las
  credenciales en Ajustes. Esa cuenta — creada en el portal web de
  Colección Nuevo Ser Kids con un proceso explícito de aceptación de
  la política y con verificación de la patria potestad — es el
  consentimiento del adulto.

> **Pendiente de revisión legal LOPDGDD**: el portal web de creación
> de cuenta y su flujo de verificación de la patria potestad NO están
> especificados en este borrador. La asesoría legal indicará qué
> formato de verificación se considera suficiente bajo la LOPDGDD y la
> jurisprudencia AEPD vigente.

## 9. Derechos del niño y del adulto

Bajo el RGPD y la LOPDGDD, el niño y el adulto que ejerce la patria
potestad pueden ejercer en cualquier momento:

- **Acceso**: ver qué datos hay en el servidor (los del niño en
  cuestión, identificados por el JWT de la cuenta del adulto).
- **Rectificación**: corregir datos inexactos.
- **Supresión** ("derecho al olvido"): borrar todos los datos del niño
  del servidor. Desde la app, el botón "Borrar mi cuaderno" en Ajustes
  borra el dispositivo. La supresión del servidor se hace desde el
  portal web del adulto. Tras la supresión, los datos desaparecen
  irreversiblemente.
- **Portabilidad**: exportar el cuaderno como archivo legible (JSON
  hoy, PDF cuando esté implementado) directamente desde la app
  ("Exportar mi cuaderno" en Ajustes), sin pasar por el servidor.
- **Oposición** y **limitación del tratamiento**: cerrar sesión del
  adulto en Ajustes detiene cualquier nuevo envío al servidor. Lo que
  ya esté en el servidor sigue ahí hasta que se ejerza supresión.

## 10. Conservación

- En el dispositivo: hasta que el niño o el adulto borren el cuaderno
  o desinstalen la app.
- En el servidor: los **agregados semanales** se conservan hasta que
  se ejerza supresión o hasta que pasen **24 meses** desde la última
  actividad de la cuenta, lo que ocurra primero. Tras ese plazo se
  eliminan automáticamente.

## 11. Cambios en esta política

Cualquier cambio sustantivo se anuncia en el portal web de Colección
Nuevo Ser Kids y, antes de que entre en vigor, los adultos vinculados
reciben una notificación por email. Los niños que solo usan la app en
modo offline no reciben notificación porque no hay con qué
notificarles, lo cual es coherente con el principio de no extracción.

## 12. Contacto

Para ejercer cualquiera de los derechos del §9, escribir al **email de
contacto del responsable del tratamiento** (pendiente de definir tras
revisión legal).

---

> **Recordatorio**: este es un BORRADOR. La asesoría legal LOPDGDD
> debe revisar y, si procede, reescribir cada apartado para que el
> documento sea jurídicamente vinculante en territorio español y
> compatible con el RGPD europeo. Hasta que esa revisión llegue, el
> piloto solo se ofrece a familias del operador con consentimiento
> verbal, no se publica abiertamente ni se sube a tiendas de apps.
