# Referencias para la memoria de la subvención

Pregunta de Zunbeltz (2026-10-06): *en qué apps nos hemos basado o fijado para el desarrollo, para poder nombrarlas en la memoria*. Datos comprobados el 2026-10-06 en las webs y tiendas de cada producto (enlaces abajo).

## 1. Base propia: ecosistema Solera

La app es una pieza de **Solera**, la familia de herramientas de gestión agraria de la Colección Nuevo Ser, y reutiliza su base común (funcionamiento sin cobertura, mapas, fotos, informes PDF, sincronización):

- **Solera** (gestión de fincas agrícolas, cuaderno de explotación).
- **Solera Viticultura**, **Solera Apícola**, **Solera Quesera**, **Solera Aceitera** (verticales por sector, con su cuaderno y sus libros oficiales).
- **Solera Arbolado Urbano** (inventario y mantenimiento para ayuntamientos).

Solera Zunbeltz es la primera pensada para un **espacio test**: varias personas, roles y el seguimiento de cada proyecto.

## 2. Referencias externas, por lo que aportan

| Referencia | Qué es | En qué nos hemos fijado | Dónde se nota en la app |
|---|---|---|---|
| **VacApp** (vacapp.net) | Cuaderno de vacuno extensivo, sin conexión | Registro del ganado en el monte sin cobertura | Planteamiento *offline* de toda la app; cuaderno ganadero futuro |
| **Herdwatch** (Irlanda/Reino Unido) | Gestión de vacuno y ovino, +20.000 explotaciones | Lectura de crotales y registros sanitarios; vacuno y ovino en la misma herramienta | Cuaderno ganadero futuro (escáner del DIB) |
| **Agroptima** (España) | Cuaderno de campo y gestión de explotaciones | Mapa de parcelas, partes de trabajo sin cobertura, costes por finca | Fincas, zonas y tareas; costes por proyecto |
| **farmOS** (código abierto) | Plataforma abierta de gestión de explotaciones | «Activos» (animales, parcelas, equipos) con sus registros, mapa y tareas pendientes/atrasadas | Puntos de infraestructura con sus tareas; tareas vencidas y próximas |
| **Línea Verde** (+600 municipios) | App de incidencias ciudadanas geolocalizadas | Avisar de un problema con foto y ubicación, que llega a quien lo resuelve | Avisos de campo y peticiones de tarea |
| **FixMyStreet** (mySociety, código abierto) | Plataforma de avisos de problemas al ayuntamiento | Aviso sobre el mapa → responsable → seguimiento hasta resolverlo | Peticiones que coordinación convierte en tarea o descarta |
| **Bandomóvil** | Avisos del ayuntamiento al vecindario | Noticias y avisos al momento + canal «¡Comunica!» de vuelta | Bandeja Hoy con noticias y alarmas; notificaciones |
| **UpKeep** (GMAO móvil) | Mantenimiento de instalaciones y órdenes de trabajo | Tareas asignables, mantenimiento preventivo periódico, avisos | Tareas de mantenimiento periódicas, asignación, tablero |
| **QField** (QGIS, código abierto) | Captura de datos sobre mapa sin cobertura y sincronización | Trabajar en el campo sin señal y fusionar al volver | Mapa de fincas sin cobertura + sincronización |
| **KoBoToolbox / ODK** (código abierto) | Recogida de datos en campo sin conexión, +14.000 organizaciones | Guardar todo en el móvil y subir al tener cobertura sin perder nada | Motor de sincronización |
| **Open Food Network / Katuma** (código abierto, cooperativo) | Venta directa y grupos de consumo | Canales cortos de comercialización | Registro de ventas por canal; módulo de comercialización |

## 3. Método (no es una app)

- **Guía metodológica del Grupo Operativo RETA** (Red de Espacios Test Agrarios, EIP-AGRI): marco del seguimiento de un test agrario. Junto con el **convenio tester de Zunbeltz** (anexo IV, indicadores), define qué se registra en la pantalla «Convenio».
- **RENETA** (red francesa de espacios test): experiencia de referencia de la red estatal.

## 4. Pendiente

- La **«App de Andia»** que mencionó Elena (cuatro categorías de avisos con iconos) es **Línea Verde** (confirmado el 2026-10-07). Revisar sus categorías con capturas para ajustar las nuestras (`lib/modelos/aviso_campo.dart`, BLOQUEOS 27).

## Fuentes

- VacApp: https://vacapp.net/ · https://snapcraft.io/install/vacapp/ubuntu
- Herdwatch: https://herdwatch.com/our-story · https://herdwatch.com/en-uk/solutions
- Agroptima: https://apps.apple.com/es/app/agroptima-software-agr%C3%ADcola/id929585869
- farmOS: https://farmos.org/guide · https://v1.farmos.org/guide/assets/
- Línea Verde: https://www.noticiasdenavarra.com/navarra/2025/03/06/corella-une-linea-verde-recibir-9364145.html
- FixMyStreet: https://fixmystreet.org/overview/ · https://www.mysociety.org/community/fixmystreet/
- Bandomóvil: https://apps.apple.com/es/app/bandomovil/id1049832681
- UpKeep: https://upkeep.com/overview/
- QField: https://gisgeography.com/qfield/
- KoBoToolbox: https://kobotoolbox.org/about-us/software
- Open Food Network / Katuma: https://zenodo.org/records/17954554 · https://www.meetup.com/barcelona-free-software/events/245608438/
- GO RETA: https://eu-cap-network.ec.europa.eu/projects/operational-group-reta-network-farm-incubators_fr · https://eu-cap-network.ec.europa.eu/sites/default/files/2023-06/gp_es_og_reta_632_web_fin.pdf
