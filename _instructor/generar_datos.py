#!/usr/bin/env python3
"""
Genera los CSV de db/datos/ de forma determinista (semilla fija).

Los totales guardados en pedidos.csv imitan lo que hace TFrmPedidos.btnGrabarClick:
la cabecera se REESCRIBE con el "recálculo desde la base" (umbrales >=, sin
excluir OFE, redondeo bancario de Round()). Por eso pedidos.csv NO siempre
coincide con golden-master.csv: esa diferencia es intencional y es material
del curso (ver guia-instructor.md).

Uso:  python3 generar_datos.py && python3 referencia_totales.py
"""
import csv
import datetime as dt
import os
import random

from referencia_totales import calcular_totales

AQUI = os.path.dirname(os.path.abspath(__file__))
DATOS = os.path.join(AQUI, "..", "db", "datos")
rnd = random.Random(2008)


def dv_rut(cuerpo: int) -> str:
    suma, mult = 0, 2
    for d in reversed(str(cuerpo)):
        suma += int(d) * mult
        mult = 2 if mult == 7 else mult + 1
    r = 11 - suma % 11
    return "0" if r == 11 else "K" if r == 10 else str(r)


def fmt_rut(cuerpo: int) -> str:
    return f"{cuerpo:,}".replace(",", ".") + "-" + dv_rut(cuerpo)


def escribir(nombre, columnas, filas):
    with open(os.path.join(DATOS, nombre), "w", newline="", encoding="utf-8") as f:
        w = csv.writer(f)
        w.writerow(columnas)
        w.writerows(filas)


# ------------------------------------------------------------------ REGIONES
REGIONES = [
    (1, "Tarapaca", 9500), (2, "Antofagasta", 9000), (3, "Atacama", 8000),
    (4, "Coquimbo", 6000), (5, "Valparaiso", 3500), (6, "O'Higgins", 3500),
    (7, "Maule", 4500), (8, "Biobio", 5500), (9, "Araucania", 6500),
    (10, "Los Lagos", 7500), (11, "Aysen", 12990), (12, "Magallanes", 13500),
    (13, "Metropolitana", 2500), (14, "Los Rios", 7000),
    (15, "Arica y Parinacota", 9990), (16, "Nuble", 5000),
]
FLETE = {c: f for c, _, f in REGIONES}

