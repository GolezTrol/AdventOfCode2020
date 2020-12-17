program d14_1_bal_masque;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Windows, System.SysUtils, Classes, RegularExpressions,
  System.Diagnostics, System.Generics.Collections;

type
  TAddress = Int64;
  TValue = Int64;
  TMask = record
    AndValue: TValue;
    OrValue: TValue;
    constructor Create(const Mask: String);
    function ApplyTo(const Value: TValue): TValue;
  end;
  TMemory = class(TDictionary<TAddress, TValue>)
    procedure Write(const Address: TAddress; const Value: TValue; const Mask: TMask);
  end;

function SetBit(const Value: TValue; const Index: Integer; const Bit: Boolean): TValue;
var
  Rec: Int64Rec;
  h, i: Integer;
begin
  Rec := Int64Rec(Value);
  i := Index;
  h := 0;
  if i > 31 then
  begin
    i := i - 32;
    h := 1;
  end;
  if Bit then
    Rec.Cardinals[h] := Rec.Cardinals[h] or (Cardinal(1) shl i)
  else
    Rec.Cardinals[h] := Rec.Cardinals[h] and not (Cardinal(1) shl i);
  Result := Int64(Rec);
end;

function AsBin(Value: TValue): String;
var
  i: Integer;
begin
  SetLength(Result, 36);
  for i := 0 to 35 do
    if Value and SetBit(0, i, True) <> 0 then
      Result[36-i] := '1'
    else
      Result[36-i] := '0';
end;

{ TMask }

function TMask.ApplyTo(const Value: TValue): TValue;
begin
  Result := (Value and AndValue) or OrValue;
end;

constructor TMask.Create(const Mask: String);
var
  i: Integer;
  c: Char;
begin
  AndValue := $FFFFFFFFF;
  OrValue := 0;
  for i := 0 to 35 do
  begin
    c := Mask[36-i];
    if c = '0' then
      AndValue := SetBit(AndValue, i, False)
    else if c = '1' then
      OrValue := SetBit(OrValue, i, True);
  end;
end;

{ TMemory }

procedure TMemory.Write(const Address: TAddress; const Value: TValue; const Mask: TMask);
var
  Masked: TValue;
begin
  Masked := Mask.ApplyTo(Value);
  WriteLn(Value, ' -> ', Masked);
  Self.AddOrSetValue(Address, Masked);
end;

var
  Input: TStringList;
  i, p: Integer;
  Mask: TMask;
  Memory: TMemory;
  Address: TAddress;
  Value: TValue;
  Sum: TValue;
  Line: String;
begin
  Memory := TMemory.Create();
  Input := TStringList.Create;
  try
    Input.LoadFromFile(ParamStr(1));
    for i := 0 to Input.Count - 1 do
    begin
      Line := Input[i];

      if Copy(Line, 1, 7) = 'mask = ' then
        Mask := TMask.Create(Copy(Line, 8, 36))
      else
      begin
        p := Pos(']', Line);
        Address := Copy(Line, 5, p - 5).ToInt64();
        Value := Copy(Line, p + 4, 100).ToInt64();
        Memory.Write(Address, Value, Mask);
      end;

    end;

    Sum := 0;
    for Value in Memory.Values do
      Sum := Sum + Value;

    WriteLn(Sum);

  finally
    Input.Free;
  end;

  if IsDebuggerPresent then ReadLn;
end.
