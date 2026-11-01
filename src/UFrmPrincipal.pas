unit UFrmPrincipal;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ComCtrls, ExtCtrls, StdCtrls, Buttons;

type
  TFrmPrincipal = class(TForm)
    mnuPrincipal: TMainMenu;
    mnuArchivo: TMenuItem;
    mnuSalir: TMenuItem;
    mnuMaestros: TMenuItem;
    mnuClientes: TMenuItem;
    mnuProductos: TMenuItem;
    mnuPedidos: TMenuItem;
    mnuNuevoPedido: TMenuItem;
    mnuAnularPedido: TMenuItem;
    mnuInformes: TMenuItem;
    mnuInfVentas: TMenuItem;
    mnuAyuda: TMenuItem;
    mnuAcercaDe: TMenuItem;
    N1: TMenuItem;
    stbPrincipal: TStatusBar;
    pnlBotones: TPanel;
    btnClientes: TSpeedButton;
    btnProductos: TSpeedButton;
    btnPedidos: TSpeedButton;
    btnInformes: TSpeedButton;
    imgFondo: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure mnuSalirClick(Sender: TObject);
    procedure mnuClientesClick(Sender: TObject);
    procedure mnuProductosClick(Sender: TObject);
    procedure mnuNuevoPedidoClick(Sender: TObject);
    procedure mnuAnularPedidoClick(Sender: TObject);
    procedure mnuInfVentasClick(Sender: TObject);
    procedure mnuAcercaDeClick(Sender: TObject);
  private
    procedure Login;
  public
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses
  UGlobales, UDMPrincipal, UStock, UFrmClientes, UFrmProductos, UFrmPedidos,
  UFrmInformes;

{$R *.dfm}

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  // para que el SQL no falle con la coma
  DecimalSeparator := '.';
  ThousandSeparator := ',';
  ShortDateFormat := 'dd/mm/yy';
  DateSeparator := '/';
  Login;
end;

procedure TFrmPrincipal.Login;
var
  u: string;
begin
  u := UpperCase(Trim(InputBox('Ingreso', 'Usuario:', '')));
  if u = '' then
  begin
    Application.Terminate;
    Exit;
  end;
  gUsuarioActual := u;
  if (u = 'ADMIN') or (u = 'JPV') then
    gNivelUsuario := 9
  else if Copy(u, 1, 3) = 'SUP' then
    gNivelUsuario := 1
  else
    gNivelUsuario := 0;
  stbPrincipal.Panels[0].Text := 'Usuario: ' + gUsuarioActual;
  stbPrincipal.Panels[1].Text := gNombreEmpresa;
  stbPrincipal.Panels[2].Text := 'v' + VERSION_SISTEMA;
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
var
  L: TStringList;
begin
  L := ProductosBajoMinimo;
  try
    if L.Count > 0 then
      MessageDlg('Productos bajo stock minimo:' + #13 + L.Text, mtWarning, [mbOK], 0);
  finally
    L.Free;
  end;
end;

procedure TFrmPrincipal.mnuSalirClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmPrincipal.mnuClientesClick(Sender: TObject);
begin
  FrmClientes := TFrmClientes.Create(Self);
  try
    FrmClientes.ShowModal;
  finally
    FrmClientes.Free;
  end;
end;

procedure TFrmPrincipal.mnuProductosClick(Sender: TObject);
begin
  FrmProductos := TFrmProductos.Create(Self);
  try
    FrmProductos.ShowModal;
  finally
    FrmProductos.Free;
  end;
end;

procedure TFrmPrincipal.mnuNuevoPedidoClick(Sender: TObject);
begin
  FrmPedidos := TFrmPedidos.Create(Self);
  try
    FrmPedidos.ShowModal;
  finally
    FrmPedidos.Free;
  end;
end;

procedure TFrmPrincipal.mnuAnularPedidoClick(Sender: TObject);
var
  s: string;
begin
  if gNivelUsuario < 1 then
  begin
    ShowMessage('Solo supervisores pueden anular pedidos');
    Exit;
  end;
  s := InputBox('Anular pedido', 'Numero de pedido:', '');
  if s = '' then
    Exit;
  if MessageDlg('Anular el pedido ' + s + '?', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;
  DMPrincipal.EjecutarSQL('UPDATE PEDIDOS SET ESTADO = ''A'' WHERE NRO_PEDIDO = ' + s);
  DevolverStock(StrToInt(s));
  ShowMessage('Pedido anulado');
end;

procedure TFrmPrincipal.mnuInfVentasClick(Sender: TObject);
begin
  FrmInformes := TFrmInformes.Create(Self);
  try
    FrmInformes.ShowModal;
  finally
    FrmInformes.Free;
  end;
end;

procedure TFrmPrincipal.mnuAcercaDeClick(Sender: TObject);
begin
  ShowMessage('Sistema de Pedidos v' + VERSION_SISTEMA + #13 +
    'Depto. Informatica - 2008');
end;

end.
