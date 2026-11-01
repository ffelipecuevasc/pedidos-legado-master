# Guía del instructor — "Pedidos Legado"

> La carpeta `_instructor/` **no se entrega a los alumnos**. Antes de compartir el repo, bórrela o cree una rama sin ella:
> `git rm -r --cached _instructor && git commit -m "Material alumnos"` en una rama aparte.

## 1. Qué es este repositorio

Un sistema **sintético** de escritorio en Delphi 7 + DBISAM 4, "escrito en 2006–2008" para una distribuidora mayorista chilena ficticia. Todo (empresa, clientes, RUT, teléfonos, correos `.example`) es inventado; los RUT tienen dígito verificador válido.

Se ve compilable (sintaxis Object Pascal correcta, `uses` coherentes, `.dfm` en formato texto), pero **no se entrega compilado**: falta `PedidosLegado.res` y los componentes DBISAM son comerciales. Esto es a propósito: los alumnos deben entender el sistema **leyéndolo**, que es la situación real con muchos legados.

| Elemento | Contenido |
|---|---|
| `src/` | 10 unidades `.pas` (1.788 líneas) + 6 `.dfm` (1.211 líneas) |
| `PedidosLegado.dpr` | Programa principal (24 líneas) |
| `db/esquema-dbisam.sql` | 6 tablas en dialecto DBISAM |
| `db/datos/*.csv` | 16 regiones, 30 clientes, 40 productos, 60 pedidos, 185 líneas, 5 parámetros |
| `_instructor/referencia_totales.py` | Réplica exacta en Python de `UCalculoTotales.pas` |
| `_instructor/golden-master.csv` | 60 casos (uno por pedido) generados con el script anterior |
| `_instructor/generar_datos.py` | Regenera los CSV de forma determinista (semilla 2008) |

Regenerar todo:

```bash
cd _instructor && python3 generar_datos.py && python3 referencia_totales.py && python3 referencia_totales.py --verificar
```

## 2. Unidad 4 — Diagnóstico de un legado con IA

**Objetivo**: que el alumno produzca, apoyado por un asistente de IA, un diagnóstico verificable: reglas de negocio, riesgos y dependencias.

### Secuencia sugerida (≈ 3 h)

1. **Lectura en frío (20 min, sin IA)**. Solo `README.md` y el árbol de archivos. Pregunta: "¿qué creen que hace y en qué tecnología está?". El README dice Delphi 5 + BDE + Paradox + Crystal Reports: **todo falso**. Primera lección: la documentación de un legado miente; el código no.
2. **Mapa del sistema (40 min, con IA)**. Pedir el diagrama de dependencias y el modelo de datos. Comparar con `solucion-dependencias.md`.
3. **Extracción de reglas (60 min, con IA)**. Consigna: "catálogo de reglas con id, archivo:línea, condición y efecto". Exigir **evidencia por línea**: una regla sin ubicación no cuenta.
4. **Riesgos (40 min)**. Clasificar seguridad / datos / mantenibilidad con severidad.
5. **Puesta en común (20 min)**. Usar la pregunta clave de la sección 4.

### Qué debería encontrar un buen diagnóstico

Escala orientativa sobre las 12 reglas (R01–R12) y los 31 riesgos (T01–T31):

| Nivel | Reglas | Indicadores |
|---|---|---|
| Insuficiente | < 6 | Solo lo que está en `UCalculoTotales`. Copia comentarios como verdad ("el flete va exento"). |
| Aceptable | 6–8 | Encuentra R06, R07, R08 y R10 fuera del módulo de cálculo. Detecta la contraseña y la inyección SQL. |
| Bueno | 9–11 | Detecta que **hay dos cálculos** (R02/R09 en `UFrmPedidos`), el `0.19` del informe y las dos validaciones de RUT. |
| Excelente | 12 + secundarias | Explica **en qué casos** difieren los cálculos (umbral exacto, OFE, redondeo ,5 vs bancario), que R12 es código muerto, que `MOV_STOCK` no existe y que `MINIMO_PEDIDO` de la tabla no se usa. |

### Señales de que la IA "alucinó" (y el alumno no verificó)

- Afirmar que el mínimo de pedido es 25.000 (eso dice `PARAMETROS`, el código usa 30.000).
- Decir que el descuento navideño "aplica en diciembre".
- Asegurar que el flete no paga IVA (se lo cree al comentario de `UCalculoTotales.pas:5`).
- Inventar una tabla `FERIADOS` (solo aparece en un `TODO`).
- Citar números de línea que no existen o funciones que no están (p. ej. "`CalcularIVA`").

Pida siempre que el alumno abra el archivo en la línea citada.

## 3. Unidad 5 — Migración del núcleo con red de seguridad

**Objetivo**: migrar `UCalculoTotales.pas` a C# (o el lenguaje del curso) **preservando el comportamiento**, usando el golden master como prueba de caracterización.

### Por qué este módulo

- 128 líneas, sin dependencias (ni UI, ni BD, ni globales), records simples y 7 funciones cortas.
- Migrable en **≈ 25 minutos** con asistencia de IA. Mapeo directo: `record` → `record struct`/`class`, `array of` → `List<T>`/arreglo, `Double` → `double`, `string[3]` → `string`.

### Secuencia sugerida (≈ 2 h)

1. **Entregar `golden-master.csv`** (sí se entrega en U5). Explicar columnas:
   - `lineas`: `cantidad x precio x categoria` separadas por `|`. Ej.: `20x25000xABA|3x14990xOFE`.
   - `tipo_cliente` (`N`/`V`), `cod_region`, `flete_base`, `tasa_iva` (en %, 19).
   - Salidas: `subtotal`, `base_descuento`, `porc_descuento`, `descuento`, `flete`, `neto`, `iva`, `total`.
