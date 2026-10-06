#!/usr/bin/env bash
# Prueba del panel de coordinación contra el WordPress local, como lo usaría
# la oficina (formularios con su nonce), y de que lo hecho allí llega a la
# app de la persona tester. Requiere ./preparar.sh y ./probar_sync.sh antes
# (para que haya fincas en el servidor).
set -euo pipefail
cd "$(dirname "$0")"
source .tokens
url="http://localhost:8790"
api="$url/wp-json/solera-zunbeltz/v1"
galletas="$(mktemp)"
trap 'rm -f "$galletas"' EXIT
fallos=0
comprobar() {
  if [ "$2" == "$3" ]; then echo "ok    $1"; else echo "FALLO $1 (esperado: $2, real: $3)"; fallos=$((fallos + 1)); fi
}
wp() { docker compose run --rm -T cli "$@" 2>/dev/null; }

# Sesión de administrador.
curl -s -c "$galletas" -b "$galletas" -o /dev/null "$url/wp-login.php"
curl -s -c "$galletas" -b "$galletas" -o /dev/null -H "Cookie: wordpress_test_cookie=WP%20Cookie%20check" \
  --data-urlencode "log=admin" --data-urlencode "pwd=$(cat .admin)" -d "wp-submit=Entrar&testcookie=1" "$url/wp-login.php"
pagina() { curl -s -b "$galletas" "$url/wp-admin/admin.php?page=$1"; }
nonce() { pagina "$1" | grep -o 'name="_wpnonce" value="[^"]*"' | head -1 | sed 's/.*value="//;s/"//'; }
enviar() { local destino="$1"; shift; curl -s -b "$galletas" "$url/wp-admin/admin.php?page=$destino" "$@"; }

sufijo="$(date +%s%N)"
tester_uid="$(curl -sf "$api/yo" -H "X-Zunbeltz-Token: $TESTER" | jq -r .yo.uid)"
finca_uid="$(wp eval 'foreach ( szs_listar_entidades_tipo( "finca" ) as $f ) { echo $f["uid"]; break; }')"
[ -n "$finca_uid" ] || { echo "No hay fincas en el servidor: ejecuta antes ./probar_sync.sh"; exit 1; }

# 1. Tarea periódica creada en la oficina para la tester.
n="$(nonce "solera-zunbeltz&vista=formulario")"
enviar solera-zunbeltz -o /dev/null --data-urlencode "_wpnonce=$n" -d "szs_accion=guardar&szs_uid=&szs_peticion_uid=" \
  --data-urlencode "szs_titulo=Rellenar comedero $sufijo" -d "szs_finca_uid=$finca_uid&szs_responsable_uid=$tester_uid&szs_prioridad=alta&szs_estado=pendiente&szs_fecha=2026-01-15&szs_recurrencia_dias=7&szs_coste="
r="$(curl -sf "$api/sync" -H "X-Zunbeltz-Token: $TESTER" -H 'content-type: application/json' -d '{}')"
uid_tarea="$(echo "$r" | jq -r --arg t "Rellenar comedero $sufijo" '[.tareas[] | select(.titulo==$t)][0].uid')"
comprobar "la tester recibe la tarea creada en la oficina" "true" "$( [ "$uid_tarea" != "null" ] && echo true || echo false)"
comprobar "… asignada a ella" "$tester_uid" "$(echo "$r" | jq -r --arg u "$uid_tarea" '.tareas[] | select(.uid==$u) | .responsable_uid')"

# 2. La oficina la marca hecha: nace la siguiente (periódica).
n="$(nonce solera-zunbeltz)"
enviar solera-zunbeltz -o /dev/null --data-urlencode "_wpnonce=$n" -d "szs_accion=cambiar_estado&szs_uid=$uid_tarea&szs_estado=hecha"
r="$(curl -sf "$api/sync" -H "X-Zunbeltz-Token: $TESTER" -H 'content-type: application/json' -d '{}')"
comprobar "al cerrarla nace la siguiente instancia" "2" "$(echo "$r" | jq --arg t "Rellenar comedero $sufijo" '[.tareas[] | select(.titulo==$t)] | length')"
comprobar "… pendiente" "pendiente" "$(echo "$r" | jq -r --arg t "Rellenar comedero $sufijo" '[.tareas[] | select(.titulo==$t and .estado=="pendiente")][0].estado')"

