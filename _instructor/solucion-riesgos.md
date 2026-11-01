# Solución — Deuda técnica y riesgos plantados

> Documento exclusivo del instructor. Severidad: **Alta** (seguridad o datos incorrectos en producción), **Media** (bugs latentes o costo de cambio alto), **Baja** (legibilidad).

## 1. Seguridad

| # | Riesgo | Ubicación | Severidad | Detalle |
|---|--------|-----------|-----------|---------|
| T01 | Contraseña de cifrado de la BD en texto plano | `src/UDMPrincipal.pas:46` | Alta | `AddPassword('Distrib#2008')`: quien tenga el ejecutable (o el repo) descifra las tablas. |
| T02 | Contraseña del servidor remoto por defecto | `src/UDMPrincipal.dfm:13` | Media | `RemoteEncryptionPassword = 'elevatesoft'` es el valor de fábrica de DBISAM. Está en el `.dfm`, donde casi nadie mira. |
| T03 | SQL concatenado con texto de la UI (inyección) | `src/UFrmClientes.pas:161-162` (búsqueda), `src/UFrmClientes.pas:191-192`, `src/UFrmPedidos.pas:173` (RUT), `src/UFrmPedidos.pas:218-219` (código producto), `src/UFrmPedidos.pas:343` (observación), `src/UFrmProductos.pas:135-136` (porcentaje y categoría), `src/UFrmInformes.pas:93` y `:95` (región y cliente), `src/UFrmPrincipal.pas:151` (nro. a anular), `src/UDMPrincipal.pas:88` | Alta | El caso más didáctico: en *Observaciones* del pedido escribir `x'); DELETE FROM CLIENTES; --` o simplemente un apóstrofo (`Despachar a D'Angelo`) rompe la grabación. En reajuste de precios, `edtPorc` se concatena dentro de una expresión aritmética. `cmbRegion` es editable, así que también acepta texto libre. |
| T04 | Autenticación inexistente | `src/UFrmPrincipal.pas:67-86` | Alta | Solo se pide un nombre; escribir `ADMIN` da nivel 9. |
| T05 | Usuario concatenado en SQL de auditoría | `src/UStock.pas:57-59` | Baja | Hoy viene de `InputBox`, también es inyectable. |

## 2. Integridad de datos y lógica

| # | Riesgo | Ubicación | Severidad | Detalle |
|---|--------|-----------|-----------|---------|
| T06 | Dos cálculos de totales distintos | `src/UCalculoTotales.pas:100-126` vs `src/UFrmPedidos.pas:360-400` | Alta | El cliente acepta un total en pantalla (`:311`) y se graba otro. 15 de 60 pedidos de ejemplo difieren. Ver `solucion-reglas.md`. |
| T07 | Dos funciones de redondeo con semántica distinta | `src/UCalculoTotales.pas:45-49` (trunca ,5) y `src/UUtilidades.pas:150-153` (`Round` bancario) | Media | Además `RedondearDec` (`src/UUtilidades.pas:155-161`) usa una tercera regla (+0,5 y truncar). |
| T08 | IVA hardcodeado en informes | `src/UFrmInformes.pas:85`, `:122` | Media | El informe recalcula el IVA sobre el neto en vez de leer `PEDIDOS.IVA`: el total del informe no cuadra con la suma de los pedidos (redondeo por pedido vs. sobre el total). |
| T09 | Número de pedido con `MAX()+1` | `src/UDMPrincipal.pas:97-106`, uso en `src/UFrmPedidos.pas:325` | Alta | Fuera de la transacción y sin bloqueo: dos vendedores pueden obtener el mismo número (violación de PK, o peor, si alguien quita la PK). |
| T10 | Lectura-modificación-escritura del stock | `src/UStock.pas:38-53` | Alta | Lee `STOCK` y escribe `STOCK = <valor calculado>`: actualizaciones perdidas con usuarios concurrentes. Compárese con `DevolverStock` (`:80-81`), que sí usa `STOCK = STOCK + n`. |
| T11 | Excepción silenciada al registrar movimiento de stock | `src/UStock.pas:56-61` | Alta | La tabla `MOV_STOCK` **no existe** en `db/esquema-dbisam.sql`: el `INSERT` falla siempre y el `try..except end` lo oculta. La "auditoría" nunca funcionó. |
| T12 | Excepción silenciada al cargar parámetros | `src/UDMPrincipal.pas:74-83` | Media | Si `IVA` falla al convertirse, el sistema sigue con el 19 de `UGlobales` sin avisar; y si falla `IVA`, ya no se cargan `EMPRESA` ni `IMPRIMIR`. |
| T13 | Excepción silenciada al generar el ticket | `src/UFrmPedidos.pas:424-445` | Media | Si no existe `C:\PedidosLegado\Tickets`, bodega no recibe el ticket y nadie se entera. Ojo: `CloseFile` no se ejecuta si `Writeln` falla. |
| T14 | Separador decimal cambiado globalmente y tarde | `src/UFrmPrincipal.pas:60-63` | Media | Se fija `DecimalSeparator := '.'` para que `FloatToStr` sirva en el SQL, pero el data module se crea **antes** (`PedidosLegado.dpr:21`) y `CargarParametros` corre con la configuración regional chilena (coma). Hoy funciona porque el IVA es `'19'`; con `'19.5'` fallaría en silencio (T12). |
| T15 | Anulación devuelve stock que nunca se descontó | `src/UFrmPrincipal.pas:151-152`, `src/UStock.pas:65-89` | Media | No revisa el estado previo: anular un pedido `P` (o anular dos veces) infla el stock. Tampoco va en transacción. |
| T16 | Regla de morosidad solo en la UI | `src/UFrmPedidos.pas:282-301` | Media | Cualquier otro canal (importación, otra pantalla futura, API) puede crear pedidos a morosos. |
| T17 | Parámetros y constantes que no se usan | `PARAMETROS.MINIMO_PEDIDO=25000` / `src/UDMPrincipal.pas:78` / `src/UGlobales.pas:13` | Media | El negocio cree que el mínimo es 25.000 (tabla), el código aplica 30.000. |
| T18 | Comentarios desactualizados | `src/UCalculoTotales.pas:5` ("el flete va exento"), `README.md` (Delphi 5, BDE, Paradox, Crystal Reports, "el cálculo de descuentos está en UFrmPedidos") | Media | Buen ejercicio para mostrar que el código es la única fuente de verdad. |

