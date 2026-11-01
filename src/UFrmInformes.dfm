object FrmInformes: TFrmInformes
  Left = 200
  Top = 100
  Width = 800
  Height = 560
  Caption = 'Informe de Ventas'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlFiltros: TPanel
    Left = 0
    Top = 0
    Width = 792
    Height = 65
    Align = alTop
    TabOrder = 0
    object lblDesde: TLabel
      Left = 8
      Top = 8
      Width = 100
      Height = 13
      Caption = 'Desde (dd/mm/aa)'
    end
    object edtDesde: TEdit
      Left = 8
      Top = 24
      Width = 80
      Height = 21
      TabOrder = 0
    end
    object lblHasta: TLabel
      Left = 100
      Top = 8
      Width = 100
      Height = 13
      Caption = 'Hasta (dd/mm/aa)'
    end
    object edtHasta: TEdit
      Left = 100
      Top = 24
      Width = 80
      Height = 21
      TabOrder = 1
    end
    object lblRegion: TLabel
      Left = 192
      Top = 8
      Width = 100
      Height = 13
      Caption = 'Regi'#243'n'
    end
    object cmbRegion: TComboBox
      Left = 192
      Top = 24
      Width = 150
      Height = 21
      ItemHeight = 13
      TabOrder = 2
    end
    object lblCliente: TLabel
      Left = 352
      Top = 8
      Width = 100
      Height = 13
      Caption = 'Cliente contiene'
    end
    object edtCliente: TEdit
      Left = 352
      Top = 24
      Width = 150
      Height = 21
      TabOrder = 3
    end
    object chkAnulados: TCheckBox
      Left = 512
      Top = 28
      Width = 110
      Height = 21
      Caption = 'Incluir anulados'
      TabOrder = 4
    end
    object btnGenerar: TButton
      Left = 628
      Top = 22
      Width = 75
      Height = 25
      Caption = '&Generar'
      Default = True
      OnClick = btnGenerarClick
      TabOrder = 5
    end
    object btnExportar: TButton
      Left = 708
      Top = 22
      Width = 75
      Height = 25
      Caption = '&Exportar'
      OnClick = btnExportarClick
      TabOrder = 6
    end
  end
  object dbgInforme: TDBGrid
    Left = 0
    Top = 65
    Width = 792
    Height = 400
    Align = alClient
    DataSource = DMPrincipal.dsInforme
    ReadOnly = True
    TabOrder = 1
  end
  object pnlResumen: TPanel
    Left = 0
    Top = 465
    Width = 792
    Height = 61
    Align = alBottom
    TabOrder = 2
    object lblCantPedidos: TLabel
      Left = 8
      Top = 8
      Width = 100
      Height = 13
      Caption = 'Pedidos:'
    end
    object lblTotNeto: TLabel
      Left = 160
      Top = 8
      Width = 100
      Height = 13
      Caption = 'Neto:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblTotIva: TLabel
      Left = 360
      Top = 8
      Width = 100
      Height = 13
      Caption = 'IVA:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblTotTotal: TLabel
      Left = 520
      Top = 8
      Width = 100
      Height = 13
      Caption = 'Total:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnCerrar: TButton
      Left = 704
      Top = 30
      Width = 75
      Height = 25
      Caption = 'Ce&rrar'
      OnClick = btnCerrarClick
      TabOrder = 0
    end
  end
end
