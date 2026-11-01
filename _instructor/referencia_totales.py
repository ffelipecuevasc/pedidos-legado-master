#!/usr/bin/env python3
"""
Implementación de referencia de UCalculoTotales.pas (Pedidos Legado).

Replica EXACTAMENTE el comportamiento del Delphi, INCLUIDOS SUS DEFECTOS:
  * RedondearPeso trunca cuando la parte decimal es exactamente 0,5 (R05).
  * El umbral de descuento por volumen se evalúa sobre el subtotal COMPLETO
    (incluye líneas OFE), con comparación estricta ">" (R02, R09).
  * El tope de 10 % se aplica a la suma volumen + VIP; las líneas OFE
    reciben sólo el % del cliente, sin tope adicional (R03, R09).
  * El recargo del 15 % sobre el flete se aplica a las regiones 11 y 12 (R04).
  * El flete forma parte del neto y paga IVA (el comentario del .pas dice lo contrario).
  * El descuento navideño (R12) es código muerto y NO se replica.

Uso:
  python3 referencia_totales.py              -> regenera golden-master.csv
  python3 referencia_totales.py --verificar  -> compara golden-master.csv con el cálculo

Sólo usa la biblioteca estándar de Python 3. Toda la aritmética es float
(IEEE-754 doble), igual que el tipo Double de Delphi.
"""
import csv
import math
import os
import sys

AQUI = os.path.dirname(os.path.abspath(__file__))
DATOS = os.path.join(AQUI, "..", "db", "datos")
SALIDA = os.path.join(AQUI, "golden-master.csv")


# ---------------------------------------------------------------- UCalculoTotales
def redondear_peso(valor: float) -> float:
    """RedondearPeso: Int(Valor) + 1 sólo si Frac(Valor) > 0.5 (defecto en ,5)."""
    entero = float(math.trunc(valor))
    if valor - entero > 0.5:
        entero += 1.0
    return entero


def calcular_subtotal(lineas):
    total = 0.0
    for cantidad, precio, _cat in lineas:
        total += cantidad * precio
    return total


def calcular_base_descuento(lineas):
    total = 0.0
    for cantidad, precio, cat in lineas:
        if cat != "OFE":
            total += cantidad * precio
    return total


def porc_descuento_volumen(subtotal: float) -> float:
    if subtotal > 1000000:
        return 8.0
    if subtotal > 500000:
        return 5.0
    return 0.0


def porc_descuento_cliente(tipo_cliente: str) -> float:
    return 3.0 if tipo_cliente.upper() == "V" else 0.0


def calcular_flete(flete_base: float, cod_region: int) -> float:
    if cod_region in (11, 12):
        return redondear_peso(flete_base * 115 / 100)
    return flete_base


def calcular_totales(lineas, tipo_cliente, cod_region, flete_base, tasa_iva):
    """lineas: lista de tuplas (cantidad:int, precio_unit:float, categoria:str)."""
    subtotal = calcular_subtotal(lineas)
    base = calcular_base_descuento(lineas)
    porc_cli = porc_descuento_cliente(tipo_cliente)
    porc = porc_descuento_volumen(subtotal) + porc_cli
    if porc > 10:
        porc = 10.0
    descuento = redondear_peso((base * porc + (subtotal - base) * porc_cli) / 100)
    flete = calcular_flete(flete_base, cod_region)
    neto = subtotal - descuento + flete
    iva = redondear_peso(neto * tasa_iva / 100)
    return {
        "subtotal": subtotal,
        "base_descuento": base,
        "porc_descuento": porc,
        "descuento": descuento,
        "flete": flete,
        "neto": neto,
        "iva": iva,
        "total": neto + iva,
    }


# ---------------------------------------------------------------- golden master
COLUMNAS = ["caso", "nro_pedido", "tipo_cliente", "cod_region", "flete_base", "tasa_iva",
            "lineas", "subtotal", "base_descuento", "porc_descuento", "descuento",
            "flete", "neto", "iva", "total"]


def _leer(nombre):
    with open(os.path.join(DATOS, nombre), newline="", encoding="utf-8") as f:
        return list(csv.DictReader(f))


def _fmt(x: float) -> str:
    return str(int(x)) if float(x).is_integer() else repr(x)


def construir_casos():
    clientes = {int(c["ID_CLIENTE"]): c for c in _leer("clientes.csv")}
    productos = {int(p["ID_PRODUCTO"]): p for p in _leer("productos.csv")}
    regiones = {int(r["COD_REGION"]): r for r in _leer("regiones.csv")}
    params = {p["CLAVE"]: p["VALOR"] for p in _leer("parametros.csv")}
    tasa_iva = float(params["IVA"])
    lineas_por_pedido = {}
    for l in _leer("pedido_lineas.csv"):
        lineas_por_pedido.setdefault(int(l["NRO_PEDIDO"]), []).append(l)

    filas = []
    for i, ped in enumerate(_leer("pedidos.csv"), start=1):
        nro = int(ped["NRO_PEDIDO"])
        cli = clientes[int(ped["ID_CLIENTE"])]
        region = int(cli["COD_REGION"])
        flete_base = float(regiones[region]["FLETE_BASE"])
        lineas = []
        for l in sorted(lineas_por_pedido[nro], key=lambda x: int(x["LINEA"])):
            cat = productos[int(l["ID_PRODUCTO"])]["CATEGORIA"]
            lineas.append((int(l["CANTIDAD"]), float(l["PRECIO_UNIT"]), cat))
        r = calcular_totales(lineas, cli["TIPO"], region, flete_base, tasa_iva)
        filas.append({
            "caso": i,
            "nro_pedido": nro,
            "tipo_cliente": cli["TIPO"],
            "cod_region": region,
            "flete_base": _fmt(flete_base),
            "tasa_iva": _fmt(tasa_iva),
            "lineas": "|".join(f"{c}x{_fmt(p)}x{cat}" for c, p, cat in lineas),
            **{k: _fmt(v) for k, v in r.items()},
        })
    return filas


def main():
    filas = construir_casos()
    if "--verificar" in sys.argv:
        with open(SALIDA, newline="", encoding="utf-8") as f:
            esperado = list(csv.DictReader(f))
        malos = [a["caso"] for a, b in zip(esperado, filas)
                 if {k: str(v) for k, v in b.items()} != a]
        if malos or len(esperado) != len(filas):
            print("DIFERENCIAS en casos:", malos)
            sys.exit(1)
        print(f"OK: {len(filas)} casos coinciden")
        return
    with open(SALIDA, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=COLUMNAS)
        w.writeheader()
        w.writerows(filas)
    print(f"golden-master.csv generado con {len(filas)} casos")


if __name__ == "__main__":
    main()
