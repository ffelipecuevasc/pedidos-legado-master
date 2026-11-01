object DMPrincipal: TDMPrincipal
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Left = 285
  Top = 160
  Height = 340
  Width = 452
  object ssnPrincipal: TDBISAMSession
    EngineVersion = '4.25 Build 4'
    AutoSessionName = False
    SessionName = 'SesPedidos'
    RemoteEncryptionPassword = 'elevatesoft'
    RemotePort = 12005
    Left = 32
    Top = 16
  end
  object dbPedidos: TDBISAMDatabase
    EngineVersion = '4.25 Build 4'
    DatabaseName = 'PEDIDOS'
    Directory = 'C:\PedidosLegado\Datos'
    SessionName = 'SesPedidos'
    Left = 112
    Top = 16
  end
  object tblClientes: TDBISAMTable
    DatabaseName = 'PEDIDOS'
    SessionName = 'SesPedidos'
    EngineVersion = '4.25 Build 4'
    IndexName = 'IDX_RAZON'
    TableName = 'CLIENTES'
    Left = 32
    Top = 80
  end
  object tblProductos: TDBISAMTable
    DatabaseName = 'PEDIDOS'
    SessionName = 'SesPedidos'
    EngineVersion = '4.25 Build 4'
    IndexName = 'IDX_CODIGO'
    TableName = 'PRODUCTOS'
    Left = 112
    Top = 80
  end
  object tblRegiones: TDBISAMTable
    DatabaseName = 'PEDIDOS'
    SessionName = 'SesPedidos'
    EngineVersion = '4.25 Build 4'
    TableName = 'REGIONES'
    Left = 192
    Top = 80
  end
  object qryAux: TDBISAMQuery
    DatabaseName = 'PEDIDOS'
    SessionName = 'SesPedidos'
    EngineVersion = '4.25 Build 4'
    Left = 32
    Top = 152
  end
  object qryAux2: TDBISAMQuery
    DatabaseName = 'PEDIDOS'
    SessionName = 'SesPedidos'
    EngineVersion = '4.25 Build 4'
    Left = 112
    Top = 152
  end
  object qryInforme: TDBISAMQuery
    DatabaseName = 'PEDIDOS'
    SessionName = 'SesPedidos'
    EngineVersion = '4.25 Build 4'
    Left = 192
    Top = 152
  end
  object dsClientes: TDataSource
    DataSet = tblClientes
    Left = 32
    Top = 224
  end
  object dsProductos: TDataSource
    DataSet = tblProductos
    Left = 112
    Top = 224
  end
  object dsRegiones: TDataSource
    DataSet = tblRegiones
    Left = 192
    Top = 224
  end
  object dsInforme: TDataSource
    DataSet = qryInforme
    Left = 272
    Top = 224
  end
end
