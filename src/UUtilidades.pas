unit UUtilidades;

{ Funciones de uso general.
  OJO: no tocar FormatearMonto, la usan los informes de Excel }

interface

uses
  SysUtils, DateUtils, Math;

function LimpiarRut(const Rut: string): string;
function ValidarRut(const Rut: string): Boolean;
function FormatearRut(const Rut: string): string;
function StrAFecha(const S: string): TDateTime;
function FechaAStr(F: TDateTime): string;
function FechaSQL(F: TDateTime): string;
function EsFinDeSemana(F: TDateTime): Boolean;
function SiguienteDiaHabil(F: TDateTime): TDateTime;
function FechaPedido(Momento: TDateTime): TDateTime;
function DiasVencidos(FechaVenc: TDateTime): Integer;
function Redondear(Valor: Double): Double;
function RedondearDec(Valor: Double; Decimales: Integer): Double;
function FormatearMonto(Valor: Double): string;
function FmtPesos(Valor: Double): string;
function SoloNumeros(const S: string): string;
function Rellenar(const S: string; Largo: Integer): string;

implementation

function LimpiarRut(const Rut: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(Rut) do
    if Rut[i] in ['0'..'9', 'K', 'k'] then
      Result := Result + Rut[i];
end;

{ valida rut chileno (modulo 11) }
function ValidarRut(const Rut: string): Boolean;
var
  S, Cuerpo: string;
  Dv, DvCalc: Char;
  i, Suma, Mult, Resto: Integer;
begin
  Result := False;
  S := LimpiarRut(Rut);
  if Length(S) < 2 then
    Exit;
  Cuerpo := Copy(S, 1, Length(S) - 1);
  Dv := S[Length(S)];
  Suma := 0;
  Mult := 2;
  for i := Length(Cuerpo) downto 1 do
  begin
    Suma := Suma + StrToInt(Cuerpo[i]) * Mult;
    Inc(Mult);
    if Mult > 7 then
      Mult := 2;
  end;
  Resto := 11 - (Suma mod 11);
  if Resto = 11 then
    DvCalc := '0'
  else if Resto = 10 then
    DvCalc := 'K'
  else
    DvCalc := Chr(Ord('0') + Resto);
  Result := (Dv = DvCalc);
end;

function FormatearRut(const Rut: string): string;
var
  S, Cuerpo: string;
  i, n: Integer;
begin
  S := UpperCase(LimpiarRut(Rut));
  if Length(S) < 2 then
  begin
    Result := Rut;
    Exit;
  end;
  Cuerpo := Copy(S, 1, Length(S) - 1);
  Result := '';
  n := 0;
  for i := Length(Cuerpo) downto 1 do
  begin
    Result := Cuerpo[i] + Result;
    Inc(n);
    if (n mod 3 = 0) and (i > 1) then
      Result := '.' + Result;
  end;
  Result := Result + '-' + S[Length(S)];
end;

{ convierte texto dd/mm/aa a fecha }
function StrAFecha(const S: string): TDateTime;
var
  d, m, a: Integer;
begin
  d := StrToInt(Copy(S, 1, 2));
  m := StrToInt(Copy(S, 4, 2));
  a := StrToInt(Copy(S, 7, 2));
  if a < 50 then
    a := a + 2000
  else
    a := a + 1900;
  Result := EncodeDate(a, m, d);
end;

function FechaAStr(F: TDateTime): string;
begin
  Result := FormatDateTime('dd/mm/yy', F);
end;

{ formato que acepta DBISAM en el SQL }
function FechaSQL(F: TDateTime): string;
begin
  Result := '''' + FormatDateTime('yyyy-mm-dd', F) + '''';
end;

function EsFinDeSemana(F: TDateTime): Boolean;
begin
  Result := DayOfWeek(F) in [1, 7];
end;

function SiguienteDiaHabil(F: TDateTime): TDateTime;
begin
  Result := Trunc(F) + 1;
  while DayOfWeek(Result) in [1, 7] do   // 1=domingo 7=sabado
    Result := Result + 1;
  // TODO: revisar tabla FERIADOS
end;

{ los pedidos que entran tarde se despachan al otro dia }
function FechaPedido(Momento: TDateTime): TDateTime;
begin
  if HourOf(Momento) >= 18 then
    Result := SiguienteDiaHabil(Momento)
  else
    Result := Trunc(Momento);
end;

function DiasVencidos(FechaVenc: TDateTime): Integer;
begin
  Result := Trunc(Date) - Trunc(FechaVenc);
end;

{ redondeo al peso }
function Redondear(Valor: Double): Double;
begin
  Result := Round(Valor);
end;

function RedondearDec(Valor: Double; Decimales: Integer): Double;
var
  f: Double;
begin
  f := Power(10, Decimales);
  Result := Int(Valor * f + 0.5) / f;
end;

function FormatearMonto(Valor: Double): string;
begin
  Result := '$ ' + FormatFloat('#,##0', Valor);
end;

{ igual que FormatearMonto pero sin espacio (para el ticket) }
function FmtPesos(Valor: Double): string;
begin
  Result := '$' + FormatFloat('###,###,##0', Redondear(Valor));
end;

function SoloNumeros(const S: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(S) do
    if S[i] in ['0'..'9'] then
      Result := Result + S[i];
end;

function Rellenar(const S: string; Largo: Integer): string;
begin
  Result := S;
  while Length(Result) < Largo do
    Result := Result + ' ';
  if Length(Result) > Largo then
    Result := Copy(Result, 1, Largo);
end;

end.