# ------------------------------------------------------------------ CLIENTES
# (razon social, comuna, region, tipo)
CLIENTES_BASE = [
    ("MINIMARKET LOS AROMOS LTDA", "Maipu", 13, "N"),
    ("ALMACEN SANTA ELVIRA", "La Florida", 13, "N"),
    ("COMERCIAL RIO CLARO SPA", "Talca", 7, "V"),
    ("SUPERMERCADO EL FARO LTDA", "Vina del Mar", 5, "V"),
    ("DISTRIBUIDORA PUNTA NORTE SPA", "Antofagasta", 2, "N"),
    ("ALMACEN DONA MARTA", "Puente Alto", 13, "N"),
    ("MINIMARKET LAS CAMELIAS", "Rancagua", 6, "N"),
    ("COMERCIAL TRES ESQUINAS LTDA", "Concepcion", 8, "V"),
    ("BOTILLERIA EL ANCLA", "Valparaiso", 5, "N"),
    ("AUTOSERVICIO LA PALMILLA SPA", "Temuco", 9, "N"),
    ("MINIMARKET COLIHUE", "Nunoa", 13, "N"),
    ("ALMACEN EL PORVENIR", "San Bernardo", 13, "N"),
    ("COMERCIAL VIENTO SUR LTDA", "Puerto Montt", 10, "N"),
    ("SUPERMERCADO LOS CANELOS SPA", "Santiago", 13, "V"),
    ("ALMACEN LA ESPIGA", "Chillan", 16, "N"),
    ("MINIMARKET EL MIRADOR", "La Serena", 4, "N"),
    ("COMERCIAL PATAGONIA AUSTRAL LTDA", "Punta Arenas", 12, "V"),
    ("AUTOSERVICIO RIO MANIHUALES", "Coyhaique", 11, "N"),
    ("ALMACEN LOS ALERCES", "Valdivia", 14, "N"),
    ("COMERCIAL CALAFATE SPA", "Puerto Natales", 12, "N"),
    ("MINIMARKET CERRO CASTILLO", "Coyhaique", 11, "V"),
    ("ALMACEN SAN EXPEDITO", "Quilicura", 13, "N"),
    ("COMERCIAL ALTO DEL CARMEN", "Copiapo", 3, "N"),
    ("MINIMARKET PAMPA BRAVA", "Iquique", 1, "N"),
    ("ALMACEN LA CANDELARIA", "Arica", 15, "N"),
    ("SUPERMERCADO DON GASPAR LTDA", "Pudahuel", 13, "N"),
    ("MINIMARKET EL TREBOL", "Los Angeles", 8, "N"),
    ("ALMACEN LAS TINAJAS", "Curico", 7, "N"),
    ("COMERCIAL LOMAS VERDES SPA", "Quilpue", 5, "N"),
    ("ALMACEN EL REFUGIO", "Renca", 13, "N"),
]
# deuda vencida: id -> (monto, fecha vencimiento mas antigua)
DEUDAS = {
    6: (184500, dt.date(2024, 9, 12)),
    9: (92300, dt.date(2024, 11, 4)),
    13: (415800, dt.date(2024, 7, 30)),
    19: (56900, dt.date(2024, 10, 21)),
    25: (238000, dt.date(2024, 8, 19)),
    28: (31200, dt.date(2024, 11, 18)),
}


def generar_clientes():
    filas, usados = [], set()
    # forzamos algunos DV 'K' y '0' (el formulario de clientes los valida mal)
    quiero = ["K", "0", "K", "0"] + [None] * (len(CLIENTES_BASE) - 4)
    rnd.shuffle(quiero)
    for i, (razon, comuna, reg, tipo) in enumerate(CLIENTES_BASE, start=1):
        while True:
            cuerpo = rnd.randint(76000000, 77999999) if i % 5 else rnd.randint(8000000, 19999999)
            if cuerpo in usados:
                continue
            if quiero[i - 1] and dv_rut(cuerpo) != quiero[i - 1]:
                continue
            if not quiero[i - 1] and dv_rut(cuerpo) in "K0":
                continue
            break
        usados.add(cuerpo)
        deuda, venc = DEUDAS.get(i, (0, None))
        dominio = razon.split()[1].lower() + str(i)
        alta = dt.date(2003, 1, 1) + dt.timedelta(days=rnd.randint(0, 365 * 11))
        filas.append([
            i, fmt_rut(cuerpo), razon,
            f"{rnd.choice(['Av.', 'Calle', 'Pasaje'])} {rnd.choice(['Los Robles', 'Uno Norte', 'Las Acacias', 'El Bosque', 'Ficticia', 'Principal', 'Central'])} {rnd.randint(10, 2999)}",
            comuna, reg, tipo,
            f"+56 9 {rnd.randint(5000, 9999)} {rnd.randint(1000, 9999)}",
            f"contacto@{dominio}.example" if i % 4 else "",
            deuda, venc.isoformat() if venc else "",
            "False" if i == 30 else "True", alta.isoformat(),
        ])
    return filas


