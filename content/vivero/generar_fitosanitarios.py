"""Genera fitosanitarios_vivero.csv desde el Registro MAPA (06/11/2026) y la EU Pesticides DB (07/11/2026).

Uso: python3 -I generar_fitosanitarios.py productos.json todas_eu.json salida.csv informe.txt
"""
import collections
import csv
import json
import re
import sys
import unicodedata

productos = json.load(open(sys.argv[1]))['Productos']
sustancias_ue = json.load(open(sys.argv[2]))
ruta_salida = sys.argv[3]
ruta_informe = sys.argv[4]

# Grupo de cultivo de la app -> códigos de cultivo del registro.
grupos_cultivo = {
    'ornamental_herbacea': {'0103050000000000'},
    'ornamental_lenosa': {'0101010400000000', '0101010000000000'},
    'pino': {'0101010101010000'},
    'tomate': {'0103010301000000'},
    'pimiento': {'0103010302000000'},
    'lechuga': {'0103010601000000', '0103010601030000'},
}

# Plaga de la app -> patrones del campo «Agente» del registro (minúsculas, sin tildes).
plagas = {
    'pulgones': ['afidos, pulgones', 'pulgon verde, myzus', 'pulgon rojo del rosal', 'pulgones'],
    'mosca_blanca': ['mosca blanca', 'moscas blancas'],
    'trips': ['trips', 'frankliniella'],
    'arana_roja': ['arana roja', 'tetranychus', 'acaros tetraniquidos'],
    'oidio': ['oidio', 'erysiphe', 'oidios', 'podosphaera', 'leveillula'],
    'botritis': ['botrytis', 'podredumbre gris'],
    'pythium': ['pythium', 'pitium'],
    'rhizoctonia': ['rhizoctonia'],
    'phytophthora': ['phytophthora spp', 'phytophthora cryptogea', 'phytophthora nicotianae', 'phytophthora capsici'],
    'fusarium': ['fusarium', 'fusariosis'],
    'babosas_caracoles': ['babosas', 'caracoles'],
    'minadores': ['liriomiza', 'liriomyza'],
    'orugas': ['lepidopteros', 'noctuidos', 'spodoptera', 'heliothis', 'helicoverpa', 'gusanos grises', 'rosquilla'],
    'procesionaria': ['procesionaria', 'thaumetopoea'],
    'tuta_absoluta': ['tuta absoluta', 'polilla del tomate'],
    'mildiu': ['mildiu', 'peronospora', 'bremia'],
    'roya': ['roya', 'puccinia'],
}


def sin_tildes(texto):
    return ''.join(c for c in unicodedata.normalize('NFD', texto.lower()) if unicodedata.category(c) != 'Mn')


def plaga_de(agente):
    normalizado = sin_tildes(agente or '')
    for plaga, patrones in plagas.items():
        if any(p in normalizado for p in patrones):
            return plaga
    return None


def grupo_de(codigo):
    for grupo, codigos in grupos_cultivo.items():
        if codigo in codigos:
            return grupo
    return None


por_sustancia = collections.defaultdict(lambda: {'usos': set(), 'plazos': set(), 'productos': set(), 'mezcla': False, 'nombre_es': None})
for producto in productos:
    datos = producto['DATOSPRODUCTO']
    if datos.get('Estado') != 'Vigente':
        continue
    composicion = producto.get('COMPOSICION') or []
    for uso in producto.get('USOS') or []:
        grupo = grupo_de(uso.get('CodigoCultivo'))
        plaga = plaga_de(uso.get('Agente'))
        if not grupo or not plaga:
            continue
        for componente in composicion:
            nombre_ue = (componente.get('NombreUE') or componente.get('Nombre Sustancia') or '').strip()
            celda = por_sustancia[nombre_ue]
            celda['nombre_es'] = celda['nombre_es'] or componente.get('Nombre Sustancia')
            celda['usos'].add(f'{grupo}:{plaga}')
            celda['plazos'].add(str(uso.get('Plazo Seguridad')).strip())
            celda['productos'].add(datos['Num_Registro'])
            if len(composicion) > 1:
                celda['mezcla'] = True

indice_ue = {}
for sustancia in sustancias_ue:
    indice_ue.setdefault((sustancia.get('substance_name') or '').strip().lower(), sustancia)

categorias = {
    'IN': 'insecticida', 'AC': 'acaricida', 'FU': 'fungicida', 'BA': 'bactericida', 'MO': 'molusquicida',
    'NE': 'nematicida', 'HB': 'herbicida', 'PG': 'regulador', 'RE': 'repelente', 'EL': 'elicitor', 'AT': 'atrayente',
}


