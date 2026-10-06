#!/usr/bin/env bash
# Prueba de punta a punta de POST /sync contra el WordPress local
# (docker compose up -d && ./preparar.sh antes). Crea datos con uids
# aleatorios, así que se puede repetir sin limpiar.
set -euo pipefail
cd "$(dirname "$0")"
source .tokens
url="http://localhost:8790/wp-json/solera-zunbeltz/v1"
fallos=0

sync() { curl -sf "$url/sync" -H "X-Zunbeltz-Token: $1" -H 'content-type: application/json' -d "$2"; }
comprobar() {
  if [ "$2" == "$3" ]; then echo "ok    $1"; else echo "FALLO $1 (esperado: $2, real: $3)"; fallos=$((fallos + 1)); fi
}

sufijo="$(date +%s%N)"
ahora="$(date +%s)000"
tester_uid="$(curl -sf "$url/yo" -H "X-Zunbeltz-Token: $TESTER" | jq -r .yo.uid)"
revision_inicial="$(sync "$COORDINACION" '{}' | jq .revision)"

# 1. Coordinación crea finca, punto, proyecto de la tester y una tarea anclada.
r="$(sync "$COORDINACION" "$(jq -n --arg s "$sufijo" --arg t "$tester_uid" --argjson ms "$ahora" '{
  entidades: [
    {tipo:"proyecto", uid:("p"+$s), actualizado_ms:$ms, datos:{nombre:"Quesería", persona_uid:$t, estado:"abierto"}},
    {tipo:"punto", uid:("pu"+$s), actualizado_ms:$ms, datos:{nombre:"Abrevadero", tipo:"abrevadero", finca_uid:("f"+$s), latitud:42.78, longitud:-1.94}},
    {tipo:"finca", uid:("f"+$s), actualizado_ms:$ms, datos:{nombre:("Zufía "+$s)}}
  ],
  tareas: [{uid:("t"+$s), finca_nombre:("Zufía "+$s), finca_uid:("f"+$s), punto_uid:("pu"+$s), titulo:"Limpiar abrevadero", responsable_uid:$t, actualizado_ms:$ms, fecha_creacion_ms:$ms}]
}')")"
comprobar "coordinación: nada rechazado" "0" "$(echo "$r" | jq '.rechazos_entidades | length')"
comprobar "la revisión avanza" "true" "$(echo "$r" | jq --argjson r0 "$revision_inicial" '.revision > $r0')"
comprobar "la tarea guarda su anclaje al punto" "pu$sufijo" "$(echo "$r" | jq -r --arg u "t$sufijo" '.tareas[] | select(.uid==$u) | .punto_uid')"

# 2. La tester baja lo nuevo.
r="$(sync "$TESTER" "{\"desde_revision\": $revision_inicial}")"
comprobar "tester recibe la finca" "1" "$(echo "$r" | jq --arg u "f$sufijo" '[.entidades[] | select(.uid==$u)] | length')"
comprobar "tester recibe su proyecto" "1" "$(echo "$r" | jq --arg u "p$sufijo" '[.entidades[] | select(.uid==$u)] | length')"
comprobar "tester recibe su tarea" "1" "$(echo "$r" | jq --arg u "t$sufijo" '[.tareas[] | select(.uid==$u)] | length')"
comprobar "tester no recibe actividad" "0" "$(echo "$r" | jq '.actividad | length')"

# 3. La tester apunta un gasto, mueve el punto e intenta crear una finca.
r="$(sync "$TESTER" "$(jq -n --arg s "$sufijo" --argjson ms "$((ahora + 1000))" '{
  entidades: [
    {tipo:"apunte", uid:("a"+$s), proyecto_uid:("p"+$s), actualizado_ms:$ms, datos:{concepto:"Cencerro", importe_centimos:1500, tipo:"gasto"}},
    {tipo:"punto", uid:("pu"+$s), actualizado_ms:$ms, datos:{nombre:"Abrevadero", tipo:"abrevadero", finca_uid:("f"+$s), latitud:42.79, longitud:-1.95}},
    {tipo:"finca", uid:("fx"+$s), actualizado_ms:$ms, datos:{nombre:"Inventada"}}
  ]
}')")"
comprobar "solo se rechaza la finca" "fx$sufijo" "$(echo "$r" | jq -r '[.rechazos_entidades[].uid] | join(",")')"
comprobar "la finca rechazada se manda borrar (no existe en el servidor)" "0" "$(echo "$r" | jq --arg u "fx$sufijo" '[.entidades[] | select(.uid==$u)] | length')"

# 4. Coordinación ve la huella.
r="$(sync "$COORDINACION" "{\"desde_revision\": $revision_inicial}")"
comprobar "coordinación recibe el apunte de la tester" "1" "$(echo "$r" | jq --arg u "a$sufijo" '[.entidades[] | select(.uid==$u)] | length')"
comprobar "actividad: la tester movió el punto" "mover" "$(echo "$r" | jq -r --arg u "pu$sufijo" '[.actividad[] | select(.uid==$u)] | last | .accion')"
comprobar "actividad: autoría del apunte" "Ane (tester)" "$(echo "$r" | jq -r --arg u "a$sufijo" '[.actividad[] | select(.uid==$u)] | last | .persona_nombre')"
comprobar "actividad: contexto del apunte = proyecto" "Quesería" "$(echo "$r" | jq -r --arg u "a$sufijo" '[.actividad[] | select(.uid==$u)] | last | .contexto')"

# 5. Coordinación borra el proyecto: la lápida llega a la tester.
r0="$(sync "$TESTER" '{}' | jq .revision)"
sync "$COORDINACION" "$(jq -n --arg s "$sufijo" --argjson ms "$((ahora + 2000))" '{entidades:[{tipo:"proyecto", uid:("p"+$s), actualizado_ms:$ms, borrado:true, datos:{}}]}')" >/dev/null
r="$(sync "$TESTER" "{\"desde_revision\": $r0}")"
comprobar "la tester recibe la lápida del proyecto" "true" "$(echo "$r" | jq --arg u "p$sufijo" '[.entidades[] | select(.uid==$u)] | .[0].borrado')"

if [ "$fallos" -gt 0 ]; then echo "$fallos fallo(s)"; exit 1; fi
echo "Prueba de sincronización superada."
