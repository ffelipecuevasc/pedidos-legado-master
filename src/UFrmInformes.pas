unit UFrmInformes;

{ Informe de ventas por periodo. Exporta a CSV para Excel }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, DBGrids, DB, dbisamtb;

type
  TFrmInformes = class(TForm)
    pnlFiltros: TPanel;
    lblDesde: TLabel;
    lblHasta: TLabel;
    lblRegion: TLabel;
    lblCliente: TLabel;
    edtDesde: TEdit;
    edtHasta: TEdit;
    cmbRegion: TComboBox;
    edtCliente: TEdit;
    chkAnulados: TCheckBox;
    btnGenerar: TButton;
    btnExportar: TButton;
    dbgInforme: TDBGrid;
    pnlResumen: TPanel;
    lblCantPedidos: TLabel;
    lblTotNeto: TLabel;
    lblTotIva: TLabel;
    lblTotTotal: TLabel;
    btnCerrar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnGenerarClick(Sender: TObject);
    procedure btnExportarClick(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
  private
    procedure CargarRegiones;
  public
  end;

var
  FrmInformes: TFrmInformes;

implementation

uses
  DateUtils, UDMPrincipal, UGlobales, UUtilidades;

{$R *.dfm}

procedure TFrmInformes.FormCreate(Sender: TObject);
begin
  edtDesde.Text := FechaAStr(StartOfTheMonth(Date));
  edtHasta.Text := FechaAStr(Date);
  CargarRegiones;
end;

procedure TFrmInformes.CargarRegiones;
begin
  cmbRegion.Items.Clear;
  cmbRegion.Items.Add('(Todas)');
  with DMPrincipal.tblRegiones do
  begin
    First;
    while not Eof do
    begin
      cmbRegion.Items.Add(FieldByName('NOMBRE').AsString);
      Next;
    end;
  end;
  cmbRegion.ItemIndex := 0;
end;

procedure TFrmInformes.btnGenerarClick(Sender: TObject);
var
  vSQL: string;
  vDesde, vHasta: TDateTime;
  vNeto, vIva, vTotal: Double;
  n: Integer;
begin
  vDesde := StrAFecha(edtDesde.Text);
  vHasta := StrAFecha(edtHasta.Text);

  vSQL := 'SELECT P.NRO_PEDIDO, P.FECHA, C.RUT, C.RAZON_SOCIAL, R.NOMBRE AS REGION, ' +
    'P.ESTADO, P.NETO, P.NETO * 0.19 AS IVA, P.NETO * 1.19 AS TOTAL ' +
    'FROM PEDIDOS P ' +
    'INNER JOIN CLIENTES C ON C.ID_CLIENTE = P.ID_CLIENTE ' +
    'INNER JOIN REGIONES R ON R.COD_REGION = C.COD_REGION ' +
    'WHERE P.FECHA >= ' + FechaSQL(vDesde) + ' AND P.FECHA <= ' + FechaSQL(vHasta);
  if not chkAnulados.Checked then
    vSQL := vSQL + ' AND P.ESTADO <> ''A''';
  if cmbRegion.ItemIndex > 0 then
    vSQL := vSQL + ' AND R.NOMBRE = ''' + cmbRegion.Text + '''';
  if Trim(edtCliente.Text) <> '' then
    vSQL := vSQL + ' AND C.RAZON_SOCIAL LIKE ''%' + UpperCase(edtCliente.Text) + '%''';
  vSQL := vSQL + ' ORDER BY P.FECHA, P.NRO_PEDIDO';

  Screen.Cursor := crHourGlass;
  try
    with DMPrincipal.qryInforme do
    begin
      Close;
      SQL.Text := vSQL;
      Open;
      vNeto := 0;
      n := 0;
      DisableControls;
      First;
      while not Eof do
      begin
        vNeto := vNeto + FieldByName('NETO').AsFloat;
        Inc(n);
        Next;
      end;
      First;
      EnableControls;
    end;
  finally
    Screen.Cursor := crDefault;
  end;

  vIva := Redondear(vNeto * 0.19);
  vTotal := vNeto + vIva;
  lblCantPedidos.Caption := 'Pedidos: ' + IntToStr(n);
  lblTotNeto.Caption := 'Neto: ' + FormatearMonto(vNeto);
  lblTotIva.Caption := 'IVA: ' + FormatearMonto(vIva);
  lblTotTotal.Caption := 'Total: ' + FormatearMonto(vTotal);
end;

procedure TFrmInformes.btnExportarClick(Sender: TObject);
var
  L: TStringList;
  s, vArchivo: string;
  i: Integer;
begin
  if not DMPrincipal.qryInforme.Active then
    Exit;
  vArchivo := 'C:\Informes\ventas_' + FormatDateTime('ddmmyy', Date) + '.csv';
  L := TStringList.Create;
  try
    with DMPrincipal.qryInforme do
    begin
      DisableControls;
      s := '';
      for i := 0 to FieldCount - 1 do
        s := s + Fields[i].FieldName + ';';
      L.Add(s);
      First;
      while not Eof do
      begin
        s := '';
        for i := 0 to FieldCount - 1 do
          s := s + Fields[i].AsString + ';';
        L.Add(s);
        Next;
      end;
      First;
      EnableControls;
    end;
    L.SaveToFile(vArchivo);
    ShowMessage('Exportado a ' + vArchivo);
  finally
    L.Free;
  end;
end;

procedure TFrmInformes.btnCerrarClick(Sender: TObject);
begin
  Close;
end;

end.