tipo_por_plaga = {
    'pulgones': 'insecticida', 'mosca_blanca': 'insecticida', 'trips': 'insecticida', 'minadores': 'insecticida',
    'orugas': 'insecticida', 'procesionaria': 'insecticida', 'tuta_absoluta': 'insecticida',
    'arana_roja': 'acaricida', 'babosas_caracoles': 'molusquicida',
}


def tipo_accion(sustancia, usos):
    tipos = sorted({tipo_por_plaga.get(u.split(':')[1], 'fungicida') for u in usos})
    if sustancia.get('as_micro_org') == 'Yes':
        tipos = [t + ' biológico' for t in tipos] or ['biológico']
    return ' y '.join(dict.fromkeys(tipos)) or 'sin categoría UE'


def fecha_es(iso):
    if not iso:
        return ''
    if '-' in iso:
        a, m, d = iso[:10].split('-')
        return f'{d}/{m}/{a}'
    return iso


def identificador(nombre):
    base = sin_tildes(nombre)
    base = re.sub(r'[^a-z0-9]+', '_', base).strip('_')
    return base[:64]


filas = []
informe = []
for nombre_ue, celda in sorted(por_sustancia.items()):
    sustancia = indice_ue.get(nombre_ue.lower())
    if not sustancia:
        informe.append(f'FUERA (no está en la base UE): {nombre_ue} ({celda["nombre_es"]})')
        continue
    if 'sclp' in nombre_ue.lower() or 'straight chain lepidopteran' in nombre_ue.lower():
        informe.append(f'FUERA (feromona SCLP, se deja fuera como en Frutal): {nombre_ue}')
        continue
    estado = sustancia.get('substance_status') or ''
    caduca = sustancia.get('expiry_date') or ''
    if caduca and '/' in caduca:
        d, m, a = caduca.split('/')
        if (a, m, d) < ('2026', '11', '07'):
            informe.append(f'FUERA (aprobación UE caducada {caduca}, dato incoherente): {nombre_ue}')
            continue
    if not estado.lower().startswith('approved'):
        informe.append(f'FUERA (no aprobada en la UE: {estado}): {nombre_ue}')
        continue
    caducidad = fecha_es(sustancia.get('expiry_date'))
    etiqueta_estado = 'aprobada'
    if sustancia.get('low_risk_active_substance') == 'Yes':
        etiqueta_estado += ' (bajo riesgo)'
    if sustancia.get('basic_substance') == 'Yes':
        etiqueta_estado += ' (sustancia básica)'
    if caducidad:
        etiqueta_estado += f' hasta {caducidad}'
    numeros = sorted({int(p) for p in celda['plazos'] if p.isdigit()})
    no_procede = any(not p.isdigit() for p in celda['plazos'])
    if numeros:
        rango = str(numeros[0]) if len(numeros) == 1 else f'{numeros[0]}–{numeros[-1]}'
        if no_procede:
            rango += '; no procede en algún uso'
        plazo_max = str(numeros[-1])
    else:
        rango = 'no procede'
        plazo_max = ''
    if 0 in numeros:
        informe.append(f'AVISO plazo 0 en el registro: {nombre_ue}')
    filas.append({
        'id': identificador(celda['nombre_es'] or nombre_ue),
        'nombre': re.sub(r'\s+', ' ', re.sub(r'[*]|\)$(?<!\(.{0,80}\))', '', (celda['nombre_es'] or nombre_ue).strip())).strip().capitalize(),
        'usos': '|'.join(sorted(celda['usos'])),
        'tipo_accion': tipo_accion(sustancia, celda['usos']),
        'plazo_seguridad_max_dias': plazo_max,
        'plazo_seguridad_registro': rango,
        'estado_ue': etiqueta_estado,
        'candidata_sustitucion': 'si' if sustancia.get('candidate_for_substitution') == 'Yes' else 'no',
        'notas': f'{len(celda["productos"])} productos vigentes.' + (' También en mezclas.' if celda['mezcla'] else ''),
        'revisado_por': 'revision-ia: Claude, 2026-11-07, Registro de Productos Fitosanitarios MAPA (exportación para el Cuaderno de Explotación, datos 06/11/2026) + EU Pesticides DB (API v3.0, 07/11/2026)',
    })

ids_vistos = collections.Counter(f['id'] for f in filas)
assert all(n == 1 for n in ids_vistos.values()), [i for i, n in ids_vistos.items() if n > 1]
with open(ruta_salida, 'w', newline='') as salida:
    escritor = csv.DictWriter(salida, fieldnames=list(filas[0].keys()))
    escritor.writeheader()
    escritor.writerows(filas)
with open(ruta_informe, 'w') as f:
    f.write('\n'.join(informe) + f'\n{len(filas)} filas\n')
print(len(filas), 'filas;', len(informe), 'avisos')