2. **Migración (25 min)**. Consigna: "migrar tal cual, **incluidos los defectos**". Nada de corregir aún.
3. **Prueba parametrizada** que lea el CSV y compare las 8 salidas en los 60 casos.
4. **Discusión de defectos**: con todo en verde, pedir que corrijan R05 (redondeo ,5) y ver qué casos se rompen: **1001, 1016, 1025, 1026** (descuento), **1055** (IVA) y **todos los de Aysén** (flete 14.938 → 14.939). Esta es la conversación central: *¿corregir un bug es un cambio de comportamiento? ¿quién lo autoriza? ¿qué pasa con los pedidos históricos?*
5. **Extra**: pedir que decidan qué hacer con R12 (código muerto) y con la segunda implementación de `UFrmPedidos`.

### Errores típicos al migrar (para detectar en la revisión)

| Error | Casos del golden master que fallan |
|---|---|
| Usar `Math.Round` con `MidpointRounding.AwayFromZero` en vez de replicar `RedondearPeso` | 1001, 1016, 1025, 1026, 1055 y todos los de región 11 |
| Usar `Math.Round` por defecto (bancario en .NET, igual que `Round` de Delphi) | Solo 1001 y 1026: el bancario coincide "por suerte" cuando el entero inferior es par. Excelente para mostrar que 58 casos verdes no prueban nada |
| Usar `decimal` sin cuidar el redondeo | No falla por precisión (los valores son exactos), pero sí si se "arregla" el redondeo |
| Usar `>=` en los umbrales | 1012 (500.000 exacto) y 1019 (1.000.000 exacto) |
| Excluir las líneas OFE del umbral de volumen | 1023 y otros con OFE |
| No dar el 3 % VIP a las líneas OFE | VIP con OFE: 1001, 1005, 1008, 1010, 1034, 1048, 1057 |
| No aplicar el tope 10 % (8 + 3 = 11) | VIP con subtotal > 1.000.000: 1001, 1005, 1031, 1039, 1058 |
| Activar o eliminar mal el descuento navideño | Ninguno (es código muerto): buena discusión sobre cobertura |
| Dejar el flete fuera del neto | Los 60 |

### Nota técnica sobre la exactitud

Todos los montos de entrada son enteros y las divisiones se hacen como `(entero * entero) / 100`, así que los valores ,5 son exactos tanto en `double` (Python/C#) como en `Extended` (Delphi 7). Por eso el golden master es reproducible en cualquier lenguaje con aritmética IEEE-754.

## 4. La pregunta clave que une U4 y U5

> "En los datos de ejemplo, ¿el total que ve el vendedor en pantalla es el mismo que queda grabado en `PEDIDOS`?"

Respuesta: **no, en 15 de 60 pedidos**. `UFrmPedidos.btnGrabarClick` muestra y confirma el total de `UCalculoTotales`, pero luego "recalcula desde la base" con otra lógica (`>=`, sin regla OFE, `Round` bancario) y **sobrescribe la cabecera**. El mensaje final y el ticket muestran el segundo total. Un alumno que compare `golden-master.csv` con `db/datos/pedidos.csv` lo descubre de inmediato.

Consecuencia para la migración: *¿cuál de los dos comportamientos es "el correcto"?* La respuesta técnica no existe; hay que preguntarle al negocio. Ése es el aprendizaje.

## 5. Datos de ejemplo: casos interesantes

| Pedido | Qué muestra |
|---|---|
| 1001, 1005 | VIP con subtotal > 1.000.000: tope 10 %; 1001 tiene además un ,5 en el descuento |
| 1012 | Subtotal exactamente 500.000: pantalla 0 %, grabado 5 % |
| 1019 | Subtotal exactamente 1.000.000: pantalla 5 %, grabado 8 % |
| 1023 | Pedido casi todo OFE: pantalla $998 de descuento, grabado $42.863 |
| 1026 | ,5 en el descuento: `RedondearPeso` da 36.167 y `Round` da 36.168 |
| 1055 | ,5 en el IVA (neto termina en 50) |
| 1051 | Región Metropolitana bajo $30.000: permitido |
| 1003, 1053 | Ingresados sábado después de las 18:00 → fecha lunes |
| 1046 | Viernes 18:42 → lunes |
| 1011, 1012, 1042 | Fechas que caen en feriados de 2024 (19 y 20 de septiembre; 1 de noviembre ingresado en feriado) |
| Clientes 1, 9, 25, 26 | RUT con DV `K` o `0`: el mantenedor de clientes los rechaza (R11) |
| Clientes 6, 13, 25 | Deuda vencida > 60 días al 29-11-2024 |
| Productos 17, 24 | Stock negativo (−3 y −12), compatible con R07 |
| Cliente 30 / producto 40 | Inactivos |

## 6. Preguntas de discusión

1. ¿Qué reglas se perderían si solo migráramos `UCalculoTotales`?
2. Si se cambia el IVA en `PARAMETROS`, ¿qué pantallas quedan inconsistentes?
3. ¿Cómo probarían R06 y R07 sin la interfaz gráfica? ¿Qué habría que refactorizar primero?
4. El golden master replica un bug. ¿Es eso correcto? ¿Cuándo dejaría de serlo?
5. ¿Qué riesgos de la tabla de deuda técnica son urgentes **antes** de migrar y cuáles se resuelven solos con la migración?
