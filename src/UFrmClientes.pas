unit UFrmClientes;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, DBGrids, DBCtrls, Mask, DB, Buttons;

type
  TFrmClientes = class(TForm)
    pnlBuscar: TPanel;
    lblBuscar: TLabel;
    edtBuscar: TEdit;
    btnBuscar: TButton;
    dbgClientes: TDBGrid;
    pnlDatos: TPanel;
    lblRut: TLabel;
    lblRazon: TLabel;
    lblDireccion: TLabel;
    lblComuna: TLabel;
    lblRegion: TLabel;
    lblTipo: TLabel;
    lblTelefono: TLabel;
    lblEmail: TLabel;
    lblDeuda: TLabel;
    lblFechaVenc: TLabel;
    dbeRut: TDBEdit;
    dbeRazon: TDBEdit;
    dbeDireccion: TDBEdit;
    dbeComuna: TDBEdit;
    dblRegion: TDBLookupComboBox;
    dbcTipo: TDBComboBox;
    dbeTelefono: TDBEdit;
    dbeEmail: TDBEdit;
    dbeDeuda: TDBEdit;
    dbeFechaVenc: TDBEdit;
    dbkActivo: TDBCheckBox;
    pnlBotones: TPanel;
    btnNuevo: TButton;
    btnGuardar: TButton;
    btnCancelar: TButton;
    btnEliminar: TButton;
    btnCerrar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnBuscarClick(Sender: TObject);
    procedure btnNuevoClick(Sender: TObject);
    procedure btnGuardarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnEliminarClick(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
    procedure TblClientesBeforePost(DataSet: TDataSet);
  private
    function ChkRut(const S: string): Boolean;
  public
  end;

var
  FrmClientes: TFrmClientes;

implementation

uses
  UDMPrincipal, UGlobales, UUtilidades;

{$R *.dfm}

procedure TFrmClientes.FormCreate(Sender: TObject);
begin
  DMPrincipal.tblClientes.BeforePost := TblClientesBeforePost;
  dbcTipo.Items.Clear;
  dbcTipo.Items.Add('N');
  dbcTipo.Items.Add('V');
  DMPrincipal.tblClientes.First;
end;

procedure TFrmClientes.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if DMPrincipal.tblClientes.State in [dsEdit, dsInsert] then
    DMPrincipal.tblClientes.Cancel;
  DMPrincipal.tblClientes.BeforePost := nil;
end;

{ verifica el digito del rut }
function TFrmClientes.ChkRut(const S: string): Boolean;
var
  r, c: string;
  i, suma, m, dv: Integer;
  d: Char;
begin
  r := '';
  for i := 1 to Length(S) do
    if S[i] in ['0'..'9', 'K', 'k'] then
      r := r + UpCase(S[i]);
  Result := False;
  if Length(r) < 8 then
    Exit;
  c := Copy(r, 1, Length(r) - 1);
  suma := 0;
  m := 2;
  for i := Length(c) downto 1 do
  begin
    suma := suma + (Ord(c[i]) - 48) * m;
    m := m + 1;
    if m = 8 then
      m := 2;
  end;
  dv := 11 - (suma mod 11);
  if dv = 10 then
    d := '0'
  else if dv = 11 then
    d := 'K'
  else
    d := IntToStr(dv)[1];
  Result := r[Length(r)] = d;
end;

procedure TFrmClientes.TblClientesBeforePost(DataSet: TDataSet);
begin
  if not ChkRut(DataSet.FieldByName('RUT').AsString) then
  begin
    MessageDlg('RUT invalido', mtError, [mbOK], 0);
    dbeRut.SetFocus;
    Abort;
  end;
  if Trim(DataSet.FieldByName('RAZON_SOCIAL').AsString) = '' then
  begin
    MessageDlg('Debe ingresar la razon social', mtError, [mbOK], 0);
    Abort;
  end;
  if DataSet.FieldByName('COD_REGION').IsNull then
    DataSet.FieldByName('COD_REGION').AsInteger := 13;
  if DataSet.FieldByName('TIPO').AsString = '' then
    DataSet.FieldByName('TIPO').AsString := 'N';
  if (DataSet.FieldByName('TIPO').AsString = 'V') and (gNivelUsuario < 1) then
  begin
    MessageDlg('Solo un supervisor puede marcar clientes VIP', mtWarning, [mbOK], 0);
    Abort;
  end;
  if (DataSet.FieldByName('EMAIL').AsString <> '') and
     (Pos('@', DataSet.FieldByName('EMAIL').AsString) = 0) then
  begin
    MessageDlg('Email invalido', mtError, [mbOK], 0);
    Abort;
  end;
  if DataSet.State = dsInsert then
  begin
    DataSet.FieldByName('FECHA_ALTA').AsDateTime := Date;
    DataSet.FieldByName('ACTIVO').AsBoolean := True;
    DataSet.FieldByName('DEUDA_VENCIDA').AsFloat := 0;
  end;
end;

procedure TFrmClientes.btnBuscarClick(Sender: TObject);
begin
  if Trim(edtBuscar.Text) = '' then
    Exit;
  with DMPrincipal.qryAux do
  begin
    Close;
    SQL.Text := 'SELECT ID_CLIENTE FROM CLIENTES WHERE RAZON_SOCIAL LIKE ''%' +
      UpperCase(edtBuscar.Text) + '%'' OR RUT = ''' + edtBuscar.Text + '''';
    Open;
    if IsEmpty then
      ShowMessage('No se encontraron clientes')
    else
      DMPrincipal.tblClientes.Locate('ID_CLIENTE', FieldByName('ID_CLIENTE').AsInteger, []);
    Close;
  end;
end;

procedure TFrmClientes.btnNuevoClick(Sender: TObject);
begin
  DMPrincipal.tblClientes.Append;
  gModoEdicion := True;
  dbeRut.SetFocus;
end;

procedure TFrmClientes.btnGuardarClick(Sender: TObject);
var
  n: Integer;
begin
  with DMPrincipal.tblClientes do
  begin
    if not (State in [dsEdit, dsInsert]) then
      Edit;
    FieldByName('RAZON_SOCIAL').AsString := UpperCase(Trim(FieldByName('RAZON_SOCIAL').AsString));
    FieldByName('RUT').AsString := FormatearRut(FieldByName('RUT').AsString);

    // rut repetido
    n := DMPrincipal.TraerValor('SELECT COUNT(*) FROM CLIENTES WHERE RUT = ''' +
      FieldByName('RUT').AsString + ''' AND ID_CLIENTE <> ' +
      IntToStr(FieldByName('ID_CLIENTE').AsInteger));
    if n > 0 then
    begin
      MessageDlg('Ya existe un cliente con ese RUT', mtError, [mbOK], 0);
      Exit;
    end;

    // si se borra la deuda se borra la fecha
    if FieldByName('DEUDA_VENCIDA').AsFloat <= 0 then
      FieldByName('FECHA_VENC_DEUDA').Clear;

    Post;
  end;
  gModoEdicion := False;
end;

procedure TFrmClientes.btnCancelarClick(Sender: TObject);
begin
  DMPrincipal.tblClientes.Cancel;
  gModoEdicion := False;
end;

procedure TFrmClientes.btnEliminarClick(Sender: TObject);
var
  n: Integer;
begin
  if MessageDlg('Eliminar el cliente?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  n := DMPrincipal.TraerValor('SELECT COUNT(*) FROM PEDIDOS WHERE ID_CLIENTE = ' +
    DMPrincipal.tblClientes.FieldByName('ID_CLIENTE').AsString);
  if n > 0 then
  begin
    // tiene pedidos, solo se desactiva
    DMPrincipal.tblClientes.Edit;
    DMPrincipal.tblClientes.FieldByName('ACTIVO').AsBoolean := False;
    DMPrincipal.tblClientes.Post;
    ShowMessage('El cliente tiene pedidos. Se dejo inactivo.');
  end
  else
    DMPrincipal.tblClientes.Delete;
end;

procedure TFrmClientes.btnCerrarClick(Sender: TObject);
begin
  Close;
end;

end.
