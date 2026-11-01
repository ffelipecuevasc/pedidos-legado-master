unit UFrmProductos;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, DBGrids, DBCtrls, Mask, DB;

type
  TFrmProductos = class(TForm)
    dbgProductos: TDBGrid;
    pnlDatos: TPanel;
    lblCodigo: TLabel;
    lblDescripcion: TLabel;
    lblCategoria: TLabel;
    lblPrecio: TLabel;
    lblStock: TLabel;
    lblMinimo: TLabel;
    dbeCodigo: TDBEdit;
    dbeDescripcion: TDBEdit;
    dbcCategoria: TDBComboBox;
    dbePrecio: TDBEdit;
    dbeStock: TDBEdit;
    dbeMinimo: TDBEdit;
    dbkActivo: TDBCheckBox;
    navProductos: TDBNavigator;
    grpPrecios: TGroupBox;
    lblPorc: TLabel;
    edtPorc: TEdit;
    cmbCategoria: TComboBox;
    btnActualizar: TButton;
    btnCerrar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TblProductosBeforePost(DataSet: TDataSet);
    procedure dbgProductosDrawColumnCell(Sender: TObject; const Rect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState);
    procedure btnActualizarClick(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
  private
  public
  end;

var
  FrmProductos: TFrmProductos;

implementation

uses
  UDMPrincipal, UGlobales, UUtilidades;

{$R *.dfm}

const
  CATEGORIAS: array[0..5] of string = ('ABA', 'BEB', 'CON', 'LAC', 'LIM', 'OFE');

procedure TFrmProductos.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  DMPrincipal.tblProductos.BeforePost := TblProductosBeforePost;
  dbcCategoria.Items.Clear;
  cmbCategoria.Items.Clear;
  for i := Low(CATEGORIAS) to High(CATEGORIAS) do
  begin
    dbcCategoria.Items.Add(CATEGORIAS[i]);
    cmbCategoria.Items.Add(CATEGORIAS[i]);
  end;
  grpPrecios.Enabled := gNivelUsuario >= 1;
end;

procedure TFrmProductos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if DMPrincipal.tblProductos.State in [dsEdit, dsInsert] then
    DMPrincipal.tblProductos.Cancel;
  DMPrincipal.tblProductos.BeforePost := nil;
end;

procedure TFrmProductos.TblProductosBeforePost(DataSet: TDataSet);
var
  i: Integer;
  ok: Boolean;
begin
  DataSet.FieldByName('CODIGO').AsString := UpperCase(Trim(DataSet.FieldByName('CODIGO').AsString));
  if DataSet.FieldByName('CODIGO').AsString = '' then
  begin
    MessageDlg('Falta el codigo', mtError, [mbOK], 0);
    Abort;
  end;
  if DataSet.FieldByName('PRECIO').AsFloat <= 0 then
  begin
    MessageDlg('El precio debe ser mayor a cero', mtError, [mbOK], 0);
    Abort;
  end;
  ok := False;
  for i := Low(CATEGORIAS) to High(CATEGORIAS) do
    if DataSet.FieldByName('CATEGORIA').AsString = CATEGORIAS[i] then
      ok := True;
  if not ok then
  begin
    MessageDlg('Categoria no valida', mtError, [mbOK], 0);
    Abort;
  end;
  if DataSet.FieldByName('STOCK_MINIMO').IsNull then
    DataSet.FieldByName('STOCK_MINIMO').AsInteger := 10;
  // las ofertas no se reponen
  if DataSet.FieldByName('CATEGORIA').AsString = 'OFE' then
    DataSet.FieldByName('STOCK_MINIMO').AsInteger := 0;
end;

procedure TFrmProductos.dbgProductosDrawColumnCell(Sender: TObject;
  const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  with DMPrincipal.tblProductos do
    if FieldByName('STOCK').AsInteger < FieldByName('STOCK_MINIMO').AsInteger then
      dbgProductos.Canvas.Font.Color := clRed;
  dbgProductos.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TFrmProductos.btnActualizarClick(Sender: TObject);
var
  p: Double;
begin
  p := StrToFloatDef(edtPorc.Text, 0);
  if p = 0 then
    Exit;
  if (p > 30) and (gNivelUsuario < 9) then
  begin
    ShowMessage('Reajustes sobre 30% solo los hace el administrador');
    Exit;
  end;
  if MessageDlg('Reajustar ' + edtPorc.Text + '% la categoria ' + cmbCategoria.Text + '?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  DMPrincipal.EjecutarSQL('UPDATE PRODUCTOS SET PRECIO = PRECIO * (1 + ' +
    edtPorc.Text + ' / 100) WHERE CATEGORIA = ''' + cmbCategoria.Text + '''');
  DMPrincipal.tblProductos.Refresh;
  ShowMessage('Precios actualizados');
end;

procedure TFrmProductos.btnCerrarClick(Sender: TObject);
begin
  Close;
end;

end.
