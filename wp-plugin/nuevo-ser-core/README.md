# Nuevo Ser Core (plugin WordPress)

Backend compartido de **Colección Nuevo Ser Kids**: sync, autenticación y tutor IA para Uno Roto y futuros juegos de la línea (Las Versiones, El Cuaderno…).

> Este plugin sustituye a `uno-roto-core`. El header declara `Replaces: uno-roto-core` y la activación desactiva automáticamente el plugin viejo si todavía está activo en la instalación.

## Estado

v0.5 — refactor en curso. Chunks 2-3 del plan: rename de `uno-roto-core` → `nuevo-ser-core` con prefijo `NS_*` (C2) y endpoints duales `/uno-roto/v1/*` (alias deprecado) ↔ `/nuevo-ser/v1/*` (canónico) (C3). Tablas y nombre de la opción `uroto_core_version` se mantienen sin cambio (se renombran en C4).

## Instalación

1. Copia el directorio `nuevo-ser-core/` a `wp-content/plugins/` de tu WordPress.
2. En `wp-config.php`, define los secretos antes de activar:
   ```php
   define( 'NS_JWT_SECRET', 'cadena-aleatoria-64-chars-o-más' );
   define( 'NS_ANTHROPIC_KEY', 'sk-ant-...' );  // opcional, solo para tutor IA
   ```
   Generar JWT secret: `openssl rand -hex 32`.

   **Backward compat**: si tu wp-config.php ya define `UROTO_JWT_SECRET` o `UROTO_ANTHROPIC_KEY` (del plugin antiguo), el nuevo plugin las promueve automáticamente — no hace falta editar wp-config.php al actualizar.

3. Activa desde el panel. Si el plugin viejo `uno-roto-core` estaba activo, se desactivará automáticamente. Las tablas se crean idempotentes vía `dbDelta`.
4. Verifica endpoints (canónico):
   ```
   curl https://tu-wp.example.org/wp-json/nuevo-ser/v1/login -I
   ```
   El alias deprecado `/wp-json/uno-roto/v1/login` también responde — devuelve el header `Deprecation: true` y un `Link: <…>; rel="successor-version"` apuntando al canónico, pero el cuerpo de la respuesta es idéntico. Vivirá hasta v1.5 para no romper APKs de testers desplegados.
5. **Juegos web** (v0.19+): en *Nuevo Ser Core → Juegos web*, «Instalar» descarga de GitHub Releases el build web del juego (tag `web-<juego>-<versión>`, zip + `.sha256`), lo comprueba y lo coloca en `wp-content/uploads/juegos/<juego>/`; «Crear /jugar/» crea la página con `[uno_roto]` y la plantilla *Página del juego* del tema Uno Roto. El build se publica desde el monorepo con `bash scripts/web/publicar_web.sh <juego>`. Requiere la extensión PHP `zip`.

## Tablas creadas

Todas con prefijo `{$wpdb->prefix}uroto_` (renombrado a `wp_ns_*` en C4 con migración aditiva):

- `uroto_usuarios` — tutor legal (email, password_hash, nombre, locale).
- `uroto_ninos` — perfiles de niño vinculados a un tutor.
- `uroto_progreso` — estado global del niño (esquirlas, rango, nombre_jugador, flags JSON, arco_actual).
- `uroto_estado_habilidades` — fila por (niño, habilidad) con nivel, precisión, tiempo_mediano, etc.
- `uroto_cache_tutor` — caché de respuestas del tutor IA (clave_hash, id_habilidad, pregunta, respuesta, creado_en, usos). Compartida entre niños — no hay PII.
- `uroto_password_reset` — tokens de reset de password con expiración.

## Endpoints REST

Todos bajo `/wp-json/nuevo-ser/v1/` (canónico). El alias `/wp-json/uno-roto/v1/*` sigue activo para clientes desplegados; sus respuestas llevan `Deprecation: true` y `Link: …; rel="successor-version"` apuntando al canónico.

### Públicos

**POST `/register`**
```json
{ "email": "padre@example.org", "password": "minimo8chars",
  "nombre_tutor": "Josu", "nombre_nino": "Leo", "locale": "es" }
```
→ 201 `{ "token": "...", "nino_id": 42, "usuario_id": 7 }`

**POST `/login`**
```json
{ "email": "padre@example.org", "password": "minimo8chars" }
```
→ 200 `{ "token": "...", "nino_id": 42 }`

### Protegidos (header `Authorization: Bearer <token>`)

**GET `/progress`**
→ 200 `{ "progreso": {...}, "habilidades": [...] }`

