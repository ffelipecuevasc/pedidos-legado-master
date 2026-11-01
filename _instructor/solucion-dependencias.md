# Solución — Mapa de dependencias de referencia

> Documento exclusivo del instructor. Se obtiene de las cláusulas `uses` (interfaz e implementación) y de las referencias a tablas en el SQL embebido.

## Dependencias entre unidades

```mermaid
flowchart TD
    DPR[PedidosLegado.dpr]

    subgraph UI[Formularios]
        FP[UFrmPrincipal]
        FC[UFrmClientes]
        FPR[UFrmProductos]
        FPE[UFrmPedidos]
        FI[UFrmInformes]
    end

    subgraph Dominio[Lógica]
        CT[UCalculoTotales<br/>funciones puras]
        ST[UStock]
    end

    subgraph Infra[Infraestructura]
        DM[UDMPrincipal<br/>data module]
        GL[UGlobales<br/>estado global]
        UT[UUtilidades]
        DB[(DBISAM 4<br/>dbisamtb)]
    end

    DPR --> FP & DM
    FP --> FC & FPR & FPE & FI
    FP --> ST & DM & GL

    FC --> DM & GL & UT
    FPR --> DM & GL & UT
    FPE --> CT & ST & DM & GL & UT
    FI --> DM & GL & UT

    ST --> DM & GL
    DM --> GL
    DM --> DB
    ST -.SQL.-> DB
    FPE -.SQL.-> DB

    CT:::puro
    classDef puro fill:#d4f7d4,stroke:#2a7a2a
    GL:::riesgo
    classDef riesgo fill:#fde2e2,stroke:#a33
```

Observaciones que debería hacer un buen diagnóstico:

1. **`UCalculoTotales` no depende de nada** (ni siquiera de `SysUtils`): es la "hoja" del grafo y el mejor candidato para extraer primero (Unidad 5).
2. **`UGlobales` es usado por casi todo**: acoplamiento oculto. `UDMPrincipal` lo *escribe* (`gTasaIva`, `gMinimoPedido`, `gDirDatos`), `UFrmPrincipal` también (`gUsuarioActual`, `gNivelUsuario`) y el resto lo *lee*.
3. **`UFrmPedidos` es el nodo con más dependencias salientes** (5 unidades + BD directa).
4. `UStock` depende del data module (no recibe la conexión como parámetro): no se puede probar sin BD.
5. No hay ciclos en `interface`; las referencias cruzadas están en `implementation` (lo habitual en Delphi para evitarlos).
6. `UFrmInformes` **no** usa `UCalculoTotales`: es la raíz de la inconsistencia de IVA (R01).

## Unidades × tablas

```mermaid
flowchart LR
    DM[UDMPrincipal] --> CLIENTES & PRODUCTOS & REGIONES & PARAMETROS & PEDIDOS
    FC[UFrmClientes] --> CLIENTES & PEDIDOS
    FPR[UFrmProductos] --> PRODUCTOS
    FPE[UFrmPedidos] --> CLIENTES & REGIONES & PRODUCTOS & PEDIDOS & PEDIDO_LINEAS
    FI[UFrmInformes] --> PEDIDOS & CLIENTES & REGIONES
    ST[UStock] --> PRODUCTOS & PEDIDO_LINEAS & MOV_STOCK
    FP[UFrmPrincipal] --> PEDIDOS
    MOV_STOCK:::fantasma
    classDef fantasma stroke-dasharray: 5 5,fill:#eee
```

`MOV_STOCK` aparece en el código (`src/UStock.pas:57`) pero **no existe en el esquema**: punto extra para quien lo detecte.

## Modelo de datos (referencia)

```mermaid
erDiagram
    REGIONES ||--o{ CLIENTES : "COD_REGION"
    CLIENTES ||--o{ PEDIDOS : "ID_CLIENTE"
    PEDIDOS ||--|{ PEDIDO_LINEAS : "NRO_PEDIDO"
    PRODUCTOS ||--o{ PEDIDO_LINEAS : "ID_PRODUCTO"
    PARAMETROS {
        varchar CLAVE PK
        varchar VALOR
    }
```

No hay claves foráneas declaradas en `esquema-dbisam.sql`: la integridad referencial depende solo del código.
