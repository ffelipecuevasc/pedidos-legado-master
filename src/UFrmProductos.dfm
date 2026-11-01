object FrmProductos: TFrmProductos
  Left = 240
  Top = 130
  BorderStyle = bsDialog
  Caption = 'Productos'
  ClientHeight = 470
  ClientWidth = 680
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object dbgProductos: TDBGrid
    Left = 0
    Top = 0
    Width = 680
    Height = 200
    Align = alTop
    DataSource = DMPrincipal.dsProductos
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgRowSelect]
    ReadOnly = True
    TabOrder = 0
    OnDrawColumnCell = dbgProductosDrawColumnCell
  end
  object pnlDatos: TPanel
    Left = 0
    Top = 200
    Width = 680
    Height = 150
    Align = alTop
    TabOrder = 1
    object lblCodigo: TLabel
      Left = 8
      Top = 8
      Width = 60
      Height = 13
      Caption = 'C'#243'digo'
    end
    object dbeCodigo: TDBEdit
      Left = 8
      Top = 24
      Width = 100
      Height = 21
      DataField = 'CODIGO'
      DataSource = DMPrincipal.dsProductos
      TabOrder = 0
    end
    object lblDescripcion: TLabel
      Left = 228
      Top = 8
      Width = 60
      Height = 13
      Caption = 'Descripci'#243'n'
    end
    object dbeDescripcion: TDBEdit
      Left = 228
      Top = 24
      Width = 300
      Height = 21
      DataField = 'DESCRIPCION'
      DataSource = DMPrincipal.dsProductos
      TabOrder = 1
    end
    object lblCategoria: TLabel
      Left = 448
      Top = 8
      Width = 60
      Height = 13
      Caption = 'Categor'#237'a'
    end
    object dbcCategoria: TDBComboBox
      Left = 448
      Top = 24
      Width = 60
      Height = 21
      DataField = 'CATEGORIA'
      DataSource = DMPrincipal.dsProductos
      TabOrder = 2
    end
    object lblPrecio: TLabel
      Left = 8
      Top = 56
      Width = 60
      Height = 13
      Caption = 'Precio'
    end
    object dbePrecio: TDBEdit
      Left = 8
      Top = 72
      Width = 90
      Height = 21
      DataField = 'PRECIO'
      DataSource = DMPrincipal.dsProductos
      TabOrder = 3
    end
    object lblStock: TLabel
      Left = 228
      Top = 56
      Width = 60
      Height = 13
      Caption = 'Stock'
    end
    object dbeStock: TDBEdit
      Left = 228
      Top = 72
      Width = 60
      Height = 21
      DataField = 'STOCK'
      DataSource = DMPrincipal.dsProductos
      TabOrder = 4
    end
    object lblMinimo: TLabel
      Left = 448
      Top = 56
      Width = 60
      Height = 13
      Caption = 'Stock m'#237'nimo'
    end
    object dbeMinimo: TDBEdit
      Left = 448
      Top = 72
      Width = 60
      Height = 21
      DataField = 'STOCK_MINIMO'
      DataSource = DMPrincipal.dsProductos
      TabOrder = 5
    end
    object dbkActivo: TDBCheckBox
      Left = 8
      Top = 112
      Width = 97
      Height = 17
      Caption = 'Activo'
      DataField = 'ACTIVO'
      DataSource = DMPrincipal.dsProductos
      TabOrder = 6
    end
    object navProductos: TDBNavigator
      Left = 420
      Top = 108
      Width = 240
      Height = 25
      DataSource = DMPrincipal.dsProductos
      TabOrder = 7
    end
  end
  object grpPrecios: TGroupBox
    Left = 8
    Top = 356
    Width = 440
    Height = 65
    Caption = ' Reajuste de precios '
    TabOrder = 2
    object lblPorc: TLabel
      Left = 12
      Top = 28
      Width = 8
      Height = 13
      Caption = '%'
    end
    object edtPorc: TEdit
      Left = 28
      Top = 24
      Width = 60
      Height = 21
      TabOrder = 0
    end
    object cmbCategoria: TComboBox
      Left = 100
      Top = 24
      Width = 100
      Height = 21
      ItemHeight = 13
      TabOrder = 1
    end
    object btnActualizar: TButton
      Left = 216
      Top = 22
      Width = 90
      Height = 25
      Caption = 'Actualizar'
      TabOrder = 2
      OnClick = btnActualizarClick
    end
  end
  object btnCerrar: TButton
    Left = 592
    Top = 432
    Width = 80
    Height = 25
    Caption = 'Ce&rrar'
    TabOrder = 3
    OnClick = btnCerrarClick
  end
end
