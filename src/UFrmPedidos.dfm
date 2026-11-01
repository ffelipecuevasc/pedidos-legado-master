object FrmPedidos: TFrmPedidos
  Left = 180
  Top = 90
  BorderStyle = bsDialog
  Caption = 'Toma de Pedidos'
  ClientHeight = 560
  ClientWidth = 760
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlCliente: TPanel
    Left = 0
    Top = 0
    Width = 760
    Height = 73
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 0
    object lblRut: TLabel
      Left = 8
      Top = 12
      Width = 120
      Height = 13
      Caption = 'RUT cliente:'
    end
    object edtRut: TEdit
      Left = 80
      Top = 8
      Width = 110
      Height = 21
      TabOrder = 0
    end
    object btnBuscarCliente: TButton
      Left = 196
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Buscar'
      TabOrder = 1
      OnClick = btnBuscarClienteClick
    end
    object lblCliente: TLabel
      Left = 284
      Top = 12
      Width = 120
      Height = 13
      Caption = ''
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblRegion: TLabel
      Left = 8
      Top = 44
      Width = 120
      Height = 13
      Caption = 'Regi'#243'n:'
    end
    object lblTipo: TLabel
      Left = 284
      Top = 44
      Width = 120
      Height = 13
      Caption = ''
    end
    object lblFecha: TLabel
      Left = 600
      Top = 12
      Width = 120
      Height = 13
      Caption = 'Fecha:'
    end
  end
  object pnlProducto: TPanel
    Left = 0
    Top = 73
    Width = 760
    Height = 41
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 1
    object lblCodProd: TLabel
      Left = 8
      Top = 14
      Width = 120
      Height = 13
      Caption = 'C'#243'digo:'
    end
    object edtCodProd: TEdit
      Left = 56
      Top = 10
      Width = 90
      Height = 21
      TabOrder = 0
    end
    object lblCantidad: TLabel
      Left = 160
      Top = 14
      Width = 120
      Height = 13
      Caption = 'Cantidad:'
    end
    object edtCantidad: TEdit
      Left = 212
      Top = 10
      Width = 50
      Height = 21
      TabOrder = 1
    end
    object btnAgregar: TButton
      Left = 276
      Top = 8
      Width = 75
      Height = 25
      Caption = '&Agregar'
      TabOrder = 2
      OnClick = btnAgregarClick
    end
    object btnQuitar: TButton
      Left = 356
      Top = 8
      Width = 75
      Height = 25
      Caption = '&Quitar'
      TabOrder = 3
      OnClick = btnQuitarClick
    end
  end
  object sgLineas: TStringGrid
    Left = 0
    Top = 114
    Width = 760
    Height = 250
    Align = alTop
    ColCount = 6
    DefaultRowHeight = 18
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRowSelect]
    TabOrder = 2
    ColWidths = (
      80
      280
      40
      60
      120
      140)
  end
  object pnlTotales: TPanel
    Left = 0
    Top = 364
    Width = 760
    Height = 196
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 3
    object memObs: TMemo
      Left = 8
      Top = 8
      Width = 360
      Height = 100
      MaxLength = 250
      TabOrder = 0
    end
    object chkConfirmar: TCheckBox
      Left = 8
      Top = 116
      Width = 200
      Height = 17
      Caption = 'Confirmar y descontar stock'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object lblSubtotal: TLabel
      Left = 480
      Top = 8
      Width = 120
      Height = 13
      Caption = 'Subtotal:'
    end
    object lblDescuento: TLabel
      Left = 480
      Top = 30
      Width = 120
      Height = 13
      Caption = 'Descuento:'
    end
    object lblFlete: TLabel
      Left = 480
      Top = 52
      Width = 120
      Height = 13
      Caption = 'Flete:'
    end
    object lblNeto: TLabel
      Left = 480
      Top = 74
      Width = 120
      Height = 13
      Caption = 'Neto:'
    end
    object lblIva: TLabel
      Left = 480
      Top = 96
      Width = 120
      Height = 13
      Caption = 'IVA:'
    end
    object lblTotal: TLabel
      Left = 480
      Top = 118
      Width = 120
      Height = 13
      Caption = 'TOTAL:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clNavy
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnGrabar: TButton
      Left = 400
      Top = 156
      Width = 90
      Height = 25
      Caption = '&Grabar'
      TabOrder = 2
      OnClick = btnGrabarClick
    end
    object btnNuevo: TButton
      Left = 500
      Top = 156
      Width = 90
      Height = 25
      Caption = '&Nuevo'
      TabOrder = 3
      OnClick = btnNuevoClick
    end
    object btnCerrar: TButton
      Left = 660
      Top = 156
      Width = 90
      Height = 25
      Caption = 'Ce&rrar'
      TabOrder = 4
      OnClick = btnCerrarClick
    end
  end
end
