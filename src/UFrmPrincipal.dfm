object FrmPrincipal: TFrmPrincipal
  Left = 192
  Top = 114
  Width = 800
  Height = 560
  Caption = 'Sistema de Pedidos - Distribuidora'
  Color = clAppWorkSpace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = mnuPrincipal
  OldCreateOrder = False
  Position = poScreenCenter
  WindowState = wsMaximized
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object imgFondo: TImage
    Left = 0
    Top = 41
    Width = 792
    Height = 454
    Align = alClient
    Center = True
  end
  object stbPrincipal: TStatusBar
    Left = 0
    Top = 495
    Width = 792
    Height = 19
    Panels = <
      item
        Width = 200
      end
      item
        Width = 350
      end
      item
        Width = 80
      end>
  end
  object pnlBotones: TPanel
    Left = 0
    Top = 0
    Width = 792
    Height = 41
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 1
    object btnClientes: TSpeedButton
      Left = 8
      Top = 4
      Width = 90
      Height = 33
      Caption = 'Clientes'
      Flat = True
      OnClick = mnuClientesClick
    end
    object btnProductos: TSpeedButton
      Left = 100
      Top = 4
      Width = 90
      Height = 33
      Caption = 'Productos'
      Flat = True
      OnClick = mnuProductosClick
    end
    object btnPedidos: TSpeedButton
      Left = 192
      Top = 4
      Width = 90
      Height = 33
      Caption = 'Pedidos'
      Flat = True
      OnClick = mnuNuevoPedidoClick
    end
    object btnInformes: TSpeedButton
      Left = 284
      Top = 4
      Width = 90
      Height = 33
      Caption = 'Informes'
      Flat = True
      OnClick = mnuInfVentasClick
    end
  end
  object mnuPrincipal: TMainMenu
    Left = 400
    Top = 8
    object mnuArchivo: TMenuItem
      Caption = '&Archivo'
      object mnuSalir: TMenuItem
        Caption = '&Salir'
        OnClick = mnuSalirClick
      end
    end
    object mnuMaestros: TMenuItem
      Caption = '&Maestros'
      object mnuClientes: TMenuItem
        Caption = '&Clientes'
        ShortCut = 112
        OnClick = mnuClientesClick
      end
      object mnuProductos: TMenuItem
        Caption = '&Productos'
        ShortCut = 113
        OnClick = mnuProductosClick
      end
    end
    object mnuPedidos: TMenuItem
      Caption = '&Pedidos'
      object mnuNuevoPedido: TMenuItem
        Caption = '&Nuevo pedido'
        ShortCut = 114
        OnClick = mnuNuevoPedidoClick
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mnuAnularPedido: TMenuItem
        Caption = '&Anular pedido...'
        OnClick = mnuAnularPedidoClick
      end
    end
    object mnuInformes: TMenuItem
      Caption = '&Informes'
      object mnuInfVentas: TMenuItem
        Caption = '&Ventas por per'#237'odo'
        OnClick = mnuInfVentasClick
      end
    end
    object mnuAyuda: TMenuItem
      Caption = 'A&yuda'
      object mnuAcercaDe: TMenuItem
        Caption = '&Acerca de...'
        OnClick = mnuAcercaDeClick
      end
    end
  end
end