# ------------------------------------------------------------------ PRODUCTOS
PRODUCTOS_BASE = [
    ("ABA-001", "ARROZ GRADO 1 1KG X 10", "ABA", 11490, "UN"),
    ("ABA-002", "AZUCAR GRANULADA 1KG X 10", "ABA", 10990, "UN"),
    ("ABA-003", "HARINA SIN POLVOS 1KG X 10", "ABA", 8790, "UN"),
    ("ABA-004", "FIDEOS SPAGHETTI 400G X 20", "ABA", 13980, "CJ"),
    ("ABA-005", "ACEITE VEGETAL 1LT X 12", "ABA", 25000, "CJ"),
    ("ABA-006", "SAL FINA 1KG X 25", "ABA", 7250, "SC"),
    ("ABA-007", "TE NEGRO 100 BOLSITAS X 12", "ABA", 19900, "CJ"),
    ("ABA-008", "CAFE INSTANTANEO 170G X 12", "ABA", 46800, "CJ"),
    ("ABA-009", "LENTEJAS 1KG X 10", "ABA", 18900, "UN"),
    ("ABA-010", "POROTOS 1KG X 10", "ABA", 21500, "UN"),
    ("BEB-001", "BEBIDA COLA 3LT X 6", "BEB", 12350, "PK"),
    ("BEB-002", "BEBIDA NARANJA 3LT X 6", "BEB", 11870, "PK"),
    ("BEB-003", "AGUA MINERAL 1,6LT X 6", "BEB", 4990, "PK"),
    ("BEB-004", "JUGO NECTAR DURAZNO 1,5LT X 6", "BEB", 8460, "PK"),
    ("BEB-005", "JUGO EN POLVO X 36", "BEB", 6120, "CJ"),
    ("BEB-006", "BEBIDA LIMA LIMON 2LT X 8", "BEB", 10400, "PK"),
    ("CON-001", "ATUN LOMITO EN ACEITE X 24", "CON", 31200, "CJ"),
    ("CON-002", "DURAZNO EN MITADES 590G X 24", "CON", 27650, "CJ"),
    ("CON-003", "TOMATE TROZOS 400G X 24", "CON", 16830, "CJ"),
    ("CON-004", "ARVEJAS 300G X 24", "CON", 15990, "CJ"),
    ("CON-005", "CHAMPINONES LAMINADOS X 24", "CON", 22440, "CJ"),
    ("LAC-001", "LECHE ENTERA 1LT X 12", "LAC", 11640, "CJ"),
    ("LAC-002", "LECHE DESCREMADA 1LT X 12", "LAC", 11880, "CJ"),
    ("LAC-003", "LECHE EN POLVO 800G X 12", "LAC", 62400, "CJ"),
    ("LAC-004", "MANTEQUILLA 250G X 20", "LAC", 38500, "CJ"),
    ("LAC-005", "LECHE CONDENSADA 397G X 24", "LAC", 35760, "CJ"),
    ("LIM-001", "DETERGENTE POLVO 5KG X 4", "LIM", 29960, "CJ"),
    ("LIM-002", "CLORO TRADICIONAL 1LT X 12", "LIM", 7680, "CJ"),
    ("LIM-003", "LAVALOZA 750ML X 12", "LIM", 14280, "CJ"),
    ("LIM-004", "PAPEL HIGIENICO 4 ROLLOS X 12", "LIM", 23880, "PK"),
    ("LIM-005", "TOALLA PAPEL 3 ROLLOS X 8", "LIM", 15920, "PK"),
    ("LIM-006", "SUAVIZANTE 3LT X 4", "LIM", 17960, "CJ"),
    ("LIM-007", "BOLSAS BASURA 80X110 X 100", "LIM", 9850, "PQ"),
    ("LIM-008", "JABON TOCADOR 90G X 48", "LIM", 20160, "CJ"),
    ("OFE-001", "PACK ONCE (TE+AZUCAR+GALLETAS)", "OFE", 14990, "PK"),
    ("OFE-002", "PACK ASEO HOGAR", "OFE", 24990, "PK"),
    ("OFE-003", "ACEITE 1LT X 12 LIQUIDACION", "OFE", 19990, "CJ"),
    ("OFE-004", "ATUN X 24 FECHA CORTA", "OFE", 22500, "CJ"),
    ("OFE-005", "BEBIDA COLA 3LT X 6 PROMO", "OFE", 9990, "PK"),
    ("LAC-006", "YOGHURT BATIDO X 24 (DESC.)", "LAC", 9360, "CJ"),
]