**POST `/sync/progress`**
```json
{
  "progreso": { "nombre_jugador": "Leo", "esquirlas_total": 30,
                "rango": 1, "arco_actual": 1, "flags": {...},
                "actualizado_en": "2026-04-21 14:23:00" },
  "habilidades": [ { "id_habilidad": "FR.01", "nivel": 3, ... } ]
}
```
→ 200 con el estado final tras el merge LWW por registro.

**DELETE `/account`**
Borra todos los datos (niño, progreso, habilidades, usuario) asociados al JWT.
→ 200 `{ "ok": true }`

**GET `/tutor/stats`** (solo admin WordPress, no JWT — `manage_options`)
→ 200 `{ "total_entradas": N, "total_usos": N, "habilidades_distintas": N, "mas_preguntadas": [...] }`
→ 403 sin sesión WP de admin.

**POST `/tutor/explicar`**
```json
{ "id_habilidad": "FR.05",
  "pregunta": "no entiendo",
  "contexto_fragmento": "3/5 vs 4/5"  // opcional
}
```
→ 200 `{ "explicacion": "...", "fuente": "cache" | "llm" }`
→ 422 `{ "error": "..." }` si el filtro PHP rechaza (PII, fuera de alcance, inyección).
→ 502 si Anthropic falla o `NS_ANTHROPIC_KEY` no está definida.

Doble capa de seguridad: el cliente Flutter filtra antes de enviar y el plugin filtra de nuevo. Las reglas son idénticas (`includes/class-ns-filtro-tutor.php` ↔ `apps/uno-roto/lib/dominio/tutor/filtro_seguridad.dart`).

## Convenciones de nombres tras el refactor

| Categoría | Antes | Después | Notas |
|---|---|---|---|
| Carpeta plugin | `uno-roto-core/` | `nuevo-ser-core/` | C2 |
| Archivo principal | `uno-roto-core.php` | `nuevo-ser-core.php` | C2 |
| Clases PHP | `UROTO_JWT`, `UROTO_Tutor`… | `NS_JWT`, `NS_Tutor`… | C2 |
| Constantes PHP | `UROTO_CORE_VERSION`, `UROTO_JWT_SECRET`… | `NS_CORE_VERSION`, `NS_JWT_SECRET`… | C2 (con fallback) |
| Text domain | `uno-roto-core` | `nuevo-ser-core` | C2 |
| Endpoints REST | `/wp-json/uno-roto/v1/*` | `/wp-json/nuevo-ser/v1/*` (canónico) + alias deprecado | C3 ✓ |
| Prefijo tablas | `wp_uroto_*` | `wp_ns_*` | C4 (con migración aditiva + `game_id`) |
| `wp_options` key | `uroto_core_version` | sin cambio en C2 | renombrado posible en C4 |
| Cron hook | `uroto_cron_purga_tutor` | sin cambio en C2 | mantiene scheduling existente |

## Privacidad

- Sin tracking. Sin analytics.
- Passwords con `password_hash` (bcrypt por defecto en PHP ≥ 7.4).
- JWT HS256 con secreto en `NS_JWT_SECRET`.
- HTTPS obligatorio — configuración de hosting, no se valida en código.
- Borrado GDPR completo vía `DELETE /account`.

## BORRADOR pendiente de validación legal

- **`NS_Caregivers` (`/caregivers/*`) es POC** marcado con
  `consent_method = 'magic_link_borrador'` literal en cada fila
  de `ns_caregiver_links`. Cualquier consumidor puede detectar el
  modo POC por esa string.
- **Antes de activar en producción se requiere**:
  1. Asesoría LOPDGDD para menores. La AEPD aplica criterios
     reforzados; magic link puede no bastar.
  2. Texto humano del email de invitación (voz amable, sin
     diminutivos, sin alarmar — test §2.3 doc 04 El Cuaderno).
  3. Mecanismo real de envío de email — hoy el `request`
     devuelve el token directamente en la respuesta para
     test manual.
  4. Decidir si el progenitor inicia el vínculo desde la app
     del niño (con su JWT, como hoy) o desde una pantalla
     dedicada con su propia cuenta WP.
- Tracker: memoria personal del operador
  `project_el_cuaderno_decisiones_humanas_pendientes` ítem 5.

## Módulo "ciencia ciudadana" de la app Fósiles (v0.16+)

Añadido en `v0.16.0`. Permite que aficionados envíen fotos de hallazgos a una cola de moderación; un curador (geólogo/paleontólogo) las aprueba y aparecen dentro de la app, asociadas a la formación geológica catalogada (estilo "Wikipedia"). Diseño completo en el plan `~/.claude/plans/magical-tumbling-thunder.md`.

### Tablas

