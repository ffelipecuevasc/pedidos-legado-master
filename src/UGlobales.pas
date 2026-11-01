unit UGlobales;

{ Variables globales del sistema
  Ult. modif: 14/03/2008 JPV }

interface

uses
  SysUtils;

const
  VERSION_SISTEMA = '2.3.1';
  REGION_METROPOLITANA = 13;
  MAX_LINEAS_PEDIDO = 25;

var
  gUsuarioActual: string = '';
  gNivelUsuario: Integer = 0;        // 0=vendedor 1=supervisor 9=admin
  gTasaIva: Double = 19;             // se carga desde PARAMETROS al iniciar
  gMinimoPedido: Double = 30000;
  gPedidoActual: Integer = 0;
  gModoEdicion: Boolean = False;
  gDirDatos: string = 'C:\PedidosLegado\Datos';
  gDirTickets: string = 'C:\PedidosLegado\Tickets';
  gImprimirAlGrabar: Boolean = True;
  gUltimoError: string = '';
  gNombreEmpresa: string = '';

implementation

end.