## 3. Fechas

| # | Riesgo | Ubicación | Severidad | Detalle |
|---|--------|-----------|-----------|---------|
| T19 | Año de dos dígitos con ventana fija | `src/UUtilidades.pas:97-108` | Media | `yy < 50` → 20yy. Además, si el usuario escribe `01/03/2024`, `Copy(S, 7, 2)` toma `'20'` → **2020**. No valida formato: `1/3/24` lanza `EConvertError`. |
| T20 | Formato de fecha global `dd/mm/yy` | `src/UFrmPrincipal.pas:62`, `src/UUtilidades.pas:113` | Baja | Tickets e informes muestran años de dos dígitos. |
| T21 | Sin calendario de feriados | `src/UUtilidades.pas:127-133` | Media | Ver R08 (pedidos 1011, 1012 y 1042 caen en feriados de 2024). |
| T22 | Días de mora con `Date` del PC | `src/UUtilidades.pas:144-147` | Baja | Si el reloj del PC está mal, cambia quién puede comprar. |

## 4. Diseño y mantenibilidad

| # | Riesgo | Ubicación | Severidad | Detalle |
|---|--------|-----------|-----------|---------|
| T23 | Variables globales mutables | `src/UGlobales.pas:17-28` | Media | `gTasaIva`, `gUsuarioActual`, `gNivelUsuario`, `gModoEdicion` (se escribe y nunca se lee), `gPedidoActual` (ídem), `gUltimoError`. |
| T24 | Método de más de 150 líneas | `src/UFrmPedidos.pas:261-451` (`btnGrabarClick`, 191 líneas) | Media | Mezcla validación, reglas, SQL, transacción, stock y archivo de ticket. |
| T25 | Números mágicos | `11`, `12`, `13` (regiones), `30000`, `60`, `500000`, `1000000`, `8`, `5`, `3`, `10`, `115`, `-20`, `18`, `250`, `30` (%) | Baja | Repartidos en `UCalculoTotales`, `UFrmPedidos`, `UStock`, `UUtilidades`, `UFrmProductos`, `UFrmClientes`. |
| T26 | Nombres poco claros | `Proc2` (`src/UFrmPedidos.pas:120`, pinta la grilla), `Calc3` (`src/UStock.pas:21`, valida stock), `ChkRut`, `qryAux`/`qryAux2`, variables `n`, `p`, `s`, `u` | Baja | |
| T27 | Código duplicado | `ValidarRut`/`ChkRut`; `LimpiarRut` vs. el bucle de `ChkRut`; `FormatearMonto`/`FmtPesos` (`src/UUtilidades.pas:163-172`); `SoloNumeros` vs `LimpiarRut` | Media | |
| T28 | Reglas de negocio en eventos de UI | `TblClientesBeforePost`, `btnGuardarClick`, `btnEliminarClick`, `btnActualizarClick`, `btnGrabarClick` | Media | Impiden probar sin levantar la UI. Contraste: `UCalculoTotales` sí es aislable. |
| T29 | `BeforePost` reasignado en tiempo de ejecución sobre un dataset compartido | `src/UFrmClientes.pas:68`, `src/UFrmProductos.pas:58` | Media | Si el formulario no se cierra por `FormClose`, el data module queda con un puntero a un método de un objeto liberado. |
| T30 | Rutas absolutas `C:\` | `src/UGlobales.pas:23-24`, `src/UFrmInformes.pas:138` | Baja | |
| T31 | Dependencia de componentes comerciales | `dbisamtb` en `UDMPrincipal`, `UStock`, `UFrmPedidos`, `UFrmInformes` | Media | DBISAM 4 está descontinuado; afecta la estrategia de migración de datos. |
