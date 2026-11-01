unit UDMPrincipal;

interface

uses
  SysUtils, Classes, DB, Variants, Dialogs, dbisamtb;

type
  TDMPrincipal = class(TDataModule)
    ssnPrincipal: TDBISAMSession;
    dbPedidos: TDBISAMDatabase;
    tblClientes: TDBISAMTable;
    tblProductos: TDBISAMTable;
    tblRegiones: TDBISAMTable;
    qryAux: TDBISAMQuery;
    qryAux2: TDBISAMQuery;
    qryInforme: TDBISAMQuery;
    dsClientes: TDataSource;
    dsProductos: TDataSource;
    dsRegiones: TDataSource;
    dsInforme: TDataSource;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    procedure CargarParametros;
  public
    function LeerParametro(const Clave, Defecto: string): string;
    function SiguienteNroPedido: Integer;
    function TraerValor(const SQL: string): Variant;
    procedure EjecutarSQL(const SQL: string);
  end;

var
  DMPrincipal: TDMPrincipal;

implementation

uses
  UGlobales;

{$R *.dfm}

procedure TDMPrincipal.DataModuleCreate(Sender: TObject);
begin
  // clave de encriptacion de las tablas (no cambiar!!)
  ssnPrincipal.AddPassword('Distrib#2008');
  ssnPrincipal.Active := True;

  if ParamCount > 0 then
    gDirDatos := ParamStr(1);
  dbPedidos.Directory := gDirDatos;
  try
    dbPedidos.Connected := True;
  except
    on E: Exception do
    begin
      MessageDlg('No se pudo abrir la base de datos en ' + gDirDatos + #13 +
        E.Message, mtError, [mbOK], 0);
      Halt;
    end;
  end;

  tblClientes.Open;
  tblProductos.Open;
  tblRegiones.Open;
  CargarParametros;
end;

procedure TDMPrincipal.DataModuleDestroy(Sender: TObject);
begin
  dbPedidos.Connected := False;
end;

procedure TDMPrincipal.CargarParametros;
begin
  try
    gTasaIva := StrToFloat(LeerParametro('IVA', '19'));
    gMinimoPedido := StrToFloat(LeerParametro('MINIMO_PEDIDO', '30000'));
    gNombreEmpresa := LeerParametro('EMPRESA', '');
    gImprimirAlGrabar := LeerParametro('IMPRIMIR', 'S') = 'S';
  except
  end;
end;

function TDMPrincipal.LeerParametro(const Clave, Defecto: string): string;
begin
  qryAux.Close;
  qryAux.SQL.Text := 'SELECT VALOR FROM PARAMETROS WHERE CLAVE = ''' + Clave + '''';
  qryAux.Open;
  if qryAux.IsEmpty then
    Result := Defecto
  else
    Result := Trim(qryAux.FieldByName('VALOR').AsString);
  qryAux.Close;
end;

function TDMPrincipal.SiguienteNroPedido: Integer;
var
  v: Variant;
begin
  v := TraerValor('SELECT MAX(NRO_PEDIDO) AS ULT FROM PEDIDOS');
  if VarIsNull(v) then
    Result := 1001
  else
    Result := v + 1;
end;

function TDMPrincipal.TraerValor(const SQL: string): Variant;
begin
  qryAux2.Close;
  qryAux2.SQL.Text := SQL;
  qryAux2.Open;
  Result := qryAux2.Fields[0].Value;
  qryAux2.Close;
end;

procedure TDMPrincipal.EjecutarSQL(const SQL: string);
begin
  qryAux2.Close;
  qryAux2.SQL.Text := SQL;
  qryAux2.ExecSQL;
end;

end.
