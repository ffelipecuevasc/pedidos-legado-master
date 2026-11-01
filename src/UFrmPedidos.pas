unit UFrmPedidos;

{ Toma de pedidos
  - 2006: version inicial
  - 2007: descuentos por volumen
  - 2008: recalculo en grabacion (ver JPV) }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Grids, DB, dbisamtb, UCalculoTotales;

type
  TLineaPedido = record
    IdProducto: Integer;
    Codigo: string;
    Descripcion: string;
    Categoria: string;
    Cantidad: Integer;
    Precio: Double;
  end;

  TFrmPedidos = class(TForm)
    pnlCliente: TPanel;
    lblRut: TLabel;
    edtRut: TEdit;
    btnBuscarCliente: TButton;
    lblCliente: TLabel;
    lblRegion: TLabel;
    lblTipo: TLabel;
    lblFecha: TLabel;
    pnlProducto: TPanel;
    lblCodProd: TLabel;
    edtCodProd: TEdit;
    lblCantidad: TLabel;
    edtCantidad: TEdit;
    btnAgregar: TButton;
    btnQuitar: TButton;
    sgLineas: TStringGrid;
    pnlTotales: TPanel;
    lblSubtotal: TLabel;
    lblDescuento: TLabel;
    lblFlete: TLabel;
    lblNeto: TLabel;
    lblIva: TLabel;
    lblTotal: TLabel;
    memObs: TMemo;
    chkConfirmar: TCheckBox;
    btnGrabar: TButton;
    btnNuevo: TButton;
    btnCerrar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnBuscarClienteClick(Sender: TObject);
    procedure btnAgregarClick(Sender: TObject);
    procedure btnQuitarClick(Sender: TObject);
    procedure btnGrabarClick(Sender: TObject);
    procedure btnNuevoClick(Sender: TObject);
    procedure btnCerrarClick(Sender: TObject);
  private
    FIdCliente: Integer;
    FTipoCliente: Char;
    FCodRegion: Integer;
    FFleteBase: Double;
    FLineas: array of TLineaPedido;
    FTotales: TTotalesPedido;
    procedure Limpiar;
    procedure Proc2;
    procedure RecalcularTotales;
  public
  end;

var
  FrmPedidos: TFrmPedidos;

implementation

uses
  UDMPrincipal, UGlobales, UUtilidades, UStock;

{$R *.dfm}

procedure TFrmPedidos.FormCreate(Sender: TObject);
begin
  sgLineas.ColCount := 6;
  sgLineas.Cells[0, 0] := 'Codigo';
  sgLineas.Cells[1, 0] := 'Descripcion';
  sgLineas.Cells[2, 0] := 'Cat';
  sgLineas.Cells[3, 0] := 'Cant';
  sgLineas.Cells[4, 0] := 'Precio';
  sgLineas.Cells[5, 0] := 'Total';
end;

procedure TFrmPedidos.FormShow(Sender: TObject);
begin
  Limpiar;
end;

procedure TFrmPedidos.Limpiar;
begin
  FIdCliente := 0;
  FTipoCliente := 'N';
  FCodRegion := 0;
  FFleteBase := 0;
  SetLength(FLineas, 0);
  edtRut.Text := '';
  lblCliente.Caption := '';
  lblRegion.Caption := '';
  lblTipo.Caption := '';
  memObs.Lines.Clear;
  chkConfirmar.Checked := True;
  lblFecha.Caption := 'Fecha: ' + FechaAStr(FechaPedido(Now));
  Proc2;
  RecalcularTotales;
  edtRut.SetFocus;
end;

{ pinta la grilla }
procedure TFrmPedidos.Proc2;
var
  i: Integer;
begin
  sgLineas.RowCount := Length(FLineas) + 2;
  for i := 0 to High(FLineas) do
  begin
    sgLineas.Cells[0, i + 1] := FLineas[i].Codigo;
    sgLineas.Cells[1, i + 1] := FLineas[i].Descripcion;
    sgLineas.Cells[2, i + 1] := FLineas[i].Categoria;
    sgLineas.Cells[3, i + 1] := IntToStr(FLineas[i].Cantidad);
    sgLineas.Cells[4, i + 1] := FormatearMonto(FLineas[i].Precio);
    sgLineas.Cells[5, i + 1] := FormatearMonto(FLineas[i].Cantidad * FLineas[i].Precio);
  end;
  sgLineas.Rows[Length(FLineas) + 1].Clear;
end;

procedure TFrmPedidos.RecalcularTotales;
var
  L: TLineasCalculo;
  i: Integer;