def generar_productos():
    filas = []
    for i, (cod, desc, cat, precio, un) in enumerate(PRODUCTOS_BASE, start=1):
        minimo = 0 if cat == "OFE" else rnd.choice([10, 10, 15, 20, 30])
        stock = rnd.randint(0, 400)
        filas.append([i, cod, desc, cat, precio, stock, minimo, un, "False" if i == 40 else "True"])
    # stock bajo minimo y negativos (quedaron asi por ventas a VIP)
    filas[7][5] = 4
    filas[23][5] = -12
    filas[16][5] = -3
    filas[26][5] = 6
    return filas


# ------------------------------------------------------------------ PEDIDOS
def fecha_pedido(momento: dt.datetime) -> dt.date:
    """Replica UUtilidades.FechaPedido / SiguienteDiaHabil."""
    if momento.hour >= 18:
        d = momento.date() + dt.timedelta(days=1)
        while d.weekday() >= 5:
            d += dt.timedelta(days=1)
        return d
    return momento.date()


def ruta_sql(lineas, tipo, flete, tasa_iva):
    """Replica el recalculo 'a mano' de btnGrabarClick (lo que queda grabado)."""
    sub = 0.0
    for c, p, _ in lineas:
        sub += c * p
    porc = 8.0 if sub >= 1000000 else 5.0 if sub >= 500000 else 0.0
    if tipo == "V":
        porc += 3
    if porc > 10:
        porc = 10.0
    desc = float(round(sub * porc / 100))   # Round() de Delphi = bancario
    neto = sub - desc + flete
    iva = float(round(neto * tasa_iva / 100))
    return sub, desc, neto, iva, neto + iva


