# Solución — Catálogo de reglas de negocio

> Documento exclusivo del instructor. No entregar a los alumnos.
> Las líneas corresponden al commit inicial del repositorio. Si se edita el código, regenérelas con `grep -n`.

## Cómo leer esta tabla

- **Ubicación**: `archivo:línea` donde se implementa la regla (la primera es la principal).
- **Condición → efecto**: lo que hace el código *realmente*, no lo que "debería" hacer.
- **Trampa**: lo que un diagnóstico superficial suele pasar por alto.

## Reglas principales (R01–R12)

| ID | Regla | Ubicación | Condición → efecto | Trampa |
|----|-------|-----------|--------------------|--------|
| R01 | IVA 19 % parametrizado | `src/UDMPrincipal.pas:77` (lectura de `PARAMETROS.IVA` a `gTasaIva`); uso en `src/UCalculoTotales.pas:124` vía `src/UFrmPedidos.pas:149` y `src/UFrmPedidos.pas:391` | `IVA = RedondearPeso(Neto * gTasaIva / 100)` | **Hardcodeado** `0.19` en `src/UFrmInformes.pas:85` (SQL: `P.NETO * 0.19`, `P.NETO * 1.19`) y `src/UFrmInformes.pas:122`. Si cambia la tasa en `PARAMETROS`, el informe no cambia. Además el valor por defecto `19` vive en `src/UGlobales.pas:19` y en el `'19'` de `UDMPrincipal.pas:77`. |
| R02 | Descuento por volumen | `src/UCalculoTotales.pas:74-77` | Subtotal `> 1.000.000` → 8 %; `> 500.000` → 5 % | El umbral se evalúa sobre el **subtotal completo** (incluye líneas OFE), antes de flete. Comparación estricta: un pedido de exactamente $500.000 **no** tiene descuento (pedido 1012). La segunda implementación (`src/UFrmPedidos.pas:381-384`) usa `>=` → sí lo tiene. |
| R03 | VIP +3 %, acumulable, tope 10 % | `src/UCalculoTotales.pas:84` (3 %), `:107` (suma), `:108-109` (tope) | `TIPO = 'V'` → +3 %; si volumen + VIP > 10 → 10 % | Las líneas OFE reciben el 3 % VIP aunque no el de volumen (`:118-120`). En `UFrmPedidos.pas:385-388` se repite la regla sin distinguir OFE. `UStock.Calc3` compara `'V'` sensible a mayúsculas, `PorcDescuentoCliente` no (`UpCase`). |
| R04 | Recargo flete zonas extremas | `src/UCalculoTotales.pas:94-95` | Región 11 (Aysén) o 12 (Magallanes) → flete × 1,15 redondeado con `RedondearPeso` | Los códigos de región son números mágicos; el flete base sale de `REGIONES.FLETE_BASE` pero el recargo **no** está en la tabla. Aysén: 12.990 × 1,15 = 14.938,5 → queda **14.938** por R05. El flete **sí** paga IVA (`:123`), aunque el comentario de la cabecera (`:5`) dice "el flete va exento". |
| R05 | Redondeo al peso defectuoso | `src/UCalculoTotales.pas:45-49` | `Int(x)`, +1 sólo si `Frac(x) > 0.5` | Los ,5 se truncan (debería subir). En negativos redondea hacia cero. Existe **otro** redondeo, `UUtilidades.Redondear` (`src/UUtilidades.pas:152`), que usa `Round` de Delphi = **redondeo bancario** (,5 al par). Casos en el golden master: descuento ,5 en 1001, 1016, 1025, 1026; IVA ,5 en 1055; flete ,5 en todos los pedidos de Aysén. |
| R06 | Bloqueo por deuda vencida > 60 días | `src/UFrmPedidos.pas:295` (cálculo de días en `:292`, función en `src/UUtilidades.pas:144`) | `DEUDA_VENCIDA > 0` y `Date - FECHA_VENC_DEUDA > 60` → no se graba el pedido | **Solo** en el formulario: ni la BD, ni `UStock`, ni otra vía lo impiden. Se valida al *grabar*, no al seleccionar el cliente (el vendedor arma todo el pedido antes de enterarse). Usa `Date` del PC: con la fecha actual, todos los clientes con deuda de los datos de ejemplo quedan bloqueados. |
| R07 | Stock negativo permitido a VIP | `src/UStock.pas:27-28` (`Calc3`), uso en `:48`; llamada desde `src/UFrmPedidos.pas:405` | VIP: stock final ≥ −20; resto: ≥ 0. Si no se cumple → excepción → rollback del pedido completo | Solo aplica si el pedido se graba confirmado (`ESTADO='C'`). Al agregar una línea (`UFrmPedidos.pas:228`) solo hay una advertencia. Los datos tienen productos con stock −12 y −3. |
| R08 | Pedidos después de las 18:00 → día hábil siguiente | `src/UUtilidades.pas:138` (`FechaPedido`), `:127-133` (`SiguienteDiaHabil`); uso en `src/UFrmPedidos.pas:305` | `HourOf(Now) >= 18` → siguiente día que no sea sábado ni domingo | Incluye las 18:00:00 en punto. **No considera feriados** (`TODO` en `:132`): el pedido 1011 (ingresado el 18-09-2024 a las 19:25) quedó con fecha 19-09, que es feriado. Un pedido de sábado antes de las 18:00 queda con fecha sábado. |
| R09 | Categoría OFE sin descuento por volumen | `src/UCalculoTotales.pas:68` (`CalcularBaseDescuento`), aplicada en `:118-120` | Las líneas `CATEGORIA = 'OFE'` quedan fuera de la base del % de volumen | Las líneas OFE **sí cuentan** para alcanzar el umbral de R02 y **sí reciben** el 3 % VIP. La reimplementación de `UFrmPedidos.pas:380-389` **ignora** R09 por completo: es la causa principal de que `PEDIDOS.DESCUENTO` no coincida con la pantalla (pedidos 1023 y 1055, por ejemplo). |
| R10 | Mínimo de pedido $30.000 salvo RM | `src/UFrmPedidos.pas:372` | Subtotal (recalculado por SQL) `< 30000` y región `<> 13` → rollback y mensaje | El parámetro `PARAMETROS.MINIMO_PEDIDO` vale **25000**, se carga en `gMinimoPedido` (`UDMPrincipal.pas:78`) y **nunca se usa**. La constante `REGION_METROPOLITANA` (`UGlobales.pas:13`) tampoco se usa. Se evalúa *después* de insertar cabecera y líneas (dentro de la transacción). |
| R11 | Validación de RUT duplicada | (a) `src/UUtilidades.pas:41-70` (`ValidarRut`, usada en `src/UFrmPedidos.pas:161`); (b) `src/UFrmClientes.pas:85-115` (`ChkRut`, usada en `src/UFrmClientes.pas:120`) | Módulo 11 | (a) compara el DV **sensible a mayúsculas** (`:69`): `76.126.611-k` se rechaza en la toma de pedidos. (b) tiene **invertidos** los casos 10 y 11 (`:109-112`): los RUT con DV `K` o `0` son "inválidos" en el mantenedor de clientes y no se pueden editar ni desactivar (clientes 1, 9, 25 y 26). Además (b) exige al menos 8 caracteres (`:96`). |
| R12 | Descuento navideño (código muerto) | `src/UCalculoTotales.pas:41-42` (constantes) y `:111-115` | `APLICA_DESC_NAVIDAD = False` → nunca se ejecuta | Si se migra "tal cual" aparece una rama que nadie puede probar. Si se activara, el +2 % se sumaría **después** del tope de 10 % (llegaría a 12 %). `referencia_totales.py` no la replica. |

