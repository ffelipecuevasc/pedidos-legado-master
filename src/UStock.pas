unit UStock;

{ Manejo de stock. Se llama desde la toma de pedidos }

interface

uses
  SysUtils, Classes, DB, dbisamtb;

function Calc3(StockActual, Cantidad: Integer; TipoCliente: Char): Boolean;
procedure DescontarStock(IdProducto, Cantidad: Integer; TipoCliente: Char;
  NroPedido: Integer);
procedure DevolverStock(NroPedido: Integer);
function ProductosBajoMinimo: TStringList;

implementation

uses
  UDMPrincipal, UGlobales;

function Calc3(StockActual, Cantidad: Integer; TipoCliente: Char): Boolean;
var
  Limite: Integer;
begin
  Limite := 0;
  if TipoCliente = 'V' then
    Limite := -20;
  Result := (StockActual - Cantidad) >= Limite;
end;

procedure DescontarStock(IdProducto, Cantidad: Integer; TipoCliente: Char;
  NroPedido: Integer);
var
  vStock: Integer;
  vCodigo: string;
begin
  with DMPrincipal.qryAux2 do
  begin
    Close;
    SQL.Text := 'SELECT CODIGO, STOCK FROM PRODUCTOS WHERE ID_PRODUCTO = ' +
      IntToStr(IdProducto);
    Open;
    vStock := FieldByName('STOCK').AsInteger;
    vCodigo := FieldByName('CODIGO').AsString;
    Close;
  end;

  if not Calc3(vStock, Cantidad, TipoCliente) then
    raise Exception.Create('Stock insuficiente para ' + vCodigo +
      ' (disponible: ' + IntToStr(vStock) + ')');

  DMPrincipal.EjecutarSQL('UPDATE PRODUCTOS SET STOCK = ' +
    IntToStr(vStock - Cantidad) + ' WHERE ID_PRODUCTO = ' + IntToStr(IdProducto));

  // movimiento para auditoria
  try
    DMPrincipal.EjecutarSQL('INSERT INTO MOV_STOCK (ID_PRODUCTO, FECHA, CANTIDAD, ' +
      'NRO_PEDIDO, USUARIO) VALUES (' + IntToStr(IdProducto) + ', CURRENT_TIMESTAMP, ' +
      IntToStr(-Cantidad) + ', ' + IntToStr(NroPedido) + ', ''' + gUsuarioActual + ''')');
  except
  end;
end;

{ al anular un pedido }
procedure DevolverStock(NroPedido: Integer);
var
  Ids, Cants: TStringList;
  i: Integer;
begin
  Ids := TStringList.Create;
  Cants := TStringList.Create;
  try
    with DMPrincipal.qryAux do
    begin
      Close;
      SQL.Text := 'SELECT ID_PRODUCTO, CANTIDAD FROM PEDIDO_LINEAS WHERE NRO_PEDIDO = ' +
        IntToStr(NroPedido);
      Open;
      while not Eof do
      begin
        Ids.Add(FieldByName('ID_PRODUCTO').AsString);
        Cants.Add(FieldByName('CANTIDAD').AsString);
        Next;
      end;
      Close;
    end;
    for i := 0 to Ids.Count - 1 do
      DMPrincipal.EjecutarSQL('UPDATE PRODUCTOS SET STOCK = STOCK + ' + Cants[i] +
        ' WHERE ID_PRODUCTO = ' + Ids[i]);
  finally
    Ids.Free;
    Cants.Free;
  end;
end;

function ProductosBajoMinimo: TStringList;
begin
  Result := TStringList.Create;
  with DMPrincipal.qryAux do
  begin
    Close;
    SQL.Text := 'SELECT CODIGO, DESCRIPCION, STOCK FROM PRODUCTOS ' +
      'WHERE STOCK < STOCK_MINIMO AND ACTIVO = TRUE ORDER BY CODIGO';
    Open;
    while not Eof do
    begin
      Result.Add(FieldByName('CODIGO').AsString + ' - ' +
        FieldByName('DESCRIPCION').AsString + ' (' +
        FieldByName('STOCK').AsString + ')');
      Next;
    end;
    Close;
  end;
end;

end.
