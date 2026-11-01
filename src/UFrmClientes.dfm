object FrmClientes: TFrmClientes
  Left = 220
  Top = 120
  BorderStyle = bsDialog
  Caption = 'Mantenci'#243'n de Clientes'
  ClientHeight = 520
  ClientWidth = 720
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
  object pnlBuscar: TPanel
    Left = 0
    Top = 0
    Width = 720
    Height = 37
    Align = alTop
    TabOrder = 0
    object lblBuscar: TLabel
      Left = 8
      Top = 12
      Width = 36
      Height = 13
      Caption = 'Buscar:'
    end
    object edtBuscar: TEdit
      Left = 56
      Top = 8
      Width = 260
      Height = 21
      TabOrder = 0
    end
    object btnBuscar: TButton
      Left = 324
      Top = 6
      Width = 75
      Height = 25
      Caption = 'Buscar'
      Default = True
      TabOrder = 1
      OnClick = btnBuscarClick
    end
  end
  object dbgClientes: TDBGrid
    Left = 0
    Top = 37
    Width = 720
    Height = 180
    Align = alTop
    DataSource = DMPrincipal.dsClientes
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect]
    ReadOnly = True
    TabOrder = 1
    Columns = <
      item
        FieldName = 'RUT'
        Width = 90
        Visible = True
      end
      item
        FieldName = 'RAZON_SOCIAL'
        Width = 260
        Visible = True
      end
      item
        FieldName = 'COMUNA'
        Width = 120
        Visible = True
      end
      item
        FieldName = 'TIPO'
        Width = 40
        Visible = True
      end
      item
        FieldName = 'DEUDA_VENCIDA'
        Width = 90
        Visible = True
      end>
  end
  object pnlDatos: TPanel
    Left = 0
    Top = 217
    Width = 720
    Height = 262
    Align = alClient
    TabOrder = 2
    object lblRut: TLabel
      Left = 8
      Top = 12
      Width = 60
      Height = 13
      Caption = 'RUT'
    end
    object dbeRut: TDBEdit
      Left = 8
      Top = 28
      Width = 120
      Height = 21
      DataField = 'RUT'
      DataSource = DMPrincipal.dsClientes
      TabOrder = 0
    end
    object lblRazon: TLabel
      Left = 8
      Top = 60
      Width = 60
      Height = 13
      Caption = 'Raz'#243'n social'
    end
    object dbeRazon: TDBEdit
      Left = 8
      Top = 76
      Width = 300
      Height = 21
      DataField = 'RAZON_SOCIAL'
      DataSource = DMPrincipal.dsClientes
      TabOrder = 1
    end
    object lblDireccion: TLabel
      Left = 8
      Top = 108
      Width = 60
      Height = 13
      Caption = 'Direcci'#243'n'
    end
    object dbeDireccion: TDBEdit
      Left = 8
      Top = 124
      Width = 300
      Height = 21
      DataField = 'DIRECCION'
      DataSource = DMPrincipal.dsClientes
      TabOrder = 2
    end
    object lblComuna: TLabel
      Left = 8
      Top = 156
      Width = 60
      Height = 13
      Caption = 'Comuna'
    end
    object dbeComuna: TDBEdit
      Left = 8
      Top = 172
      Width = 160
      Height = 21
      DataField = 'COMUNA'
      DataSource = DMPrincipal.dsClientes
      TabOrder = 3
    end
    object lblRegion: TLabel
      Left = 8
      Top = 204
      Width = 60
      Height = 13
      Caption = 'Regi'#243'n'
    end
    object dblRegion: TDBLookupComboBox
      Left = 8
      Top = 220
      Width = 200
      Height = 21
      DataField = 'COD_REGION'
      DataSource = DMPrincipal.dsClientes
      KeyField = 'COD_REGION'
      ListField = 'NOMBRE'
      ListSource = DMPrincipal.dsRegiones
      TabOrder = 4
    end
    object lblTipo: TLabel
      Left = 368
      Top = 12
      Width = 60
      Height = 13
      Caption = 'Tipo (N/V)'
    end
    object dbcTipo: TDBComboBox
      Left = 368
      Top = 28
      Width = 50
      Height = 21
      DataField = 'TIPO'
      DataSource = DMPrincipal.dsClientes
      ItemHeight = 13
      TabOrder = 5
    end
    object lblTelefono: TLabel
      Left = 368
      Top = 60
      Width = 60
      Height = 13
      Caption = 'Tel'#233'fono'
    end
    object dbeTelefono: TDBEdit
      Left = 368
      Top = 76
      Width = 140
      Height = 21
      DataField = 'TELEFONO'
      DataSource = DMPrincipal.dsClientes
      TabOrder = 6
    end
    object lblEmail: TLabel
      Left = 368
      Top = 108
      Width = 60
      Height = 13
      Caption = 'Email'
    end
    object dbeEmail: TDBEdit
      Left = 368
      Top = 124
      Width = 220
      Height = 21
      DataField = 'EMAIL'
      DataSource = DMPrincipal.dsClientes
      TabOrder = 7
    end
    object lblDeuda: TLabel
      Left = 368
      Top = 156
      Width = 60
      Height = 13
      Caption = 'Deuda vencida'
    end
    object dbeDeuda: TDBEdit
      Left = 368
      Top = 172
      Width = 100
      Height = 21
      DataField = 'DEUDA_VENCIDA'
      DataSource = DMPrincipal.dsClientes
      TabOrder = 8
    end
    object lblFechaVenc: TLabel
      Left = 368
      Top = 204
      Width = 60
      Height = 13
      Caption = 'Vencimiento'
    end
    object dbeFechaVenc: TDBEdit
      Left = 368
      Top = 220
      Width = 80
      Height = 21
      DataField = 'FECHA_VENC_DEUDA'
      DataSource = DMPrincipal.dsClientes
      TabOrder = 9
    end
    object dbkActivo: TDBCheckBox
      Left = 600
      Top = 220
      Width = 97
      Height = 17
      Caption = 'Activo'
      DataField = 'ACTIVO'
      DataSource = DMPrincipal.dsClientes
      TabOrder = 10
      ValueChecked = 'True'
      ValueUnchecked = 'False'
    end
  end
  object pnlBotones: TPanel
    Left = 0
    Top = 479
    Width = 720
    Height = 41
    Align = alBottom
    TabOrder = 3
    object btnNuevo: TButton
      Left = 8
      Top = 8
      Width = 80
      Height = 25
      Caption = '&Nuevo'
      TabOrder = 0
      OnClick = btnNuevoClick
    end
    object btnGuardar: TButton
      Left = 96
      Top = 8
      Width = 80
      Height = 25
      Caption = '&Guardar'
      TabOrder = 1
      OnClick = btnGuardarClick
    end
    object btnCancelar: TButton
      Left = 184
      Top = 8
      Width = 80
      Height = 25
      Caption = '&Cancelar'
      TabOrder = 2
      OnClick = btnCancelarClick
    end
    object btnEliminar: TButton
      Left = 272
      Top = 8
      Width = 80
      Height = 25
      Caption = '&Eliminar'
      TabOrder = 3
      OnClick = btnEliminarClick
    end
    object btnCerrar: TButton
      Left = 632
      Top = 8
      Width = 80
      Height = 25
      Caption = 'Ce&rrar'
      TabOrder = 4
      OnClick = btnCerrarClick
    end
  end
end