begin
  SetLength(L, Length(FLineas));
  for i := 0 to High(FLineas) do
  begin
    L[i].Cantidad := FLineas[i].Cantidad;
    L[i].PrecioUnit := FLineas[i].Precio;
    L[i].Categoria := FLineas[i].Categoria;
  end;
  FTotales := CalcularTotales(L, FTipoCliente, FCodRegion, FFleteBase, gTasaIva);
  lblSubtotal.Caption := 'Subtotal: ' + FormatearMonto(FTotales.Subtotal);
  lblDescuento.Caption := 'Descuento (' + FloatToStr(FTotales.PorcDescuento) + '%): ' +
    FormatearMonto(FTotales.Descuento);
  lblFlete.Caption := 'Flete: ' + FormatearMonto(FTotales.Flete);
  lblNeto.Caption := 'Neto: ' + FormatearMonto(FTotales.Neto);
  lblIva.Caption := 'IVA: ' + FormatearMonto(FTotales.Iva);
  lblTotal.Caption := 'TOTAL: ' + FormatearMonto(FTotales.Total);
end;

procedure TFrmPedidos.btnBuscarClienteClick(Sender: TObject);
begin
  if not ValidarRut(edtRut.Text) then
  begin
    MessageDlg('RUT no valido', mtError, [mbOK], 0);
    Exit;
  end;
  edtRut.Text := FormatearRut(edtRut.Text);
  with DMPrincipal.qryAux do
  begin
    Close;
    SQL.Text := 'SELECT C.ID_CLIENTE, C.RAZON_SOCIAL, C.TIPO, C.COD_REGION, ' +
      'R.NOMBRE, R.FLETE_BASE FROM CLIENTES C ' +
      'INNER JOIN REGIONES R ON R.COD_REGION = C.COD_REGION ' +
      'WHERE C.ACTIVO = TRUE AND C.RUT = ''' + edtRut.Text + '''';
    Open;
    if IsEmpty then
    begin
      Close;
      ShowMessage('Cliente no encontrado o inactivo');
      Exit;
    end;
    FIdCliente := FieldByName('ID_CLIENTE').AsInteger;
    if FieldByName('TIPO').AsString = '' then
      FTipoCliente := 'N'
    else
      FTipoCliente := FieldByName('TIPO').AsString[1];
    FCodRegion := FieldByName('COD_REGION').AsInteger;
    FFleteBase := FieldByName('FLETE_BASE').AsFloat;
    lblCliente.Caption := FieldByName('RAZON_SOCIAL').AsString;
    lblRegion.Caption := 'Region: ' + FieldByName('NOMBRE').AsString;
    if FTipoCliente = 'V' then
      lblTipo.Caption := 'CLIENTE VIP'
    else
      lblTipo.Caption := '';
    Close;
  end;
  RecalcularTotales;
  edtCodProd.SetFocus;
end;

procedure TFrmPedidos.btnAgregarClick(Sender: TObject);
var
  n, cant: Integer;
begin
  cant := StrToIntDef(edtCantidad.Text, 0);
  if cant <= 0 then
  begin
    ShowMessage('Cantidad invalida');
    Exit;
  end;
  if Length(FLineas) >= MAX_LINEAS_PEDIDO then
  begin
    ShowMessage('Maximo de lineas alcanzado');
    Exit;
  end;
  with DMPrincipal.qryAux do
  begin
    Close;
    SQL.Text := 'SELECT * FROM PRODUCTOS WHERE ACTIVO = TRUE AND CODIGO = ''' +
      UpperCase(edtCodProd.Text) + '''';
    Open;
    if IsEmpty then
    begin
      Close;
      ShowMessage('Producto no existe');
      Exit;
    end;
    if FieldByName('STOCK').AsInteger < cant then
      MessageDlg('Atencion: stock disponible ' + FieldByName('STOCK').AsString,
        mtWarning, [mbOK], 0);
    n := Length(FLineas);
    SetLength(FLineas, n + 1);
    FLineas[n].IdProducto := FieldByName('ID_PRODUCTO').AsInteger;
    FLineas[n].Codigo := FieldByName('CODIGO').AsString;
    FLineas[n].Descripcion := FieldByName('DESCRIPCION').AsString;
    FLineas[n].Categoria := FieldByName('CATEGORIA').AsString;
    FLineas[n].Precio := FieldByName('PRECIO').AsFloat;
    FLineas[n].Cantidad := cant;
    Close;
  end;
  Proc2;
  RecalcularTotales;
  edtCodProd.Text := '';
  edtCantidad.Text := '';
  edtCodProd.SetFocus;
end;

procedure TFrmPedidos.btnQuitarClick(Sender: TObject);
var
  i, f: Integer;
begin
  f := sgLineas.Row - 1;
  if (f < 0) or (f > High(FLineas)) then
    Exit;
  for i := f to High(FLineas) - 1 do
    FLineas[i] := FLineas[i + 1];
  SetLength(FLineas, Length(FLineas) - 1);
  Proc2;
  RecalcularTotales;
end;

procedure TFrmPedidos.btnGrabarClick(Sender: TObject);
var
  vNro, i, vDias: Integer;
  vMomento, vFecha: TDateTime;
  vSQL, vEstado, vObs, vArchivo: string;
  vSubtotalSQL, vPorc, vDesc, vNeto, vIva, vTotal, vDeuda: Double;
  F: TextFile;
begin
  // validaciones basicas
  if FIdCliente = 0 then
  begin
    MessageDlg('Debe seleccionar un cliente', mtError, [mbOK], 0);
    edtRut.SetFocus;
    Exit;
  end;
  if Length(FLineas) = 0 then
  begin
    MessageDlg('El pedido no tiene lineas', mtError, [mbOK], 0);
    Exit;
  end;

  // clientes morosos
  with DMPrincipal.qryAux do
  begin
    Close;
    SQL.Text := 'SELECT DEUDA_VENCIDA, FECHA_VENC_DEUDA FROM CLIENTES WHERE ID_CLIENTE = ' +
      IntToStr(FIdCliente);
    Open;
    vDeuda := FieldByName('DEUDA_VENCIDA').AsFloat;
    vDias := 0;
    if not FieldByName('FECHA_VENC_DEUDA').IsNull then
      vDias := DiasVencidos(FieldByName('FECHA_VENC_DEUDA').AsDateTime);
    Close;
  end;
  if (vDeuda > 0) and (vDias > 60) then
  begin
    MessageDlg('El cliente tiene deuda vencida hace ' + IntToStr(vDias) +
      ' dias por ' + FormatearMonto(vDeuda) + '.' + #13 +
      'No se pueden ingresar pedidos. Derivar a Cobranza.', mtError, [mbOK], 0);
    Exit;
  end;

  // fecha del pedido
  vMomento := Now;
  vFecha := FechaPedido(vMomento);
  if Trunc(vFecha) <> Date then
    if MessageDlg('El pedido quedara con fecha ' + FechaAStr(vFecha) + '. Continuar?',
      mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
      Exit;

  if MessageDlg('Confirma la grabacion del pedido por ' + FormatearMonto(FTotales.Total) + '?',
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  if chkConfirmar.Checked then
    vEstado := 'C'
  else
    vEstado := 'P';

  vObs := memObs.Lines.Text;
  if Length(vObs) > 250 then
    vObs := Copy(vObs, 1, 250);

  Screen.Cursor := crHourGlass;
  vNro := DMPrincipal.SiguienteNroPedido;
  DMPrincipal.dbPedidos.StartTransaction;
  try
    // cabecera
    vSQL := 'INSERT INTO PEDIDOS (NRO_PEDIDO, FECHA, FECHA_INGRESO, ID_CLIENTE, ESTADO, ' +
      'SUBTOTAL, DESCUENTO, FLETE, NETO, IVA, TOTAL, USUARIO, OBSERVACION) VALUES (';
    vSQL := vSQL + IntToStr(vNro) + ', ';
    vSQL := vSQL + FechaSQL(vFecha) + ', ';
    vSQL := vSQL + '''' + FormatDateTime('yyyy-mm-dd hh:nn:ss', vMomento) + ''', ';
    vSQL := vSQL + IntToStr(FIdCliente) + ', ';
    vSQL := vSQL + '''' + vEstado + ''', ';
    vSQL := vSQL + FloatToStr(FTotales.Subtotal) + ', ';
    vSQL := vSQL + FloatToStr(FTotales.Descuento) + ', ';
    vSQL := vSQL + FloatToStr(FTotales.Flete) + ', ';
    vSQL := vSQL + FloatToStr(FTotales.Neto) + ', ';
    vSQL := vSQL + FloatToStr(FTotales.Iva) + ', ';
    vSQL := vSQL + FloatToStr(FTotales.Total) + ', ';
    vSQL := vSQL + '''' + gUsuarioActual + ''', ';
    vSQL := vSQL + '''' + vObs + ''')';
    DMPrincipal.EjecutarSQL(vSQL);

    // detalle
    for i := 0 to High(FLineas) do
    begin
      vSQL := 'INSERT INTO PEDIDO_LINEAS (NRO_PEDIDO, LINEA, ID_PRODUCTO, CANTIDAD, ' +
        'PRECIO_UNIT, TOTAL_LINEA) VALUES (' +
        IntToStr(vNro) + ', ' +
        IntToStr(i + 1) + ', ' +
        IntToStr(FLineas[i].IdProducto) + ', ' +
        IntToStr(FLineas[i].Cantidad) + ', ' +
        FloatToStr(FLineas[i].Precio) + ', ' +
        FloatToStr(FLineas[i].Cantidad * FLineas[i].Precio) + ')';
      DMPrincipal.EjecutarSQL(vSQL);
    end;

    // recalculo desde la base (los totales de pantalla no cuadraban con el informe)
    with DMPrincipal.qryAux do
    begin
      Close;
      SQL.Text := 'SELECT SUM(CANTIDAD * PRECIO_UNIT) AS TOT FROM PEDIDO_LINEAS ' +
        'WHERE NRO_PEDIDO = ' + IntToStr(vNro);
      Open;
      vSubtotalSQL := FieldByName('TOT').AsFloat;
      Close;
    end;

    // monto minimo (en Santiago no se cobra minimo)
    if (vSubtotalSQL < 30000) and (FCodRegion <> 13) then
    begin
      DMPrincipal.dbPedidos.Rollback;
      Screen.Cursor := crDefault;
      MessageDlg('El pedido no alcanza el monto minimo de $30.000', mtWarning, [mbOK], 0);
      Exit;
    end;

    vPorc := 0;
    if vSubtotalSQL >= 1000000 then
      vPorc := 8
    else if vSubtotalSQL >= 500000 then
      vPorc := 5;
    if FTipoCliente = 'V' then
      vPorc := vPorc + 3;
    if vPorc > 10 then
      vPorc := 10;
    vDesc := Redondear(vSubtotalSQL * vPorc / 100);
    vNeto := vSubtotalSQL - vDesc + FTotales.Flete;
    vIva := Redondear(vNeto * gTasaIva / 100);
    vTotal := vNeto + vIva;

    vSQL := 'UPDATE PEDIDOS SET SUBTOTAL = ' + FloatToStr(vSubtotalSQL) +
      ', DESCUENTO = ' + FloatToStr(vDesc) +
      ', NETO = ' + FloatToStr(vNeto) +
      ', IVA = ' + FloatToStr(vIva) +
      ', TOTAL = ' + FloatToStr(vTotal) +
      ' WHERE NRO_PEDIDO = ' + IntToStr(vNro);
    DMPrincipal.EjecutarSQL(vSQL);

    // stock solo si se confirma
    if vEstado = 'C' then
      for i := 0 to High(FLineas) do
        DescontarStock(FLineas[i].IdProducto, FLineas[i].Cantidad, FTipoCliente, vNro);

    DMPrincipal.dbPedidos.Commit;
  except
    on E: Exception do
    begin
      DMPrincipal.dbPedidos.Rollback;
      Screen.Cursor := crDefault;
      gUltimoError := E.Message;
      MessageDlg('Error al grabar el pedido:' + #13 + E.Message, mtError, [mbOK], 0);
      Exit;
    end;
  end;
  Screen.Cursor := crDefault;

  // ticket para la bodega
  if gImprimirAlGrabar then
  begin
    vArchivo := gDirTickets + '\PED' + IntToStr(vNro) + '.TXT';
    try
      AssignFile(F, vArchivo);
      Rewrite(F);
      Writeln(F, gNombreEmpresa);
      Writeln(F, 'PEDIDO NRO ' + IntToStr(vNro) + '   FECHA ' + FechaAStr(vFecha));
      Writeln(F, 'CLIENTE: ' + lblCliente.Caption);
      Writeln(F, 'RUT    : ' + edtRut.Text);
      Writeln(F, StringOfChar('-', 60));
      for i := 0 to High(FLineas) do
        Writeln(F, Rellenar(FLineas[i].Codigo, 10) +
          Rellenar(FLineas[i].Descripcion, 30) +
          Rellenar(IntToStr(FLineas[i].Cantidad), 6) +
          FmtPesos(FLineas[i].Cantidad * FLineas[i].Precio));
      Writeln(F, StringOfChar('-', 60));
      Writeln(F, 'NETO : ' + FmtPesos(vNeto));
      Writeln(F, 'IVA  : ' + FmtPesos(vIva));
      Writeln(F, 'TOTAL: ' + FmtPesos(vTotal));
      if vEstado = 'P' then
        Writeln(F, '*** PENDIENTE - NO DESPACHAR ***');
      CloseFile(F);
    except
    end;
  end;

  gPedidoActual := vNro;
  ShowMessage('Pedido ' + IntToStr(vNro) + ' grabado. Total ' + FmtPesos(vTotal));
  Limpiar;
end;

procedure TFrmPedidos.btnNuevoClick(Sender: TObject);
begin
  if Length(FLineas) > 0 then
    if MessageDlg('Descartar el pedido actual?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
      Exit;
  Limpiar;
end;

procedure TFrmPedidos.btnCerrarClick(Sender: TObject);
begin
  Close;
end;

end.