## Reglas secundarias (también plantadas, útiles para evaluar diagnósticos completos)

| ID | Regla | Ubicación | Comentario |
|----|-------|-----------|------------|
| S01 | Solo supervisores (nivel ≥ 1) marcan clientes VIP | `src/UFrmClientes.pas:135` | Regla en `BeforePost`. |
| S02 | Nivel de usuario por nombre (`ADMIN`/`JPV` = 9, prefijo `SUP` = 1) | `src/UFrmPrincipal.pas:78-80` | No hay contraseña de usuario: cualquiera escribe `ADMIN`. |
| S03 | Anular pedidos solo supervisores; devuelve stock | `src/UFrmPrincipal.pas:137-154` | Devuelve stock aunque el pedido estuviera **pendiente** (nunca descontado) o ya anulado. |
| S04 | Cliente con pedidos no se borra: queda inactivo | `src/UFrmClientes.pas:225` | Regla dentro de `OnClick`. |
| S05 | Región por defecto 13 al crear cliente | `src/UFrmClientes.pas:132` | Número mágico. |
| S06 | Si la deuda es 0 se borra la fecha de vencimiento | `src/UFrmClientes.pas:201-202` | Dentro de `btnGuardarClick`. |
| S07 | Productos OFE tienen stock mínimo 0 | `src/UFrmProductos.pas:106-108` | |
| S08 | Reajuste de precios > 30 % solo administrador | `src/UFrmProductos.pas:127` | El `UPDATE` no redondea: deja precios con decimales. |
| S09 | Máximo 25 líneas por pedido | `src/UGlobales.pas:14`, uso en `src/UFrmPedidos.pas:211` | |
| S10 | Observación truncada a 250 caracteres | `src/UFrmPedidos.pas:321-322` | |

## Las dos implementaciones del cálculo (pregunta clave de U4)

| Aspecto | Pantalla (`UCalculoTotales.CalcularTotales`) | Lo que se graba (`UFrmPedidos.pas:360-400`) |
|---|---|---|
| Umbrales volumen | `>` 500.000 / `>` 1.000.000 | `>=` 500.000 / `>=` 1.000.000 |
| Líneas OFE | Sin % de volumen, con % VIP | Igual que el resto |
| Redondeo | `RedondearPeso` (trunca los ,5) | `Redondear` = `Round` bancario |
| Flete | Calculado (R04) | Toma `FTotales.Flete` de la pantalla |
| Dónde se ve | Etiquetas de la pantalla y pregunta de confirmación (`:311`) | Mensaje final (`:449`), ticket (`:438-440`), tabla `PEDIDOS`, informe |

En los datos de ejemplo, **15 de 60 pedidos** tienen totales grabados distintos a los del golden master: 1001, 1003, 1005, 1006, 1012, 1016, 1019, 1020, 1021, 1023, 1026, 1037, 1041, 1055 y 1057.
