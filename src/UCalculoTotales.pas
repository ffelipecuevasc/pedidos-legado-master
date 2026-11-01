unit UCalculoTotales;

{ Calculo de totales del pedido.
  v2 - se agrega descuento VIP (oct-2007)
  El IVA se calcula sobre el neto. El flete va exento. }

interface

type
  TLineaCalculo = record
    Cantidad: Integer;
    PrecioUnit: Double;
    Categoria: string[3];
  end;

  TLineasCalculo = array of TLineaCalculo;

  TTotalesPedido = record
    Subtotal: Double;
    BaseDescuento: Double;
    PorcDescuento: Double;
    Descuento: Double;
    Flete: Double;
    Neto: Double;
    Iva: Double;
    Total: Double;
  end;

function RedondearPeso(Valor: Double): Double;
function CalcularSubtotal(const Lineas: TLineasCalculo): Double;
function CalcularBaseDescuento(const Lineas: TLineasCalculo): Double;
function PorcDescuentoVolumen(Subtotal: Double): Double;
function PorcDescuentoCliente(TipoCliente: Char): Double;
function CalcularFlete(FleteBase: Double; CodRegion: Integer): Double;
function CalcularTotales(const Lineas: TLineasCalculo; TipoCliente: Char;
  CodRegion: Integer; FleteBase, TasaIva: Double): TTotalesPedido;

implementation

const
  APLICA_DESC_NAVIDAD = False;   // campana dic-2008
  PORC_NAVIDAD = 2;

{ redondea al peso mas cercano }
function RedondearPeso(Valor: Double): Double;
begin
  Result := Int(Valor);
  if Frac(Valor) > 0.5 then
    Result := Result + 1;
end;

function CalcularSubtotal(const Lineas: TLineasCalculo): Double;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to High(Lineas) do
    Result := Result + Lineas[i].Cantidad * Lineas[i].PrecioUnit;
end;

{ suma de las lineas que llevan descuento }
function CalcularBaseDescuento(const Lineas: TLineasCalculo): Double;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to High(Lineas) do
    if Lineas[i].Categoria <> 'OFE' then
      Result := Result + Lineas[i].Cantidad * Lineas[i].PrecioUnit;
end;

function PorcDescuentoVolumen(Subtotal: Double): Double;
begin
  if Subtotal > 1000000 then
    Result := 8
  else if Subtotal > 500000 then
    Result := 5
  else
    Result := 0;
end;

function PorcDescuentoCliente(TipoCliente: Char): Double;
begin
  if UpCase(TipoCliente) = 'V' then
    Result := 3
  else
    Result := 0;
end;

{ recargo zonas extremas }
function CalcularFlete(FleteBase: Double; CodRegion: Integer): Double;
begin
  Result := FleteBase;
  if (CodRegion = 11) or (CodRegion = 12) then
    Result := RedondearPeso(FleteBase * 115 / 100);
end;

function CalcularTotales(const Lineas: TLineasCalculo; TipoCliente: Char;
  CodRegion: Integer; FleteBase, TasaIva: Double): TTotalesPedido;
var
  PorcCli: Double;
begin
  Result.Subtotal := CalcularSubtotal(Lineas);
  Result.BaseDescuento := CalcularBaseDescuento(Lineas);

  PorcCli := PorcDescuentoCliente(TipoCliente);
  Result.PorcDescuento := PorcDescuentoVolumen(Result.Subtotal) + PorcCli;
  if Result.PorcDescuento > 10 then
    Result.PorcDescuento := 10;

  if APLICA_DESC_NAVIDAD then
  begin
    Result.PorcDescuento := Result.PorcDescuento + PORC_NAVIDAD;
    PorcCli := PorcCli + PORC_NAVIDAD;
  end;

  // las ofertas solo llevan el descuento del cliente
  Result.Descuento := RedondearPeso(
    (Result.BaseDescuento * Result.PorcDescuento +
     (Result.Subtotal - Result.BaseDescuento) * PorcCli) / 100);

  Result.Flete := CalcularFlete(FleteBase, CodRegion);
  Result.Neto := Result.Subtotal - Result.Descuento + Result.Flete;
  Result.Iva := RedondearPeso(Result.Neto * TasaIva / 100);
  Result.Total := Result.Neto + Result.Iva;
end;

end.