# 3. La tester pide una tarea urgente; la oficina la convierte en tarea.
ms="$(date +%s)000"
curl -sf "$api/sync" -H "X-Zunbeltz-Token: $TESTER" -H 'content-type: application/json' -d "$(jq -n --arg s "$sufijo" --arg f "$finca_uid" --argjson ms "$ms" \
  '{entidades:[{tipo:"peticion", uid:("pe"+$s), actualizado_ms:$ms, datos:{titulo:("Falta pienso "+$s), urgente:1, estado:"pendiente", finca_uid:$f, fecha_creacion_ms:$ms}}]}')" >/dev/null
peticiones="$(pagina solera-zunbeltz-peticiones)"
comprobar "la petición aparece en la oficina" "1" "$(grep -c "Falta pienso $sufijo" <<<"$peticiones")"
n="$(nonce "solera-zunbeltz&vista=formulario&peticion=pe$sufijo")"
enviar solera-zunbeltz -o /dev/null --data-urlencode "_wpnonce=$n" -d "szs_accion=guardar&szs_uid=&szs_peticion_uid=pe$sufijo" \
  --data-urlencode "szs_titulo=Comprar pienso $sufijo" -d "szs_finca_uid=$finca_uid&szs_responsable_uid=&szs_prioridad=alta&szs_estado=pendiente&szs_fecha=&szs_recurrencia_dias=&szs_coste="
r="$(curl -sf "$api/sync" -H "X-Zunbeltz-Token: $TESTER" -H 'content-type: application/json' -d '{"desde_revision": 0}')"
comprobar "la petición queda aceptada" "aceptada" "$(echo "$r" | jq -r --arg u "pe$sufijo" '.entidades[] | select(.uid==$u) | .datos.estado')"
comprobar "… enlazada a la tarea creada" "$(echo "$r" | jq -r --arg t "Comprar pienso $sufijo" '.tareas[] | select(.titulo==$t) | .uid')" "$(echo "$r" | jq -r --arg u "pe$sufijo" '.entidades[] | select(.uid==$u) | .datos.tarea_uid')"
comprobar "la tarea general (sin responsable) le llega a la tester" "1" "$(echo "$r" | jq --arg t "Comprar pienso $sufijo" '[.tareas[] | select(.titulo==$t)] | length')"

# 4. Noticia publicada en la oficina.
n="$(nonce solera-zunbeltz-avisos)"
enviar solera-zunbeltz-avisos -o /dev/null --data-urlencode "_wpnonce=$n" -d "szs_accion=publicar&szs_categoria=noticias" --data-urlencode "szs_titulo=Feria $sufijo" -d "szs_descripcion=Inscripción abierta"
r="$(curl -sf "$api/sync" -H "X-Zunbeltz-Token: $TESTER" -H 'content-type: application/json' -d '{"desde_revision": 0}')"
comprobar "la noticia llega a la tester" "noticias" "$(echo "$r" | jq -r --arg t "Feria $sufijo" '.entidades[] | select(.tipo=="aviso" and .datos.titulo==$t) | .datos.categoria')"

# 5. Actividad con origen oficina y correo diario (con una tarea vencida).
n="$(nonce "solera-zunbeltz&vista=formulario")"
enviar solera-zunbeltz -o /dev/null --data-urlencode "_wpnonce=$n" -d "szs_accion=guardar&szs_uid=&szs_peticion_uid=" \
  --data-urlencode "szs_titulo=Revisar cierre $sufijo" -d "szs_finca_uid=$finca_uid&szs_responsable_uid=&szs_prioridad=media&szs_estado=pendiente&szs_fecha=2026-01-15&szs_recurrencia_dias=&szs_coste="
actividad="$(pagina solera-zunbeltz-actividad)"
comprobar "la actividad registra lo hecho en la oficina" "true" "$(grep -q "Rellenar comedero $sufijo» como «Hecha»" <<<"$actividad" && echo true || echo false)"
correo="$(wp eval '
  global $szs_correo_capturado;
  add_filter( "pre_wp_mail", function ( $nulo, $atributos ) { global $szs_correo_capturado; $szs_correo_capturado = $atributos; return true; }, 10, 2 );
  global $wpdb; $wpdb->query( $wpdb->prepare( "UPDATE {$wpdb->prefix}solera_zunbeltz_personas SET correo = %s WHERE rol = %s", "oficina@zunbeltz.test", "coordinador" ) );
  szs_enviar_correo_diario();
  echo $szs_correo_capturado["subject"] ?? "sin correo";
')"
comprobar "el correo diario avisa de la tarea vencida" "true" "$(echo "$correo" | grep -q 'vencida' && echo true || echo false)"
echo "Asunto del correo: $correo"

if [ "$fallos" -gt 0 ]; then echo "$fallos fallo(s)"; exit 1; fi
echo "Prueba del panel superada."