- `wp_ns_fosiles_aportaciones` — cola: foto + datos declarados + contacto (email + nombre opcional) + estado (`pendiente`/`aprobada`/`rechazada`/`archivada`) + campos curados.
- `wp_ns_fosiles_fotos_blob` — archivo binario en `wp-content/uploads/fosiles-comunidad/YYYY/MM/<sha256>.<ext>`; UNIQUE por `sha256` para deduplicar.
- `wp_ns_fosiles_formaciones_catalogadas` — catálogo de formaciones que el curador puede asociar a una aportación. Espejo manual de `apps/fosiles/lib/datos/formacion_a_fosiles.dart`.
- `wp_ns_fosiles_borrados_rgpd` — tokens de un solo uso (24h) emitidos al solicitar borrado por email.

### Roles

- `nuevoser_curador_fosiles` — capability `nuevoser_fosiles_revisar`. Aprueba/rechaza/archiva.
- `nuevoser_admin_fosiles` — además `nuevoser_fosiles_gestionar_catalogo` y `nuevoser_fosiles_gestionar_curadores`. Mantiene el catálogo de formaciones.
- El rol `administrator` global de WP recibe automáticamente las tres capabilities al activar/actualizar el plugin.

### Endpoints

Bajo `/wp-json/nuevo-ser/v1/fosiles/*` (solo canónico).

**Públicos** (sin auth, rate-limit 5/día por token de dispositivo + 10/día por IP):

- `POST /fosiles/aportaciones` — multipart con `foto` + `datos` (JSON con `tipo`/`especie`/`edad`/`formacion`/`notas`/`email`/`nombre`/`token_dispositivo`/`consentimiento`). Devuelve `{id, estado:'pendiente'}` o `429` si rate-limit.
- `GET /fosiles/fotos-comunidad/por-formacion/{codigo}` — galería de fotos aprobadas. SIN email/nombre/coords.
- `POST /fosiles/aportaciones/borrar-mis-aportaciones` — body `{email}`. Envía email con enlace de un solo uso (24h).
- `GET /fosiles/aportaciones/confirmar-borrado?token={hex}` — borra todas las aportaciones (y blobs huérfanos) asociadas al email. Devuelve HTML simple.

**Curador** (sesión WP con `nuevoser_fosiles_revisar` o JWT `tipo='curador_fosiles'`/`'admin_fosiles'`):

- `GET /fosiles/aportaciones?estado=pendiente&pag=N`
- `GET /fosiles/aportaciones/{id}`
- `POST /fosiles/aportaciones/{id}/aprobar` — body `{formacion_catalogada_id, especie_curada, edad_curada, comentarios?}`. Envía email al aficionado.
- `POST /fosiles/aportaciones/{id}/rechazar` — body `{motivo}`. Envía email al aficionado.
- `POST /fosiles/aportaciones/{id}/archivar` — sin email. Para spam.

**Admin** (capability `nuevoser_fosiles_gestionar_catalogo`):

- `GET/POST /fosiles/formaciones-catalogadas`
- `PUT/DELETE /fosiles/formaciones-catalogadas/{id}` (DELETE = soft-delete via `activo=0`).

### Panel wp-admin

Submenú **Fósiles** con tres páginas:
- **Aportaciones** — lista paginada por estado, con thumbnail.
- **Revisar** — formulario con foto a tamaño completo, datos declarados, campos curados, selector de formación, botones aprobar/rechazar/archivar.
- **Catálogo** — CRUD de formaciones (solo admin).

Los curadores acceden con su cuenta WP en `/wp-login.php` y aterrizan en el panel.

### Privacidad / RGPD

- No se almacenan coordenadas precisas — la app NO las envía.
- Email/nombre/IP/token_dispositivo quedan solo en backend; nunca aparecen en respuestas públicas.
- Base legal: consentimiento explícito (RGPD art. 6.1.a) — checkbox obligatorio en la app antes de enviar.
- Derecho de supresión: endpoint de borrado por email + token de un solo uso.
- IP + token de dispositivo se usan solo para rate-limit. Documentar en política de privacidad antes de activar en producción.

### Antes de activar en producción se requiere

1. Al menos un curador real (geólogo / paleontólogo) dispuesto a moderar.
2. Política de privacidad y T&Cs revisados jurídicamente (presupuesto 200-500 €).
3. Configuración SMTP del servidor WP para que `wp_mail` salga (notificaciones de aprobación/rechazo + tokens RGPD).
4. Sembrar el catálogo `wp_ns_fosiles_formaciones_catalogadas` con las 25 formaciones de `apps/fosiles/lib/datos/formacion_a_fosiles.dart`.
5. Activar el feature flag en el cliente: `kFeatureComunidadHabilitada = true` en `apps/fosiles/lib/comunidad/feature_flag_comunidad.dart` + apuntar `urlBaseComunidad` a la instancia real.

## Licencia

GPL-2.0-or-later (compatible con AGPL-3.0 del repo).