def main():
    os.makedirs(DATOS, exist_ok=True)
    clientes = generar_clientes()
    productos = generar_productos()
    cli = {c[0]: c for c in clientes}
    prod = {p[0]: p for p in productos}
    activos = [p[0] for p in productos if p[8] == "True"]
    ofe = [p[0] for p in productos if p[3] == "OFE"]
    tasa_iva = 19.0

    # momentos de ingreso (dias habiles + algun sabado), varios despues de las 18:00
    momentos = []
    inicio = dt.date(2024, 9, 2)
    while len(momentos) < 60:
        d = inicio + dt.timedelta(days=rnd.randint(0, 88))
        if d.weekday() == 6 or (d.weekday() == 5 and rnd.random() < 0.7):
            continue
        h = rnd.choice([8, 9, 10, 11, 12, 15, 16, 17, 18, 19])
        momentos.append(dt.datetime(d.year, d.month, d.day, h, rnd.randint(0, 59), rnd.randint(0, 59)))
    momentos.sort()
    # garantizamos un viernes despues de las 18 -> lunes
    momentos[40] = dt.datetime(2024, 11, 8, 18, 42, 10)
    momentos.sort()

    id_aceite = 5      # 25.000
    especiales = {
        4: (3, [(id_aceite, 30), (8, 12), (37, 10)]),     # VIP > 1M con OFE -> tope 10%
        11: (1, [(id_aceite, 20)]),                        # exactamente 500.000
        18: (12, [(id_aceite, 40)]),                       # exactamente 1.000.000
        22: (5, [(36, 20), (38, 15), (13, 4)]),            # casi todo OFE > 500.000
        27: (18, [(1, 6), (22, 4)]),                       # Aysen
        33: (21, [(31, 9), (4, 7), (36, 6)]),              # Aysen VIP
        37: (17, [(17, 10), (24, 6), (id_aceite, 8)]),     # Magallanes VIP
        45: (20, [(11, 3), (3, 2)]),                       # Magallanes
        50: (11, [(13, 2), (28, 1)]),                      # RM bajo 30.000
        56: (14, [(25, 8), (17, 9), (37, 4)]),             # VIP RM 500k-1M
    }
    usuarios = ["MSOTO", "CARAYA", "JPV", "SUPLOPEZ", "MSOTO", "CARAYA"]
    pedidos, lineas_csv = [], []
    for idx, mom in enumerate(momentos):
        nro = 1001 + idx
        if idx in especiales:
            id_cli, items = especiales[idx]
        else:
            while True:
                id_cli = rnd.randint(1, 29)
                n = rnd.choice([1, 2, 2, 3, 3, 4, 5, 6])
                ids = rnd.sample(activos, n)
                items = [(p, rnd.choice([1, 2, 3, 4, 5, 6, 8, 10, 12, 15, 20, 24, 30])) for p in ids]
                sub = sum(prod[p][4] * q for p, q in items)
                if cli[id_cli][5] != 13 and sub < 30000:
                    continue
                if sub > 1600000:
                    continue
                break
        reg, tipo = cli[id_cli][5], cli[id_cli][6]
        lin = [(q, float(prod[p][4]), prod[p][3]) for p, q in items]
        ref = calcular_totales(lin, tipo, reg, float(FLETE[reg]), tasa_iva)
        sub, desc, neto, iva, total = ruta_sql(lin, tipo, ref["flete"], tasa_iva)
        estado = "C"
        if idx in (7, 15, 29, 44, 52, 58, 59):
            estado = "P"
        if idx in (9, 26, 41):
            estado = "A"
        obs = rnd.choice(["", "", "", "Despachar en la manana", "Llamar antes de despachar",
                          "Retira en bodega", "Factura a nombre del local"])
        pedidos.append([nro, fecha_pedido(mom).isoformat(), mom.isoformat(sep=" "), id_cli,
                        estado, int(sub), int(desc), int(ref["flete"]), int(neto), int(iva),
                        int(total), rnd.choice(usuarios), obs])
        for k, (p, q) in enumerate(items, start=1):
            lineas_csv.append([nro, k, p, q, prod[p][4], prod[p][4] * q])

    escribir("regiones.csv", ["COD_REGION", "NOMBRE", "FLETE_BASE"], REGIONES)
    escribir("clientes.csv", ["ID_CLIENTE", "RUT", "RAZON_SOCIAL", "DIRECCION", "COMUNA",
                              "COD_REGION", "TIPO", "TELEFONO", "EMAIL", "DEUDA_VENCIDA",
                              "FECHA_VENC_DEUDA", "ACTIVO", "FECHA_ALTA"], clientes)
    escribir("productos.csv", ["ID_PRODUCTO", "CODIGO", "DESCRIPCION", "CATEGORIA", "PRECIO",
                               "STOCK", "STOCK_MINIMO", "UNIDAD", "ACTIVO"], productos)
    escribir("pedidos.csv", ["NRO_PEDIDO", "FECHA", "FECHA_INGRESO", "ID_CLIENTE", "ESTADO",
                             "SUBTOTAL", "DESCUENTO", "FLETE", "NETO", "IVA", "TOTAL",
                             "USUARIO", "OBSERVACION"], pedidos)
    escribir("pedido_lineas.csv", ["NRO_PEDIDO", "LINEA", "ID_PRODUCTO", "CANTIDAD",
                                   "PRECIO_UNIT", "TOTAL_LINEA"], lineas_csv)
    escribir("parametros.csv", ["CLAVE", "VALOR", "DESCRIPCION"], [
        ["IVA", "19", "Tasa de IVA en porcentaje"],
        ["MINIMO_PEDIDO", "25000", "Monto minimo de pedido fuera de RM"],
        ["EMPRESA", "DISTRIBUIDORA EJEMPLO SUR LTDA.", "Nombre para tickets e informes"],
        ["IMPRIMIR", "S", "Generar ticket al grabar (S/N)"],
        ["VERSION_BD", "7", "Version del esquema"],
    ])
    print("CSV generados:", len(clientes), "clientes,", len(productos), "productos,",
          len(pedidos), "pedidos,", len(lineas_csv), "lineas")


if __name__ == "__main__":
    main()
